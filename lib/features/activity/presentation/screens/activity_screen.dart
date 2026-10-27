import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/responsive.dart';
import '../../../home/domain/models/live_stream_card_model.dart';
import '../../../live_stream/presentation/screens/live_stream_screen.dart';
import '../../domain/models/activity_item_model.dart';
import '../controllers/activity_controller.dart';
import '../widgets/activity_card.dart';
import '../widgets/activity_header.dart';

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

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // 2. Activity Items List
            Builder(
              builder: (context) {
                final activities = state.allActivities
                    .where((i) => i.type != ActivityType.topGifter)
                    .toList();

                return SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.isTablet
                        ? ((context.screenWidth - 600) / 2).clamp(16.0, 200.0)
                        : 16.0,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = activities[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ActivityCard(
                            activity: item,
                            onFollowBackTap: () {
                              controller.toggleFollow(item.id);
                            },
                            onTap: () {
                              if (item.isLive) {
                                final liveItems = activities
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
                      childCount: activities.length,
                    ),
                  ),
                );
              },
            ),

            // Bottom space for floating bottom nav bar
            SliverToBoxAdapter(
              child: SizedBox(height: 100 + MediaQuery.paddingOf(context).bottom),
            ),
          ],
        ),
      ),
    );
  }
}
