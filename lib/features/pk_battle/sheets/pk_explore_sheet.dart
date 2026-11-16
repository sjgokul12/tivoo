import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/custom_avatar.dart';
import '../core/pk_models.dart';

/// Smooth bottom sheet covering ~70% of the screen displaying mock PK battles
/// with Ongoing, Upcoming, and Results tabs.
class PkExploreSheet extends StatelessWidget {
  final ValueChanged<PkMatch> onSelectBattle;
  final String? currentMatchId;

  const PkExploreSheet({
    super.key,
    required this.onSelectBattle,
    this.currentMatchId,
  });

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<PkMatch> onSelectBattle,
    String? currentMatchId,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => PkExploreSheet(
        onSelectBattle: onSelectBattle,
        currentMatchId: currentMatchId,
      ),
    );
  }

  // --- Mock Battles Data -----------------------------------------------------

  static PkHost _host(String name, String avatar, String video, String likes, String viewers) =>
      PkHost(name: name, avatarAsset: avatar, videoAsset: video, likes: likes, viewers: viewers);

  static final List<PkMatch> _ongoingBattles = [
    PkMatch(
      id: 'pk_priya_anu',
      left: _host('Priya', AppAssets.avatarPriya, AppAssets.video1, '88.1K', '8.4K'),
      right: _host('Anu', AppAssets.avatarMeena, AppAssets.video2, '76.4K', '8.4K'),
      status: PkMatchStatus.ongoing,
      viewers: '16.8K',
      cover: AppAssets.pkCoverPriyaAnu,
      leftScore: 19020,
      rightScore: 16640,
      secondsLeft: 212,
    ),
    PkMatch(
      id: 'pk_sweety_nila',
      left: _host('Sweety', AppAssets.homeCard1, AppAssets.video2, '61.0K', '4.8K'),
      right: _host('Nila', AppAssets.avatarSneha, AppAssets.video1, '57.3K', '4.8K'),
      status: PkMatchStatus.ongoing,
      viewers: '11.2K',
      cover: AppAssets.pkCoverSweetyNila,
      leftScore: 9870,
      rightScore: 11340,
      secondsLeft: 168,
    ),
    PkMatch(
      id: 'pk_angel_divya',
      left: _host('Angel', AppAssets.status3, AppAssets.video2, '44.9K', '2.6K'),
      right: _host('Divya', AppAssets.avatarDiya, AppAssets.video1, '39.2K', '2.6K'),
      status: PkMatchStatus.ongoing,
      viewers: '7.5K',
      cover: AppAssets.pkCoverAngelDivya,
      leftScore: 7420,
      rightScore: 6980,
      secondsLeft: 95,
    ),
    PkMatch(
      id: 'pk_karthik_vicky',
      left: _host('Karthik', AppAssets.avatarKarthik, AppAssets.video1, '68.4K', '5.1K'),
      right: _host('Vicky', AppAssets.avatarVicky, AppAssets.video2, '54.2K', '5.1K'),
      status: PkMatchStatus.ongoing,
      viewers: '13.4K',
      cover: AppAssets.pkCoverMeenaSneha,
      leftScore: 14200,
      rightScore: 13850,
      secondsLeft: 240,
    ),
    PkMatch(
      id: 'pk_meena_neha',
      left: _host('Meena', AppAssets.avatarMeena, AppAssets.video2, '52.7K', '3.8K'),
      right: _host('Neha', AppAssets.avatarNeha, AppAssets.video1, '48.9K', '3.8K'),
      status: PkMatchStatus.ongoing,
      viewers: '8.9K',
      cover: AppAssets.pkCoverSweetyNila,
      leftScore: 8110,
      rightScore: 7950,
      secondsLeft: 180,
    ),
  ];

  static final List<PkMatch> _upcomingBattles = [
    PkMatch(
      id: 'pk_up_diya_priya',
      left: _host('Diya', AppAssets.avatarDiya, AppAssets.video2, '70.3K', '0'),
      right: _host('Priya', AppAssets.avatarPriya, AppAssets.video1, '88.1K', '0'),
      status: PkMatchStatus.upcoming,
      viewers: '2.4K',
      cover: AppAssets.pkCoverDiyaPriya,
      startsAt: 'Starts in 15m',
    ),
    PkMatch(
      id: 'pk_up_arun_saran',
      left: _host('Arun', AppAssets.avatarArun, AppAssets.video1, '59.1K', '0'),
      right: _host('Saran', AppAssets.avatarSaran, AppAssets.video2, '51.8K', '0'),
      status: PkMatchStatus.upcoming,
      viewers: '1.8K',
      cover: AppAssets.pkCoverAngelDivya,
      startsAt: 'Today, 9:00 PM',
    ),
    PkMatch(
      id: 'pk_up_sneha_meena',
      left: _host('Sneha', AppAssets.avatarSneha, AppAssets.video1, '49.8K', '0'),
      right: _host('Meena', AppAssets.avatarMeena, AppAssets.video2, '52.7K', '0'),
      status: PkMatchStatus.upcoming,
      viewers: '3.1K',
      cover: AppAssets.pkCoverMeenaSneha,
      startsAt: 'Tomorrow, 7:00 PM',
    ),
  ];

  static final List<PkMatch> _resultsBattles = [
    PkMatch(
      id: 'pk_res_diya_priya',
      left: _host('Diya', AppAssets.avatarDiya, AppAssets.video2, '70.3K', '0'),
      right: _host('Priya', AppAssets.avatarPriya, AppAssets.video1, '88.1K', '0'),
      status: PkMatchStatus.ended,
      viewers: '15.8K',
      cover: AppAssets.pkCoverDiyaPriya,
      leftScore: 24110,
      rightScore: 19870,
    ),
    PkMatch(
      id: 'pk_res_sweety_divya',
      left: _host('Sweety', AppAssets.homeCard1, AppAssets.video2, '61.0K', '0'),
      right: _host('Divya', AppAssets.avatarDiya, AppAssets.video1, '39.2K', '0'),
      status: PkMatchStatus.ended,
      viewers: '12.1K',
      cover: AppAssets.pkCoverSweetyNila,
      leftScore: 18340,
      rightScore: 21500,
    ),
    PkMatch(
      id: 'pk_res_angel_nila',
      left: _host('Angel', AppAssets.status3, AppAssets.video2, '44.9K', '0'),
      right: _host('Nila', AppAssets.avatarSneha, AppAssets.video1, '57.3K', '0'),
      status: PkMatchStatus.ended,
      viewers: '9.4K',
      cover: AppAssets.pkCoverAngelDivya,
      leftScore: 15900,
      rightScore: 12400,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final sheetHeight = media.height * 0.70;

    return DefaultTabController(
      length: 3,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: sheetHeight,
            decoration: BoxDecoration(
              color: const Color(0xF2100A26),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
              border: Border.all(
                color: const Color(0x3300E5FF),
                width: 1.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x6600E5FF),
                  blurRadius: 28,
                  spreadRadius: 1,
                  offset: Offset(0, -4),
                ),
                BoxShadow(
                  color: Colors.black87,
                  blurRadius: 36,
                ),
              ],
            ),
            child: Column(
              children: [
                // Top drag handle
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    width: 42,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Header with Title & Close button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                          border: Border.all(
                            color: const Color(0xFF00E5FF).withValues(alpha: 0.5),
                            width: 1.2,
                          ),
                        ),
                        child: const Icon(
                          Icons.explore_rounded,
                          color: Color(0xFF00E5FF),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Explore PK Battles',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white70,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 6),

                // Tab Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF191238),
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: TabBar(
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(19),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00E5FF), Color(0xFFFF2DB4)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF2DB4).withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 0.5,
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white54,
                    labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                    unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('●', style: TextStyle(color: Color(0xFFFF2D55), fontSize: 10)),
                            SizedBox(width: 5),
                            Text('Ongoing'),
                          ],
                        ),
                      ),
                      Tab(text: 'Upcoming'),
                      Tab(text: 'Results'),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Tab Views with mock battle cards
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildBattleList(context, _ongoingBattles, isOngoing: true),
                      _buildBattleList(context, _upcomingBattles, isUpcoming: true),
                      _buildBattleList(context, _resultsBattles, isResults: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBattleList(
    BuildContext context,
    List<PkMatch> battles, {
    bool isOngoing = false,
    bool isUpcoming = false,
    bool isResults = false,
  }) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
      physics: const BouncingScrollPhysics(),
      itemCount: battles.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final battle = battles[index];
        final isCurrent = battle.id == currentMatchId;

        return _PkBattleCard(
          battle: battle,
          isCurrent: isCurrent,
          isOngoing: isOngoing,
          isUpcoming: isUpcoming,
          isResults: isResults,
          onWatch: () {
            Navigator.of(context).pop();
            onSelectBattle(battle);
          },
        );
      },
    );
  }
}

/// Glassmorphic PK Battle Card matching Tivoo's dark purple, neon cyan and pink style
class _PkBattleCard extends StatelessWidget {
  final PkMatch battle;
  final bool isCurrent;
  final bool isOngoing;
  final bool isUpcoming;
  final bool isResults;
  final VoidCallback onWatch;

  const _PkBattleCard({
    required this.battle,
    required this.isCurrent,
    required this.isOngoing,
    required this.isUpcoming,
    required this.isResults,
    required this.onWatch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrent ? const Color(0x4000E5FF) : const Color(0xB316103A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isCurrent
              ? const Color(0xFF00E5FF)
              : const Color(0x3300E5FF),
          width: isCurrent ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrent
                ? const Color(0x4400E5FF)
                : const Color(0x22FF2DB4),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Row: Streamer 1 vs Streamer 2
          Row(
            children: [
              // Left Streamer
              Expanded(
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF00E5FF), width: 1.5),
                        boxShadow: const [
                          BoxShadow(color: Color(0x5500E5FF), blurRadius: 8),
                        ],
                      ),
                      child: CustomAvatar(
                        radius: 19,
                        assetPath: battle.left.avatarAsset,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            battle.left.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (isResults)
                            Text(
                              '${battle.leftScore}',
                              style: TextStyle(
                                color: battle.leftScore >= battle.rightScore
                                    ? const Color(0xFFFFD700)
                                    : Colors.white54,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            )
                          else
                            Text(
                              battle.left.likes,
                              style: const TextStyle(
                                color: Color(0xFF00E5FF),
                                fontSize: 10.5,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Center VS Indicator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E5FF), Color(0xFFFF2DB4)],
                    ),
                    boxShadow: const [
                      BoxShadow(color: Color(0x66FF2DB4), blurRadius: 8),
                    ],
                  ),
                  child: const Text(
                    'VS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              // Right Streamer
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            battle.right.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (isResults)
                            Text(
                              '${battle.rightScore}',
                              style: TextStyle(
                                color: battle.rightScore > battle.leftScore
                                    ? const Color(0xFFFFD700)
                                    : Colors.white54,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            )
                          else
                            Text(
                              battle.right.likes,
                              style: const TextStyle(
                                color: Color(0xFFFF2DB4),
                                fontSize: 10.5,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFF2DB4), width: 1.5),
                        boxShadow: const [
                          BoxShadow(color: Color(0x55FF2DB4), blurRadius: 8),
                        ],
                      ),
                      child: CustomAvatar(
                        radius: 19,
                        assetPath: battle.right.avatarAsset,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Bottom Action Row: Status badge / viewers & "Watch Battle" button
          Row(
            children: [
              // Status Badge
              if (isOngoing)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0x26FF2D55),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0x66FF2D55)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('●', style: TextStyle(color: Color(0xFFFF2D55), fontSize: 9)),
                      const SizedBox(width: 4),
                      const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Color(0xFFFF2D55),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '🔥 ${battle.viewers}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else if (isUpcoming)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0x2600E5FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0x6600E5FF)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.alarm_rounded, color: Color(0xFF00E5FF), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        battle.startsAt ?? 'Coming Soon',
                        style: const TextStyle(
                          color: Color(0xFF00E5FF),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: const Color(0x26FFD700),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0x66FFD700)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD700), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        'Winner: ${battle.winner.name}',
                        style: const TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

              const Spacer(),

              // "Watch Battle" Button
              SizedBox(
                height: 32,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: isCurrent
                          ? [Colors.white24, Colors.white12]
                          : [const Color(0xFF00E5FF), const Color(0xFFFF2DB4)],
                    ),
                    boxShadow: isCurrent
                        ? null
                        : [
                            BoxShadow(
                              color: const Color(0xFFFF2DB4).withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: ElevatedButton(
                    onPressed: isCurrent ? null : onWatch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isCurrent
                              ? Icons.check_circle_rounded
                              : (isUpcoming ? Icons.notifications_active_rounded : Icons.play_arrow_rounded),
                          color: Colors.white,
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          isCurrent
                              ? 'Watching'
                              : (isUpcoming ? 'Preview' : (isResults ? 'Replay' : 'Watch Battle')),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
