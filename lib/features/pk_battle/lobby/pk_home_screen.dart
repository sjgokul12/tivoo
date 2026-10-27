// PK Home: banner, status filters and the list of PK battles. Opened from the home screen's PK tab.

import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/luxe_theme.dart';
import '../../../core/utils/responsive.dart';
import '../core/pk_models.dart';
import '../pk_battle_live_screen.dart';
import 'pk_match_card.dart';

enum _PkFilter { all, ongoing, upcoming, result }

/// Lists PK battles (ongoing, upcoming, finished). Tapping an ongoing battle opens
/// [PkBattleLiveScreen] for it.
class PkHomeScreen extends StatefulWidget {
  final List<PkMatch>? matches;

  const PkHomeScreen({super.key, this.matches});

  static Future<void> push(BuildContext context) {
    return Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PkHomeScreen()));
  }

  @override
  State<PkHomeScreen> createState() => _PkHomeScreenState();
}

class _PkHomeScreenState extends State<PkHomeScreen> {
  _PkFilter _filter = _PkFilter.all;
  final Set<String> _following = {};

  List<PkMatch> get _matches {
    final all = widget.matches ?? PkDemoData.matches;
    return switch (_filter) {
      _PkFilter.all => all,
      _PkFilter.ongoing => all.where((m) => m.status == PkMatchStatus.ongoing).toList(),
      _PkFilter.upcoming => all.where((m) => m.status == PkMatchStatus.upcoming).toList(),
      _PkFilter.result => all.where((m) => m.status == PkMatchStatus.ended).toList(),
    };
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }

  void _watchOngoingBattles() {
    final ongoing = _matches.where((m) => m.status == PkMatchStatus.ongoing).toList();
    if (ongoing.isNotEmpty) {
      _open(ongoing.first);
    } else {
      setState(() => _filter = _PkFilter.ongoing);
    }
  }

  void _open(PkMatch match) {
    switch (match.status) {
      case PkMatchStatus.ongoing:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PkBattleLiveScreen(match: match, onBack: () => Navigator.of(context).pop()),
          ),
        );
      case PkMatchStatus.upcoming:
        _toast('⏰ We\'ll remind you when ${match.left.name} vs ${match.right.name} starts at ${match.startsAt}');
      case PkMatchStatus.ended:
        _toast('🏆 ${match.winner.name} won  ${match.leftScore} – ${match.rightScore}');
    }
  }

  void _toggleFollow(PkHost host) {
    setState(() => _following.contains(host.name) ? _following.remove(host.name) : _following.add(host.name));
    _toast(_following.contains(host.name) ? 'Now following ${host.name}' : 'Unfollowed ${host.name}');
  }

  @override
  Widget build(BuildContext context) {
    final matches = _matches;
    final gutter = context.pageGutter;
    final columns = context.isTablet ? 2 : 1;

    return Scaffold(
      backgroundColor: const Color(0xFF07070D),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _Header(onBack: () => Navigator.of(context).maybePop())),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(gutter, 8, gutter, 4),
              // Capped on tablets so the banner doesn't dominate the list.
              sliver: SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: _PkBanner(onTap: _watchOngoingBattles),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _FilterTabs(selected: _filter, onSelected: (f) => setState(() => _filter = f)),
            ),
            if (matches.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text('No PK battles here yet', style: TextStyle(color: Colors.white54, fontSize: 14)),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(gutter, 4, gutter, 24 + context.padding.bottom),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: PkMatchCard.aspectRatio,
                  ),
                  delegate: SliverChildBuilderDelegate(childCount: matches.length, (context, index) {
                    final match = matches[index];
                    return PkMatchCard(
                      match: match,
                      isFollowingRight: _following.contains(match.right.name),
                      onTap: () => _open(match),
                      onFollowTap: () => _toggleFollow(match.right),
                    );
                  }),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// [‹]                PK                    — title with a glowing gold underline.
class _Header extends StatelessWidget {
  final VoidCallback onBack;
  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 4,
            child: IconButton(
              tooltip: 'Back',
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            ),
          ),
          Image.asset(AppAssets.pkTopBanner, height: 46, fit: BoxFit.contain, filterQuality: FilterQuality.medium),
        ],
      ),
    );
  }
}

/// PK Hero Banner styled matching the Home screen hero banner (AppAssets.bannerPk,
/// LuxeDecor.border with gold/violet/blue, PK BATTLE tag, Pacifico script highlight,
/// and LuxeDecor.goldButton call-to-action).
class _PkBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _PkBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.35,
      child: Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [LuxeColors.goldLight, LuxeColors.gold, LuxeColors.violet, LuxeColors.blue],
            stops: [0, 0.25, 0.65, 1],
          ),
          boxShadow: const [
            BoxShadow(color: Color(0x55FFC928), blurRadius: 18, offset: Offset(-3, 3)),
            BoxShadow(color: Color(0x557B4DFF), blurRadius: 18, offset: Offset(3, 3)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.5),
          child: GestureDetector(
            onTap: onTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background artwork from Home Screen Hero Banner
                Image.asset(
                  AppAssets.bannerPk,
                  fit: BoxFit.cover,
                  alignment: const Alignment(0.6, 0),
                  errorBuilder: (_, _, _) => const ColoredBox(color: LuxeColors.bgTop),
                ),
                // Gradient vignette for copy readability
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xE608071A), Color(0xB308071A), Color(0x3308071A)],
                      stops: [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
                // Banner Content
                LayoutBuilder(
                  builder: (context, c) {
                    final h = c.maxHeight;
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: h * 0.1, vertical: h * 0.08),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Tag chip
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: h * 0.05, vertical: h * 0.016),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFFFF4FB8), Color(0xFF4F8BFF)]),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: const [BoxShadow(color: Color(0x66FF4FB8), blurRadius: 8)],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bolt_rounded, color: Colors.white, size: h * 0.075),
                                SizedBox(width: h * 0.02),
                                Text(
                                  'PK BATTLE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: h * 0.055,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: h * 0.04),
                          Text(
                            'Tonight 9 PM',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: h * 0.115,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                              shadows: const [Shadow(color: Color(0xCC000000), blurRadius: 6)],
                            ),
                          ),
                          LuxeGoldText(
                            'Clash of Stars',
                            style: TextStyle(
                              fontFamily: 'Pacifico',
                              fontSize: h * 0.11,
                              height: 1.3,
                              shadows: const [Shadow(color: Color(0x99FFC928), blurRadius: 10)],
                            ),
                          ),
                          Text(
                            'Support your favorite live stars & send power',
                            style: TextStyle(
                              color: const Color(0xFFDCD6F5),
                              fontSize: h * 0.058,
                              fontWeight: FontWeight.w500,
                              shadows: const [Shadow(color: Color(0xCC000000), blurRadius: 6)],
                            ),
                          ),
                          SizedBox(height: h * 0.05),
                          // CTA Gold button with yellow tint
                          Container(
                            padding: EdgeInsets.fromLTRB(h * 0.05, h * 0.022, h * 0.06, h * 0.022),
                            decoration: LuxeDecor.goldButton(radius: 30),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.play_arrow_rounded, color: const Color(0xFF1F1400), size: h * 0.075),
                                SizedBox(width: h * 0.02),
                                Text(
                                  'Watch Battles',
                                  style: TextStyle(
                                    color: const Color(0xFF1F1400),
                                    fontSize: h * 0.065,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(width: h * 0.02),
                                Icon(Icons.arrow_forward_rounded, color: const Color(0xFF1F1400), size: h * 0.065),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// All · Ongoing · Upcoming · Result — the selected filter has a yellow/gold tint pill.
class _FilterTabs extends StatelessWidget {
  final _PkFilter selected;
  final ValueChanged<_PkFilter> onSelected;

  const _FilterTabs({required this.selected, required this.onSelected});

  static const _labels = {
    _PkFilter.all: 'All',
    _PkFilter.ongoing: 'Ongoing',
    _PkFilter.upcoming: 'Upcoming',
    _PkFilter.result: 'Result',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.pageGutter, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (final entry in _labels.entries)
            Flexible(
              child: Semantics(
                button: true,
                selected: entry.key == selected,
                label: entry.value,
                child: GestureDetector(
                  onTap: () => onSelected(entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(horizontal: context.rs(14), vertical: context.rs(8)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: entry.key == selected ? LuxeColors.goldGradient : null,
                      color: entry.key == selected ? null : Colors.white.withValues(alpha: 0.06),
                      border: entry.key == selected ? null : Border.all(color: Colors.white.withValues(alpha: 0.1)),
                      boxShadow: entry.key == selected
                          ? const [BoxShadow(color: Color(0x66FFC928), blurRadius: 10)]
                          : null,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          color: entry.key == selected ? const Color(0xFF1F1400) : const Color(0xFFB0B0B8),
                          fontSize: context.sp(13.5),
                          fontWeight: entry.key == selected ? FontWeight.w900 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
