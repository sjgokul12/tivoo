import 'package:flutter/material.dart';
import '../../../../core/widgets/custom_avatar.dart';

/// Right Vertical Action Bar strictly matching Image 4:
/// - Host avatar with red '+' follow badge at the bottom edge
/// - Red Heart icon with '12.5K' count
/// - 3D Gift Box (🎁) with 'Gift' label
/// - Share icon (curved arrow) with 'Share' label
class LiveActionBar extends StatelessWidget {
  final String? streamerAvatarAsset;
  final String? streamerAvatarUrl;
  final bool isFollowing;
  final bool isLiked;
  final String likesCount;
  final String commentsCount;
  final String? starsCount;
  final VoidCallback onFollowTap;
  final VoidCallback onLikeTap;
  final VoidCallback? onCommentTap;
  final VoidCallback onShareTap;
  final VoidCallback? onStarTap;
  final VoidCallback? onGiftTap;
  final VoidCallback? onAvatarTap;

  const LiveActionBar({
    super.key,
    this.streamerAvatarAsset,
    this.streamerAvatarUrl,
    required this.isFollowing,
    required this.isLiked,
    required this.likesCount,
    required this.commentsCount,
    this.starsCount,
    required this.onFollowTap,
    required this.onLikeTap,
    this.onCommentTap,
    required this.onShareTap,
    this.onStarTap,
    this.onGiftTap,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Host Avatar with red '+' badge (Image 4)
        _buildHostAvatarWithFollowBadge(),

        const SizedBox(height: 18),

        // 2. Red Heart Icon with 12.5K (Image 4)
        _buildActionButton(
          iconWidget: Icon(
            Icons.favorite_rounded,
            color: isLiked ? const Color(0xFFFF1744) : const Color(0xFFFF2D55),
            size: 32,
            shadows: const [
              Shadow(
                color: Color(0x88FF1744),
                blurRadius: 10,
              ),
            ],
          ),
          label: likesCount.isEmpty ? '12.5K' : likesCount,
          onTap: onLikeTap,
        ),

        const SizedBox(height: 18),

        // 3. 3D Gift Box with 'Gift' label (Image 4)
        if (onGiftTap != null)
          _buildActionButton(
            iconWidget: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFFFFEA00), Color(0xFFFF9100)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9100).withValues(alpha: 0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🎁', style: TextStyle(fontSize: 24)),
              ),
            ),
            label: 'Gift',
            onTap: onGiftTap!,
          ),

        const SizedBox(height: 18),

        // 4. Share Curved Arrow with 'Share' label (Pointing forward & rightward - Image 1 Step 1)
        _buildActionButton(
          iconWidget: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.40),
            ),
            child: Transform.flip(
              flipX: true,
              child: const Icon(
                Icons.reply_rounded, // Curved forward share arrow pointing right
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
          label: 'Share',
          onTap: onShareTap,
        ),
      ],
    );
  }

  Widget _buildHostAvatarWithFollowBadge() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 8,
                ),
              ],
            ),
            child: ClipOval(
              child: CustomAvatar(
                radius: 24,
                assetPath: (streamerAvatarAsset != null && streamerAvatarAsset!.isNotEmpty)
                    ? streamerAvatarAsset
                    : null,
                imageUrl: streamerAvatarUrl,
              ),
            ),
          ),
        ),

        // Red circular '+' button overlapping bottom (Image 4)
        if (!isFollowing)
          Positioned(
            bottom: -6,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: onFollowTap,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF1744),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.add,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButton({
    required Widget iconWidget,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(color: Colors.black87, blurRadius: 4),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
