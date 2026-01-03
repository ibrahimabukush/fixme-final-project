import 'dart:convert';
import 'package:stomp_dart_client/stomp_dart_client.dart';

typedef OnMessageJson = void Function(Map<String, dynamic> json);

class ChatSocketService {
  StompClient? _client;

  // ✅ SockJS endpoint (because backend uses withSockJS())
  // Web: ws://localhost:8081/ws/websocket
  // Android emulator: ws://10.0.2.2:8081/ws/websocket
  final String wsUrl;

  ChatSocketService({required this.wsUrl});

  bool get isConnected => _client?.connected ?? false;

  Future<void> connect() async {
    if (_client != null && (_client!.connected)) return;

    _client = StompClient(
      config: StompConfig(
        url: wsUrl,
        reconnectDelay: const Duration(seconds: 2),
        stompConnectHeaders: const {},
        webSocketConnectHeaders: const {},
      ),
    );

    _client!.activate();

    // ننتظر شوي لحد ما يتصل
    int tries = 0;
    while (!(_client!.connected) && tries < 30) {
      await Future.delayed(const Duration(milliseconds: 100));
      tries++;
    }
    if (!(_client!.connected)) {
      throw Exception('WebSocket connect failed');
    }
  }

  void Function() subscribeToConversation({
    required int conversationId,
    required OnMessageJson onMessage,
  }) {
    final topic = '/topic/requests/$conversationId'; // ✅ نفس الباك اند عندك
    return _client!.subscribe(
      destination: topic,
      callback: (frame) {
        if (frame.body == null) return;
        final map = jsonDecode(frame.body!) as Map<String, dynamic>;
        onMessage(map);
      },
    );
  }

  void sendMessage({
    required int conversationId,
    required int senderId,
    required String senderRole, // "CUSTOMER" / "PROVIDER"
    required String message,
  }) {
    final body = jsonEncode({
      "conversationId": conversationId,
      "senderId": senderId,
      "senderRole": senderRole,
      "message": message,
    });

    _client!.send(
      destination: '/app/chat.send',
      body: body,
    );
  }

  void disconnect() {
    _client?.deactivate();
    _client = null;
  }
}
