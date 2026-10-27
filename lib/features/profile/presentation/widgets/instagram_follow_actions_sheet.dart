import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../domain/models/follow_relationship.dart';
import '../controllers/follow_controller.dart';

/// Instagram-style Action Sheet for managing Following, Close Friends, Muting,
/// Unfollowing, and Blocking a user with rich confirmation dialogues.
class InstagramFollowActionsSheet extends ConsumerWidget {
  final FollowRelationship relationship;
  final String streamerId;
  final VoidCallback? onUnfollowed;
  final VoidCallback? onBlocked;

  const InstagramFollowActionsSheet({
    super.key,
    required this.relationship,
    required this.streamerId,
    this.onUnfollowed,
    this.onBlocked,
  });

  /// Presents the Instagram-style Following Options modal.
  static Future<void> show(
    BuildContext context, {
    required FollowRelationship relationship,
    required String streamerId,
    VoidCallback? onUnfollowed,
    VoidCallback? onBlocked,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InstagramFollowActionsSheet(
        relationship: relationship,
        streamerId: streamerId,
        onUnfollowed: onUnfollowed,
        onBlocked: onBlocked,
      ),
    );
  }

  /// Presents the Instagram-style Cancel Request sheet when state is [FollowStatus.requested].
  static Future<void> showRequestedSheet(
    BuildContext context, {
    required FollowRelationship relationship,
    required String streamerId,
    required VoidCallback onCancelRequest,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF141A28),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 18),
              const Icon(Icons.schedule_rounded, color: Color(0xFFFFDF00), size: 36),
              const SizedBox(height: 12),
              Text(
                'Follow Request Pending',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'You have requested to follow ${relationship.userName}. If you cancel, you will have to request again.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.3),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, color: Colors.redAccent, size: 20),
                ),
                title: const Text(
                  'Cancel Follow Request',
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700, fontSize: 15),
                ),
                onTap: () {
                  Navigator.of(ctx).pop();
                  onCancelRequest();
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: Colors.white70, size: 20),
                ),
                title: const Text(
                  'Dismiss',
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 15),
                ),
                onTap: () => Navigator.of(ctx).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmUnfollow(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF141A28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
          child: Column(
            children: [
              CustomAvatar(
                radius: 30,
                assetPath: relationship.userAvatar.startsWith('assets/') ? relationship.userAvatar : null,
                imageUrl: relationship.userAvatar.startsWith('assets/') ? null : relationship.userAvatar,
              ),
              const SizedBox(height: 12),
              Text(
                'Unfollow ${relationship.userName}?',
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        content: Text(
          'Their live streams, posts, and stories will no longer appear prominently on your feed.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF2D55),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop(); // Dismiss dialog
              Navigator.of(context).pop(); // Dismiss sheet
              ref.read(followControllerProvider.notifier).unfollow(
                    streamerId,
                    onStatusNotify: (msg) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
                      );
                    },
                  );
              onUnfollowed?.call();
            },
            child: const Text('Unfollow', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmBlock(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF141A28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
          child: Column(
            children: [
              const Icon(Icons.block_rounded, color: Colors.redAccent, size: 36),
              const SizedBox(height: 10),
              Text(
                'Block ${relationship.userName}?',
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        content: Text(
          'They will not be able to find your profile, watch your streams, or send you messages on Tivoo.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60, fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop(); // Dismiss dialog
              Navigator.of(context).pop(); // Dismiss sheet
              ref.read(followControllerProvider.notifier).blockUser(
                    streamerId,
                    onStatusNotify: (msg) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
                      );
                    },
                  );
              onBlocked?.call();
            },
            child: const Text('Block', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRel = ref.watch(followControllerProvider)[streamerId] ?? relationship;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F1420),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: Color(0x33FFDF00), width: 1)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag indicator
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),

            // User Info Header
            Row(
              children: [
                CustomAvatar(
                  radius: 24,
                  assetPath: currentRel.userAvatar.startsWith('assets/') ? currentRel.userAvatar : null,
                  imageUrl: currentRel.userAvatar.startsWith('assets/') ? null : currentRel.userAvatar,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentRel.userName,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (currentRel.isMutual) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0x33FFDF00),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.compare_arrows_rounded, color: Color(0xFFFFDF00), size: 12),
                                  SizedBox(width: 4),
                                  Text(
                                    'You follow each other',
                                    style: TextStyle(
                                      color: Color(0xFFFFDF00),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            const Text(
                              'Following',
                              style: TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 8),

            // 1. Add to Close Friends
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (currentRel.isCloseFriend ? const Color(0xFF00E676) : Colors.white10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.star_rounded,
                  color: currentRel.isCloseFriend ? Colors.black : Colors.white70,
                  size: 20,
                ),
              ),
              title: const Text(
                'Close Friends',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14.5),
              ),
              subtitle: Text(
                currentRel.isCloseFriend ? 'On your Close Friends list' : 'Add to Close Friends list',
                style: const TextStyle(color: Colors.white54, fontSize: 11.5),
              ),
              trailing: Switch.adaptive(
                value: currentRel.isCloseFriend,
                activeTrackColor: const Color(0xFF00E676),
                activeThumbColor: Colors.white,
                onChanged: (_) {
                  ref.read(followControllerProvider.notifier).toggleCloseFriend(streamerId);
                },
              ),
            ),

            // 2. Mute Notifications
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (currentRel.isMuted ? Colors.orangeAccent : Colors.white10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  currentRel.isMuted ? Icons.notifications_off_rounded : Icons.notifications_none_rounded,
                  color: currentRel.isMuted ? Colors.black : Colors.white70,
                  size: 20,
                ),
              ),
              title: const Text(
                'Mute Notifications',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14.5),
              ),
              subtitle: Text(
                currentRel.isMuted ? 'Notifications are muted' : 'Mute lives, posts and stories',
                style: const TextStyle(color: Colors.white54, fontSize: 11.5),
              ),
              trailing: Switch.adaptive(
                value: currentRel.isMuted,
                activeTrackColor: Colors.orangeAccent,
                activeThumbColor: Colors.white,
                onChanged: (_) {
                  ref.read(followControllerProvider.notifier).toggleMute(streamerId);
                },
              ),
            ),

            const Divider(color: Colors.white10, height: 16),

            // 3. Unfollow Option
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_remove_rounded, color: Color(0xFFFF2D55), size: 20),
              ),
              title: Text(
                'Unfollow ${currentRel.userName}',
                style: const TextStyle(
                  color: Color(0xFFFF2D55),
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                ),
              ),
              onTap: () => _confirmUnfollow(context, ref),
            ),

            // 4. Block Option
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.block_rounded, color: Colors.redAccent, size: 20),
              ),
              title: Text(
                'Block ${currentRel.userName}',
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                ),
              ),
              onTap: () => _confirmBlock(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}
