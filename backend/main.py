import os
import sentry_sdk
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.staticfiles import StaticFiles
from dotenv import load_dotenv

from api.chat_router import router as chat_router, limiter
from api.streaming_router import router as streaming_router
from api.data_router import router as data_router
from middleware.logging_middleware import LoggingMiddleware
from middleware.security_headers import SecurityHeadersMiddleware
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded

load_dotenv()

# ── Sentry (production error tracking) ───────────────────────────────────────
sentry_dsn = os.environ.get("SENTRY_DSN")
if sentry_dsn:
    sentry_sdk.init(
        dsn=sentry_dsn,
        traces_sample_rate=0.2,
        environment=os.environ.get("ENV", "production"),
    )

# ── Allowed origins ───────────────────────────────────────────────────────────
_ALLOWED_ORIGINS = [o.strip() for o in os.environ.get(
    "ALLOWED_ORIGINS",
    "*"
).split(",") if o.strip()]

app = FastAPI(
    title="Election Education Assistant API",
    version="1.0.0",
    docs_url="/api/docs",
    redoc_url="/api/redoc",
    openapi_url="/api/openapi.json",
)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# ── Middleware (order matters: Request goes Bottom -> Top) ───────────────────
app.add_middleware(GZipMiddleware, minimum_size=1000)
app.add_middleware(SecurityHeadersMiddleware)
app.add_middleware(LoggingMiddleware)
app.add_middleware(
    CORSMiddleware,
    allow_origins=_ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
    expose_headers=["*"],
)

# ── Routers ───────────────────────────────────────────────────────────────────
app.include_router(chat_router, prefix="/api")
app.include_router(streaming_router, prefix="/api")
app.include_router(data_router)


@app.get("/health", tags=["ops"])
async def health():
    return {
        "status": "ok",
        "version": app.version,
        "environment": os.environ.get("ENV", "production"),
    }


# ── Static Flutter Web ────────────────────────────────────────────────────────
static_dir = os.path.join(os.path.dirname(__file__), "static")
if os.path.exists(static_dir):
    # Catch-all to serve index.html for Flutter SPA routing
    from fastapi.responses import FileResponse
    
    @app.get("/{full_path:path}")
    async def serve_flutter(full_path: str):
        # Skip API routes
        if full_path.startswith("api/"):
            raise HTTPException(status_code=404)
        
        # Check if requested file exists in static dir
        file_path = os.path.join(static_dir, full_path)
        if full_path and os.path.isfile(file_path):
            # Explicitly set media types for critical files to avoid MIME errors
            media_type = None
            if full_path.endswith(".js"):
                media_type = "application/javascript"
            elif full_path.endswith(".json"):
                media_type = "application/json"
            return FileResponse(file_path, media_type=media_type)
        
        # Return index.html for all other routes (SPA)
        index_path = os.path.join(static_dir, "index.html")
        if os.path.isfile(index_path):
            return FileResponse(index_path)
        
        return {"error": "Frontend assets not found. Build may have failed."}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
