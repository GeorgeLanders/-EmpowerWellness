import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';
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
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _isLoading = true;
  bool _voiceEnabled = true;
  bool _isSpeaking = false;
  final String _userName = 'Friend';
  late AnimationController _avatarPulseController;
  late FlutterTts _tts;

  // ── Quick Prompts System ──
  String _selectedCategory = 'All';
  int _staggerNonce = 0;
  int _flashedPromptIndex = -1;
  final Random _rng = Random();
  late List<Map<String, dynamic>> _prompts;

  static const List<Map<String, dynamic>> _allPrompts = [
    // Energy & Motivation (purple)
    {'emoji': '💪', 'text': 'Help me get motivated', 'category': 'Energy', 'color': AppTheme.primaryPurple},
    {'emoji': '⚡', 'text': 'I need an energy boost', 'category': 'Energy', 'color': AppTheme.primaryPurple},
    {'emoji': '🌟', 'text': 'I want to feel stronger', 'category': 'Energy', 'color': AppTheme.primaryPurple},
    {'emoji': '🏆', 'text': 'Celebrate a win with me', 'category': 'Energy', 'color': AppTheme.primaryPurple},
    // Mood & Calm (cyan)
    {'emoji': '🧘', 'text': "I'm feeling stressed", 'category': 'Mood', 'color': AppTheme.neonCyan},
    {'emoji': '💙', 'text': "I'm feeling down", 'category': 'Mood', 'color': AppTheme.neonCyan},
    {'emoji': '😤', 'text': "I'm frustrated today", 'category': 'Mood', 'color': AppTheme.neonCyan},
    {'emoji': '😰', 'text': "I'm anxious about something", 'category': 'Mood', 'color': AppTheme.neonCyan},
    // Sleep & Rest (gold)
    {'emoji': '😴', 'text': "I can't sleep", 'category': 'Sleep', 'color': AppTheme.warmGold},
    {'emoji': '🌙', 'text': 'Help me wind down', 'category': 'Sleep', 'color': AppTheme.warmGold},
    {'emoji': '☕', 'text': 'I had too much caffeine', 'category': 'Sleep', 'color': AppTheme.warmGold},
    {'emoji': '🌅', 'text': "I'm tired in the morning", 'category': 'Sleep', 'color': AppTheme.warmGold},
    // Body & Movement (coral)
    {'emoji': '🚶', 'text': 'Quick workout idea', 'category': 'Body', 'color': AppTheme.hotCoral},
    {'emoji': '💧', 'text': 'Remind me to hydrate', 'category': 'Body', 'color': AppTheme.hotCoral},
    {'emoji': '🍎', 'text': 'What should I eat?', 'category': 'Body', 'color': AppTheme.hotCoral},
    {'emoji': '🦴', 'text': "I'm sore today", 'category': 'Body', 'color': AppTheme.hotCoral},
    {'emoji': '🍳', 'text': 'Help me log my meals', 'category': 'Body', 'color': AppTheme.hotCoral},
  ];

  static const List<Map<String, dynamic>> _categories = [
    {'key': 'All', 'emoji': '✨', 'color': AppTheme.softLavender, 'label': 'All suggestions'},
    {'key': 'Energy', 'emoji': '⚡', 'color': AppTheme.primaryPurple, 'label': 'Energy & Motivation'},
    {'key': 'Mood', 'emoji': '💙', 'color': AppTheme.neonCyan, 'label': 'Mood & Calm'},
    {'key': 'Sleep', 'emoji': '🌙', 'color': AppTheme.warmGold, 'label': 'Sleep & Rest'},
    {'key': 'Body', 'emoji': '💪', 'color': AppTheme.hotCoral, 'label': 'Body & Movement'},
  ];

  static const String _serverUrl = 'https://empowerwellness.onrender.com';

  @override
  void initState() {
    super.initState();
    _avatarPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _voiceEnabled = StorageService().getBool('voice_guidance', defaultValue: true);
    _initTts();
    // Auto-connect: server holds the API key
    _addCoachMessage('Welcome back, $_userName! 💚 I\'m Lumina — your personal wellness coach. How are you feeling today?');
    setState(() => _isLoading = false);
    _prompts = List<Map<String, dynamic>>.from(_allPrompts);
  }

  Future<void> _initTts() async {
    _tts = FlutterTts();
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.42);   // slower, comfortable for seniors
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    // Try to pick a warm female voice if available; fall back to default
    try {
      final voices = await _tts.getVoices;
      if (voices is List) {
        final preferred = voices.firstWhere(
          (v) {
            final n = (v['name'] ?? '').toString().toLowerCase();
            return n.contains('female') || n.contains('samantha') ||
                   n.contains('aria') || n.contains('karen') ||
                   n.contains('fiona') || n.contains('victoria') ||
                   n.contains('nova') || n.contains('allison');
          },
          orElse: () => null,
        );
        if (preferred != null && preferred['name'] != null) {
          await _tts.setVoice({'name': preferred['name'], 'locale': preferred['locale'] ?? 'en-US'});
        }
      }
    } catch (_) {
      // Voice selection is best-effort; default voice will be used
    }
    _tts.setStartHandler(() { if (mounted) setState(() => _isSpeaking = true); });
    _tts.setCompletionHandler(() { if (mounted) setState(() => _isSpeaking = false); });
    _tts.setCancelHandler(() { if (mounted) setState(() => _isSpeaking = false); });
    _tts.setErrorHandler((_) { if (mounted) setState(() => _isSpeaking = false); });
  }

  @override
  void dispose() {
    _tts.stop();
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
    if (_voiceEnabled) {
      _tts.stop();
      _tts.speak(text);
    }
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
                    child: const Center(child: Text('💎', style: TextStyle(fontSize: 16))),
                  );
                },
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Lumina',
                      style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary, fontSize: 16)),
                  Text(
                    _isSpeaking
                        ? 'Speaking…'
                        : (_voiceEnabled ? 'Tap speaker to mute' : 'Voice is off'),
                    style: TextStyle(
                      color: _isSpeaking ? AppTheme.neonCyan : AppTheme.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: _voiceEnabled ? 'Mute Lumina' : 'Unmute Lumina',
              onPressed: () {
                setState(() => _voiceEnabled = !_voiceEnabled);
                StorageService().setBool('voice_guidance', _voiceEnabled);
                if (!_voiceEnabled) {
                  _tts.stop();
                  _isSpeaking = false;
                }
              },
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  _voiceEnabled
                      ? (_isSpeaking ? Icons.graphic_eq : Icons.volume_up_rounded)
                      : Icons.volume_off_rounded,
                  key: ValueKey(_voiceEnabled.toString() + _isSpeaking.toString()),
                  color: _isSpeaking ? AppTheme.neonCyan : AppTheme.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 4),
          ],
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
    // Filter prompts by selected category
    final List<Map<String, dynamic>> filteredPrompts = _selectedCategory == 'All'
        ? List<Map<String, dynamic>>.from(_prompts)
        : _prompts.where((p) => p['category'] == _selectedCategory).toList();

    // Resolve current category color for the header
    final currentCat = _categories.firstWhere(
      (c) => c['key'] == _selectedCategory,
      orElse: () => _categories.first,
    );
    final Color categoryColor = currentCat['color'] as Color;

    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: AppTheme.space2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row: section label + refresh ──
          Padding(
            padding: const EdgeInsets.fromLTRB(AppTheme.space5, 0, AppTheme.space2, AppTheme.space2),
            child: Row(
              children: [
                const Text(
                  'Quick suggestions',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _shufflePrompts,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.space1),
                    decoration: BoxDecoration(
                      color: AppTheme.glassWhite,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      border: Border.all(color: AppTheme.glassBorders),
                    ),
                    child: const Icon(
                      Icons.refresh_rounded,
                      color: AppTheme.textSecondary,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Category filter row (GlassCard) ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(vertical: AppTheme.space2, horizontal: AppTheme.space3),
              radius: AppTheme.radiusPill,
              tint: AppTheme.glassWhite,
              opacity: 0.05,
              child: SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: AppTheme.space2),
                  itemBuilder: (context, idx) {
                    final cat = _categories[idx];
                    final Color catColor = cat['color'] as Color;
                    final bool isSelected = _selectedCategory == cat['key'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat['key'] as String;
                          _staggerNonce++;
                          _flashedPromptIndex = -1;
                        });
                      },
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.space3, vertical: AppTheme.space1),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? catColor.withValues(alpha: 0.22)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                          border: Border.all(
                            color: isSelected
                                ? catColor.withValues(alpha: 0.6)
                                : AppTheme.glassBorders,
                            width: isSelected ? 1.2 : 1.0,
                          ),
                          boxShadow: [
                            if (isSelected)
                              BoxShadow(
                                color: catColor.withValues(alpha: 0.35),
                                blurRadius: 10,
                                spreadRadius: 0,
                              ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(cat['emoji'] as String, style: const TextStyle(fontSize: 13)),
                            const SizedBox(width: 5),
                            Text(
                              cat['key'] as String,
                              style: TextStyle(
                                color: isSelected ? catColor : AppTheme.textSecondary,
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // ── Category name label above the prompt row ──
          if (filteredPrompts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(AppTheme.space5, AppTheme.space2, AppTheme.space4, AppTheme.space1),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: categoryColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: categoryColor.withValues(alpha: 0.6), blurRadius: 6),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppTheme.space1),
                  Text(
                    currentCat['label'] as String,
                    style: TextStyle(
                      color: categoryColor,
                      fontSize: 10,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // ── Prompt chips (filtered, staggered, with color flash) ──
          SizedBox(
            height: 56,
            child: filteredPrompts.isEmpty
                ? Center(
                    child: Text(
                      'No prompts here',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4),
                    itemCount: filteredPrompts.length,
                    itemBuilder: (context, index) {
                      final p = filteredPrompts[index];
                      final Color pColor = p['color'] as Color;
                      final bool isFlashing = _flashedPromptIndex == index;
                      return TweenAnimationBuilder<double>(
                        key: ValueKey('prompt_${_staggerNonce}_$index'),
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 300 + (index * 50).clamp(0, 300)),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, 14 * (1 - value)),
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: AppTheme.space2),
                          child: GestureDetector(
                            onTap: () => _onPromptTapped(index, p),
                            behavior: HitTestBehavior.opaque,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              height: 56,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: isFlashing
                                    ? pColor.withValues(alpha: 0.35)
                                    : AppTheme.glassWhite,
                                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                                border: Border(
                                  left: BorderSide(color: pColor, width: 4),
                                  top: BorderSide(color: AppTheme.glassBorders),
                                  right: BorderSide(color: AppTheme.glassBorders),
                                  bottom: BorderSide(color: AppTheme.glassBorders),
                                ),
                                boxShadow: [
                                  if (isFlashing)
                                    BoxShadow(
                                      color: pColor.withValues(alpha: 0.45),
                                      blurRadius: 14,
                                      spreadRadius: 0,
                                    ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(p['emoji'] as String, style: const TextStyle(fontSize: 16)),
                                  const SizedBox(width: 8),
                                  Text(
                                    p['text'] as String,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _onPromptTapped(int index, Map<String, dynamic> prompt) {
    // Trigger the highlight flash (color flash for 300ms)
    setState(() => _flashedPromptIndex = index);
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => _flashedPromptIndex = -1);
      _messageController.text = prompt['text'] as String;
      _sendMessage();
    });
  }

  void _shufflePrompts() {
    setState(() {
      _prompts.shuffle(_rng);
      _staggerNonce++;
      _flashedPromptIndex = -1;
    });
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
