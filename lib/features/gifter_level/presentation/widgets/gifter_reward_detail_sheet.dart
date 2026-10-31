import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/luxe_theme.dart';
import '../../domain/models/gifter_level_model.dart';
import 'gifter_frame_preview.dart';

/// Modal bottom sheet detailing a milestone's rewards, frame preview, and perks.
///
/// Designed to be completely responsive and overflow-proof on all phone heights and widths.
class GifterRewardDetailSheet extends StatefulWidget {
  final GifterMilestone milestone;
  final List<GifterMilestone> allMilestones;
  final int userLevel;
  final ValueChanged<GifterMilestone>? onMilestoneChanged;

  const GifterRewardDetailSheet({
    super.key,
    required this.milestone,
    required this.allMilestones,
    required this.userLevel,
    this.onMilestoneChanged,
  });

  static Future<void> show(
    BuildContext context, {
    required GifterMilestone milestone,
    required List<GifterMilestone> allMilestones,
    required int userLevel,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => GifterRewardDetailSheet(
        milestone: milestone,
        allMilestones: allMilestones,
        userLevel: userLevel,
      ),
    );
  }

  @override
  State<GifterRewardDetailSheet> createState() => _GifterRewardDetailSheetState();
}

class _GifterRewardDetailSheetState extends State<GifterRewardDetailSheet> {
  late GifterMilestone _currentMilestone;

  @override
  void initState() {
    super.initState();
    _currentMilestone = widget.milestone;
  }

  int get _currentIndex =>
      widget.allMilestones.indexWhere((m) => m.level == _currentMilestone.level);

  bool get _hasPrevious => _currentIndex > 0;
  bool get _hasNext => _currentIndex < widget.allMilestones.length - 1;

  void _goToPrevious() {
    if (_hasPrevious) {
      setState(() => _currentMilestone = widget.allMilestones[_currentIndex - 1]);
      widget.onMilestoneChanged?.call(_currentMilestone);
    }
  }

  void _goToNext() {
    if (_hasNext) {
      setState(() => _currentMilestone = widget.allMilestones[_currentIndex + 1]);
      widget.onMilestoneChanged?.call(_currentMilestone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = _currentMilestone;
    final bracket = m.bracket;
    final isUnlocked = m.isUnlocked(widget.userLevel);
    final isCurrent = m.isCurrent(widget.userLevel, widget.allMilestones);

    final mediaQuery = MediaQuery.of(context);
    final sheetHeight = (mediaQuery.size.height * 0.85).clamp(420.0, 720.0);
    final bottomPadding = mediaQuery.padding.bottom;

    return SizedBox(
      height: sheetHeight,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0C0A26),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          border: Border.all(
            color: bracket.glowColor.withValues(alpha: 0.5),
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: bracket.glowColor.withValues(alpha: 0.25),
              blurRadius: 24,
            ),
          ],
        ),
        child: Column(
          children: [
            // Drag Handle
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Top Bar with Close
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  const Text(
                    'Milestone Reward Preview',
                    style: TextStyle(
                      color: LuxeColors.textDim,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white10, height: 1),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                child: Column(
                  children: [
                    // Hero Frame & Badge Preview
                    GifterFramePreview(
                      size: 96,
                      bracket: bracket,
                      level: m.level,
                      avatarAsset: AppAssets.status5,
                      showBadge: true,
                    ),

                    const SizedBox(height: 14),

                    // Tier Name & Level
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: LuxeGoldText(
                        'Level ${m.level} • ${m.tierName}',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),

                    const SizedBox(height: 5),

                    // Status Pill
                    _buildStatusPill(isCurrent, isUnlocked, m.level),

                    const SizedBox(height: 8),

                    // Description
                    Text(
                      m.description,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: LuxeColors.textMuted,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Threshold Notice (Placeholder)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, color: bracket.jewelColor, size: 15),
                          const SizedBox(width: 5),
                          Text(
                            'Threshold: ${_formatNumber(m.starsThresholdPlaceholder)} Stars Spent (Demo)',
                            style: TextStyle(
                              color: bracket.jewelColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Specified Rewards Header
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          const Icon(Icons.workspace_premium_rounded,
                              color: LuxeColors.gold, size: 15),
                          const SizedBox(width: 6),
                          Text(
                            'UNLOCKED PERKS (${m.rewards.length})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    ...m.rewards.map((reward) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _RewardItemTile(
                          reward: reward,
                          bracket: bracket,
                          isUnlocked: isUnlocked,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Bottom Navigation: Previous & Next Milestones
            Container(
              padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + bottomPadding),
              decoration: const BoxDecoration(
                color: Color(0xFF08061B),
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _hasPrevious ? _goToPrevious : null,
                      icon: const Icon(Icons.arrow_back_ios_rounded, size: 13),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _hasPrevious
                              ? 'Lv ${widget.allMilestones[_currentIndex - 1].level}'
                              : 'First',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: LuxeColors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: _hasNext ? _goToNext : null,
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _hasNext
                              ? 'Lv ${widget.allMilestones[_currentIndex + 1].level}'
                              : 'Max Level',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusPill(bool isCurrent, bool isUnlocked, int level) {
    if (isCurrent) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          gradient: LuxeColors.goldGradient,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [BoxShadow(color: Color(0x66FFC928), blurRadius: 6)],
        ),
        child: const Text(
          '👑 YOUR CURRENT LEVEL',
          style: TextStyle(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.3,
          ),
        ),
      );
    } else if (isUnlocked) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0x2600E676),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF00E676)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF00E676), size: 12),
            SizedBox(width: 4),
            Text(
              'UNLOCKED & ACTIVE',
              style: TextStyle(
                color: Color(0xFF00E676),
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_rounded, color: LuxeColors.textDim, size: 11),
            const SizedBox(width: 4),
            Text(
              'LOCKED • REACH LEVEL $level',
              style: const TextStyle(
                color: LuxeColors.textDim,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }
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

class _RewardItemTile extends StatelessWidget {
  final GifterReward reward;
  final GifterTierBracket bracket;
  final bool isUnlocked;

  const _RewardItemTile({
    required this.reward,
    required this.bracket,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked ? bracket.glowColor.withValues(alpha: 0.3) : Colors.white10,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              gradient: LinearGradient(
                colors: isUnlocked
                    ? bracket.gradientColors.take(2).toList()
                    : [Colors.white24, Colors.white10],
              ),
            ),
            child: Icon(
              reward.category.icon,
              color: isUnlocked ? Colors.black87 : Colors.white60,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        reward.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isUnlocked ? Colors.white : Colors.white70,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        reward.category.label,
                        style: TextStyle(
                          color: isUnlocked ? bracket.jewelColor : LuxeColors.textDim,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  reward.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: LuxeColors.textMuted,
                    fontSize: 10.5,
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
}
