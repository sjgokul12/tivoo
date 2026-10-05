import 'package:flutter/material.dart';

/// Shared "3D glass" lighting used by cards and buttons.
abstract final class Gloss {
  /// Light from above: highlight on the top half, soft shade along the bottom.
  static const sheen = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x38FFFFFF), Color(0x0DFFFFFF), Color(0x00FFFFFF), Color(0x2E000010)],
    stops: [0, 0.4, 0.55, 1],
  );

  /// Diagonal reflection for larger cards.
  static const reflection = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x30FFFFFF), Color(0x00FFFFFF), Color(0x00FFFFFF), Color(0x40000010)],
    stops: [0, 0.35, 0.6, 1],
  );

  /// Neon halo plus a drop shadow underneath, so the surface looks lifted.
  static List<BoxShadow> raised(Color glow, {double blur = 16, double intensity = 0.55}) => [
        BoxShadow(color: glow.withValues(alpha: intensity), blurRadius: blur, blurStyle: BlurStyle.outer),
        const BoxShadow(color: Color(0x99000000), blurRadius: 10, offset: Offset(0, 6)),
      ];
}
