import 'package:flutter/material.dart';

/// Single source of truth for the Tivoo neon-glass palette.
abstract final class AppColors {
  static const background = Color(0xFF04040E);
  static const backgroundAlt = Color(0xFF0E0A2E);
  static const navy = Color(0xFF111436);

  static const pink = Color(0xFFFF3FA4);
  static const magenta = Color(0xFFD946EF);
  static const purple = Color(0xFF8B5CF6);
  static const violet = Color(0xFF6D28D9);
  static const blue = Color(0xFF3B82F6);
  static const cyan = Color(0xFF38BDF8);
  static const gold = Color(0xFFFFC83D);
  static const orange = Color(0xFFFF9F1C);
  static const live = Color(0xFFFF2D6F);
  static const success = Color(0xFF34D399);

  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFFC9C6E8);
  static const textMuted = Color(0xFF8E8AB8);
  static const link = Color(0xFF6EA8FF);

  static const glassFill = Color(0x1AFFFFFF);
  static const glassBorder = Color(0x33FFFFFF);

  static const brandGradient = LinearGradient(
    colors: [Color(0xFFFF4FB0), Color(0xFFB44CFF), Color(0xFF4F7CFF)],
  );
  static const logoGradient = LinearGradient(
    colors: [Color(0xFFFFB547), Color(0xFFFF4FA3), Color(0xFFC04BFF), Color(0xFF7C6BFF)],
  );
  static const goldGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFE680), Color(0xFFFFC23A), Color(0xFFFF9500)],
  );
  static const liveGradient = LinearGradient(
    colors: [Color(0xFFFF5C9A), Color(0xFFE8207F)],
  );
  static const pinkPurpleGradient = LinearGradient(
    colors: [Color(0xFFFF4FB0), Color(0xFF9B5CFF)],
  );
  static const blueGradient = LinearGradient(
    colors: [Color(0xFF38BDF8), Color(0xFF2563EB)],
  );
}
