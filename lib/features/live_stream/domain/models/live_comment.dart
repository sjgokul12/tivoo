enum LiveCommentType {
  chat,
  like,
  star,
  gift,
}

class LiveComment {
  final String id;
  final String userName;
  final String? userAvatarUrl;
  final String? userAssetPath;
  final String message;
  final DateTime timestamp;
  final LiveCommentType type;
  final int? starsCount;
  final bool isReported;

  const LiveComment({
    required this.id,
    required this.userName,
    this.userAvatarUrl,
    this.userAssetPath,
    required this.message,
    required this.timestamp,
    this.type = LiveCommentType.chat,
    this.starsCount,
    this.isReported = false,
  });

  LiveComment copyWith({
    String? id,
    String? userName,
    String? userAvatarUrl,
    String? userAssetPath,
    String? message,
    DateTime? timestamp,
    LiveCommentType? type,
    int? starsCount,
    bool? isReported,
  }) {
    return LiveComment(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      userAssetPath: userAssetPath ?? this.userAssetPath,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      starsCount: starsCount ?? this.starsCount,
      isReported: isReported ?? this.isReported,
    );
  }
}
