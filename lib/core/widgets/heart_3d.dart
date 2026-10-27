import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Glossy 3D heart with specular shine, bevel depth and customizable glow.
class Heart3D extends StatelessWidget {
  final double size;
  final Color color;
  final double glow;

  const Heart3D({
    super.key,
    required this.size,
    this.color = const Color(0xFFFF2DAA),
    this.glow = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size(size, size),
        painter: _Heart3DPainter(color: color, glow: glow),
      ),
    );
  }
}

class _Heart3DPainter extends CustomPainter {
  final Color color;
  final double glow;

  const _Heart3DPainter({required this.color, required this.glow});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Heart path scaled to fit the bounding box
    final path = Path();
    path.moveTo(w * 0.5, h * 0.88);
    // Left bottom up to top-left arch
    path.cubicTo(w * 0.1, h * 0.65, -w * 0.05, h * 0.35, w * 0.18, h * 0.14);
    path.cubicTo(w * 0.35, -h * 0.02, w * 0.48, h * 0.12, w * 0.5, h * 0.25);
    // Top-right arch down to bottom
    path.cubicTo(w * 0.52, h * 0.12, w * 0.65, -h * 0.02, w * 0.82, h * 0.14);
    path.cubicTo(w * 1.05, h * 0.35, w * 0.9, h * 0.65, w * 0.5, h * 0.88);
    path.close();

    // 1. Glow bloom behind heart
    if (glow > 0) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: (0.45 * glow).clamp(0.0, 1.0))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, math.max(1.0, w * 0.22 * glow));
      canvas.drawPath(path, glowPaint);
    }

    // 2. 3D Body shading (gradient from top-left bright light to bottom-right shadow)
    final lightColor = Color.lerp(color, Colors.white, 0.45)!;
    final darkColor = Color.lerp(color, Colors.black, 0.35)!;
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [lightColor, color, darkColor],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(path, bodyPaint);

    // 3. Subtle inner stroke / rim light
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.6, w * 0.035)
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white.withValues(alpha: 0.8), color.withValues(alpha: 0.3)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(path, strokePaint);

    // 4. Glossy specular shine on top-left lobe
    final shinePath = Path();
    shinePath.moveTo(w * 0.22, h * 0.2);
    shinePath.cubicTo(w * 0.28, h * 0.14, w * 0.4, h * 0.16, w * 0.44, h * 0.24);
    shinePath.cubicTo(w * 0.4, h * 0.27, w * 0.3, h * 0.27, w * 0.24, h * 0.24);
    shinePath.close();

    final shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, math.max(0.5, w * 0.04));
    canvas.drawPath(shinePath, shinePaint);

    // 5. Tiny glint sparkle
    final glintPaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    canvas.drawCircle(Offset(w * 0.3, h * 0.22), math.max(0.5, w * 0.04), glintPaint);
  }

  @override
  bool shouldRepaint(covariant _Heart3DPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.glow != glow;
}
