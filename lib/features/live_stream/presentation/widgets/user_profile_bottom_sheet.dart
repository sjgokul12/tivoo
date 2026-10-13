import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../profile/presentation/screens/profile_screen.dart';

/// Interactive User Profile Bottom Sheet.
/// Opened when tapping any commenter's avatar or username in live comments,
/// or tapping a viewer / contributor avatar.
class UserProfileBottomSheet extends StatefulWidget {
  final String userName;
  final String? avatarAsset;
  final String? avatarUrl;
  final String? userId;
  final VoidCallback? onSendGiftTap;

  const UserProfileBottomSheet({
    super.key,
    required this.userName,
    this.avatarAsset,
    this.avatarUrl,
    this.userId,
    this.onSendGiftTap,
  });

  static Future<void> show(
    BuildContext context, {
    required String userName,
    String? avatarAsset,
    String? avatarUrl,
    String? userId,
    VoidCallback? onSendGiftTap,
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
      ),
    );
  }

  @override
  State<UserProfileBottomSheet> createState() => _UserProfileBottomSheetState();
}

class _UserProfileBottomSheetState extends State<UserProfileBottomSheet> {
  bool _isFollowing = false;

  @override
  Widget build(BuildContext context) {
    final displayId = widget.userId ??
        'ID: ${widget.userName.toLowerCase().replaceAll(' ', '_')}_${(widget.userName.hashCode.abs() % 89999 + 10000)}';

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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: SafeArea(
        top: false,
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

            // User Avatar with Gold VIP Border
            Stack(
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
                  child: const Text(
                    'VIP 5',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // User ID
            Text(
              displayId,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // Stats Row: Followers, Following, Stars
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  _buildStatItem('14.2K', 'Followers'),
                  Container(width: 1, height: 28, color: Colors.white12),
                  _buildStatItem('348', 'Following'),
                  Container(width: 1, height: 28, color: Colors.white12),
                  _buildStatItem('⭐ 2,850', 'Stars Sent'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons: Follow / Unfollow & Send Gift
            Row(
              children: [
                // Follow / Unfollow Button
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFollowing
                          ? const Color(0xFF232234)
                          : const Color(0xFFFF2D78),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                        side: _isFollowing
                            ? const BorderSide(color: Colors.white24)
                            : BorderSide.none,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: _isFollowing ? 0 : 6,
                      shadowColor: const Color(0x66FF2D78),
                    ),
                    onPressed: () {
                      setState(() => _isFollowing = !_isFollowing);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _isFollowing
                                ? 'Now following ${widget.userName}! ❤️'
                                : 'Unfollowed ${widget.userName}',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isFollowing ? Icons.check_rounded : Icons.person_add_rounded,
                          size: 17,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isFollowing ? 'Following' : 'Follow',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Send Gift Button
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD600),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 6,
                      shadowColor: const Color(0x66FFD600),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (widget.onSendGiftTap != null) {
                        widget.onSendGiftTap!();
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('🎁', style: TextStyle(fontSize: 15)),
                        SizedBox(width: 6),
                        Text(
                          'Send Gift',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // View Full Profile Button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ProfileScreen(),
                    ),
                  );
                },
                child: const Text(
                  'View Full Profile',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
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
