import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/models/camera_filter_model.dart';

/// Real-time animated AR / Visual overlay widget rendered on top of the camera feed.
/// Features smooth continuous animations for butterflies, bunny ears, hearts, galaxy sparkles, etc.
class FilterOverlayWidget extends StatefulWidget {
  final CameraFilterModel filter;

  const FilterOverlayWidget({
    super.key,
    required this.filter,
  });

  @override
  State<FilterOverlayWidget> createState() => _FilterOverlayWidgetState();
}

class _FilterOverlayWidgetState extends State<FilterOverlayWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  )..repeat();

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.filter.isNone) return const SizedBox.shrink();

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, _) {
          return CustomPaint(
            painter: _FilterPainter(
              filter: widget.filter,
              progress: _anim.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _FilterPainter extends CustomPainter {
  final CameraFilterModel filter;
  final double progress;

  _FilterPainter({
    required this.filter,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    switch (filter.overlayType) {
      case FilterOverlayType.butterfly:
        _drawButterflies(canvas, size);
        break;
      case FilterOverlayType.bunny:
        _drawBunnyEars(canvas, size);
        break;
      case FilterOverlayType.heart:
        _drawHearts(canvas, size);
        break;
      case FilterOverlayType.galaxy:
        _drawGalaxy(canvas, size);
        break;
      case FilterOverlayType.naturalGlow:
        _drawNaturalGlow(canvas, size);
        break;
      case FilterOverlayType.catAnime:
        _drawCatAnime(canvas, size);
        break;
      case FilterOverlayType.dog:
        _drawDog(canvas, size);
        break;
      case FilterOverlayType.vintage:
        _drawVintage(canvas, size);
        break;
      case FilterOverlayType.angelHalo:
        _drawAngelHalo(canvas, size);
        break;
      case FilterOverlayType.cyberGlasses:
        _drawCyberGlasses(canvas, size);
        break;
      case FilterOverlayType.none:
        break;
    }
  }

  // ---------------------------------------------------------------------------
  // 1. Butterflies (Screenshot 3: Neon fluttering butterflies around head)
  // ---------------------------------------------------------------------------
  void _drawButterflies(Canvas canvas, Size size) {
    final headCenterX = size.width * 0.5;
    final headCenterY = size.height * 0.32;

    final butterflyPositions = [
      Offset(headCenterX - size.width * 0.28, headCenterY - size.height * 0.08),
      Offset(headCenterX - size.width * 0.32, headCenterY + size.height * 0.02),
      Offset(headCenterX + size.width * 0.26, headCenterY - size.height * 0.07),
      Offset(headCenterX + size.width * 0.32, headCenterY + size.height * 0.03),
      Offset(headCenterX - size.width * 0.14, headCenterY - size.height * 0.16),
      Offset(headCenterX + size.width * 0.16, headCenterY - size.height * 0.15),
    ];

    for (int i = 0; i < butterflyPositions.length; i++) {
      final base = butterflyPositions[i];
      final offsetAngle = progress * 2 * math.pi + (i * 1.2);
      final hoverX = math.cos(offsetAngle) * 6;
      final hoverY = math.sin(offsetAngle) * 8;
      final flap = (math.sin(progress * 14 + i) * 0.4 + 0.6).abs();

      final pos = Offset(base.dx + hoverX, base.dy + hoverY);
      final butterflySize = (size.width * 0.08) * (i.isEven ? 1.0 : 0.85);

      _paintButterfly(
        canvas: canvas,
        center: pos,
        radius: butterflySize,
        wingScaleX: flap,
        primary: const Color(0xFFFF2DC0),
        secondary: const Color(0xFFFF8AE6),
        rotation: (i < 3 ? -0.2 : 0.2) + math.sin(offsetAngle) * 0.1,
      );

      // Star sparkles near butterflies
      final sparklePos = Offset(pos.dx + math.cos(offsetAngle) * 16, pos.dy + math.sin(offsetAngle) * 16);
      _drawSparkle(canvas, sparklePos, 6, const Color(0xFFFFF0FA));
    }

    // Soft pink vignette halo
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.4),
        radius: 0.8,
        colors: [
          const Color(0x33FF2DC0),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), glowPaint);
  }

  void _paintButterfly({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double wingScaleX,
    required Color primary,
    required Color secondary,
    double rotation = 0,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    // Glow aura
    final glow = Paint()
      ..color = primary.withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset.zero, radius * 0.9, glow);

    final wingPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [secondary, primary],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: radius))
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Left wings
    canvas.save();
    canvas.scale(wingScaleX, 1.0);
    final leftTopWing = Path()
      ..moveTo(0, 0)
      ..cubicTo(-radius * 0.8, -radius * 1.1, -radius * 1.2, -radius * 0.4, 0, radius * 0.1)
      ..close();
    final leftBottomWing = Path()
      ..moveTo(0, 0)
      ..cubicTo(-radius * 0.9, radius * 0.2, -radius * 0.7, radius * 0.9, 0, radius * 0.4)
      ..close();
    canvas.drawPath(leftTopWing, wingPaint);
    canvas.drawPath(leftTopWing, strokePaint);
    canvas.drawPath(leftBottomWing, wingPaint);
    canvas.drawPath(leftBottomWing, strokePaint);
    canvas.restore();

    // Right wings
    canvas.save();
    canvas.scale(-wingScaleX, 1.0);
    final rightTopWing = Path()
      ..moveTo(0, 0)
      ..cubicTo(-radius * 0.8, -radius * 1.1, -radius * 1.2, -radius * 0.4, 0, radius * 0.1)
      ..close();
    final rightBottomWing = Path()
      ..moveTo(0, 0)
      ..cubicTo(-radius * 0.9, radius * 0.2, -radius * 0.7, radius * 0.9, 0, radius * 0.4)
      ..close();
    canvas.drawPath(rightTopWing, wingPaint);
    canvas.drawPath(rightTopWing, strokePaint);
    canvas.drawPath(rightBottomWing, wingPaint);
    canvas.drawPath(rightBottomWing, strokePaint);
    canvas.restore();

    // Body
    final bodyPaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: 3, height: radius * 0.8), const Radius.circular(2)),
      bodyPaint,
    );

    canvas.restore();
  }

  // ---------------------------------------------------------------------------
  // 2. Bunny Ears (Screenshot 4: Fluffy bunny ears + blush)
  // ---------------------------------------------------------------------------
  void _drawBunnyEars(Canvas canvas, Size size) {
    final headTopX = size.width * 0.5;
    final headTopY = size.height * 0.16;
    final earWidth = size.width * 0.13;
    final earHeight = size.height * 0.15;
    final bob = math.sin(progress * 4 * math.pi) * 4;

    // Left ear
    _paintBunnyEar(
      canvas: canvas,
      base: Offset(headTopX - size.width * 0.18, headTopY + bob),
      width: earWidth,
      height: earHeight,
      tilt: -0.18,
    );

    // Right ear
    _paintBunnyEar(
      canvas: canvas,
      base: Offset(headTopX + size.width * 0.18, headTopY + bob),
      width: earWidth,
      height: earHeight,
      tilt: 0.18,
    );

    // Headband connection curve
    final bandPaint = Paint()
      ..color = const Color(0xFFC7B6FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final bandPath = Path()
      ..moveTo(headTopX - size.width * 0.22, headTopY + earHeight * 0.85 + bob)
      ..quadraticBezierTo(
        headTopX,
        headTopY + earHeight * 0.72 + bob,
        headTopX + size.width * 0.22,
        headTopY + earHeight * 0.85 + bob,
      );
    canvas.drawPath(bandPath, bandPaint);

    // Cheek blush
    final blushPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0x66FF2DC0),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: size.width * 0.12));

    canvas.save();
    canvas.translate(headTopX - size.width * 0.24, size.height * 0.40);
    canvas.drawCircle(Offset.zero, size.width * 0.12, blushPaint);
    canvas.restore();

    canvas.save();
    canvas.translate(headTopX + size.width * 0.24, size.height * 0.40);
    canvas.drawCircle(Offset.zero, size.width * 0.12, blushPaint);
    canvas.restore();

    // Sparkles around head
    final sparkleOffsets = [
      Offset(headTopX - size.width * 0.32, headTopY + 20),
      Offset(headTopX + size.width * 0.30, headTopY + 10),
      Offset(headTopX, headTopY - 20),
    ];
    for (final sp in sparkleOffsets) {
      _drawSparkle(canvas, sp, 8, const Color(0xFFBBE5FF));
    }
  }

  void _paintBunnyEar({
    required Canvas canvas,
    required Offset base,
    required double width,
    required double height,
    required double tilt,
  }) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.rotate(tilt);

    // Outer fluffy ear
    final outerPaint = Paint()
      ..color = const Color(0xFFECE6FF)
      ..style = PaintingStyle.fill;
    final outerShadow = Paint()
      ..color = const Color(0x668E70FF)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final earPath = Path()
      ..moveTo(-width * 0.5, height)
      ..cubicTo(-width * 0.8, height * 0.3, -width * 0.6, -height * 0.2, 0, -height)
      ..cubicTo(width * 0.6, -height * 0.2, width * 0.8, height * 0.3, width * 0.5, height)
      ..close();

    canvas.drawPath(earPath, outerShadow);
    canvas.drawPath(earPath, outerPaint);

    // Inner pink ear
    final innerPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFF8AE6), Color(0xFFFF2DC0)],
      ).createShader(Rect.fromLTWH(-width * 0.3, -height * 0.8, width * 0.6, height * 1.6));

    final innerPath = Path()
      ..moveTo(-width * 0.3, height * 0.8)
      ..cubicTo(-width * 0.5, height * 0.2, -width * 0.4, -height * 0.1, 0, -height * 0.75)
      ..cubicTo(width * 0.4, -height * 0.1, width * 0.5, height * 0.2, width * 0.3, height * 0.8)
      ..close();

    canvas.drawPath(innerPath, innerPaint);

    canvas.restore();
  }

  // ---------------------------------------------------------------------------
  // 3. Floating Neon Hearts
  // ---------------------------------------------------------------------------
  void _drawHearts(Canvas canvas, Size size) {
    final heartCount = 7;
    for (int i = 0; i < heartCount; i++) {
      final t = (progress + (i / heartCount)) % 1.0;
      final y = size.height * (0.85 - t * 0.65);
      final x = size.width * (0.2 + (i * 0.11) + math.sin(t * 4 * math.pi + i) * 0.05);
      final scale = (math.sin(t * math.pi) * 0.8 + 0.4).clamp(0.0, 1.2);
      final alpha = (math.sin(t * math.pi) * 255).clamp(0, 255).toInt();

      _drawHeart(canvas, Offset(x, y), 18 * scale, Color(0xFFFF2D55).withAlpha(alpha));
    }

    // Warm pink rim glow
    final rimPaint = Paint()
      ..shader = RadialGradient(
        radius: 0.9,
        colors: [Colors.transparent, const Color(0x33FF2D55), const Color(0x55C04DFF)],
        stops: const [0.65, 0.88, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), rimPaint);
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final glow = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final path = Path();
    path.moveTo(center.dx, center.dy + size * 0.3);
    path.cubicTo(center.dx - size, center.dy - size * 0.4, center.dx - size * 0.5, center.dy - size * 0.9, center.dx, center.dy - size * 0.4);
    path.cubicTo(center.dx + size * 0.5, center.dy - size * 0.9, center.dx + size, center.dy - size * 0.4, center.dx, center.dy + size * 0.3);
    path.close();

    canvas.drawPath(path, glow);
    canvas.drawPath(path, paint);
  }

  // ---------------------------------------------------------------------------
  // 4. Galaxy Stars & Stardust
  // ---------------------------------------------------------------------------
  void _drawGalaxy(Canvas canvas, Size size) {
    // Deep space cosmic vignette
    final vignette = Paint()
      ..shader = RadialGradient(
        radius: 0.85,
        colors: [
          Colors.transparent,
          const Color(0x4400E5FF),
          const Color(0x773D1E8C),
        ],
        stops: const [0.55, 0.82, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), vignette);

    // Starlight particles
    final stars = [
      Offset(size.width * 0.15, size.height * 0.22),
      Offset(size.width * 0.82, size.height * 0.18),
      Offset(size.width * 0.28, size.height * 0.12),
      Offset(size.width * 0.72, size.height * 0.35),
      Offset(size.width * 0.12, size.height * 0.45),
      Offset(size.width * 0.88, size.height * 0.48),
      Offset(size.width * 0.50, size.height * 0.10),
    ];

    for (int i = 0; i < stars.length; i++) {
      final pulse = (math.sin(progress * 6 * math.pi + i) * 0.5 + 0.5);
      final starColor = i.isEven ? const Color(0xFF00F0FF) : const Color(0xFFFFD600);
      _drawSparkle(canvas, stars[i], 10 * pulse + 4, starColor);
    }
  }

  // ---------------------------------------------------------------------------
  // 5. Natural Glow
  // ---------------------------------------------------------------------------
  void _drawNaturalGlow(Canvas canvas, Size size) {
    final auraPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.75,
        colors: [
          const Color(0x22FFD700),
          const Color(0x11FF6FD8),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), auraPaint);

    final sparklePulse = math.sin(progress * 4 * math.pi) * 0.4 + 0.6;
    _drawSparkle(canvas, Offset(size.width * 0.2, size.height * 0.25), 9 * sparklePulse, const Color(0xFFFFEFA8));
    _drawSparkle(canvas, Offset(size.width * 0.78, size.height * 0.28), 11 * sparklePulse, const Color(0xFFFFD600));
  }

  // ---------------------------------------------------------------------------
  // 6. Cat Anime Ears
  // ---------------------------------------------------------------------------
  void _drawCatAnime(Canvas canvas, Size size) {
    final headTopX = size.width * 0.5;
    final headTopY = size.height * 0.18;
    final earSize = size.width * 0.18;

    // Left Cat Ear
    _paintCatEar(canvas, Offset(headTopX - size.width * 0.20, headTopY), earSize, -0.2);
    // Right Cat Ear
    _paintCatEar(canvas, Offset(headTopX + size.width * 0.20, headTopY), earSize, 0.2);

    // Whiskers
    final whiskerPaint = Paint()
      ..color = const Color(0xCCFF7AD9)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // Left whiskers
    canvas.drawLine(Offset(size.width * 0.24, size.height * 0.42), Offset(size.width * 0.08, size.height * 0.40), whiskerPaint);
    canvas.drawLine(Offset(size.width * 0.24, size.height * 0.44), Offset(size.width * 0.07, size.height * 0.44), whiskerPaint);
    // Right whiskers
    canvas.drawLine(Offset(size.width * 0.76, size.height * 0.42), Offset(size.width * 0.92, size.height * 0.40), whiskerPaint);
    canvas.drawLine(Offset(size.width * 0.76, size.height * 0.44), Offset(size.width * 0.93, size.height * 0.44), whiskerPaint);
  }

  void _paintCatEar(Canvas canvas, Offset center, double size, double angle) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final outerPath = Path()
      ..moveTo(-size * 0.5, size * 0.5)
      ..lineTo(0, -size * 0.8)
      ..lineTo(size * 0.5, size * 0.5)
      ..close();

    final outerPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF261D52), Color(0xFF6B4BFF)],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: size));
    canvas.drawPath(outerPath, outerPaint);

    final innerPath = Path()
      ..moveTo(-size * 0.3, size * 0.4)
      ..lineTo(0, -size * 0.5)
      ..lineTo(size * 0.3, size * 0.4)
      ..close();

    final innerPaint = Paint()..color = const Color(0xFFFF2DC0);
    canvas.drawPath(innerPath, innerPaint);

    canvas.restore();
  }

  // ---------------------------------------------------------------------------
  // 7. Dog Ears & Nose
  // ---------------------------------------------------------------------------
  void _drawDog(Canvas canvas, Size size) {
    final headTopX = size.width * 0.5;
    final headTopY = size.height * 0.18;
    final earHeight = size.height * 0.18;
    final droop = math.sin(progress * 4 * math.pi) * 3;

    final dogEarPaint = Paint()
      ..color = const Color(0xFFC7844E)
      ..style = PaintingStyle.fill;

    // Left floppy ear
    final leftEar = Path()
      ..moveTo(headTopX - size.width * 0.18, headTopY)
      ..cubicTo(headTopX - size.width * 0.38, headTopY + earHeight * 0.4 + droop, headTopX - size.width * 0.34, headTopY + earHeight + droop, headTopX - size.width * 0.20, headTopY + earHeight + droop)
      ..cubicTo(headTopX - size.width * 0.14, headTopY + earHeight * 0.6, headTopX - size.width * 0.14, headTopY, headTopX - size.width * 0.18, headTopY)
      ..close();
    canvas.drawPath(leftEar, dogEarPaint);

    // Right floppy ear
    final rightEar = Path()
      ..moveTo(headTopX + size.width * 0.18, headTopY)
      ..cubicTo(headTopX + size.width * 0.38, headTopY + earHeight * 0.4 + droop, headTopX + size.width * 0.34, headTopY + earHeight + droop, headTopX + size.width * 0.20, headTopY + earHeight + droop)
      ..cubicTo(headTopX + size.width * 0.14, headTopY + earHeight * 0.6, headTopX + size.width * 0.14, headTopY, headTopX + size.width * 0.18, headTopY)
      ..close();
    canvas.drawPath(rightEar, dogEarPaint);

    // Cute nose button
    final noseCenter = Offset(headTopX, size.height * 0.44);
    final nosePaint = Paint()..color = const Color(0xFF231C18);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: noseCenter, width: 22, height: 16), const Radius.circular(8)), nosePaint);
  }

  // ---------------------------------------------------------------------------
  // 8. Vintage Cinema Frame
  // ---------------------------------------------------------------------------
  void _drawVintage(Canvas canvas, Size size) {
    final sepia = Paint()
      ..color = const Color(0x33FFB300)
      ..blendMode = BlendMode.color;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), sepia);

    final vignette = Paint()
      ..shader = RadialGradient(
        radius: 0.85,
        colors: [Colors.transparent, const Color(0x992B1500)],
        stops: const [0.65, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), vignette);
  }

  // ---------------------------------------------------------------------------
  // 9. Angel Halo
  // ---------------------------------------------------------------------------
  void _drawAngelHalo(Canvas canvas, Size size) {
    final headCenterX = size.width * 0.5;
    final haloCenterY = size.height * 0.12 + math.sin(progress * 2 * math.pi) * 6;
    final haloWidth = size.width * 0.38;
    final haloHeight = 22.0;

    final glowPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.6)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawOval(Rect.fromCenter(center: Offset(headCenterX, haloCenterY), width: haloWidth, height: haloHeight), glowPaint);

    final ringPaint = Paint()
      ..shader = const LinearGradient(colors: [Color(0xFFFFF9D2), Color(0xFFFFD600), Color(0xFFFFF4C2)])
          .createShader(Rect.fromCenter(center: Offset(headCenterX, haloCenterY), width: haloWidth, height: haloHeight))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0;
    canvas.drawOval(Rect.fromCenter(center: Offset(headCenterX, haloCenterY), width: haloWidth, height: haloHeight), ringPaint);
  }

  // ---------------------------------------------------------------------------
  // 10. Cyber Glasses
  // ---------------------------------------------------------------------------
  void _drawCyberGlasses(Canvas canvas, Size size) {
    final eyeCenterX = size.width * 0.5;
    final eyeCenterY = size.height * 0.36;
    final glassW = size.width * 0.28;
    final glassH = 34.0;

    final cyanNeon = Paint()
      ..color = const Color(0xFF00F0FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final glow = Paint()
      ..color = const Color(0xFF00F0FF).withValues(alpha: 0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final leftRect = Rect.fromCenter(center: Offset(eyeCenterX - glassW * 0.6, eyeCenterY), width: glassW, height: glassH);
    final rightRect = Rect.fromCenter(center: Offset(eyeCenterX + glassW * 0.6, eyeCenterY), width: glassW, height: glassH);

    canvas.drawRRect(RRect.fromRectAndRadius(leftRect, const Radius.circular(8)), glow);
    canvas.drawRRect(RRect.fromRectAndRadius(leftRect, const Radius.circular(8)), cyanNeon);

    canvas.drawRRect(RRect.fromRectAndRadius(rightRect, const Radius.circular(8)), glow);
    canvas.drawRRect(RRect.fromRectAndRadius(rightRect, const Radius.circular(8)), cyanNeon);

    // Bridge
    canvas.drawLine(Offset(eyeCenterX - glassW * 0.1, eyeCenterY), Offset(eyeCenterX + glassW * 0.1, eyeCenterY), cyanNeon);
  }

  // ---------------------------------------------------------------------------
  // Sparkle Helper
  // ---------------------------------------------------------------------------
  void _drawSparkle(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.8;

    canvas.drawLine(Offset(center.dx - size, center.dy), Offset(center.dx + size, center.dy), paint);
    canvas.drawLine(Offset(center.dx, center.dy - size), Offset(center.dx, center.dy + size), paint);
    canvas.drawCircle(center, size * 0.25, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _FilterPainter old) =>
      old.filter.id != filter.id || old.progress != progress;
}
