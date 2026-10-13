import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/glow_icon_button.dart';
import '../../domain/models/user_profile_model.dart';

class ProfileHeroHeader extends ConsumerWidget {
  final UserProfileModel profile;
  final VoidCallback? onBackTap;
  final VoidCallback? onEditTap;
  final VoidCallback? onSettingsTap;

  const ProfileHeroHeader({super.key, required this.profile, this.onBackTap, this.onEditTap, this.onSettingsTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final topPadding = MediaQuery.paddingOf(context).top;

    return Stack(
      children: [
        // 1. Atmospheric Hero Background Image with Gradient Overlay
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 330 + topPadding,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: profile.coverBackgroundUrl,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                fadeInDuration: const Duration(milliseconds: 150),
                memCacheWidth: 800,
                memCacheHeight: 600,
                placeholder: (context, url) => Container(color: const Color(0xFF13131E)),
                errorWidget: (context, url, error) => Container(color: const Color(0xFF13131E)),
              ),
              // Gradient Scrim from Top to Bottom
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.45),
                      Colors.black.withValues(alpha: 0.7),
                      Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.95),
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                    stops: const [0.0, 0.45, 0.85, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2. Foreground Content with Safe Status Bar Spacing
        Padding(
          padding: EdgeInsets.fromLTRB(16, topPadding > 0 ? topPadding + 10 : 20, 16, 0),
          child: Column(
            children: [
              // Top Action Bar: Back, Theme Toggle, Edit, Settings
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GlowIconButton(
                    icon: Icons.chevron_left_rounded,
                    size: 40,
                    iconSize: 26,
                    backgroundColor: const Color(0x99181828),
                    onTap: onBackTap ?? () => Navigator.maybePop(context),
                  ),
                  Row(
                    children: [
                      GlowIconButton(
                        icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        size: 40,
                        backgroundColor: AppColors.surfaceColor.withValues(alpha: 0.85),
                        iconColor: isDark ? AppColors.primaryYellow : AppColors.primaryAmber,
                        glow: true,
                        glowColor: isDark ? AppColors.primaryYellow : AppColors.primaryAmber,
                        onTap: () {
                          ref.read(themeModeProvider.notifier).toggleTheme();
                        },
                      ),
                      const SizedBox(width: 8),
                      GlowIconButton(
                        icon: Icons.edit_outlined,
                        size: 40,
                        backgroundColor: const Color(0x99181828),
                        onTap: onEditTap,
                      ),
                      const SizedBox(width: 8),
                      GlowIconButton(
                        icon: Icons.settings_outlined,
                        size: 40,
                        backgroundColor: const Color(0x99181828),
                        onTap: onSettingsTap,
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Avatar & User Details Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Avatar with Glowing Rainbow Ring & Green Online Dot
                  _buildAvatarWithRing(),

                  const SizedBox(width: 16),

                  // Name, verified badge, username, tagline, roles
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                profile.name,
                                style: AppTextStyles.heroHeading.copyWith(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (profile.isVerified) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.verified, color: Color(0xFF388AF6), size: 19),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile.username,
                          style: AppTextStyles.streamerTagline.copyWith(fontSize: 13, color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile.bio,
                          style: AppTextStyles.streamerTagline.copyWith(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Roles Badges: Streamer & Content Creator
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: profile.roles.map((role) {
                            final isFirst = role == profile.roles.first;
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: isFirst ? AppColors.getStartedButtonGradient : null,
                                color: isFirst ? null : AppColors.cardBackground,
                                border: isFirst
                                    ? null
                                    : Border.all(color: AppColors.primaryYellow.withValues(alpha: 0.4), width: 1),
                              ),
                              child: Text(
                                role,
                                style: TextStyle(
                                  color: isFirst ? AppColors.textOnPrimary : Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatarWithRing() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 94,
          height: 94,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.storyRingGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryYellow.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(2.5),
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF13131E)),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: profile.avatarUrl,
                width: 82,
                height: 82,
                fit: BoxFit.cover,
                memCacheWidth: 200,
                memCacheHeight: 200,
                placeholder: (context, url) => Container(color: AppColors.surfaceColor),
                errorWidget: (context, url, error) => const Icon(Icons.person, size: 42),
              ),
            ),
          ),
        ),
        if (profile.isOnline)
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              width: 17,
              height: 17,
              decoration: BoxDecoration(
                color: const Color(0xFF00E676),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF13131E), width: 2.5),
                boxShadow: const [BoxShadow(color: Color(0x6600E676), blurRadius: 6)],
              ),
            ),
          ),
      ],
    );
  }
}
