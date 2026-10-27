import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/follow_relationship.dart';
import 'profile_controller.dart';

/// Centralized frontend-only in-memory state manager for follow relationships
/// across all feed cards, user profiles, livestreams, and reels.
///
/// Implements the 3 frontend states:
/// - Follow ([FollowStatus.notFollowing])
/// - Requested ([FollowStatus.requested])
/// - Following ([FollowStatus.following] / [FollowStatus.mutual])
class FollowController extends StateNotifier<Map<String, FollowRelationship>> {
  final Ref? _ref;

  FollowController([this._ref]) : super({});

  /// Pure, non-mutating query for the relationship state of [userId].
  ///
  /// Safe to call inside [Widget.build] because it does NOT mutate state.
  FollowRelationship getRelationship(
    String userId, {
    String? defaultName,
    String? defaultAvatar,
    int? initialFollowers,
    bool? initialFollowing,
  }) {
    if (state.containsKey(userId)) {
      return state[userId]!;
    }

    final initialStatus = (initialFollowing == true)
        ? FollowStatus.following
        : FollowStatus.notFollowing;

    final baseCount = initialFollowers ?? 120400;

    return FollowRelationship(
      userId: userId,
      userName: defaultName ?? 'Creator',
      userAvatar: defaultAvatar ?? '',
      status: initialStatus,
      theyFollowMe: true,
      followerCount: initialStatus == FollowStatus.following ? baseCount + 1 : baseCount,
    );
  }

  /// Taps [Follow]: Transitions state directly to [FollowStatus.requested].
  /// Saves this state in the shared in-memory state manager by target user ID.
  void sendFollowRequest(
    String userId, {
    String? targetName,
    String? targetAvatar,
    int? initialFollowers,
    void Function(String message)? onStatusNotify,
  }) {
    final current = getRelationship(
      userId,
      defaultName: targetName,
      defaultAvatar: targetAvatar,
      initialFollowers: initialFollowers,
    );

    final updated = current.copyWith(
      status: FollowStatus.requested,
      requestedAt: DateTime.now(),
      userName: targetName ?? current.userName,
      userAvatar: targetAvatar ?? current.userAvatar,
    );

    state = {...state, userId: updated};
    onStatusNotify?.call('Requested to follow ${updated.userName} ⏳');
  }

  /// Taps [Requested]: Cancels the pending request and returns to [FollowStatus.notFollowing].
  void cancelFollowRequest(
    String userId, {
    void Function(String message)? onStatusNotify,
  }) {
    final current = state[userId] ?? getRelationship(userId);

    final updated = current.copyWith(
      status: FollowStatus.notFollowing,
      requestedAt: null,
    );

    state = {...state, userId: updated};
    onStatusNotify?.call('Follow request canceled');
  }

  /// Taps [Following]: Unfollows the target user and returns to [FollowStatus.notFollowing].
  void unfollow(
    String userId, {
    void Function(String message)? onStatusNotify,
  }) {
    final current = state[userId] ?? getRelationship(userId);
    final wasFollowing = current.isFollowingOrMutual;

    final updated = current.copyWith(
      status: FollowStatus.notFollowing,
      followerCount: (current.followerCount - 1).clamp(0, 9999999),
      followedAt: null,
      requestedAt: null,
    );

    state = {...state, userId: updated};

    if (wasFollowing && _ref != null) {
      _ref.read(profileControllerProvider.notifier).modifyFollowing(-1);
    }

    onStatusNotify?.call('Unfollowed ${current.userName}');
  }

  /// Optional simulation method: Allows client to preview [FollowStatus.following] in UI review.
  void acceptRequest(
    String userId, {
    void Function(String message)? onStatusNotify,
  }) {
    final current = state[userId] ?? getRelationship(userId);

    final updated = current.copyWith(
      status: FollowStatus.following,
      followedAt: DateTime.now(),
      followerCount: current.followerCount + 1,
    );

    state = {...state, userId: updated};

    if (_ref != null) {
      _ref.read(profileControllerProvider.notifier).modifyFollowing(1);
    }

    onStatusNotify?.call('Now following ${current.userName}!');
  }

  /// Blocks a user (optional safety feature).
  void blockUser(
    String userId, {
    void Function(String message)? onStatusNotify,
  }) {
    final current = state[userId] ?? getRelationship(userId);
    final wasFollowing = current.isFollowingOrMutual;

    final updated = current.copyWith(
      status: FollowStatus.blocked,
      followerCount: wasFollowing ? (current.followerCount - 1).clamp(0, 9999999) : current.followerCount,
    );

    state = {...state, userId: updated};

    if (wasFollowing && _ref != null) {
      _ref.read(profileControllerProvider.notifier).modifyFollowing(-1);
    }

    onStatusNotify?.call('Blocked ${updated.userName}');
  }

  /// Unblocks a user, returning them to notFollowing state.
  void unblockUser(
    String userId, {
    void Function(String message)? onStatusNotify,
  }) {
    final current = state[userId] ?? getRelationship(userId);

    final updated = current.copyWith(
      status: FollowStatus.notFollowing,
    );

    state = {...state, userId: updated};
    onStatusNotify?.call('Unblocked ${current.userName}');
  }

  /// Toggles close friends status.
  void toggleCloseFriend(String userId) {
    final current = state[userId] ?? getRelationship(userId);
    state = {
      ...state,
      userId: current.copyWith(isCloseFriend: !current.isCloseFriend),
    };
  }

  /// Toggles notifications / mute.
  void toggleMute(String userId) {
    final current = state[userId] ?? getRelationship(userId);
    state = {
      ...state,
      userId: current.copyWith(isMuted: !current.isMuted),
    };
  }
}

/// Shared provider for global in-memory follow relationships.
final followControllerProvider =
    StateNotifierProvider<FollowController, Map<String, FollowRelationship>>((ref) {
  return FollowController(ref);
});
