import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/animated_background.dart';
import '../../services/storage_service.dart';
import '../../services/diorama_controller.dart';
import '../../models/user_data.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final StorageService _storage = StorageService();
  late UserData _user;
  late AnimationController _shimmerController;

  // Stats
  int _currentStreak = 0;
  int _totalMovements = 0;
  int _daysActive = 0;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _loadData();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _loadData() {
    _user = _storage.loadUserData();
    // Derive stats from available UserData fields
    _totalMovements = _user.steps;
    // Derive streak from steps: if they walked >0 steps consecutively, simulate a streak
    // Using a heuristic based on steps taken relative to a daily goal of 8000
    _currentStreak = (_user.steps / 8000).floor().clamp(0, 7);
    _daysActive = (_user.waterCups > 0 || _user.steps > 0) ? (_user.waterCups + _user.sleepHours).clamp(1, 365) : 0;
  }

  int _calculateTotalProgress() {
    double waterScore = (_user.waterCups / 8).clamp(0.0, 1.0) * 30;
    double sleepScore = (_user.sleepHours / 8).clamp(0.0, 1.0) * 25;
    double stepScore = (_user.steps / 8000).clamp(0.0, 1.0) * 25;
    double moodScore = (_moodToValue() / 5.0) * 20;
    return (waterScore + sleepScore + stepScore + moodScore).toInt().clamp(0, 100);
  }

  int _moodToValue() {
    switch (_user.mood.toLowerCase()) {
      case 'amazing':
        return 5;
      case 'great':
        return 4;
      case 'good':
        return 3;
      case 'okay':
        return 2;
      case 'low':
        return 1;
      default:
        return 3;
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'F'; // Default: Friend
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  bool _isAchievementUnlocked(String achievementId) {
    switch (achievementId) {
      case 'first_step':
        return _totalMovements >= 1;
      case 'week_warrior':
        return _currentStreak >= 7;
      case 'century_club':
        return _totalMovements >= 100;
      case 'world_builder':
        return _calculateTotalProgress() >= 80;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalProgress = _calculateTotalProgress();
    final WorldState currentState = DioramaController.calculateState(totalProgress);

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppTheme.space2),

                // ── Hero Section ──
                _buildHeroSection(),
                const SizedBox(height: AppTheme.space6),

                // ── Diorama Card ──
                _buildDioramaCard(currentState, totalProgress),
                const SizedBox(height: AppTheme.space6),

                // ── Stats Row ──
                _buildStatsRow(),
                const SizedBox(height: AppTheme.space6),

                // ── Achievements ──
                _buildAchievementsSection(),
                const SizedBox(height: AppTheme.space6),

                // ── About ──
                _buildAboutSection(),
                const SizedBox(height: AppTheme.space8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.space6),
      glowing: true,
      glowColor: AppTheme.neonCyan,
      glowIntensity: 0.08,
      child: Column(
        children: [
          // Avatar circle with initials
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.purpleCoral,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.3),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: Text(
                _getInitials(_user.name),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space4),
          // User name
          Text(
            _user.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppTheme.space1),
          // Tagline
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '✨',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(width: AppTheme.space1),
              const Text(
                'Your world is evolving',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(width: AppTheme.space1),
              Text(
                '✨',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDioramaCard(WorldState state, int progress) {
    final String stateName = state.name[0].toUpperCase() + state.name.substring(1);
    final String imageAsset = DioramaController.getWorldImageAsset(state);

    return GlassCard(
      radius: AppTheme.radiusXl,
      padding: const EdgeInsets.all(AppTheme.space5),
      glowing: true,
      glowColor: AppTheme.primaryPurple,
      glowIntensity: 0.1,
      child: Column(
        children: [
          // World state image
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            child: Image.asset(
              imageAsset,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback if image assets don't exist yet
                return Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    gradient: AppTheme.spaceGradient,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.landscape_rounded,
                          size: 48,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(height: AppTheme.space2),
                        Text(
                          stateName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppTheme.space4),
          // World state name
          Text(
            stateName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppTheme.space1),
          Text(
            'World Level',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: AppTheme.space4),
          // Progress bar to next level
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Progress to next level',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                   Text(
                    '$progress%',
                    style: const TextStyle(
                      color: AppTheme.neonCyan,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.space2),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                child: Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: (progress / 100).clamp(0.0, 1.0),
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: AppTheme.purpleCoral,
                          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryPurple.withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        // Current Streak
        Expanded(
          child: _buildStatCard(
            icon: '🔥',
            label: 'Current Streak',
            value: '$_currentStreak days',
          ),
        ),
        const SizedBox(width: AppTheme.space3),
        // Total Movements
        Expanded(
          child: _buildStatCard(
            icon: '🏃',
            label: 'Total Movements',
            value: '$_totalMovements',
          ),
        ),
        const SizedBox(width: AppTheme.space3),
        // Days Active
        Expanded(
          child: _buildStatCard(
            icon: '📅',
            label: 'Days Active',
            value: '$_daysActive',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String label,
    required String value,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.space4),
      child: Column(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(height: AppTheme.space2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppTheme.space1),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    final achievements = [
      _AchievementData(
        id: 'first_step',
        title: 'First Step',
        description: 'Complete 1 movement',
        icon: Icons.directions_walk,
        gradient: AppTheme.purpleCoral,
      ),
      _AchievementData(
        id: 'week_warrior',
        title: 'Week Warrior',
        description: '7 day streak',
        icon: Icons.local_fire_department_rounded,
        gradient: LinearGradient(
          colors: [AppTheme.hotCoral, AppTheme.emberOrange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      _AchievementData(
        id: 'century_club',
        title: 'Century Club',
        description: '100 movements',
        icon: Icons.military_tech_rounded,
        gradient: AppTheme.cyanGold,
      ),
      _AchievementData(
        id: 'world_builder',
        title: 'World Builder',
        description: 'Reach Empire',
        icon: Icons.castle_rounded,
        gradient: LinearGradient(
          colors: [AppTheme.softLavender, AppTheme.neonCyan],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppTheme.space1, bottom: AppTheme.space4),
          child: Row(
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: AppTheme.warmGold,
                size: 22,
              ),
              const SizedBox(width: AppTheme.space2),
              const Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppTheme.space3,
            mainAxisSpacing: AppTheme.space3,
            childAspectRatio: 1.1,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            final unlocked = _isAchievementUnlocked(achievement.id);
            return _buildAchievementBadge(achievement, unlocked);
          },
        ),
      ],
    );
  }

  Widget _buildAchievementBadge(_AchievementData achievement, bool unlocked) {
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.space4),
      opacity: unlocked ? 0.12 : 0.05,
      borderColor: unlocked
          ? AppTheme.warmGold.withValues(alpha: 0.4)
          : AppTheme.textMuted.withValues(alpha: 0.15),
      glowing: unlocked,
      glowColor: AppTheme.warmGold,
      glowIntensity: 0.08,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Badge icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: unlocked ? achievement.gradient : null,
              color: unlocked ? null : Colors.white.withValues(alpha: 0.05),
            ),
            child: Center(
              child: unlocked
                  ? const Icon(
                      Icons.stars_rounded,
                      color: Colors.white,
                      size: 26,
                    )
                  : Icon(
                      Icons.lock_rounded,
                      color: AppTheme.textMuted,
                      size: 22,
                    ),
            ),
          ),
          const SizedBox(height: AppTheme.space3),
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: unlocked ? Colors.white : AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: AppTheme.space1),
          Text(
            achievement.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: unlocked ? AppTheme.textSecondary : AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return GlassCard(
      child: Column(
        children: [
          const Divider(color: AppTheme.glassBorders, height: 1),
          const SizedBox(height: AppTheme.space4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'EmpowerWellness',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: AppTheme.space4),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppTheme.textMuted,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppTheme.space4),
              const Text(
                'v1.0.0',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Made with ',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textMuted,
                ),
              ),
              const Text(
                '❤️',
                style: TextStyle(fontSize: 13),
              ),
              const Text(
                ' love',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space4),
        ],
      ),
    );
  }
}

class _AchievementData {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final LinearGradient gradient;

  const _AchievementData({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
  });
}

