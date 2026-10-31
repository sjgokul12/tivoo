import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../profile/presentation/controllers/follow_controller.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../profile/presentation/widgets/instagram_follow_button.dart';
import '../../../messages/presentation/widgets/profile_message_button.dart';
import '../../domain/models/live_stream_card_model.dart';

/// Interactive Streamer ID Profile Sheet.
///
/// Opened directly when tapping the streamer avatar / ID on the live stream.
/// Presents the creator's avatar (tappable to view full profile), verification status,
/// full bio, followers / following stats, and quick actions (Follow, Message).
class StreamerIdProfileSheet extends ConsumerStatefulWidget {
  final LiveStreamCardModel stream;

  const StreamerIdProfileSheet({super.key, required this.stream});

  static Future<void> show(BuildContext context, {required LiveStreamCardModel stream}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StreamerIdProfileSheet(stream: stream),
    );
  }

  @override
  ConsumerState<StreamerIdProfileSheet> createState() => _StreamerIdProfileSheetState();
}

class _StreamerIdProfileSheetState extends ConsumerState<StreamerIdProfileSheet> {
  void _openFullProfile() {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileScreen(streamer: widget.stream),
      ),
    );
  }

  void _toggleBlock(BuildContext context, String userId, String userName, bool isBlocked) {
    if (isBlocked) {
      ref.read(followControllerProvider.notifier).unblockUser(
        userId,
        onStatusNotify: (msg) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: const Color(0xFF1E2840),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      );
    } else {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF141927),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.block_rounded, color: Color(0xFFFF4B6E), size: 24),
              SizedBox(width: 8),
              Text('Block User', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'Are you sure you want to block $userName? They will no longer be able to message you, view your profile, or see your activity.',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4B6E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                ref.read(followControllerProvider.notifier).blockUser(
                  userId,
                  onStatusNotify: (msg) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(msg),
                        backgroundColor: const Color(0xFF1E2840),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                );
              },
              child: const Text('Block'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stream = widget.stream;
    final followMap = ref.watch(followControllerProvider);
    final relationship = followMap[stream.id] ??
        ref.read(followControllerProvider.notifier).getRelationship(
              stream.id,
              defaultName: stream.streamerName,
              defaultAvatar: stream.streamerAssetPath ?? stream.streamerAvatarUrl ?? '',
              initialFollowers: 120400,
              initialFollowing: stream.isFollowing,
            );

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D111A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: const Color(0x33FFDF00), width: 1.2),
        boxShadow: const [BoxShadow(color: Colors.black87, blurRadius: 30, offset: Offset(0, -6))],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
            // Top Drag Handle & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 40),
                Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(3)),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Streamer Avatar with Gold Border & Live Indicator (Tappable to view full profile)
            GestureDetector(
              onTap: _openFullProfile,
              behavior: HitTestBehavior.opaque,
              child: Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFFFDF00), width: 2.2),
                      boxShadow: [BoxShadow(color: const Color(0xFFFFDF00).withValues(alpha: 0.35), blurRadius: 16)],
                    ),
                    child: CustomAvatar(
                      radius: 40,
                      assetPath: stream.streamerAssetPath,
                      imageUrl: stream.streamerAvatarUrl,
                    ),
                  ),
                  if (stream.isLive)
                    Positioned(
                      bottom: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF2D55),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 1.2),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.fiber_manual_record, color: Colors.white, size: 8),
                            SizedBox(width: 3),
                            Text(
                              'LIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Streamer Name & Verified Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  stream.streamerName,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                if (stream.isVerified) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.verified, color: Color(0xFFFFDF00), size: 19),
                ],
              ],
            ),

            // Room Host or Audio Speaker Role Pill Badge
            if (stream.category == 'Room Host' ||
                stream.category == 'Chat Room Host' ||
                stream.category == 'Audio Speaker') ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                decoration: BoxDecoration(
                  gradient: (stream.category == 'Room Host' || stream.category == 'Chat Room Host')
                      ? const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA000)])
                      : LinearGradient(colors: [
                          const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                          const Color(0xFF3B82F6).withValues(alpha: 0.35),
                        ]),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (stream.category == 'Room Host' || stream.category == 'Chat Room Host')
                        ? const Color(0xFFFFE082)
                        : Colors.white24,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      (stream.category == 'Room Host' || stream.category == 'Chat Room Host')
                          ? Icons.workspace_premium_rounded
                          : Icons.mic_rounded,
                      color: (stream.category == 'Room Host' || stream.category == 'Chat Room Host')
                          ? const Color(0xFF1E1035)
                          : Colors.white,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      (stream.category == 'Room Host' || stream.category == 'Chat Room Host')
                          ? '👑 Room Host'
                          : '🎙️ Audio Speaker',
                      style: TextStyle(
                        color: (stream.category == 'Room Host' || stream.category == 'Chat Room Host')
                            ? const Color(0xFF1E1035)
                            : Colors.white,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Mutual / Follows You Indicator (Instagram style)
            if (relationship.theyFollowMe) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: relationship.isMutual
                      ? const Color(0x29FFDF00)
                      : Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: relationship.isMutual
                        ? const Color(0x66FFDF00)
                        : Colors.white12,
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      relationship.isMutual
                          ? Icons.compare_arrows_rounded
                          : Icons.person_rounded,
                      color: relationship.isMutual
                          ? const Color(0xFFFFDF00)
                          : Colors.white60,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      relationship.isMutual
                          ? 'You and ${stream.streamerName} follow each other'
                          : 'Follows you',
                      style: TextStyle(
                        color: relationship.isMutual
                            ? const Color(0xFFFFDF00)
                            : Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 8),

            // Bio / Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                stream.streamerBio,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500, height: 1.3),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(height: 18),

            // Key Statistics Cards: Followers & Following only
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              decoration: BoxDecoration(
                color: const Color(0xFF121724),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Followers', relationship.formattedFollowers),
                  _buildDivider(),
                  _buildStatItem('Following', '142'),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Action Buttons: Follow button, Message button, and Block
            Row(
              children: [
                // Instagram-style Follow Button
                Expanded(
                  flex: 5,
                  child: InstagramFollowButton(
                    userId: stream.id,
                    userName: stream.streamerName,
                    userAvatar: stream.streamerAssetPath ?? stream.streamerAvatarUrl ?? '',
                    initialFollowers: 120400,
                    initialFollowing: stream.isFollowing,
                    height: 44,
                  ),
                ),
                const SizedBox(width: 8),

                // Direct Message Button
                Expanded(
                  flex: 5,
                  child: ProfileMessageButton(
                    userId: stream.id,
                    userName: stream.streamerName,
                    userAvatar: stream.streamerAssetPath ?? stream.streamerAvatarUrl ?? '',
                    isVerified: stream.isVerified,
                    height: 44,
                  ),
                ),
                const SizedBox(width: 8),

                // Block / Unblock Icon Button
                SizedBox(
                  width: 44,
                  height: 44,
                  child: IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: relationship.isBlocked ? const Color(0xFF1B2338) : Colors.white.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => _toggleBlock(context, stream.id, stream.streamerName, relationship.isBlocked),
                    icon: Icon(
                      relationship.isBlocked ? Icons.lock_open_rounded : Icons.block_rounded,
                      size: 18,
                      color: relationship.isBlocked ? Colors.white70 : const Color(0xFFFF4B6E),
                    ),
                    tooltip: relationship.isBlocked ? 'Unblock' : 'Block',
                  ),
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 22, color: Colors.white12);
  }
}
