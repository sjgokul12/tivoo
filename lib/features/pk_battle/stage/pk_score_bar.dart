// Pink vs blue clash score bar in a thick glossy gold frame.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// [ 19,020  ▬▬pink▬▬ ╱ ▬▬blue▬▬  16,640 ] in a glossy gold frame with a slanted
/// white junction. The pink / blue split follows the live scores.
class PkScoreBar extends StatelessWidget {
  final int leftScore;
  final int rightScore;

  const PkScoreBar({super.key, required this.leftScore, required this.rightScore});

  static final NumberFormat _format = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    final total = leftScore + rightScore;
    // Dynamic tug-of-war lead formula:
    // Instead of a static flat percentage where large base numbers drown out
    // incremental star gains, the score differential drives visible, responsive movement.
    final double ratio;
    if (total == 0) {
      ratio = 0.5;
    } else {
      final double diff = (leftScore - rightScore).toDouble();
      // Dynamic sensitivity scale adapts to battle magnitude so every gift produces visible motion
      final double scale = (total * 0.35).clamp(250.0, 2500.0);
      final double shift = (diff / scale).clamp(-1.0, 1.0) * 0.28;
      // Keep ratio within 0.22 to 0.78 so scores sit comfortably inside their color
      ratio = (0.50 + shift).clamp(0.22, 0.78);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isKeyboard = MediaQuery.viewInsetsOf(context).bottom > 50;
        final width = constraints.maxWidth - 20;
        final barH = isKeyboard ? (width * 0.08).clamp(30.0, 36.0) : (width * 0.10).clamp(34.0, 48.0);
        final scoreStyle = TextStyle(
          color: Colors.white,
          fontSize: barH * 0.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.3,
          shadows: const [Shadow(color: Color(0x99000000), blurRadius: 4, offset: Offset(0, 1.5))],
        );

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: isKeyboard ? 1.5 : 3),
          child: SizedBox(
            width: double.infinity,
            height: barH,
            child: Stack(
              children: [
                Positioned.fill(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: ratio.toDouble()),
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutCubic,
                    builder: (_, value, _) => CustomPaint(painter: _ScoreBarPainter(leftRatio: value)),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: barH * 0.5),
                    child: Row(
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded, color: Color(0xFFFFDF00), size: 17),
                                const SizedBox(width: 3),
                                Text(_format.format(leftScore), style: scoreStyle),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: barH * 0.4),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_format.format(rightScore), style: scoreStyle),
                                const SizedBox(width: 3),
                                const Icon(Icons.star_rounded, color: Color(0xFFFFDF00), size: 17),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ScoreBarPainter extends CustomPainter {
  final double leftRatio;

  _ScoreBarPainter({required this.leftRatio});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final frame = h * 0.11; // gold frame thickness
    final outer = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(h / 2));
    final inner = outer.deflate(frame);
    final cx = w * leftRatio;

    // Warm gold glow around the frame, pink / blue bloom underneath.
    canvas.drawRRect(
      outer.inflate(2),
      Paint()
        ..color = const Color(0xAAFFB300)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, h * 0.25),
    );
    canvas.drawRRect(
      outer,
      Paint()
        ..shader = const LinearGradient(colors: [Color(0x99FF2DB4), Color(0x992D6BFF)]).createShader(Offset.zero & size)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, h * 0.4),
    );

    // Glossy gold frame: bright top edge, deep amber bottom edge.
    canvas.drawRRect(
      outer,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF6C8), Color(0xFFFFC928), Color(0xFFE08A00), Color(0xFFFFD54A)],
          stops: [0, 0.35, 0.75, 1],
        ).createShader(Offset.zero & size),
    );

    canvas.save();
    canvas.clipRRect(inner);
    final innerRect = inner.outerRect;
    // Slanted junction: the pink side leans right at the top.
    final slant = h * 0.18;
    final pink = Path()
      ..moveTo(innerRect.left, innerRect.top)
      ..lineTo(cx + slant, innerRect.top)
      ..lineTo(cx - slant, innerRect.bottom)
      ..lineTo(innerRect.left, innerRect.bottom)
      ..close();
    canvas.drawRect(
      innerRect,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF1EA0FF), Color(0xFF2D7BFF), Color(0xFF2B4FE8)],
        ).createShader(innerRect),
    );
    canvas.drawPath(
      pink,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFE0158F), Color(0xFFFF2DB4), Color(0xFFFF4FC8)],
        ).createShader(innerRect),
    );
    // Top gloss.
    final gloss = Rect.fromLTWH(innerRect.left, innerRect.top, innerRect.width, innerRect.height * 0.5);
    canvas.drawRect(
      gloss,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withValues(alpha: 0.5), Colors.white.withValues(alpha: 0.06)],
        ).createShader(gloss),
    );
    // Glowing slanted white junction.
    final junction = Path()
      ..moveTo(cx + slant, innerRect.top)
      ..lineTo(cx - slant, innerRect.bottom);
    canvas.drawPath(
      junction,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.22
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, h * 0.18),
    );
    canvas.drawPath(
      junction,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.07,
    );
    canvas.restore();

    // Fine highlight on the frame's upper edge.
    canvas.drawRRect(
      outer.deflate(frame * 0.3),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreBarPainter oldDelegate) => oldDelegate.leftRatio != leftRatio;
}
