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

/// Glowing card with the animated 3D Star ('juststar.png') and soft, professional ambient stars.
class PkGiftCard extends StatelessWidget {
  final VoidCallback onTap;

  const PkGiftCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open stars',
      child: GestureDetector(
        onTap: onTap,
        child: PkNeonBox(
          radius: 22,
          borderColors: const [
            Color(0xFFFFD700),
            Color(0xFFBA68C8),
            Color(0xFFFFC928),
          ],
          glow: const Color(0x44FFD700),
          padding: const EdgeInsets.all(4),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: 110,
                height: 110,
                child: BigGiftButton(size: 100, onTap: onTap),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StarParticle {
  final double dx;
  final double dy;
  final double size;
  final double phase;
  final Color color;
  final bool isSparkle;

  const _StarParticle(this.dx, this.dy, this.size, this.phase, this.color, {this.isSparkle = true});
}

/// Floating 3D Star ('juststar.png') with a soft ambient glow and gentle twinkling stars.
class BigGiftButton extends StatefulWidget {
  final double size;
  final VoidCallback onTap;

  const BigGiftButton({super.key, required this.size, required this.onTap});

  @override
  State<BigGiftButton> createState() => _BigGiftButtonState();
}

class _BigGiftButtonState extends State<BigGiftButton> with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4500),
  )..repeat();

  static const _particles = [
    _StarParticle(-38.0, -32.0, 14.0, 0.0, Color(0xFFFFE082), isSparkle: true),
    _StarParticle(36.0, -28.0, 12.0, 0.35, Color(0xFFE1BEE7), isSparkle: false),
    _StarParticle(-36.0, 20.0, 11.0, 0.65, Color(0xFFFFF59D), isSparkle: true),
    _StarParticle(38.0, 18.0, 13.0, 0.85, Color(0xFFFFD700), isSparkle: true),
    _StarParticle(-4.0, -42.0, 15.0, 0.50, Color(0xFFE1BEE7), isSparkle: true),
  ];

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final starSize = size * 0.84;

    return Semantics(
      button: true,
      label: 'Open stars',
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: AnimatedBuilder(
            animation: _anim,
            builder: (context, _) {
              final t = _anim.value;
              final floatDy = sin(t * 2 * pi) * 2.2;
              final pulseScale = 1.0 + 0.018 * sin(t * 2 * pi);

              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Dual soft aura (warm gold + royal violet) behind juststar
                  Container(
                    width: starSize * 0.78,
                    height: starSize * 0.78,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withValues(
                            alpha: (0.16 + 0.08 * sin(t * 2 * pi).abs()).clamp(0.0, 1.0),
                          ),
                          blurRadius: 24,
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: const Color(0xFFBA68C8).withValues(
                            alpha: (0.12 + 0.06 * cos(t * 2 * pi).abs()).clamp(0.0, 1.0),
                          ),
                          blurRadius: 32,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),

                  // Floating 3D Star (glossy_star.png)
                  Transform.translate(
                    offset: Offset(0, floatDy),
                    child: Transform.scale(
                      scale: pulseScale,
                      child: Image.asset(
                        AppAssets.glossyStar,
                        width: starSize,
                        height: starSize,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFD700),
                          size: 56,
                        ),
                      ),
                    ),
                  ),

                  // Soft ambient floating & twinkling sparkles around the star
                  for (final p in _particles) ...[
                    Builder(
                      builder: (context) {
                        final phaseT = (t + p.phase) % 1.0;
                        final particleFloatDy = sin(phaseT * 2 * pi) * 1.8;
                        final twinkle = 0.45 + 0.45 * sin(phaseT * 2 * pi).abs();

                        return Positioned(
                          left: size / 2 + p.dx - p.size / 2,
                          top: size / 2 + p.dy - p.size / 2 + particleFloatDy,
                          child: Opacity(
                            opacity: twinkle.clamp(0.25, 0.95),
                            child: Transform.scale(
                              scale: twinkle,
                              child: Icon(
                                p.isSparkle ? Icons.auto_awesome : Icons.star_rounded,
                                size: p.size,
                                color: p.color,
                                shadows: [
                                  Shadow(
                                    color: p.color.withValues(alpha: 0.5),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
