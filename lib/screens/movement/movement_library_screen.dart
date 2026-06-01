import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/animated_background.dart';
import 'video_player_screen.dart';

class MovementLibraryScreen extends StatefulWidget {
  const MovementLibraryScreen({super.key});

  @override
  State<MovementLibraryScreen> createState() => _MovementLibraryScreenState();
}

class _MovementLibraryScreenState extends State<MovementLibraryScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'Seated', 'Standing', 'Stretch', 'Strength', 'Walk'];

  final List<MovementItem> _movements = [
    MovementItem('Seated Leg Lifts', 'Seated', '3 min', 'assets/videos/seated_leg_lifts.mp4', 'Legs', 'Gentle leg strengthening from a chair. Great for beginners.'),
    MovementItem('Torso Twists', 'Seated', '2 min', 'assets/videos/torso_twist.mp4', 'Core', 'Gentle spinal rotation to improve mobility and reduce stiffness.'),
    MovementItem('Seated Marching', 'Seated', '3 min', 'assets/videos/seated_march.mp4', 'Cardio', 'March in place while seated. Gets your heart rate up gently.'),
    MovementItem('Arm Circles', 'Standing', '2 min', 'assets/videos/arm_circles.mp4', 'Upper Body', 'Warm up your shoulders and improve range of motion.'),
    MovementItem('Heel Touches', 'Standing', '3 min', 'assets/videos/heel_touches.mp4', 'Balance', 'Improve balance and coordination with gentle heel-to-toe touches.'),
    MovementItem('Wall Stand', 'Standing', '5 min', 'assets/videos/wall_stand.mp4', 'Legs', 'Stand against a wall to build leg strength and endurance.'),
    MovementItem('Neck Release', 'Seated', '2 min', 'assets/videos/neck_release.mp4', 'Upper Body', 'Release tension in your neck and upper shoulders.'),
    MovementItem('Cat-Cow Stretch', 'Stretch', '3 min', 'assets/videos/cat_cow.mp4', 'Back', 'Classic yoga flow to improve spinal flexibility.'),
    MovementItem('Wrist Stretch', 'Stretch', '1 min', 'assets/videos/wrist_stretch.mp4', 'Arms', 'Prevent wrist pain with gentle stretching.'),
    MovementItem('Butterfly Stretch', 'Stretch', '3 min', 'assets/videos/butterfly.mp4', 'Hips', 'Open your hips and inner thighs with this gentle stretch.'),
    MovementItem('Wall Push-ups', 'Strength', '3 min', 'assets/videos/wall_pushups.mp4', 'Upper Body', 'Build upper body strength without getting on the floor.'),
    MovementItem('Chair Squats', 'Strength', '5 min', 'assets/videos/chair_squats.mp4', 'Legs', 'Sit and stand from a chair to build leg and core strength.'),
    MovementItem('Indoor Walk', 'Walk', '10 min', 'assets/videos/indoor_walk.mp4', 'Cardio', 'Walk in place or around your home. Every step counts!'),
    MovementItem('Nature Walk', 'Walk', '15 min', 'assets/videos/nature_walk.mp4', 'Cardio', 'Step outside and enjoy a refreshing walk in nature.'),
  ];

  List<MovementItem> get _filteredMovements {
    if (_selectedCategory == 'All') return _movements;
    return _movements.where((m) => m.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Movement Library',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          centerTitle: true,
        ),
        body: Column(
          children: [
            _buildCategorySelector(),
            _buildLibraryHeader(),
            Expanded(
              child: _filteredMovements.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      padding: const EdgeInsets.all(AppTheme.space5),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: AppTheme.space4,
                        crossAxisSpacing: AppTheme.space4,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: _filteredMovements.length,
                      itemBuilder: (context, index) => _buildMovementCard(_filteredMovements[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: AppTheme.space2, top: 8, bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.neonCyan.withValues(alpha: 0.2) : AppTheme.glassWhite,
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                border: Border.all(
                  color: isSelected ? AppTheme.neonCyan : AppTheme.glassBorders,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(color: AppTheme.neonCyan.withValues(alpha: 0.3), blurRadius: 10)]
                    : [],
              ),
              child: Center(
                child: Row(
                  children: [
                    Text(_getCategoryIcon(cat), style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getCategoryIcon(String cat) {
    switch (cat) {
      case 'All': return '🏋️';
      case 'Seated': return '🪑';
      case 'Standing': return '🧍';
      case 'Stretch': return '🤸';
      case 'Strength': return '💪';
      case 'Walk': return '🚶';
      default: return '🎯';
    }
  }

  Widget _buildLibraryHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5, vertical: AppTheme.space3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_filteredMovements.length} exercises',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          Text(
            '${_movements.length} total',
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🤷', style: TextStyle(fontSize: 48)),
          const SizedBox(height: AppTheme.space4),
          Text('No exercises in "$_selectedCategory"',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
          const SizedBox(height: AppTheme.space2),
          const Text('Try a different category',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildMovementCard(MovementItem item) {
    final Color categoryColor = _getCategoryColor(item.category);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VideoPlayerScreen(movementItem: item)),
        );
      },
      child: GlassCard(
        padding: const EdgeInsets.all(AppTheme.space3),
        tint: categoryColor,
        opacity: 0.08,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon/thumbnail area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppTheme.glassBorders.withValues(alpha: 0.5)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_getExerciseIcon(item.category), style: const TextStyle(fontSize: 36)),
                        const SizedBox(height: 4),
                        Text(
                          item.targetArea,
                          style: TextStyle(
                            color: categoryColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.deepSpace.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_arrow, color: categoryColor, size: 12),
                            const SizedBox(width: 2),
                            Text(item.duration,
                                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.space2),
            Text(
              item.title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              item.description,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _getExerciseIcon(String category) {
    switch (category) {
      case 'Seated': return '🪑';
      case 'Standing': return '🧍';
      case 'Stretch': return '🤸';
      case 'Strength': return '💪';
      case 'Walk': return '🚶';
      default: return '🏋️';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Seated': return AppTheme.neonCyan;
      case 'Standing': return AppTheme.warmGold;
      case 'Stretch': return AppTheme.roseGold;
      case 'Strength': return AppTheme.hotCoral;
      case 'Walk': return AppTheme.primaryPurple;
      default: return AppTheme.neonCyan;
    }
  }
}

class MovementItem {
  final String title;
  final String category;
  final String duration;
  final String assetPath;
  final String targetArea;
  final String description;

  MovementItem(this.title, this.category, this.duration, this.assetPath, this.targetArea, this.description);
}
