import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glow_icon_button.dart';
import '../controllers/settings_controller.dart';
import '../widgets/settings_tile.dart';

class LiveContentSettingsScreen extends ConsumerWidget {
  const LiveContentSettingsScreen({super.key});

  void _showContentLanguageDialog(BuildContext context, WidgetRef ref, String currentLang) {
    final languages = [
      'English',
      'Hindi',
      'Spanish',
      'French',
      'Arabic',
      'German',
      'Russian',
      'Japanese',
      'Korean',
      'Portuguese',
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Preferred Content Language',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final lang = languages[index];
              final isSelected = lang == currentLang;
              return ListTile(
                title: Text(
                  lang,
                  style: TextStyle(
                    color: isSelected ? AppColors.primaryYellow : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryYellow)
                    : null,
                onTap: () {
                  ref.read(settingsControllerProvider.notifier).setContentLanguage(lang);
                  Navigator.pop(ctx);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final live = settings.liveContent;

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
          'Live & Content Settings',
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
            // Live Stream Interactions
            SettingsSectionCard(
              title: 'Live Stream Controls',
              children: [
                SettingsSwitchTile(
                  icon: Icons.chat_rounded,
                  title: 'Allow Live Chat Comments',
                  subtitle: 'Enable viewers to send live messages while you stream.',
                  value: live.allowComments,
                  onChanged: (val) => controller.toggleAllowComments(val),
                ),
                SettingsSwitchTile(
                  icon: Icons.group_add_rounded,
                  title: 'Co-Host & Guest Invitations',
                  subtitle: 'Allow other streamers to invite you to split-screen live sessions.',
                  value: live.allowLiveInvitations,
                  onChanged: (val) => controller.toggleAllowLiveInvitations(val),
                ),
                SettingsSwitchTile(
                  icon: Icons.card_giftcard_rounded,
                  title: 'Receive Virtual Gifts',
                  subtitle: 'Allow viewers to send coins, animations, and tips during streams.',
                  value: live.acceptVirtualGifts,
                  showDivider: false,
                  onChanged: (val) => controller.toggleAcceptVirtualGifts(val),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Feed & Content
            SettingsSectionCard(
              title: 'Feed & Content Preferences',
              children: [
                SettingsSwitchTile(
                  icon: Icons.filter_list_rounded,
                  title: 'Filter Mature Content',
                  subtitle: 'Hide streams and videos flagged with mature or sensitive content.',
                  value: live.filterMatureContent,
                  onChanged: (val) => controller.toggleFilterMatureContent(val),
                ),
                SettingsTile(
                  icon: Icons.translate_rounded,
                  title: 'Content Language',
                  subtitle: 'Prioritize streams and videos in this language.',
                  trailingText: live.contentLanguage,
                  onTap: () => _showContentLanguageDialog(context, ref, live.contentLanguage),
                ),
                SettingsSwitchTile(
                  icon: Icons.wifi_rounded,
                  title: 'Autoplay on Wi-Fi Only',
                  subtitle: 'Conserve mobile cellular data while scrolling through videos.',
                  value: live.autoplayWifiOnly,
                  showDivider: false,
                  onChanged: (val) => controller.toggleAutoplayWifiOnly(val),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
