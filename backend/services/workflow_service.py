from datetime import date
from models.schemas import EligibilityResponse, QuizQuestion, QuizResponse
from typing import List

class WorkflowService:
    @staticmethod
    def check_eligibility(dob: date) -> EligibilityResponse:
        cutoff_date = date(2026, 4, 1)
        age = cutoff_date.year - dob.year - (
            (cutoff_date.month, cutoff_date.day) < (dob.month, dob.day)
        )
        if age >= 18:
            return EligibilityResponse(
                eligible=True,
                message=(
                    f"✅ You will be {age} years old by April 2026 and are "
                    f"eligible to vote! Register at nvsp.in using Form 6."
                )
            )
        else:
            months_remaining = ((cutoff_date.year - dob.year) * 12
                                + cutoff_date.month - dob.month - 12)
            return EligibilityResponse(
                eligible=False,
                message=(
                    f"❌ You will be {age} years old by April 2026. "
                    f"You must be 18 to vote. You may be eligible in future elections."
                )
            )

    @staticmethod
    def get_quiz() -> List[QuizQuestion]:
        return [
            QuizQuestion(
                id=1,
                question="What is the minimum age to vote in India?",
                options=["16", "18", "21", "25"],
                answer_index=1,
                explanation="The voting age was lowered from 21 to 18 by the 61st Amendment Act, 1988.",
            ),
            QuizQuestion(
                id=2,
                question="Which form is used for new voter registration in India?",
                options=["Form 6", "Form 7", "Form 8", "Form 12"],
                answer_index=0,
                explanation="Form 6 is for 'Application for inclusion of name in electoral roll'. Submit it at nvsp.in.",
            ),
            QuizQuestion(
                id=3,
                question="What does VVPAT stand for?",
                options=[
                    "Voter Verifiable Paper Audit Trail",
                    "Voter Verified Process Account Trail",
                    "Voting Verification Paper Audit Tool",
                    "Voter Verifiable Process Audit Trail",
                ],
                answer_index=0,
                explanation="VVPAT lets voters verify their vote was cast correctly via a printed slip visible for 7 seconds.",
            ),
            QuizQuestion(
                id=4,
                question="Which article of the Indian Constitution grants universal adult suffrage?",
                options=["Article 19", "Article 21", "Article 324", "Article 326"],
                answer_index=3,
                explanation="Article 326 grants every adult citizen (18+) the right to vote in elections.",
            ),
            QuizQuestion(
                id=5,
                question="What is the role of the Election Commission of India?",
                options=[
                    "Collect taxes",
                    "Administer elections at all levels",
                    "Draft the Constitution",
                    "Appoint the Prime Minister",
                ],
                answer_index=1,
                explanation="ECI is an autonomous body under Article 324 that oversees free and fair elections to Parliament and State legislatures.",
            ),
        ]

    @staticmethod
    def get_mock_location() -> dict:
        return {
            "constituency": "Panvel (188)",
            "district": "Raigad",
            "state": "Maharashtra",
            "booth_number": "142",
            "booth_name": "Zilla Parishad School, New Panvel",
            "address": "Sector 5, Near Khandeshwar Railway Station, New Panvel (E), Maharashtra 410206",
            "blo": "Mr. Ramesh Kumar",
            "helpline": "1950",
        }

    @staticmethod
    def get_mock_candidates() -> list:
        return [
            {
                "name": "Arjun Patil",
                "party": "Vikas Party",
                "constituency": "Panvel (188)",
                "agenda": [
                    "Upgrading local public hospital infrastructure",
                    "24/7 clean water supply for Panvel West",
                    "Setting up a specialised youth skill centre",
                ],
            },
            {
                "name": "Priya Deshmukh",
                "party": "Navbharat Party",
                "constituency": "Panvel (188)",
                "agenda": [
                    "Women's safety initiatives & faster grievance redressal",
                    "Expanding local green spaces and parks",
                    "Subsidised legal aid for marginalised communities",
                ],
            },
            {
                "name": "Ramesh Rao",
                "party": "Independent",
                "constituency": "Panvel (188)",
                "agenda": [
                    "Tax breaks for local street vendors",
                    "Repairing pothole-ridden inner roads",
                    "Direct citizen-audit of municipal spending",
                ],
            },
        ]

    @staticmethod
    def get_election_schedule() -> dict:
        return {
            "elections": [
                {
                    "name": "Maharashtra State Assembly Elections 2026",
                    "type": "State Assembly",
                    "phases": [
                        {"phase": 1, "date": "2026-10-15", "constituencies": ["Panvel", "Belapur", "Uran"]},
                        {"phase": 2, "date": "2026-10-22", "constituencies": ["Pune", "Mumbai South", "Nashik"]},
                    ],
                    "result_date": "2026-10-28",
                    "status": "upcoming",
                },
                {
                    "name": "Lok Sabha General Elections 2029",
                    "type": "National",
                    "phases": [],
                    "result_date": None,
                    "status": "scheduled",
                },
            ],
            "important_dates": {
                "voter_registration_deadline": "2026-08-01",
                "form8_submission_deadline": "2026-09-01",
                "model_code_effective": "2026-09-15",
            },
            "eci_links": {
                "nvsp": "https://www.nvsp.in",
                "eci": "https://eci.gov.in",
                "form6": "https://www.nvsp.in/Forms/Forms?formid=form6",
                "form8": "https://www.nvsp.in/Forms/Forms?formid=form8",
                "voter_helpline": "1950",
            },
        }

    @staticmethod
    def get_booth_by_epic(epic_number: str) -> dict:
        """Stub for real EPIC-based booth lookup. Returns mock for demo."""
        # In production, integrate with ECI's electoral roll API
        return WorkflowService.get_mock_location()
