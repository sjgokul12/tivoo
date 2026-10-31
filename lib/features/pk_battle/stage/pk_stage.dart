// Top of the PK screen: Back button at top-left, PK BATTLE emblem in center,
// and host profile pills (Priya & Anu) on both sides of the PK logo with full glassmorphism UI.

import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/custom_avatar.dart';
import '../core/pk_common_widgets.dart';
import '../core/pk_models.dart';
import '../core/pk_responsive.dart';

class PkStage extends StatelessWidget {
  final Widget arena;
  final bool showHeader;
  final VoidCallback onBack;
  final VoidCallback onEmblemTap;
  final PkHost left;
  final PkHost right;
  final bool isFollowingLeft;
  final bool isFollowingRight;
  final bool isRequestedLeft;
  final bool isRequestedRight;
  final int leftScore;
  final int rightScore;
  final ValueChanged<bool>? onFollowTap;
  final ValueChanged<bool>? onHostTap;
  final VoidCallback? onExplorePk;

  const PkStage({
    super.key,
    required this.arena,
    required this.onBack,
    required this.onEmblemTap,
    this.showHeader = true,
    required this.left,
    required this.right,
    this.isFollowingLeft = false,
    this.isFollowingRight = false,
    this.isRequestedLeft = false,
    this.isRequestedRight = false,
    this.leftScore = 0,
    this.rightScore = 0,
    this.onFollowTap,
    this.onHostTap,
    this.onExplorePk,
  });

  static const double _emblemAspect = 1671 / 941;

  @override
  Widget build(BuildContext context) {
    if (!showHeader) {
      return arena;
    }

    final r = PkResponsive.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth > 0 ? constraints.maxWidth : r.width;
        final emblemW = (width * 0.29).clamp(96.0, 132.0);
        final emblemH = emblemW / _emblemAspect;
        final control = r.s(31).clamp(28.0, 36.0);
        final pillH = r.s(36).clamp(32.0, 42.0);
        // Back button row on top, host pills underneath.
        final headerH = max(emblemH, control + 4 + pillH + 2);

        // As wide as possible without running under the centre emblem.
        final pillW = min(width * 0.33, (width - emblemW) / 2 - 14).clamp(96.0, 168.0);

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Section: Back button at top-left, PK BATTLE emblem in center,
            // and Priya & Anu host profile pills on both sides of the PK logo.
            SizedBox(
              height: headerH,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. Back button at the top-left matching reference image
                  Positioned(
                    left: 10,
                    top: 4,
                    child: _BackButton(size: control, onTap: onBack),
                  ),

                  // 2. PK BATTLE emblem in the center, spanning vertically between rows
                  Positioned(
                    top: 0,
                    left: (width - emblemW) / 2,
                    width: emblemW,
                    child: Semantics(
                      button: true,
                      label: 'PK Battle',
                      child: GestureDetector(
                        onTap: onEmblemTap,
                        child: Image.asset(
                          AppAssets.pkTopBanner,
                          width: emblemW,
                          height: emblemH,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.medium,
                        ),
                      ),
                    ),
                  ),

                  // 3. Left host pill (Priya) with reduced, compact outline width
                  Positioned(
                    left: 10,
                    width: pillW,
                    bottom: 2,
                    child: _HostGlassPill(
                      height: pillH,
                      host: left,
                      isLeft: true,
                      isFollowing: isFollowingLeft,
                      isRequested: isRequestedLeft,
                      score: leftScore,
                      onTap: () => onHostTap?.call(true),
                      onFollowTap: () => onFollowTap?.call(true),
                    ),
                  ),

                  // 4. Right host pill (Anu) with reduced, compact outline width
                  Positioned(
                    right: 10,
                    width: pillW,
                    bottom: 2,
                    child: _HostGlassPill(
                      height: pillH,
                      host: right,
                      isLeft: false,
                      isFollowing: isFollowingRight,
                      isRequested: isRequestedRight,
                      score: rightScore,
                      onTap: () => onHostTap?.call(false),
                      onFollowTap: () => onFollowTap?.call(false),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // The two video stream cards
            Expanded(child: arena),
          ],
        );
      },
    );
  }
}

/// Back button matching the glowing cyan-blue neon circle with glassmorphism from the design.
class _BackButton extends StatelessWidget {
  final double size;
  final VoidCallback onTap;
  const _BackButton({required this.size, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF00E5FF), width: 1.6),
            gradient: const RadialGradient(colors: [Color(0xFF1E3A8A), Color(0xFF0A0F2D)]),
            boxShadow: const [BoxShadow(color: Color(0xAA00E5FF), blurRadius: 10, spreadRadius: 0.5)],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Specular curved gloss reflection on top half
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: size * 0.45,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(size / 2)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white.withValues(alpha: 0.45), Colors.transparent],
                    ),
                  ),
                ),
              ),
              Icon(Icons.arrow_back_ios_new_rounded, color: const Color(0xFFBAE6FD), size: size * 0.38),
            ],
          ),
        ),
      ),
    );
  }
}

/// Host profile glassmorphic banner on both sides of the PK logo (Priya on left, Anu on right).
class _HostGlassPill extends StatelessWidget {
  final double height;
  final PkHost host;
  final bool isLeft;
  final bool isFollowing;
  final bool isRequested;
  final int score;
  final VoidCallback? onTap;
  final VoidCallback? onFollowTap;

  const _HostGlassPill({
    required this.height,
    required this.host,
    required this.isLeft,
    this.isFollowing = false,
    this.isRequested = false,
    this.score = 0,
    this.onTap,
    this.onFollowTap,
  });

  @override
  Widget build(BuildContext context) {
    final h = height;
    final avatarRadius = h * 0.34;
    final followSize = h * 0.6;
    final accent = isLeft ? const Color(0xFFFF2DC0) : const Color(0xFF00E5FF);
    final border = isLeft ? const [Color(0xFFFF7AE0), Color(0xFFFF2DC0)] : const [Color(0xFF7FD0FF), Color(0xFF00E5FF)];

    final avatar = Container(
      padding: const EdgeInsets.all(1.4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: border),
        boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.6), blurRadius: 6)],
      ),
      child: CustomAvatar(radius: avatarRadius, assetPath: host.avatarAsset),
    );

    // Name + score are two lines inside a fixed-height pill: fonts are sized
    // from the pill height and system text scaling is capped below, so large
    // accessibility font sizes no longer overflow the bottom of the pill.
    final nameSize = h * 0.31;
    final scoreSize = h * 0.27;
    final scoreText = Text(
      '$score',
      maxLines: 1,
      style: TextStyle(color: Colors.white, fontSize: scoreSize, fontWeight: FontWeight.w700, height: 1.1),
    );
    final star = Icon(Icons.star_rounded, color: const Color(0xFFFFDF00), size: scoreSize + 0.5);

    final info = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                host.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white, fontSize: nameSize, fontWeight: FontWeight.w800, height: 1.1),
              ),
            ),
            const SizedBox(width: 2.5),
            PkGoldCrown(size: nameSize - 1),
          ],
        ),
        // Star count: at the right for the left, and left for the right (vice versa)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: isLeft
              ? [Flexible(child: scoreText), const SizedBox(width: 2), star]
              : [star, const SizedBox(width: 2), Flexible(child: scoreText)],
        ),
      ],
    );

    final followBtn = GestureDetector(
      onTap: onFollowTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: followSize,
        height: followSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isFollowing
              ? const LinearGradient(colors: [Color(0xFF34D399), Color(0xFF059669)])
              : (isRequested
                    ? null
                    : (isLeft
                          ? const LinearGradient(colors: [Color(0xFFFF5CC4), Color(0xFFFF2DC0)])
                          : const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF00E5FF)]))),
          color: isRequested ? const Color(0xFF1E2840) : null,
          border: isRequested ? Border.all(color: const Color(0xFFFFDF00), width: 1.2) : null,
          boxShadow: [
            BoxShadow(color: (isRequested ? const Color(0xFFFFDF00) : accent).withValues(alpha: 0.6), blurRadius: 6),
          ],
        ),
        child: Icon(
          isFollowing ? Icons.check_rounded : (isRequested ? Icons.schedule_rounded : Icons.add_rounded),
          color: isRequested ? const Color(0xFFFFDF00) : Colors.white,
          size: followSize * (isRequested ? 0.55 : 0.65),
        ),
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.0,
        child: Container(
          height: h,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(h / 2),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isLeft
                  ? [const Color(0xDD2A0E5E), const Color(0xBB180B3A)]
                  : [const Color(0xBB0A1A4A), const Color(0xDD0E1A66)],
            ),
            border: Border.all(color: accent.withValues(alpha: 0.9), width: 1.0),
            boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.35), blurRadius: 6, spreadRadius: 0.5)],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Specular glass shine on top edge
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: h * 0.45,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(h / 2)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white.withValues(alpha: 0.28), Colors.transparent],
                    ),
                  ),
                ),
              ),
              Row(
                children: isLeft
                    ? [avatar, const SizedBox(width: 4), Expanded(child: info), const SizedBox(width: 3), followBtn]
                    : [followBtn, const SizedBox(width: 3), Expanded(child: info), const SizedBox(width: 4), avatar],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
