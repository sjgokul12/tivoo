// Colours and shared decorations for the PK battle screen.

import 'package:flutter/material.dart';

/// Design tokens for the PK Battle screen (dark navy + neon pink / blue).
class PkColors {
  PkColors._();

  static const Color background = Color(0xFF070A18);
  static const Color backgroundTop = Color(0xFF0B1434);
  static const Color surface = Color(0xE60E1428);
  static const Color stroke = Color(0xFF2A3355);

  static const Color pink = Color(0xFFFF2D78);
  static const Color blue = Color(0xFF1E88FF);
  static const Color cyan = Color(0xFF00C6FF);
  static const Color gold = Color(0xFFFFD54A);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0BBD8);

  /// Accent for a side of the battle: left host is pink, right host is blue.
  static Color side(bool isLeft) => isLeft ? pink : blue;
}

/// Shared decorations so every card on the screen has the same neon-glass look.
class PkDecor {
  PkDecor._();

  static BoxDecoration glass({
    Color border = PkColors.stroke,
    double radius = 16,
    double borderWidth = 1,
    double glow = 0,
    Color color = PkColors.surface,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border, width: borderWidth),
      boxShadow: glow > 0 ? [BoxShadow(color: border.withValues(alpha: 0.45), blurRadius: glow)] : null,
    );
  }
}
