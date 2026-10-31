import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/luxe_theme.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../family/presentation/screens/family_team_screen.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../controllers/profile_controller.dart';
import '../../../home/domain/models/live_stream_card_model.dart';
import '../controllers/follow_controller.dart';
import '../widgets/instagram_follow_button.dart';
import '../widgets/edit_profile_dialog.dart';
import '../widgets/profile_luxe_sections.dart';
import '../widgets/tiki_verification_sheet.dart';
import '../../../wallet/presentation/screens/wallet_screen.dart';
import '../../../../core/widgets/tivoo_share_sheet.dart';
import 'package:tivoo/features/messages/messages.dart';
import 'package:tivoo/features/explore/presentation/controllers/posts_controller.dart';
import 'package:tivoo/features/explore/presentation/screens/video_post_viewer_screen.dart';
import '../../../gifter_level/presentation/screens/gifter_level_screen.dart';

/// VIP profile in the Luxe style: top bar, identity header, bio, actions, badges,
/// Videos / Likes bar and the Drafts / Pinned / My Posts content grid.
class ProfileScreen extends ConsumerStatefulWidget {
  final LiveStreamCardModel? streamer;

  const ProfileScreen({super.key, this.streamer});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isViewingDrafts = false;

  static const _draftsFolder = ProfileVideo(AppAssets.draft1, isDraftFolder: true);

  final List<DraftVideoItem> _drafts = [
    const DraftVideoItem(
      id: 'd1',
      asset: AppAssets.draft1,
      title: 'Vlog cut #1',
      duration: '00:42',
      date: 'Today',
    ),
    const DraftVideoItem(
      id: 'd2',
      asset: AppAssets.draft2,
      title: 'Story draft #2',
      duration: '01:15',
      date: 'Yesterday',
    ),
    const DraftVideoItem(
      id: 'd3',
      asset: AppAssets.draft3,
      title: 'Reel edit #3',
      duration: '00:58',
      date: '2d ago',
    ),
    const DraftVideoItem(
      id: 'd4',
      asset: AppAssets.draft4,
      title: 'Music session #4',
      duration: '00:32',
      date: '3d ago',
    ),
    const DraftVideoItem(
      id: 'd5',
      asset: AppAssets.draft5,
      title: 'Special live #5',
      duration: '01:20',
      date: '5d ago',
    ),
    const DraftVideoItem(
      id: 'd6',
      asset: AppAssets.draft6,
      title: 'Highlights #6',
      duration: '00:48',
      date: '1w ago',
    ),
  ];

  void _toast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), duration: const Duration(milliseconds: 900)));
  }

  void _toggleBlock(BuildContext context, String userId, String userName, bool isBlocked) {
    if (isBlocked) {
      ref.read(followControllerProvider.notifier).unblockUser(
        userId,
        onStatusNotify: (msg) => _toast(msg),
      );
    } else {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF141927),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.block_rounded, color: Color(0xFFFF4B6E), size: 24),
              SizedBox(width: 8),
              Text('Block User', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'Are you sure you want to block $userName? They will no longer be able to message you, view your profile, or see your activity.',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4B6E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                ref.read(followControllerProvider.notifier).blockUser(
                  userId,
                  onStatusNotify: (msg) => _toast(msg),
                );
              },
              child: const Text('Block'),
            ),
          ],
        ),
      );
    }
  }

  void _goBack() {
    if (_isViewingDrafts) {
      setState(() => _isViewingDrafts = false);
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      ref.read(bottomNavIndexProvider.notifier).state = 0; // Home tab
    }
  }

  void _open(Widget screen) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));

  void _openDraftOptions(DraftVideoItem draft) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
          decoration: const BoxDecoration(
            color: Color(0xFF100D28),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Color(0x66000000), blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(draft.asset, width: 50, height: 50, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          draft.title,
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${draft.duration} • Saved ${draft.date}',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LuxeColors.goldGradient,
                  ),
                  child: const Icon(Icons.edit_rounded, color: Color(0xFF1A1300), size: 18),
                ),
                title: const Text('Edit Draft', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: const Text('Add sound, stickers, effects or trim video', style: TextStyle(color: Colors.white54, fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  _toast('Opening video editor for "${draft.title}" ✂️');
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF2E9BFF).withValues(alpha: 0.2),
                  ),
                  child: const Icon(Icons.publish_rounded, color: Color(0xFF2E9BFF), size: 18),
                ),
                title: const Text('Post to Feed Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                subtitle: const Text('Publish this draft to your profile', style: TextStyle(color: Colors.white54, fontSize: 11)),
                onTap: () {
                  Navigator.pop(ctx);
                  _toast('Publishing "${draft.title}" to profile! 🎉');
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.redAccent.withValues(alpha: 0.2),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                ),
                title: const Text('Delete Draft', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _drafts.removeWhere((d) => d.id == draft.id);
                  });
                  _toast('Draft deleted');
                },
              ),
            ],
          ),
        );
      },
    );
  }

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

  void _showChangeAvatarSheet() {
    final avatarPresets = [
      AppAssets.status5,
      AppAssets.avatarNeha,
      AppAssets.avatarPriya,
      AppAssets.avatarDiya,
      AppAssets.avatarSneha,
      AppAssets.avatarArun,
      AppAssets.avatarKarthik,
      AppAssets.avatarMeena,
      AppAssets.status1,
      AppAssets.status2,
      AppAssets.status3,
      AppAssets.status4,
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: const BoxDecoration(
            color: Color(0xFF100D28),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Color(0x99000000), blurRadius: 28, offset: Offset(0, -4))],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Change Profile Picture',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Upload from your gallery, camera, or choose an avatar',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 18),
                _UploadOptionTile(
                  icon: Icons.photo_library_rounded,
                  iconColor: const Color(0xFFFFB800),
                  iconBg: const Color(0x26FFB800),
                  title: 'Upload from Gallery',
                  subtitle: 'Select a photo from your album',
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(source: ImageSource.gallery);
                      if (picked != null) {
                        ref.read(profileControllerProvider.notifier).updateProfile(avatarUrl: picked.path);
                        _toast('Profile picture updated from gallery! 📸');
                      }
                    } catch (e) {
                      _toast('Could not pick photo: $e');
                    }
                  },
                ),
                const SizedBox(height: 10),
                _UploadOptionTile(
                  icon: Icons.camera_alt_rounded,
                  iconColor: const Color(0xFFFF4081),
                  iconBg: const Color(0x26FF4081),
                  title: 'Take a Photo (Camera)',
                  subtitle: 'Capture a selfie or photo right now',
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(source: ImageSource.camera);
                      if (picked != null) {
                        ref.read(profileControllerProvider.notifier).updateProfile(avatarUrl: picked.path);
                        _toast('Profile picture updated from camera! 📷');
                      }
                    } catch (e) {
                      _toast('Could not take photo: $e');
                    }
                  },
                ),
                const SizedBox(height: 18),
                const Text(
                  'Or Choose an Avatar',
                  style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 64,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: avatarPresets.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      final asset = avatarPresets[i];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          ref.read(profileControllerProvider.notifier).updateProfile(avatarUrl: asset);
                          _toast('Avatar chosen! 🌟');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFFDF00), width: 1.5),
                          ),
                          child: CustomAvatar(radius: 26, assetPath: asset),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeletePostOption(ProfileVideo video) {
    if (video.post == null) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: const BoxDecoration(
            color: Color(0xFF100D28),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [BoxShadow(color: Color(0x99000000), blurRadius: 28, offset: Offset(0, -4))],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Post Options',
                  style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.redAccent.withValues(alpha: 0.16),
                    ),
                    child: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 22),
                  ),
                  title: const Text('Delete Post', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600, fontSize: 16)),
                  subtitle: const Text('This post will be permanently removed', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final post = video.post;
                    if (post == null) return;

                    try {
                      await ref.read(postsControllerProvider.notifier).delete(post);
                      _toast('Post deleted successfully 🗑️');
                    } catch (e) {
                      _toast('Could not delete: $e');
                    }
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white70, size: 22),
                  ),
                  title: const Text('Cancel', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600, fontSize: 15)),
                  onTap: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openVideo(ProfileVideo video) {
    final post = video.post;
    if (post == null) return;
    final myPosts = ref.read(postsControllerProvider).myPosts;
    VideoPostViewerScreen.open(context, myPosts, initialIndex: myPosts.indexOf(post).clamp(0, myPosts.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final isViewingStreamer = widget.streamer != null;
    final streamer = widget.streamer;
    final profile = ref.watch(profileControllerProvider).profile;
    final followMap = ref.watch(followControllerProvider);
    final relationship = isViewingStreamer
        ? (followMap[streamer!.id] ??
            ref.read(followControllerProvider.notifier).getRelationship(
                  streamer.id,
                  defaultName: streamer.streamerName,
                  defaultAvatar: streamer.streamerAssetPath ?? streamer.streamerAvatarUrl ?? '',
                  initialFollowers: 120400,
                  initialFollowing: streamer.isFollowing,
                ))
        : null;

    final myPosts = ref.watch(postsControllerProvider).myPosts;

    final s = profileScale(context);
    final gap = SizedBox(height: 12 * s);

    return PopScope(
      canPop: !_isViewingDrafts,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _isViewingDrafts) {
          setState(() => _isViewingDrafts = false);
        }
      },
      child: Scaffold(
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
                  padding: EdgeInsets.fromLTRB(14 * s, 8, 14 * s, 120 + MediaQuery.paddingOf(context).bottom),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: context.isTablet ? 680 : double.infinity),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProfileTopBar(
                            onBack: _goBack,
                            onMenu: isViewingStreamer ? null : _showMenu,
                            onSettings: isViewingStreamer ? null : () => _open(const SettingsScreen()),
                            showActions: true,
                          ),
                          SizedBox(height: 20 * s),
                          ProfileIdentityHeader(
                            username: isViewingStreamer
                                ? streamer!.streamerName.toLowerCase().replaceAll(' ', '_')
                                : profile.username,
                            avatarAsset: isViewingStreamer
                                ? (streamer!.streamerAssetPath ??
                                    (streamer.streamerAvatarUrl == null
                                        ? AppAssets.liveCard1
                                        : streamer.streamerAvatarUrl!))
                                : (profile.avatarUrl.isNotEmpty ? profile.avatarUrl : AppAssets.status5),
                            followersCount: isViewingStreamer
                                ? relationship!.formattedFollowers
                                : profile.followersCount,
                            followingCount: isViewingStreamer ? '142' : '${profile.followingCount}',
                            likesCount: isViewingStreamer ? '45.2K' : profile.likesCount,
                            onAvatarCamera: isViewingStreamer ? () {} : _showChangeAvatarSheet,
                            onLevelTap: () => GifterLevelScreen.push(context),
                          ),
                          SizedBox(height: 10 * s),
                          ProfileBio(
                            name: isViewingStreamer ? streamer!.streamerName : profile.name,
                            bio: isViewingStreamer ? streamer!.streamerBio : profile.bio,
                          ),
                          SizedBox(height: 14 * s),
                          if (isViewingStreamer)
                            Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: InstagramFollowButton(
                                    userId: streamer!.id,
                                    userName: streamer.streamerName,
                                    userAvatar: streamer.streamerAssetPath ?? streamer.streamerAvatarUrl ?? '',
                                    initialFollowers: 120400,
                                    initialFollowing: streamer.isFollowing,
                                    height: 44 * s,
                                  ),
                                ),
                                SizedBox(width: 8 * s),
                                Expanded(
                                  flex: 4,
                                  child: ProfileMessageButton(
                                    userId: streamer.id,
                                    userName: streamer.streamerName,
                                    userAvatar: streamer.streamerAssetPath ?? streamer.streamerAvatarUrl ?? '',
                                    isVerified: streamer.isVerified,
                                    height: 44 * s,
                                  ),
                                ),
                                SizedBox(width: 8 * s),
                                SizedBox(
                                  width: 44 * s,
                                  height: 44 * s,
                                  child: IconButton(
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    onPressed: () => _toggleBlock(
                                      context,
                                      streamer.id,
                                      streamer.streamerName,
                                      relationship?.isBlocked ?? false,
                                    ),
                                    icon: Icon(
                                      (relationship?.isBlocked ?? false)
                                          ? Icons.lock_open_rounded
                                          : Icons.block_rounded,
                                      size: 18,
                                      color: (relationship?.isBlocked ?? false)
                                          ? Colors.white70
                                          : const Color(0xFFFF4B6E),
                                    ),
                                    tooltip: (relationship?.isBlocked ?? false) ? 'Unblock' : 'Block',
                                  ),
                                ),
                              ],
                            )
                          else
                            ProfileActions(
                              onEdit: _editProfile,
                              onMessagesTap: () => _open(const MessagesInboxScreen()),
                              unreadCount: ref.watch(messagesControllerProvider).totalUnreadCount,
                            ),
                          if (!isViewingStreamer) ...[
                            gap,
                            ProfileBadgesRow(
                              onTikiStar: () => TivooVerificationSheet.show(context),
                              onAngels: () => _toast('Your angels'),
                              onShare: () {
                                final profile = ref.read(profileControllerProvider).profile;
                                final shareUrl = 'https://tivoo.app/profile/${profile.username}';
                                final shareText = 'Check out ${profile.name} (@${profile.username}) on Tivoo! $shareUrl';
                                TivooShareSheet.show(
                                  context,
                                  title: 'Share Profile',
                                  subtitle: '@${profile.username}',
                                  shareUrl: shareUrl,
                                  shareText: shareText,
                                );
                              },
                              onFamily: () => _open(const FamilyTeamScreen()),
                            ),
                          ],
                          SizedBox(height: 24 * s),
                          ProfileContentPanel(
                            isViewingDrafts: _isViewingDrafts,
                            // Videos only: your uploads after the Drafts folder (other creators have none yet).
                            videos: isViewingStreamer
                                ? const []
                                : [_draftsFolder, ...myPosts.map(ProfileVideo.uploaded)],
                            draftVideos: _drafts,
                            onOpen: _openVideo,
                            onLongPressVideo: isViewingStreamer ? null : _showDeletePostOption,
                            onOpenDrafts: () => setState(() => _isViewingDrafts = true),
                            onCloseDrafts: () => setState(() => _isViewingDrafts = false),
                            onOpenDraft: _openDraftOptions,
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
                          item(
                            Icons.account_balance_wallet_rounded,
                            const Color(0xFFFF9100),
                            'Wallet / Balance',
                            () => WalletScreen.push(context),
                            subtitle: 'Coins, Stars',
                          ),
                          item(
                            Icons.military_tech_rounded,
                            LuxeColors.gold,
                            'Gifter Level & Rewards',
                            () => GifterLevelScreen.push(context),
                            subtitle: 'Milestone frames, badges & perks',
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

class _UploadOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _UploadOptionTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.white38,
          size: 15,
        ),
        onTap: onTap,
      ),
    );
  }
}
