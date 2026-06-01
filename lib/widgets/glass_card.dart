import 'package:flutter/material.dart';
import 'dart:ui'; // Required for ImageFilter
import '../theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final dynamic radius;
  final Color? tint;
  final double opacity;
  final Color? borderColor;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.radius,
    this.tint,
    this.opacity = 0.1,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius finalRadius = (radius is double)
        ? BorderRadius.circular(radius as double)
        : (radius as BorderRadius?) ?? BorderRadius.circular(AppTheme.radiusLg);

    return ClipRRect(
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
