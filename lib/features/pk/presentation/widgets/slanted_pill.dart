import 'package:flutter/material.dart';

/// Glass capsule rounded on its outer end and cut at an angle on the inner
/// end (towards the centre of the PK screen). [mirrored] flips it for the
/// right-hand side.
class SlantedPill extends StatelessWidget {
  const SlantedPill({
    super.key,
    required this.child,
    required this.color,
    required this.fill,
    this.mirrored = false,
    this.slant = 18,
    this.chevron = false,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;

  /// Neon rim / glow colour.
  final Color color;

  /// Body gradient, from the outer end to the inner end.
  final List<Color> fill;
  final bool mirrored;
  final double slant;

  /// Inner end comes to a point (">") instead of a single slanted cut.
  final bool chevron;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SlantedPillPainter(color: color, fill: fill, mirrored: mirrored, slant: slant, chevron: chevron),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _SlantedPillPainter extends CustomPainter {
  const _SlantedPillPainter({
    required this.color,
    required this.fill,
    required this.mirrored,
    required this.slant,
    required this.chevron,
  });

  final Color color;
  final List<Color> fill;
  final bool mirrored;
  final double slant;
  final bool chevron;

  Path _path(Size size) {
    final w = size.width;
    final h = size.height;
    final r = h / 2;
    final path = chevron
        ? (Path()
          ..moveTo(r, 0)
          ..lineTo(w - slant - 2, 0)
          ..quadraticBezierTo(w - slant + 2, 0, w - slant + 4, 3)
          ..lineTo(w - 1, h / 2 - 3)
          ..quadraticBezierTo(w, h / 2, w - 1, h / 2 + 3)
          ..lineTo(w - slant + 4, h - 3)
          ..quadraticBezierTo(w - slant + 2, h, w - slant - 2, h)
          ..lineTo(r, h)
          ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
          ..close())
        : (Path()
          ..moveTo(r, 0)
          ..lineTo(w - 4, 0)
          ..quadraticBezierTo(w, 0, w - 1.5, 4)
          ..lineTo(w - slant + 1.5, h - 4)
          ..quadraticBezierTo(w - slant - 1, h, w - slant - 5, h)
          ..lineTo(r, h)
          ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
          ..close());
    if (!mirrored) return path;
    return path.transform((Matrix4.identity()
          ..translateByDouble(w, 0, 0, 1)
          ..scaleByDouble(-1, 1, 1, 1))
        .storage);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = _path(size);
    final begin = mirrored ? Alignment.centerRight : Alignment.centerLeft;
    final end = mirrored ? Alignment.centerLeft : Alignment.centerRight;

    canvas
      // Outer neon glow.
      ..drawPath(
        path,
        Paint()
          ..color = color.withValues(alpha: 0.65)
          ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 10),
      )
      // Glass body.
      ..drawPath(path, Paint()..shader = LinearGradient(begin: begin, end: end, colors: fill).createShader(rect))
      // Top-lit gloss.
      ..drawPath(
        path,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0x40FFFFFF), Color(0x00FFFFFF), Color(0x26000000)],
            stops: [0, 0.5, 1],
          ).createShader(rect),
      )
      // Rim: bright at the outer end, fading inward.
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..shader = LinearGradient(
            begin: begin,
            end: end,
            colors: [color, Colors.white.withValues(alpha: 0.6), color.withValues(alpha: 0.5)],
          ).createShader(rect),
      );
  }

  @override
  bool shouldRepaint(_SlantedPillPainter old) =>
      old.color != color ||
      old.fill != fill ||
      old.mirrored != mirrored ||
      old.slant != slant ||
      old.chevron != chevron;
}
