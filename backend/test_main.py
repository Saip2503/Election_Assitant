import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"

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

def test_constituencies_list():
    # Adjusted to correct prefix /api/data
    response = client.get("/api/data/constituencies")
    assert response.status_code == 200
    assert isinstance(response.json(), list)
    assert "Varanasi" in response.json()

def test_constituency_details_valid():
    # Adjusted to correct prefix /api/data/results/constituency
    response = client.get("/api/data/results/constituency/Varanasi")
    assert response.status_code == 200
    assert response.json()["Leading_Candidate"] == "Narendra Modi"

def test_constituency_details_invalid():
    response = client.get("/api/data/results/constituency/NonExistentCity")
    assert response.status_code == 404
