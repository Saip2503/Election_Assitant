import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/models/chat_model.dart';
import 'package:frontend/widgets/chat_bubble.dart';

Widget _bubble(ChatMessage msg) => MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(child: ChatBubble(message: msg)),
      ),
    );

void main() {
  group('ChatBubble', () {
    testWidgets('User bubble renders message text', (WidgetTester tester) async {
      final msg = ChatMessage(text: 'Hello from user', isUser: true);
      await tester.pumpWidget(_bubble(msg));
      await tester.pump();
      expect(find.text('Hello from user'), findsOneWidget);
    });

    testWidgets('Assistant bubble renders message text', (WidgetTester tester) async {
      final msg = ChatMessage(text: 'Hello from bot', isUser: false);
      await tester.pumpWidget(_bubble(msg));
      await tester.pump();
      expect(find.text('Hello from bot'), findsOneWidget);
    });

    testWidgets('User bubble aligns to end (right)', (WidgetTester tester) async {
      final msg = ChatMessage(text: 'Right side', isUser: true);
      await tester.pumpWidget(_bubble(msg));
      await tester.pump();

      final col = tester.widget<Column>(
        find.descendant(
          of: find.byType(ChatBubble),
          matching: find.byType(Column),
        ).first,
      );
      expect(col.crossAxisAlignment, CrossAxisAlignment.end);
    });

    testWidgets('Assistant bubble aligns to start (left)', (WidgetTester tester) async {
      final msg = ChatMessage(text: 'Left side', isUser: false);
      await tester.pumpWidget(_bubble(msg));
      await tester.pump();

      final col = tester.widget<Column>(
        find.descendant(
          of: find.byType(ChatBubble),
          matching: find.byType(Column),
        ).first,
      );
      expect(col.crossAxisAlignment, CrossAxisAlignment.start);
    });

    testWidgets('Semantics label includes sender info', (WidgetTester tester) async {
      final msg = ChatMessage(text: 'Test semantics', isUser: true);
      await tester.pumpWidget(_bubble(msg));
      await tester.pump();

      final semantics = tester.getSemantics(find.byType(ChatBubble));
      expect(semantics.label, contains('You'));
    });
  });
}
