import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/custom_avatar.dart';
import 'live_stream_viewers_sheet.dart';

/// Top Bar for Live Stream screen strictly matching Image 1:
/// - Host profile & ID badge (tap opens streamer ID profile sheet)
/// - [((•)) LIVE] vibrant red pill badge with broadcast waves
/// - [👁 85.4K] dark translucent pill (tapping opens Viewers List sheet)
/// - Overlapping viewer photos stack + [+3] badge (tapping opens Viewers List)
/// - Close [✕] circular button on the top right
class LiveStreamTopBar extends StatelessWidget {
  final String viewersCount;
  final VoidCallback onCloseTap;
  final String? streamerName;
  final String? streamerId;
  final String? streamerAvatarAsset;
  final String? streamerAvatarUrl;
  final bool isFollowing;
  final bool isRequested;
  final VoidCallback? onFollowTap;
  final VoidCallback? onHostProfileTap;
  final VoidCallback? onMoreTap;

  const LiveStreamTopBar({
    super.key,
    this.viewersCount = '85.4K',
    required this.onCloseTap,
    this.streamerName,
    this.streamerId,
    this.streamerAvatarAsset,
    this.streamerAvatarUrl,
    this.isFollowing = false,
    this.isRequested = false,
    this.onFollowTap,
    this.onHostProfileTap,
    this.onMoreTap,
  });

  void _openViewerList(BuildContext context) {
    LiveStreamViewersSheet.show(
      context,
      totalViewersCount: '85,432',
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 380;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // 1. Host Profile & ID Pill (Streamer identification at the top of streaming)
          if (streamerName != null && streamerName!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(3, 3, 8, 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.60),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                  width: 1.0,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tappable Host Info area (Avatar + Name + ID)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onHostProfileTap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Host Avatar with golden ring
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
                          ),
                          child: ClipOval(
                            child: CustomAvatar(
                              radius: 15,
                              assetPath: streamerAvatarAsset,
                              imageUrl: streamerAvatarUrl,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Host Name & Host ID
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: isCompact ? 52 : (screenWidth < 400 ? 64 : 76),
                                  ),
                                  child: Text(
                                    streamerName!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 2),
                                const Icon(Icons.verified_rounded, color: Color(0xFF00E5FF), size: 11),
                              ],
                            ),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: isCompact ? 56 : (screenWidth < 400 ? 68 : 80),
                              ),
                              child: Text(
                                streamerId != null ? 'ID: $streamerId' : 'ID: Host',
                                style: const TextStyle(
                                  color: Color(0xFFFFD700),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Quick Follow / Requested / Following Button (Independent gesture target)
                  if (onFollowTap != null) ...[
                    const SizedBox(width: 6),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onFollowTap,
                      child: isFollowing
                          ? Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF1E2840),
                                border: Border.all(color: const Color(0xFFFFD700), width: 1.2),
                              ),
                              child: const Center(
                                child: Icon(Icons.check, color: Color(0xFFFFD700), size: 12),
                              ),
                            )
                          : isRequested
                              ? Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF1E2840),
                                    border: Border.all(color: const Color(0xFFFFDF00), width: 1.2),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.schedule, color: Color(0xFFFFDF00), size: 12),
                                  ),
                                )
                              : Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [Color(0xFFFF2D78), Color(0xFFBA43F6)],
                                    ),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.add, color: Colors.white, size: 13),
                                  ),
                                ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 5),
          ] else ...[
            // LIVE Pill Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFF1744),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x88FF1744),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sensors_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                  SizedBox(width: 3),
                  Text(
                    'LIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
          ],

          // 2. Viewers Count Pill: 👁 85.4K (Tap opens viewers list!)
          GestureDetector(
            onTap: () => _openViewerList(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.visibility_outlined,
                    color: Colors.white,
                    size: 12,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    viewersCount,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 5),

          // 3. Viewers Avatar Stack + (+3) badge (Tap opens viewers list)
          GestureDetector(
            onTap: () => _openViewerList(context),
            child: _buildViewersAvatarStack(context),
          ),

          const Spacer(),

          if (onMoreTap != null && screenWidth >= 400) ...[
            GestureDetector(
              onTap: onMoreTap,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.55),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.20),
                    width: 0.8,
                  ),
                ),
                child: const Icon(
                  Icons.more_horiz_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // 4. Close Button [✕]
          GestureDetector(
            onTap: onCloseTap,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.55),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.20),
                  width: 0.8,
                ),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewersAvatarStack(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 380;

    final viewerData = isCompact
        ? [
            {'name': 'Karthik', 'asset': AppAssets.status5},
            {'name': 'Aurora_X', 'asset': AppAssets.status4},
          ]
        : [
            {'name': 'Karthik', 'asset': AppAssets.status5},
            {'name': 'Aurora_X', 'asset': AppAssets.status4},
            {'name': 'Sam_99', 'asset': AppAssets.status2},
          ];

    final stackWidth = isCompact ? 54.0 : 76.0;
    final badgeLeft = isCompact ? 28.0 : 48.0;

    return SizedBox(
      height: 28,
      width: stackWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Overlapping Viewers
          for (int i = 0; i < viewerData.length; i++)
            Positioned(
              left: i * (isCompact ? 14.0 : 16.0),
              top: 1,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: CustomAvatar(
                    radius: 12,
                    assetPath: viewerData[i]['asset']!,
                  ),
                ),
              ),
            ),

          // [+3] Badge with Glowing Golden/Orange Halo Ring
          Positioned(
            left: badgeLeft,
            top: 0,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF141724),
                border: Border.all(
                  color: const Color(0xFFFFB300),
                  width: 1.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFB300).withValues(alpha: 0.85),
                    blurRadius: 8,
                    spreadRadius: 1.5,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '+3',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
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
