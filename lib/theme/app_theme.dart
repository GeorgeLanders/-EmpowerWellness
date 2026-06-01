import 'package:flutter/material.dart';

class AppTheme {
  // ── EmpowerWellness V2: Ultra-Glass & Miniature World ──
  
  // ── 4px Grid System ──
  static const double space1 = 4.0;
  static const double space2 = 8.0;
  static const double space3 = 12.0;
  static const double space4 = 16.0;
  static const double space5 = 20.0;
  static const double space6 = 24.0;
  static const double space7 = 32.0;
  static const double space8 = 48.0;

  // ── Border Radius Scale ──
  static const double radiusSm = 6.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusPill = 100.0;

  // ── Core Palette (Deep Space & Iridescence) ──
  static const Color deepSpace    = Color(0xFF0B051A); // Absolute dark void
  static const Color voidPurple   = Color(0xFF1B0A2E); // Deep nền
  static const Color primaryPurple = Color(0xFF8B5CF6); // Vivid Purple
  static const Color neonCyan     = Color(0xFF00F5FF); // Bright Cyan
  static const Color hotCoral     = Color(0xFFFF3366); // Energy Coral
  static const Color warmGold     = Color(0xFFFFB800); // Achievement Gold
  static const Color roseGold     = Color(0xFFE8A87C); // Soft Wellness

  // ── Text Colors ──
  static const Color textPrimary   = Colors.white;
  static const Color textSecondary = Color(0xFFB0A5C0); // Muted purple-grey
  static const Color textMuted     = Color(0xFF6B5B8B);

  // ── Glass Overlays ──
  static const Color glassWhite    = Color(0x1AFFFFFF); // 10% White
  static const Color glassPurple   = Color(0x1A8B5CF6); // 10% Purple
  static const Color glassBorders  = Color(0x33FFFFFF); // 20% White for edges

  // ── Theme Data ──
  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: deepSpace,
    fontFamily: 'Inter',
    colorScheme: ColorScheme.dark(
      primary: primaryPurple,
      secondary: neonCyan,
      tertiary: hotCoral,
      surface: voidPurple,
    ),
  );
}
