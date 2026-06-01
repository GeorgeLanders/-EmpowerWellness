import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final dynamic radius;
  final Color? tint;
  final double opacity;
  final Color? borderColor;
  final bool glowing;
  final Color? glowColor;
  final double glowIntensity;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.radius,
    this.tint,
    this.opacity = 0.08,
    this.borderColor,
    this.glowing = false,
    this.glowColor,
    this.glowIntensity = 0.15,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius finalRadius = (radius is double)
        ? BorderRadius.circular(radius as double)
        : (radius as BorderRadius?) ?? BorderRadius.circular(AppTheme.radiusLg);

    return Container(
      decoration: BoxDecoration(
        borderRadius: finalRadius,
        boxShadow: [
          if (glowing)
            BoxShadow(
              color: (glowColor ?? tint ?? AppTheme.primaryPurple).withValues(alpha: glowIntensity),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: finalRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppTheme.space4),
            decoration: BoxDecoration(
              color: (tint ?? Colors.white).withValues(alpha: opacity),
              borderRadius: finalRadius,
              border: Border.all(
                color: borderColor ?? AppTheme.glassBorders,
                width: 1.0,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.06),
                  Colors.white.withValues(alpha: 0.02),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
