import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/luxe_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../family/presentation/screens/family_team_screen.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../controllers/profile_controller.dart';
import '../widgets/edit_profile_dialog.dart';
import '../widgets/profile_luxe_sections.dart';
import '../widgets/tiki_verification_sheet.dart';

/// VIP profile in the Luxe style: top bar, identity header, bio, actions, badges,
/// Videos / Likes bar and the Drafts / Pinned / My Posts content grid.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _tab = 1; // 0 = Drafts, 1 = Pinned, 2 = My Posts
  bool _showVideos = true;

  static const _videos = [
    ProfileVideo(AppAssets.status1, draft: true),
    ProfileVideo(AppAssets.status2, views: '4.9K', pinned: true),
    ProfileVideo(AppAssets.status3, views: '6.3K', pinned: true),
    ProfileVideo(AppAssets.status4, views: '8.2K', pinned: true),
    ProfileVideo(AppAssets.avatarNeha, views: '5.7K'),
    ProfileVideo(AppAssets.status5, views: '9.1K'),
  ];

  void _toast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), duration: const Duration(milliseconds: 900)));
  }

  void _goBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      ref.read(bottomNavIndexProvider.notifier).state = 0; // Home tab
    }
  }

  void _open(Widget screen) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  void _editProfile() {
    final controller = ref.read(profileControllerProvider.notifier);
    EditProfileDialog.show(
      context,
      profile: ref.read(profileControllerProvider).profile,
      onSave: ({required String name, required String username, required String bio, required String aboutMe}) {
        controller.updateProfile(name: name, username: username, bio: bio, aboutMe: aboutMe);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileControllerProvider).profile;
    final s = profileScale(context);
    final gap = SizedBox(height: 12 * s);

    return Scaffold(
      backgroundColor: const Color(0xFF07061A),
      body: Stack(
        children: [
          const Positioned.fill(child: ProfileBackdrop()),
          SafeArea(
            bottom: false,
            child: DefaultTextStyle.merge(
              style: const TextStyle(fontFamily: 'Poppins'),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(14 * s, 8, 14 * s, 120),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: context.isTablet ? 680 : double.infinity),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileTopBar(
                          onBack: _goBack,
                          onVip: () => _toast('👑 VIP host tier active'),
                          onMenu: _showMenu,
                          onSettings: () => _open(const SettingsScreen()),
                        ),
                        SizedBox(height: 20 * s),
                        ProfileIdentityHeader(
                          username: profile.username,
                          avatarAsset: AppAssets.status5,
                          onAvatarCamera: () => _toast('Change profile photo'),
                        ),
                        SizedBox(height: 10 * s),
                        ProfileBio(name: profile.name, bio: profile.bio),
                        SizedBox(height: 14 * s),
                        ProfileActions(
                          onEdit: _editProfile,
                          onFindFriends: () => _toast('Finding friends & nearby creators...'),
                          onCamera: () => _toast('Open camera / create story'),
                        ),
                        gap,
                        ProfileBadgesRow(
                          onTikiStar: () => TikiVerificationSheet.show(context),
                          onAngels: () => _toast('Your angels'),
                          onShare: () => _toast('Sharing profile link ✨'),
                          onFamily: () => _open(const FamilyTeamScreen()),
                        ),
                        gap,
                        ProfileStatsBar(
                          videos: 411,
                          likes: 39637,
                          showVideos: _showVideos,
                          onChanged: (v) => setState(() => _showVideos = v),
                        ),
                        gap,
                        ProfileContentPanel(
                          tab: _tab,
                          onTab: (t) => setState(() => _tab = t),
                          videos: _videos,
                          onOpen: (v) =>
                              _toast(v.draft ? 'Opening drafts (12 videos)' : 'Playing video · ${v.views} views'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Menu sheet
  // ---------------------------------------------------------------------------

  void _showMenu() {
    final profile = ref.read(profileControllerProvider).profile;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        void go(VoidCallback action) {
          Navigator.pop(ctx);
          action();
        }

        Widget item(IconData icon, Color color, String title, VoidCallback onTap, {String? subtitle}) => ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.16), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          subtitle: subtitle == null
              ? null
              : Text(subtitle, style: const TextStyle(color: LuxeColors.textDim, fontSize: 11)),
          trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white24, size: 14),
          onTap: () => go(onTap),
        );

        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.85),
          padding: const EdgeInsets.only(top: 1.4),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            gradient: LinearGradient(colors: LuxeColors.goldToNeon),
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: LuxeColors.bg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(27)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LuxeColors.goldGradient),
                      child: const CustomAvatar(radius: 22, assetPath: AppAssets.status5),
                    ),
                    title: Text(
                      profile.name,
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '@${profile.username} • VIP Host',
                      style: const TextStyle(color: LuxeColors.gold, fontSize: 12),
                    ),
                    trailing: IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  Flexible(
                    child: Material(
                      type: MaterialType.transparency,
                      child: ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        children: [
                          item(Icons.person_outline_rounded, LuxeColors.gold, 'My Profile', () {}),
                          item(
                            Icons.insights_rounded,
                            LuxeColors.goldDeep,
                            'Creator Tools',
                            () => _toast('📊 Creator tools & analytics'),
                            subtitle: 'Analytics, LIVE Center, Monetization',
                          ),
                          item(
                            Icons.account_balance_wallet_rounded,
                            const Color(0xFFFF9100),
                            'Wallet / Balance',
                            () => _toast('💎 Wallet: 6,850 diamonds • 120 stars'),
                            subtitle: 'Diamonds, Coins, Stars',
                          ),
                          item(
                            Icons.military_tech_outlined,
                            LuxeColors.gold,
                            'My Level & Rewards',
                            () => _toast('👑 Level 10 host • SVIP badge active'),
                          ),
                          item(
                            Icons.groups_rounded,
                            const Color(0xFF8FB8FF),
                            'Family / Team',
                            () => _open(const FamilyTeamScreen()),
                          ),
                          item(
                            Icons.settings_outlined,
                            Colors.white70,
                            'Settings & Privacy',
                            () => _open(const SettingsScreen()),
                            subtitle: 'AI Content Moderation, Privacy, Account',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
