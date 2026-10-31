import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/custom_avatar.dart';
import 'user_profile_bottom_sheet.dart';
import '../../../profile/domain/models/follow_relationship.dart';
import '../../../profile/presentation/controllers/follow_controller.dart';
import '../../../profile/presentation/widgets/instagram_follow_actions_sheet.dart';
import '../../../messages/presentation/widgets/profile_message_button.dart';

/// Viewer Profile Screen matching Image 2 (Screen 3) & Image 3 (Screen 3):
/// - Header: Back arrow [<] and More [...]
/// - Profile Photo with glowing gold ring and Crown [👑] badge on bottom
/// - Username (e.g. Queen_Anu 👑 or Aurora_X) with blue verified checkmark
/// - Handle (@queen_anu or @aurora_x)
/// - Bio (multi-line quote / tags / location)
/// - Stats Row: Posts, Followers, Following
/// - Action Buttons: Wide pink [Follow] button + Direct Message / Share button
/// - Content Tabs: Videos (with cyan active indicator), Live, Liked
/// - 3-Column Video Grid with play count badges (▶ 125K, ▶ 98K, etc.)
class ViewerProfileScreen extends ConsumerStatefulWidget {
  final String userName;
  final String? handle;
  final String? avatarAsset;
  final String? bio;
  final String postsCount;
  final String followersCount;
  final String followingCount;
  final bool isVerified;
  final bool initialFollowing;

  const ViewerProfileScreen({
    super.key,
    required this.userName,
    this.handle,
    this.avatarAsset,
    this.bio,
    this.postsCount = '532',
    this.followersCount = '1.2M',
    this.followingCount = '256',
    this.isVerified = true,
    this.initialFollowing = false,
  });

  static Future<void> open(
    BuildContext context, {
    required String userName,
    String? handle,
    String? avatarAsset,
    String? bio,
    String postsCount = '532',
    String followersCount = '1.2M',
    String followingCount = '256',
    bool isVerified = true,
    bool initialFollowing = false,
  }) {
    return UserProfileBottomSheet.show(
      context,
      userName: userName,
      avatarAsset: avatarAsset,
      userId: 'user_${userName.toLowerCase().replaceAll(' ', '_')}',
    );
  }

  @override
  ConsumerState<ViewerProfileScreen> createState() => _ViewerProfileScreenState();
}

class _ViewerProfileScreenState extends ConsumerState<ViewerProfileScreen> {
  int _selectedTab = 0; // 0 = Videos, 1 = Live, 2 = Liked

  final List<Map<String, String>> _videoPosts = [
    {'image': AppAssets.status4, 'views': '125K'},
    {'image': AppAssets.status3, 'views': '98K'},
    {'image': AppAssets.status5, 'views': '210K'},
    {'image': AppAssets.status2, 'views': '76K'},
    {'image': AppAssets.status1, 'views': '145K'},
    {'image': AppAssets.avatarSneha, 'views': '320K'},
  ];

  int _parseFollowers(String raw) {
    final clean = raw.trim().toUpperCase();
    if (clean.endsWith('M')) {
      final val = double.tryParse(clean.replaceAll('M', '')) ?? 1.2;
      return (val * 1000000).toInt();
    } else if (clean.endsWith('K')) {
      final val = double.tryParse(clean.replaceAll('K', '')) ?? 10.0;
      return (val * 1000).toInt();
    }
    return int.tryParse(clean.replaceAll(',', '')) ?? 12500;
  }

  @override
  Widget build(BuildContext context) {
    final streamerId = 'user_${widget.userName.toLowerCase().replaceAll(' ', '_')}';
    final followMap = ref.watch(followControllerProvider);
    final relationship = followMap[streamerId] ??
        ref.read(followControllerProvider.notifier).getRelationship(
              streamerId,
              defaultName: widget.userName,
              defaultAvatar: widget.avatarAsset ?? '',
              initialFollowers: _parseFollowers(widget.followersCount),
              initialFollowing: widget.initialFollowing,
            );
    final avatar = widget.avatarAsset ?? AppAssets.status4;
    final handle = widget.handle ??
        '@${widget.userName.toLowerCase().replaceAll(' ', '_').replaceAll('👑', '').trim()}';
    final bioText = widget.bio ??
        (widget.userName.toLowerCase().contains('aurora')
            ? '✨ Dream • Create • Inspire\n🌸 Good Vibes Only\n📍 Chennai, India'
            : 'Dance • Travel • Positive Vibes ✨\nBelieve in Yourself 💕');

    final screenHeight = MediaQuery.of(context).size.height;
    final coverHeight = screenHeight * 0.44;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0D18),
      body: Stack(
        children: [
          // 1. Large Top Cover Image (Matching Image 1 Step 3: full image without cutoff)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: coverHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  avatar,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF1E2235),
                    child: const Icon(Icons.person, color: Colors.white24, size: 80),
                  ),
                ),
                // Gradient vignette on top for nav bar and bottom for smooth transition
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.50),
                        Colors.transparent,
                        const Color(0xFF0F121E).withValues(alpha: 0.70),
                      ],
                      stops: const [0.0, 0.60, 1.0],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Top Navigation Bar: Back [<] and More [...] (Transparently over cover photo)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: _buildTopNavBar(),
            ),
          ),

          // 3. Scrollable Profile Sheet Overlapping Cover Image
          Positioned.fill(
            top: coverHeight - 44,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0F121E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 18,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Circular Avatar with glowing gold border and gold crown [👑] (Overlapping top-left)
                  Positioned(
                    top: -38,
                    left: 20,
                    child: _buildAvatarWithCrown(avatar),
                  ),

                  // Profile Details Content
                  Positioned.fill(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 52), // Space for overlapping avatar

                          // Username, Crown & Verified badge
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  widget.userName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text('👑', style: TextStyle(fontSize: 18)),
                              if (widget.isVerified) ...[
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.verified_rounded,
                                  color: Color(0xFF2196F3),
                                  size: 20,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),

                          // Handle (@username)
                          Text(
                            handle,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Bio text
                          Text(
                            bioText,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13.5,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Stats Row: Posts, Followers, Following
                          _buildStatsRow(relationship),

                          const SizedBox(height: 20),

                          // Action Buttons: Pink [Follow] + Direct Message
                          _buildActionButtons(relationship, streamerId),

                          const SizedBox(height: 22),

                          // Content Tabs: Videos | Live | Liked
                          _buildTabs(),

                          const SizedBox(height: 16),

                          // 3-Column Video Thumbnail Grid
                          _buildVideosGrid(),

                          const SizedBox(height: 36),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopNavBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),

          // More Options button
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Profile options'),
                  duration: Duration(milliseconds: 900),
                ),
              );
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
              child: const Icon(
                Icons.more_horiz_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarWithCrown(String avatar) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Outer glowing gold ring
        Container(
          width: 98,
          height: 98,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFFFFEA00), Color(0xFFFF9100)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFD600).withValues(alpha: 0.45),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF0D0C15),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(2.5),
                child: CustomAvatar(
                  radius: 43,
                  assetPath: avatar,
                ),
              ),
            ),
          ),
        ),

        // Golden Crown badge overlapping bottom right
        Positioned(
          bottom: 2,
          right: 2,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFFFFEA00), Color(0xFFFF8F00)],
              ),
              border: Border.all(color: Colors.black, width: 1.8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '👑',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(FollowRelationship rel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem(widget.postsCount, 'Posts'),
        Container(width: 1, height: 26, color: Colors.white12),
        _buildStatItem(rel.formattedFollowers, 'Followers'),
        Container(width: 1, height: 26, color: Colors.white12),
        _buildStatItem(widget.followingCount, 'Following'),
      ],
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(FollowRelationship rel, String streamerId) {
    return Row(
      children: [
        // Follow / Requested / Following Button (Backed by followControllerProvider)
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (rel.isNotFollowing) {
                ref.read(followControllerProvider.notifier).sendFollowRequest(
                      streamerId,
                      targetName: widget.userName,
                      targetAvatar: widget.avatarAsset ?? '',
                      initialFollowers: _parseFollowers(widget.followersCount),
                      onStatusNotify: (msg) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(msg),
                            backgroundColor: const Color(0xFF192233),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    );
              } else if (rel.isRequested) {
                InstagramFollowActionsSheet.showRequestedSheet(
                  context,
                  relationship: rel,
                  streamerId: streamerId,
                  onCancelRequest: () {
                    ref.read(followControllerProvider.notifier).cancelFollowRequest(
                          streamerId,
                          onStatusNotify: (msg) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(msg),
                                backgroundColor: const Color(0xFF192233),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        );
                  },
                );
              } else if (rel.isFollowingOrMutual) {
                InstagramFollowActionsSheet.show(
                  context,
                  relationship: rel,
                  streamerId: streamerId,
                );
              } else if (rel.isBlocked) {
                ref.read(followControllerProvider.notifier).unblockUser(
                      streamerId,
                      onStatusNotify: (msg) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(msg),
                            backgroundColor: const Color(0xFF192233),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    );
              }
            },
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                gradient: rel.isFollowingOrMutual
                    ? const LinearGradient(
                        colors: [Color(0xFF2A2B3C), Color(0xFF1E1F2C)],
                      )
                    : (rel.isRequested
                        ? const LinearGradient(
                            colors: [Color(0xFF1F2839), Color(0xFF151C28)],
                          )
                        : const LinearGradient(
                            colors: [Color(0xFFFF2D78), Color(0xFFE91E63)],
                          )),
                borderRadius: BorderRadius.circular(24),
                border: rel.isRequested
                    ? Border.all(color: const Color(0xFFFFD700), width: 1.2)
                    : null,
                boxShadow: rel.isFollowingOrMutual
                    ? null
                    : [
                        BoxShadow(
                          color: (rel.isRequested
                                  ? const Color(0xFFFFD700)
                                  : const Color(0xFFFF2D78))
                              .withValues(alpha: 0.45),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (rel.isFollowingOrMutual) ...[
                      const Icon(Icons.check_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 6),
                    ] else if (rel.isRequested) ...[
                      const Icon(Icons.schedule_rounded, color: Color(0xFFFFD700), size: 16),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      rel.isFollowingOrMutual
                          ? 'Following'
                          : (rel.isRequested ? 'Requested' : 'Follow'),
                      style: TextStyle(
                        color: rel.isRequested ? const Color(0xFFFFD700) : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Direct Message button
        GestureDetector(
          onTap: () {
            ProfileMessageButton.openChat(
              context,
              ref,
              userId: streamerId,
              userName: widget.userName,
              userAvatar: widget.avatarAsset ?? '',
              userUsername: widget.handle ?? '',
            );
          },
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1B1E2E),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
                width: 1.2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.chat_bubble_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    final tabs = ['Videos', 'Live', 'Liked'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(tabs.length, (index) {
        final isSelected = _selectedTab == index;
        return GestureDetector(
          onTap: () => setState(() => _selectedTab = index),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tabs[index],
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white54,
                  fontSize: 15,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 2.5,
                width: 32,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF00E5FF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildVideosGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.76,
      ),
      itemCount: _videoPosts.length,
      itemBuilder: (context, index) {
        final item = _videoPosts[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                item['image']!,
                fit: BoxFit.cover,
              ),
              // Dark gradient shadow at bottom
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.75),
                      ],
                      stops: const [0.55, 1.0],
                    ),
                  ),
                ),
              ),
              // View count with Play icon (e.g. ▶ 125K)
              Positioned(
                left: 6,
                bottom: 6,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      item['views']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
