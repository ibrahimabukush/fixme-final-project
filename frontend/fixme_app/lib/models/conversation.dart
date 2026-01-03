class Conversation {
  final int id;
  final int serviceRequestId;
  final int customerId;
  final int providerId;

  Conversation({
    required this.id,
    required this.serviceRequestId,
    required this.customerId,
    required this.providerId,
  });

  factory Conversation.fromJson(Map<String, dynamic> j) => Conversation(
        id: (j['id'] as num).toInt(),
        serviceRequestId: (j['serviceRequestId'] as num).toInt(),
        customerId: (j['customerId'] as num).toInt(),
        providerId: (j['providerId'] as num).toInt(),
      );
}
