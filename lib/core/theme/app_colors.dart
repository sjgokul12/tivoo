import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Backgrounds - Pure AMOLED Black & Deep Charcoal
  static const Color background = Color(0xFF000000);
  static const Color cardBackground = Color(0xFF101012);
  static const Color surfaceColor = Color(0xFF17171A);
  static const Color glassBackground = Color(0xEB0A0A0C);
  static const Color bubbleBackground = Color(0xF018181C);

  // Brand & Accents - Electric Cyber Yellow & Golden Amber
  static const Color primaryYellow = Color(0xFFFFD600); // Electric Cyber Yellow
  static const Color primaryAmber = Color(0xFFFFAB00); // Warm Amber Gold
  static const Color primaryYellowLight = Color(0xFFFFEA00); // Bright Neon Yellow
  static const Color vipGold = Color(0xFFFFD700);
  static const Color vipAmber = Color(0xFFFFA000);
  static const Color vipDeepGold = Color(0xFFFF8F00);
  static const Color vipDarkCard = Color(0xFF101322);
  static const Color vipDarkBase = Color(0xFF070810);
  static const Color vipBorderGold = Color(0x66FFD700);

  // Aliases for seamless compatibility
  static const Color primaryPink = primaryYellow;
  static const Color primaryPurple = primaryAmber;
  static const Color primaryCyan = primaryYellowLight;
  static const Color liveRed = Color(0xFFFF3B30); // Kept for live broadcast alerts
  static const Color verifiedBlue = Color(0xFF2196F3); // Golden/Blue verified badge

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B8);
  static const Color textMuted = Color(0xFF6E6E78);
  static const Color textOnPrimary = Color(0xFF000000); // High-contrast black on yellow

  // Indicators & Badges
  static const Color diamondCyan = Color(0xFFFFD600);
  static const Color viewerWhite = Color(0xFFFFFFFF);
  static const Color dotInactive = Color(0x40FFFFFF);
  static const Color borderSubtle = Color(0x33FFD600); // Subtle gold glow border

  // Light theme (for light mode option)
  static const Color lightScaffoldBackground = Color(0xFFF7F7FA);
  static const Color lightOnSurface = Color(0xFF101014);

  // Neon glow colors
  static const Color glowPink = Color(0xFFFFD600);
  static const Color glowPurple = Color(0xFFFFAB00);
  static const Color glowCyan = Color(0xFFFFEA00);
  static const Color glowYellow = Color(0xFFFFD600);

  // Gradients - Rich Yellow & Black / Cyber Gold Palettes

  // Local one-off gradients used by TivooLogo
  static const LinearGradient logoSplashGradient = LinearGradient(
    colors: [
      Color(0xFFFFF59D), // Soft pale gold
      Color(0xFFFFD600), // Pure electric yellow
      Color(0xFFFF9100), // Deep amber gold
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient logoPlayOGradient1 = LinearGradient(
    colors: [Color(0xFFFFEA00), Color(0xFFFFB300)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient logoPlayOGradient2 = LinearGradient(
    colors: [Color(0xFFFFD600), Color(0xFFFF8F00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandLogoGradient = LinearGradient(
    colors: [Color(0xFFFFF9C4), Color(0xFFFFEA00), Color(0xFFFFD600), Color(0xFFFF9800)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient getStartedButtonGradient = LinearGradient(
    colors: [Color(0xFFFFEA00), Color(0xFFFFD600), Color(0xFFFF9800)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient popularTabGradient = LinearGradient(
    colors: [Color(0xFFFFF59D), Color(0xFFFFD600), Color(0xFFFFAB00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient storyRingGradient = LinearGradient(
    colors: [Color(0xFFFFEA00), Color(0xFFFFD600), Color(0xFFFF9100), Color(0xFFFF6D00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient followButtonGradient = LinearGradient(
    colors: [Color(0xFFFFEA00), Color(0xFFFFB300)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient liveCenterButtonGradient = LinearGradient(
    colors: [Color(0xFFFFEA00), Color(0xFFFF9800)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonAuroraGradient = LinearGradient(
    colors: [Color(0xFFFFF9C4), Color(0xFFFFD600), Color(0xFFFF9100)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient neonSunsetGradient = LinearGradient(
    colors: [Color(0xFFFFEA00), Color(0xFFFFAB00), Color(0xFFFF6D00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient vipGoldGradient = LinearGradient(
    colors: [Color(0xFFFFF1A8), Color(0xFFFFD700), Color(0xFFFFA000)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient vipMetallicGradient = LinearGradient(
    colors: [Color(0xFFFFEA00), Color(0xFFFFB300), Color(0xFFFF8F00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient yellowBlackGradient = LinearGradient(
    colors: [Color(0xFFFFD600), Color(0xFF101012)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
