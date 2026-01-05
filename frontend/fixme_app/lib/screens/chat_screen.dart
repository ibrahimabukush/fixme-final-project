import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../services/chat_api.dart';
import '../services/chat_socket_service.dart';

class ChatScreen extends StatefulWidget {
  final int requestId;
  final int userId;
  final String role; // "CUSTOMER" / "PROVIDER"
  final bool readOnly;

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
  final _scroll = ScrollController();

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
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      final conv = await ChatApi.getConversationByRequestId(widget.requestId);
      _conversationId = conv.id;

      final old = await ChatApi.getMessages(conv.id);
      _messages
        ..clear()
        ..addAll(old);

      // ✅ choose correct wsUrl for your platform
      final wsUrl = 'ws://localhost:8081/ws/websocket';
      _socket = ChatSocketService(wsUrl: wsUrl);
      await _socket!.connect();

      _unsub = _socket!.subscribeToConversation(
        conversationId: conv.id,
        onMessage: (json) {
          final m = ChatMessage.fromJson(json);
          if (!mounted) return;
          setState(() => _messages.add(m));
          _scrollToBottomSoon();
        },
      );

      if (!mounted) return;
      setState(() => _loading = false);
      _scrollToBottomSoon();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chat init failed: $e')),
      );
    }
  }

  void _scrollToBottomSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  String _prettyTime(dynamic sentAt) {
    // Handles String/DateTime-ish values; best effort.
    final s = (sentAt ?? '').toString().trim();
    if (s.isEmpty) return '';

    // Common ISO format: 2026-01-04T12:34:56...
    if (s.contains('T')) {
      final parts = s.split('T');
      if (parts.length > 1) {
        final timePart = parts[1];
        final hhmm = timePart.length >= 5 ? timePart.substring(0, 5) : timePart;
        return hhmm;
      }
    }

    // If backend already sends formatted time/date
    return s.length > 16 ? s.substring(0, 16) : s;
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    if (_conversationId == null) return;
    if (widget.readOnly) return;

    _socket?.sendMessage(
      conversationId: _conversationId!,
      senderId: widget.userId,
      senderRole: widget.role,
      message: text,
    );

    _ctrl.clear();
    FocusScope.of(context).unfocus();
    _scrollToBottomSoon();
  }

  // ========= UI HELPERS =========

  Widget _topBar() {
    final convId = _conversationId;
    final title = convId == null ? 'Chat' : 'Chat #$convId';

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Material(
        elevation: 8,
        shadowColor: Colors.black12,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEAEAF2)),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                tooltip: 'Back',
                icon: const Icon(Icons.arrow_back),
              ),
              const SizedBox(width: 2),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: const Color(0xFFEEF2FF),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  color: Color(0xFF4F46E5),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 2),
                    Text(
                      widget.readOnly ? 'Read-only (job completed)' : 'Live chat',
                      style: const TextStyle(fontSize: 12.5, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              if (widget.readOnly)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color(0xFFFED7AA)),
                  ),
                  child: const Text(
                    'Read-only',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12.5)),
    );
  }

  Widget _bubble(ChatMessage m) {
    final isMe = m.senderId == widget.userId;

    final bubbleColor = isMe ? const Color(0xFFEEF2FF) : const Color(0xFFF3F4F6);
    final borderColor = isMe ? const Color(0xFFDDE3FF) : const Color(0xFFE5E7EB);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 340),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMe ? 16 : 6),
              bottomRight: Radius.circular(isMe ? 6 : 16),
            ),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (m.message).toString(),
                style: const TextStyle(fontWeight: FontWeight.w700, height: 1.25),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _pill(m.senderRole.toString()),
                  if (_prettyTime(m.sentAt).isNotEmpty) _pill(_prettyTime(m.sentAt)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _composer() {
    if (widget.readOnly) {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
          child: Material(
            elevation: 6,
            shadowColor: Colors.black12,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEAEAF2)),
              ),
              child: const Text(
                'Chat is read-only for completed jobs.',
                style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
        child: Material(
          elevation: 8,
          shadowColor: Colors.black12,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFEAEAF2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                    decoration: InputDecoration(
                      hintText: 'Type a message…',
                      filled: true,
                      fillColor: const Color(0xFFF6F7FB),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 46,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: _send,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Icon(Icons.send),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========= BUILD =========

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // ✅ modern gradient like the rest of your app
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF5F7FF),
              Color(0xFFFFFBEB),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _topBar(),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _messages.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Material(
                                elevation: 8,
                                shadowColor: Colors.black12,
                                borderRadius: BorderRadius.circular(18),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: const Color(0xFFEAEAF2)),
                                  ),
                                  child: const Text(
                                    'No messages yet.\nSay hi 👋',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: _scroll,
                            padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
                            itemCount: _messages.length,
                            itemBuilder: (_, i) => _bubble(_messages[i]),
                          ),
              ),
              _composer(),
            ],
          ),
        ),
      ),
    );
  }
}
