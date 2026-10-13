import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/models/user_profile_model.dart';

class ProfileStatsBar extends StatelessWidget {
  final UserProfileModel profile;

  const ProfileStatsBar({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final stats = [
      _StatItem(
        icon: Icons.videocam_outlined,
        iconColor: AppColors.primaryYellow,
        count: '${profile.liveStreamsCount}',
        label: 'Live Streams',
      ),
      _StatItem(
        icon: Icons.favorite_border_rounded,
        iconColor: AppColors.primaryAmber,
        count: profile.followersCount,
        label: 'Followers',
      ),
      _StatItem(
        icon: Icons.person_outline_rounded,
        iconColor: const Color(0xFFFFEA00),
        count: '${profile.followingCount}',
        label: 'Following',
      ),
      _StatItem(
        icon: Icons.visibility_outlined,
        iconColor: const Color(0xFFFFF176),
        count: profile.totalViews,
        label: 'Total Views',
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: isDark ? const Color(0xFF13131E) : Colors.white,
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: stats.map((stat) {
          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: stat.iconColor.withValues(alpha: 0.12),
                    boxShadow: [BoxShadow(color: stat.iconColor.withValues(alpha: 0.35), blurRadius: 10)],
                  ),
                  child: Icon(stat.icon, color: stat.iconColor, size: 20),
                ),
                const SizedBox(height: 6),
                Text(
                  stat.count,
                  style: AppTextStyles.heroHeading.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF161622),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  stat.label,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textSecondary : const Color(0xFF6B6B78),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatItem {
  final IconData icon;
  final Color iconColor;
  final String count;
  final String label;

  _StatItem({required this.icon, required this.iconColor, required this.count, required this.label});
}
