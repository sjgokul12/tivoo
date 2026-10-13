import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/models/streamer_story.dart';

class StoryListView extends StatelessWidget {
  final List<StreamerStory> stories;
  final Function(StreamerStory story)? onStoryTap;
  final VoidCallback? onAddStoryTap;

  const StoryListView({super.key, required this.stories, this.onStoryTap, this.onAddStoryTap});

  @override
  Widget build(BuildContext context) {
    final avatarSize = context.responsiveWidth(66);
    return SizedBox(
      height: avatarSize + 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: stories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final story = stories[index];
          return _buildTrendingStoryItem(context, story, avatarSize);
        },
      ),
    );
  }

  Widget _buildTrendingStoryItem(BuildContext context, StreamerStory story, double avatarSize) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        if (story.isUser) {
          onAddStoryTap?.call();
        } else {
          onStoryTap?.call(story);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Trending Stylized Squircle Avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              // Outer Gradient Border with Glowing Shadow
              Container(
                width: avatarSize,
                height: avatarSize,
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: story.isUser ? null : AppColors.storyRingGradient,
                  border: story.isUser
                      ? Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.12),
                          width: 1.5,
                        )
                      : null,
                  boxShadow: story.isUser
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.primaryYellow.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(19.5),
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  child: ClipRRect(borderRadius: BorderRadius.circular(18), child: _buildImage(story)),
                ),
              ),

              // Plus Badge for "You"
              if (story.isUser)
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.followButtonGradient,
                      border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                      boxShadow: const [BoxShadow(color: Color(0x66FF2D68), blurRadius: 6)],
                    ),
                    child: const Icon(Icons.add, size: 13, color: Colors.white),
                  ),
                ),

              // LIVE Pill Tag for Streamers
              if (!story.isUser)
                Positioned(
                  bottom: -5,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: AppColors.liveRed,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 1.5),
                        boxShadow: const [BoxShadow(color: Color(0x55FF2D55), blurRadius: 4)],
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          // Streamer Name
          SizedBox(
            width: avatarSize,
            child: Text(
              story.name,
              style: AppTextStyles.storyName.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1F1F2C),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(StreamerStory story) {
    final fallbackAsset = (story.assetPath != null && story.assetPath!.isNotEmpty)
        ? story.assetPath!
        : AppAssets.liveCard1;

    if (story.assetPath != null && story.assetPath!.isNotEmpty) {
      return Image.asset(
        story.assetPath!,
        fit: BoxFit.cover,
        cacheWidth: 160,
        cacheHeight: 160,
        errorBuilder: (context, error, stackTrace) =>
            Image.asset(AppAssets.liveCard1, fit: BoxFit.cover, cacheWidth: 160, cacheHeight: 160),
      );
    }
    if (story.avatarUrl != null && story.avatarUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: story.avatarUrl!,
        fit: BoxFit.cover,
        memCacheWidth: 160,
        memCacheHeight: 160,
        placeholder: (context, url) => Image.asset(fallbackAsset, fit: BoxFit.cover, cacheWidth: 160, cacheHeight: 160),
        errorWidget: (context, url, error) =>
            Image.asset(fallbackAsset, fit: BoxFit.cover, cacheWidth: 160, cacheHeight: 160),
      );
    }
    return Image.asset(fallbackAsset, fit: BoxFit.cover, cacheWidth: 160, cacheHeight: 160);
  }
}
