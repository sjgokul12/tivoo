/// A comment on an Explore video.
class PostComment {
  final String id;
  final String authorName;

  /// Asset path, file path or URL.
  final String authorAvatar;
  final String text;
  final DateTime createdAt;
  final int likes;
  final bool isLiked;
  final bool isMine;

  const PostComment({
    required this.id,
    required this.authorName,
    required this.authorAvatar,
    required this.text,
    required this.createdAt,
    this.likes = 0,
    this.isLiked = false,
    this.isMine = false,
  });

  PostComment copyWith({int? likes, bool? isLiked}) => PostComment(
    id: id,
    authorName: authorName,
    authorAvatar: authorAvatar,
    text: text,
    createdAt: createdAt,
    likes: likes ?? this.likes,
    isLiked: isLiked ?? this.isLiked,
    isMine: isMine,
  );

  /// Instagram-style age: "now", "5m", "3h", "2d", "4w".
  String get age {
    final d = DateTime.now().difference(createdAt);
    if (d.inMinutes < 1) return 'now';
    if (d.inHours < 1) return '${d.inMinutes}m';
    if (d.inDays < 1) return '${d.inHours}h';
    if (d.inDays < 7) return '${d.inDays}d';
    return '${d.inDays ~/ 7}w';
  }
}
