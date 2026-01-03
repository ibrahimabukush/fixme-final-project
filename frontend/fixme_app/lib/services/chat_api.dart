import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/conversation.dart';
import '../models/chat_message.dart';

class ChatApi {
  static const String baseUrl = 'http://localhost:8081';

  static Future<Conversation> getConversationByRequestId(int requestId) async {
    final uri = Uri.parse('$baseUrl/api/chat/request/$requestId');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Get conversation failed: ${res.body}');
    }
    return Conversation.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  static Future<List<ChatMessage>> getMessages(int conversationId) async {
    final uri = Uri.parse('$baseUrl/api/chat/$conversationId/messages');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Get messages failed: ${res.body}');
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList();
  }
}
