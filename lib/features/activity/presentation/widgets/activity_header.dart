import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glow_icon_button.dart';

class ActivityHeader extends StatelessWidget {
  final VoidCallback? onNotificationTap;

  const ActivityHeader({
    super.key,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title & Subtitle in Expanded to prevent text overflow
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Activity',
                  style: AppTextStyles.heroHeading.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF161622),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Stay updated with your favorite streamers',
                  style: AppTextStyles.heroSubtitle.copyWith(
                    fontSize: 13.5,
                    color: isDark ? AppColors.textSecondary : const Color(0xFF6B6B78),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Right Notification Bell
          GlowIconButton(
            icon: Icons.notifications_none_rounded,
            iconSize: 22,
            onTap: onNotificationTap,
          ),
        ],
      ),
    );
  }
}
