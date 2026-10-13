import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/models/user_profile_model.dart';

class MyContentSection extends StatelessWidget {
  final List<ProfileMediaPost> posts;
  final int selectedTab; // 0 = Videos, 1 = Images
  final String selectedSort;
  final Function(int index) onTabChanged;
  final Function(String sort) onSortChanged;
  final Function(ProfileMediaPost post)? onPostTap;

  const MyContentSection({
    super.key,
    required this.posts,
    required this.selectedTab,
    required this.selectedSort,
    required this.onTabChanged,
    required this.onSortChanged,
    this.onPostTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title: "My Content"
        Text(
          'My Content',
          style: AppTextStyles.heroHeading.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF161622),
          ),
        ),

        const SizedBox(height: 12),

        // Tabs & Sort Row: [Videos | Images]   [Recent ⌵]
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Tabs: Videos & Images
            Row(
              children: [
                _buildTab(title: 'Videos', isSelected: selectedTab == 0, onTap: () => onTabChanged(0), isDark: isDark),
                const SizedBox(width: 16),
                _buildTab(title: 'Images', isSelected: selectedTab == 1, onTap: () => onTabChanged(1), isDark: isDark),
              ],
            ),

            // Sort Dropdown Button: "Recent ⌵"
            PopupMenuButton<String>(
              onSelected: onSortChanged,
              color: isDark ? const Color(0xFF1C1C2C) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'Recent', child: Text('Recent')),
                const PopupMenuItem(value: 'Most Viewed', child: Text('Most Viewed')),
                const PopupMenuItem(value: 'Popular', child: Text('Popular')),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: isDark ? const Color(0xFF181828) : Colors.black.withValues(alpha: 0.05),
                  border: Border.all(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      selectedSort,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : const Color(0xFF555566),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: isDark ? Colors.white70 : const Color(0xFF555566),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // 3-Column Media Grid
        if (posts.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 36),
            alignment: Alignment.center,
            child: Text(
              selectedTab == 0 ? 'No videos uploaded yet' : 'No images uploaded yet',
              style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 13),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: posts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 10,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              final post = posts[index];
              return _buildMediaCard(context, post, isDark);
            },
          ),
      ],
    );
  }

  Widget _buildTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? (isDark ? Colors.white : const Color(0xFF161622))
                  : (isDark ? Colors.white54 : const Color(0xFF888899)),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 2.5,
            width: isSelected ? 28 : 0,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryPink : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaCard(BuildContext context, ProfileMediaPost post, bool isDark) {
    return GestureDetector(
      onTap: () => onPostTap?.call(post),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(color: isDark ? const Color(0xFF1A1A2A) : const Color(0xFFE5E5EA)),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Media Thumbnail Image
              CachedNetworkImage(
                imageUrl: post.mediaUrl,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 150),
                placeholder: (context, url) => Container(color: const Color(0xFF161622)),
                errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.white38),
              ),

              // Gradient Scrim for readable badges and text
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black38, Colors.transparent, Colors.transparent, Colors.black87],
                    stops: [0.0, 0.25, 0.65, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // Duration Badge on Top Right (for Videos)
              if (post.type == ProfileMediaType.video)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      post.duration,
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),

              // Bottom Stats: Play / Eye count & Likes count
              Positioned(
                bottom: 6,
                left: 6,
                right: 6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Views / Plays
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          post.type == ProfileMediaType.video ? Icons.play_arrow_rounded : Icons.visibility_outlined,
                          size: 11,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          post.viewsCount,
                          style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),

                    // Likes
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite, size: 9, color: AppColors.primaryYellow),
                        const SizedBox(width: 2),
                        Text(
                          post.likesCount,
                          style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
