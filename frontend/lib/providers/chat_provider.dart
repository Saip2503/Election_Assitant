import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../services/l10n_service.dart';
import '../models/chat_model.dart';

// ── API base URL ──────────────────────────────────────────────────────────────
// In debug mode, point at local backend; in release, use relative path.
const _kApiBase = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: '', // relative path — works for Cloud Run unified deploy
);

String get _baseUrl => _kApiBase.isEmpty
    ? (const bool.fromEnvironment('dart.vm.product') ? '/api' : 'http://localhost:8080/api')
    : _kApiBase;

// ── Providers ─────────────────────────────────────────────────────────────────
final languageProvider = StateProvider<String>((ref) => 'en');

final chatProvider =
    StateNotifierProvider<ChatNotifier, List<ChatMessage>>((ref) {
  return ChatNotifier();
});

// ── Local intent map (instant, no backend needed) ────────────────────────────
const _localIntents = <String, Map<String, dynamic>>{
  'register to vote': {
    'key': 'intent_registration',
    'intent': 'eligibility_check',
    'payload': null,
  },
  'eligibility': {
    'key': 'intent_registration',
    'intent': 'eligibility_check',
    'payload': null,
  },
  'find my booth': {
    'key': 'intent_booth',
    'intent': 'booth_finder',
    'payload': null,
  },
  'booth': {
    'key': 'intent_booth',
    'intent': 'booth_finder',
    'payload': null,
  },
  'evm guide': {
    'key': 'intent_evm',
    'intent': 'evm_walkthrough',
    'payload': null,
  },
  'evm': {
    'key': 'intent_evm',
    'intent': 'evm_walkthrough',
    'payload': null,
  },
  'civic quiz': {
    'key': 'intent_quiz',
    'intent': 'quiz',
    'payload': {
      'questions': [
        {
          'question': 'What is the minimum age to register as a voter in India?',
          'options': ['16 years', '18 years', '21 years', '25 years'],
          'answer_index': 1,
          'explanation':
              'As per Article 326 of the Indian Constitution, every citizen aged 18 or above is entitled to vote.',
        },
        {
          'question': 'Which body conducts general elections in India?',
          'options': ['Parliament of India', 'Supreme Court', 'Election Commission of India', 'UPSC'],
          'answer_index': 2,
          'explanation':
              'The Election Commission of India (ECI) is an autonomous constitutional authority responsible for elections.',
        },
        {
          'question': 'What does VVPAT stand for?',
          'options': [
            'Voter Verified Paper Audit Trail',
            'Vote Verification Paper and Tracking',
            'Verified Voting Paper Audit Track',
            'Voter Valid Paper Audit Technology',
          ],
          'answer_index': 0,
          'explanation':
              'VVPAT is a printer attached to an EVM that lets voters verify their vote for 7 seconds.',
        },
      ],
    },
  },
  'candidates': {
    'key': 'intent_candidates',
    'intent': 'candidates',
    'payload': {
      'candidates': [
        {
          'name': 'Arjun Patil',
          'party': 'Vikas Party',
          'agenda': [
            'Upgrading local public hospital infrastructure',
            '24/7 clean water supply for Panvel West',
            'Setting up a youth skill centre',
          ],
        },
        {
          'name': 'Priya Deshmukh',
          'party': 'Navbharat Party',
          'agenda': [
            "Women's safety initiatives & faster grievance redressal",
            'Expanding local green spaces and parks',
            'Subsidised legal aid for marginalised communities',
          ],
        },
        {
          'name': 'Ramesh Rao',
          'party': 'Independent',
          'agenda': [
            'Tax breaks for local street vendors',
            'Repairing pothole-ridden inner roads',
            'Direct citizen-audit of municipal spending',
          ],
        },
      ],
    },
  },
  'update info': {
    'key': 'intent_form8',
    'intent': 'form8',
    'payload': null,
  },
  'update': {
    'key': 'intent_form8',
    'intent': 'form8',
    'payload': null,
  },
  'official links': {
    'key': 'intent_official_links',
    'intent': 'official_links',
    'payload': null,
  },
};

// ── Notifier ──────────────────────────────────────────────────────────────────
class ChatNotifier extends StateNotifier<List<ChatMessage>> {
  ChatNotifier() : super([]);

  Map<String, dynamic>? _resolveLocalIntent(String text) {
    final lower = text.toLowerCase().trim();
    for (final key in _localIntents.keys) {
      if (lower.contains(key)) return _localIntents[key];
    }
    return null;
  }

  Future<void> sendMessage(
    String text,
    String language, {
    String sessionId = 'anonymous',
  }) async {
    state = [...state, ChatMessage(text: text, isUser: true)];

    // Try local intent first (instant)
    final local = _resolveLocalIntent(text);
    if (local != null) {
      final reply = L10nService.translate(local['key'] as String, language);
      state = [
        ...state,
        ChatMessage(
          text: reply,
          isUser: false,
          intent: local['intent'] as String?,
          payload: local['payload'] as Map<String, dynamic>?,
        ),
      ];
      return;
    }

    // Show typing indicator
    const typingId = '__typing__';
    state = [...state, const ChatMessage(text: typingId, isUser: false, isTyping: true)];

    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'message': text,
              'language': language,
              'session_id': sessionId,
            }),
          )
          .timeout(const Duration(seconds: 30));

      // Remove typing indicator
      state = state.where((m) => !m.isTyping).toList();

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        state = [
          ...state,
          ChatMessage(
            text: data['reply'] as String,
            isUser: false,
            intent: data['intent'] as String?,
            payload: data['payload'] as Map<String, dynamic>?,
          ),
        ];
      } else if (response.statusCode == 429) {
        state = [
          ...state,
          const ChatMessage(
            text: '⚠️ You are sending messages too quickly. Please wait a moment and try again.',
            isUser: false,
          ),
        ];
      } else {
        state = [
          ...state,
          const ChatMessage(
            text: 'Something went wrong on the server. Please try again.',
            isUser: false,
          ),
        ];
      }
    } catch (e) {
      state = state.where((m) => !m.isTyping).toList();
      state = [
        ...state,
        const ChatMessage(
          text: 'Could not reach the server. Check your connection or call the ECI Voter Helpline: 1950.',
          isUser: false,
        ),
      ];
    }
  }

  void addSystemMessage(
    String text, {
    String? intent,
    Map<String, dynamic>? payload,
  }) {
    state = [
      ...state,
      ChatMessage(text: text, isUser: false, intent: intent, payload: payload),
    ];
  }

  void clearHistory() => state = [];
}
