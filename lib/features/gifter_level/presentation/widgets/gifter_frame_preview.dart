import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/luxe_theme.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../domain/models/gifter_level_model.dart';
import 'gifter_badge_widget.dart';

/// A luxury avatar frame renderer that visually transforms based on the Gifter Tier.
///
/// Features:
/// - Distinct border sweeps & metallic ring textures for all 19 tiers.
/// - Pulsing ambient glow matching the tier bracket.
/// - Ornate crests (crowns, star gems, wings, diamond cuts, prismatic halos).
/// - Attached level badge at the bottom.
class GifterFramePreview extends StatefulWidget {
  final double size;
  final GifterTierBracket bracket;
  final int level;
  final String? avatarAsset;
  final String? avatarUrl;
  final bool showBadge;
  final bool isAnimated;

  const GifterFramePreview({
    super.key,
    this.size = 80,
    required this.bracket,
    required this.level,
    this.avatarAsset,
    this.avatarUrl,
    this.showBadge = true,
    this.isAnimated = true,
  });

  @override
  State<GifterFramePreview> createState() => _GifterFramePreviewState();
}

class _GifterFramePreviewState extends State<GifterFramePreview>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.isAnimated) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant GifterFramePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimated && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isAnimated && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final photoInset = s * 0.12;
    final innerDiameter = s - photoInset * 2;

    return SizedBox(
      width: s,
      height: s,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // 1. Ambient Glow
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.bracket.glowColor.withValues(alpha: 0.4),
                    blurRadius: s * 0.28,
                    spreadRadius: s * 0.02,
                  ),
                ],
              ),
            ),
          ),

          // 2. Avatar Photo
          Padding(
            padding: EdgeInsets.all(photoInset),
            child: ClipOval(
              child: CustomAvatar(
                radius: innerDiameter / 2,
                assetPath: widget.avatarAsset ?? (widget.avatarUrl == null ? AppAssets.status5 : null),
                imageUrl: widget.avatarUrl,
              ),
            ),
          ),

          // 3. Custom Frame Painter
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _TierFramePainter(
                    bracket: widget.bracket,
                    animationValue: widget.isAnimated ? _controller.value : 0.0,
                  ),
                );
              },
            ),
          ),

          // 4. Crown / Crest Ornaments (for higher tiers)
          if (_hasCrown(widget.bracket))
            Positioned(
              top: -s * 0.16,
              child: _CrownOrCrest(bracket: widget.bracket, size: s * 0.34),
            ),

          // 5. Attached Level Badge
          if (widget.showBadge)
            Positioned(
              bottom: -s * 0.08,
              child: GifterBadgeWidget(
                level: widget.level,
                bracket: widget.bracket,
                size: s * 0.32,
              ),
            ),
        ],
      ),
    );
  }

  bool _hasCrown(GifterTierBracket b) {
    switch (b) {
      case GifterTierBracket.gold:
      case GifterTierBracket.premiumGold:
      case GifterTierBracket.royal:
      case GifterTierBracket.royalElite:
      case GifterTierBracket.supreme:
      case GifterTierBracket.royalSupreme:
      case GifterTierBracket.ultimateLegend:
      case GifterTierBracket.mythical:
      case GifterTierBracket.master:
      case GifterTierBracket.grandMaster:
      case GifterTierBracket.legendary:
      case GifterTierBracket.legendaryPlus:
        return true;
      default:
        return false;
    }
  }
}

class _CrownOrCrest extends StatelessWidget {
  final GifterTierBracket bracket;
  final double size;

  const _CrownOrCrest({required this.bracket, required this.size});

  @override
  Widget build(BuildContext context) {
    switch (bracket) {
      case GifterTierBracket.gold:
      case GifterTierBracket.premiumGold:
        return LuxeCrown(size: size);
      case GifterTierBracket.royal:
      case GifterTierBracket.royalElite:
      case GifterTierBracket.royalSupreme:
        return _RoyalCrown(size: size);
      case GifterTierBracket.ultimateLegend:
        return _UltimateLegendCrown(size: size * 1.15);
      case GifterTierBracket.mythical:
      case GifterTierBracket.legendary:
      case GifterTierBracket.legendaryPlus:
        return _FlameCrest(size: size, color: bracket.jewelColor);
      case GifterTierBracket.master:
      case GifterTierBracket.grandMaster:
        return _StarGemCrest(size: size, color: bracket.jewelColor);
      case GifterTierBracket.supreme:
        return _SupremeCrown(size: size);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _TierFramePainter extends CustomPainter {
  final GifterTierBracket bracket;
  final double animationValue;

  const _TierFramePainter({
    required this.bracket,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = size.center(Offset.zero);
    final stroke = s * 0.08;
    final r = s / 2 - stroke / 2 - s * 0.02;
    final ring = Rect.fromCircle(center: c, radius: r);

    final colors = bracket.gradientColors;

    // 1. Base metallic sweep ring
    final sweepAngle = animationValue * math.pi * 2;
    final paintRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..shader = SweepGradient(
        transform: GradientRotation(sweepAngle),
        colors: [...colors, colors.first],
      ).createShader(ring);

    canvas.drawCircle(c, r, paintRing);

    // 2. Bright outer rim
    final outerRim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.012
      ..color = Colors.white.withValues(alpha: 0.85);
    canvas.drawCircle(c, r + stroke / 2, outerRim);

    // 3. Inner bezel
    final innerRim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.014
      ..color = Colors.black.withValues(alpha: 0.5);
    canvas.drawCircle(c, r - stroke / 2, innerRim);

    // 4. Accent corner glints / studs
    final numGlints = _glintCount(bracket);
    final glintPaint = Paint()..color = bracket.jewelColor;
    for (int i = 0; i < numGlints; i++) {
      final angle = (i * 2 * math.pi / numGlints) + (animationValue * math.pi * 0.5);
      final p = c + Offset(math.cos(angle), math.sin(angle)) * r;
      canvas.drawCircle(p, s * 0.022, glintPaint);
      canvas.drawCircle(
        p,
        s * 0.01,
        Paint()..color = Colors.white,
      );
    }
  }

  int _glintCount(GifterTierBracket b) {
    switch (b) {
      case GifterTierBracket.basic:
        return 0;
      case GifterTierBracket.bronze:
      case GifterTierBracket.silver:
        return 2;
      case GifterTierBracket.gold:
      case GifterTierBracket.premiumGold:
      case GifterTierBracket.platinum:
        return 4;
      case GifterTierBracket.diamond:
      case GifterTierBracket.royal:
      case GifterTierBracket.elite:
        return 6;
      default:
        return 8;
    }
  }

  @override
  bool shouldRepaint(covariant _TierFramePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue || oldDelegate.bracket != bracket;
}

// -----------------------------------------------------------------------------
// Specialized Crest & Crown Widgets
// -----------------------------------------------------------------------------

class _RoyalCrown extends StatelessWidget {
  final double size;
  const _RoyalCrown({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.7,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(color: Color(0xAAE040FB), blurRadius: 10, spreadRadius: 1),
        ],
      ),
      child: Icon(Icons.workspace_premium_rounded, color: const Color(0xFFFFD700), size: size * 0.95),
    );
  }
}

class _UltimateLegendCrown extends StatelessWidget {
  final double size;
  const _UltimateLegendCrown({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.8,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(color: Color(0xFFFFD700), blurRadius: 16, spreadRadius: 2),
          BoxShadow(color: Color(0xFFFF007F), blurRadius: 12),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.auto_awesome_rounded, color: const Color(0xFFFFD700), size: size * 1.1),
          Icon(Icons.military_tech_rounded, color: Colors.white, size: size * 0.75),
        ],
      ),
    );
  }
}

class _FlameCrest extends StatelessWidget {
  final double size;
  final Color color;
  const _FlameCrest({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.7,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.7), blurRadius: 10),
        ],
      ),
      child: Icon(Icons.local_fire_department_rounded, color: color, size: size * 0.85),
    );
  }
}

class _StarGemCrest extends StatelessWidget {
  final double size;
  final Color color;
  const _StarGemCrest({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.7,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.8), blurRadius: 12),
        ],
      ),
      child: Icon(Icons.diamond_rounded, color: color, size: size * 0.85),
    );
  }
}

class _SupremeCrown extends StatelessWidget {
  final double size;
  const _SupremeCrown({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.75,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(color: Color(0xAAFFD700), blurRadius: 12),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const LuxeCrown(size: 26),
          Positioned(
            top: 2,
            child: Icon(Icons.star_rounded, color: Colors.white, size: size * 0.45),
          ),
        ],
      ),
    );
  }
}

