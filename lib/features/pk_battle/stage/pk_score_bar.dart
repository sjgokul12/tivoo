// Pink vs blue clash score bar.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_assets.dart';

/// Pink vs blue clash bar with 3D gift boxes on both ends.
/// The split follows the live scores, clamped so neither side disappears.
class PkScoreBar extends StatelessWidget {
  final int leftScore;
  final int rightScore;

  const PkScoreBar({super.key, required this.leftScore, required this.rightScore});

  static final NumberFormat _format = NumberFormat('#,###');

  static const _scoreStyle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.3,
    shadows: [Shadow(color: Colors.black87, blurRadius: 4, offset: Offset(0, 1.5))],
  );

  @override
  Widget build(BuildContext context) {
    final total = leftScore + rightScore;
    final ratio = total == 0 ? 0.5 : (leftScore / total).clamp(0.35, 0.62);

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
      child: SizedBox(
        height: 32,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(color: Color(0x80FF0055), blurRadius: 10, offset: Offset(-2, 1.5)),
                    BoxShadow(color: Color(0x8000E5FF), blurRadius: 10, offset: Offset(2, 1.5)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: ratio.toDouble()),
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutCubic,
                    builder: (_, value, _) => CustomPaint(painter: _PkScoreBarPainter(leftRatio: value)),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 44),
                child: Row(
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(_format.format(leftScore), style: _scoreStyle),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(_format.format(rightScore), style: _scoreStyle),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(left: -14, top: -16, child: Image.asset(AppAssets.pkGiftRed, width: 54, height: 54)),
            Positioned(right: -14, top: -16, child: Image.asset(AppAssets.pkGiftBlue, width: 54, height: 54)),
          ],
        ),
      ),
    );
  }
}

/// Glossy pink/blue clash bar with a glowing white oval at the junction.
class _PkScoreBarPainter extends CustomPainter {
  final double leftRatio;

  _PkScoreBarPainter({required this.leftRatio});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * leftRatio;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, cx, h),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFF0055), Color(0xFFFF007F), Color(0xFFFF1A88)],
        ).createShader(Rect.fromLTWH(0, 0, cx, h)),
    );
    canvas.drawRect(
      Rect.fromLTWH(cx, 0, w - cx, h),
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF0072FF), Color(0xFF00A6FF), Color(0xFF00F0FF)],
        ).createShader(Rect.fromLTWH(cx, 0, w - cx, h)),
    );

    // Top gloss
    final gloss = Rect.fromLTWH(0, 0, w, h * 0.45);
    canvas.drawRect(
      gloss,
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.white.withValues(alpha: 0.42), Colors.white.withValues(alpha: 0.1), Colors.transparent],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(gloss),
    );

    // Junction oval
    final oval = Rect.fromCenter(center: Offset(cx, h / 2), width: 6.5, height: h * 0.9);
    canvas.drawOval(
      oval,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    canvas.drawOval(oval, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _PkScoreBarPainter oldDelegate) => oldDelegate.leftRatio != leftRatio;
}
