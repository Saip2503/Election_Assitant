import os
import time
import vertexai
from vertexai.generative_models import GenerativeModel, Content, Part, ChatSession
from typing import Tuple, Optional, AsyncIterator
from services.session_store import session_store
from services.election_data_service import election_data_service

_MODEL_NAME = "gemini-2.5-flash"

_SYSTEM_PROMPT = """\
You are Election Dost, a neutral, helpful, and empathetic assistant for the
Election Commission of India (ECI). Your mission is to educate Indian citizens
about the democratic process — registration, voting, EVMs, candidates, and forms.

LANGUAGE RULE: Always respond natively in the requested language:
  - "en" → English  |  "hi" → Hindi  |  "te" → Telugu

STRICT CONTENT RULES:
1. Never express partisan opinions or favour any political party.
2. For geographic context, default to New Panvel, Panvel (188), Maharashtra, 2026.
3. Keep responses concise (≤3 paragraphs for prose; use bullet points for steps).
4. Always cite the official ECI Voter Portal (voters.eci.gov.in/Homepage) for all forms and registration.

INTENT TAGGING — append EXACTLY ONE tag when the user's need maps to a widget:
  [INTENT:eligibility_check]  → age / registration eligibility questions
  [INTENT:evm_walkthrough]    → how to vote / EVM / VVPAT
  [INTENT:form6]              → new voter registration
  [INTENT:form8]              → update address / name / photo
  [INTENT:booth_finder]       → find polling station / booth
  [INTENT:candidates]         → candidate profiles / manifesto
  [INTENT:quiz]               → test knowledge / civic quiz

EXAMPLES:
  User: "Am I old enough to vote?" → reply + [INTENT:eligibility_check]
  User: "How do I press the button on the machine?" → reply + [INTENT:evm_walkthrough]
  User: "Show me who is running in Panvel" → reply + [INTENT:candidates]
"""


class VertexAIService:
    def __init__(self):
        project_id = os.environ.get("VERTEX_AI_PROJECT_ID", "election-assistant-2026")
        location = os.environ.get("VERTEX_AI_LOCATION", "us-central1")
        vertexai.init(project=project_id, location=location)
        self._model = GenerativeModel(
            _MODEL_NAME,
            system_instruction=_SYSTEM_PROMPT,
        )

    def _get_or_create_session(self, session_id: str) -> ChatSession:
        session = session_store.get(session_id)
        if session is None:
            session = self._model.start_chat()
            session_store.set(session_id, session)
        return session

    async def generate_reply(
        self, message: str, language: str, session_id: str = "default"
    ) -> Tuple[str, Optional[str]]:
        """Stateful multi-turn reply. Returns (cleaned_text, intent | None)."""
        chat = self._get_or_create_session(session_id)
        
        # Get real-time election context from Kaggle dataset
        election_context = election_data_service.get_context_for_ai(message)
        
        prompt = (
            f"ELECTION DATA CONTEXT: {election_context}\n\n"
            f"[LANGUAGE:{language.upper()}]\n"
            f"User Query: {message}"
        )

        try:
            response = chat.send_message(prompt)
            reply_text = response.text
        except Exception as exc:
            # Log and return a safe fallback
            import logging
            logging.getLogger("election_assistant").error(f"Vertex AI error: {exc}")
            return (
                "I'm having trouble reaching the AI service right now. "
                "Please try again in a moment, or call the ECI Voter Helpline: 1950.",
                None,
            )

        # Extract intent tag
        detected_intent: Optional[str] = None
        intents = [
            "eligibility_check", "evm_walkthrough", "form6", "form8",
            "booth_finder", "candidates", "quiz",
        ]
        for intent in intents:
            tag = f"[INTENT:{intent}]"
            if tag in reply_text:
                detected_intent = intent
                reply_text = reply_text.replace(tag, "").strip()
                break

        return reply_text, detected_intent

    async def stream_reply(
        self, message: str, language: str, session_id: str = "default"
    ) -> AsyncIterator[str]:
        """Streaming version — yields text chunks as they arrive."""
        chat = self._get_or_create_session(session_id)
        prompt = f"[LANGUAGE:{language.upper()}]\n{message}"

        try:
            responses = chat.send_message(prompt, stream=True)
            for chunk in responses:
                if chunk.text:
                    yield chunk.text
        except Exception as exc:
            import logging
            logging.getLogger("election_assistant").error(f"Stream error: {exc}")
            yield "I'm unable to respond right now. Please try again or call 1950."
