import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/luxe_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/models/gifter_level_model.dart';
import '../controllers/gifter_level_controller.dart';
import '../widgets/gifter_header_card.dart';
import '../widgets/gifter_milestone_card.dart';
import '../widgets/gifter_progress_card.dart';
import '../widgets/gifter_reward_detail_sheet.dart';

/// The main Gifter Level screen matching Tivoo's Luxe design system.
///
/// Responsive and overflow-proof across all phone and tablet dimensions.
class GifterLevelScreen extends ConsumerWidget {
  const GifterLevelScreen({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const GifterLevelScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gifterLevelControllerProvider);
    final controller = ref.read(gifterLevelControllerProvider.notifier);
    final status = state.userStatus;
    final milestones = state.filteredMilestones;

    final mediaQuery = MediaQuery.of(context);
    final bottomInset = mediaQuery.padding.bottom;
    final isTablet = context.isTablet;

    return Scaffold(
      backgroundColor: LuxeColors.bg,
      body: Stack(
        children: [
          const Positioned.fill(child: LuxeBackdrop()),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildTopBar(context, ref, status.currentLevel),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16, 6, 16, bottomInset + 20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: isTablet ? 700 : double.infinity,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Hero Gifter Status Card
                            GifterHeaderCard(
                              status: status,
                              onAvatarTap: () => _openMilestoneSheet(
                                context,
                                status.currentMilestone,
                                state.milestones,
                                status.currentLevel,
                              ),
                              onInfoTap: () => _showRulesSheet(context),
                            ),

                            const SizedBox(height: 12),

                            // 2. Next Milestone Progress Card
                            GifterProgressCard(
                              status: status,
                              onNextMilestoneTap: status.nextMilestone == null
                                  ? null
                                  : () => _openMilestoneSheet(
                                        context,
                                        status.nextMilestone!,
                                        state.milestones,
                                        status.currentLevel,
                                      ),
                            ),

                            const SizedBox(height: 18),

                            // 3. Milestones Section Header & Filters
                            _buildMilestonesHeader(context, state, controller),

                            const SizedBox(height: 12),

                            // 4. Milestones Display (Grid or Timeline)
                            if (milestones.isEmpty)
                              _buildEmptyState()
                            else if (state.isGridView)
                              _buildMilestoneGrid(context, state)
                            else
                              _buildMilestoneTimeline(context, state),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top App Bar
  // ---------------------------------------------------------------------------

  Widget _buildTopBar(BuildContext context, WidgetRef ref, int currentLevel) {
    final screenW = MediaQuery.sizeOf(context).width;
    final isSmall = screenW < 370;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          LuxeCircleButton(
            label: 'Back',
            icon: Icons.arrow_back_ios_new_rounded,
            size: 38,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const LuxeGoldText(
                  'Gifter Level',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  isSmall ? '19 Milestones' : '19 Milestone Prestige Tiers',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: LuxeColors.textDim,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Demo Switcher Pill
          GestureDetector(
            onTap: () => _showDemoLevelPicker(context, ref, currentLevel),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: LuxeColors.purple.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: LuxeColors.purple, width: 1.1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.tune_rounded, color: LuxeColors.goldLight, size: 13),
                  const SizedBox(width: 4),
                  Text(
                    isSmall ? 'Lv $currentLevel' : 'Demo Lv $currentLevel',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down_rounded, color: Colors.white70, size: 16),
                ],
              ),
            ),
          ),

          const SizedBox(width: 6),

          LuxeCircleButton(
            label: 'Rules',
            icon: Icons.help_outline_rounded,
            size: 38,
            onTap: () => _showRulesSheet(context),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Milestones Header
  // ---------------------------------------------------------------------------

  Widget _buildMilestonesHeader(
    BuildContext context,
    GifterLevelState state,
    GifterLevelController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Milestone Journey',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ViewModeIconButton(
                    icon: Icons.grid_view_rounded,
                    isSelected: state.isGridView,
                    onTap: () => controller.setGridView(true),
                    tooltip: 'Grid view',
                  ),
                  _ViewModeIconButton(
                    icon: Icons.view_timeline_rounded,
                    isSelected: !state.isGridView,
                    onTap: () => controller.setGridView(false),
                    tooltip: 'Timeline view',
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _FilterPill(
                label: 'All (${state.milestones.length})',
                isSelected: state.filter == MilestoneFilter.all,
                onTap: () => controller.setFilter(MilestoneFilter.all),
              ),
              const SizedBox(width: 6),
              _FilterPill(
                label: 'Unlocked (${state.unlockedCount})',
                isSelected: state.filter == MilestoneFilter.unlocked,
                onTap: () => controller.setFilter(MilestoneFilter.unlocked),
                badgeColor: const Color(0xFF00E676),
              ),
              const SizedBox(width: 6),
              _FilterPill(
                label: 'Locked (${state.lockedCount})',
                isSelected: state.filter == MilestoneFilter.locked,
                onTap: () => controller.setFilter(MilestoneFilter.locked),
                badgeColor: LuxeColors.textDim,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Milestones Grid
  // ---------------------------------------------------------------------------

  Widget _buildMilestoneGrid(BuildContext context, GifterLevelState state) {
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 600 ? 4 : 2;
    final cardHeight = width >= 600 ? 210.0 : 205.0;
    final userLevel = state.userStatus.currentLevel;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.filteredMilestones.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: cardHeight,
      ),
      itemBuilder: (context, index) {
        final milestone = state.filteredMilestones[index];
        final isCurrent = milestone.isCurrent(userLevel, state.milestones);

        return GifterMilestoneCard(
          milestone: milestone,
          userLevel: userLevel,
          isCurrent: isCurrent,
          isHorizontal: false,
          onTap: () => _openMilestoneSheet(
            context,
            milestone,
            state.milestones,
            userLevel,
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Milestones Timeline
  // ---------------------------------------------------------------------------

  Widget _buildMilestoneTimeline(BuildContext context, GifterLevelState state) {
    final userLevel = state.userStatus.currentLevel;
    final items = state.filteredMilestones;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final milestone = items[index];
        final isCurrent = milestone.isCurrent(userLevel, state.milestones);
        final isUnlocked = milestone.isUnlocked(userLevel);
        final isLast = index == items.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Connecting line & node
              SizedBox(
                width: 28,
                child: Column(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isCurrent
                            ? LuxeColors.goldGradient
                            : LinearGradient(
                                colors: isUnlocked
                                    ? milestone.bracket.gradientColors.take(2).toList()
                                    : [Colors.white24, Colors.white12],
                              ),
                        boxShadow: isUnlocked
                            ? [
                                BoxShadow(
                                  color: milestone.bracket.glowColor.withValues(alpha: 0.6),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: isUnlocked
                          ? Icon(
                              isCurrent ? Icons.star_rounded : Icons.check_rounded,
                              size: 12,
                              color: isCurrent ? Colors.black : Colors.white,
                            )
                          : const Icon(Icons.lock_rounded, size: 9, color: Colors.white54),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: isUnlocked
                              ? LuxeColors.purple.withValues(alpha: 0.5)
                              : Colors.white10,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Horizontal Card
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GifterMilestoneCard(
                    milestone: milestone,
                    userLevel: userLevel,
                    isCurrent: isCurrent,
                    isHorizontal: true,
                    onTap: () => _openMilestoneSheet(
                      context,
                      milestone,
                      state.milestones,
                      userLevel,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(28),
      alignment: Alignment.center,
      child: const Text(
        'No milestones match this filter.',
        style: TextStyle(color: LuxeColors.textDim, fontSize: 13),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Modals
  // ---------------------------------------------------------------------------

  void _openMilestoneSheet(
    BuildContext context,
    GifterMilestone milestone,
    List<GifterMilestone> allMilestones,
    int userLevel,
  ) {
    GifterRewardDetailSheet.show(
      context,
      milestone: milestone,
      allMilestones: allMilestones,
      userLevel: userLevel,
    );
  }

  void _showRulesSheet(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxH = (mediaQuery.size.height * 0.82).clamp(380.0, 680.0);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => SizedBox(
        height: maxH,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF0C0A26),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: LuxeColors.purple, width: 1.2)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.workspace_premium_rounded, color: LuxeColors.gold, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Gifter Level Rules',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const _RuleRow(
                          icon: Icons.star_rounded,
                          iconColor: LuxeColors.gold,
                          title: 'Eligible Stars Spent Only',
                          description:
                              'Only Stars spent on sending gifts to creators advance your Gifter Level. Purchasing Stars into your wallet alone does not increase your level.',
                        ),
                        const SizedBox(height: 12),
                        const _RuleRow(
                          icon: Icons.military_tech_rounded,
                          iconColor: Color(0xFF00E5FF),
                          title: '19 Landmark Milestones',
                          description:
                              '1, 5, 10, 15, 20, 25, 30, 35, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, and 50. Milestone rewards remain yours permanently once unlocked.',
                        ),
                        const SizedBox(height: 12),
                        const _RuleRow(
                          icon: Icons.shield_rounded,
                          iconColor: Color(0xFFE040FB),
                          title: 'Automatic Reward Equipping',
                          description:
                              'Your active profile frame, animated badge, and live room entrance effects automatically match your highest unlocked milestone tier.',
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: LuxeColors.purple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Understood', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDemoLevelPicker(BuildContext context, WidgetRef ref, int currentLevel) {
    final demoOptions = [1, 5, 10, 15, 18, 20, 25, 30, 35, 40, 42, 45, 48, 50];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0E0B2C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          border: Border(top: BorderSide(color: LuxeColors.gold, width: 1.1)),
        ),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Demo Level Switcher',
                  style: TextStyle(
                    color: LuxeColors.gold,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Select a simulated level to preview locked, unlocked, and current tier states:',
                  style: TextStyle(color: LuxeColors.textDim, fontSize: 11.5),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: demoOptions.map((lvl) {
                    final isSelected = lvl == currentLevel;
                    return ChoiceChip(
                      label: Text('Lv $lvl'),
                      selected: isSelected,
                      selectedColor: LuxeColors.gold,
                      backgroundColor: Colors.white.withValues(alpha: 0.06),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 11.5,
                      ),
                      onSelected: (_) {
                        ref.read(gifterLevelControllerProvider.notifier).setDemoLevel(lvl);
                        Navigator.pop(ctx);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ViewModeIconButton extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String tooltip;

  const _ViewModeIconButton({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      icon: Icon(icon, size: 17, color: isSelected ? LuxeColors.gold : Colors.white38),
      tooltip: tooltip,
      onPressed: onTap,
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? badgeColor;

  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? LuxeColors.purple.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? LuxeColors.violet : Colors.white12,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badgeColor != null) ...[
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(shape: BoxShape.circle, color: badgeColor),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : LuxeColors.textDim,
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RuleRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _RuleRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  color: LuxeColors.textDim,
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
