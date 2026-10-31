import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../home/domain/models/live_stream_card_model.dart';
import '../../../profile/presentation/controllers/follow_controller.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../profile/presentation/widgets/instagram_follow_button.dart';
import '../../../messages/presentation/widgets/profile_message_button.dart';

/// Interactive User Profile Bottom Sheet.
/// Opened when tapping any commenter's avatar or username in live comments,
/// or tapping a viewer / contributor avatar, or any speaker in chat rooms.
class UserProfileBottomSheet extends ConsumerStatefulWidget {
  final String userName;
  final String? avatarAsset;
  final String? avatarUrl;
  final String? userId;
  final VoidCallback? onSendGiftTap;
  final String? roleBadge;

  const UserProfileBottomSheet({
    super.key,
    required this.userName,
    this.avatarAsset,
    this.avatarUrl,
    this.userId,
    this.onSendGiftTap,
    this.roleBadge,
  });

  static Future<void> show(
    BuildContext context, {
    required String userName,
    String? avatarAsset,
    String? avatarUrl,
    String? userId,
    VoidCallback? onSendGiftTap,
    String? roleBadge,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UserProfileBottomSheet(
        userName: userName,
        avatarAsset: avatarAsset,
        avatarUrl: avatarUrl,
        userId: userId,
        onSendGiftTap: onSendGiftTap,
        roleBadge: roleBadge,
      ),
    );
  }

  @override
  ConsumerState<UserProfileBottomSheet> createState() => _UserProfileBottomSheetState();
}

class _UserProfileBottomSheetState extends ConsumerState<UserProfileBottomSheet> {
  void _openFullProfile() {
    Navigator.of(context).pop();
    final streamerModel = LiveStreamCardModel(
      id: widget.userId ?? 'user_${widget.userName.toLowerCase().replaceAll(' ', '_')}',
      userId: widget.userName.toLowerCase().replaceAll(' ', '_'),
      streamerName: widget.userName,
      streamerBio: widget.roleBadge != null
          ? '${widget.roleBadge} • Good Vibes Only ✨'
          : '✨ Creator on Tivoo • Good Vibes Only ✨',
      streamerAssetPath: widget.avatarAsset,
      streamerAvatarUrl: widget.avatarUrl,
      viewersCount: '1.2K',
      diamondsCount: '45.2K',
      category: widget.roleBadge ?? 'Creator',
      isFollowing: false,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProfileScreen(streamer: streamerModel),
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
    final displayId = widget.userId ??
        'ID: ${widget.userName.toLowerCase().replaceAll(' ', '_')}_${(widget.userName.hashCode.abs() % 89999 + 10000)}';

    final followMap = ref.watch(followControllerProvider);
    final rel = followMap[displayId] ??
        ref.read(followControllerProvider.notifier).getRelationship(
              displayId,
              defaultName: widget.userName,
              defaultAvatar: widget.avatarAsset ?? widget.avatarUrl ?? '',
              initialFollowers: 14200,
            );

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F0E17),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: const Color(0x44FFD600),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 32,
            offset: Offset(0, -6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Drag Handle & Close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 36),
                Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
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
            const SizedBox(height: 14),

            // User Avatar with Gold VIP Border (Tappable to view full profile)
            GestureDetector(
              onTap: _openFullProfile,
              behavior: HitTestBehavior.opaque,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFEA00), Color(0xFFFF2D78)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF2D78).withValues(alpha: 0.35),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                  ),
                  CustomAvatar(
                    radius: 40,
                    imageUrl: widget.avatarUrl,
                    assetPath: widget.avatarAsset ?? AppAssets.status1,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFD600),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.verified_rounded,
                        color: Colors.black,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // User Name
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD600), Color(0xFFFF9100)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.roleBadge ?? 'VIP 5',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Stats Row: Followers & Following only
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF161524),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(rel.formattedFollowers, 'Followers'),
                  Container(width: 1, height: 28, color: Colors.white12),
                  _buildStatItem('348', 'Following'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons: Follow button, Message button, and Block
            Row(
              children: [
                // Follow / Requested / Following Button
                Expanded(
                  flex: 5,
                  child: InstagramFollowButton(
                    userId: displayId,
                    userName: widget.userName,
                    userAvatar: widget.avatarAsset ?? widget.avatarUrl ?? '',
                    initialFollowers: 14200,
                    height: 44,
                  ),
                ),
                const SizedBox(width: 8),

                // Direct Message Button
                Expanded(
                  flex: 5,
                  child: ProfileMessageButton(
                    userId: displayId,
                    userName: widget.userName,
                    userAvatar: widget.avatarAsset ?? widget.avatarUrl ?? '',
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
                      backgroundColor: rel.isBlocked ? const Color(0xFF1B2338) : Colors.white.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => _toggleBlock(context, displayId, widget.userName, rel.isBlocked),
                    icon: Icon(
                      rel.isBlocked ? Icons.lock_open_rounded : Icons.block_rounded,
                      size: 18,
                      color: rel.isBlocked ? Colors.white70 : const Color(0xFFFF4B6E),
                    ),
                    tooltip: rel.isBlocked ? 'Unblock' : 'Block',
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

  Widget _buildStatItem(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
