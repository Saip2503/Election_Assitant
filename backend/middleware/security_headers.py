from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request


class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        response = await call_next(request)
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["X-XSS-Protection"] = "1; mode=block"
        response.headers["Referrer-Policy"] = "strict-origin-when-cross-origin"
        response.headers["Permissions-Policy"] = "geolocation=(), microphone=(), camera=()"
        response.headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
        response.headers["Content-Security-Policy"] = (
            "default-src 'self'; "
            "script-src 'self' 'unsafe-inline' 'unsafe-eval' blob: https://*.google.com https://*.googleapis.com https://*.gstatic.com; "
            "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://accounts.google.com; "
            "font-src 'self' https://fonts.gstatic.com; "
            "img-src 'self' data: blob: https://*.googleusercontent.com https://www.gstatic.com https://upload.wikimedia.org https://*.googleapis.com https://*.gstatic.com; "
            "connect-src 'self' http://localhost:8080 https://*.google.com https://*.googleapis.com https://*.google-analytics.com https://*.gstatic.com https://upload.wikimedia.org https://*.googleusercontent.com; "
            "worker-src 'self' blob:; "
            "child-src 'self' blob:; "
            "object-src 'none';"
        )
        return response
