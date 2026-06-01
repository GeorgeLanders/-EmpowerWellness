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
    with SingleTickerProviderStateMixin {
  late AnimationController _breathController;
  late Animation<double> _breathAnim;
  bool _breathingActive = false;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    _breathAnim = Tween<double>(begin: 0.8, end: 1.4).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathController.dispose();
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
    if (!_breathingActive) return 'TAP TO START';
    final val = _breathController.value;
    if (val < 0.5) return 'BREATHE IN';
    return 'BREATHE OUT';
  }

  Future<void> _launchPhone(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchSms(String number) async {
    final uri = Uri.parse('sms:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.space5),
          child: Column(
            children: [
              const SizedBox(height: AppTheme.space4),
              _buildIntroCard(),
              const SizedBox(height: AppTheme.space5),
              _buildBreathingExercise(),
              const SizedBox(height: AppTheme.space6),
              _buildGroundingExercise(),
              const SizedBox(height: AppTheme.space5),
              _buildCrisisSection(),
              const SizedBox(height: AppTheme.space5),
              _buildQuickMoodLog(),
              const SizedBox(height: AppTheme.space6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.space5),
      tint: AppTheme.roseGold,
      opacity: 0.12,
      child: Column(
        children: [
          const Text('🌿', style: TextStyle(fontSize: 40)),
          const SizedBox(height: AppTheme.space3),
          const Text(
            'This is your safe space',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppTheme.space2),
          const Text(
            'Whatever you\'re feeling right now is valid. Take a moment to breathe, ground yourself, and remember: you are not alone.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.4),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBreathingExercise() {
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.space5),
      tint: AppTheme.primaryPurple,
      opacity: 0.12,
      child: Column(
        children: [
          const Text('Breathing Exercise',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppTheme.space4),
          GestureDetector(
            onTap: _toggleBreathing,
            child: SizedBox(
              height: 220,
              width: 220,
              child: AnimatedBuilder(
                animation: _breathAnim,
                builder: (context, child) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow ring
                      Container(
                        width: 200 * (_breathingActive ? _breathAnim.value : 0.8),
                        height: 200 * (_breathingActive ? _breathAnim.value : 0.8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryPurple.withValues(alpha: 0.08),
                        ),
                      ),
                      // Middle ring
                      Container(
                        width: 150 * (_breathingActive ? _breathAnim.value : 0.8),
                        height: 150 * (_breathingActive ? _breathAnim.value : 0.8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.primaryPurple.withValues(alpha: 0.15),
                          border: Border.all(
                            color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                      ),
                      // Inner circle with text
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.primaryPurple.withValues(alpha: 0.4),
                              AppTheme.primaryPurple.withValues(alpha: 0.1),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _getBreathText(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 1.0,
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
                ? 'Follow the circle. Breathe with it. You\'re doing great.'
                : 'Tap the circle to begin a calming breathing exercise.',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGroundingExercise() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('5-4-3-2-1 Grounding',
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: AppTheme.space2),
        const Text('Use your senses to anchor yourself in the present moment.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: AppTheme.space4),
        _buildGroundingItem('5', 'things you can see', Icons.visibility, AppTheme.neonCyan),
        _buildGroundingItem('4', 'things you can touch', Icons.touch_app, AppTheme.roseGold),
        _buildGroundingItem('3', 'things you can hear', Icons.hearing, AppTheme.warmGold),
        _buildGroundingItem('2', 'things you can smell', Icons.air, AppTheme.primaryPurple),
        _buildGroundingItem('1', 'thing you can taste', Icons.restaurant, AppTheme.hotCoral),
      ],
    );
  }

  Widget _buildGroundingItem(String number, String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.space3),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4, vertical: AppTheme.space3),
        tint: color,
        opacity: 0.08,
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.2),
              ),
              child: Center(
                child: Text(number,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            const SizedBox(width: AppTheme.space4),
            Icon(icon, color: color, size: 20),
            const SizedBox(width: AppTheme.space3),
            Expanded(
              child: Text(text,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrisisSection() {
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.space5),
      tint: AppTheme.hotCoral,
      opacity: 0.12,
      child: Column(
        children: [
          const Text('Need Immediate Help?',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: AppTheme.space2),
          const Text(
            'You are not alone. Trained professionals are available 24/7.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.space4),
          _buildCrisisButton(
            label: 'Call 988 Suicide & Crisis Lifeline',
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
            label: 'Call 911 Emergency',
            subtitle: 'Immediate danger',
            icon: Icons.emergency,
            color: const Color(0xFFD32F2F),
            onTap: () => _launchPhone('911'),
          ),
          const SizedBox(height: AppTheme.space4),
          const Text(
            'If you are in immediate danger, please call 911 right away.',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
            textAlign: TextAlign.center,
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
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: AppTheme.space3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: textColor ?? Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  Text(subtitle,
                      style: TextStyle(
                          color: (textColor ?? Colors.white).withValues(alpha: 0.7),
                          fontSize: 12)),
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
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.space4),
      tint: AppTheme.roseGold,
      opacity: 0.1,
      child: Column(
        children: [
          const Text('Log how you\'re feeling',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: AppTheme.space3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildMoodButton('😄', 'Great', 'great'),
              _buildMoodButton('🙂', 'Good', 'good'),
              _buildMoodButton('😐', 'Okay', 'okay'),
              _buildMoodButton('😔', 'Low', 'low'),
              _buildMoodButton('😢', 'Bad', 'bad'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodButton(String emoji, String label, String value) {
    return GestureDetector(
      onTap: () {
        final user = StorageService().loadUserData();
        user.mood = value;
        StorageService().saveUserData(user);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mood logged: $emoji $label'),
              duration: const Duration(seconds: 2),
              backgroundColor: AppTheme.voidPurple,
            ),
          );
      },
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}
