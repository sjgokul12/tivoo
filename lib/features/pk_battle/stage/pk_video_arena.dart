// Split live video, gift pills, VS emblem and arena painters.

import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/custom_avatar.dart';
import '../../../core/widgets/live_video_player.dart';
import '../core/pk_models.dart';

/// Split live video: left host | plasma seam + VS badge | right host.
class PkVideoArena extends StatefulWidget {
  final PkHost left;
  final PkHost right;
  final PkGiftEvent leftGift;
  final PkGiftEvent rightGift;

  const PkVideoArena({
    super.key,
    required this.left,
    required this.right,
    required this.leftGift,
    required this.rightGift,
  });

  @override
  State<PkVideoArena> createState() => _PkVideoArenaState();
}

class _PkVideoArenaState extends State<PkVideoArena> with SingleTickerProviderStateMixin {
  static const double _radius = 18;

  late final AnimationController _energy = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _energy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(_radius),
            child: ColoredBox(
              color: Colors.black,
              child: Row(
                children: [
                  Expanded(
                    child: _StreamTile(
                      host: widget.left,
                      gift: widget.leftGift,
                      isLeft: true,
                      playerId: 'pk_left_stream',
                    ),
                  ),
                  Expanded(
                    child: _StreamTile(
                      host: widget.right,
                      gift: widget.rightGift,
                      isLeft: false,
                      playerId: 'pk_right_stream',
                    ),
                  ),
                ],
              ),
            ),
          ),
          IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _PkVideoAuraPainter(animation: _energy, radius: _radius),
              ),
            ),
          ),
          IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(painter: _PkPlasmaSeamPainter(animation: _energy)),
            ),
          ),
          LayoutBuilder(
            builder: (context, c) {
              // ~21% of the arena width, never taller than the arena.
              final w = (c.maxWidth * 0.21).clamp(70.0, 104.0);
              final fitted = w / _VsBadge.aspectRatio > c.maxHeight * 0.85
                  ? c.maxHeight * 0.85 * _VsBadge.aspectRatio
                  : w;
              return Center(
                child: _VsBadge(animation: _energy, width: fitted),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StreamTile extends StatelessWidget {
  final PkHost host;
  final PkGiftEvent gift;
  final bool isLeft;
  final String playerId;

  const _StreamTile({required this.host, required this.gift, required this.isLeft, required this.playerId});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        LiveVideoPlayer(
          key: ValueKey('${playerId}_${host.videoAsset}'),
          playerId: playerId,
          videoAssetPath: host.videoAsset,
          placeholderAssetPath: host.avatarAsset,
          fit: BoxFit.cover,
          autoPlay: true,
          isMuted: true,
          showSoundToggle: false,
        ),
        // Top vignette so the badges stay readable on bright video.
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 56,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xB3000000), Colors.transparent],
              ),
            ),
          ),
        ),
        Positioned(top: 10, left: 10, child: _ViewerBadge(count: host.viewers)),
        Positioned(top: 10, right: 12, child: _LiveBadge(isLeft: isLeft)),
        Positioned(
          left: 8,
          right: 8,
          bottom: 10,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, 0.4), end: Offset.zero).animate(anim),
                child: child,
              ),
            ),
            child: _GiftPill(key: ValueKey(gift.id), gift: gift),
          ),
        ),
      ],
    );
  }
}

class _ViewerBadge extends StatelessWidget {
  final String count;
  const _ViewerBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 11)),
          const SizedBox(width: 3),
          Text(
            count,
            style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  final bool isLeft;
  const _LiveBadge({required this.isLeft});

  @override
  Widget build(BuildContext context) {
    final color = isLeft ? const Color(0xFFFF1F5A) : const Color(0xFF1E6BFF);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3.5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 8)],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 2.5, backgroundColor: Colors.white),
          SizedBox(width: 4),
          Text(
            'LIVE',
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.6),
          ),
        ],
      ),
    );
  }
}

/// "Riya · Sent Rose 🌹 x1" pill at the bottom of a host's video.
class _GiftPill extends StatelessWidget {
  final PkGiftEvent gift;
  const _GiftPill({super.key, required this.gift});

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
        color: const Color(0xB30B1028),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          ClipOval(child: CustomAvatar(radius: 14, assetPath: gift.senderAvatar)),
          const SizedBox(width: 6),
          Expanded(
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

/// VS emblem artwork (assets/VS.png) with a gentle pulse.
class _VsBadge extends StatelessWidget {
  final Animation<double> animation;
  final double width;
  const _VsBadge({required this.animation, required this.width});

  /// Width / height of the VS.png artwork.
  static const double aspectRatio = 420 / 664;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) => Transform.scale(scale: 1 + 0.035 * sin(animation.value * 2 * pi), child: child),
        child: Image.asset(
          AppAssets.pkVsEmblem,
          width: width,
          height: width / aspectRatio,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        ),
      ),
    );
  }
}

/// Animated pink/blue seam running down the middle of the split video, with a
/// soft bloom behind the VS emblem.
class _PkPlasmaSeamPainter extends CustomPainter {
  final Animation<double> animation;

  _PkPlasmaSeamPainter({required this.animation}) : super(repaint: animation);

  static const _pink = Color(0xFFFF0055);
  static const _cyan = Color(0xFF2E8BFF);

  @override
  void paint(Canvas canvas, Size size) {
    final progress = animation.value;
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Bloom behind the VS badge.
    final pulse = 0.85 + 0.15 * sin(progress * 4 * pi);
    canvas.drawCircle(
      Offset(cx - 10, cy),
      40,
      Paint()
        ..color = _pink.withValues(alpha: 0.55 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
    );
    canvas.drawCircle(
      Offset(cx + 10, cy),
      40,
      Paint()
        ..color = _cyan.withValues(alpha: 0.55 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
    );

    _paintBeam(canvas, cx, size.height, progress);
  }

  void _paintBeam(Canvas canvas, double cx, double height, double progress) {
    const steps = 30;
    final dy = height / steps;

    final pinkAura = Path()..moveTo(cx - 2, 0);
    final cyanAura = Path()..moveTo(cx + 2, 0);
    final pinkBody = Path()..moveTo(cx - 2.5, 0);
    final cyanBody = Path()..moveTo(cx + 2.5, 0);
    final core = Path()..moveTo(cx, 0);

    for (var i = 0; i <= steps; i++) {
      final y = i * dy;
      final offset = sin((y * 0.05) - progress * 2 * pi) * 1.6 + cos((y * 0.11) + progress * 3 * pi) * 0.9;
      pinkAura.lineTo(cx - 3, y);
      cyanAura.lineTo(cx + 3, y);
      pinkBody.lineTo(cx - 1.6 + offset.clamp(-3.0, 0.0), y);
      cyanBody.lineTo(cx + 1.6 + offset.clamp(0.0, 3.0), y);
      core.lineTo(cx + offset * 0.3, y);
    }

    Paint stroke(Color c, double width, [double blur = 0]) {
      final p = Paint()
        ..color = c
        ..strokeWidth = width
        ..style = PaintingStyle.stroke;
      if (blur > 0) p.maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
      return p;
    }

    // Thin, bright seam: soft side glows, coloured edges, white-hot core.
    canvas.drawPath(pinkAura, stroke(_pink.withValues(alpha: 0.45), 10, 8));
    canvas.drawPath(cyanAura, stroke(_cyan.withValues(alpha: 0.45), 10, 8));
    canvas.drawPath(pinkBody, stroke(const Color(0xFFFF1A75), 2.2, 1.5));
    canvas.drawPath(cyanBody, stroke(const Color(0xFF4FA3FF), 2.2, 1.5));
    canvas.drawPath(core, stroke(Colors.white, 3, 2));
    canvas.drawPath(core, stroke(Colors.white, 1.3));

    // Energy pulses travelling along the beam.
    for (var k = 0; k < 3; k++) {
      final y = ((progress * 1.6 + k / 3) % 1.0) * height;
      final x = cx + sin((y * 0.04) - progress * 2 * pi) * 1.5;
      canvas.drawCircle(
        Offset(x, y),
        4.5,
        Paint()
          ..color = k.isEven ? const Color(0xFFFF80AB) : const Color(0xFF80D8FF)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawCircle(Offset(x, y), 2.2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _PkPlasmaSeamPainter oldDelegate) => false;
}

/// Pulsing neon border around both video halves (pink left, cyan right) with travelling sparks.
class _PkVideoAuraPainter extends CustomPainter {
  final Animation<double> animation;
  final double radius;

  _PkVideoAuraPainter({required this.animation, this.radius = 18}) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final progress = animation.value;
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final pulse = 0.7 + 0.3 * sin(progress * 2 * pi);
    final r = Radius.circular(radius);

    final leftBorder = Path()
      ..moveTo(cx, 0)
      ..lineTo(radius, 0)
      ..arcToPoint(Offset(0, radius), radius: r, clockwise: false)
      ..lineTo(0, h - radius)
      ..arcToPoint(Offset(radius, h), radius: r, clockwise: false)
      ..lineTo(cx, h);

    final rightBorder = Path()
      ..moveTo(cx, 0)
      ..lineTo(w - radius, 0)
      ..arcToPoint(Offset(w, radius), radius: r)
      ..lineTo(w, h - radius)
      ..arcToPoint(Offset(w - radius, h), radius: r)
      ..lineTo(cx, h);

    void neon(Path path, Color glow, Color core) {
      canvas.drawPath(
        path,
        Paint()
          ..color = glow.withValues(alpha: 0.6 * pulse)
          ..strokeWidth = 4
          ..style = PaintingStyle.stroke
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = core.withValues(alpha: 0.9 * pulse)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke,
      );
    }

    neon(leftBorder, const Color(0xFFFF007F), const Color(0xFFFF1493));
    neon(rightBorder, const Color(0xFF00E5FF), const Color(0xFF00B0FF));

    final spark = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    for (var i = 0; i < 3; i++) {
      final t = (progress + i * 0.33) % 1.0;
      canvas.drawCircle(Offset(cx * (1 - t), 0), 2.2, spark);
      canvas.drawCircle(Offset(cx + cx * t, h), 2.2, spark);
    }
  }

  @override
  bool shouldRepaint(covariant _PkVideoAuraPainter oldDelegate) => oldDelegate.radius != radius;
}
