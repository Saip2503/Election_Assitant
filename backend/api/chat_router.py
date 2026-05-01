import re
import html
from fastapi import APIRouter, HTTPException, Request
from slowapi import Limiter
from slowapi.util import get_remote_address

from models.schemas import (
    ChatRequest, ChatResponse,
    EligibilityRequest, EligibilityResponse,
    QuizResponse, FeedbackRequest, FeedbackResponse,
)
from services.vertex_ai_service import VertexAIService
from services.workflow_service import WorkflowService
from services.firestore_service import FirestoreService

router = APIRouter()
limiter = Limiter(key_func=get_remote_address)
vertex_service = VertexAIService()

_MAX_MESSAGE_LEN = 500
_HTML_TAG_RE = re.compile(r"<[^>]+>")


def _sanitize(text: str) -> str:
    """Strip HTML tags, unescape entities, trim, enforce max length."""
    text = _HTML_TAG_RE.sub("", text)
    text = html.unescape(text)
    return text.strip()[:_MAX_MESSAGE_LEN]


@router.post("/chat", response_model=ChatResponse)
@limiter.limit("5/minute")
async def chat_endpoint(request: Request, body: ChatRequest):
    """AI chat — rate limited to 5 req/min per IP."""
    message = _sanitize(body.message)
    if not message:
        raise HTTPException(status_code=422, detail="Message cannot be empty.")

    try:
        reply, intent = await vertex_service.generate_reply(
            message, body.language, session_id=body.session_id or "anonymous"
        )
    except Exception:
        raise HTTPException(status_code=503, detail="AI service temporarily unavailable.")

    payload = None
    if intent == "quiz":
        payload = {"questions": [q.dict() for q in WorkflowService.get_quiz()]}
    elif intent == "booth_finder":
        payload = WorkflowService.get_mock_location()
    elif intent == "candidates":
        payload = {"candidates": WorkflowService.get_mock_candidates()}

    return ChatResponse(reply=reply, intent=intent, payload=payload)


@router.get("/quiz", response_model=QuizResponse)
async def get_quiz():
    return QuizResponse(questions=WorkflowService.get_quiz())


@router.post("/eligibility", response_model=EligibilityResponse)
@limiter.limit("10/minute")
async def check_eligibility(request: Request, body: EligibilityRequest):
    return WorkflowService.check_eligibility(body.dob)


@router.get("/elections/schedule")
async def get_election_schedule():
    return WorkflowService.get_election_schedule()


@router.get("/health/sessions")
async def sessions_health():
    from services.session_store import session_store
    purged = session_store.purge_expired()
    return {"active_sessions": session_store.active_count, "purged": purged}


@router.post("/feedback", response_model=FeedbackResponse)
@limiter.limit("3/minute")
async def submit_feedback(request: Request, body: FeedbackRequest):
    success = FirestoreService.save_feedback(body.session_id, body.rating, body.comment)
    return FeedbackResponse(success=success)


@router.get("/quiz/leaderboard")
async def get_leaderboard():
    return {"leaderboard": FirestoreService.get_leaderboard()}
