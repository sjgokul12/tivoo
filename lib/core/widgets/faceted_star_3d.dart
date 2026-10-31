import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_assets.dart';

/// Ultra-sharp 3D faceted gold star for PK gift portals and screens.
/// Renders high-quality glossy star asset with custom painted faceted vector fallback.
class FacetedStar3D extends StatelessWidget {
  final double size;

  const FacetedStar3D({
    super.key,
    this.size = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        AppAssets.glossyStar,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => CustomPaint(
          size: Size(size, size),
          painter: const _FacetedStar3DPainter(),
        ),
      ),
    );
  }
}

class _FacetedStar3DPainter extends CustomPainter {
  const _FacetedStar3DPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width * 0.46;
    final innerR = outerR * 0.44;

    final outerPoints = <Offset>[];
    final innerPoints = <Offset>[];

    for (int i = 0; i < 5; i++) {
      final aOuter = -math.pi / 2 + (i * 2 * math.pi / 5);
      final aInner = aOuter + (math.pi / 5);
      outerPoints.add(Offset(cx + outerR * math.cos(aOuter), cy + outerR * math.sin(aOuter)));
      innerPoints.add(Offset(cx + innerR * math.cos(aInner), cy + innerR * math.sin(aInner)));
    }

    final center = Offset(cx, cy);

    // 1. Soft gold bloom glow behind star
    final glowPaint = Paint()
      ..color = const Color(0x66FFD700)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, outerR * 0.35);
    canvas.drawCircle(center, outerR * 0.9, glowPaint);

    // 2. Faceted 3D shading:
    final lightPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFFBEA), Color(0xFFFFE082), Color(0xFFFFD54F)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final darkPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFB300), Color(0xFFF57C00), Color(0xFFC76900)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    for (int i = 0; i < 5; i++) {
      final prevInner = innerPoints[(i + 4) % 5];
      final currOuter = outerPoints[i];
      final currInner = innerPoints[i];

      final pathLight = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(prevInner.dx, prevInner.dy)
        ..lineTo(currOuter.dx, currOuter.dy)
        ..close();
      canvas.drawPath(pathLight, lightPaint);

      final pathDark = Path()
        ..moveTo(center.dx, center.dy)
        ..lineTo(currOuter.dx, currOuter.dy)
        ..lineTo(currInner.dx, currInner.dy)
        ..close();
      canvas.drawPath(pathDark, darkPaint);
    }

    // 3. Crisp outer gold outline
    final outlinePath = Path();
    outlinePath.moveTo(outerPoints[0].dx, outerPoints[0].dy);
    for (int i = 0; i < 5; i++) {
      outlinePath.lineTo(innerPoints[i].dx, innerPoints[i].dy);
      outlinePath.lineTo(outerPoints[(i + 1) % 5].dx, outerPoints[(i + 1) % 5].dy);
    }
    outlinePath.close();

    final strokePaint = Paint()
      ..color = const Color(0xFFFFF9C4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(0.6, size.width * 0.04);
    canvas.drawPath(outlinePath, strokePaint);

    // 4. Center jewel facet accent
    if (size.width >= 14) {
      final jewelR = outerR * 0.22;
      final jewelPath = Path()
        ..moveTo(cx, cy - jewelR)
        ..lineTo(cx + jewelR * 0.8, cy)
        ..lineTo(cx, cy + jewelR)
        ..lineTo(cx - jewelR * 0.8, cy)
        ..close();

      final jewelPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE040FB), Color(0xFF7C4DFF)],
        ).createShader(Rect.fromCircle(center: center, radius: jewelR));
      canvas.drawPath(jewelPath, jewelPaint);
    }

    // 5. Specular highlight sparkle glint
    final glintPaint = Paint()..color = Colors.white.withValues(alpha: 0.9);
    canvas.drawCircle(Offset(cx - outerR * 0.25, cy - outerR * 0.28), math.max(0.8, outerR * 0.12), glintPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
