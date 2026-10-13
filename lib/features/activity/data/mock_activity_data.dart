import '../../../../core/constants/app_assets.dart';
import '../domain/models/activity_item_model.dart';

class MockActivityData {
  MockActivityData._();

  static const List<String> categories = [
    'All',
    'Live',
    'Following',
    'Likes',
    'Mentions',
  ];

  static const List<ActivityItemModel> activities = [
    ActivityItemModel(
      id: 'act_family_1',
      type: ActivityType.familyJoinRequest,
      userName: 'Jayachandran Jaya',
      userAvatarAsset: AppAssets.status5,
      title: 'requested to join Family',
      subtitle: 'Tiki ID: 10341053 • Gray Tiki 500+ views',
      subSubtitle: 'Team: RS TECH • Needs Leader Approval',
      timeAgo: 'Just now',
      category: 'All',
      requestId: 'req_1',
      applicantId: '10341053',
      familyName: 'RS TECH',
    ),
    ActivityItemModel(
      id: 'act_1',
      type: ActivityType.liveNow,
      userName: 'Khalid',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&auto=format&fit=crop&q=80',
      title: 'is live now!',
      subtitle: 'Gaming Live',
      subSubtitle: 'Playing Call of Duty',
      timeAgo: 'Now',
      previewImageUrl:
          'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=500&auto=format&fit=crop&q=80',
      viewersCount: '12.5K',
      isLive: true,
      category: 'Live',
    ),
    ActivityItemModel(
      id: 'act_2',
      type: ActivityType.like,
      userName: 'Maya Singh',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80',
      title: 'liked',
      subtitle: "Leo Beat's live stream",
      timeAgo: '2m ago',
      previewImageUrl:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=500&auto=format&fit=crop&q=80',
      viewersCount: '6.2K',
      category: 'Likes',
    ),
    ActivityItemModel(
      id: 'act_3',
      type: ActivityType.follow,
      userName: 'Aiko Tanaka',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=200&auto=format&fit=crop&q=80',
      title: 'started following you',
      timeAgo: '5m ago',
      isFollowing: false,
      category: 'Following',
    ),
    ActivityItemModel(
      id: 'act_4',
      type: ActivityType.topGifter,
      userName: 'Top Gifter This Week',
      title: "You're in the top 10 gifters!",
      timeAgo: 'This Week',
      category: 'All',
    ),
    ActivityItemModel(
      id: 'act_5',
      type: ActivityType.milestone,
      userName: 'Leo Beat',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=200&auto=format&fit=crop&q=80',
      title: 'received',
      subtitle: '1000 likes on his live',
      timeAgo: '10m ago',
      previewImageUrl:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=500&auto=format&fit=crop&q=80',
      likesCount: '1K',
      category: 'Likes',
    ),
    ActivityItemModel(
      id: 'act_6',
      type: ActivityType.gift,
      userName: 'Lena Rivers',
      userAvatarAsset: AppAssets.liveCard1,
      title: 'sent you',
      subtitle: 'a special gift 🎁',
      timeAgo: '15m ago',
      giftMultiplier: 'x1',
      category: 'All',
    ),
    ActivityItemModel(
      id: 'act_7',
      type: ActivityType.wentLive,
      userName: 'Riya Sharma',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&auto=format&fit=crop&q=80',
      title: 'went live',
      timeAgo: '20m ago',
      previewImageUrl:
          'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=500&auto=format&fit=crop&q=80',
      viewersCount: '9.8K',
      isLive: true,
      category: 'Live',
    ),
  ];
}
