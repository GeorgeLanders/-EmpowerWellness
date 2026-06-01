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

  @override
  Widget build(BuildContext context) {
    final int totalProgress = _calculateTotalProgress();
    final WorldState currentState = DioramaController.calculateState(totalProgress);
    final String worldImage = DioramaController.getWorldImageAsset(currentState);

    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: Image.asset(
                  worldImage,
                  width: MediaQuery.of(context).size.width * 0.8,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.space5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: AppTheme.space6),
                    _buildWorldStatus(),
                    const SizedBox(height: AppTheme.space6),
                    _buildDailyStats(),
                    const SizedBox(height: AppTheme.space6),
                    _buildQuickActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${_user.name}!',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              'Your world is evolving...',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const CircleAvatar(
          radius: 24,
          backgroundColor: AppTheme.primaryPurple,
          child: Icon(Icons.person, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildWorldStatus() {
    final int progress = _calculateTotalProgress();
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.space4),
      tint: AppTheme.primaryPurple,
      opacity: 0.2,
      radius: AppTheme.radiusXl,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('World Level', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
              Text('$progress%', style: const TextStyle(color: AppTheme.neonCyan, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: AppTheme.space2),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            color: AppTheme.neonCyan,
            minHeight: 6,
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyStats() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: AppTheme.space4,
      crossAxisSpacing: AppTheme.space4,
      children: [
        _statCard('Water', '${_user.waterCups}/8', Icons.water_drop, AppTheme.neonCyan),
        _statCard('Steps', '${_user.steps}k', Icons.directions_walk, AppTheme.warmGold),
        _statCard('Sleep', '${_user.sleepHours}h', Icons.nightlight_round, AppTheme.primaryPurple),
        _statCard('Mood', '😊', Icons.emoji_emotions, AppTheme.hotCoral),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(AppTheme.space4),
      tint: color,
      opacity: 0.1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: AppTheme.space2),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(AppTheme.space4),
            tint: AppTheme.hotCoral,
            child: const Column(
              children: [
                Icon(Icons.psychology, color: AppTheme.hotCoral),
                SizedBox(height: 8),
                Text('Coach', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppTheme.space4),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(AppTheme.space4),
            tint: AppTheme.neonCyan,
            child: const Column(
              children: [
                Icon(Icons.fitness_center, color: AppTheme.neonCyan),
                SizedBox(height: 8),
                Text('Move', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  int _calculateTotalProgress() {
    double waterScore = (_user.waterCups / 8) * 25;
    double sleepScore = (_user.sleepHours / 8) * 25;
    double stepScore = (_user.steps / 10000) * 25;
    double moodScore = 25;
    return (waterScore + sleepScore + stepScore + moodScore).toInt().clamp(0, 100);
  }
}
