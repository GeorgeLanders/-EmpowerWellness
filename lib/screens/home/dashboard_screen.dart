import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/animated_background.dart';
import '../../widgets/app_nav_shell.dart';
import '../../services/diorama_controller.dart';
import '../../services/storage_service.dart';
import '../../models/user_data.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  final _storage = StorageService();
  late UserData _user;
  late AnimationController _floatController;
  late AnimationController _shimmerController;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _user = _storage.loadUserData();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _shimmerController.dispose();
    super.dispose();
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
          child: RefreshIndicator(
            onRefresh: () async => _reload(),
            color: AppTheme.primaryPurple,
            backgroundColor: AppTheme.voidPurple,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              padding: const EdgeInsets.all(AppTheme.space5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppTheme.space5),
                  _buildDioramaHero(currentState, totalProgress),
                  const SizedBox(height: AppTheme.space5),
                  _buildStatRings(),
                  const SizedBox(height: AppTheme.space5),
                  _buildQuickLog(),
                  const SizedBox(height: AppTheme.space5),
                  _buildDailyGoals(),
                  const SizedBox(height: AppTheme.space5),
                  _buildTipCard(),
                  const SizedBox(height: AppTheme.space6),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── HEADER ──────────────────────────────────────
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
      children: [
        // Profile button
        GestureDetector(
          onTap: () => navigateToProfile(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.glassWhite,
              border: Border.all(color: AppTheme.glassBorders),
            ),
            child: const Icon(Icons.person_outline, color: AppTheme.textSecondary, size: 20),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$greeting,',
                style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              Text(
                _user.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, _) {
                  return ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        AppTheme.roseGold,
                        AppTheme.warmGold,
                        AppTheme.roseGold,
                      ],
                      stops: [
                        (_shimmerController.value - 0.3).clamp(0.0, 1.0),
                        _shimmerController.value,
                        (_shimmerController.value + 0.3).clamp(0.0, 1.0),
                      ],
                    ).createShader(bounds),
                    child: Text(
                      _getMotivationalLine(),
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                        height: 1.3,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: AppTheme.space3),
        GestureDetector(
          onTap: () => _reload(),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.purpleCoral,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.4),
                  blurRadius: 15,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Text(
                _user.name.isNotEmpty ? _user.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppTheme.space2),
        // Settings button
        GestureDetector(
          onTap: () => navigateToSettings(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.glassWhite,
              border: Border.all(color: AppTheme.glassBorders),
            ),
            child: const Icon(Icons.settings_outlined, color: AppTheme.textSecondary, size: 20),
          ),
        ),
      ],
    );
  }

  String _getMotivationalLine() {
    final progress = _calculateTotalProgress();
    if (progress < 20) return '🌱 Every empire starts with a single seed';
    if (progress < 40) return '🌿 Your sprout is growing — keep going!';
    if (progress < 60) return '🌳 Strong roots, strong you. Well done!';
    if (progress < 80) return '🌸 Your garden is blooming beautifully';
    return '👑 Your empire is magnificent! Unstoppable!';
  }

  // ─── DIORAMA HERO ───────────────────────────────
  Widget _buildDioramaHero(WorldState state, int progress) {
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.space5),
      tint: _getWorldColor(state),
      opacity: 0.08,
      glowing: true,
      glowColor: _getWorldColor(state),
      glowIntensity: 0.12,
      child: Column(
        children: [
          // Floating diorama
          AnimatedBuilder(
            animation: _floatAnim,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnim.value),
                child: child,
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow behind emoji
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        _getWorldColor(state).withValues(alpha: 0.3),
                        _getWorldColor(state).withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
                // Emoji
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        _getWorldColor(state).withValues(alpha: 0.2),
                        AppTheme.deepSpace.withValues(alpha: 0.5),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: _getWorldColor(state).withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getWorldEmoji(state),
                      style: const TextStyle(fontSize: 52),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.space4),
          // World name
          Text(
            _getWorldTitle(state),
            style: TextStyle(
              color: _getWorldColor(state),
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getWorldDescription(state),
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.3),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.space4),
          // Progress bar
          _buildProgressTrack(progress, state),
          const SizedBox(height: AppTheme.space4),
          // View Progress button
          GestureDetector(
            onTap: () => navigateToProgress(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                color: AppTheme.glassWhite,
                border: Border.all(color: _getWorldColor(state).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bar_chart, color: AppTheme.textSecondary, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'View Full Progress',
                    style: TextStyle(
                      color: _getWorldColor(state),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTrack(int progress, WorldState currentState) {
    final stages = [
      {'emoji': '🌱', 'threshold': 0},
      {'emoji': '🌿', 'threshold': 20},
      {'emoji': '🌳', 'threshold': 40},
      {'emoji': '🌸', 'threshold': 60},
      {'emoji': '🏰', 'threshold': 80},
    ];

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          child: LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            valueColor: AlwaysStoppedAnimation(_getWorldColor(currentState)),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: AppTheme.space2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: stages.map((s) {
            final unlocked = progress >= (s['threshold'] as int);
            return AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: unlocked ? 1.0 : 0.25,
              child: Text(
                s['emoji'] as String,
                style: const TextStyle(fontSize: 18),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getWorldColor(WorldState state) {
    switch (state) {
      case WorldState.seed: return AppTheme.softLavender;
      case WorldState.sprout: return AppTheme.mintGreen;
      case WorldState.tree: return AppTheme.neonCyan;
      case WorldState.garden: return AppTheme.roseGold;
      case WorldState.empire: return AppTheme.warmGold;
    }
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
      case WorldState.seed: return 'Your journey begins. Small steps create mighty empires.';
      case WorldState.sprout: return 'Growth is happening! You\'re building momentum.';
      case WorldState.tree: return 'Strong roots, strong you. Keep going!';
      case WorldState.garden: return 'A thriving ecosystem of healthy habits.';
      case WorldState.empire: return 'You\'ve built something incredible!';
    }
  }

  // ─── STAT RINGS ──────────────────────────────────
  Widget _buildStatRings() {
    return Row(
      children: [
        Expanded(child: _buildStatRing('Water', _user.waterCups, 8, Icons.water_drop, AppTheme.neonCyan, 'cups')),
        const SizedBox(width: AppTheme.space3),
        Expanded(child: _buildStatRing('Sleep', _user.sleepHours, 8, Icons.bedtime_rounded, AppTheme.primaryPurple, 'hrs')),
        const SizedBox(width: AppTheme.space3),
        Expanded(child: _buildStatRing('Mood', _getMoodValue(), 5, Icons.favorite_rounded, AppTheme.hotCoral, '')),
      ],
    );
  }

  int _getMoodValue() {
    switch (_user.mood.toLowerCase()) {
      case 'great': return 5;
      case 'good': return 4;
      case 'okay': return 3;
      case 'low': return 2;
      case 'bad': return 1;
      default: return 3;
    }
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

  Widget _buildStatRing(String label, int value, int max, IconData icon, Color color, String unit) {
    final pct = (value / max).clamp(0.0, 1.0);
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.space3),
      tint: color,
      opacity: 0.06,
      glowing: pct >= 1.0,
      glowColor: color,
      child: Column(
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    value: pct,
                    strokeWidth: 4,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation(color),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: color, size: 18),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.space1),
          Text(
            unit.isNotEmpty ? '$value $unit' : _getMoodEmoji(_user.mood),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: unit.isNotEmpty ? 12 : 20,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ─── QUICK LOG ───────────────────────────────────
  Widget _buildQuickLog() {
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.space4),
      tint: AppTheme.roseGold,
      opacity: 0.06,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Log',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: AppTheme.space3),
          Row(
            children: [
              Expanded(
                child: _buildLogButton(
                  icon: Icons.water_drop,
                  label: 'Water',
                  value: '${_user.waterCups}/8',
                  color: AppTheme.neonCyan,
                  onTap: _logWater,
                  glow: _user.waterCups >= 8,
                ),
              ),
              const SizedBox(width: AppTheme.space3),
              Expanded(
                child: GestureDetector(
                  onTap: () => _showMoodPicker(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.roseGold.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: AppTheme.roseGold.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        Text(_getMoodEmoji(_user.mood), style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 4),
                        Text('Mood', style: TextStyle(color: AppTheme.roseGold, fontSize: 12, fontWeight: FontWeight.w600)),
                        Text(_user.mood, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.space3),
              Expanded(
                child: _buildLogButton(
                  icon: Icons.directions_walk_rounded,
                  label: 'Steps',
                  value: '${(_user.steps / 1000).toStringAsFixed(1)}k',
                  color: AppTheme.warmGold,
                  onTap: () {
                    _user.steps += 500;
                    if (_user.steps > 20000) _user.steps = 0;
                    _storage.saveUserData(_user);
                    _reload();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogButton({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required VoidCallback onTap,
    bool glow = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: color.withValues(alpha: glow ? 0.6 : 0.3)),
          boxShadow: glow
              ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 12, spreadRadius: 1)]
              : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  void _showMoodPicker(BuildContext context) {
    final moods = ['Great', 'Good', 'Okay', 'Low', 'Bad'];
    final emojis = ['😄', '🙂', '😐', '😔', '😢'];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.voidPurple, AppTheme.deepSpace],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
            border: Border.all(color: AppTheme.glassBorders),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.space6),
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
                  const SizedBox(height: AppTheme.space5),
                  const Text('How are you feeling right now?',
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppTheme.space2),
                  const Text('There\'s no wrong answer.',
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                  const SizedBox(height: AppTheme.space5),
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
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.glassWhite,
                                border: Border.all(color: AppTheme.glassBorders),
                              ),
                              child: Center(child: Text(emojis[i], style: const TextStyle(fontSize: 30))),
                            ),
                            const SizedBox(height: AppTheme.space2),
                            Text(moods[i], style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          ],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppTheme.space4),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── DAILY GOALS ───────────────────────────────
  Widget _buildDailyGoals() {
    final goals = [
      {'label': 'Drink 8 cups', 'done': _user.waterCups >= 8, 'current': _user.waterCups, 'target': 8, 'icon': Icons.water_drop, 'color': AppTheme.neonCyan},
      {'label': 'Sleep 8 hours', 'done': _user.sleepHours >= 8, 'current': _user.sleepHours, 'target': 8, 'icon': Icons.bedtime_rounded, 'color': AppTheme.primaryPurple},
      {'label': 'Move your body', 'done': _user.steps >= 5000, 'current': _user.steps, 'target': 5000, 'icon': Icons.directions_walk_rounded, 'color': AppTheme.warmGold},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Daily Goals',
            style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: AppTheme.space3),
        ...goals.map((g) {
          final pct = ((g['current'] as int) / (g['target'] as int)).clamp(0.0, 1.0);
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.space2),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4, vertical: AppTheme.space3),
              tint: g['color'] as Color,
              opacity: 0.06,
              child: Row(
                children: [
                  Icon(g['icon'] as IconData, color: (g['done'] as bool) ? (g['color'] as Color) : AppTheme.textMuted, size: 20),
                  const SizedBox(width: AppTheme.space3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(g['label'] as String,
                            style: TextStyle(
                              color: (g['done'] as bool) ? AppTheme.textPrimary : AppTheme.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            )),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                          child: LinearProgressIndicator(
                            value: pct,
                            backgroundColor: Colors.white.withValues(alpha: 0.06),
                            valueColor: AlwaysStoppedAnimation((g['color'] as Color).withValues(alpha: (g['done'] as bool) ? 0.8 : 0.4)),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppTheme.space3),
                  if (g['done'] as bool)
                    const Icon(Icons.check_circle, color: AppTheme.mintGreen, size: 20)
                  else
                    Text('${(pct * 100).toInt()}%',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ─── TIP CARD ────────────────────────────────────
  Widget _buildTipCard() {
    final tips = [
      '🧊 Drink a glass of water first thing in the morning — your body craves hydration after sleep.',
      '🚶 A 10-minute walk can boost your mood for up to 2 hours. Step outside today!',
      '😴 Try to get 7-8 hours of sleep tonight. Your body heals and grows during rest.',
      '🧘 When stressed, try the 4-7-8 breath: inhale 4s, hold 7s, exhale 8s. Repeat 3x.',
      '🥗 Add one extra vegetable to your next meal. Small changes = big results over time.',
      '💪 Every step counts. You don\'t need to be perfect — just consistent.',
      '🌟 You\'re doing better than you think. Progress isn\'t always visible right away.',
      '☀️ Sunlight in the morning helps reset your circadian rhythm. Open those curtains!',
      '🍎 Protein at breakfast keeps you full longer. Try eggs, yogurt, or nuts.',
      '🤝 Tell someone you trust how you feel. Connection is a powerful form of medicine.',
    ];
    final tipIndex = DateTime.now().day % tips.length;
    final tip = tips[tipIndex];

    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.space4),
      tint: AppTheme.warmGold,
      opacity: 0.06,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.warmGold.withValues(alpha: 0.15),
              border: Border.all(color: AppTheme.warmGold.withValues(alpha: 0.3)),
            ),
            child: const Center(
              child: Text('💡', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: AppTheme.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Wellness Tip',
                    style: TextStyle(color: AppTheme.warmGold, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 3),
                Text(tip, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── HELPERS ─────────────────────────────────────
  int _calculateTotalProgress() {
    double waterScore = (_user.waterCups / 8).clamp(0.0, 1.0) * 30;
    double sleepScore = (_user.sleepHours / 8).clamp(0.0, 1.0) * 25;
    double stepScore = (_user.steps / 8000).clamp(0.0, 1.0) * 25;
    double moodScore = (_getMoodValue() / 5.0) * 20;
    return (waterScore + sleepScore + stepScore + moodScore).toInt().clamp(0, 100);
  }
}
