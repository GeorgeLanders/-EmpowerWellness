import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/animated_background.dart';

class SOSScreen extends StatefulWidget {
  const SOSScreen({super.key});

  @override
  State<SOSScreen> createState() => _SOSScreenState();
}

class _SOSScreenState extends State<SOSScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathController;
  late Animation<double> _breathAnim;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _breathAnim = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  Future<void> _launchPhone(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to call $number')),
        );
      }
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
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.space5),
          child: Column(
            children: [
              const SizedBox(height: AppTheme.space6),

              // ── BREATHING EXERCISE ──
              _buildBreathingCircle(),

              const SizedBox(height: AppTheme.space8),

              // ── GROUNDING ──
              const Text(
                'Ground Yourself',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary),
              ),
              const SizedBox(height: AppTheme.space4),

              _buildGroundingItem('5 things you can see', Icons.visibility),
              _buildGroundingItem('4 things you can touch', Icons.touch_app),
              _buildGroundingItem('3 things you can hear', Icons.hearing),
              _buildGroundingItem('2 things you can smell', Icons.air),
              _buildGroundingItem('1 thing you can taste', Icons.restaurant),

              const SizedBox(height: AppTheme.space6),

              // ── EMERGENCY ACTIONS ──
              GlassCard(
                padding: const EdgeInsets.all(AppTheme.space5),
                tint: AppTheme.hotCoral,
                opacity: 0.2,
                radius: AppTheme.radiusXl,
                child: Column(
                  children: [
                    const Text(
                      'Need Immediate Help?',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    const SizedBox(height: AppTheme.space3),
                    const Text(
                      'You are not alone. Reach out to a crisis professional.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: AppTheme.space4),

                    // Crisis Hotline — 988
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _launchPhone('988'),
                        icon:
                            const Icon(Icons.phone, color: Colors.white, size: 18),
                        label: const Text('Call 988 Crisis Line',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.hotCoral,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusPill),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.space3),

                    // Text Crisis Line — 741741
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _launchSms('741741'),
                        icon: const Icon(Icons.message,
                            color: AppTheme.deepSpace, size: 18),
                        label: const Text('Text Crisis Line',
                            style: TextStyle(color: AppTheme.deepSpace)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.warmGold,
                          foregroundColor: AppTheme.deepSpace,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusPill),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.space3),

                    // Emergency — 911
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _launchPhone('911'),
                        icon: const Icon(Icons.emergency,
                            color: Colors.white, size: 18),
                        label: const Text('Call 911 Emergency',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusPill),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.space4),

              // ── Disclaimer ──
              const Text(
                'If you are in immediate danger, call 911.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
              ),

              const SizedBox(height: AppTheme.space6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBreathingCircle() {
    return Center(
      child: Column(
        children: [
          SizedBox(
            height: 300,
            width: 300,
            child: AnimatedBuilder(
              animation: _breathAnim,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 200 * _breathAnim.value,
                      height: 200 * _breathAnim.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.hotCoral.withValues(alpha: 0.1),
                      ),
                    ),
                    Container(
                      width: 150 * _breathAnim.value,
                      height: 150 * _breathAnim.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.hotCoral,
                            AppTheme.hotCoral.withValues(alpha: 0.4),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.hotCoral.withValues(alpha: 0.5),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _getBreathText(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              letterSpacing: 1.2),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: AppTheme.space6),
          const Text(
            'Breathe in... and out...',
            style: TextStyle(
                color: AppTheme.roseGold,
                fontSize: 16,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  String _getBreathText() {
    double val = _breathController.value;
    if (val < 0.5) return 'IN';
    return 'OUT';
  }

  Widget _buildGroundingItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.space3),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.space4, vertical: AppTheme.space3),
        tint: AppTheme.hotCoral,
        opacity: 0.1,
        radius: AppTheme.radiusMd,
        child: Row(
          children: [
            Icon(icon, color: AppTheme.hotCoral, size: 20),
            const SizedBox(width: AppTheme.space4),
            Text(text,
                style: const TextStyle(
                    color: AppTheme.textPrimary, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
