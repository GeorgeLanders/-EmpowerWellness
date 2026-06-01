import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/animated_background.dart';
import '../../services/diorama_controller.dart';
import '../../services/storage_service.dart';
import '../../models/user_data.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _storage = StorageService();
  late UserData _user;

  @override
  void initState() {
    super.initState();
    _user = _storage.loadUserData();
  }

  void _reload() {
    setState(() {
      _user = _storage.loadUserData();
    });
  }

  void _logWater() {
    if (_user.waterCups < 8) {
      _user.waterCups++;
      _storage.saveUserData(_user);
      _reload();
    }
  }

  void _logMood(String mood) {
    _user.mood = mood;
    _storage.saveUserData(_user);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final int totalProgress = _calculateTotalProgress();
    final WorldState currentState = DioramaController.calculateState(totalProgress);

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.space5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: AppTheme.space5),
                _buildDioramaCard(currentState),
                const SizedBox(height: AppTheme.space5),
                _buildWorldProgress(totalProgress),
                const SizedBox(height: AppTheme.space5),
                _buildDailyStats(),
                const SizedBox(height: AppTheme.space5),
                _buildQuickLog(),
                const SizedBox(height: AppTheme.space5),
                _buildTipsCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting, ${_user.name}!',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getMotivationalLine(),
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            // TODO: navigate to profile
          },
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppTheme.primaryPurple, AppTheme.roseGold],
              ),
              boxShadow: [
                BoxShadow(color: AppTheme.primaryPurple.withValues(alpha: 0.4), blurRadius: 12),
              ],
            ),
            child: Center(
              child: Text(
                _user.name.isNotEmpty ? _user.name[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getMotivationalLine() {
    final int progress = _calculateTotalProgress();
    if (progress < 20) return 'Every empire starts with a single seed. 🌱';
    if (progress < 40) return 'Look at you growing! Your sprout is emerging. 🌿';
    if (progress < 60) return 'Your tree is taking shape. Keep going! 🌳';
    if (progress < 80) return 'A garden of progress! You\'re flourishing. 🌸';
    return 'Your empire is magnificent! You\'re unstoppable! 👑';
  }

  Widget _buildDioramaCard(WorldState state) {
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.space5),
      tint: AppTheme.primaryPurple,
      opacity: 0.15,
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primaryPurple.withValues(alpha: 0.6),
                  AppTheme.deepSpace,
                ],
              ),
              boxShadow: [
                BoxShadow(color: AppTheme.primaryPurple.withValues(alpha: 0.3), blurRadius: 20),
              ],
            ),
            child: Center(
              child: Text(_getWorldEmoji(state), style: const TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(width: AppTheme.space4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getWorldTitle(state),
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getWorldDescription(state),
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getWorldEmoji(WorldState state) {
    switch (state) {
      case WorldState.seed: return '🌱';
      case WorldState.sprout: return '🌿';
      case WorldState.tree: return '🌳';
      case WorldState.garden: return '🌸';
      case WorldState.empire: return '🏰';
    }
  }

  String _getWorldTitle(WorldState state) {
    switch (state) {
      case WorldState.seed: return 'The Seed';
      case WorldState.sprout: return 'The Sprout';
      case WorldState.tree: return 'The Tree';
      case WorldState.garden: return 'The Garden';
      case WorldState.empire: return 'The Empire';
    }
  }

  String _getWorldDescription(WorldState state) {
    switch (state) {
      case WorldState.seed: return 'Your journey has begun. Small steps create mighty empires.';
      case WorldState.sprout: return 'Growth is happening! You\'re building momentum.';
      case WorldState.tree: return 'Strong roots, strong you. Your dedication is showing.';
      case WorldState.garden: return 'A thriving ecosystem of healthy habits is forming.';
      case WorldState.empire: return 'You\'ve built something incredible. You are unstoppable!';
    }
  }

  Widget _buildWorldProgress(int progress) {
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.space4),
      tint: AppTheme.neonCyan,
      opacity: 0.1,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('World Evolution',
                  style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
              Text('$progress%',
                  style: const TextStyle(color: AppTheme.neonCyan, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: AppTheme.space3),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            color: AppTheme.neonCyan,
            minHeight: 8,
          ),
          const SizedBox(height: AppTheme.space2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStageDot('🌱', progress >= 0),
              _buildStageDot('🌿', progress >= 20),
              _buildStageDot('🌳', progress >= 40),
              _buildStageDot('🌸', progress >= 60),
              _buildStageDot('🏰', progress >= 80),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStageDot(String emoji, bool unlocked) {
    return Opacity(
      opacity: unlocked ? 1.0 : 0.3,
      child: Text(emoji, style: const TextStyle(fontSize: 20)),
    );
  }

  Widget _buildDailyStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Today\'s Stats',
            style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: AppTheme.space3),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: AppTheme.space3,
          crossAxisSpacing: AppTheme.space3,
          childAspectRatio: 1.5,
          children: [
            _statCard('Water', '${_user.waterCups}/8', 'cups', Icons.water_drop, AppTheme.neonCyan),
            _statCard('Steps', '${(_user.steps / 1000).toStringAsFixed(1)}k', 'steps', Icons.directions_walk, AppTheme.warmGold),
            _statCard('Sleep', '${_user.sleepHours}', 'hours', Icons.nightlight_round, AppTheme.primaryPurple),
            _statCard('Mood', _getMoodEmoji(_user.mood), '', Icons.emoji_emotions, AppTheme.roseGold),
          ],
        ),
      ],
    );
  }

  String _getMoodEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'great': return '😄';
      case 'good': return '🙂';
      case 'okay': return '😐';
      case 'low': return '😔';
      case 'bad': return '😢';
      default: return '🙂';
    }
  }

  Widget _statCard(String label, String value, String unit, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.space3),
      tint: color,
      opacity: 0.1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          if (unit.isNotEmpty) Text(unit, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildQuickLog() {
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.space4),
      tint: AppTheme.roseGold,
      opacity: 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Log',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: AppTheme.space3),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _logWater,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.neonCyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: AppTheme.neonCyan.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.water_drop, color: AppTheme.neonCyan, size: 24),
                        const SizedBox(height: 4),
                        const Text('+ Water', style: TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text('${_user.waterCups}/8', style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.space2),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showMoodPicker(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.roseGold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: AppTheme.roseGold.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(_getMoodEmoji(_user.mood), style: const TextStyle(fontSize: 24)),
                        const SizedBox(height: 4),
                        const Text('Mood', style: TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(_user.mood, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showMoodPicker(BuildContext context) {
    final moods = ['Great', 'Good', 'Okay', 'Low', 'Bad'];
    final emojis = ['😄', '🙂', '😐', '😔', '😢'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.voidPurple,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
            border: Border.all(color: AppTheme.glassBorders),
          ),
          padding: const EdgeInsets.all(AppTheme.space5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppTheme.space4),
              const Text('How are you feeling?',
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: AppTheme.space4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(moods.length, (i) {
                  return GestureDetector(
                    onTap: () {
                      _logMood(moods[i]);
                      Navigator.pop(ctx);
                    },
                    child: Column(
                      children: [
                        Text(emojis[i], style: const TextStyle(fontSize: 36)),
                        const SizedBox(height: 4),
                        Text(moods[i], style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppTheme.space4),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTipsCard() {
    final tips = [
      '🧊 Drink a glass of water when you wake up',
      '🚶 A 10-minute walk can boost your mood for hours',
      '😴 Try to get 7-8 hours of sleep tonight',
      '🧘 Take 3 deep breaths when feeling stressed',
      '🥗 Add one extra vegetable to your next meal',
      '💪 Every step counts, even the small ones',
      '🌟 You\'re doing better than you think',
    ];
    final tip = tips[DateTime.now().day % tips.length];

    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.space4),
      tint: AppTheme.warmGold,
      opacity: 0.1,
      child: Row(
        children: [
          const Icon(Icons.lightbulb, color: AppTheme.warmGold, size: 24),
          const SizedBox(width: AppTheme.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Daily Tip',
                    style: TextStyle(color: AppTheme.warmGold, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(tip, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _calculateTotalProgress() {
    double waterScore = (_user.waterCups / 8).clamp(0.0, 1.0) * 25;
    double sleepScore = (_user.sleepHours / 8).clamp(0.0, 1.0) * 25;
    double stepScore = (_user.steps / 10000).clamp(0.0, 1.0) * 25;
    double moodScore = _getMoodScore();
    return (waterScore + sleepScore + stepScore + moodScore).toInt().clamp(0, 100);
  }

  double _getMoodScore() {
    switch (_user.mood.toLowerCase()) {
      case 'great': return 25;
      case 'good': return 20;
      case 'okay': return 15;
      case 'low': return 8;
      case 'bad': return 5;
      default: return 15;
    }
  }
}
