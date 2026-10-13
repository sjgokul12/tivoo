import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/reel_video_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../home/domain/models/live_stream_card_model.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../live_stream/presentation/screens/live_stream_screen.dart';
import '../../domain/models/explore_stream_model.dart';
import '../controllers/explore_controller.dart';
import '../widgets/explore_header.dart';
import '../widgets/explore_reel_card.dart';
import '../widgets/explore_stream_card.dart';

LiveStreamCardModel _toLiveStreamCardModel(ExploreStreamModel stream) {
  return LiveStreamCardModel(
    id: stream.id,
    streamerName: stream.streamerName,
    streamerBio: stream.subCategory,
    coverAssetPath: stream.coverAssetPath,
    coverImageUrl: stream.coverImageUrl,
    streamerAssetPath: stream.avatarAssetPath,
    streamerAvatarUrl: stream.avatarUrl,
    videoAssetPath: stream.videoAssetPath,
    viewersCount: stream.viewersCount,
    diamondsCount: stream.diamondsCount,
    isLive: stream.isLive,
    isVerified: stream.isVerified,
  );
}

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // Immediately trigger playback and prewarm on frame 0
    final streams = ref.read(exploreControllerProvider).filteredStreams;
    if (streams.isNotEmpty && streams[0].videoAssetPath != null) {
      ReelVideoManager.instance.play(streams[0].videoAssetPath!);
      if (streams.length > 1 && streams[1].videoAssetPath != null) {
        ReelVideoManager.instance.prewarm(streams[1].videoAssetPath!);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onPageSettled(0);
    });
  }

  void _onPageSettled(int index) {
    if (!mounted) return;
    final streams = ref.read(exploreControllerProvider).filteredStreams;
    if (streams.isEmpty || index >= streams.length) return;

    final currentStream = streams[index];
    if (currentStream.videoAssetPath != null) {
      ReelVideoManager.instance.play(currentStream.videoAssetPath!);
    }

    // Pre-warm the NEXT explore reel (+1) to Frame 0
    if (index + 1 < streams.length) {
      final nextStream = streams[index + 1];
      if (nextStream.videoAssetPath != null) {
        ReelVideoManager.instance.prewarm(nextStream.videoAssetPath!);
      }
    }

    // Pre-warm the PREVIOUS explore reel (-1) for instant backward scrolling
    if (index - 1 >= 0) {
      final prevStream = streams[index - 1];
      if (prevStream.videoAssetPath != null) {
        ReelVideoManager.instance.prewarm(prevStream.videoAssetPath!);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Back arrow: pop if Explore was pushed, otherwise switch to the Home tab.
  void _goHome() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      ref.read(bottomNavIndexProvider.notifier).state = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exploreControllerProvider);
    final controller = ref.read(exploreControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: state.isReelsView
          ? _buildReelsFeedView(context, ref, state, controller)
          : _buildGridView(context, ref, state, controller),
    );
  }

  /// Instagram Reels-Style Vertical Snap-Scroll Feed
  Widget _buildReelsFeedView(BuildContext context, WidgetRef ref, ExploreState state, ExploreController controller) {
    final filtered = state.filteredStreams;

    return Stack(
      children: [
        // 1. Vertical Snap-Scrolling PageView (Reels Feed)
        if (filtered.isNotEmpty)
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              physics: const PageScrollPhysics(),
              onPageChanged: (newIndex) {
                if (_currentIndex != newIndex) {
                  setState(() {
                    _currentIndex = newIndex;
                  });
                  _onPageSettled(newIndex);
                }
              },
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final stream = filtered[index];
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: context.isTablet ? 480 : double.infinity),
                    child: ExploreReelCard(
                      key: ValueKey(stream.id),
                      stream: stream,
                      isActive: index == _currentIndex,
                      onEnterLiveRoom: () {
                        _openLiveRoom(context, filtered, index);
                      },
                      onLikeTap: () {
                        controller.toggleLike(stream.id);
                      },
                      onCommentTap: () {
                        _openLiveRoom(context, filtered, index);
                      },
                    ),
                  ),
                );
              },
            ),
          )
        else
          Positioned.fill(child: _buildEmptyState(context, controller)),

        // 2. Floating Top Header & Category Tabs (Overlayed with gradient scrim)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xD9000000), Color(0x99000000), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.0, 0.65, 1.0],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ExploreHeader(
                  isReelsView: true,
                  onViewModeToggle: controller.toggleViewMode,
                  onBackTap: _goHome,
                  onSearchTap: () => _showSearchDialog(context, ref),
                  onFilterTap: () => _showFilterInfo(context),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Classic 2-Column Responsive Grid View
  Widget _buildGridView(BuildContext context, WidgetRef ref, ExploreState state, ExploreController controller) {
    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Top Header
          SliverToBoxAdapter(
            child: ExploreHeader(
              isReelsView: false,
              onViewModeToggle: controller.toggleViewMode,
              onBackTap: _goHome,
              onSearchTap: () => _showSearchDialog(context, ref),
              onFilterTap: () => _showFilterInfo(context),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // 3. Responsive Live Streams Grid
          if (state.filteredStreams.isNotEmpty)
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: context.isTablet ? ((context.screenWidth - 800) / 2).clamp(16.0, 200.0) : 16.0,
              ),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: context.isTablet ? 3 : 2,
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 14,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final stream = state.filteredStreams[index];
                  return ExploreStreamCard(
                    stream: stream,
                    onCardTap: () {
                      _openLiveRoom(context, state.filteredStreams, index);
                    },
                    onLikeTap: () {
                      controller.toggleLike(stream.id);
                    },
                  );
                }, childCount: state.filteredStreams.length),
              ),
            )
          else
            SliverToBoxAdapter(
              child: Padding(padding: const EdgeInsets.only(top: 80), child: _buildEmptyState(context, controller)),
            ),

          // Bottom space for floating bottom navigation bar
          const SliverToBoxAdapter(child: SizedBox(height: 96)),
        ],
      ),
    );
  }

  void _openLiveRoom(BuildContext context, List<ExploreStreamModel> streams, int initialIndex) {
    final liveStreams = streams.map(_toLiveStreamCardModel).toList();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LiveStreamScreen(streams: liveStreams, initialIndex: initialIndex),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ExploreController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Icon(Icons.videocam_off_outlined, color: Colors.white54, size: 42),
            ),
            const SizedBox(height: 18),
            const Text(
              'No live streams found',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            const Text(
              'Try clearing your search query',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {
                controller.setSearchQuery('');
              },
              icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryYellow, size: 18),
              label: const Text(
                'Show All Streams',
                style: TextStyle(color: AppColors.primaryYellow, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterInfo(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filter live rooms by region, tags & viewers'), duration: Duration(seconds: 1)),
    );
  }

  void _showSearchDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xF5161622),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.viewInsetsOf(context).bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search live streamer or topic...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0x66181824),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                ),
                onChanged: (val) {
                  ref.read(exploreControllerProvider.notifier).setSearchQuery(val);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
