import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/luxe_theme.dart';
import '../../domain/models/gifter_level_model.dart';
import 'gifter_badge_widget.dart';
import 'gifter_frame_preview.dart';

/// The Hero Showcase at the top of the Gifter Level screen.
///
/// Responsive and overflow-proof across all mobile screen dimensions.
class GifterHeaderCard extends StatelessWidget {
  final GifterUserStatus status;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onInfoTap;

  const GifterHeaderCard({
    super.key,
    required this.status,
    this.onAvatarTap,
    this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentMilestone = status.currentMilestone;
    final bracket = currentMilestone.bracket;
    final screenW = MediaQuery.sizeOf(context).width;
    final isSmall = screenW < 370;
    final avatarSize = isSmall ? 74.0 : 84.0;

    return LuxePanel(
      radius: 22,
      glow: 16,
      borderColors: [LuxeColors.gold, bracket.glowColor, LuxeColors.purple],
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 14 : 16, vertical: 16),
      child: Column(
        children: [
          // -------------------------------------------------------------------
          // Top Row: Avatar with Frame + Tier Name & Level
          // -------------------------------------------------------------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: onAvatarTap,
                child: GifterFramePreview(
                  size: avatarSize,
                  bracket: bracket,
                  level: status.currentLevel,
                  avatarAsset: AppAssets.status5,
                  showBadge: true,
                ),
              ),
              const SizedBox(width: 14),

              // Level & Tier Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GifterBadgeWidget(
                          level: status.currentLevel,
                          bracket: bracket,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: LuxeColors.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: LuxeColors.gold.withValues(alpha: 0.4)),
                          ),
                          child: const Text(
                            'ACTIVE STATUS',
                            style: TextStyle(
                              color: LuxeColors.gold,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: LuxeGoldText(
                        status.tierName,
                        style: TextStyle(
                          fontSize: isSmall ? 18 : 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),

                    Text(
                      currentMilestone.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: LuxeColors.textMuted,
                        fontSize: 11.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 12),

          // -------------------------------------------------------------------
          // Stars Spending Stats Row
          // -------------------------------------------------------------------
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  icon: Icons.auto_awesome_rounded,
                  iconColor: LuxeColors.gold,
                  title: 'Eligible Stars Spent',
                  value: _formatNumber(status.starsSpentOnGifts),
                  subtitle: 'Count toward Level',
                  isHighlighted: true,
                ),
              ),
              Container(width: 1, height: 38, color: Colors.white12),
              Expanded(
                child: _MetricTile(
                  icon: Icons.account_balance_wallet_outlined,
                  iconColor: const Color(0xFF8C88B5),
                  title: 'Purchased Stars',
                  value: _formatNumber(status.purchasedStarsTotal),
                  subtitle: 'Wallet balance only',
                  isHighlighted: false,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // -------------------------------------------------------------------
          // Important Notice Pill
          // -------------------------------------------------------------------
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 14, color: LuxeColors.textDim),
                const SizedBox(width: 7),
                const Expanded(
                  child: Text(
                    'Only Stars spent on gifts advance level. Purchasing Stars does not increase level.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: LuxeColors.textDim,
                      fontSize: 10.5,
                      height: 1.25,
                    ),
                  ),
                ),
                if (onInfoTap != null)
                  GestureDetector(
                    onTap: onInfoTap,
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: LuxeColors.gold,
                      size: 16,
                    ),
                  ),
              ],
            ),
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

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;
  final bool isHighlighted;

  const _MetricTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: iconColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: LuxeColors.textDim,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: isHighlighted ? LuxeColors.gold : Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 3),
                const Text('⭐', style: TextStyle(fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(height: 1),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isHighlighted
                  ? LuxeColors.goldLight.withValues(alpha: 0.8)
                  : LuxeColors.textMuted,
              fontSize: 9.5,
            ),
          ),
        ],
      ),
    );
  }
}
