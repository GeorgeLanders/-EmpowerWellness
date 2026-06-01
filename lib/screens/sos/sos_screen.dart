import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/animated_background.dart';
import '../../services/storage_service.dart';

class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen>
    with TickerProviderStateMixin {
  late AnimationController _breathController;
  late AnimationController _fadeController;
  late Animation<double> _breathAnim;
  late Animation<double> _fadeAnim;
  bool _breathingActive = false;
  int _currentGroundingIndex = -1;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 8),
    );
    _breathAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _breathController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _toggleBreathing() {
    setState(() {
      _breathingActive = !_breathingActive;
      if (_breathingActive) {
        _breathController.repeat(reverse: true);
      } else {
        _breathController.stop();
        _breathController.reset();
      }
    });
  }

  String _getBreathText() {
    if (!_breathingActive) return 'TAP TO\nSTART';
    final val = _breathController.value;
    if (val < 0.5) return 'BREATHE\nIN';
    return 'BREATHE\nOUT';
  }

  Future<void> _launchPhone(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _launchSms(String number) async {
    final uri = Uri.parse('sms:$number');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Quiet Space',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          centerTitle: true,
        ),
        body: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.space5),
            child: Column(
              children: [
                const SizedBox(height: AppTheme.space2),
                _buildIntroCard(),
                const SizedBox(height: AppTheme.space5),
                _buildBreathingExercise(),
                const SizedBox(height: AppTheme.space6),
                _buildGroundingExercise(),
                const SizedBox(height: AppTheme.space5),
                _buildReliefActions(),
                const SizedBox(height: AppTheme.space5),
                _buildCrisisSection(),
                const SizedBox(height: AppTheme.space5),
                _buildQuickMoodLog(),
                const SizedBox(height: AppTheme.space6),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return GestureDetector(
      onTap: _toggleBreathing,
      child: GlassCard(
        padding: const EdgeInsets.all(AppTheme.space5),
        tint: AppTheme.roseGold,
        opacity: 0.08,
        glowing: true,
        glowColor: AppTheme.roseGold,
        glowIntensity: 0.1,
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.roseGold.withValues(alpha: 0.3),
                    AppTheme.roseGold.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: const Center(child: Text('🌿', style: TextStyle(fontSize: 28))),
            ),
            const SizedBox(width: AppTheme.space4),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('This is your safe space',
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 4),
                  Text('Whatever you\'re feeling is valid. Take a moment. You are not alone.',
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreathingExercise() {
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.space5),
      tint: AppTheme.primaryPurple,
      opacity: 0.08,
      glowing: _breathingActive,
      glowColor: AppTheme.primaryPurple,
      glowIntensity: _breathingActive ? 0.12 : 0.05,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.air_rounded, color: AppTheme.primaryPurple, size: 18),
              const SizedBox(width: 8),
              const Text('Breathing Exercise',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: AppTheme.space4),
          GestureDetector(
            onTap: _toggleBreathing,
            child: SizedBox(
              height: 240,
              width: 240,
              child: AnimatedBuilder(
                animation: _breathAnim,
                builder: (context, child) {
                  final scale = _breathingActive
                      ? 0.8 + (_breathAnim.value * 0.6)
                      : 0.8;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer ring
                      _buildBreathRing(220 * scale, AppTheme.primaryPurple.withValues(alpha: 0.04)),
                      // Middle ring
                      _buildBreathRing(180 * scale, AppTheme.primaryPurple.withValues(alpha: 0.08)),
                      // Inner ring
                      _buildBreathRing(140 * scale, AppTheme.primaryPurple.withValues(alpha: 0.12)),
                      // Core
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.primaryPurple.withValues(alpha: 0.5),
                              AppTheme.primaryPurple.withValues(alpha: 0.15),
                            ],
                          ),
                          boxShadow: _breathingActive
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            _getBreathText(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 0.8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space4),
          Text(
            _breathingActive
                ? 'Follow the circle. In... and out... You\'re doing great.'
                : 'Tap to begin a calming breath. Inhale as it grows, exhale as it shrinks.',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBreathRing(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
    );
  }

  Widget _buildGroundingExercise() {
    final items = [
      {'number': '5', 'text': 'things you can see', 'icon': Icons.visibility, 'color': AppTheme.neonCyan},
      {'number': '4', 'text': 'things you can touch', 'icon': Icons.touch_app, 'color': AppTheme.roseGold},
      {'number': '3', 'text': 'things you can hear', 'icon': Icons.hearing, 'color': AppTheme.warmGold},
      {'number': '2', 'text': 'things you can smell', 'icon': Icons.air, 'color': AppTheme.mintGreen},
      {'number': '1', 'text': 'thing you can taste', 'icon': Icons.restaurant, 'color': AppTheme.hotCoral},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('5-4-3-2-1 Grounding',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: AppTheme.space2),
        const Text('Use your senses to anchor yourself in the present.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: AppTheme.space4),
        ...List.generate(items.length, (i) {
          final item = items[i];
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + (i * 100)),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(30 * (1 - value), 0),
                child: Opacity(opacity: value, child: child),
              );
            },
            child: GestureDetector(
              onTap: () {
                setState(() => _currentGroundingIndex = i);
                Future.delayed(const Duration(seconds: 3), () {
                  if (mounted) setState(() => _currentGroundingIndex = -1);
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: AppTheme.space2),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4, vertical: AppTheme.space3),
                  tint: item['color'] as Color,
                  opacity: _currentGroundingIndex == i ? 0.15 : 0.05,
                  glowing: _currentGroundingIndex == i,
                  glowColor: item['color'] as Color,
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (item['color'] as Color).withValues(alpha: 0.15),
                          border: Border.all(color: (item['color'] as Color).withValues(alpha: 0.3)),
                        ),
                        child: Center(
                          child: Text(item['number'] as String,
                              style: TextStyle(color: item['color'] as Color, fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                      ),
                      const SizedBox(width: AppTheme.space4),
                      Icon(item['icon'] as IconData, color: item['color'] as Color, size: 20),
                      const SizedBox(width: AppTheme.space3),
                      Expanded(
                        child: Text(item['text'] as String,
                            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
                      ),
                      if (_currentGroundingIndex == i)
                        const Icon(Icons.check_circle, color: AppTheme.mintGreen, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildReliefActions() {
    final actions = [
      {'emoji': '🧊', 'title': 'Cold Water', 'desc': 'Splash cold water on your wrists', 'color': AppTheme.neonCyan},
      {'emoji': '🎵', 'title': 'Unground', 'desc': 'Name 5 colors you can see right now', 'color': AppTheme.plasmaViolet},
      {'emoji': '🤲', 'title': 'Press', 'desc': 'Press your palms together hard for 10s', 'color': AppTheme.roseGold},
      {'emoji': '📝', 'title': 'Write', 'desc': 'Write down 3 things you\'re grateful for', 'color': AppTheme.mintGreen},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Relief',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: AppTheme.space3),
        ...actions.map((a) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.space2),
            child: GlassCard(
              padding: const EdgeInsets.all(AppTheme.space3),
              tint: a['color'] as Color,
              opacity: 0.06,
              child: Row(
                children: [
                  Text(a['emoji'] as String, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: AppTheme.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a['title'] as String,
                            style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(a['desc'] as String,
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCrisisSection() {
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.space5),
      tint: AppTheme.hotCoral,
      opacity: 0.08,
      glowing: true,
      glowColor: AppTheme.hotCoral,
      glowIntensity: 0.08,
      child: Column(
        children: [
          const Text('Need Immediate Help?',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: AppTheme.space2),
          const Text('You are not alone. Trained professionals are available 24/7.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              textAlign: TextAlign.center),
          const SizedBox(height: AppTheme.space4),
          _buildCrisisButton(
            label: '988 Suicide & Crisis Lifeline',
            subtitle: 'Free, confidential, 24/7',
            icon: Icons.phone,
            color: AppTheme.hotCoral,
            onTap: () => _launchPhone('988'),
          ),
          const SizedBox(height: AppTheme.space3),
          _buildCrisisButton(
            label: 'Text HOME to 741741',
            subtitle: 'Crisis Text Line',
            icon: Icons.message,
            color: AppTheme.warmGold,
            textColor: AppTheme.deepSpace,
            onTap: () => _launchSms('741741'),
          ),
          const SizedBox(height: AppTheme.space3),
          _buildCrisisButton(
            label: '911 Emergency',
            subtitle: 'Immediate danger',
            icon: Icons.emergency,
            color: const Color(0xFFD32F2F),
            onTap: () => _launchPhone('911'),
          ),
        ],
      ),
    );
  }

  Widget _buildCrisisButton({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color color,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.2),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: AppTheme.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(color: textColor ?? Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(subtitle,
                      style: TextStyle(color: (textColor ?? Colors.white).withValues(alpha: 0.7), fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickMoodLog() {
    final moods = ['😄', '🙂', '😐', '😔', '😢'];
    final labels = ['Great', 'Good', 'Okay', 'Low', 'Bad'];
    final values = ['great', 'good', 'okay', 'low', 'bad'];

    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.space4),
      tint: AppTheme.roseGold,
      opacity: 0.08,
      child: Column(
        children: [
          const Text('Log how you\'re feeling',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: AppTheme.space3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(moods.length, (i) {
              return GestureDetector(
                onTap: () {
                  final user = StorageService().loadUserData();
                  user.mood = values[i];
                  StorageService().saveUserData(user);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Mood logged: ${moods[i]} ${labels[i]}'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: AppTheme.voidPurple,
                    ),
                  );
                },
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.glassWhite,
                        border: Border.all(color: AppTheme.glassBorders),
                      ),
                      child: Center(child: Text(moods[i], style: const TextStyle(fontSize: 24))),
                    ),
                    const SizedBox(height: 4),
                    Text(labels[i], style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
