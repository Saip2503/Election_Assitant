from fastapi import APIRouter, HTTPException
from services.election_data_service import election_data_service

router = APIRouter(prefix="/api/data", tags=["data"])

@router.get("/results/summary")
async def get_results_summary():
    """Returns the party-wise seat summary for 2024 elections."""
    summary = election_data_service.get_party_summary()
    if summary is None:
        raise HTTPException(status_code=503, detail="Election data not yet loaded")
    return summary

@router.get("/constituencies")
async def get_constituencies():
    """Returns a list of all parliamentary constituencies."""
    return election_data_service.get_all_constituencies()

@router.get("/results/constituency/{name}")
async def get_constituency_results(name: str):
    """Returns detailed results for a specific constituency."""
    results = election_data_service.get_constituency_results(name)
    if not results:
        raise HTTPException(status_code=404, detail=f"No results found for {name}")
    return results
