import 'package:flutter/material.dart';

class AppTheme {
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

  // ── Core Palette ──
  static const Color deepSpace     = Color(0xFF0B051A);
  static const Color voidPurple    = Color(0xFF1B0A2E);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color neonCyan      = Color(0xFF00F5FF);
  static const Color hotCoral      = Color(0xFFFF3366);
  static const Color warmGold      = Color(0xFFFFB800);
  static const Color roseGold      = Color(0xFFE8A87C);

  // ── Extended Palette (Iridescent) ──
  static const Color plasmaViolet  = Color(0xFFC084FC);
  static const Color iceBlue       = Color(0xFF67E8F9);
  static const Color emberOrange   = Color(0xFFFB923C);
  static const Color mintGreen     = Color(0xFF34D399);
  static const Color softLavender  = Color(0xFFD8B4FE);

  // ── Text Colors ──
  static const Color textPrimary   = Colors.white;
  static const Color textSecondary = Color(0xFFB0A5C0);
  static const Color textMuted     = Color(0xFF6B5B8B);

  // ── Glass Overlays ──
  static const Color glassWhite    = Color(0x1AFFFFFF);
  static const Color glassPurple   = Color(0x1A8B5CF6);
  static const Color glassCyan     = Color(0x1A00F5FF);
  static const Color glassBorders  = Color(0x33FFFFFF);
  static const Color glassHighlight = Color(0x0DFFFFFF);

  // ── Gradients ──
  static const LinearGradient purpleCoral = LinearGradient(
    colors: [primaryPurple, hotCoral],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGold = LinearGradient(
    colors: [neonCyan, warmGold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient spaceGradient = LinearGradient(
    colors: [Color(0xFF0B051A), Color(0xFF1B0A2E), Color(0xFF0F0820)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const RadialGradient glowPurple = RadialGradient(
    colors: [Color(0x408B5CF6), Color(0x008B5CF6)],
  );

  static const RadialGradient glowCoral = RadialGradient(
    colors: [Color(0x40FF3366), Color(0x00FF3366)],
  );

  static const RadialGradient glowCyan = RadialGradient(
    colors: [Color(0x4000F5FF), Color(0x0000F5FF)],
  );

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
