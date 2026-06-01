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
  final List<String> _categories = ['All', 'Seated', 'Standing', 'Stretch', 'Strength'];

  final List<MovementItem> _movements = [
    MovementItem('Seated Leg Lifts', 'Seated', '1 min', 'assets/videos/seated_leg_lifts.mp4', 'Legs'),
    MovementItem('Torso Twist', 'Seated', '2 min', 'assets/videos/torso_twist.mp4', 'Core'),
    MovementItem('Arm Circles', 'Standing', '2 min', 'assets/videos/arm_circles.mp4', 'Upper Body'),
    MovementItem('Heel Touches', 'Standing', '3 min', 'assets/videos/heel_touches.mp4', 'Legs'),
    MovementItem('Neck Release', 'Seated', '1 min', 'assets/videos/neck_release.mp4', 'Upper Body'),
    MovementItem('Cat-Cow', 'Stretch', '3 min', 'assets/videos/cat_cow.mp4', 'Back'),
    MovementItem('Wrist Stretch', 'Stretch', '1 min', 'assets/videos/wrist_stretch.mp4', 'Arms'),
    MovementItem('Wall Push-ups', 'Strength', '3 min', 'assets/videos/wall_pushups.mp4', 'Upper Body'),
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
          title: const Text('Movement Library', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // ── Category Selector (Pill-shaped chips) ──
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _categories.map((cat) => _buildCategoryChip(cat)).toList(),
              ),
            ),
            
            // ── Video Grid ──
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(AppTheme.space5),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppTheme.space4,
                  crossAxisSpacing: AppTheme.space4,
                  childAspectRatio: 0.8,
                ),
                itemCount: _filteredMovements.length,
                itemBuilder: (context, index) {
                  return _buildMovementCard(_filteredMovements[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.neonCyan : AppTheme.glassWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
          border: Border.all(
            color: isSelected ? AppTheme.neonCyan : AppTheme.glassBorders,
            width: 1,
          ),
          boxShadow: isSelected 
            ? [BoxShadow(color: AppTheme.neonCyan.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 2))] 
            : [],
        ),
        child: Center(
          child: Text(
            category,
            style: TextStyle(
              color: isSelected ? AppTheme.deepSpace : AppTheme.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMovementCard(MovementItem item) {
    return GlassCard(
      radius: AppTheme.radiusLg,
      tint: AppTheme.neonCyan,
      opacity: 0.1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Video Preview Placeholder
          Expanded(
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerScreen(movementItem: item),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.voidPurple,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: AppTheme.glassBorders),
                ),
                child: const Center(
                  child: Icon(Icons.play_circle_fill, color: AppTheme.neonCyan, size: 40),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space3),
          Text(
            item.title,
            style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 14),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.duration,
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
              ),
              Text(
                item.targetArea,
                style: TextStyle(
                  color: AppTheme.neonCyan, 
                  fontSize: 11, 
                  fontWeight: FontWeight.w600,
                  backgroundColor: AppTheme.neonCyan.withValues(alpha: 0.1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MovementItem {
  final String title;
  final String category;
  final String duration;
  final String assetPath;
  final String targetArea;

  MovementItem(this.title, this.category, this.duration, this.assetPath, this.targetArea);
}
