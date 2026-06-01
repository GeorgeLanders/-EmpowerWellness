import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _slowController;
  late AnimationController _fastController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _slowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    _fastController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 15),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _slowController.dispose();
    _fastController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Deep Space Base
        Container(decoration: BoxDecoration(gradient: AppTheme.spaceGradient)),

        // Animated Nebula Blobs
        AnimatedBuilder(
          animation: Listenable.merge([_slowController, _fastController, _pulseController]),
          builder: (context, child) {
            return Stack(
              children: [
                // Primary purple blob (large, slow)
                _buildBlob(
                  Offset(
                    math.sin(_slowController.value * 2 * math.pi) * size.width * 0.3,
                    math.cos(_slowController.value * 2 * math.pi) * size.height * 0.2,
                  ),
                  AppTheme.primaryPurple.withValues(alpha: 0.15 + _pulseController.value * 0.05),
                  450,
                ),
                // Cyan blob (medium, medium speed)
                _buildBlob(
                  Offset(
                    math.cos(_fastController.value * 2 * math.pi) * size.width * 0.35,
                    math.sin(_fastController.value * 2 * math.pi) * size.height * 0.25,
                  ),
                  AppTheme.neonCyan.withValues(alpha: 0.08 + _pulseController.value * 0.04),
                  320,
                ),
                // Coral blob (small, orbiting)
                _buildBlob(
                  Offset(
                    math.sin(_slowController.value * 3 * math.pi + 1) * size.width * 0.25,
                    math.cos(_slowController.value * 3 * math.pi + 1) * size.height * 0.3,
                  ),
                  AppTheme.hotCoral.withValues(alpha: 0.06 + _pulseController.value * 0.03),
                  380,
                ),
                // Rose gold blob (very slow, background)
                _buildBlob(
                  Offset(
                    math.cos(_slowController.value * 1.5 * math.pi) * size.width * 0.4,
                    math.sin(_slowController.value * 1.5 * math.pi) * size.height * 0.35,
                  ),
                  AppTheme.roseGold.withValues(alpha: 0.05),
                  500,
                ),
                // Warm gold accent (tiny, fast orbit)
                _buildBlob(
                  Offset(
                    math.sin(_fastController.value * 4 * math.pi + 2) * size.width * 0.15,
                    math.cos(_fastController.value * 4 * math.pi + 2) * size.height * 0.2,
                  ),
                  AppTheme.warmGold.withValues(alpha: 0.04 + _pulseController.value * 0.02),
                  200,
                ),
              ],
            );
          },
        ),

        // Subtle noise overlay for texture
        Positioned.fill(
          child: Opacity(
            opacity: 0.03,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),

        // The actual app content
        SizedBox.expand(child: widget.child),
      ],
    );
  }

  Widget _buildBlob(Offset offset, Color color, double size) {
    return Positioned(
      left: (MediaQuery.of(context).size.width / 2) + offset.dx - (size / 2),
      top: (MediaQuery.of(context).size.height / 2) + offset.dy - (size / 2),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: size * 0.4,
              spreadRadius: size * 0.15,
            ),
          ],
        ),
      ),
    );
  }
}
