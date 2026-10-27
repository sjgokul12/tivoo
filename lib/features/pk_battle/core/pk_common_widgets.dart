// Small widgets shared across the PK battle screen.

import 'dart:math';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

/// Vector gold crown with jewelled tips and a blue gem (names, score bar).
class PkGoldCrown extends StatelessWidget {
  final double size;
  const PkGoldCrown({super.key, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.82,
      child: CustomPaint(painter: _GoldCrownPainter()),
    );
  }
}

class _GoldCrownPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final gold = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFF6C2), Color(0xFFFFCC33), Color(0xFFE08A00)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);

    final body = Path()
      ..moveTo(w * 0.06, h * 0.86)
      ..lineTo(0, h * 0.3)
      ..lineTo(w * 0.28, h * 0.55)
      ..lineTo(w * 0.5, h * 0.14)
      ..lineTo(w * 0.72, h * 0.55)
      ..lineTo(w, h * 0.3)
      ..lineTo(w * 0.94, h * 0.86)
      ..close();
    if (w > 18) {
      canvas.drawPath(
        body,
        Paint()
          ..color = const Color(0x99FFB300)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.08),
      );
    }
    canvas.drawPath(body, gold);
    canvas.drawPath(
      body,
      Paint()
        ..color = const Color(0xFFB36B00)
        ..style = PaintingStyle.stroke
        ..strokeWidth = max(0.6, w * 0.025),
    );

    // Band and jewelled tips.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.04, h * 0.8, w * 0.92, h * 0.18), Radius.circular(h * 0.06)),
      gold,
    );
    final tip = Paint()..color = const Color(0xFFFFE27A);
    for (final p in [Offset(0, h * 0.27), Offset(w * 0.5, h * 0.1), Offset(w, h * 0.27)]) {
      canvas.drawCircle(p, w * 0.075, tip);
    }
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.5, h * 0.48)
        ..lineTo(w * 0.57, h * 0.6)
        ..lineTo(w * 0.5, h * 0.72)
        ..lineTo(w * 0.43, h * 0.6)
        ..close(),
      Paint()..color = const Color(0xFF2E7BFF),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Icon filled with a vertical gradient (Like / Share buttons).
class PkGradientIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final List<Color> colors;

  const PkGradientIcon(this.icon, {super.key, required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      ).createShader,
      child: Icon(icon, size: size, color: Colors.white),
    );
  }
}

/// Frosted-glass surface: blurs what's behind it, adds a translucent tint, a neon
/// gradient border with glow and a thin white highlight along the top edge.
class PkGlass extends StatelessWidget {
  final Widget child;
  final double radius;
  final List<Color> border;
  final double borderWidth;
  final Color tint;
  final double blur;
  final double glow;
  final EdgeInsetsGeometry padding;
  final double? height;

  const PkGlass({
    super.key,
    required this.child,
    this.radius = 24,
    this.border = const [Color(0xFF3D9BFF), Color(0xFFB04DFF), Color(0xFF3D7BFF)],
    this.borderWidth = 1.5,
    this.tint = const Color(0xFF140F50),
    this.blur = 14,
    this.glow = 14,
    this.padding = EdgeInsets.zero,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final inner = BorderRadius.circular(radius - borderWidth);
    return Container(
      height: height,
      padding: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(colors: border),
        boxShadow: glow > 0
            ? [BoxShadow(color: border[border.length ~/ 2].withValues(alpha: 0.55), blurRadius: glow)]
            : null,
      ),
      child: ClipRRect(
        borderRadius: inner,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: inner,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.lerp(tint, Colors.white, 0.12)!.withValues(alpha: 0.62),
                  tint.withValues(alpha: 0.55),
                  tint.withValues(alpha: 0.72),
                ],
                stops: const [0, 0.4, 1],
              ),
            ),
            child: DecoratedBox(
              // Glass sheen: a soft white highlight across the top.
              decoration: BoxDecoration(
                borderRadius: inner,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white.withValues(alpha: 0.14), Colors.white.withValues(alpha: 0)],
                  stops: const [0, 0.45],
                ),
              ),
              child: Padding(padding: padding, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

/// Four-point twinkle star, used for sparkles around the gift portal and on the seam.
void paintSparkle(Canvas canvas, Offset c, double r, Color color) {
  final path = Path()
    ..moveTo(c.dx, c.dy - r)
    ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
    ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
    ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
    ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
    ..close();
  canvas.drawPath(
    path,
    Paint()
      ..color = color.withValues(alpha: 0.6)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.5),
  );
  canvas.drawPath(path, Paint()..color = color);
}

/// Deep indigo page background with magenta (top-left) and blue (top-right) glows, light rays and streaks.
class PkBackdrop extends StatelessWidget {
  const PkBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF26106A), Color(0xFF16137A), Color(0xFF100E5C), Color(0xFF0A0A3E)],
          stops: [0, 0.35, 0.7, 1],
        ),
      ),
      child: CustomPaint(painter: _BackdropGlowPainter(), size: Size.infinite),
    );
  }
}

class _BackdropGlowPainter extends CustomPainter {
  const _BackdropGlowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    void glow(Offset center, double radius, Color color) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..shader = RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ).createShader(Rect.fromCircle(center: center, radius: radius)),
      );
    }

    final w = size.width;
    glow(Offset(w * 0.05, size.height * 0.08), w * 0.7, const Color(0x99B42BE6));
    glow(Offset(w * 0.95, size.height * 0.08), w * 0.7, const Color(0x992E6BFF));
    glow(Offset(w * 0.5, 0), w * 0.4, const Color(0x55FFFFFF));
    glow(Offset(w * 0.1, size.height * 0.8), w * 0.6, const Color(0x33FF2DB4));
    glow(Offset(w * 0.9, size.height * 0.85), w * 0.6, const Color(0x442E6BFF));

    // Thin diagonal light streaks.
    final streak = Paint()
      ..strokeWidth = 1.2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
    for (final (x0, color) in [
      (0.05, const Color(0x55FF7AE0)),
      (0.35, const Color(0x33B38CFF)),
      (0.7, const Color(0x447FC4FF)),
      (0.95, const Color(0x553DA9FF)),
    ]) {
      streak.color = color;
      canvas.drawLine(Offset(w * x0, 0), Offset(w * x0 - w * 0.6, size.height * 0.45), streak);
    }

    // Soft light rays fanning down from the top centre.
    final rays = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    for (var i = -3; i <= 3; i++) {
      final dx = i * w * 0.16;
      rays.color = (i < 0 ? const Color(0xFFFF4FD8) : const Color(0xFF4F8BFF)).withValues(alpha: 0.12);
      canvas.drawPath(
        Path()
          ..moveTo(w * 0.5 - 6, 0)
          ..lineTo(w * 0.5 + 6, 0)
          ..lineTo(w * 0.5 + dx + 30, size.height * 0.32)
          ..lineTo(w * 0.5 + dx - 30, size.height * 0.32)
          ..close(),
        rays,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
