import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/luxe_theme.dart';
import '../../domain/models/gifter_level_model.dart';
import 'gifter_frame_preview.dart';

/// Milestone card displayed in the grid or list of all 19 Gifter levels.
///
/// Designed to be fully responsive across all device sizes using dynamic layout
/// constraints and FittedBoxes to prevent any bottom or horizontal overflow.
class GifterMilestoneCard extends StatelessWidget {
  final GifterMilestone milestone;
  final int userLevel;
  final bool isCurrent;
  final VoidCallback onTap;
  final bool isHorizontal;

  const GifterMilestoneCard({
    super.key,
    required this.milestone,
    required this.userLevel,
    required this.isCurrent,
    required this.onTap,
    this.isHorizontal = false,
  });

  bool get isUnlocked => milestone.isUnlocked(userLevel);

  @override
  Widget build(BuildContext context) {
    final bracket = milestone.bracket;

    final List<Color> borderColors;
    final double glow;
    if (isCurrent) {
      borderColors = [LuxeColors.gold, LuxeColors.violet, LuxeColors.gold];
      glow = 14;
    } else if (isUnlocked) {
      borderColors = [bracket.glowColor, LuxeColors.purple.withValues(alpha: 0.5)];
      glow = 8;
    } else {
      borderColors = [Colors.white12, Colors.white10];
      glow = 0;
    }

    return GestureDetector(
      onTap: onTap,
      child: LuxePanel(
        radius: 18,
        glow: glow,
        borderColors: borderColors,
        padding: isHorizontal
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
            : const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: isHorizontal ? _buildHorizontalLayout(context) : _buildVerticalLayout(context),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Vertical Layout (Grid View)
  // ---------------------------------------------------------------------------

  Widget _buildVerticalLayout(BuildContext context) {
    final bracket = milestone.bracket;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableH = constraints.maxHeight;
        final isCompact = availableH < 190;
        final frameSize = isCompact ? 50.0 : 58.0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Status Tag
            _buildStatusTag(),

            // Frame & Badge Preview
            Opacity(
              opacity: isUnlocked ? 1.0 : 0.65,
              child: GifterFramePreview(
                size: frameSize,
                bracket: bracket,
                level: milestone.level,
                avatarAsset: AppAssets.status5,
                showBadge: true,
                isAnimated: isCurrent,
              ),
            ),

            // Level & Tier Name
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Level ${milestone.level}',
                  maxLines: 1,
                  style: TextStyle(
                    color: isCurrent
                        ? LuxeColors.gold
                        : (isUnlocked ? Colors.white : Colors.white60),
                    fontSize: isCompact ? 13 : 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  milestone.tierName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isUnlocked ? bracket.jewelColor : LuxeColors.textDim,
                    fontSize: isCompact ? 10.5 : 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            // Rewards Count Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: isUnlocked ? 0.08 : 0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isUnlocked
                      ? bracket.glowColor.withValues(alpha: 0.3)
                      : Colors.white10,
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.card_giftcard_rounded,
                    size: 10.5,
                    color: isUnlocked ? LuxeColors.gold : LuxeColors.textDim,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${milestone.rewards.length} Rewards',
                    style: TextStyle(
                      color: isUnlocked ? Colors.white : LuxeColors.textDim,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Horizontal Layout (Timeline View)
  // ---------------------------------------------------------------------------

  Widget _buildHorizontalLayout(BuildContext context) {
    final bracket = milestone.bracket;

    return Row(
      children: [
        // Frame Preview Thumbnail
        Opacity(
          opacity: isUnlocked ? 1.0 : 0.65,
          child: GifterFramePreview(
            size: 50,
            bracket: bracket,
            level: milestone.level,
            avatarAsset: AppAssets.status5,
            showBadge: true,
            isAnimated: isCurrent,
          ),
        ),
        const SizedBox(width: 14),

        // Level & Tier Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Level ${milestone.level}',
                    style: TextStyle(
                      color: isCurrent
                          ? LuxeColors.gold
                          : (isUnlocked ? Colors.white : Colors.white60),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusTag(),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                milestone.tierName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isUnlocked ? bracket.jewelColor : LuxeColors.textDim,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                milestone.rewards.first.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: LuxeColors.textMuted,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),

        // Arrow
        const Icon(
          Icons.chevron_right_rounded,
          color: Colors.white38,
          size: 20,
        ),
      ],
    );
  }

  Widget _buildStatusTag() {
    if (isCurrent) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          gradient: LuxeColors.goldGradient,
          borderRadius: BorderRadius.circular(7),
          boxShadow: const [
            BoxShadow(color: Color(0x66FFC928), blurRadius: 6),
          ],
        ),
        child: const Text(
          'CURRENT',
          style: TextStyle(
            color: Colors.black,
            fontSize: 8.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.3,
          ),
        ),
      );
    } else if (isUnlocked) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
        decoration: BoxDecoration(
          color: const Color(0x2600E676),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: const Color(0xFF00E676), width: 0.8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_rounded, color: Color(0xFF00E676), size: 9),
            SizedBox(width: 2.5),
            Text(
              'UNLOCKED',
              style: TextStyle(
                color: Color(0xFF00E676),
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: Colors.white12, width: 0.8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_rounded, color: LuxeColors.textDim, size: 8.5),
            SizedBox(width: 2.5),
            Text(
              'LOCKED',
              style: TextStyle(
                color: LuxeColors.textDim,
                fontSize: 8,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }
  }
}
