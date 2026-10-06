import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _scroll = ScrollController();
  final List<ChatMessage> _messages = [
    const ChatMessage('Bonjour ! Comment puis-je vous aider ?', isUser: false),
  ];
  bool _isTyping = false;

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    setState(() {
      _messages.add(ChatMessage(text, isUser: true));
      _isTyping = true;
    });
    _scrollToBottom();

    // Remplacez ce délai par l'appel à votre API.
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    setState(() {
      _messages.add(const ChatMessage('Merci pour votre message !', isUser: false));
      _isTyping = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // l'input remonte avec le clavier
      appBar: AppBar(title: const Text('Assistant')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (_, i) => i < _messages.length
                  ? MessageBubble(message: _messages[i])
                  : const TypingBubble(),
            ),
          ),
          ChatInputBar(onSend: _send, enabled: !_isTyping),
        ],
      ),
    );
  }
}
