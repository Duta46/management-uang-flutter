import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_message.dart';
import '../providers/transaction_provider_change_notifier.dart';
import '../providers/savings_goal_provider.dart';
import '../providers/bill_reminder_provider.dart';
import '../services/financial_chatbot_service.dart';
import '../services/conversation_context.dart';
import '../providers/global_providers.dart';

class FinancialChatbotScreen extends StatefulWidget {
  const FinancialChatbotScreen({Key? key}) : super(key: key);

  @override
  State<FinancialChatbotScreen> createState() => _FinancialChatbotScreenState();
}

class _FinancialChatbotScreenState extends State<FinancialChatbotScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ConversationContext _context = ConversationContext();

  @override
  void initState() {
    super.initState();
    // Kirim pesan sambutan saat layar pertama kali dimuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendWelcomeMessage();
    });
  }

  void _sendWelcomeMessage() {
    final welcomeMessage = ChatMessage.bot(
      "Halo! Saya adalah asisten keuangan digital Anda. Saya bisa membantu Anda dengan informasi keuangan seperti saldo, pengeluaran, pemasukan, rencana tabungan, dan lainnya. Apa yang ingin Anda ketahui hari ini?",
      intent: FinancialChatbotService.INTENT_SAMBUNG,
    );
    setState(() {
      _messages.insert(0, welcomeMessage);
    });
  }

  void _sendMessage() async {
    if (_textController.text.trim().isEmpty) return;

    // Tambahkan pesan pengguna
    final userMessage = ChatMessage.user(_textController.text.trim());
    setState(() {
      _messages.insert(0, userMessage);
    });

    // Kosongkan input field
    _textController.clear();

    // Kita tidak perlu mendeteksi intent di sisi client karena backend akan menanganinya
    // Simpan intent untuk keperluan konteks percakapan
    String intent = "api_generated"; // Placeholder karena backend yang menangani intent

    // Tambahkan indikator loading sebelum meminta jawaban dari bot
    final loadingMessage = ChatMessage.bot(
      "",
      intent: "loading",
    );

    setState(() {
      _messages.insert(0, loadingMessage);
    });

    // Scroll ke pesan loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Dapatkan provider untuk mengakses API
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
    // Kita tidak perlu mengakses data lokal karena backend yang akan mengaksesnya

    // Generate response dari API backend
    final apiResponse = await sharedApiRepository
        .askChatbotQuestion(userMessage.text);

    // Debug logging
    print('Chatbot API Response: success=${apiResponse.success}, data=${apiResponse.data}, message=${apiResponse.message}');

    String botResponse;
    if (apiResponse.success && apiResponse.data != null) {
      botResponse = apiResponse.data['answer'] ?? 'Maaf, saya tidak dapat memproses permintaan Anda saat ini.';
    } else {
      botResponse = 'Terjadi kesalahan saat menghubungi layanan chatbot: ${apiResponse.message}';
    }

    // Hapus indikator loading
    setState(() {
      _messages.removeAt(0); // Hapus loading message
    });

    // Tambahkan respon bot
    final botMessage = ChatMessage.bot(
      botResponse,
      intent: intent,
    );

    setState(() {
      _messages.insert(0, botMessage);
    });

    // Update konteks percakapan
    String responseIntent = apiResponse.data != null ? apiResponse.data['intent'] ?? intent : intent;
    print('Updating context with intent: $responseIntent');

    _context.updateContext(
      intent: responseIntent, // Gunakan intent dari API jika tersedia
      interactionTime: DateTime.now(),
      question: userMessage.text,
    );

    // Jika respon mengandung pertanyaan atau ajakan untuk informasi lebih lanjut
    if (_containsFollowUpOpportunity(botResponse)) {
      _context.updateContext(followUp: 'more_details');
    } else {
      _context.updateContext(followUp: null);
    }

    // Scroll ke pesan terbaru
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Fungsi untuk mendeteksi apakah respon adalah afirmatif
  bool _isAffirmativeResponse(String text) {
    final lowerText = text.toLowerCase();
    final affirmativeKeywords = [
      'ya', 'iya', 'yap', 'benar', 'betul', 'setuju', 'ok', 'oke',
      'yes', 'y', 'correct', 'true', 'pasti', 'tentu', 'boleh', 'silakan'
    ];
    return affirmativeKeywords.any((keyword) => lowerText.contains(keyword));
  }

  // Fungsi untuk mendeteksi apakah respon adalah negatif
  bool _isNegativeResponse(String text) {
    final lowerText = text.toLowerCase();
    final negativeKeywords = [
      'tidak', 'ga', 'gak', 'enggak', 'bukan', 'salah', 'no', 'n',
      'false', 'wrong', 'never', 'nope', 'tidak perlu', 'sudah cukup'
    ];
    return negativeKeywords.any((keyword) => lowerText.contains(keyword));
  }

  // Fungsi untuk mendeteksi apakah respon mengandung ajakan untuk informasi lebih lanjut
  bool _containsFollowUpOpportunity(String response) {
    final lowerResponse = response.toLowerCase();
    final followUpIndicators = [
      'ingin tahu lebih lanjut', 'mau tau lebih lanjut', 'ingin tahu detail',
      'mau tau detail', 'butuh informasi lebih', 'ingin informasi lebih',
      'apa lagi yang bisa kamu bantu', 'ada yang lain', 'ada lagi',
      'apa saja yang bisa kamu lakukan', 'apa yang bisa kamu bantu',
      'mau bantu', 'ingin bantu', 'butuh bantuan', 'cara lainnya',
      'bagaimana caranya', 'apa langkah selanjutnya', 'apa yang harus saya lakukan'
    ];
    return followUpIndicators.any((indicator) => lowerResponse.contains(indicator));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asisten Keuangan'),
        backgroundColor: Theme.of(context).cardTheme.color,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
      ),
      body: Column(
        children: [
          // Area chat
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_outlined,
                          size: 60,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Mulai percakapan dengan saya',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'Saya bisa bantu Anda dengan informasi keuangan',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true, // Pesan terbaru di atas
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
          ),
          
          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: 'Tanyakan tentang keuangan Anda...',
                      hintStyle: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardTheme.color,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  backgroundColor: Theme.of(context).primaryColor,
                  mini: true,
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.sender == 'user';
    final alignment = isUser ? Alignment.centerRight : Alignment.centerLeft;
    final color = isUser
        ? Theme.of(context).primaryColor
        : Theme.of(context).cardTheme.color;
    final textColor = isUser ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color;

    // Tampilkan loading indicator jika intent adalah "loading"
    if (message.intent == "loading") {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(18),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Bot sedang mengetik...',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      alignment: alignment,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 10,
                color: textColor?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}