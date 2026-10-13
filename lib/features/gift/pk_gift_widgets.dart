import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import '../../core/widgets/custom_avatar.dart';

/// ============================================================================
/// PK BATTLE GIFT WIDGETS & COMPONENTS
/// ============================================================================
/// Dedicated file containing all PK Battle specific gift UI elements, pills,
/// animated cards, orbit buttons, and event models.
/// ============================================================================

/// Event model representing a gift sent in PK Battle (displayed on stream video pill).
class PkGiftEvent {
  final int id;
  final String sender;
  final String senderAvatar;
  final String giftName;
  final String emoji;
  final String? giftImage;
  final int count;

  const PkGiftEvent({
    required this.id,
    required this.sender,
    required this.senderAvatar,
    required this.giftName,
    required this.emoji,
    required this.count,
    this.giftImage,
  });
}

/// Neon-outlined container used by the PK gift card and panels.
class PkNeonBox extends StatelessWidget {
  final Widget child;
  final double radius;
  final List<Color> borderColors;
  final Color glow;
  final EdgeInsetsGeometry padding;
  final double? height;

  const PkNeonBox({
    super.key,
    required this.child,
    this.radius = 20,
    this.borderColors = const [Color(0xFF5B3CFF), Color(0xFFB04DFF), Color(0xFF3D6BFF)],
    this.glow = const Color(0x447C5CFF),
    this.padding = EdgeInsets.zero,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(1.2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(colors: borderColors),
        boxShadow: [BoxShadow(color: glow, blurRadius: 12)],
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius - 1.2),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xF0171340), Color(0xF00D0B28)],
          ),
        ),
        child: child,
      ),
    );
  }
}

/// "Riya · Sent Rose 🌹 x1" pill displayed at the bottom of a host's video.
class PkGiftPill extends StatelessWidget {
  final PkGiftEvent gift;

  const PkGiftPill({super.key, required this.gift});

  @override
  Widget build(BuildContext context) {
    final giftIcon = gift.giftImage != null
        ? Image.asset(
            gift.giftImage!,
            width: 26,
            height: 26,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Text(gift.emoji, style: const TextStyle(fontSize: 18)),
          )
        : Text(gift.emoji, style: const TextStyle(fontSize: 18));

    return Container(
      padding: const EdgeInsets.fromLTRB(3, 3, 10, 3),
      decoration: BoxDecoration(
        color: const Color(0xB30E0B2C),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipOval(child: CustomAvatar(radius: 14, assetPath: gift.senderAvatar)),
          const SizedBox(width: 6),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gift.sender,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700, height: 1.15),
                ),
                Text(
                  'Sent ${gift.giftName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFFC5CCE0), fontSize: 10.5, height: 1.15),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          giftIcon,
          const SizedBox(width: 4),
          Text(
            'x${gift.count}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

/// Glowing card with the animated purple gift box, floating hearts and "Gift" label.
class PkGiftCard extends StatelessWidget {
  final VoidCallback onTap;

  const PkGiftCard({super.key, required this.onTap});

  static const _hearts = [(-46.0, -30.0, 16.0), (-12.0, -50.0, 12.0), (34.0, -44.0, 10.0), (48.0, -22.0, 15.0)];

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open gifts',
      child: GestureDetector(
        onTap: onTap,
        child: PkNeonBox(
          radius: 24,
          borderColors: const [Color(0xFFFFC928), Color(0xFFB04DFF), Color(0xFF3D6BFF)],
          glow: const Color(0x55FFC928),
          padding: const EdgeInsets.all(8),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 120,
                    height: 112,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        BigGiftButton(size: 100, onTap: onTap),
                        for (final (dx, dy, size) in _hearts)
                          Positioned(
                            left: 60 + dx - size / 2,
                            top: 56 + dy - size / 2,
                            child: Icon(
                              Icons.favorite_rounded,
                              size: size,
                              color: const Color(0xFFFF5CB8),
                              shadows: const [Shadow(color: Color(0xAAFF2D9A), blurRadius: 8)],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Gift',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Floating purple gift box with a glowing orbit ring passing around it.
class BigGiftButton extends StatefulWidget {
  final double size;
  final VoidCallback onTap;

  const BigGiftButton({super.key, required this.size, required this.onTap});

  @override
  State<BigGiftButton> createState() => _BigGiftButtonState();
}

class _BigGiftButtonState extends State<BigGiftButton> with SingleTickerProviderStateMixin {
  late final AnimationController _orbit = AnimationController(vsync: this, duration: const Duration(seconds: 3))
    ..repeat();

  @override
  void dispose() {
    _orbit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return Semantics(
      button: true,
      label: 'Open gifts',
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: GiftOrbitPainter(animation: _orbit, front: false),
              ),
              AnimatedBuilder(
                animation: _orbit,
                builder: (context, child) =>
                    Transform.translate(offset: Offset(0, sin(_orbit.value * 2 * pi) * 2.5), child: child),
                child: Image.asset(AppAssets.pkGiftPurple, width: size * 0.78, height: size * 0.78),
              ),
              CustomPaint(
                size: Size(size, size),
                painter: GiftOrbitPainter(animation: _orbit, front: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tilted neon ellipse around the big gift. Drawn in two passes (back half behind
/// the box, front half over it) so the ring appears to wrap around it.
class GiftOrbitPainter extends CustomPainter {
  final Animation<double> animation;
  final bool front;

  GiftOrbitPainter({required this.animation, required this.front}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height * 0.62);
    final rect = Rect.fromCenter(center: Offset.zero, width: size.width * 1.02, height: size.height * 0.34);

    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(-0.18);

    // Front half = lower arc (0..π), back half = upper arc (π..2π).
    final start = front ? 0.0 : pi;
    final shader = const SweepGradient(
      colors: [Color(0xFFFFC928), Color(0xFFB04DFF), Color(0xFF3D6BFF), Color(0xFFB04DFF), Color(0xFFFFC928)],
    ).createShader(rect);

    canvas.drawArc(
      rect,
      start,
      pi,
      false,
      Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    canvas.drawArc(
      rect,
      start,
      pi,
      false,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant GiftOrbitPainter oldDelegate) =>
      oldDelegate.front != front || oldDelegate.animation.value != animation.value;
}
