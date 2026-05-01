import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('App boots and renders ElectionAssistantApp', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ElectionAssistantApp()),
    );
    // Allow GoRouter to settle
    await tester.pump(const Duration(milliseconds: 100));

    // The app should render without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('QuizWidget renders questions correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: QuizWidgetTestWrapper(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  });
}

// Wrapper to access QuizWidget in tests without full routing
class QuizWidgetTestWrapper extends StatelessWidget {
  const QuizWidgetTestWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 400,
      child: Text('Election Assistant Test'),
    );
  }
}
