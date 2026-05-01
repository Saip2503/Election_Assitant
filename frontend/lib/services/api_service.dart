import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Centralized API service for all backend calls.
class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return '/api'; 
    }
    return const bool.fromEnvironment('dart.vm.product') ? '/api' : 'http://localhost:8080/api';
  }

  static Future<List<Map<String, dynamic>>> fetchQuizQuestions() async {
    try {
      final resp = await http
          .get(Uri.parse('$baseUrl/quiz'))
          .timeout(const Duration(seconds: 15));
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        final list = data['questions'] as List<dynamic>;
        return list.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      if (kDebugMode) print('[ApiService] fetchQuizQuestions error: $e');
    }
    // Fallback to hardcoded questions if API unreachable
    return _fallbackQuestions;
  }

  static Future<Map<String, dynamic>> fetchElectionSchedule() async {
    try {
      final resp = await http
          .get(Uri.parse('$baseUrl/elections/schedule'))
          .timeout(const Duration(seconds: 15));
      if (resp.statusCode == 200) {
        return jsonDecode(resp.body) as Map<String, dynamic>;
      }
    } catch (e) {
      if (kDebugMode) print('[ApiService] fetchElectionSchedule error: $e');
    }
    return _fallbackSchedule;
  }

  static const _fallbackQuestions = <Map<String, dynamic>>[
    {
      'id': 1,
      'question': 'What is the minimum age to vote in India?',
      'options': ['16', '18', '21', '25'],
      'answer_index': 1,
      'explanation': 'The voting age was lowered from 21 to 18 by the 61st Amendment Act, 1988.',
    },
    {
      'id': 2,
      'question': 'Which form is used for new voter registration?',
      'options': ['Form 6', 'Form 7', 'Form 8', 'Form 12'],
      'answer_index': 0,
      'explanation': 'Form 6 is for application for inclusion of name in electoral roll.',
    },
    {
      'id': 3,
      'question': 'What does VVPAT stand for?',
      'options': [
        'Voter Verifiable Paper Audit Trail',
        'Voter Verified Process Account Trail',
        'Voting Verification Paper Audit Tool',
        'Voter Verifiable Process Audit Trail',
      ],
      'answer_index': 0,
      'explanation': 'VVPAT allows voters to verify their vote via a printed slip visible for 7 seconds.',
    },
  ];

  static const _fallbackSchedule = <String, dynamic>{
    'elections': [],
    'important_dates': {},
    'eci_links': {'voter_helpline': '1950', 'voter_portal': 'https://voters.eci.gov.in/Homepage'},
  };
}
