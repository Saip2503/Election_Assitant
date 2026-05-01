import os
import pandas as pd
import logging

logger = logging.getLogger("election_assistant")

class ElectionDataService:
    _instance = None
    _df = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(ElectionDataService, cls).__new__(cls)
        return cls._instance

    def __init__(self):
        if self._df is None:
            self._load_data()

    def _load_data(self):
        try:
            # Using clean, high-performance mock data for the 2024 results
            self._df = pd.DataFrame([
                {
                    "Constituency": "Varanasi", 
                    "Const_No": 77, 
                    "Leading_Candidate": "Narendra Modi", 
                    "Leading_Party": "Bharatiya Janata Party", 
                    "Trailing_Candidate": "Ajay Rai", 
                    "Trailing_Party": "Indian National Congress", 
                    "Margin": "152,513", 
                    "Status": "Result Declared"
                },
                {
                    "Constituency": "Rae Bareli", 
                    "Const_No": 36, 
                    "Leading_Candidate": "Rahul Gandhi", 
                    "Leading_Party": "Indian National Congress", 
                    "Trailing_Candidate": "Dinesh Pratap Singh", 
                    "Trailing_Party": "Bharatiya Janata Party", 
                    "Margin": "390,030", 
                    "Status": "Result Declared"
                },
                {
                    "Constituency": "Kannauj", 
                    "Const_No": 38, 
                    "Leading_Candidate": "Akhilesh Yadav", 
                    "Leading_Party": "Samajwadi Party", 
                    "Trailing_Candidate": "Subrat Pathak", 
                    "Trailing_Party": "Bharatiya Janata Party", 
                    "Margin": "170,922", 
                    "Status": "Result Declared"
                },
                {
                    "Constituency": "Diamond Harbour", 
                    "Const_No": 21, 
                    "Leading_Candidate": "Abhishek Banerjee", 
                    "Leading_Party": "All India Trinamool Congress", 
                    "Trailing_Candidate": "Abhijit Das (Bobby)", 
                    "Trailing_Party": "Bharatiya Janata Party", 
                    "Margin": "710,930", 
                    "Status": "Result Declared"
                },
                {
                    "Constituency": "Guntur", 
                    "Const_No": 13, 
                    "Leading_Candidate": "Dr Chandra Sekhar Pemmasani", 
                    "Leading_Party": "Telugu Desam", 
                    "Trailing_Candidate": "Kilari Venkata Rosaiah", 
                    "Trailing_Party": "Yuvajana Sramika Rythu Congress Party", 
                    "Margin": "344,695", 
                    "Status": "Result Declared"
                }
            ])
            logger.info("Election mock data initialized successfully.")
        except Exception as e:
            logger.error(f"Error initializing mock data: {e}")
            self._df = pd.DataFrame()

    def get_all_constituencies(self):
        if self._df.empty:
            return []
        return sorted(self._df['Constituency'].unique().tolist())

    def get_constituency_results(self, constituency_name: str):
        if self._df.empty:
            return None
        
        # Case insensitive exact or partial match
        results = self._df[self._df['Constituency'].str.contains(constituency_name, case=False, na=False)]
        if results.empty:
            return None
            
        # Return the first matching record with all requested fields
        row = results.iloc[0]
        return {
            'Constituency': str(row.get('Constituency')),
            'Const_No': int(row.get('Const_No')),
            'Leading_Candidate': str(row.get('Leading_Candidate')),
            'Leading_Party': str(row.get('Leading_Party')),
            'Trailing_Candidate': str(row.get('Trailing_Candidate')),
            'Trailing_Party': str(row.get('Trailing_Party')),
            'Margin': str(row.get('Margin')),
            'Status': str(row.get('Status'))
        }

    def get_party_summary(self):
        if self._df.empty:
            return None
            
        summary = self._df.groupby('Leading_Party').size().reset_index(name='Seats Won')
        return summary.rename(columns={'Leading_Party': 'Leading Party'}).to_dict(orient='records')

    def get_context_for_ai(self, query: str):
        """
        Extracts relevant snippets from the dataset to feed into the AI prompt.
        """
        if self._df.empty:
            return "No election data available."
            
        # Simple heuristic: if query contains a place name found in the dataset
        # We can do more complex matching later
        return "2024 Lok Sabha Results Overview: " + str(self.get_party_summary()[:10])

# Singleton instance
election_data_service = ElectionDataService()
