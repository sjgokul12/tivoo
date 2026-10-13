enum ProfileMediaType { video, image }

class ProfileMediaPost {
  final String id;
  final ProfileMediaType type;
  final String title;
  final String mediaUrl;
  final String duration;
  final String viewsCount;
  final String likesCount;
  final DateTime createdAt;

  const ProfileMediaPost({
    required this.id,
    required this.type,
    required this.title,
    required this.mediaUrl,
    this.duration = '10:00',
    this.viewsCount = '1.2K',
    this.likesCount = '850',
    required this.createdAt,
  });

  ProfileMediaPost copyWith({
    String? id,
    ProfileMediaType? type,
    String? title,
    String? mediaUrl,
    String? duration,
    String? viewsCount,
    String? likesCount,
    DateTime? createdAt,
  }) {
    return ProfileMediaPost(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      duration: duration ?? this.duration,
      viewsCount: viewsCount ?? this.viewsCount,
      likesCount: likesCount ?? this.likesCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class UserProfileModel {
  final String id;
  final String name;
  final String username;
  final String bio;
  final String aboutMe;
  final String avatarUrl;
  final String coverBackgroundUrl;
  final String email;
  final String phoneNumber;
  final List<String> roles;
  final bool isVerified;
  final bool isOnline;
  final int followingCount;
  final String followersCount;
  final String likesCount;
  final int liveStreamsCount;
  final String totalViews;
  final List<ProfileMediaPost> posts;

  const UserProfileModel({
    required this.id,
    required this.name,
    required this.username,
    required this.bio,
    required this.aboutMe,
    required this.avatarUrl,
    required this.coverBackgroundUrl,
    this.email = 'jessica.parker@tivoo.live',
    this.phoneNumber = '+1 (555) 389-4920',
    this.roles = const ['Streamer', 'Content Creator'],
    this.isVerified = true,
    this.isOnline = true,
    required this.followingCount,
    required this.followersCount,
    required this.likesCount,
    required this.liveStreamsCount,
    required this.totalViews,
    required this.posts,
  });

  UserProfileModel copyWith({
    String? id,
    String? name,
    String? username,
    String? bio,
    String? aboutMe,
    String? avatarUrl,
    String? coverBackgroundUrl,
    String? email,
    String? phoneNumber,
    List<String>? roles,
    bool? isVerified,
    bool? isOnline,
    int? followingCount,
    String? followersCount,
    String? likesCount,
    int? liveStreamsCount,
    String? totalViews,
    List<ProfileMediaPost>? posts,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      aboutMe: aboutMe ?? this.aboutMe,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverBackgroundUrl: coverBackgroundUrl ?? this.coverBackgroundUrl,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      roles: roles ?? this.roles,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      followingCount: followingCount ?? this.followingCount,
      followersCount: followersCount ?? this.followersCount,
      likesCount: likesCount ?? this.likesCount,
      liveStreamsCount: liveStreamsCount ?? this.liveStreamsCount,
      totalViews: totalViews ?? this.totalViews,
      posts: posts ?? this.posts,
    );
  }
}
