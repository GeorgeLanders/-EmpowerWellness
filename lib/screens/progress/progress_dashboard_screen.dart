import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/animated_background.dart';

class ProgressDashboardScreen extends StatefulWidget {
  const ProgressDashboardScreen({super.key});

  @override
  State<ProgressDashboardScreen> createState() =>
      _ProgressDashboardScreenState();
}

class _ProgressDashboardScreenState extends State<ProgressDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _entryAnim;

  // Mock progress data - in a real app this would come from persistent storage
  final List<int> _last7DaysMovement = [3, 5, 2, 7, 4, 6, 3];
  final List<String> _last7DaysMood = [
    'Good',
    'Great',
    'Okay',
    'Great',
    'Good',
    'Great',
    'Good'
  ];

  final int _currentStreak = 7;
  final int _movementsThisWeek = 30;
  final int _movementsThisMonth = 124;
  final int _movementsTotal = 312;
  final Set<int> _completedMilestones = {0, 1}; // First 2 completed

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _entryAnim = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Your Progress',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
          ),
          centerTitle: true,
        ),
        body: FadeTransition(
          opacity: _entryAnim,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppTheme.space5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStreakHero(),
                const SizedBox(height: AppTheme.space5),
                _buildWeeklyCalendar(),
                const SizedBox(height: AppTheme.space5),
                _buildMovementStats(),
                const SizedBox(height: AppTheme.space5),
                _buildActivityChart(),
                const SizedBox(height: AppTheme.space5),
                _buildMilestones(),
                const SizedBox(height: AppTheme.space5),
                _buildMoodTrends(),
                const SizedBox(height: AppTheme.space6),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── STREAK HERO ─────────────────────────────────────
  Widget _buildStreakHero() {
    final bool hasStreak = _currentStreak > 0;
    final String motivationalMessage = hasStreak
        ? _getStreakMessage(_currentStreak)
        : 'Start your streak today!';
    final String streakLabel = hasStreak ? 'day streak' : '';

    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.space6),
      tint: AppTheme.warmGold,
      opacity: 0.06,
      glowing: hasStreak,
      glowColor: AppTheme.warmGold,
      glowIntensity: 0.10,
      child: Column(
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            color: AppTheme.warmGold,
            size: 48,
          ),
          const SizedBox(height: AppTheme.space3),
          Text(
            hasStreak ? '$_currentStreak' : '🔥',
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: AppTheme.warmGold,
              height: 1.0,
            ),
          ),
          if (streakLabel.isNotEmpty) ...[
            const SizedBox(height: AppTheme.space1),
            Text(
              streakLabel,
              style: const TextStyle(
                fontSize: 18,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const SizedBox(height: AppTheme.space3),
          Text(
            motivationalMessage,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getStreakMessage(int streak) {
    if (streak < 3) return 'Great start! Keep the fire burning! 🔥';
    if (streak < 7) return 'Amazing momentum! You\'re building a habit.';
    if (streak < 14) return 'One week strong! Incredible dedication! 💪';
    if (streak < 30) return 'Unstoppable! Your consistency is inspiring.';
    return 'Legendary streak! You\'re a wellness champion! 👑';
  }

  // ─── WEEKLY CALENDAR ─────────────────────────────────
  Widget _buildWeeklyCalendar() {
    final now = DateTime.now();
    // Find Monday of current week
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This Week',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppTheme.space3),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final day = monday.add(Duration(days: i));
              final isToday = day.day == now.day &&
                  day.month == now.month &&
                  day.year == now.year;
              final isPast = day.isBefore(now) && !isToday;
              final isFuture = day.isAfter(now);
              final isCompleted =
                  isPast && _isDayCompleted(i); // mock logic

              return Column(
                children: [
                  Text(
                    dayNames[i],
                    style: TextStyle(
                      color: isToday
                          ? AppTheme.neonCyan
                          : AppTheme.textMuted,
                      fontSize: 11,
                      fontWeight:
                          isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDayCircle(
                    isToday: isToday,
                    isCompleted: isCompleted,
                    isFuture: isFuture,
                    dayNum: day.day,
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  bool _isDayCompleted(int dayIndex) {
    // Mock: days 0-4 of the week are completed, rest depend on today
    return dayIndex < 5;
  }

  Widget _buildDayCircle({
    required bool isToday,
    required bool isCompleted,
    required bool isFuture,
    required int dayNum,
  }) {
    if (isFuture) {
      // Empty circle for future days
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.03),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            '$dayNum',
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 12,
            ),
          ),
        ),
      );
    }

    if (isToday) {
      // Highlighted today
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.neonCyan.withValues(alpha: 0.2),
          border: Border.all(color: AppTheme.neonCyan, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.neonCyan.withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Center(
          child: Text(
            '$dayNum',
            style: const TextStyle(
              color: AppTheme.neonCyan,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    if (isCompleted) {
      // Completed day with checkmark
      return Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.warmGold.withValues(alpha: 0.2),
          border: Border.all(color: AppTheme.warmGold.withValues(alpha: 0.6), width: 1.5),
        ),
        child: const Center(
          child: Icon(Icons.check_rounded, color: AppTheme.warmGold, size: 18),
        ),
      );
    }

    // Past missed day - empty circle
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.03),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          '$dayNum',
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // ─── MOVEMENT STATS ──────────────────────────────────
  Widget _buildMovementStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'This Week',
            '$_movementsThisWeek',
            Icons.fitness_center,
            AppTheme.neonCyan,
          ),
        ),
        const SizedBox(width: AppTheme.space3),
        Expanded(
          child: _buildStatCard(
            'This Month',
            '$_movementsThisMonth',
            Icons.fitness_center,
            AppTheme.primaryPurple,
          ),
        ),
        const SizedBox(width: AppTheme.space3),
        Expanded(
          child: _buildStatCard(
            'Total',
            '$_movementsTotal',
            Icons.fitness_center,
            AppTheme.warmGold,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.space3),
      tint: color,
      opacity: 0.06,
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppTheme.space2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── ACTIVITY CHART ──────────────────────────────────
  Widget _buildActivityChart() {
    final maxMovements =
        _last7DaysMovement.reduce((a, b) => a > b ? a : b);
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Last 7 Days',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppTheme.space2),
          const Text(
            'Movements per day',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: AppTheme.space4),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children:
                  List.generate(_last7DaysMovement.length, (i) {
                final value = _last7DaysMovement[i];
                final heightPct =
                    maxMovements > 0 ? value / maxMovements : 0.0;
                final barHeight = 100.0 * heightPct;

                return Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Value label
                        Text(
                          '$value',
                          style: TextStyle(
                            color: value == maxMovements
                                ? AppTheme.neonCyan
                                : AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: value == maxMovements
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Bar
                        Container(
                          height: barHeight.clamp(4.0, 100.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppTheme.neonCyan,
                                AppTheme.primaryPurple,
                              ],
                            ),
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(AppTheme.radiusSm),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Day label
                        Text(
                          dayLabels[i],
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ─── MILESTONES ──────────────────────────────────────
  Widget _buildMilestones() {
    final milestones = [
      {'label': 'First Movement', 'emoji': '🏃'},
      {'label': 'Week Complete', 'emoji': '📅'},
      {'label': 'Month Complete', 'emoji': '🗓️'},
      {'label': '100 Movements', 'emoji': '💯'},
    ];

    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Milestones',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppTheme.space4),
          Column(
            children:
                List.generate(milestones.length, (i) {
              final isCompleted = _completedMilestones.contains(i);
              final isLast = i == milestones.length - 1;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Timeline indicator
                    Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted
                                ? AppTheme.warmGold
                                : Colors.white.withValues(alpha: 0.05),
                            border: Border.all(
                              color: isCompleted
                                  ? AppTheme.warmGold
                                  : AppTheme.textMuted,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              milestones[i]['emoji'] as String,
                              style:
                                  const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 30,
                            color: isCompleted
                                ? AppTheme.warmGold
                                    .withValues(alpha: 0.4)
                                : Colors.white.withValues(alpha: 0.08),
                          ),
                      ],
                    ),
                    const SizedBox(width: AppTheme.space3),
                    // Label
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(
                          top: 6,
                          bottom: isLast ? 0 : 16,
                        ),
                        child: Text(
                          milestones[i]['label'] as String,
                          style: TextStyle(
                            color: isCompleted
                                ? AppTheme.textPrimary
                                : AppTheme.textMuted,
                            fontSize: 14,
                            fontWeight: isCompleted
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                    // Completed check
                    if (isCompleted)
                      const Padding(
                        padding: EdgeInsets.only(top: 6),
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: AppTheme.warmGold,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ─── MOOD TRENDS ─────────────────────────────────────
  Widget _buildMoodTrends() {
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mood This Week',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: AppTheme.space2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_last7DaysMood.length, (i) {
              final mood = _last7DaysMood[i];
              final emoji = _moodToEmoji(mood);
              return Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _moodColor(mood).withValues(alpha: 0.12),
                      border: Border.all(
                        color:
                            _moodColor(mood).withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mood,
                    style: TextStyle(
                      color: _moodColor(mood),
                      fontSize: 9,
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: AppTheme.space3),
          // Average mood summary
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.space3,
              vertical: AppTheme.space2,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Row(
              children: [
                const Text('Weekly Average: ',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
                Text(
                  _moodToEmoji(_calculateAverageMood()),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 6),
                Text(
                  _calculateAverageMood(),
                  style: TextStyle(
                    color: _moodColor(_calculateAverageMood()),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _moodToEmoji(String mood) {
    switch (mood.toLowerCase()) {
      case 'great':
        return '😄';
      case 'good':
        return '🙂';
      case 'okay':
        return '😐';
      case 'low':
        return '😔';
      case 'bad':
        return '😢';
      default:
        return '🙂';
    }
  }

  Color _moodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'great':
        return AppTheme.mintGreen;
      case 'good':
        return AppTheme.neonCyan;
      case 'okay':
        return AppTheme.warmGold;
      case 'low':
        return AppTheme.hotCoral;
      case 'bad':
        return AppTheme.textMuted;
      default:
        return AppTheme.textSecondary;
    }
  }

  String _calculateAverageMood() {
    final scores = _last7DaysMood.map((m) {
      switch (m.toLowerCase()) {
        case 'great':
          return 5;
        case 'good':
          return 4;
        case 'okay':
          return 3;
        case 'low':
          return 2;
        case 'bad':
          return 1;
        default:
          return 3;
      }
    }).toList();
    final avg = scores.reduce((a, b) => a + b) / scores.length;
    if (avg >= 4.5) return 'Great';
    if (avg >= 3.5) return 'Good';
    if (avg >= 2.5) return 'Okay';
    if (avg >= 1.5) return 'Low';
    return 'Bad';
  }
}
