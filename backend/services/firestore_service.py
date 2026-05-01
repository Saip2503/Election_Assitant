"""
Firestore service for persisting quiz scores, session metadata, and feedback.
"""

import os
import logging
from datetime import datetime, timezone
from typing import Optional

logger = logging.getLogger("election_assistant")

try:
    from google.cloud import firestore
    _db = firestore.Client(project=os.environ.get("GCP_PROJECT_ID", "election-assistant-2026"))
    _FIRESTORE_ENABLED = True
except Exception as exc:
    logger.warning(f"Firestore unavailable (running locally?): {exc}")
    _db = None
    _FIRESTORE_ENABLED = False


class FirestoreService:
    @staticmethod
    def save_quiz_score(session_id: str, score: int, total: int) -> bool:
        if not _FIRESTORE_ENABLED or _db is None:
            return False
        try:
            _db.collection("quiz_scores").add({
                "session_id": session_id,
                "score": score,
                "total": total,
                "percentage": round((score / total) * 100, 1) if total else 0,
                "timestamp": datetime.now(timezone.utc),
            })
            return True
        except Exception as exc:
            logger.error(f"Firestore save_quiz_score failed: {exc}")
            return False

    @staticmethod
    def get_leaderboard(limit: int = 10) -> list[dict]:
        if not _FIRESTORE_ENABLED or _db is None:
            return []
        try:
            docs = (
                _db.collection("quiz_scores")
                .order_by("percentage", direction=firestore.Query.DESCENDING)
                .limit(limit)
                .stream()
            )
            return [d.to_dict() for d in docs]
        except Exception as exc:
            logger.error(f"Firestore get_leaderboard failed: {exc}")
            return []

    @staticmethod
    def save_feedback(session_id: str, rating: int, comment: str) -> bool:
        if not _FIRESTORE_ENABLED or _db is None:
            return False
        try:
            _db.collection("feedback").add({
                "session_id": session_id,
                "rating": rating,
                "comment": comment,
                "timestamp": datetime.now(timezone.utc),
            })
            return True
        except Exception as exc:
            logger.error(f"Firestore save_feedback failed: {exc}")
            return False
