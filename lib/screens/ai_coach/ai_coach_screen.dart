import 'package:flutter/material.dart';
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

class _AICoachScreenState extends State<AICoachScreen> {
  final TextEditingController _messageController = TextEditingController();
  final StorageService _storage = StorageService();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;
  bool _isConfigured = false;
  bool _isLoading = true;
  String _userName = 'Friend';
  String _apiKey = '';
  String _model = 'google/gemma-4-31b-it:free';

  // Change this to your Render URL
  static const String _serverUrl = 'https://empowerwellness.onrender.com';

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  void _loadConfig() {
    _apiKey = _storage.getApiKey();
    _model = _storage.getModel();
    final userData = _storage.loadUserData();
    _userName = userData.name.isNotEmpty ? userData.name : 'Friend';

    if (_apiKey.isNotEmpty) {
      _isConfigured = true;
      _addCoachMessage('Welcome back, $_userName. I\'m Big Pickle Free, and I\'m here whenever you\'re ready. How are you feeling today?');
    }

    setState(() => _isLoading = false);
  }

  void _saveConfig(String apiKey, String model) async {
    _apiKey = apiKey;
    _model = model;
    await _storage.saveApiKey(apiKey);
    await _storage.saveModel(model);
    setState(() {
      _isConfigured = true;
    });
    _addCoachMessage('Hi $_userName! I\'m Big Pickle Free — your personal wellness coach. No judgment here, just support. What\'s on your mind today?');
  }

  void _addCoachMessage(String text) {
    setState(() {
      _messages.add({
        'role': 'coach',
        'text': text,
        'time': _formatTime(),
      });
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

    try {
      final history = _messages
          .where((m) => m['role'] != 'user' || true)
          .map((m) => {'role': m['role'] == 'coach' ? 'assistant' : 'user', 'content': m['text']})
          .toList();
      // Remove the last entry (the one we just added as user)
      if (history.isNotEmpty) history.removeLast();

      final response = await http.post(
        Uri.parse('$_serverUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': text,
          'user_name': _userName,
          'history': history,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['reply'] ?? 'I\'m here for you. Tell me more about how you\'re feeling.';
        setState(() {
          _isTyping = false;
          _messages.add({'role': 'coach', 'text': reply, 'time': _formatTime()});
        });
      } else {
        throw Exception('Server returned ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isTyping = false;
        _messages.add({
          'role': 'coach',
          'text': 'I\'m having trouble connecting right now. Make sure your API key is set up, or try again in a moment. I\'m still here for you. 💚',
          'time': _formatTime(),
        });
      });
    }
  }

  String _formatTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
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
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryPurple, AppTheme.roseGold],
                  ),
                ),
                child: const Center(child: Text('🥒', style: TextStyle(fontSize: 16))),
              ),
              const SizedBox(width: 10),
              const Text('Big Pickle Free',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 18)),
            ],
          ),
          centerTitle: true,
        ),
        body: _isConfigured ? _buildChatView() : _buildSetupView(),
      ),
    );
  }

  Widget _buildSetupView() {
    final keyController = TextEditingController();
    final modelController = TextEditingController(text: _model);

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
              const Center(child: Text('🥒', style: TextStyle(fontSize: 48))),
              const SizedBox(height: AppTheme.space4),
              const Text(
                'Meet Big Pickle Free',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.space2),
              const Text(
                'Your personal wellness coach — no shame, no judgment, just real support.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.space5),
              const Text('OpenRouter API Key',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: AppTheme.space2),
              TextField(
                controller: keyController,
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
                ),
              ),
              const SizedBox(height: AppTheme.space4),
              const Text('Model (optional)',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: AppTheme.space2),
              TextField(
                controller: modelController,
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
                ),
              ),
              const SizedBox(height: AppTheme.space5),
              ElevatedButton(
                onPressed: () {
                  if (keyController.text.trim().isNotEmpty) {
                    _saveConfig(keyController.text.trim(), modelController.text.trim());
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusPill)),
                ),
                child: const Text('Connect & Start',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: AppTheme.space3),
              const Text(
                'Get a free key at openrouter.ai',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                textAlign: TextAlign.center,
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
        // Quick action chips
        if (_messages.length <= 1) _buildQuickPrompts(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5, vertical: AppTheme.space3),
            itemCount: _messages.length + (_isTyping ? 1 : 0),
            itemBuilder: (context, index) {
              if (_isTyping && index == _messages.length) return _buildTypingIndicator();
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

  Widget _buildQuickPrompts() {
    final prompts = [
      '💪 Help me get motivated',
      '🧘 I\'m feeling stressed',
      '🍎 What should I eat?',
      '😴 I can\'t sleep',
      '🚶 Suggest a quick workout',
    ];
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4),
        children: prompts.map((p) {
          return GestureDetector(
            onTap: () {
              _messageController.text = p.substring(2).trim();
              _sendMessage();
            },
            child: Container(
              margin: const EdgeInsets.only(right: AppTheme.space2),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.glassPurple,
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                border: Border.all(color: AppTheme.primaryPurple.withValues(alpha: 0.3)),
              ),
              child: Center(child: Text(p, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13))),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          tint: AppTheme.primaryPurple,
          opacity: 0.2,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🥒', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              SizedBox(
                width: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(3, (i) =>
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppTheme.textPrimary.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isCoach, String time) {
    return Align(
      alignment: isCoach ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        child: Column(
          crossAxisAlignment: isCoach ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            GlassCard(
              padding: const EdgeInsets.all(AppTheme.space4),
              tint: isCoach ? AppTheme.primaryPurple : AppTheme.roseGold,
              opacity: isCoach ? 0.15 : 0.25,
              child: Text(
                text,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15, height: 1.4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
              child: Text(time, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space4),
      decoration: BoxDecoration(
        color: AppTheme.deepSpace.withValues(alpha: 0.8),
        border: Border(top: BorderSide(color: AppTheme.glassBorders, width: 1)),
      ),
      child: SafeArea(
        top: false,
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
                    hintText: 'Share what\'s on your mind...',
                    hintStyle: TextStyle(color: AppTheme.textMuted),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                  maxLines: null,
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
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryPurple, AppTheme.hotCoral],
                  ),
                  boxShadow: [
                    BoxShadow(color: AppTheme.primaryPurple.withValues(alpha: 0.4), blurRadius: 8),
                  ],
                ),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
