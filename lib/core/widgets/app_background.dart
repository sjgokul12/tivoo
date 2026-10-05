import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Near-black background with neon blue/purple/pink glows, gold light
/// streaks and slowly drifting gold bokeh. The static layer is painted once;
/// the bokeh repaints on its own layer via the painter's `repaint` listenable,
/// so no widgets rebuild and scrolling content is never repainted.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const RepaintBoundary(
          child: DecoratedBox(
            decoration: BoxDecoration(color: AppColors.background),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _Glow(alignment: Alignment(-1.2, -1.0), color: Color(0x4D2436B8)),
                _Glow(alignment: Alignment(1.3, -0.5), color: Color(0x338A1FE0)),
                _Glow(alignment: Alignment(-1.3, 0.35), color: Color(0x261D4ED8)),
                _Glow(alignment: Alignment(1.2, 0.7), color: Color(0x26FF3FA4)),
                _Glow(alignment: Alignment(0, 1.35), color: Color(0x33FFB020), radius: 0.7),
                CustomPaint(painter: _LightBeamsPainter()),
                CustomPaint(painter: _GoldStreaksPainter()),
              ],
            ),
          ),
        ),
        const RepaintBoundary(child: _DriftingBokeh()),
        child,
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.alignment, required this.color, this.radius = 0.9});

  final Alignment alignment;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: alignment,
          radius: radius,
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}

/// Soft diagonal stage-light beams across the top of the screen.
class _LightBeamsPainter extends CustomPainter {
  const _LightBeamsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height * 0.45;
    for (final (x, width, color) in const [
      (0.18, 0.16, Color(0x1F4F7CFF)),
      (0.42, 0.10, Color(0x14B44CFF)),
      (0.7, 0.18, Color(0x1A4F7CFF)),
    ]) {
      final beam = Path()
        ..moveTo(w * (x + 0.12), 0)
        ..lineTo(w * (x + 0.12 + width), 0)
        ..lineTo(w * (x - 0.1 + width * 1.6), h)
        ..lineTo(w * (x - 0.1), h)
        ..close();
      canvas.drawPath(
        beam,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color, color.withValues(alpha: 0)],
          ).createShader(Rect.fromLTWH(0, 0, w, h))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );
    }
  }

  @override
  bool shouldRepaint(_LightBeamsPainter oldDelegate) => false;
}

/// Warm diagonal gold light trails (top-right and lower-left).
class _GoldStreaksPainter extends CustomPainter {
  const _GoldStreaksPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    for (final (start, end, width, alpha) in const [
      (Offset(1.05, 0.0), Offset(0.62, 0.2), 26.0, 0x30),
      (Offset(1.1, 0.12), Offset(0.75, 0.3), 12.0, 0x24),
      (Offset(-0.05, 0.62), Offset(0.3, 0.48), 18.0, 0x1C),
    ]) {
      final a = Offset(start.dx * w, start.dy * h);
      final b = Offset(end.dx * w, end.dy * h);
      canvas.drawLine(
        a,
        b,
        Paint()
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..shader = LinearGradient(
            colors: [Color.fromARGB(alpha, 0xFF, 0xC8, 0x3D), const Color(0x00FFC83D)],
          ).createShader(Rect.fromPoints(a, b))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
      );
    }
  }

  @override
  bool shouldRepaint(_GoldStreaksPainter oldDelegate) => false;
}

/// Soft gold / pink bokeh dots rising slowly.
class _DriftingBokeh extends StatefulWidget {
  const _DriftingBokeh();

  @override
  State<_DriftingBokeh> createState() => _DriftingBokehState();
}

class _DriftingBokehState extends State<_DriftingBokeh> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 28),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: CustomPaint(painter: _BokehPainter(_controller), size: Size.infinite));
  }
}

class _BokehPainter extends CustomPainter {
  _BokehPainter(this.progress) : super(repaint: progress);

  final Animation<double> progress;

  // (x, startY, radius, speed, color)
  static const _particles = [
    (0.12, 0.15, 22.0, 1.0, Color(0x40FFC83D)),
    (0.82, 0.32, 30.0, 0.7, Color(0x38FFB020)),
    (0.55, 0.62, 16.0, 1.3, Color(0x33FF4FB0)),
    (0.3, 0.85, 26.0, 0.8, Color(0x30FFC83D)),
    (0.92, 0.75, 14.0, 1.6, Color(0x40FFE680)),
    (0.65, 0.05, 20.0, 0.9, Color(0x2EB44CFF)),
    (0.05, 0.45, 12.0, 1.4, Color(0x38FFC83D)),
    (0.42, 0.3, 10.0, 1.8, Color(0x40FFE680)),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    for (final (x, y0, r, speed, color) in _particles) {
      final y = (y0 - t * speed) % 1.0;
      final sway = math.sin((t * speed + x) * 2 * math.pi) * 14;
      final c = Offset(x * size.width + sway, y * size.height);
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(colors: [color, color.withValues(alpha: 0)])
              .createShader(Rect.fromCircle(center: c, radius: r)),
      );
    }
  }

  @override
  bool shouldRepaint(_BokehPainter oldDelegate) => false;
}
