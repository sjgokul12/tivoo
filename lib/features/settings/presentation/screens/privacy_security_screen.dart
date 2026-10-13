import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../../core/widgets/glow_icon_button.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../controllers/settings_controller.dart';
import '../widgets/settings_tile.dart';

class PrivacySecurityScreen extends ConsumerWidget {
  const PrivacySecurityScreen({super.key});

  void _show2FADialog(BuildContext context, WidgetRef ref, bool currentValue) {
    if (currentValue) {
      // Disable 2FA confirmation
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Turn Off 2FA?',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          ),
          content: const Text(
            'Turning off Two-Factor Authentication will make your account less secure.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF453A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                ref.read(settingsControllerProvider.notifier).toggle2FA(false);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Two-Factor Authentication disabled.')),
                );
              },
              child: const Text('Turn Off', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    } else {
      // Enable 2FA Sheet
      showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.cardBackground,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (ctx) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Set Up Two-Factor (2FA)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Protect your live stream account with an extra verification code on login.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primaryYellow.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.sms_outlined, color: AppColors.primaryYellow),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SMS Text Message Verification',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Code sent to your verified mobile number',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              GradientButton(
                text: 'Enable 2FA Now',
                onPressed: () {
                  ref.read(settingsControllerProvider.notifier).toggle2FA(true);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Two-Factor Authentication is now active! 🛡️'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showBlockedUsersSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          final currentBlocked =
              ref.watch(settingsControllerProvider).privacy.blockedUsers;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Blocked Accounts (${currentBlocked.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.textSecondary),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (currentBlocked.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: Text(
                        'No blocked users.',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: currentBlocked.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final user = currentBlocked[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              CustomAvatar(radius: 20, imageUrl: user.avatarUrl),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: const TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    Text(
                                      user.username,
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 12,
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
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                ),
                                onPressed: () {
                                  ref
                                      .read(settingsControllerProvider.notifier)
                                      .unblockUser(user.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Unblocked ${user.username}')),
                                  );
                                },
                                child: const Text('Unblock', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final privacy = settings.privacy;

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
          'Privacy & Security',
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
            // Privacy Section
            SettingsSectionCard(
              title: 'Account Privacy',
              children: [
                SettingsSwitchTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Private Account',
                  subtitle:
                      'Only approved followers can view your profile, posts, and live streams.',
                  value: privacy.isPrivateAccount,
                  onChanged: (val) => controller.togglePrivateAccount(val),
                ),
                SettingsSwitchTile(
                  icon: Icons.brightness_1_rounded,
                  iconColor: Colors.greenAccent,
                  title: 'Activity Status',
                  subtitle:
                      'Allow accounts you follow to see when you are currently online on Tivoo.',
                  value: privacy.showActivityStatus,
                  showDivider: false,
                  onChanged: (val) => controller.toggleActivityStatus(val),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Security Section
            SettingsSectionCard(
              title: 'Security Protection',
              children: [
                SettingsTile(
                  icon: Icons.security_rounded,
                  title: 'Two-Factor Authentication',
                  subtitle: privacy.is2FAEnabled
                      ? 'Enabled (SMS Verification)'
                      : 'Disabled — Turn on for maximum security',
                  trailingText: privacy.is2FAEnabled ? 'Active' : 'Off',
                  onTap: () => _show2FADialog(context, ref, privacy.is2FAEnabled),
                ),
                SettingsTile(
                  icon: Icons.devices_rounded,
                  title: 'Manage Active Logins',
                  subtitle: '1 active device (This Android device)',
                  trailingText: 'Current',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All sessions are verified and secure.'),
                      ),
                    );
                  },
                ),
                SettingsTile(
                  icon: Icons.block_rounded,
                  iconColor: Colors.orangeAccent,
                  title: 'Blocked Accounts',
                  subtitle: '${privacy.blockedUsers.length} users blocked',
                  trailingText: '${privacy.blockedUsers.length}',
                  showDivider: false,
                  onTap: () => _showBlockedUsersSheet(context, ref),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
