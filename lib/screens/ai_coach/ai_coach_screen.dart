import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/animated_background.dart';
import '../../services/storage_service.dart';

class AICoachScreen extends StatefulWidget {
  const AICoachScreen({super.key});

  @override
  State<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends State<AICoachScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final StorageService _storage = StorageService();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _isConfigured = false;
  bool _isLoading = true;
  String _userName = 'Friend';
  late AnimationController _avatarPulseController;

  static const String _serverUrl = 'https://empowerwellness.onrender.com';

  @override
  void initState() {
    super.initState();
    _avatarPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    // Auto-connect: server holds the API key
    _isConfigured = true;
    _addCoachMessage('Welcome back, $_userName! 💚 I\'m Lumina — your personal wellness coach. How are you feeling today?');
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _avatarPulseController.dispose();
    super.dispose();
  }

  void _addCoachMessage(String text) {
    setState(() {
      _messages.add({'role': 'coach', 'text': text, 'time': _formatTime()});
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();
    setState(() {
      _messages.add({'role': 'user', 'text': text, 'time': _formatTime()});
      _isTyping = true;
    });
    _scrollToBottom();

    try {
      final history = _messages
          .map((m) => {'role': m['role'] == 'coach' ? 'assistant' : 'user', 'content': m['text']})
          .toList();
      if (history.isNotEmpty) history.removeLast();

      final response = await http.post(
        Uri.parse('$_serverUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': text, 'user_name': _userName, 'history': history}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['reply'] ?? 'I\'m here for you. Tell me more. 💚';
        setState(() {
          _isTyping = false;
          _messages.add({'role': 'coach', 'text': reply, 'time': _formatTime()});
        });
      } else {
        throw Exception('${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isTyping = false;
        _messages.add({
          'role': 'coach',
          'text': 'I\'m having trouble connecting right now. Make sure your Secure Key is set up, or try again in a moment. I\'m still here for you. 💚',
          'time': _formatTime(),
        });
      });
    }
    _scrollToBottom();
  }

  String _formatTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primaryPurple)),
      );
    }

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _avatarPulseController,
                builder: (context, _) {
                  return Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.purpleCoral,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryPurple.withValues(alpha: 0.3 + _avatarPulseController.value * 0.2),
                          blurRadius: 12 + _avatarPulseController.value * 8,
                        ),
                      ],
                    ),
                    child: const Center(child: Text('🥒', style: TextStyle(fontSize: 16))),
                  );
                },
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Lumina',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 16)),
                  Text('Always here for you',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                ],
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: _buildChatView(),
      ),
    );
  }

  Widget _buildChatView() {
    return Column(
      children: [
        if (_messages.length <= 1) _buildQuickPrompts(),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5, vertical: AppTheme.space3),
            itemCount: _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (_isTyping && index == _messages.length) return _buildTypingIndicator();
              final msg = _messages[index];
              return _buildMessageBubble(msg['text'], msg['role'] == 'coach', msg['time']);
            },
          ),
        ),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildQuickPrompts() {
    final prompts = [
      {'emoji': '💪', 'text': 'Help me get motivated'},
      {'emoji': '🧘', 'text': 'I\'m feeling stressed'},
      {'emoji': '🍎', 'text': 'What should I eat?'},
      {'emoji': '😴', 'text': 'I can\'t sleep'},
      {'emoji': '🚶', 'text': 'Quick workout idea'},
      {'emoji': '💧', 'text': 'Remind me to hydrate'},
    ];
    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4),
        children: prompts.map((p) {
          return Padding(
            padding: const EdgeInsets.only(right: AppTheme.space2),
            child: GestureDetector(
              onTap: () {
                _messageController.text = p['text']!;
                _sendMessage();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.glassPurple,
                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  border: Border.all(color: AppTheme.primaryPurple.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(p['emoji']!, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(p['text']!, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.purpleCoral,
            ),
            child: const Center(child: Text('🥒', style: TextStyle(fontSize: 14))),
          ),
          const SizedBox(width: AppTheme.space3),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(color: AppTheme.primaryPurple.withValues(alpha: 0.15)),
            ),
            child: _TypingDots(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isCoach, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isCoach ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (isCoach) ...[
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.purpleCoral,
              ),
              child: const Center(child: Text('🥒', style: TextStyle(fontSize: 12))),
            ),
            const SizedBox(width: AppTheme.space2),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              child: Column(
                crossAxisAlignment: isCoach ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.space4),
                    decoration: BoxDecoration(
                      color: isCoach
                          ? AppTheme.primaryPurple.withValues(alpha: 0.12)
                          : AppTheme.hotCoral.withValues(alpha: 0.18),
                      borderRadius: isCoach
                          ? const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            )
                          : const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(4),
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                      border: Border.all(
                        color: isCoach
                            ? AppTheme.primaryPurple.withValues(alpha: 0.15)
                            : AppTheme.hotCoral.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(text,
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, height: 1.45)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 3, left: 4, right: 4),
                    child: Text(time, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                  ),
                ],
              ),
            ),
          ),
          if (!isCoach) ...[
            const SizedBox(width: AppTheme.space2),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [AppTheme.roseGold, AppTheme.warmGold]),
              ),
              child: Center(
                child: Text(
                  _userName.isNotEmpty ? _userName[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.only(
        left: AppTheme.space4,
        right: AppTheme.space4,
        top: AppTheme.space3,
        bottom: MediaQuery.of(context).padding.bottom + AppTheme.space3,
      ),
      decoration: BoxDecoration(
        color: AppTheme.deepSpace.withValues(alpha: 0.85),
        border: Border(top: BorderSide(color: AppTheme.glassBorders, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                border: Border.all(color: AppTheme.glassBorders),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Share what\'s on your mind...',
                      hintStyle: TextStyle(color: AppTheme.textMuted),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    maxLines: null,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.space2),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.purpleCoral,
                boxShadow: [
                  BoxShadow(color: AppTheme.primaryPurple.withValues(alpha: 0.4), blurRadius: 12, spreadRadius: 1),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with TickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 12,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(3, (i) {
              final delay = i * 0.2;
              final progress = ((_c.value - delay) % 1.0).clamp(0.0, 1.0);
              final opacity = (progress < 0.5) ? progress * 2 : (1 - progress) * 2;
              return Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppTheme.textPrimary.withValues(alpha: 0.3 + opacity * 0.7),
                  shape: BoxShape.circle,
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
