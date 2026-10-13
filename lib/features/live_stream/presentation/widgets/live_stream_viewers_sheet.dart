import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/custom_avatar.dart';
import 'viewer_profile_screen.dart';

/// Interactive Viewers List Bottom Sheet matching Image 2 (Screen 2):
/// - Header: "Viewers (85,432)" with close [✕] button
/// - Tabs: "All Viewers", "Top Viewers", "Recent" with callout "Switch to see latest viewers"
/// - Ranked list with Gold/Silver/Bronze badges (1, 2, 3) and numbered badges (4 to 10)
/// - User avatar, Name (with crown), "Watching for Xh Ym", and [Follow] / [Following] button
/// - Tapping any viewer opens their full Profile Screen (Image 2 Screen 3 & Image 3 Screen 3)
class LiveStreamViewersSheet extends StatefulWidget {
  final String totalViewersCount;

  const LiveStreamViewersSheet({
    super.key,
    this.totalViewersCount = '85,432',
  });

  static Future<void> show(
    BuildContext context, {
    String totalViewersCount = '85,432',
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LiveStreamViewersSheet(
        totalViewersCount: totalViewersCount,
      ),
    );
  }

  @override
  State<LiveStreamViewersSheet> createState() => _LiveStreamViewersSheetState();
}

class _LiveStreamViewersSheetState extends State<LiveStreamViewersSheet> {
  int _selectedTab = 0; // 0 = All Viewers, 1 = Top Viewers, 2 = Recent

  // Viewer list data matching Image 2 Screen 2
  final List<Map<String, dynamic>> _viewers = [
    {
      'rank': 1,
      'name': 'Queen_Anu',
      'hasCrown': true,
      'watchTime': 'Watching for 2h 12m',
      'avatar': AppAssets.status4,
      'isFollowing': false,
    },
    {
      'rank': 2,
      'name': 'Karthik_07',
      'hasCrown': false,
      'watchTime': 'Watching for 1h 48m',
      'avatar': AppAssets.status5,
      'isFollowing': false,
    },
    {
      'rank': 3,
      'name': 'Priya_Love',
      'hasCrown': false,
      'watchTime': 'Watching for 1h 20m',
      'avatar': AppAssets.status3,
      'isFollowing': true,
    },
    {
      'rank': 4,
      'name': 'Vicky_S',
      'hasCrown': false,
      'watchTime': 'Watching for 58m',
      'avatar': AppAssets.status2,
      'isFollowing': false,
    },
    {
      'rank': 5,
      'name': 'Nandhu_Official',
      'hasCrown': false,
      'watchTime': 'Watching for 45m',
      'avatar': AppAssets.status1,
      'isFollowing': false,
    },
    {
      'rank': 6,
      'name': 'Sweety_Girl',
      'hasCrown': false,
      'watchTime': 'Watching for 32m',
      'avatar': AppAssets.avatarSneha,
      'isFollowing': false,
    },
    {
      'rank': 7,
      'name': 'Mani_Raj',
      'hasCrown': false,
      'watchTime': 'Watching for 28m',
      'avatar': AppAssets.avatarSaran,
      'isFollowing': true,
    },
    {
      'rank': 8,
      'name': 'Divya_Creations',
      'hasCrown': false,
      'watchTime': 'Watching for 20m',
      'avatar': AppAssets.avatarDiya,
      'isFollowing': false,
    },
    {
      'rank': 9,
      'name': 'Hari_Editz',
      'hasCrown': false,
      'watchTime': 'Watching for 15m',
      'avatar': AppAssets.avatarArun,
      'isFollowing': false,
    },
    {
      'rank': 10,
      'name': 'Lovely_Sana',
      'hasCrown': false,
      'watchTime': 'Watching for 10m',
      'avatar': AppAssets.avatarMeena,
      'isFollowing': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.78;

    return Container(
      height: sheetHeight,
      decoration: const BoxDecoration(
        color: Color(0xFF0F0E18),
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        border: Border(
          top: BorderSide(color: Color(0x3300E5FF), width: 1.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 30,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Drag Handle
            const SizedBox(height: 10),
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),

            // Header Title: Viewers (85,432) & Close Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 32),
                  Text(
                    'Viewers (${widget.totalViewersCount})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Tabs Row: All Viewers | Top Viewers | Recent
            _buildTabsRow(),

            const SizedBox(height: 6),

            // Viewer List
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _viewers.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final viewer = _viewers[index];
                  return _buildViewerItem(viewer, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                _buildTabPill('All Viewers', 0),
                _buildTabPill('Top Viewers', 1),
                _buildTabPill('Recent', 2),
              ],
            ),
          ),

          // Yellow Callout tooltip pointing to Recent ("Switch to see latest viewers")
          Positioned(
            right: 0,
            top: -24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD600),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Text(
                'Switch to see latest viewers',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabPill(String title, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E5BFF) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewerItem(Map<String, dynamic> viewer, int index) {
    final rank = viewer['rank'] as int;
    final name = viewer['name'] as String;
    final hasCrown = viewer['hasCrown'] as bool;
    final watchTime = viewer['watchTime'] as String;
    final avatar = viewer['avatar'] as String;
    final isFollowing = viewer['isFollowing'] as bool;

    Color badgeColor;
    if (rank == 1) {
      badgeColor = const Color(0xFFFFD700); // Gold
    } else if (rank == 2) {
      badgeColor = const Color(0xFFE0E0E0); // Silver
    } else if (rank == 3) {
      badgeColor = const Color(0xFFCD7F32); // Bronze
    } else {
      badgeColor = Colors.white24;
    }

    return GestureDetector(
      onTap: () {
        // Tap on any user to open their profile matching Image 2 Step 3!
        Navigator.of(context).pop();
        ViewerProfileScreen.open(
          context,
          userName: hasCrown ? '$name 👑' : name,
          avatarAsset: avatar,
          initialFollowing: isFollowing,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: rank <= 3
                ? badgeColor.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Rank Badge Number (1, 2, 3, etc.)
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: rank <= 3 ? badgeColor : Colors.white10,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    color: rank <= 3 ? Colors.black : Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Viewer Avatar with Status Ring
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: rank <= 3 ? badgeColor : const Color(0xFF00E5FF),
                      width: 1.5,
                    ),
                  ),
                  child: CustomAvatar(
                    radius: 20,
                    assetPath: avatar,
                  ),
                ),
                if (hasCrown)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFD700),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('👑', style: TextStyle(fontSize: 8)),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(width: 12),

            // Name & Watch Time
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (hasCrown) ...[
                        const SizedBox(width: 4),
                        const Text('👑', style: TextStyle(fontSize: 12)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    watchTime,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Follow / Following Button
            GestureDetector(
              onTap: () {
                setState(() {
                  viewer['isFollowing'] = !isFollowing;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                decoration: BoxDecoration(
                  gradient: isFollowing
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFFFF2D78), Color(0xFFE91E63)],
                        ),
                  color: isFollowing ? const Color(0xFF1E2846) : null,
                  borderRadius: BorderRadius.circular(18),
                  border: isFollowing
                      ? Border.all(color: const Color(0xFF2979FF), width: 1)
                      : null,
                ),
                child: Text(
                  isFollowing ? 'Following' : 'Follow',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
