class ChatMessage {
  final int id;
  final int conversationId;
  final int senderId;
  final String senderRole; // "CUSTOMER" / "PROVIDER"
  final String message;
  final DateTime sentAt;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderRole,
    required this.message,
    required this.sentAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        id: (j['id'] as num).toInt(),
        conversationId: (j['conversationId'] as num).toInt(),
        senderId: (j['senderId'] as num).toInt(),
        senderRole: (j['senderRole'] ?? '').toString(),
        message: (j['message'] ?? '').toString(),
        sentAt: DateTime.tryParse((j['sentAt'] ?? '').toString()) ?? DateTime.now(),
      );
}
