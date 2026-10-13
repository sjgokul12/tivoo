import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../family/presentation/controllers/family_controller.dart';
import '../../domain/models/activity_item_model.dart';

class ActivityCard extends StatelessWidget {
  final ActivityItemModel activity;
  final VoidCallback? onTap;
  final VoidCallback? onFollowBackTap;

  const ActivityCard({
    super.key,
    required this.activity,
    this.onTap,
    this.onFollowBackTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: isDark
              ? const Color(0x9913131E)
              : Colors.white,
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.05),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. User Avatar with Badges
            _buildAvatarWithBadge(),

            const SizedBox(width: 12),

            // 2. Notification Text Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildRichTitle(),
                  if (activity.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      activity.subtitle!,
                      style: AppTextStyles.streamerTagline.copyWith(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : const Color(0xFF6B6B78),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (activity.subSubtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      activity.subSubtitle!,
                      style: AppTextStyles.streamerTagline.copyWith(
                        fontSize: 11,
                        color: isDark ? AppColors.textMuted : const Color(0xFF9E9EA7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (activity.timeAgo.isNotEmpty && activity.timeAgo != 'Now') ...[
                    const SizedBox(height: 3),
                    Text(
                      activity.timeAgo,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textMuted : const Color(0xFF9E9EA7),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 10),

            // 3. Right Action or Preview
            _buildRightActionOrPreview(),

            const SizedBox(width: 6),

            // 4. More Options Icon
            Icon(
              Icons.drag_indicator_rounded,
              color: isDark ? Colors.white24 : Colors.black26,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarWithBadge() {
    IconData badgeIcon;
    Color badgeColor;

    switch (activity.type) {
      case ActivityType.familyJoinRequest:
        badgeIcon = Icons.group_add_rounded;
        badgeColor = const Color(0xFF00E676);
        break;
      case ActivityType.liveNow:
        badgeIcon = Icons.podcasts_rounded;
        badgeColor = const Color(0xFFBA43F6);
        break;
      case ActivityType.like:
      case ActivityType.milestone:
        badgeIcon = Icons.favorite_rounded;
        badgeColor = AppColors.liveRed;
        break;
      case ActivityType.follow:
        badgeIcon = Icons.add;
        badgeColor = const Color(0xFF8E38FF);
        break;
      case ActivityType.gift:
        badgeIcon = Icons.card_giftcard_rounded;
        badgeColor = const Color(0xFF7E3FF2);
        break;
      case ActivityType.wentLive:
        badgeIcon = Icons.campaign_rounded;
        badgeColor = const Color(0xFFBA43F6);
        break;
      default:
        badgeIcon = Icons.notifications_rounded;
        badgeColor = AppColors.primaryPink;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CustomAvatar(
          radius: 23,
          imageUrl: activity.userAvatarUrl,
          assetPath: activity.userAvatarAsset,
        ),
        Positioned(
          bottom: -2,
          right: -2,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: badgeColor,
              border: Border.all(color: const Color(0xFF161622), width: 1.5),
              boxShadow: [
                BoxShadow(color: badgeColor.withValues(alpha: 0.6), blurRadius: 8),
              ],
            ),
            child: Icon(
              badgeIcon,
              size: 10,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRichTitle() {
    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: AppTextStyles.streamerName.copyWith(fontSize: 13.5),
        children: [
          TextSpan(
            text: '${activity.userName} ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(
            text: activity.title,
            style: const TextStyle(
              color: AppColors.primaryPink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightActionOrPreview() {
    if (activity.type == ActivityType.familyJoinRequest) {
      return Consumer(
        builder: (context, ref, child) {
          final familyState = ref.watch(familyControllerProvider);
          final hasAlreadyJoined = familyState.currentFamily.members
              .any((m) => m.tikiId.contains(activity.applicantId ?? '---'));
          final isPending = familyState.currentFamily.pendingRequests
              .any((r) => r.id == activity.requestId);

          if (hasAlreadyJoined) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0x3300E676),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF00E676), width: 0.8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, color: Color(0xFF00E676), size: 13),
                  SizedBox(width: 4),
                  Text(
                    'Joined',
                    style: TextStyle(
                      color: Color(0xFF00E676),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          if (!isPending) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: const Text(
                'Processed',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            );
          }

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  ref
                      .read(familyControllerProvider.notifier)
                      .acceptJoinRequest(activity.requestId ?? 'req_1');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Accepted ${activity.userName} into ${activity.familyName ?? "Family"}! 🎉'),
                      backgroundColor: const Color(0xFF00E676),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E676), Color(0xFF00B0FF)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(color: Color(0x5500E676), blurRadius: 6),
                    ],
                  ),
                  child: const Text(
                    'Accept',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  ref
                      .read(familyControllerProvider.notifier)
                      .declineJoinRequest(activity.requestId ?? 'req_1');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Declined request from ${activity.userName}'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Decline',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }

    if (activity.type == ActivityType.follow) {
      return GestureDetector(
        onTap: onFollowBackTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: activity.isFollowing
                ? const LinearGradient(
                    colors: [Color(0x55FFFFFF), Color(0x33FFFFFF)],
                  )
                : AppColors.followButtonGradient,
          ),
          child: Text(
            activity.isFollowing ? 'Following' : 'Follow Back',
            style: AppTextStyles.buttonSmall.copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    if (activity.type == ActivityType.gift) {
      return Container(
        width: 76,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF1E1428),
          border: Border.all(
            color: const Color(0xFF7E3FF2).withValues(alpha: 0.3),
            width: 0.8,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Text('🎁', style: TextStyle(fontSize: 26)),
            Positioned(
              bottom: 4,
              right: 6,
              child: Text(
                activity.giftMultiplier ?? 'x1',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (activity.previewImageUrl != null && activity.previewImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 78,
          height: 52,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: activity.previewImageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: AppColors.surfaceColor),
                errorWidget: (context, url, error) => Container(color: AppColors.surfaceColor),
              ),
              Container(color: Colors.black26),
              if (activity.isLive)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.liveRed,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.podcasts_rounded, size: 8, color: Colors.white),
                        SizedBox(width: 2),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 7.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (activity.viewersCount != null)
                Positioned(
                  bottom: 3,
                  right: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.visibility_outlined,
                          size: 10, color: Colors.white),
                      const SizedBox(width: 2),
                      Text(
                        activity.viewersCount!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              if (activity.likesCount != null)
                Positioned(
                  bottom: 3,
                  right: 4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite,
                          size: 10, color: AppColors.liveRed),
                      const SizedBox(width: 2),
                      Text(
                        activity.likesCount!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
