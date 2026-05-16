import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:safea/data/gemini_live_service.dart';

class CompanionScreen extends StatefulWidget {
  const CompanionScreen({super.key});

  @override
  State<CompanionScreen> createState() => _CompanionScreenState();
}

class _CompanionScreenState extends State<CompanionScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {
      'role': 'safea',
      'content':
          'Halo Aldani, saya Safea, asisten virtual kesehatan mentalmu. Bagaimana perasaanmu hari ini? Apa ada yang ingin kamu bagi?',
    },
  ];
  bool _isTyping = false;
  bool _isCallActive = false;
  final GeminiLiveService _liveService = GeminiLiveService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSend() async {
    if (_textController.text.trim().isEmpty) return;

    final userText = _textController.text;
    setState(() {
      _messages.add({'role': 'user', 'content': userText});
      _textController.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API Key tidak ditemukan di .env');
      }

      final model = GenerativeModel(
        model: 'models/gemini-2.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.system('''
          Kamu adalah "Safea", seorang asisten virtual kesehatan mental yang empatik, profesional, dan menenangkan.
          Dengarkan pengguna, berikan validasi emosi, dan berikan saran ringan untuk relaksasi jika perlu.
          
          Panduan merespons:
          - Bahasa Indonesia yang ramah dan suportif (hindari bahasa terlalu formal/kaku).
          - Singkat namun bermakna (maksimal 3 paragraf pendek).
        '''),
      );

      final contents = _messages.map((m) {
        final role = m['role'] == 'user' ? 'user' : 'model';
        return Content(role, [TextPart(m['content'])]);
      }).toList();

      final response = await model.generateContent(contents);

      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'safea',
            'content': response.text ?? 'Saya di sini. Tarik napas perlahan.',
          });
          _isTyping = false;
        });
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    } catch (e) {
      debugPrint('Error calling Gemini API: \$e');
      if (mounted) {
        setState(() {
          _messages.add({
            'role': 'safea',
            'content':
                'Maaf, sistem sedang kesulitan menyambung. Bagaimana jika kita latihan napas sejenak?',
          });
          _isTyping = false;
        });
        _scrollToBottom();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error Chat: \$e')));
      }
    }
  }

  Future<void> _startCall() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _isCallActive = true;
    });
    try {
      await _liveService.connect();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCallActive = false;
        });
        messenger.showSnackBar(
          SnackBar(content: Text('Gagal menyambungkan: \$e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 16),
                  Expanded(child: _buildChatArea(context)),
                  const SizedBox(height: 16),
                  _buildInputArea(context),
                ],
              ),
            ),
          ),
          if (_isCallActive) _buildCallOverlay(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Virtual Avatar: Safea',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Teman cerita yang selalu ada untukmu 24/7. Validasi emosi dan bantuan menenangkan diri.',
                style: TextStyle(color: Color(0xFFC7D2FE)), // indigo-200
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: _startCall,
          icon: const Icon(LucideIcons.phone),
          label: const Text('Telepon Safea'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1), // indigo-500
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildChatArea(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(24),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildTypingIndicator(context);
                }
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Row(
                    mainAxisAlignment: isUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (!isUser) ...[
                        CircleAvatar(
                          backgroundColor: const Color(
                            0xFF4F46E5,
                          ), // indigo-600
                          child: const Icon(
                            LucideIcons.heart,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isUser
                                ? Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest
                                : const Color(
                                    0xFF312E81,
                                  ).withValues(alpha: 0.4), // indigo-900/40
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(24),
                              topRight: const Radius.circular(24),
                              bottomLeft: Radius.circular(isUser ? 24 : 4),
                              bottomRight: Radius.circular(isUser ? 4 : 24),
                            ),
                            border: Border.all(
                              color: isUser
                                  ? Theme.of(context).dividerColor
                                  : const Color(
                                      0xFF6366F1,
                                    ).withValues(alpha: 0.2), // indigo-500/20
                            ),
                          ),
                          child: Text(
                            msg['content'],
                            style: TextStyle(
                              color: isUser
                                  ? Colors.white
                                  : const Color(0xFFE0E7FF), // indigo-100
                            ),
                          ),
                        ),
                      ),
                      if (isUser) ...[
                        const SizedBox(width: 12),
                        CircleAvatar(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          child: const Icon(
                            LucideIcons.user,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFF4F46E5), // indigo-600
            child: const Icon(LucideIcons.heart, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(
                0xFF312E81,
              ).withValues(alpha: 0.4), // indigo-900/40
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(24),
              ),
              border: Border.all(
                color: const Color(
                  0xFF6366F1,
                ).withValues(alpha: 0.2), // indigo-500/20
              ),
            ),
            child: const Text(
              '...',
              style: TextStyle(color: Color(0xFFE0E7FF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Row(
      children: [
        OutlinedButton(
          onPressed: _startCall,
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            minimumSize: const Size(56, 56),
          ),
          child: const Icon(LucideIcons.mic),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _textController,
            decoration: const InputDecoration(
              hintText: 'Ketik balasanmu di sini...',
            ),
            onSubmitted: (_) => _handleSend(),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: _handleSend,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5), // indigo-600
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            minimumSize: const Size(56, 56),
          ),
          child: const Icon(LucideIcons.send),
        ),
      ],
    );
  }

  Widget _buildCallOverlay(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF020617).withValues(alpha: 0.95), // slate-950/95
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFF312E81), // indigo-900
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF6366F1),
                    width: 4,
                  ), // indigo-500
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha: 0.5),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    LucideIcons.heart,
                    color: Color(0xFF818CF8),
                    size: 64,
                  ), // indigo-400
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                'Safea',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'TERHUBUNG',
                style: TextStyle(
                  color: Color(0xFFA5B4FC),
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ), // indigo-300
              ),
              const SizedBox(height: 64),
              ElevatedButton(
                onPressed: () async {
                  await _liveService.disconnect();
                  if (mounted) {
                    setState(() {
                      _isCallActive = false;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(24),
                ),
                child: const Icon(
                  LucideIcons.phoneOff,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
