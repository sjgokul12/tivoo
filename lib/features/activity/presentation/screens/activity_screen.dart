import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/neon_tab_bar.dart';
import '../../../home/domain/models/live_stream_card_model.dart';
import '../../../live_stream/presentation/screens/live_stream_screen.dart';
import '../../domain/models/activity_item_model.dart';
import '../controllers/activity_controller.dart';
import '../widgets/activity_card.dart';
import '../widgets/activity_header.dart';
import '../widgets/top_gifter_banner.dart';

LiveStreamCardModel _toLiveStreamCardModel(ActivityItemModel item) {
  return LiveStreamCardModel(
    id: item.id,
    streamerName: item.userName,
    streamerBio: item.subtitle ?? 'Live Room',
    streamerAvatarUrl: item.userAvatarUrl,
    streamerAssetPath: item.userAvatarAsset,
    coverImageUrl: item.previewImageUrl,
    coverAssetPath: item.previewAssetPath,
    viewersCount: item.viewersCount ?? '10.5K',
    diamondsCount: '18.2K',
    isLive: true,
  );
}

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activityControllerProvider);
    final controller = ref.read(activityControllerProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Top Header: Title, Subtitle, Notification Bell
            SliverToBoxAdapter(
              child: ActivityHeader(
                onNotificationTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notifications are all caught up!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // 2. Category Filter Tabs: "All", "Live", "Following", "Likes", "Mentions"
            SliverToBoxAdapter(
              child: NeonTabBar(
                categories: state.categories,
                selectedIndex: state.selectedCategoryIndex,
                onCategorySelected: controller.selectCategory,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // 3. Activity Items List (centered/capped width on tablets)
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: context.isTablet
                    ? ((context.screenWidth - 600) / 2).clamp(16.0, 200.0)
                    : 16.0,
              ),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = state.filteredActivities[index];

                    if (item.type == ActivityType.topGifter) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: TopGifterBanner(
                          onViewRankTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Weekly Gifter Leaderboard #8 Rank'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ActivityCard(
                        activity: item,
                        onFollowBackTap: () {
                          controller.toggleFollow(item.id);
                        },
                        onTap: () {
                          if (item.isLive) {
                            final liveItems = state.filteredActivities
                                .where((i) => i.isLive)
                                .toList();
                            final liveIndex = liveItems.indexOf(item);
                            final streams = liveItems
                                .map(_toLiveStreamCardModel)
                                .toList();

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => LiveStreamScreen(
                                  streams: streams,
                                  initialIndex: liveIndex,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                  childCount: state.filteredActivities.length,
                ),
              ),
            ),

            // Bottom space for floating bottom nav bar
            const SliverToBoxAdapter(child: SizedBox(height: 96)),
          ],
        ),
      ),
    );
  }
}
