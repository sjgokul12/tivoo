import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Neon ribbons hugging a box's bottom corners, with a comet of light
/// travelling along each one. Repaints via the painter's listenable only.
class NeonRibbons extends StatefulWidget {
  const NeonRibbons({super.key, this.flares = false});

  /// Adds pulsing lens-flare sparkles along the top edge.
  final bool flares;

  @override
  State<NeonRibbons> createState() => _NeonRibbonsState();
}

class _NeonRibbonsState extends State<NeonRibbons> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(child: CustomPaint(painter: _RibbonsPainter(_controller, flares: widget.flares))),
    );
  }
}

class _RibbonsPainter extends CustomPainter {
  _RibbonsPainter(this.progress, {required this.flares}) : super(repaint: progress);

  final Animation<double> progress;
  final bool flares;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    void ribbon(Path path, List<Color> colors, double width, double phase) {
      final shader = LinearGradient(colors: colors).createShader(rect);
      canvas
        ..drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = width * 5
            ..shader = shader
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
        )
        ..drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = width
            ..strokeCap = StrokeCap.round
            ..shader = shader,
        );

      // Comet travelling along the ribbon.
      final metric = path.computeMetrics().first;
      final t = (progress.value + phase) % 1.0;
      final tangent = metric.getTangentForOffset(metric.length * t);
      if (tangent == null) return;
      final fade = math.sin(t * math.pi); // fades in and out at the ends
      final c = tangent.position;
      canvas
        ..drawCircle(
          c,
          12,
          Paint()
            ..shader = RadialGradient(
              colors: [colors[colors.length ~/ 2].withValues(alpha: 0.9 * fade), const Color(0x00FFFFFF)],
            ).createShader(Rect.fromCircle(center: c, radius: 12)),
        )
        ..drawCircle(c, 2.2, Paint()..color = Colors.white.withValues(alpha: fade));
    }

    // Pink / purple ribbon wrapping the bottom-left corner.
    ribbon(
      Path()
        ..moveTo(-2, h * 0.42)
        ..cubicTo(-4, h * 0.82, w * 0.06, h + 2, w * 0.3, h + 1),
      const [Color(0xFF8B5CF6), Color(0xFFFF4FB0), Color(0x00FF4FB0)],
      1.8,
      0,
    );
    // Gold ribbon wrapping the bottom-right corner.
    ribbon(
      Path()
        ..moveTo(w * 0.6, h + 1)
        ..cubicTo(w * 0.86, h + 2, w + 3, h * 0.9, w + 2, h * 0.5),
      const [Color(0x00FFC83D), Color(0xFFFFC83D), Color(0xFFFFF0A8)],
      1.8,
      0.5,
    );
    // Thin light line along the bottom edge.
    canvas.drawLine(
      Offset(w * 0.12, h),
      Offset(w * 0.88, h),
      Paint()
        ..strokeWidth = 1
        ..shader = const LinearGradient(
          colors: [Color(0x00FF4FB0), Color(0x99FFFFFF), Color(0x00FFC83D)],
        ).createShader(rect),
    );

    if (!flares) return;

    // Lens-flare sparkles on the top edge.
    for (final (dx, r, color) in const [
      (0.83, 16.0, Color(0xCCFFC83D)),
      (0.62, 9.0, Color(0x99FF8AD8)),
    ]) {
      final c = Offset(w * dx, 0);
      final pulse = 0.75 + 0.25 * math.sin(progress.value * 2 * math.pi + dx * 10);
      canvas
        ..drawCircle(
          c,
          r * pulse,
          Paint()
            ..shader = RadialGradient(colors: [color, color.withValues(alpha: 0)])
                .createShader(Rect.fromCircle(center: c, radius: r)),
        )
        ..drawCircle(c, 1.8, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_RibbonsPainter oldDelegate) => false;
}
