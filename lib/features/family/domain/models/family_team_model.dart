class FamilyMemberModel {
  final String id;
  final String name;
  final String avatar;
  final String role; // 'Leader' | 'Elder' | 'Member'
  final String joinedDate;
  final int contributionStars;
  final String tikiId;

  const FamilyMemberModel({
    required this.id,
    required this.name,
    required this.avatar,
    required this.role,
    required this.joinedDate,
    this.contributionStars = 0,
    required this.tikiId,
  });
}

class FamilyJoinRequestModel {
  final String id;
  final String userId;
  final String userName;
  final String userAvatar;
  final String userTikiId;
  final DateTime requestedAt;
  final bool isAccepted;
  final bool isDeclined;

  const FamilyJoinRequestModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.userTikiId,
    required this.requestedAt,
    this.isAccepted = false,
    this.isDeclined = false,
  });

  FamilyJoinRequestModel copyWith({
    bool? isAccepted,
    bool? isDeclined,
  }) {
    return FamilyJoinRequestModel(
      id: id,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      userTikiId: userTikiId,
      requestedAt: requestedAt,
      isAccepted: isAccepted ?? this.isAccepted,
      isDeclined: isDeclined ?? this.isDeclined,
    );
  }
}

class FamilyTeamModel {
  final String id;
  final String name;
  final String leaderId;
  final String leaderName;
  final String leaderAvatar;
  final String slogan;
  final int totalPower;
  final int diamonds;
  final int memberCount;
  final List<FamilyMemberModel> members;
  final List<FamilyJoinRequestModel> pendingRequests;
  final String badgeIcon;

  const FamilyTeamModel({
    required this.id,
    required this.name,
    required this.leaderId,
    required this.leaderName,
    required this.leaderAvatar,
    required this.slogan,
    this.totalPower = 185000,
    this.diamonds = 92000,
    required this.memberCount,
    required this.members,
    this.pendingRequests = const [],
    this.badgeIcon = '🛡️',
  });

  FamilyTeamModel copyWith({
    String? name,
    String? slogan,
    int? totalPower,
    int? diamonds,
    int? memberCount,
    List<FamilyMemberModel>? members,
    List<FamilyJoinRequestModel>? pendingRequests,
    String? badgeIcon,
  }) {
    return FamilyTeamModel(
      id: id,
      name: name ?? this.name,
      leaderId: leaderId,
      leaderName: leaderName,
      leaderAvatar: leaderAvatar,
      slogan: slogan ?? this.slogan,
      totalPower: totalPower ?? this.totalPower,
      diamonds: diamonds ?? this.diamonds,
      memberCount: memberCount ?? this.memberCount,
      members: members ?? this.members,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      badgeIcon: badgeIcon ?? this.badgeIcon,
    );
  }
}
