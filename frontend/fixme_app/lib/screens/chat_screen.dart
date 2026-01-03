import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../services/chat_api.dart';
import '../services/chat_socket_service.dart';

class ChatScreen extends StatefulWidget {
  final int requestId;
  final int userId;
  final String role; // "CUSTOMER" / "PROVIDER"
  final bool readOnly; // optional

  const ChatScreen({
    super.key,
    required this.requestId,
    required this.userId,
    required this.role,
    this.readOnly = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _ctrl = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _loading = true;

  int? _conversationId;
  ChatSocketService? _socket;
  void Function()? _unsub;


  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _unsub?.call();
    _socket?.disconnect();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      // 1) get conversation (creates if not exists)
      final conv = await ChatApi.getConversationByRequestId(widget.requestId);
      _conversationId = conv.id;

      // 2) load old messages
      final old = await ChatApi.getMessages(conv.id);
      _messages
        ..clear()
        ..addAll(old);

      // 3) connect websocket
      // ✅ choose correct wsUrl for your platform
      final wsUrl = 'ws://localhost:8081/ws/websocket';
      _socket = ChatSocketService(wsUrl: wsUrl);
      await _socket!.connect();

      // 4) subscribe
      _unsub = _socket!.subscribeToConversation(
        conversationId: conv.id,
        onMessage: (json) {
          final m = ChatMessage.fromJson(json);
          setState(() {
            _messages.add(m);
          });
        },
      );

      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chat init failed: $e')),
      );
    }
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    if (_conversationId == null) return;
    if (widget.readOnly) return;

    _socket!.sendMessage(
      conversationId: _conversationId!,
      senderId: widget.userId,
      senderRole: widget.role,
      message: text,
    );

    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final convId = _conversationId;

    return Scaffold(
      appBar: AppBar(
        title: Text(convId == null ? 'Chat' : 'Chat #$convId'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final m = _messages[i];
                      final isMe = m.senderId == widget.userId;

                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          constraints: const BoxConstraints(maxWidth: 320),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue.shade100 : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.message,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${m.senderRole} • ${m.sentAt}',
                                style: const TextStyle(fontSize: 11, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                if (!widget.readOnly)
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _ctrl,
                              decoration: const InputDecoration(
                                hintText: 'Type a message...',
                                border: OutlineInputBorder(),
                              ),
                              onSubmitted: (_) => _send(),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: _send,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('Chat is read-only for completed jobs.'),
                  ),
              ],
            ),
    );
  }
}
