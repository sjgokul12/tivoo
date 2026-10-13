class LiveStreamCardModel {
  final String id;
  final String? userId;
  final String streamerName;
  final String streamerBio;
  final String? streamerAvatarUrl;
  final String? streamerAssetPath;
  final String? coverImageUrl;
  final String? coverAssetPath;
  final String? videoAssetPath;
  final String? videoUrl;
  final bool isVerified;
  final String viewersCount;
  final String diamondsCount;
  final bool isLive;
  final bool isFollowing;
  final String category;
  final String? likesCount;
  final bool isPk;
  final int? heatScore;

  /// Interests shown on the home card (e.g. 'Music', 'Dance').
  final List<String> tags;

  /// Top-right card label: 'Top Host', 'Rising Star', 'Popular', 'New' or 'Trending'.
  final String? badge;

  const LiveStreamCardModel({
    required this.id,
    this.userId,
    required this.streamerName,
    required this.streamerBio,
    this.streamerAvatarUrl,
    this.streamerAssetPath,
    this.coverImageUrl,
    this.coverAssetPath,
    this.videoAssetPath,
    this.videoUrl,
    this.isVerified = true,
    required this.viewersCount,
    required this.diamondsCount,
    this.isLive = true,
    this.isFollowing = false,
    this.category = 'Popular',
    this.likesCount,
    this.isPk = false,
    this.heatScore,
    this.tags = const [],
    this.badge,
  });

  String get displayUserId {
    if (userId != null && userId!.isNotEmpty) return userId!;
    if (id.contains('1')) return 'UID-928410';
    if (id.contains('2')) return 'UID-338291';
    if (id.contains('3')) return 'UID-773190';
    if (id.contains('4')) return 'UID-512093';
    return 'UID-620184';
  }

  LiveStreamCardModel copyWith({
    String? id,
    String? userId,
    String? streamerName,
    String? streamerBio,
    String? streamerAvatarUrl,
    String? streamerAssetPath,
    String? coverImageUrl,
    String? coverAssetPath,
    String? videoAssetPath,
    String? videoUrl,
    bool? isVerified,
    String? viewersCount,
    String? diamondsCount,
    bool? isLive,
    bool? isFollowing,
    String? category,
    String? likesCount,
    bool? isPk,
    int? heatScore,
    List<String>? tags,
    String? badge,
  }) {
    return LiveStreamCardModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      streamerName: streamerName ?? this.streamerName,
      streamerBio: streamerBio ?? this.streamerBio,
      streamerAvatarUrl: streamerAvatarUrl ?? this.streamerAvatarUrl,
      streamerAssetPath: streamerAssetPath ?? this.streamerAssetPath,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      coverAssetPath: coverAssetPath ?? this.coverAssetPath,
      videoAssetPath: videoAssetPath ?? this.videoAssetPath,
      videoUrl: videoUrl ?? this.videoUrl,
      isVerified: isVerified ?? this.isVerified,
      viewersCount: viewersCount ?? this.viewersCount,
      diamondsCount: diamondsCount ?? this.diamondsCount,
      isLive: isLive ?? this.isLive,
      isFollowing: isFollowing ?? this.isFollowing,
      category: category ?? this.category,
      likesCount: likesCount ?? this.likesCount,
      isPk: isPk ?? this.isPk,
      heatScore: heatScore ?? this.heatScore,
      tags: tags ?? this.tags,
      badge: badge ?? this.badge,
    );
  }
}
