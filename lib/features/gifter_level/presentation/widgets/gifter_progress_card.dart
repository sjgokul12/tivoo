import 'package:flutter/material.dart';

import '../../../../core/theme/luxe_theme.dart';
import '../../domain/models/gifter_level_model.dart';
import 'gifter_badge_widget.dart';

/// Card showing progress towards the next Gifter milestone.
///
/// Responsive and overflow-proof across all mobile screen dimensions.
class GifterProgressCard extends StatelessWidget {
  final GifterUserStatus status;
  final VoidCallback? onNextMilestoneTap;

  const GifterProgressCard({
    super.key,
    required this.status,
    this.onNextMilestoneTap,
  });

  @override
  Widget build(BuildContext context) {
    final next = status.nextMilestone;

    if (next == null) {
      return LuxePanel(
        radius: 20,
        glow: 14,
        borderColors: const [Color(0xFFFFD700), Color(0xFFFF007F), Color(0xFF00E5FF)],
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LuxeColors.goldGradient,
                boxShadow: [
                  BoxShadow(color: Color(0x88FFC928), blurRadius: 12),
                ],
              ),
              child: const Icon(Icons.emoji_events_rounded, color: Colors.black, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MAX LEVEL REACHED 👑',
                    style: TextStyle(
                      color: LuxeColors.gold,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'You hold the immortal Ultimate Legend status across all of Tivoo!',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final percent = (status.progressToNext * 100).round();
    final starsNeeded = status.starsNeededForNext;

    return LuxePanel(
      radius: 20,
      glow: 10,
      borderColors: [LuxeColors.purple, next.bracket.glowColor, LuxeColors.gold],
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -------------------------------------------------------------------
          // Header: Next Milestone Preview
          // -------------------------------------------------------------------
          Row(
            children: [
              GifterBadgeWidget(
                level: next.level,
                bracket: next.bracket,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        text: 'NEXT: ',
                        style: const TextStyle(
                          color: LuxeColors.textDim,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                        children: [
                          TextSpan(
                            text: next.tierName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${_formatNumber(starsNeeded)} more Stars needed',
                      style: const TextStyle(
                        color: LuxeColors.goldLight,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (onNextMilestoneTap != null)
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    visualDensity: VisualDensity.compact,
                    backgroundColor: Colors.white.withValues(alpha: 0.06),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: onNextMilestoneTap,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Rewards',
                        style: TextStyle(
                          color: LuxeColors.gold,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: LuxeColors.gold, size: 14),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 10),

          // -------------------------------------------------------------------
          // Glowing Progress Bar
          // -------------------------------------------------------------------
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: status.progressToNext.clamp(0.02, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      colors: [
                        LuxeColors.purple,
                        LuxeColors.gold,
                        next.bracket.jewelColor,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: LuxeColors.gold.withValues(alpha: 0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          // -------------------------------------------------------------------
          // Progress Labels Row
          // -------------------------------------------------------------------
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lv ${status.currentLevel}',
                style: const TextStyle(
                  color: LuxeColors.textDim,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                decoration: BoxDecoration(
                  color: LuxeColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$percent%',
                  style: const TextStyle(
                    color: LuxeColors.gold,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                'Lv ${next.level}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // -------------------------------------------------------------------
          // Rewards Preview Chips
          // -------------------------------------------------------------------
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: next.rewards.take(3).map((reward) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: next.bracket.glowColor.withValues(alpha: 0.3),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      reward.category.icon,
                      size: 10,
                      color: next.bracket.jewelColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      reward.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  static String _formatNumber(int n) {
    if (n >= 1000000) {
      return '${(n / 1000000).toStringAsFixed(1)}M';
    } else if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}K';
    }
    return n.toString();
  }
}
