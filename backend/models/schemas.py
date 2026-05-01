from pydantic import BaseModel, Field
from typing import List, Optional, Literal
from datetime import date

class ChatRequest(BaseModel):
    message: str = Field(..., max_length=500)
    language: Literal["en", "hi", "te"] = "en"
    session_id: Optional[str] = None

class ChatResponse(BaseModel):
    reply: str
    intent: Optional[str] = None
    payload: Optional[dict] = None

class EligibilityRequest(BaseModel):
    dob: date

class EligibilityResponse(BaseModel):
    eligible: bool
    message: str

class QuizQuestion(BaseModel):
    id: int
    question: str
    options: List[str]
    answer_index: int
    explanation: str

class QuizResponse(BaseModel):
    questions: List[QuizQuestion]

class FeedbackRequest(BaseModel):
    session_id: str
    rating: int = Field(..., ge=1, le=5)
    comment: str = Field("", max_length=1000)

class FeedbackResponse(BaseModel):
    success: bool
