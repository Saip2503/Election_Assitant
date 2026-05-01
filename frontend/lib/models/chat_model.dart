class ChatMessage {
  final String text;
  final bool isUser;
  final String? intent;
  final Map<String, dynamic>? payload;
  final bool isTyping;

  const ChatMessage({
    required this.text,
    required this.isUser,
    this.intent,
    this.payload,
    this.isTyping = false,
  });
}
