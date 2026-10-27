import '../../../../core/constants/app_assets.dart';
import '../domain/models/explore_stream_model.dart';

/// Demo Explore feed: one creator per video in assets/videos/.
class MockExploreData {
  MockExploreData._();

  static const List<ExploreStreamModel> exploreStreams = [
    ExploreStreamModel(
      id: 'exp_1',
      streamerName: 'Lena Rivers',
      category: 'Music',
      subCategory: 'Music & Chill 🎶',
      avatarAssetPath: AppAssets.status3,
      videoAssetPath: AppAssets.video1,
      viewersCount: '12.5K',
      diamondsCount: '24.2K',
    ),
    ExploreStreamModel(
      id: 'exp_2',
      streamerName: 'Maya Singh',
      category: 'Lifestyle',
      subCategory: 'Weekend vibes ✨',
      avatarAssetPath: AppAssets.status4,
      videoAssetPath: AppAssets.video2,
      viewersCount: '8.7K',
      diamondsCount: '18.4K',
    ),
    ExploreStreamModel(
      id: 'exp_3',
      streamerName: 'Khalid',
      category: 'Travel',
      subCategory: 'Chasing sunsets 🌅',
      avatarAssetPath: AppAssets.status2,
      videoAssetPath: AppAssets.video3,
      viewersCount: '15.3K',
      diamondsCount: '32.1K',
    ),
    ExploreStreamModel(
      id: 'exp_4',
      streamerName: 'Leo Beat',
      category: 'Music',
      subCategory: 'Feel the beat 🔥',
      avatarAssetPath: AppAssets.status5,
      videoAssetPath: AppAssets.video4,
      viewersCount: '6.2K',
      diamondsCount: '9.8K',
    ),
    ExploreStreamModel(
      id: 'exp_5',
      streamerName: 'Aiko Tanaka',
      category: 'Art',
      subCategory: 'Art & Creative 🎨',
      avatarAssetPath: AppAssets.status1,
      videoAssetPath: AppAssets.video5,
      viewersCount: '5.1K',
      diamondsCount: '7.4K',
    ),
    ExploreStreamModel(
      id: 'exp_6',
      streamerName: 'Neha',
      category: 'Daily',
      subCategory: 'Little moments 💛',
      avatarAssetPath: AppAssets.avatarNeha,
      videoAssetPath: AppAssets.video6,
      viewersCount: '9.9K',
      diamondsCount: '11.6K',
    ),
  ];
}
