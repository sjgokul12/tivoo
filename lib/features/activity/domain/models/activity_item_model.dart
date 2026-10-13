enum ActivityType {
  liveNow,
  like,
  follow,
  topGifter,
  milestone,
  gift,
  wentLive,
  familyJoinRequest,
}

class ActivityItemModel {
  final String id;
  final ActivityType type;
  final String userName;
  final String? userAvatarUrl;
  final String? userAvatarAsset;
  final String title;
  final String? subtitle;
  final String? subSubtitle;
  final String timeAgo;
  final String? previewImageUrl;
  final String? previewAssetPath;
  final String? viewersCount;
  final String? likesCount;
  final String? giftMultiplier;
  final bool isLive;
  final bool isFollowing;
  final String category;
  final String? requestId;
  final String? applicantId;
  final String? familyName;

  const ActivityItemModel({
    required this.id,
    required this.type,
    required this.userName,
    this.userAvatarUrl,
    this.userAvatarAsset,
    required this.title,
    this.subtitle,
    this.subSubtitle,
    required this.timeAgo,
    this.previewImageUrl,
    this.previewAssetPath,
    this.viewersCount,
    this.likesCount,
    this.giftMultiplier,
    this.isLive = false,
    this.isFollowing = false,
    this.category = 'All',
    this.requestId,
    this.applicantId,
    this.familyName,
  });

  ActivityItemModel copyWith({
    String? id,
    ActivityType? type,
    String? userName,
    String? userAvatarUrl,
    String? userAvatarAsset,
    String? title,
    String? subtitle,
    String? subSubtitle,
    String? timeAgo,
    String? previewImageUrl,
    String? previewAssetPath,
    String? viewersCount,
    String? likesCount,
    String? giftMultiplier,
    bool? isLive,
    bool? isFollowing,
    String? category,
    String? requestId,
    String? applicantId,
    String? familyName,
  }) {
    return ActivityItemModel(
      id: id ?? this.id,
      type: type ?? this.type,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      userAvatarAsset: userAvatarAsset ?? this.userAvatarAsset,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      subSubtitle: subSubtitle ?? this.subSubtitle,
      timeAgo: timeAgo ?? this.timeAgo,
      previewImageUrl: previewImageUrl ?? this.previewImageUrl,
      previewAssetPath: previewAssetPath ?? this.previewAssetPath,
      viewersCount: viewersCount ?? this.viewersCount,
      likesCount: likesCount ?? this.likesCount,
      giftMultiplier: giftMultiplier ?? this.giftMultiplier,
      isLive: isLive ?? this.isLive,
      isFollowing: isFollowing ?? this.isFollowing,
      category: category ?? this.category,
      requestId: requestId ?? this.requestId,
      applicantId: applicantId ?? this.applicantId,
      familyName: familyName ?? this.familyName,
    );
  }
}
