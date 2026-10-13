import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class CreatePostCards extends StatelessWidget {
  final VoidCallback onUploadVideo;
  final VoidCallback onUploadImage;
  final VoidCallback? onViewAll;

  const CreatePostCards({super.key, required this.onUploadVideo, required this.onUploadImage, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: "Create New Post" & "View All >"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Create New Post',
              style: AppTextStyles.heroHeading.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF161622),
              ),
            ),
            GestureDetector(
              onTap: onViewAll,
              child: Row(
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? Colors.white70 : const Color(0xFF6B6B78),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(Icons.chevron_right_rounded, size: 16, color: isDark ? Colors.white70 : const Color(0xFF6B6B78)),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 2 Upload Action Cards
        Row(
          children: [
            // 1. Upload Video Card
            Expanded(
              child: _buildUploadCard(
                context: context,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFD600), Color(0xFFFF9100)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                icon: Icons.videocam_rounded,
                title: 'Upload Video',
                subtitle: 'Share your moments',
                onTap: onUploadVideo,
              ),
            ),

            const SizedBox(width: 12),

            // 2. Upload Image Card
            Expanded(
              child: _buildUploadCard(
                context: context,
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFEA00), Color(0xFFFFB300)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                icon: Icons.image_rounded,
                title: 'Upload Image',
                subtitle: 'Share your photos',
                onTap: onUploadImage,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUploadCard({
    required BuildContext context,
    required Gradient gradient,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isDark ? const Color(0xFF13131E) : Colors.white,
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon Box
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: gradient,
                  boxShadow: [
                    BoxShadow(color: (gradient as LinearGradient).colors.first.withValues(alpha: 0.5), blurRadius: 12),
                  ],
                ),
                child: Icon(icon, color: AppColors.textOnPrimary, size: 20),
              ),

              const SizedBox(width: 10),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.heroHeading.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF161622),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: isDark ? AppColors.textSecondary : const Color(0xFF6B6B78),
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
