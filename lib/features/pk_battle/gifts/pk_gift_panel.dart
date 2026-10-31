// Right side of the comment panel: 3D star portal on a multi-tier pedestal with glowing neon rings
// and rising glossy 3D hearts, matching the reference image.

import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/heart_3d.dart';

/// Right column of the comment panel: the star gift portal at the bottom,
/// and floating / rising 3D pink hearts above that.
class PkRightColumn extends StatelessWidget {
  final VoidCallback onGift;
  final Widget? hearts;

  const PkRightColumn({super.key, required this.onGift, this.hearts});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (hearts != null) Expanded(child: ClipRect(child: hearts!)),
            Center(
              child: PkGiftOrb(size: w, onTap: onGift),
            ),
          ],
        );
      },
    );
  }
}

/// Floating 3D pink hearts cluster matching the reference screenshot.
class _FloatingHeartsCluster extends StatefulWidget {
  final double width;
  final double height;
  const _FloatingHeartsCluster({required this.width, required this.height});

  @override
  State<_FloatingHeartsCluster> createState() => _FloatingHeartsClusterState();
}

class _FloatingHeartsClusterState extends State<_FloatingHeartsCluster> with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(vsync: this, duration: const Duration(milliseconds: 2400))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _float,
      builder: (context, _) {
        final t = _float.value;
        final floatY = sin(t * pi) * 4.0;
        final floatY2 = cos(t * pi) * 3.0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Large main heart (center-left)
            Positioned(
              left: widget.width * 0.08,
              bottom: widget.height * 0.14 + floatY,
              child: Transform.rotate(
                angle: -0.12,
                child: const Heart3D(size: 38, color: Color(0xFFFF2DAA), glow: 1.0),
              ),
            ),
            // 2. Medium heart (upper-right)
            Positioned(
              right: widget.width * 0.08,
              bottom: widget.height * 0.44 - floatY2,
              child: Transform.rotate(angle: 0.15, child: const Heart3D(size: 30, color: Color(0xFFFF4FD8), glow: 0.8)),
            ),
            // 3. Small heart (upper-left)
            Positioned(
              left: widget.width * 0.22,
              bottom: widget.height * 0.58 + floatY,
              child: Transform.rotate(
                angle: -0.08,
                child: const Heart3D(size: 22, color: Color(0xFFFF3D9A), glow: 0.6),
              ),
            ),
            // 4. Lower-right heart
            Positioned(
              right: widget.width * 0.03,
              bottom: widget.height * 0.18 + floatY2,
              child: Transform.rotate(angle: 0.2, child: const Heart3D(size: 25, color: Color(0xFFFF5CC4), glow: 0.7)),
            ),
            // Golden 4-point sparkle stars matching Image 1
            Positioned(right: widget.width * 0.16, top: widget.height * 0.08, child: const _SparkleStar(size: 15)),
            Positioned(left: widget.width * 0.06, top: widget.height * 0.34, child: const _SparkleStar(size: 12)),
            Positioned(right: widget.width * 0.02, top: widget.height * 0.52, child: const _SparkleStar(size: 14)),
          ],
        );
      },
    );
  }
}

/// 4-point golden sparkle glint matching Image 1.
class _SparkleStar extends StatelessWidget {
  final double size;
  const _SparkleStar({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size), painter: const _SparkleStarPainter());
  }
}

class _SparkleStarPainter extends CustomPainter {
  const _SparkleStarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final path = Path()
      ..moveTo(cx, 0)
      ..quadraticBezierTo(cx, cy, size.width, cy)
      ..quadraticBezierTo(cx, cy, cx, size.height)
      ..quadraticBezierTo(cx, cy, 0, cy)
      ..quadraticBezierTo(cx, cy, cx, 0)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFD600)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawPath(path, Paint()..color = const Color(0xFFFFFBE0));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Star gift button: clean, compact icon placed above the share button,
/// keeping the 3D star image artwork style with responsive tap feedback and subtle golden glow.
class PkGiftOrb extends StatefulWidget {
  final double size;
  final VoidCallback onTap;

  const PkGiftOrb({super.key, required this.size, required this.onTap});

  @override
  State<PkGiftOrb> createState() => _PkGiftOrbState();
}

class _PkGiftOrbState extends State<PkGiftOrb> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    return Semantics(
      button: true,
      label: 'Send gift',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.90 : 1.0,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutBack,
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Transform.scale(
                scale: 1.25,
                child: Image.asset(
                  AppAssets.star,
                  width: size,
                  height: size,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 38),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
