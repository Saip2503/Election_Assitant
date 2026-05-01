"""
Unit tests for WorkflowService.
Tests eligibility calculation, quiz structure, and mock data helpers.
"""
import pytest
from datetime import date
from services.workflow_service import WorkflowService


class TestCheckEligibility:
    CUTOFF = date(2026, 4, 1)

    def test_clearly_eligible(self):
        result = WorkflowService.check_eligibility(date(2000, 1, 1))
        assert result.eligible is True
        assert 'eligible to vote' in result.message

    def test_boundary_exactly_18(self):
        """Born exactly 18 years before cutoff — should be eligible."""
        dob = date(self.CUTOFF.year - 18, self.CUTOFF.month, self.CUTOFF.day)
        result = WorkflowService.check_eligibility(dob)
        assert result.eligible is True

    def test_boundary_one_day_short(self):
        """Born one day after 18-year threshold — should NOT be eligible."""
        dob = date(self.CUTOFF.year - 18, self.CUTOFF.month, self.CUTOFF.day + 1)
        result = WorkflowService.check_eligibility(dob)
        assert result.eligible is False

    def test_clearly_not_eligible(self):
        result = WorkflowService.check_eligibility(date(2015, 6, 15))
        assert result.eligible is False
        assert 'must be 18' in result.message

    def test_message_includes_age(self):
        result = WorkflowService.check_eligibility(date(2000, 1, 1))
        assert '26' in result.message or '25' in result.message  # approximate age


class TestGetQuiz:
    def test_returns_exactly_5_questions(self):
        questions = WorkflowService.get_quiz()
        assert len(questions) == 5

    def test_each_question_has_4_options(self):
        for q in WorkflowService.get_quiz():
            assert len(q.options) == 4

    def test_answer_index_is_valid(self):
        for q in WorkflowService.get_quiz():
            assert 0 <= q.answer_index <= 3

    def test_questions_have_explanations(self):
        for q in WorkflowService.get_quiz():
            assert q.explanation and len(q.explanation) > 10

    def test_question_ids_are_unique(self):
        ids = [q.id for q in WorkflowService.get_quiz()]
        assert len(ids) == len(set(ids))


class TestGetMockLocation:
    def test_returns_dict(self):
        result = WorkflowService.get_mock_location()
        assert isinstance(result, dict)

    def test_has_constituency(self):
        result = WorkflowService.get_mock_location()
        assert 'constituency' in result

    def test_has_helpline(self):
        result = WorkflowService.get_mock_location()
        assert result.get('helpline') == '1950'

    def test_defaults_to_new_panvel(self):
        result = WorkflowService.get_mock_location()
        assert 'Panvel' in result['constituency']


class TestGetElectionSchedule:
    def test_returns_elections_list(self):
        result = WorkflowService.get_election_schedule()
        assert 'elections' in result
        assert len(result['elections']) > 0

    def test_has_important_dates(self):
        result = WorkflowService.get_election_schedule()
        assert 'important_dates' in result
        assert 'voter_registration_deadline' in result['important_dates']

    def test_has_eci_links(self):
        result = WorkflowService.get_election_schedule()
        assert 'eci_links' in result
        assert 'nvsp' in result['eci_links']
