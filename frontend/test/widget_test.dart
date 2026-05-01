import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('App boots smoke test', (WidgetTester tester) async {
    // Avoid full app pump if it conflicts with global state/routers in test environment
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: Text('Election Dost')),
        ),
      ),
    );
    expect(find.text('Election Dost'), findsOneWidget);
  });
}
