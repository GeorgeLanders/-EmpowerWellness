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

class _MovementLibraryScreenState extends State<MovementLibraryScreen>
    with TickerProviderStateMixin {
  String _selectedCategory = 'All';
  late AnimationController _entryController;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'All', 'icon': '🏋️', 'color': AppTheme.warmGold},
    {'label': 'Seated', 'icon': '🪑', 'color': AppTheme.neonCyan},
    {'label': 'Standing', 'icon': '🧍', 'color': AppTheme.plasmaViolet},
    {'label': 'Stretch', 'icon': '🤸', 'color': AppTheme.roseGold},
    {'label': 'Strength', 'icon': '💪', 'color': AppTheme.hotCoral},
    {'label': 'Walk', 'icon': '🚶', 'color': AppTheme.mintGreen},
  ];

  final List<MovementItem> _movements = [
    MovementItem('Seated Leg Lifts', 'Seated', '3 min', 'assets/videos/seated-leg-lifts.mp4', 'Legs', 'Gentle leg strengthening from a chair. No standing required. Perfect for beginners or those with limited mobility.'),
    MovementItem('Torso Twists', 'Seated', '2 min', 'assets/videos/torso-twists.mp4', 'Core', 'Gentle spinal rotation to improve flexibility and reduce back stiffness. Great for desk workers.'),
    MovementItem('Seated Marching', 'Seated', '3 min', 'assets/videos/seated-marching.mp4', 'Cardio', 'March in place while seated to get your heart pumping. Fun and accessible.'),
    MovementItem('Neck Release', 'Seated', '2 min', 'assets/videos/neck-release.mp4', 'Upper Body', 'Release built-up tension in your neck and upper shoulders. Do this one daily.'),
    MovementItem('Arm Circles', 'Standing', '2 min', 'assets/videos/arm-circles.mp4', 'Upper Body', 'Warm up your shoulders and improve range of motion. Great before any upper body work.'),
    MovementItem('Heel Touches', 'Standing', '3 min', 'assets/videos/heel-touches.mp4', 'Balance', 'Improve balance and coordination with gentle heel-to-toe touches. Hold a chair for support.'),
    MovementItem('Wall Stand', 'Standing', '5 min', 'assets/videos/wall-stand.mp4', 'Legs', 'Build leg strength and endurance by standing against a wall. Feel the burn safely.'),
    MovementItem('Cat-Cow Stretch', 'Stretch', '3 min', 'assets/videos/cat-cow.mp4', 'Back', 'Classic yoga flow to improve spinal flexibility. Move slowly and breathe deeply.'),
    MovementItem('Wrist Stretch', 'Stretch', '1 min', 'assets/videos/wrist-stretch.mp4', 'Arms', 'Prevent wrist pain and carpal tunnel with gentle stretching. Essential for phone users.'),
    MovementItem('Butterfly Stretch', 'Stretch', '3 min', 'assets/videos/butterfly-stretch.mp4', 'Hips', 'Open your hips and inner thighs. Great for improving flexibility and reducing tightness.'),
    MovementItem('Gentle Hamstring', 'Stretch', '2 min', 'assets/videos/gentle-hamstring.mp4', 'Legs', 'Loosen tight hamstrings while seated. Tight hamstrings contribute to back pain.'),
    MovementItem('Wall Push-ups', 'Strength', '3 min', 'assets/videos/wall-pushups.mp4', 'Upper Body', 'Build chest and arm strength without getting on the floor. Adjust angle for difficulty.'),
    MovementItem('Chair Squats', 'Strength', '5 min', 'assets/videos/chair-squats.mp4', 'Legs', 'Sit and stand from a chair to build functional leg and core strength. Very practical!'),
    MovementItem('Calf Raises', 'Strength', '2 min', 'assets/videos/calf-raises.mp4', 'Legs', 'Simple but effective for ankle stability and lower leg strength. Hold a wall for balance.'),
    MovementItem('Indoor Walk', 'Walk', '10 min', 'assets/videos/indoor-walk.mp4', 'Cardio', 'Walk in place or around your home. Put on your favorite music and just move!'),
    MovementItem('Nature Walk', 'Walk', '15 min', 'assets/videos/nature-walk.mp4', 'Cardio', 'Step outside and enjoy a refreshing walk. Fresh air + movement = mood boost.'),
  ];

  List<MovementItem> get _filteredMovements {
    if (_selectedCategory == 'All') return _movements;
    return _movements.where((m) => m.category == _selectedCategory).toList();
  }

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
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
          title: const Text('Movement Library',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          centerTitle: true,
        ),
        body: Column(
          children: [
            _buildCategorySelector(),
            _buildLibraryHeader(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _filteredMovements.isEmpty
                    ? _buildEmptyState()
                    : _buildGrid(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Container(
      height: 60,
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.space4),
        children: _categories.map((cat) {
          final isSelected = _selectedCategory == cat['label'];
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.only(right: AppTheme.space2),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat['label']),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (cat['color'] as Color).withValues(alpha: 0.15)
                      : AppTheme.glassWhite,
                  borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  border: Border.all(
                    color: isSelected ? (cat['color'] as Color) : AppTheme.glassBorders,
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: (cat['color'] as Color).withValues(alpha: 0.2), blurRadius: 12, spreadRadius: 1)]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(cat['icon'], style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      cat['label'],
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

  Widget _buildLibraryHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space5, vertical: AppTheme.space2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_filteredMovements.length} ${_filteredMovements.length == 1 ? 'exercise' : 'exercises'}',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          Row(
            children: [
              const Icon(Icons.fitness_center, color: AppTheme.textMuted, size: 14),
              const SizedBox(width: 4),
              Text('${_movements.length} total',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ],
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

  Widget _buildGrid() {
    return GridView.builder(
      key: ValueKey(_selectedCategory),
      padding: const EdgeInsets.fromLTRB(AppTheme.space5, 0, AppTheme.space5, AppTheme.space5),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppTheme.space4,
        crossAxisSpacing: AppTheme.space4,
        childAspectRatio: 0.7,
      ),
      itemCount: _filteredMovements.length,
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + (index * 50).clamp(0, 300)),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: _buildMovementCard(_filteredMovements[index]),
        );
      },
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
        opacity: 0.06,
        glowing: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      categoryColor.withValues(alpha: 0.15),
                      AppTheme.deepSpace.withValues(alpha: 0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppTheme.glassBorders.withValues(alpha: 0.5)),
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        child: CustomPaint(
                          painter: _CardPatternPainter(color: categoryColor),
                        ),
                      ),
                    ),
                    // Center icon
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: categoryColor.withValues(alpha: 0.2),
                              border: Border.all(color: categoryColor.withValues(alpha: 0.3)),
                            ),
                            child: Center(child: Text(_getExerciseIcon(item.category), style: const TextStyle(fontSize: 22))),
                          ),
                          const SizedBox(height: 6),
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
                    ),
                    // Duration badge
                    Positioned(
                      bottom: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.deepSpace.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                          border: Border.all(color: categoryColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.play_arrow, color: categoryColor, size: 12),
                            const SizedBox(width: 2),
                            Text(item.duration,
                                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 10, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppTheme.space2),
            // Title
            Text(
              item.title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 1),
            // Description
            Expanded(
              flex: 0,
              child: Text(
                item.description,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
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
      case 'Standing': return AppTheme.plasmaViolet;
      case 'Stretch': return AppTheme.roseGold;
      case 'Strength': return AppTheme.hotCoral;
      case 'Walk': return AppTheme.mintGreen;
      default: return AppTheme.neonCyan;
    }
  }
}

class _CardPatternPainter extends CustomPainter {
  final Color color;
  _CardPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.03)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final spacing = 20.0;
    for (double x = 0; x < size.width + spacing; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x - size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
