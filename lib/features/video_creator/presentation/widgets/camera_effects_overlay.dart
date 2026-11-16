import 'dart:math' as math;
import 'package:flutter/material.dart';

class CameraEffectsOverlay extends StatefulWidget {
  final String? activeEffectId;

  const CameraEffectsOverlay({super.key, this.activeEffectId});

  @override
  State<CameraEffectsOverlay> createState() => _CameraEffectsOverlayState();
}

class _CameraEffectsOverlayState extends State<CameraEffectsOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effect = widget.activeEffectId;
    if (effect == null || effect == 'none') return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _EffectPainter(effect: effect, progress: _anim.value),
        );
      },
    );
  }
}

class _EffectPainter extends CustomPainter {
  final String effect;
  final double progress;

  _EffectPainter({required this.effect, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    switch (effect) {
      case 'sparkles':
        _paintSparkles(canvas, size);
        break;
      case 'light_leak':
        _paintLightLeak(canvas, size);
        break;
      case 'bokeh_hearts':
        _paintBokehHearts(canvas, size);
        break;
      case 'neon_aura':
        _paintNeonAura(canvas, size);
        break;
      case 'film_grain':
        _paintFilmGrain(canvas, size);
        break;
      case 'glitch_vhs':
        _paintGlitchVhs(canvas, size);
        break;
      case 'stardust':
        _paintStardust(canvas, size);
        break;
    }
  }

  void _paintSparkles(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final sparkles = [
      (0.2, 0.25, 14.0, const Color(0xFFFFD700)),
      (0.8, 0.35, 18.0, const Color(0xFFFF2DC0)),
      (0.35, 0.55, 12.0, Colors.white),
      (0.7, 0.68, 16.0, const Color(0xFFFFE600)),
      (0.15, 0.75, 10.0, const Color(0xFFC04DFF)),
      (0.85, 0.18, 14.0, Colors.white),
      (0.5, 0.3, 11.0, const Color(0xFFFF69B4)),
    ];

    for (int i = 0; i < sparkles.length; i++) {
      final (xR, yR, baseSize, color) = sparkles[i];
      final wave = (math.sin((progress * 2 * math.pi) + (i * 1.2)) + 1) / 2;
      final opacity = (0.2 + 0.8 * wave).clamp(0.0, 1.0);
      final currentSize = baseSize * (0.6 + 0.6 * wave);

      final cx = xR * size.width;
      final cy = yR * size.height;

      paint.color = color.withValues(alpha: opacity);
      _drawStar(canvas, cx, cy, currentSize, paint);
    }
  }

  void _drawStar(Canvas canvas, double cx, double cy, double r, Paint paint) {
    final path = Path();
    path.moveTo(cx, cy - r);
    path.quadraticBezierTo(cx, cy, cx + r, cy);
    path.quadraticBezierTo(cx, cy, cx, cy + r);
    path.quadraticBezierTo(cx, cy, cx - r, cy);
    path.quadraticBezierTo(cx, cy, cx, cy - r);
    canvas.drawPath(path, paint);

    // Center glow dot
    canvas.drawCircle(Offset(cx, cy), r * 0.2, paint..color = Colors.white);
  }

  void _paintLightLeak(Canvas canvas, Size size) {
    final wave = (math.sin(progress * 2 * math.pi) + 1) / 2;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final paint1 = Paint()
      ..shader = RadialGradient(
        center: Alignment(-0.8 + 0.2 * wave, -0.7),
        radius: 1.1,
        colors: [
          const Color(0x66FF8A00),
          const Color(0x33FF007F),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect);

    canvas.drawRect(rect, paint1);
  }

  void _paintBokehHearts(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final hearts = [
      (0.25, 0.4, 22.0, const Color(0x66FF2DC0)),
      (0.75, 0.3, 28.0, const Color(0x55E040FB)),
      (0.5, 0.65, 32.0, const Color(0x55FF4081)),
      (0.2, 0.7, 18.0, const Color(0x66FF80AB)),
      (0.8, 0.6, 24.0, const Color(0x66EA80FC)),
    ];

    for (int i = 0; i < hearts.length; i++) {
      final (xR, yR, baseSize, color) = hearts[i];
      final wave = (math.sin((progress * 2 * math.pi) + (i * 1.5)) + 1) / 2;
      final cx = xR * size.width;
      final cy = (yR * size.height) - (wave * 30);
      final r = baseSize * (0.8 + 0.3 * wave);

      paint.color = color;
      _drawHeart(canvas, cx, cy, r, paint);
    }
  }

  void _drawHeart(Canvas canvas, double cx, double cy, double size, Paint paint) {
    final path = Path();
    path.moveTo(cx, cy + size * 0.35);
    path.cubicTo(
      cx - size * 0.55, cy - size * 0.35,
      cx - size * 0.55, cy - size * 0.75,
      cx, cy - size * 0.45,
    );
    path.cubicTo(
      cx + size * 0.55, cy - size * 0.75,
      cx + size * 0.55, cy - size * 0.35,
      cx, cy + size * 0.35,
    );
    canvas.drawPath(path, paint);
  }

  void _paintNeonAura(Canvas canvas, Size size) {
    final wave = (math.sin(progress * 2 * math.pi) + 1) / 2;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20)
      ..shader = LinearGradient(
        colors: [
          Color.lerp(const Color(0x99FF2DC0), const Color(0x997B1FA2), wave)!,
          Color.lerp(const Color(0x9900E5FF), const Color(0x99FF007F), 1 - wave)!,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);

    canvas.drawRect(rect, paint);
  }

  void _paintFilmGrain(Canvas canvas, Size size) {
    // Subtle vignette + warm retro cast
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final vignette = Paint()
      ..shader = const RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [Colors.transparent, Color(0x66000000)],
        stops: [0.65, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, vignette);
  }

  void _paintGlitchVhs(Canvas canvas, Size size) {
    // VHS scanlines and bottom timestamp
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (double y = 0; y < size.height; y += 8) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _paintStardust(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final random = math.Random(42);

    for (int i = 0; i < 40; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final wave = (math.sin((progress * 2 * math.pi) + (i * 0.8)) + 1) / 2;
      final r = 1.0 + 2.0 * wave;
      paint.color = Colors.white.withValues(alpha: (0.15 + 0.65 * wave).clamp(0.0, 1.0));
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _EffectPainter oldDelegate) => true;
}

