"""
Streaming SSE endpoint for real-time AI responses.
"""

import asyncio
from fastapi import APIRouter, Request
from fastapi.responses import StreamingResponse
from slowapi import Limiter
from slowapi.util import get_remote_address

from models.schemas import ChatRequest
from services.vertex_ai_service import VertexAIService

router = APIRouter()
limiter = Limiter(key_func=get_remote_address)
vertex_service = VertexAIService()


@router.post("/chat/stream")
@limiter.limit("5/minute")
async def stream_chat(request: Request, body: ChatRequest):
    """Server-Sent Events endpoint for streaming AI responses."""

    async def event_generator():
        try:
            async for chunk in vertex_service.stream_reply(
                body.message, body.language, session_id=body.session_id or "anonymous"
            ):
                # SSE format: data: <payload>\n\n
                yield f"data: {chunk}\n\n"
        except asyncio.CancelledError:
            pass
        finally:
            yield "data: [DONE]\n\n"

    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "X-Accel-Buffering": "no",
        },
    )
