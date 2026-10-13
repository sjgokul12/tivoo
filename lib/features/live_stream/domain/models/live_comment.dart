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

  const LiveComment({
    required this.id,
    required this.userName,
    this.userAvatarUrl,
    this.userAssetPath,
    required this.message,
    required this.timestamp,
    this.type = LiveCommentType.chat,
    this.starsCount,
  });
}

