import 'package:flutter/material.dart';
import '../services/gemini_service.dart';

/**
 * Financial Chatbot Screen using Qwen AI via OpenRouter
 * This screen provides financial advice and insights using AI
 */
class FinancialChatbotScreen extends StatefulWidget {
  const FinancialChatbotScreen({Key? key}) : super(key: key);

  @override
  _FinancialChatbotScreenState createState() => _FinancialChatbotScreenState();
}

class _FinancialChatbotScreenState extends State<FinancialChatbotScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_textController.text.trim().isEmpty || _isLoading) return;

    final userMessage = _textController.text.trim();
    _textController.clear();

    // Add user message to chat
    setState(() {
      _messages.add(ChatMessage(text: userMessage, isUser: true));
      _isLoading = true;
    });

    try {
      // Get response from Qwen AI via OpenRouter
      final response = await GeminiService.sendMessage(userMessage);

      // Add AI response to chat
      setState(() {
        _messages.add(ChatMessage(text: response, isUser: false));
        _isLoading = false;
      });
    } catch (e) {
      // Add error message to chat
      setState(() {
        _messages.add(ChatMessage(
          text: 'Terjadi kesalahan: ${e.toString()}',
          isUser: false,
          isError: true,
        ));
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatbot Keuangan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Chat messages list
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _messages[index];
              },
            ),
          ),

          // Loading indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),

          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Tanyakan sesuatu tentang keuangan...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onSubmitted: (value) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isLoading ? null : _sendMessage,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}

/**
 * Chat message widget for displaying user and AI messages
 * Shows different styling for user vs AI messages and error states
 */
class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool isError;

  const ChatMessage({
    Key? key,
    required this.text,
    required this.isUser,
    this.isError = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isUser
                    ? Colors.blue
                    : isError
                        ? Colors.red.shade100
                        : Colors.grey.shade200,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(isUser ? 12 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isError) ...[
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 16,
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}