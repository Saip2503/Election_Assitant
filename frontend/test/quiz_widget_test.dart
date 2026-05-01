import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/widgets/quiz_widget.dart';

// Minimal mock question list matching the backend QuizQuestion schema
final _mockQuestions = [
  {
    'id': 1,
    'question': 'What is the minimum voting age in India?',
    'options': ['16', '18', '21', '25'],
    'answer_index': 1,
    'explanation': 'The 61st Amendment Act lowered the voting age to 18.',
  },
  {
    'id': 2,
    'question': 'Which form is used for new voter registration?',
    'options': ['Form 6', 'Form 7', 'Form 8', 'Form 12'],
    'answer_index': 0,
    'explanation': 'Form 6 is submitted at nvsp.in for new registrations.',
  },
];

Widget _buildQuiz() => ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: QuizWidget(questions: _mockQuestions),
          ),
        ),
      ),
    );

void main() {
  group('QuizWidget', () {
    testWidgets('renders first question text', (WidgetTester tester) async {
      await tester.pumpWidget(_buildQuiz());
      await tester.pump();
      expect(find.text('What is the minimum voting age in India?'), findsOneWidget);
    });

    testWidgets('renders all 4 answer options', (WidgetTester tester) async {
      await tester.pumpWidget(_buildQuiz());
      await tester.pump();
      // Options are in AnimatedContainers via GestureDetectors
      expect(find.text('16'), findsOneWidget);
      expect(find.text('18'), findsOneWidget);
      expect(find.text('21'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
    });

    testWidgets('Submit button is disabled before selecting an answer',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildQuiz());
      await tester.pump();
      // FilledButton with null onPressed is semantically disabled
      final btn = tester.widget<FilledButton>(find.byType(FilledButton).first);
      expect(btn.onPressed, isNull);
    });

    testWidgets('Selecting an answer enables the Submit button',
        (WidgetTester tester) async {
      await tester.pumpWidget(_buildQuiz());
      await tester.pump();
      // Tap the first option ("16")
      await tester.tap(find.text('16'));
      await tester.pump();
      final btn = tester.widget<FilledButton>(find.byType(FilledButton).first);
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('Empty questions list renders nothing visible',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: QuizWidget(questions: [])),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(QuizWidget), findsOneWidget);
      // Should render SizedBox.shrink() — no quiz text visible
      expect(find.text('What is the minimum voting age in India?'), findsNothing);
    });
  });
}
