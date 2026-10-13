class StreamerStory {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? assetPath;
  final bool isUser;
  final bool hasUnseenStory;
  final bool isLive;

  const StreamerStory({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.assetPath,
    this.isUser = false,
    this.hasUnseenStory = true,
    this.isLive = false,
  });
}
