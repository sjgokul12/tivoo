import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Ultra-realistic 3D minted gold coins symbol featuring multiple stacked
/// coins in perspective with cylindrical milled edges, embossed stars,
/// depth shadows, metallic specular reflections, and diamond shine sparkles.
class Realistic3DCoin extends StatelessWidget {
  final double size;
  final bool isMultiple;

  const Realistic3DCoin({
    super.key,
    this.size = 38,
    this.isMultiple = true,
  });

  @override
  Widget build(BuildContext context) {
    // When size is small (like inline text chips < 22px), single coin is cleanest;
    // otherwise render the rich multiple 3D coins stack symbol.
    final renderMultiple = isMultiple && size >= 22;
    final w = renderMultiple ? size * 1.25 : size;
    final h = size;

    return SizedBox(
      width: w,
      height: h,
      child: CustomPaint(
        size: Size(w, h),
        painter: _Realistic3DCoinPainter(isMultiple: renderMultiple),
      ),
    );
  }
}

class _Realistic3DCoinPainter extends CustomPainter {
  final bool isMultiple;

  const _Realistic3DCoinPainter({required this.isMultiple});

  @override
  void paint(Canvas canvas, Size size) {
    if (isMultiple) {
      _drawMultipleCoins(canvas, size);
    } else {
      _drawSingleCoin(canvas, size);
    }
  }

  // ===========================================================================
  // MULTIPLE 3D COINS STACK & CLUSTER SYMBOL
  // ===========================================================================
  void _drawMultipleCoins(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 0. Ambient floor shadow & golden radiance underneath stack
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.50, h * 0.82),
        width: w * 0.86,
        height: h * 0.26,
      ),
      Paint()
        ..color = const Color(0xFFFFB300).withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );

    // 1. Coin 1: Back-Left Coin (slightly angled, depth tier 1)
    _drawAngledCoin(
      canvas,
      center: Offset(w * 0.32, h * 0.36),
      rx: w * 0.28,
      ry: h * 0.17,
      thickness: h * 0.10,
      brightness: 0.88,
    );

    // 2. Coin 2: Back-Right Coin (depth tier 2)
    _drawAngledCoin(
      canvas,
      center: Offset(w * 0.68, h * 0.40),
      rx: w * 0.29,
      ry: h * 0.18,
      thickness: h * 0.11,
      brightness: 0.94,
    );

    // 3. Coin 3: Front-Center Coin (main hero coin, crisp & prominent)
    _drawAngledCoin(
      canvas,
      center: Offset(w * 0.50, h * 0.58),
      rx: w * 0.34,
      ry: h * 0.22,
      thickness: h * 0.13,
      brightness: 1.05,
    );

    // 4. Sparkles / Specular diamond glints
    _drawSparkle(canvas, Offset(w * 0.74, h * 0.22), w * 0.07);
    _drawSparkle(canvas, Offset(w * 0.20, h * 0.66), w * 0.055);
  }

  // ===========================================================================
  // HELPER: DRAW AN ANGLED 3D COIN IN PERSPECTIVE WITH CYLINDRICAL THICKNESS
  // ===========================================================================
  void _drawAngledCoin(
    Canvas canvas, {
    required Offset center,
    required double rx,
    required double ry,
    required double thickness,
    double brightness = 1.0,
  }) {
    final topRect = Rect.fromCenter(center: center, width: rx * 2, height: ry * 2);
    final bottomCenter = Offset(center.dx, center.dy + thickness);
    final bottomRect = Rect.fromCenter(center: bottomCenter, width: rx * 2, height: ry * 2);

    // 1. Drop Shadow under individual coin
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(bottomCenter.dx, bottomCenter.dy + thickness * 0.35),
        width: rx * 2.1,
        height: ry * 1.8,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.45 * brightness)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, thickness * 0.8),
    );

    // 2. Cylindrical Edge / Rim Thickness
    final edgePath = Path()
      ..moveTo(center.dx - rx, center.dy)
      ..arcTo(topRect, math.pi, -math.pi, false)
      ..lineTo(bottomCenter.dx + rx, bottomCenter.dy)
      ..arcTo(bottomRect, 0, math.pi, false)
      ..close();

    final edgePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color.lerp(const Color(0xFF6B3A00), Colors.black, (1.0 - brightness).clamp(0.0, 1.0))!,
          Color.lerp(const Color(0xFFFFD54F), Colors.white, (brightness - 1.0).clamp(0.0, 1.0))!,
          Color.lerp(const Color(0xFFC78100), Colors.black, (1.0 - brightness).clamp(0.0, 1.0))!,
          Color.lerp(const Color(0xFF5A3100), Colors.black, (1.0 - brightness).clamp(0.0, 1.0))!,
          Color.lerp(const Color(0xFFFFE082), Colors.white, (brightness - 1.0).clamp(0.0, 1.0))!,
          Color.lerp(const Color(0xFF9E5C00), Colors.black, (1.0 - brightness).clamp(0.0, 1.0))!,
        ],
        stops: const [0.0, 0.22, 0.45, 0.65, 0.82, 1.0],
      ).createShader(Rect.fromLTRB(center.dx - rx, center.dy, center.dx + rx, bottomCenter.dy + ry));
    canvas.drawPath(edgePath, edgePaint);

    // Fine vertical milled ridge lines on edge
    final ridgePaint = Paint()
      ..color = const Color(0x333E2000)
      ..strokeWidth = 1.0;
    const ridgeCount = 14;
    for (int i = 1; i < ridgeCount; i++) {
      final t = i / ridgeCount;
      final a = math.pi + t * math.pi;
      final x = center.dx + rx * math.cos(a);
      final yTop = center.dy + ry * math.sin(a);
      final yBot = yTop + thickness;
      canvas.drawLine(Offset(x, yTop), Offset(x, yBot), ridgePaint);
    }

    // Bottom edge rim highlight curve
    final bottomRimPath = Path()..addArc(bottomRect, 0, math.pi);
    canvas.drawPath(
      bottomRimPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..shader = const LinearGradient(
          colors: [Color(0x88FFE082), Color(0x22422000), Color(0x88FFE082)],
        ).createShader(bottomRect),
    );

    // 3. Top Face Outer Rim Ellipse
    final faceRimPaint = Paint()
      ..shader = SweepGradient(
        center: Alignment.center,
        colors: const [
          Color(0xFFFFF9C4),
          Color(0xFFFFCA28),
          Color(0xFFB87800),
          Color(0xFF593300),
          Color(0xFFFFB300),
          Color(0xFFFFF9C4),
          Color(0xFF8A4F00),
          Color(0xFFFFF9C4),
        ],
        stops: const [0.0, 0.2, 0.38, 0.52, 0.7, 0.85, 0.93, 1.0],
        transform: GradientRotation(-math.pi / 4),
      ).createShader(topRect);
    canvas.drawOval(topRect, faceRimPaint);

    // 4. Inner Ridge Groove
    final grooveRect = Rect.fromCenter(center: center, width: rx * 1.76, height: ry * 1.76);
    canvas.drawOval(
      grooveRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = rx * 0.08
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6B3C00), Color(0xFFFFECB3)],
        ).createShader(grooveRect),
    );

    // 5. Minted Face Disc
    final discRect = Rect.fromCenter(center: center, width: rx * 1.62, height: ry * 1.62);
    canvas.drawOval(
      discRect,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.25, -0.25),
          colors: const [
            Color(0xFFFFEE58),
            Color(0xFFFFC107),
            Color(0xFFCC8300),
            Color(0xFF6E3C00),
          ],
          stops: const [0.0, 0.5, 0.85, 1.0],
        ).createShader(discRect),
    );

    // 6. Embossed 3D Star (Perspective-adjusted)
    final starOuterRx = rx * 0.42;
    final starOuterRy = ry * 0.42;
    final starInnerRx = rx * 0.19;
    final starInnerRy = ry * 0.19;

    Path createStar(Offset c) {
      final path = Path();
      for (int i = 0; i < 10; i++) {
        final a = -math.pi / 2 + (i * math.pi / 5);
        final radX = (i.isEven) ? starOuterRx : starInnerRx;
        final radY = (i.isEven) ? starOuterRy : starInnerRy;
        final x = c.dx + radX * math.cos(a);
        final y = c.dy + radY * math.sin(a);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      return path;
    }

    // Drop shadow of star
    canvas.drawPath(
      createStar(Offset(center.dx, center.dy + ry * 0.08)),
      Paint()..color = const Color(0x884E2600),
    );
    // Specular top highlight of star
    canvas.drawPath(
      createStar(Offset(center.dx - rx * 0.03, center.dy - ry * 0.04)),
      Paint()..color = const Color(0xE6FFFDE7),
    );
    // Star body
    canvas.drawPath(
      createStar(center),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFDE7), Color(0xFFFFB300), Color(0xFFBF7400)],
        ).createShader(discRect),
    );

    // 7. Specular Gloss Glare / Sheen arc
    final sheenPath = Path()
      ..addArc(
        Rect.fromCenter(center: center, width: rx * 1.55, height: ry * 1.55),
        -math.pi * 0.85,
        math.pi * 0.7,
      );
    canvas.drawPath(
      sheenPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = rx * 0.12
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x99FFFFFF), Color(0x00FFFFFF)],
        ).createShader(topRect),
    );
  }

  // ===========================================================================
  // DIAMOND SHINE SPARKLE (✨)
  // ===========================================================================
  void _drawSparkle(Canvas canvas, Offset pos, double r) {
    final p = Path()
      ..moveTo(pos.dx, pos.dy - r)
      ..quadraticBezierTo(pos.dx, pos.dy, pos.dx + r, pos.dy)
      ..quadraticBezierTo(pos.dx, pos.dy, pos.dx, pos.dy + r)
      ..quadraticBezierTo(pos.dx, pos.dy, pos.dx - r, pos.dy)
      ..quadraticBezierTo(pos.dx, pos.dy, pos.dx, pos.dy - r)
      ..close();

    canvas.drawCircle(
      pos,
      r * 1.4,
      Paint()
        ..color = const Color(0xFFFFE082).withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );
    canvas.drawPath(p, Paint()..color = Colors.white);
  }

  // ===========================================================================
  // SINGLE FLAT/ROUND COIN (FOR COMPACT SIZES < 22PX)
  // ===========================================================================
  void _drawSingleCoin(Canvas canvas, Size size) {
    final r = size.width / 2;
    final center = Offset(r, r);
    final rect = Rect.fromCircle(center: center, radius: r);

    // Outer Beveled Rim
    final rimPaint = Paint()
      ..shader = const SweepGradient(
        colors: [
          Color(0xFFFFF9C4),
          Color(0xFFFFCA28),
          Color(0xFFC78100),
          Color(0xFF5D3800),
          Color(0xFFFFB300),
          Color(0xFFFFF9C4),
          Color(0xFF8C5300),
          Color(0xFFFFF9C4),
        ],
        stops: [0.0, 0.2, 0.38, 0.52, 0.7, 0.85, 0.93, 1.0],
        transform: GradientRotation(-math.pi / 4),
      ).createShader(rect);
    canvas.drawCircle(center, r, rimPaint);

    // Bevel groove
    final groovePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.08
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF6D3E00), Color(0xFFFFECB3)],
      ).createShader(rect);
    canvas.drawCircle(center, r * 0.88, groovePaint);

    // Minted inner disc
    final discPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.25, -0.25),
        colors: const [
          Color(0xFFFFEE58),
          Color(0xFFFFC107),
          Color(0xFFD68A00),
          Color(0xFF7A4500),
        ],
        stops: const [0.0, 0.5, 0.85, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: r * 0.82));
    canvas.drawCircle(center, r * 0.82, discPaint);

    // Center star
    final starOuterR = r * 0.44;
    final starInnerR = r * 0.20;
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final a = -math.pi / 2 + (i * math.pi / 5);
      final rad = (i.isEven) ? starOuterR : starInnerR;
      final x = center.dx + rad * math.cos(a);
      final y = center.dy + rad * math.sin(a);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFFDE7), Color(0xFFFFB300), Color(0xFFC47600)],
        ).createShader(Rect.fromCircle(center: center, radius: starOuterR)),
    );
  }

  @override
  bool shouldRepaint(covariant _Realistic3DCoinPainter oldDelegate) =>
      oldDelegate.isMultiple != isMultiple;
}
