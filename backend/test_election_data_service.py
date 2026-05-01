"""
Unit tests for ElectionDataService.
Tests singleton pattern, data loading, and query methods.
"""
import pytest
from services.election_data_service import ElectionDataService, election_data_service


class TestElectionDataServiceSingleton:
    def test_singleton_returns_same_instance(self):
        """Two instantiations must return the exact same object."""
        a = ElectionDataService()
        b = ElectionDataService()
        assert a is b

    def test_module_level_instance_is_singleton(self):
        """Module-level election_data_service must be the same singleton."""
        assert election_data_service is ElectionDataService()


class TestGetAllConstituencies:
    def test_returns_list(self):
        result = election_data_service.get_all_constituencies()
        assert isinstance(result, list)

    def test_contains_expected_constituencies(self):
        result = election_data_service.get_all_constituencies()
        assert 'Varanasi' in result
        assert 'Rae Bareli' in result
        assert 'Guntur' in result

    def test_is_sorted(self):
        result = election_data_service.get_all_constituencies()
        assert result == sorted(result)

    def test_not_empty(self):
        result = election_data_service.get_all_constituencies()
        assert len(result) > 0


class TestGetConstituencyResults:
    def test_exact_match_varanasi(self):
        result = election_data_service.get_constituency_results('Varanasi')
        assert result is not None
        assert result['Leading_Candidate'] == 'Narendra Modi'
        assert result['Leading_Party'] == 'Bharatiya Janata Party'

    def test_exact_match_rae_bareli(self):
        result = election_data_service.get_constituency_results('Rae Bareli')
        assert result is not None
        assert result['Leading_Candidate'] == 'Rahul Gandhi'

    def test_case_insensitive_match(self):
        """Lowercase query should still find a match."""
        result = election_data_service.get_constituency_results('varanasi')
        assert result is not None
        assert result['Constituency'] == 'Varanasi'

    def test_partial_match(self):
        """Partial name should return a result."""
        result = election_data_service.get_constituency_results('Diamond')
        assert result is not None

    def test_unknown_constituency_returns_none(self):
        result = election_data_service.get_constituency_results('NonExistentPlace999')
        assert result is None

    def test_result_has_expected_keys(self):
        result = election_data_service.get_constituency_results('Varanasi')
        assert result is not None
        for key in ['Constituency', 'Const_No', 'Leading_Candidate', 'Leading_Party',
                    'Trailing_Candidate', 'Trailing_Party', 'Margin', 'Status']:
            assert key in result

    def test_result_types_are_native_python(self):
        """Ensure no numpy types that break JSON serialization."""
        result = election_data_service.get_constituency_results('Varanasi')
        assert isinstance(result['Const_No'], int)
        assert isinstance(result['Constituency'], str)


class TestGetPartySummary:
    def test_returns_list(self):
        result = election_data_service.get_party_summary()
        assert isinstance(result, list)

    def test_each_item_has_required_keys(self):
        result = election_data_service.get_party_summary()
        for item in result:
            assert 'Leading Party' in item
            assert 'Seats Won' in item

    def test_seats_won_are_positive(self):
        result = election_data_service.get_party_summary()
        for item in result:
            assert item['Seats Won'] > 0
