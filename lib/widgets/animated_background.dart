import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Deep Space Base
        Container(color: AppTheme.deepSpace),
        
        // Animated Nebula Blobs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                _buildBlob(
                  offset: Offset(math.sin(_controller.value * 2 * math.pi) * 100, math.cos(_controller.value * 2 * math.pi) * 100),
                  color: AppTheme.primaryPurple.withValues(alpha: 0.2),
                  size: 400,
                ),
                _buildBlob(
                  offset: Offset(math.cos(_controller.value * 2 * math.pi) * 150, math.sin(_controller.value * 2 * math.pi) * 150),
                  color: AppTheme.neonCyan.withValues(alpha: 0.15),
                  size: 300,
                ),
                _buildBlob(
                  offset: Offset(math.sin(_controller.value * 3 * math.pi) * 80, math.cos(_controller.value * 3 * math.pi) * 80),
                  color: AppTheme.hotCoral.withValues(alpha: 0.1),
                  size: 500,
                ),
              ],
            );
          },
        ),
        
        // The actual app content
        SizedBox.expand(child: widget.child),
      ],
    );
  }

  Widget _buildBlob( {required Offset offset, required Color color, required double size}) {
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
              blurRadius: 100,
              spreadRadius: 50,
            ),
          ],
        ),
      ),
    );
  }
}
