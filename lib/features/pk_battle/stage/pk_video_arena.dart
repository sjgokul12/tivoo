// The two live video cards, their LIVE / viewer / gift pills, the PK timer, and the gold VS.

import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/widgets/custom_avatar.dart';
import '../../../core/widgets/live_video_player.dart';
import '../core/pk_common_widgets.dart';
import '../core/pk_models.dart';

/// [ left live card ]   VS   [ right live card ]
/// Each card has a neon border (pink / blue), LIVE top-left, viewer count
/// top-right and the latest gift pill along the bottom.
/// The PK timer sits in the center of the arena below the top icon pills.
class PkVideoArena extends StatefulWidget {
  final PkHost left;
  final PkHost right;
  final PkGiftEvent? leftGift;
  final PkGiftEvent? rightGift;
  final bool showVs;
  final VoidCallback? onViewersTap;
  final Widget? timer;

  /// Which host the viewer supports (gets a badge); tapping a card reports its side.
  final bool supportLeft;
  final ValueChanged<bool>? onCardTap;

  const PkVideoArena({
    super.key,
    required this.left,
    required this.right,
    this.leftGift,
    this.rightGift,
    this.showVs = true,
    this.onViewersTap,
    this.timer,
    this.isPlaying = true,
    this.supportLeft = true,
    this.onCardTap,
  });

  final bool isPlaying;

  @override
  State<PkVideoArena> createState() => _PkVideoArenaState();
}

class _PkVideoArenaState extends State<PkVideoArena> with SingleTickerProviderStateMixin {
  late final AnimationController _energy = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  @override
  void dispose() {
    _energy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        const gap = 6.0;
        final vsWidth = (c.maxWidth * 0.22).clamp(70.0, 130.0);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _LiveCard(
                      host: widget.left,
                      isLeft: true,
                      energy: _energy,
                      gift: widget.leftGift ?? PkDemoData.leftGift,
                      onViewersTap: widget.onViewersTap,
                      isPlaying: widget.isPlaying,
                      isSupported: widget.supportLeft,
                      onTap: () => widget.onCardTap?.call(true),
                    ),
                  ),
                  const SizedBox(width: gap),
                  Expanded(
                    child: _LiveCard(
                      host: widget.right,
                      isLeft: false,
                      energy: _energy,
                      gift: widget.rightGift ?? PkDemoData.rightGift,
                      onViewersTap: widget.onViewersTap,
                      isPlaying: widget.isPlaying,
                      isSupported: !widget.supportLeft,
                      onTap: () => widget.onCardTap?.call(false),
                    ),
                  ),
                ],
              ),
              // Timer positioned in the center between the video screens below the LIVE / viewer pills
              if (widget.timer != null) Positioned(top: 38, child: Transform.scale(scale: 0.95, child: widget.timer!)),
              // VS emblem shown at the start of a round
              IgnorePointer(
                child: AnimatedOpacity(
                  opacity: widget.showVs ? 1 : 0,
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOut,
                  child: AnimatedScale(
                    scale: widget.showVs ? 1 : 0.6,
                    duration: const Duration(milliseconds: 450),
                    curve: widget.showVs ? Curves.easeOutBack : Curves.easeIn,
                    child: _GoldVs(animation: _energy, width: min(vsWidth, c.maxHeight * 0.45)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LiveCard extends StatelessWidget {
  final PkHost host;
  final bool isLeft;
  final Animation<double> energy;
  final PkGiftEvent gift;
  final VoidCallback? onViewersTap;
  final bool isPlaying;
  final bool isSupported;
  final VoidCallback? onTap;

  const _LiveCard({
    required this.host,
    required this.isLeft,
    required this.energy,
    required this.gift,
    this.onViewersTap,
    this.isPlaying = true,
    this.isSupported = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColors = isLeft
        ? const [Color(0xFFFF8AE6), Color(0xFFFF2DC0), Color(0xFFC04DFF)]
        : const [Color(0xFF8AD8FF), Color(0xFF2E9BFF), Color(0xFF3D6BFF)];
    final glow = isLeft ? const Color(0xFFFF2DC0) : const Color(0xFF2E9BFF);

    const cardRadius = BorderRadius.all(Radius.circular(20.0));
    const clipRadius = BorderRadius.all(Radius.circular(17.5));

    return AnimatedBuilder(
      animation: energy,
      builder: (context, child) {
        final pulse = 0.7 + 0.25 * sin(energy.value * 2 * pi);
        return Container(
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            borderRadius: cardRadius,
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: borderColors),
            boxShadow: [BoxShadow(color: glow.withValues(alpha: pulse), blurRadius: 14, spreadRadius: 0.5)],
          ),
          child: child,
        );
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ClipRRect(
          borderRadius: clipRadius,
          child: LayoutBuilder(
            builder: (context, c) {
              final pill = (c.maxWidth * 0.11).clamp(18.0, 24.0);
              return Stack(
                fit: StackFit.expand,
                children: [
                  LiveVideoPlayer(
                    key: ValueKey('pk_${isLeft ? 'left' : 'right'}_stream_${host.name}_${host.videoAsset}'),
                    playerId: 'pk_${isLeft ? 'left' : 'right'}_stream_${host.name.toLowerCase()}',
                    videoAssetPath: host.videoAsset,
                    placeholderAssetPath: host.avatarAsset,
                    fit: BoxFit.cover,
                    autoPlay: isPlaying,
                    isMuted: true,
                    showSoundToggle: false,
                  ),
                  // Gradient shade over video
                  const IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x66000000), Colors.transparent, Colors.transparent, Color(0x88000000)],
                          stops: [0, 0.2, 0.7, 1],
                        ),
                      ),
                    ),
                  ),
                  // Top-left: LIVE pill
                  Positioned(
                    top: 8,
                    left: 8,
                    height: pill,
                    child: _LivePill(height: pill),
                  ),
                  // Top-right: Viewer count pill
                  Positioned(
                    top: 8,
                    right: 8,
                    height: pill,
                    child: _ViewerPill(count: host.viewers, height: pill, onTap: onViewersTap),
                  ),
                  // Bottom: Latest gift event pill inside the video card
                  Positioned(
                    left: 6,
                    right: 6,
                    bottom: 8,
                    child: _GiftPillInCard(gift: gift, isLeft: isLeft),
                  ),
                  // Below LIVE: badge on the host this viewer supports.
                  Positioned(
                    top: 8 + pill + 5,
                    left: 8,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: isSupported ? _SupportingBadge(color: glow) : const SizedBox.shrink(),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Red "● LIVE" pill.
class _LivePill extends StatelessWidget {
  final double height;
  const _LivePill({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: height * 0.36),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height),
        gradient: const LinearGradient(colors: [Color(0xFFFF3B5C), Color(0xFFE5173F)]),
        boxShadow: const [BoxShadow(color: Color(0x66FF2D55), blurRadius: 6)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: height * 0.24,
            height: height * 0.24,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
          ),
          SizedBox(width: height * 0.16),
          Text(
            'LIVE',
            style: TextStyle(color: Colors.white, fontSize: height * 0.44, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

/// "👁 6.2K" in a translucent dark pill.
class _ViewerPill extends StatelessWidget {
  final String count;
  final double height;
  final VoidCallback? onTap;
  const _ViewerPill({required this.count, required this.height, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$count viewers',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: height * 0.35),
          decoration: BoxDecoration(
            color: const Color(0xB305061A),
            borderRadius: BorderRadius.circular(height / 2),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 0.8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.remove_red_eye_rounded, color: Colors.white, size: height * 0.52),
              SizedBox(width: height * 0.15),
              Text(
                count,
                style: TextStyle(color: Colors.white, fontSize: height * 0.44, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Latest gift pill at the bottom of the video card matching the reference image.
class _GiftPillInCard extends StatelessWidget {
  final PkGiftEvent gift;
  final bool isLeft;
  const _GiftPillInCard({required this.gift, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    final border = isLeft ? const [Color(0xFFFF7AE0), Color(0xFFB04DFF)] : const [Color(0xFF7FD0FF), Color(0xFF2E9BFF)];

    final giftIcon = gift.giftImage != null
        ? Image.asset(
            gift.giftImage!,
            width: 22,
            height: 22,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => Text(gift.emoji, style: const TextStyle(fontSize: 16)),
          )
        : Text(gift.emoji, style: const TextStyle(fontSize: 16));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xCC0D0B28),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border.first.withValues(alpha: 0.8), width: 1.2),
        boxShadow: [BoxShadow(color: border.first.withValues(alpha: 0.35), blurRadius: 6)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(1.2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: border),
            ),
            child: CustomAvatar(radius: 12, assetPath: gift.senderAvatar),
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        gift.sender,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 3),
                    const PkGoldCrown(size: 10),
                  ],
                ),
                Text(
                  'Sent ${gift.giftName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFC0C8E0),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          giftIcon,
          const SizedBox(width: 3),
          Text(
            'x${gift.count}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(width: 2),
        ],
      ),
    );
  }
}

/// Gold, italic "VS" over lightning bolt.
class _GoldVs extends StatelessWidget {
  final Animation<double> animation;
  final double width;
  const _GoldVs({required this.animation, required this.width});

  @override
  Widget build(BuildContext context) {
    final height = width * 1.15;
    final style = TextStyle(
      fontSize: width * 0.52,
      fontWeight: FontWeight.w900,
      fontStyle: FontStyle.italic,
      letterSpacing: -1,
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Transform.scale(scale: 1 + 0.04 * sin(animation.value * 2 * pi), child: child),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(size: Size(width, height), painter: _BoltPainter()),
            Text(
              'VS',
              style: style.copyWith(
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = width * 0.06
                  ..color = const Color(0xFF5A2600),
                shadows: const [Shadow(color: Color(0xCCFF8A00), blurRadius: 16)],
              ),
            ),
            ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFFBE0), Color(0xFFFFD54A), Color(0xFFFF9800), Color(0xFFFFC107)],
                stops: [0, 0.4, 0.75, 1],
              ).createShader,
              child: Text('VS', style: style.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _BoltPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bolt = Path()
      ..moveTo(w * 0.62, 0)
      ..lineTo(w * 0.26, h * 0.56)
      ..lineTo(w * 0.47, h * 0.56)
      ..lineTo(w * 0.34, h)
      ..lineTo(w * 0.76, h * 0.4)
      ..lineTo(w * 0.54, h * 0.4)
      ..lineTo(w * 0.74, 0)
      ..close();
    canvas.drawPath(
      bolt,
      Paint()
        ..color = const Color(0xCCFF9800)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.08),
    );
    canvas.drawPath(
      bolt,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF59D), Color(0xFFFFB300), Color(0xFFFF6F00)],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// "♥ Supporting" chip on the supported host's video.
class _SupportingBadge extends StatelessWidget {
  final Color color;
  const _SupportingBadge({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 8)],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.favorite_rounded, color: Colors.white, size: 10),
          SizedBox(width: 3),
          Text(
            'Supporting',
            style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
