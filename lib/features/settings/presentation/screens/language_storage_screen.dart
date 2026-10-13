import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glow_icon_button.dart';
import '../controllers/settings_controller.dart';
import '../widgets/settings_tile.dart';

class LanguageStorageScreen extends ConsumerStatefulWidget {
  const LanguageStorageScreen({super.key});

  @override
  ConsumerState<LanguageStorageScreen> createState() => _LanguageStorageScreenState();
}

class _LanguageStorageScreenState extends ConsumerState<LanguageStorageScreen> {
  bool _isClearingCache = false;

  final List<String> _languages = [
    'English',
    'Hindi (हिन्दी)',
    'Spanish (Español)',
    'French (Français)',
    'Arabic (العربية)',
    'German (Deutsch)',
    'Russian (Русский)',
    'Portuguese (Português)',
    'Japanese (日本語)',
    'Korean (한국어)',
  ];

  final List<String> _qualityOptions = [
    'Auto (1080p Recommended)',
    '1080p Full HD',
    '720p HD',
    '480p Standard Definition',
    '360p Data Saver',
  ];

  void _showLanguageDialog(String currentLang) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Select App Language',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _languages.length,
            itemBuilder: (context, index) {
              final lang = _languages[index];
              final isSelected = lang.startsWith(currentLang) || lang == currentLang;
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
                  ref.read(settingsControllerProvider.notifier).setAppLanguage(lang);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('App language changed to $lang')),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showQualityDialog(String currentQuality) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Video Streaming Quality',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _qualityOptions.length,
            itemBuilder: (context, index) {
              final quality = _qualityOptions[index];
              final isSelected = quality == currentQuality;
              return ListTile(
                title: Text(
                  quality,
                  style: TextStyle(
                    color: isSelected ? AppColors.primaryYellow : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryYellow)
                    : null,
                onTap: () {
                  ref.read(settingsControllerProvider.notifier).setVideoQuality(quality);
                  Navigator.pop(ctx);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleClearCache() async {
    setState(() => _isClearingCache = true);
    await Future.delayed(const Duration(milliseconds: 600));
    ref.read(settingsControllerProvider.notifier).clearCache();
    setState(() => _isClearingCache = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.cardBackground,
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: const [
              Icon(Icons.cleaning_services_rounded, color: AppColors.primaryYellow),
              SizedBox(width: 10),
              Text(
                'Cache cleared! 148.6 MB freed up.',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final storage = settings.storageLanguage;

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
          'Language & Storage',
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
            // Language Section
            SettingsSectionCard(
              title: 'Language',
              children: [
                SettingsTile(
                  icon: Icons.language_rounded,
                  title: 'App Interface Language',
                  subtitle: 'Changes navigation, buttons, and app text.',
                  trailingText: storage.appLanguage,
                  showDivider: false,
                  onTap: () => _showLanguageDialog(storage.appLanguage),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Video & Cellular Network
            SettingsSectionCard(
              title: 'Network & Video Playback',
              children: [
                SettingsSwitchTile(
                  icon: Icons.data_saver_on_outlined,
                  iconColor: Colors.cyanAccent,
                  title: 'Data Saver Mode',
                  subtitle:
                      'Reduces streaming resolution when using cellular mobile data.',
                  value: storage.isDataSaver,
                  onChanged: (val) => controller.toggleDataSaver(val),
                ),
                SettingsTile(
                  icon: Icons.hd_outlined,
                  title: 'Default Video Quality',
                  subtitle: 'Preferred resolution for live streams and videos.',
                  trailingText: storage.videoQuality.split(' ').first,
                  showDivider: false,
                  onTap: () => _showQualityDialog(storage.videoQuality),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Cache & Storage
            SettingsSectionCard(
              title: 'Storage & Cache',
              children: [
                SettingsTile(
                  icon: Icons.storage_rounded,
                  title: 'Temporary Cached Files',
                  subtitle:
                      'Includes cached video segments, thumbnails, and fonts.',
                  trailingText: '${storage.cacheSizeMB.toStringAsFixed(1)} MB',
                  onTap: () {},
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: storage.cacheSizeMB > 0
                                ? AppColors.primaryYellow
                                : AppColors.textMuted,
                            side: BorderSide(
                              color: storage.cacheSizeMB > 0
                                  ? AppColors.primaryYellow
                                  : Colors.white12,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: _isClearingCache
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation(
                                        AppColors.primaryYellow),
                                  ),
                                )
                              : const Icon(Icons.delete_sweep_rounded),
                          label: Text(
                            storage.cacheSizeMB > 0
                                ? 'Clear Cache (${storage.cacheSizeMB.toStringAsFixed(1)} MB)'
                                : 'Cache is Clean (0.0 MB)',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          onPressed: (storage.cacheSizeMB > 0 && !_isClearingCache)
                              ? _handleClearCache
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
