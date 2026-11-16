// Top gifters under the score bar: who sent each host the most gifts.

import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/custom_avatar.dart';
import '../core/pk_common_widgets.dart';
import '../core/pk_models.dart';

/// (👑)(●)(●)(●) ♥                                  (●)(●)(●)(👑)
/// [521]                                                  [500]
///
/// Each side lists that host's gifters, highest total first and nearest the
/// outer edge, in thick neon rings. The #1 gifter has a gold ring, a crown and
/// their total in a gold pill.
class PkTopGiftersRow extends StatelessWidget {
  final List<PkGifter> left;
  final List<PkGifter> right;
  final VoidCallback? onHeartTap;
  final ValueChanged<PkGifter> onGifterTap;

  /// How many gifters to show per side.
  final int maxPerSide;

  const PkTopGiftersRow({
    super.key,
    required this.left,
    required this.right,
    this.onHeartTap,
    required this.onGifterTap,
    this.maxPerSide = 4,
  });

  // Distinct ring colours matching reference image: cyan, gold/orange, pink / blue
  static const _leftRings = [Color(0xFF00E5FF), Color(0xFFFF9F1A), Color(0xFFFF2DC0)];
  static const _rightRings = [Color(0xFF00E5FF), Color(0xFFFF9F1A), Color(0xFF2E9BFF)];

  List<PkGifter> _ranked(List<PkGifter> gifters) =>
      ([...gifters]..sort((a, b) => b.total.compareTo(a.total))).take(maxPerSide).toList();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) => _build(context, constraints.maxWidth));
  }

  Widget _build(BuildContext context, double width) {
    final half = (width - 24) / 2;
    // Reduced avatar radius for compact, elegant fit matching reference
    final double radius = ((half - 20) / 9.5).clamp(11.0, 15.0).toDouble();
    final leftRanked = _ranked(left);
    final rightRanked = _ranked(right);

    Widget item(PkGifter g, int rank, List<Color> rings) => Padding(
      padding: EdgeInsets.symmetric(horizontal: radius * 0.08),
      child: _GifterAvatar(
        gifter: g,
        isTop: rank == 1,
        ring: rank == 1 ? const Color(0xFFFFC928) : rings[(rank - 2) % rings.length],
        radius: radius,
        onTap: () => onGifterTap(g),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (var i = leftRanked.length - 1; i >= 0; i--) item(leftRanked[i], i + 1, _leftRings),
                ],
              ),
            ),
          ),
          // Middle glowing crossed swords partition for PK battle
          _PkSwordPartition(onTap: onHeartTap),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (var i = 0; i < rightRanked.length; i++) item(rightRanked[i], i + 1, _rightRings),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GifterAvatar extends StatelessWidget {
  final PkGifter gifter;
  final bool isTop;
  final Color ring;
  final double radius;
  final VoidCallback onTap;

  const _GifterAvatar({
    required this.gifter,
    required this.isTop,
    required this.ring,
    required this.radius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final light = Color.lerp(ring, Colors.white, 0.45)!;
    final crown = radius * 1.15;
    final dot = radius * 0.28;

    return Semantics(
      button: true,
      label: '${gifter.name}${isTop ? ', top gifter' : ''}',
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: radius * 2 + 7,
          // Every avatar reserves the crown's space so all rings line up.
          height: radius * 2 + 7 + crown * 0.55,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [light, ring, light],
                  ),
                  boxShadow: [BoxShadow(color: ring.withValues(alpha: 0.85), blurRadius: 12, spreadRadius: 0.5)],
                ),
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF0B0E3A)),
                  child: CustomAvatar(radius: radius, assetPath: gifter.avatar),
                ),
              ),
              if (isTop) Positioned(top: 0, child: PkGoldCrown(size: crown)),
              // Small glowing gem at the bottom of the ring.
              Positioned(
                bottom: -dot * 0.35,
                child: Container(
                  width: dot,
                  height: dot,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [Colors.white, light, ring]),
                    boxShadow: [BoxShadow(color: ring, blurRadius: 6)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// High-detail battle partition between left & right top gifters:
/// - Replaced with the 3-sword crystal & gold battle emblem
/// - Flanked by neon divider whiskers differentiating the partition from user profiles
class _PkSwordPartition extends StatelessWidget {
  final VoidCallback? onTap;

  const _PkSwordPartition({this.onTap});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final isSmall = media.width < 360;
    // Bolder, larger media-query responsive sizing so the battle partition stands out clearly
    final partitionHeight = isSmall ? 52.0 : 60.0;
    final partitionWidth = partitionHeight * (717 / 827);

    return Semantics(
      label: 'PK Battle Partition',
      button: onTap != null,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left Cyan/Pink divider whisker pointing towards host #1 gifters
              Container(
                width: isSmall ? 10 : 16,
                height: 2.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1.5),
                  gradient: const LinearGradient(
                    colors: [Colors.transparent, Color(0xFFFF2DB4)],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x99FF2DB4),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 4),

              // Bolder PK Battle 3-sword emblem partition with vibrant multi-tone aura
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.45),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: const Color(0xFFFF2DB4).withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(-4, 0),
                    ),
                    BoxShadow(
                      color: const Color(0xFF2D7BFF).withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(4, 0),
                    ),
                  ],
                ),
                child: Image.asset(
                  AppAssets.pkCrossedSwords,
                  width: partitionWidth,
                  height: partitionHeight,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.flash_on_rounded,
                      color: Color(0xFFFFD700),
                      size: 32,
                    );
                  },
                ),
              ),

              const SizedBox(width: 4),

              // Right Blue divider whisker pointing towards host #2 gifters
              Container(
                width: isSmall ? 10 : 16,
                height: 2.5,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1.5),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2D7BFF), Colors.transparent],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x992D7BFF),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
