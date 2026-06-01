import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/animated_background.dart';
import '../../services/ai_coach_service.dart';
import '../../services/storage_service.dart';

class AICoachScreen extends StatefulWidget {
  const AICoachScreen({super.key});

  @override
  State<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends State<AICoachScreen> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final AICoachService _aiService = AICoachService();
  final StorageService _storage = StorageService();

  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  bool _isConfigured = false;
  bool _isLoading = true;
  String _userName = 'Friend';

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  void _loadConfig() {
    final apiKey = _storage.getApiKey();
    final model = _storage.getModel();
    final userData = _storage.loadUserData();

    _userName = userData.name.isNotEmpty ? userData.name : 'Friend';

    if (apiKey.isNotEmpty) {
      _aiService.configure(apiKey, model);
      _isConfigured = true;
      _apiKeyController.text = apiKey;
      _modelController.text = model;
      _messages.add({
        'role': 'coach',
        'text': 'Welcome to your sanctuary, $_userName. I am Big Pickle Free, your guide to a stronger, more vibrant you. How are we feeling today?',
        'time': 'Just now',
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _saveConfig() async {
    final apiKey = _apiKeyController.text.trim();
    final model = _modelController.text.trim();

    if (apiKey.isEmpty) return;

    await _storage.saveApiKey(apiKey);
    await _storage.saveModel(model.isEmpty ? 'google/gemma-4-31b-it:free' : model);

    _aiService.configure(apiKey, model);

    setState(() {
      _isConfigured = true;
      _messages.add({
        'role': 'coach',
        'text': 'Welcome to your sanctuary, $_userName. I am Big Pickle Free, your guide to a stronger, more vibrant you. How are we feeling today?',
        'time': 'Just now',
      },
      );
    });
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userText = _messageController.text.trim();
    setState(() {
      _messages.add({'role': 'user', 'text': userText, 'time': 'Now'});
      _messageController.clear();
      _isTyping = true;
    });

    final response = await _aiService.getResponse(userText, userName: _userName);

    if (mounted) {
      setState(() {
        _isTyping = false;
        _messages.add({
          'role': 'coach',
          'text': response,
          'time': 'Now',
        });
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('AI Coach', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          centerTitle: true,
        ),
        body: _isConfigured ? _buildChatView() : _buildSetupCard(),
      ),
    );
  }

  Widget _buildSetupCard() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.space6),
        child: GlassCard(
          padding: const EdgeInsets.all(AppTheme.space6),
          tint: AppTheme.primaryPurple,
          opacity: 0.15,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Setup AI Coach',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.space3),
              const Text(
                'Enter your OpenRouter API key to connect Big Pickle Free to the real AI.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.space5),
              const Text(
                'OpenRouter API Key',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppTheme.space2),
              TextField(
                controller: _apiKeyController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'sk-or-v1-...',
                  hintStyle: const TextStyle(color: AppTheme.textMuted),
                  filled: true,
                  fillColor: AppTheme.deepSpace.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    borderSide: const BorderSide(color: AppTheme.glassBorders),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    borderSide: const BorderSide(color: AppTheme.glassBorders),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    borderSide: const BorderSide(color: AppTheme.primaryPurple),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.space4),
              const Text(
                'Model (optional)',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppTheme.space2),
              TextField(
                controller: _modelController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'google/gemma-4-31b-it:free',
                  hintStyle: const TextStyle(color: AppTheme.textMuted),
                  filled: true,
                  fillColor: AppTheme.deepSpace.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    borderSide: const BorderSide(color: AppTheme.glassBorders),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    borderSide: const BorderSide(color: AppTheme.glassBorders),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    borderSide: const BorderSide(color: AppTheme.primaryPurple),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.space5),
              ElevatedButton(
                onPressed: _apiKeyController.text.trim().isEmpty ? null : _saveConfig,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.space4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                ),
                child: const Text('Save & Connect', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatView() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppTheme.space5),
            itemCount: _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (_isTyping && index == _messages.length) {
                return _buildTypingIndicator();
              }
              final msg = _messages[index];
              final isCoach = msg['role'] == 'coach';
              return _buildMessageBubble(msg['text'], isCoach, msg['time']);
            },
          ),
        ),
        _buildInputArea(),
      ],
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: GlassCard(
          padding: const EdgeInsets.all(AppTheme.space4),
          tint: AppTheme.primaryPurple,
          opacity: 0.2,
          radius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          child: const SizedBox(
            width: 60,
            child: _TypingDots(),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isCoach, String time) {
    return Align(
      alignment: isCoach ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: isCoach ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            GlassCard(
              padding: const EdgeInsets.all(AppTheme.space4),
              tint: isCoach ? AppTheme.primaryPurple : AppTheme.roseGold,
              opacity: isCoach ? 0.2 : 0.3,
              radius: isCoach ? const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ) : const BorderRadius.only(
                topRight: Radius.circular(12),
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Text(
                text,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, height: 1.4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 4, left: 4),
              child: Text(time, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space5),
      decoration: BoxDecoration(
        color: AppTheme.deepSpace.withValues(alpha: 0.8),
        border: Border(top: BorderSide(color: AppTheme.glassBorders, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              radius: AppTheme.radiusPill,
              opacity: 0.05,
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Speak your truth...',
                  hintStyle: TextStyle(color: AppTheme.textMuted),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.space3),
          FloatingActionButton(
            onPressed: _sendMessage,
            backgroundColor: AppTheme.primaryPurple,
            child: const Icon(Icons.send, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.2;
            final progress = ((_controller.value - delay) % 1.0).clamp(0.0, 1.0);
            final opacity = (progress < 0.5) ? progress * 2 : (1 - progress) * 2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.textPrimary.withValues(alpha: 0.4 + opacity * 0.6),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}
