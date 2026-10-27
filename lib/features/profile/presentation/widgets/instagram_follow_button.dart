import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/follow_relationship.dart';
import '../controllers/follow_controller.dart';
import 'instagram_follow_actions_sheet.dart';

/// Reusable Instagram-style Follow / Requested / Following button.
///
/// Features:
/// - Follow state: Vibrant gold button with person-add icon.
/// - Requested state: Sleek slate button with pending clock icon; tap allows cancelling.
/// - Following / Mutual state: Refined dark button with checkmark / mutual icon;
///   tap opens the Instagram options sheet (Unfollow, Block, Close Friends, Mute).
/// - Blocked state: Danger button offering Unblock.
/// - Backed by persistent [followControllerProvider].
class InstagramFollowButton extends ConsumerWidget {
  final String userId;
  final String userName;
  final String userAvatar;
  final int? initialFollowers;
  final bool? initialFollowing;
  final double height;
  final double fontSize;
  final VoidCallback? onStatusChanged;

  const InstagramFollowButton({
    super.key,
    required this.userId,
    required this.userName,
    this.userAvatar = '',
    this.initialFollowers,
    this.initialFollowing,
    this.height = 42.0,
    this.fontSize = 13.0,
    this.onStatusChanged,
  });

  void _notify(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF192233),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followMap = ref.watch(followControllerProvider);
    final relationship = followMap[userId] ??
        ref.read(followControllerProvider.notifier).getRelationship(
              userId,
              defaultName: userName,
              defaultAvatar: userAvatar,
              initialFollowers: initialFollowers,
              initialFollowing: initialFollowing,
            );

    switch (relationship.status) {
      case FollowStatus.notFollowing:
        return _buildFollowButton(context, ref, relationship);
      case FollowStatus.requested:
        return _buildRequestedButton(context, ref, relationship);
      case FollowStatus.following:
      case FollowStatus.mutual:
        return _buildFollowingButton(context, ref, relationship);
      case FollowStatus.blocked:
        return _buildBlockedButton(context, ref, relationship);
    }
  }

  Widget _buildFollowButton(
    BuildContext context,
    WidgetRef ref,
    FollowRelationship rel,
  ) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: () {
          ref.read(followControllerProvider.notifier).sendFollowRequest(
                userId,
                targetName: userName,
                targetAvatar: userAvatar,
                initialFollowers: initialFollowers,
                onStatusNotify: (msg) => _notify(context, msg),
              );
          onStatusChanged?.call();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFDF00),
          foregroundColor: const Color(0xFF10131A),
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_add_rounded, size: 16),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Follow',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestedButton(
    BuildContext context,
    WidgetRef ref,
    FollowRelationship rel,
  ) {
    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: () {
          InstagramFollowActionsSheet.showRequestedSheet(
            context,
            relationship: rel,
            streamerId: userId,
            onCancelRequest: () {
              ref.read(followControllerProvider.notifier).cancelFollowRequest(
                    userId,
                    onStatusNotify: (msg) => _notify(context, msg),
                  );
              onStatusChanged?.call();
            },
          );
        },
        style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xFF1F2839),
          foregroundColor: Colors.white,
          side: const BorderSide(color: Color(0x66FFDF00), width: 1.1),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.schedule_rounded, color: Color(0xFFFFDF00), size: 15),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                'Requested',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 3),
            const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFollowingButton(
    BuildContext context,
    WidgetRef ref,
    FollowRelationship rel,
  ) {
    final isMutual = rel.isMutual;

    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: () {
          InstagramFollowActionsSheet.show(
            context,
            relationship: rel,
            streamerId: userId,
            onUnfollowed: onStatusChanged,
            onBlocked: onStatusChanged,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E2638),
          foregroundColor: Colors.white,
          elevation: 0,
          side: BorderSide(
            color: isMutual ? const Color(0xFFFFDF00).withValues(alpha: 0.5) : Colors.white24,
            width: 1.0,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isMutual ? Icons.compare_arrows_rounded : Icons.check_rounded,
              color: isMutual ? const Color(0xFFFFDF00) : const Color(0xFF00E676),
              size: 16,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                isMutual ? 'Friends' : 'Following',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 3),
            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockedButton(
    BuildContext context,
    WidgetRef ref,
    FollowRelationship rel,
  ) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: () {
          ref.read(followControllerProvider.notifier).unblockUser(
                userId,
                onStatusNotify: (msg) => _notify(context, msg),
              );
          onStatusChanged?.call();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent.withValues(alpha: 0.25),
          foregroundColor: Colors.redAccent,
          elevation: 0,
          side: const BorderSide(color: Colors.redAccent, width: 1.0),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_open_rounded, size: 15),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                'Unblock',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
