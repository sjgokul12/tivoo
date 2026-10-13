class ExploreStreamModel {
  final String id;
  final String streamerName;
  final String category;
  final String subCategory;
  final String? avatarUrl;
  final String? avatarAssetPath;
  final String? coverImageUrl;
  final String? coverAssetPath;
  final String viewersCount;
  final String diamondsCount;
  final bool isLive;
  final bool isVerified;
  final String? videoAssetPath;
  final bool isLiked;

  const ExploreStreamModel({
    required this.id,
    required this.streamerName,
    required this.category,
    required this.subCategory,
    this.avatarUrl,
    this.avatarAssetPath,
    this.coverImageUrl,
    this.coverAssetPath,
    this.videoAssetPath,
    required this.viewersCount,
    this.diamondsCount = '10.5K',
    this.isLive = true,
    this.isVerified = true,
    this.isLiked = false,
  });

  ExploreStreamModel copyWith({
    String? id,
    String? streamerName,
    String? category,
    String? subCategory,
    String? avatarUrl,
    String? avatarAssetPath,
    String? coverImageUrl,
    String? coverAssetPath,
    String? videoAssetPath,
    String? viewersCount,
    String? diamondsCount,
    bool? isLive,
    bool? isVerified,
    bool? isLiked,
  }) {
    return ExploreStreamModel(
      id: id ?? this.id,
      streamerName: streamerName ?? this.streamerName,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarAssetPath: avatarAssetPath ?? this.avatarAssetPath,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      coverAssetPath: coverAssetPath ?? this.coverAssetPath,
      videoAssetPath: videoAssetPath ?? this.videoAssetPath,
      viewersCount: viewersCount ?? this.viewersCount,
      diamondsCount: diamondsCount ?? this.diamondsCount,
      isLive: isLive ?? this.isLive,
      isVerified: isVerified ?? this.isVerified,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
