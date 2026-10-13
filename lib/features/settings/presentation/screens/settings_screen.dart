import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../../core/widgets/glow_icon_button.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../widgets/settings_tile.dart';

import 'ai_content_moderation_screen.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';
import 'help_support_screen.dart';
import 'legal_policy_screen.dart';
import 'live_content_settings_screen.dart';
import 'notifications_settings_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: const [
            Icon(Icons.logout_rounded, color: Color(0xFFFF453A)),
            SizedBox(width: 10),
            Text(
              'Log Out of Tivoo?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out? You will need to enter your password to log back in.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF453A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: () {
              ref.read(authControllerProvider.notifier).logout();
              Navigator.pop(ctx);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logged out successfully.')),
              );
            },
            child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileControllerProvider).profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GlowIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          size: 38,
          backgroundColor: AppColors.cardBackground,
          iconColor: AppColors.textPrimary,
          onTap: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings & Privacy',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            // User Mini Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryYellow.withValues(alpha: 0.25),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryYellow.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.storyRingGradient,
                    ),
                    child: CustomAvatar(
                      radius: 28,
                      imageUrl: profile.avatarUrl,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              profile.name,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (profile.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified_rounded,
                                color: AppColors.primaryYellow,
                                size: 16,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile.username,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryYellow,
                      side: const BorderSide(color: AppColors.primaryYellow, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                      );
                    },
                    child: const Text('Edit', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 1. Account & Security
            SettingsSectionCard(
              title: 'Account & Security',
              children: [
                SettingsTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Edit Profile',
                  subtitle: 'Name, photo, username, bio, phone, and email',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    );
                  },
                ),
                SettingsTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Change Password',
                  subtitle: 'Update your security credentials',
                  showDivider: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 2. Preferences & Interactions
            SettingsSectionCard(
              title: 'Preferences & Interactions',
              children: [
                SettingsTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  subtitle: 'Likes, comments, followers, live alerts, gifts',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const NotificationsSettingsScreen()),
                    );
                  },
                ),
                SettingsTile(
                  icon: Icons.psychology_rounded,
                  title: 'AI Video Moderation & Detection',
                  subtitle: 'Avoid unwanted videos, sensitivity filter & 5-step detection',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AiContentModerationScreen()),
                    );
                  },
                ),
                SettingsTile(
                  icon: Icons.live_tv_rounded,
                  title: 'Live & Content Settings',
                  subtitle: 'Live comments, co-hosting, virtual gifts, filters',
                  showDivider: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LiveContentSettingsScreen()),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // 3. Support & Legal
            SettingsSectionCard(
              title: 'Support & Legal',
              children: [
                SettingsTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  subtitle: 'Help Center & Report Problem',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HelpSupportScreen()),
                    );
                  },
                ),
                SettingsTile(
                  icon: Icons.policy_outlined,
                  title: 'Legal & Policies',
                  subtitle: 'Privacy Policy, Terms of Use, Community Guidelines',
                  showDivider: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LegalPolicyScreen()),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 4. Logout Section
            SettingsSectionCard(
              children: [
                SettingsTile(
                  icon: Icons.logout_rounded,
                  isDestructive: true,
                  title: 'Log Out',
                  subtitle: 'Sign out of @${profile.username}',
                  showDivider: false,
                  onTap: () => _showLogoutDialog(context, ref),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Footer Version Info
            Column(
              children: const [
                Text(
                  'Tivoo Live',
                  style: TextStyle(
                    color: AppColors.primaryYellow,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Version 1.0.0 (Build 2026.09) • Made with 💛',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
