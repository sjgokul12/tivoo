import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/reel_video_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../domain/models/explore_stream_model.dart';
import '../../domain/models/video_post.dart';
import '../controllers/explore_controller.dart';
import '../controllers/posts_controller.dart';
import '../widgets/explore_header.dart';
import '../widgets/explore_reel_card.dart';

ExploreStreamModel _postToExploreModel(VideoPost post) {
  final avatarIsAsset = post.authorAvatar.startsWith('assets/');
  return ExploreStreamModel(
    id: post.id,
    streamerName: post.authorName,
    category: 'Video',
    subCategory: post.caption.isNotEmpty ? post.caption : '@${post.authorUsername}',
    avatarAssetPath: avatarIsAsset ? post.authorAvatar : null,
    avatarUrl: avatarIsAsset || post.authorAvatar.isEmpty ? null : post.authorAvatar,
    coverImageUrl: post.thumbnailUrl,
    videoAssetPath: post.videoUrl,
    viewersCount: post.formattedViews,
    diamondsCount: '${post.likes}',
    isLive: false,
    isVerified: false,
    post: post,
  );
}

/// Explore tab: full-screen vertical video feed (uploaded videos first, then demo videos).
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onPageSettled(0));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Uploaded posts first (newest first), then the demo videos; both follow the search.
  List<ExploreStreamModel> _feed() {
    final query = ref.read(exploreSearchProvider).trim().toLowerCase();
    final posts = ref
        .read(postsControllerProvider)
        .posts
        .where(
          (p) =>
              query.isEmpty ||
              p.caption.toLowerCase().contains(query) ||
              p.authorName.toLowerCase().contains(query) ||
              p.authorUsername.toLowerCase().contains(query),
        );
    return [...posts.map(_postToExploreModel), ...ref.read(exploreStreamsProvider)];
  }

  /// Plays the visible video and warms up its neighbours for instant swiping.
  void _onPageSettled(int index) {
    if (!mounted) return;
    final feed = _feed();
    if (index >= feed.length) return;
    final manager = ReelVideoManager.instance;
    manager.play(feed[index].videoAssetPath!);
    for (final i in [index + 1, index - 1]) {
      if (i >= 0 && i < feed.length) manager.prewarm(feed[i].videoAssetPath!);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Resume playback when coming back to the Explore tab.
    ref.listen<int>(bottomNavIndexProvider, (prev, next) {
      if (next == 0 && prev != 0) _onPageSettled(_currentIndex);
    });
    // A new upload lands at the top of the feed: restart playback on the visible page.
    ref.listen<PostsState>(postsControllerProvider, (prev, next) {
      if (prev?.posts.length != next.posts.length && ref.read(bottomNavIndexProvider) == 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _onPageSettled(_currentIndex));
      }
    });
    ref.watch(postsControllerProvider);
    ref.watch(exploreStreamsProvider);
    final feed = _feed();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: feed.isEmpty
                ? _EmptyState(onClear: () => ref.read(exploreSearchProvider.notifier).state = '')
                : PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    itemCount: feed.length,
                    onPageChanged: (i) {
                      setState(() => _currentIndex = i);
                      _onPageSettled(i);
                    },
                    itemBuilder: (context, i) => Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: context.isTablet ? 480 : double.infinity),
                        child: ExploreReelCard(key: ValueKey(feed[i].id), stream: feed[i], isActive: i == _currentIndex),
                      ),
                    ),
                  ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: ExploreHeader(
                onBackTap: Navigator.of(context).canPop() ? () => Navigator.of(context).pop() : null,
                onSearchTap: _showSearch,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearch() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xF5161622),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
        child: TextFormField(
          autofocus: true,
          initialValue: ref.read(exploreSearchProvider),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search creators or topics…',
            hintStyle: const TextStyle(color: Colors.white54),
            prefixIcon: const Icon(Icons.search, color: Colors.white70),
            filled: true,
            fillColor: const Color(0x66181824),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
          ),
          onChanged: (v) => ref.read(exploreSearchProvider.notifier).state = v,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onClear;
  const _EmptyState({required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.videocam_off_outlined, color: Colors.white54, size: 48),
          const SizedBox(height: 16),
          const Text(
            'No videos found',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryYellow, size: 18),
            label: const Text('Clear search', style: TextStyle(color: AppColors.primaryYellow)),
          ),
        ],
      ),
    );
  }
}
