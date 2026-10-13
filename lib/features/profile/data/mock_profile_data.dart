import '../domain/models/user_profile_model.dart';

class MockProfileData {
  MockProfileData._();

  static final List<ProfileMediaPost> initialPosts = [
    ProfileMediaPost(
      id: 'post_1',
      type: ProfileMediaType.video,
      title: 'Studio Mic Live Chill Session',
      mediaUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600&auto=format&fit=crop&q=85',
      duration: '12:45',
      viewsCount: '2.5K',
      likesCount: '1.2K',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    ProfileMediaPost(
      id: 'post_2',
      type: ProfileMediaType.video,
      title: 'Purple Neon Vibes & Chat',
      mediaUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=600&auto=format&fit=crop&q=85',
      duration: '08:30',
      viewsCount: '1.8K',
      likesCount: '976',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ProfileMediaPost(
      id: 'post_3',
      type: ProfileMediaType.video,
      title: 'Warm Golden Hour Acoustic Stream',
      mediaUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=600&auto=format&fit=crop&q=85',
      duration: '15:20',
      viewsCount: '3.7K',
      likesCount: '2.1K',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ProfileMediaPost(
      id: 'post_4',
      type: ProfileMediaType.video,
      title: 'City Night Lights Walk',
      mediaUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=600&auto=format&fit=crop&q=85',
      duration: '06:15',
      viewsCount: '1.4K',
      likesCount: '890',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    ProfileMediaPost(
      id: 'post_5',
      type: ProfileMediaType.video,
      title: 'Cyberpunk Gaming Setup Tour',
      mediaUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=600&auto=format&fit=crop&q=85',
      duration: '11:40',
      viewsCount: '3.1K',
      likesCount: '1.6K',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    ProfileMediaPost(
      id: 'post_6',
      type: ProfileMediaType.video,
      title: 'Sunset Beach Talk & QnA',
      mediaUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=600&auto=format&fit=crop&q=85',
      duration: '20:05',
      viewsCount: '4.5K',
      likesCount: '2.9K',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),

    // Images for the Images Tab
    ProfileMediaPost(
      id: 'img_1',
      type: ProfileMediaType.image,
      title: 'Studio Lighting Setup',
      mediaUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=600&auto=format&fit=crop&q=85',
      viewsCount: '3.8K',
      likesCount: '2.2K',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    ProfileMediaPost(
      id: 'img_2',
      type: ProfileMediaType.image,
      title: 'Streaming Space',
      mediaUrl: 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=600&auto=format&fit=crop&q=85',
      viewsCount: '2.1K',
      likesCount: '1.4K',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ProfileMediaPost(
      id: 'img_3',
      type: ProfileMediaType.image,
      title: 'Headphones & Mood',
      mediaUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=600&auto=format&fit=crop&q=85',
      viewsCount: '4.2K',
      likesCount: '3.1K',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  static final UserProfileModel defaultProfile = UserProfileModel(
    id: 'user_rohit',
    name: 'Rohit Rajdhani',
    username: 'Rohit_Rajdhani66',
    bio: 'OFFICIAL HOST BANNE KE LIYE MASSAGE KARE 80848 06861 LIVE AANE KA TIME 9PM 👑',
    aboutMe:
        "Rohit Rajdhani • Official Host on Tivoo\nConnect for official hosting and live broadcast partnerships.\nLive every night at 9 PM! 👑",
    avatarUrl: 'assets/status5.jpg',
    coverBackgroundUrl: 'assets/status1.jpg',
    roles: const ['Official Host', 'VIP Streamer'],
    isVerified: true,
    isOnline: true,
    liveStreamsCount: 411,
    followersCount: '4.7K',
    followingCount: 300,
    likesCount: '53.1K',
    totalViews: '39.6K',
    posts: initialPosts,
  );
}
