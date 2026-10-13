import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glow_icon_button.dart';
import '../controllers/settings_controller.dart';
import '../widgets/settings_tile.dart';

class NotificationsSettingsScreen extends ConsumerWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final notifs = settings.notifications;

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
          'Notifications',
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
            // Master Switch
            SettingsSectionCard(
              title: 'Master Control',
              children: [
                SettingsSwitchTile(
                  icon: Icons.notifications_off_outlined,
                  iconColor: Colors.orangeAccent,
                  title: 'Pause All Notifications',
                  subtitle: 'Temporarily silence all push notifications from Tivoo.',
                  value: notifs.muteAll,
                  showDivider: false,
                  onChanged: (val) => controller.toggleMuteAll(val),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Interactions
            SettingsSectionCard(
              title: 'Social & Interactions',
              children: [
                SettingsSwitchTile(
                  icon: Icons.favorite_border_rounded,
                  title: 'Likes',
                  subtitle: 'Notifications when someone likes your videos or stream.',
                  value: notifs.likes,
                  onChanged: notifs.muteAll
                      ? (val) {}
                      : (val) => controller.toggleNotificationLikes(val),
                ),
                SettingsSwitchTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Comments',
                  subtitle: 'When someone comments on your posts or live chat.',
                  value: notifs.comments,
                  onChanged: notifs.muteAll
                      ? (val) {}
                      : (val) => controller.toggleNotificationComments(val),
                ),
                SettingsSwitchTile(
                  icon: Icons.person_add_outlined,
                  title: 'New Followers',
                  subtitle: 'Get notified when another user starts following you.',
                  value: notifs.followers,
                  onChanged: notifs.muteAll
                      ? (val) {}
                      : (val) => controller.toggleNotificationFollowers(val),
                ),
                SettingsSwitchTile(
                  icon: Icons.mail_outline_rounded,
                  title: 'Direct Messages',
                  subtitle: 'Instant alerts for private chats and message requests.',
                  value: notifs.directMessages,
                  showDivider: false,
                  onChanged: notifs.muteAll
                      ? (val) {}
                      : (val) => controller.toggleNotificationMessages(val),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Live & Gifts
            SettingsSectionCard(
              title: 'Live Streams & Rewards',
              children: [
                SettingsSwitchTile(
                  icon: Icons.videocam_outlined,
                  title: 'Live Stream Alerts',
                  subtitle: 'Alerts when streamers and friends you follow go live.',
                  value: notifs.liveAlerts,
                  onChanged: notifs.muteAll
                      ? (val) {}
                      : (val) => controller.toggleNotificationLiveAlerts(val),
                ),
                SettingsSwitchTile(
                  icon: Icons.card_giftcard_rounded,
                  title: 'Gifts & Coin Rewards',
                  subtitle: 'Notifications when you receive diamonds, gifts or tips.',
                  value: notifs.giftsReceived,
                  showDivider: false,
                  onChanged: notifs.muteAll
                      ? (val) {}
                      : (val) => controller.toggleNotificationGifts(val),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
