"""
Integration tests for the FastAPI application.
Tests all public API endpoints for correct behavior and edge cases.
"""
import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)


# ── Health ────────────────────────────────────────────────────────────────────
def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "ok"
    assert "version" in data


# ── Eligibility ───────────────────────────────────────────────────────────────
def test_eligibility_eligible():
    response = client.post("/api/eligibility", json={"dob": "2000-01-01"})
    assert response.status_code == 200
    data = response.json()
    assert data["eligible"] is True
    assert "eligible to vote" in data["message"]


def test_eligibility_not_eligible():
    response = client.post("/api/eligibility", json={"dob": "2015-01-01"})
    assert response.status_code == 200
    data = response.json()
    assert data["eligible"] is False
    assert "must be 18 to vote" in data["message"]


def test_eligibility_invalid_date_format():
    """Malformed date should return 422 Unprocessable Entity."""
    response = client.post("/api/eligibility", json={"dob": "not-a-date"})
    assert response.status_code == 422


def test_eligibility_missing_dob():
    """Missing required field should return 422."""
    response = client.post("/api/eligibility", json={})
    assert response.status_code == 422


# ── Quiz ──────────────────────────────────────────────────────────────────────
def test_quiz_returns_5_questions():
    response = client.get("/api/quiz")
    assert response.status_code == 200
    data = response.json()
    assert "questions" in data
    assert len(data["questions"]) == 5


def test_quiz_question_schema():
    """Each question must have required fields."""
    response = client.get("/api/quiz")
    for q in response.json()["questions"]:
        assert "id" in q
        assert "question" in q
        assert "options" in q
        assert "answer_index" in q
        assert len(q["options"]) == 4
        assert 0 <= q["answer_index"] <= 3


# ── Constituencies ────────────────────────────────────────────────────────────
def test_constituencies_list():
    response = client.get("/api/data/constituencies")
    assert response.status_code == 200
    result = response.json()
    assert isinstance(result, list)
    assert "Varanasi" in result


def test_constituency_details_valid():
    response = client.get("/api/data/results/constituency/Varanasi")
    assert response.status_code == 200
    data = response.json()
    assert data["Leading_Candidate"] == "Narendra Modi"
    assert data["Constituency"] == "Varanasi"


def test_constituency_details_case_insensitive():
    """Lower-case name should still resolve."""
    response = client.get("/api/data/results/constituency/varanasi")
    assert response.status_code == 200


def test_constituency_details_invalid():
    response = client.get("/api/data/results/constituency/NonExistentCity")
    assert response.status_code == 404


# ── Results Summary ───────────────────────────────────────────────────────────
def test_results_summary():
    response = client.get("/api/data/results/summary")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) > 0
    assert "Leading Party" in data[0]
    assert "Seats Won" in data[0]


# ── Election Schedule ─────────────────────────────────────────────────────────
def test_election_schedule():
    response = client.get("/api/elections/schedule")
    assert response.status_code == 200
    data = response.json()
    assert "elections" in data
    assert "important_dates" in data
    assert len(data["elections"]) > 0
