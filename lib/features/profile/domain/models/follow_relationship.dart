import 'package:flutter/foundation.dart';

/// Status of the follow relationship resembling Instagram.
enum FollowStatus {
  /// Not following the user. Displays "Follow".
  notFollowing,

  /// Follow request has been sent and is awaiting acceptance. Displays "Requested".
  requested,

  /// Currently following the user. Displays "Following".
  following,

  /// Both users follow each other. Displays "Following" with a "Mutual" badge.
  mutual,

  /// User is blocked. Displays "Unblock".
  blocked,
}

/// Represents the persistent relationship state between current user and a target profile.
@immutable
class FollowRelationship {
  final String userId;
  final String userName;
  final String userAvatar;
  final FollowStatus status;
  final bool theyFollowMe;
  final int followerCount;
  final bool isCloseFriend;
  final bool isMuted;
  final DateTime? requestedAt;
  final DateTime? followedAt;

  const FollowRelationship({
    required this.userId,
    this.userName = '',
    this.userAvatar = '',
    this.status = FollowStatus.notFollowing,
    this.theyFollowMe = true,
    this.followerCount = 120400,
    this.isCloseFriend = false,
    this.isMuted = false,
    this.requestedAt,
    this.followedAt,
  });

  /// True if current user is actively following (either one-way or mutual).
  bool get isFollowingOrMutual =>
      status == FollowStatus.following || status == FollowStatus.mutual;

  /// True if a follow request is pending.
  bool get isRequested => status == FollowStatus.requested;

  /// True if current user has blocked the target.
  bool get isBlocked => status == FollowStatus.blocked;

  /// True if neither following nor requested.
  bool get isNotFollowing => status == FollowStatus.notFollowing;

  /// True if both follow each other.
  bool get isMutual => status == FollowStatus.mutual;

  /// Formatted follower count (e.g., "120,400").
  String get formattedFollowers {
    return followerCount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  FollowRelationship copyWith({
    String? userId,
    String? userName,
    String? userAvatar,
    FollowStatus? status,
    bool? theyFollowMe,
    int? followerCount,
    bool? isCloseFriend,
    bool? isMuted,
    DateTime? requestedAt,
    DateTime? followedAt,
  }) {
    return FollowRelationship(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      status: status ?? this.status,
      theyFollowMe: theyFollowMe ?? this.theyFollowMe,
      followerCount: followerCount ?? this.followerCount,
      isCloseFriend: isCloseFriend ?? this.isCloseFriend,
      isMuted: isMuted ?? this.isMuted,
      requestedAt: requestedAt ?? this.requestedAt,
      followedAt: followedAt ?? this.followedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FollowRelationship &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          status == other.status &&
          theyFollowMe == other.theyFollowMe &&
          followerCount == other.followerCount &&
          isCloseFriend == other.isCloseFriend &&
          isMuted == other.isMuted;

  @override
  int get hashCode => Object.hash(
        userId,
        status,
        theyFollowMe,
        followerCount,
        isCloseFriend,
        isMuted,
      );
}
