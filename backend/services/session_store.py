"""
In-memory session store for Vertex AI ChatSession objects.
Sessions expire after TTL_SECONDS of inactivity to prevent memory leaks.
"""

import time
from typing import Optional, Any


_TTL_SECONDS = 30 * 60  # 30 minutes


class _SessionStore:
    def __init__(self):
        self._sessions: dict[str, tuple[Any, float]] = {}

    def get(self, session_id: str) -> Optional[Any]:
        entry = self._sessions.get(session_id)
        if entry is None:
            return None
        obj, last_access = entry
        if time.monotonic() - last_access > _TTL_SECONDS:
            del self._sessions[session_id]
            return None
        # Refresh TTL on access
        self._sessions[session_id] = (obj, time.monotonic())
        return obj

    def set(self, session_id: str, session: Any) -> None:
        self._sessions[session_id] = (session, time.monotonic())

    def delete(self, session_id: str) -> None:
        self._sessions.pop(session_id, None)

    def purge_expired(self) -> int:
        now = time.monotonic()
        expired = [k for k, (_, t) in self._sessions.items() if now - t > _TTL_SECONDS]
        for k in expired:
            del self._sessions[k]
        return len(expired)

    @property
    def active_count(self) -> int:
        return len(self._sessions)


# Module-level singleton
session_store = _SessionStore()
