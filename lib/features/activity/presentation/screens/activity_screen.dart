import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/luxury_atmosphere_background.dart';
import '../../../family/presentation/controllers/family_controller.dart';
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

String _formatTimeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activityControllerProvider);
    final controller = ref.read(activityControllerProvider.notifier);
    final familyState = ref.watch(familyControllerProvider);
    final family = familyState.currentFamily;
    final pendingRequests = family.pendingRequests;

    // Convert live family join requests into high-priority notifications
    final familyJoinItems = pendingRequests.map((req) {
      return ActivityItemModel(
        id: 'act_family_${req.id}',
        type: ActivityType.familyJoinRequest,
        userName: req.userName,
        userAvatarAsset: req.userAvatar,
        title: 'requested to join Family',
        subtitle: '${req.userTikiId} • Needs Leader Approval',
        subSubtitle: 'Team: ${family.name}',
        timeAgo: _formatTimeAgo(req.requestedAt),
        category: 'All',
        requestId: req.id,
        applicantId: req.userTikiId,
        familyName: family.name,
      );
    }).toList();

    // Filter other activities, removing any old static family requests
    final otherActivities = state.allActivities
        .where((i) => i.type != ActivityType.topGifter && i.type != ActivityType.familyJoinRequest)
        .toList();

    final allActivities = [...familyJoinItems, ...otherActivities];

    return Scaffold(
      backgroundColor: const Color(0xFF0C0B14),
      body: Stack(
        children: [
          const LuxuryAtmosphereBackground(),
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 1. Top Header: Title, Subtitle, Back button (when pushed)
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

                // 2. Activity / Notification Items List
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.isTablet
                        ? ((context.screenWidth - 600) / 2).clamp(16.0, 200.0)
                        : 16.0,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = allActivities[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ActivityCard(
                            activity: item,
                            onFollowBackTap: () {
                              controller.toggleFollow(item.id);
                            },
                            onTap: () {
                              if (item.isLive) {
                                final liveItems = allActivities
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
                      childCount: allActivities.length,
                    ),
                  ),
                ),

                // Bottom space for floating bottom nav bar or safe area
                SliverToBoxAdapter(
                  child: SizedBox(height: 100 + MediaQuery.paddingOf(context).bottom),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
