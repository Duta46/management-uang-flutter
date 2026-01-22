class ChatMessage {
  final String id;
  final String text;
  final String sender; // 'user' or 'bot'
  final DateTime timestamp;
  final String? intent; // intent dari pesan pengguna
  final Map<String, dynamic>? metadata; // data tambahan terkait pesan

  ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.intent,
    this.metadata,
  });

  factory ChatMessage.user(String text) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      sender: 'user',
      timestamp: DateTime.now(),
    );
  }

  factory ChatMessage.bot(String text, {String? intent, Map<String, dynamic>? metadata}) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      sender: 'bot',
      timestamp: DateTime.now(),
      intent: intent,
      metadata: metadata,
    );
  }
}