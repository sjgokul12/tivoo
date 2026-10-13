import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_live_comments.dart';
import '../../domain/models/gift_item.dart';
import '../../domain/models/live_comment.dart';

class LiveStreamState {
  final List<LiveComment> comments;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final bool isFollowing;
  final int poolIndex;

  const LiveStreamState({
    required this.comments,
    this.likesCount = 12500,
    this.commentsCount = 8965,
    this.isLiked = false,
    this.isFollowing = false,
    this.poolIndex = 0,
  });

  String get formattedLikes {
    if (likesCount >= 1000) {
      return '${(likesCount / 1000).toStringAsFixed(1)}K';
    }
    return likesCount.toString();
  }

  String get formattedComments {
    return commentsCount.toString();
  }

  LiveStreamState copyWith({
    List<LiveComment>? comments,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    bool? isFollowing,
    int? poolIndex,
  }) {
    return LiveStreamState(
      comments: comments ?? this.comments,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      isFollowing: isFollowing ?? this.isFollowing,
      poolIndex: poolIndex ?? this.poolIndex,
    );
  }
}

class LiveStreamController extends StateNotifier<LiveStreamState> {
  Timer? _commentTimer;

  LiveStreamController()
      : super(LiveStreamState(comments: MockLiveComments.initialComments)) {
    _startCommentSimulation();
  }

  void _startCommentSimulation() {
    _commentTimer?.cancel();
    _commentTimer = Timer.periodic(const Duration(milliseconds: 1600), (timer) {
      if (!mounted) return;
      _pushNextAutomatedComment();
    });

  }

  void _pushNextAutomatedComment() {
    final pool = MockLiveComments.automatedIncomingPool;
    final nextCommentTemplate = pool[state.poolIndex % pool.length];

    final newComment = LiveComment(
      id: 'live_${DateTime.now().millisecondsSinceEpoch}',
      userName: nextCommentTemplate.userName,
      userAvatarUrl: nextCommentTemplate.userAvatarUrl,
      message: nextCommentTemplate.message,
      timestamp: DateTime.now(),
    );

    // Keep max 25 comments in memory to optimize memory & performance
    final updatedList = List<LiveComment>.from(state.comments);
    if (updatedList.length >= 25) {
      updatedList.removeAt(0);
    }
    updatedList.add(newComment);

    state = state.copyWith(
      comments: updatedList,
      commentsCount: state.commentsCount + 1,
      poolIndex: state.poolIndex + 1,
    );
  }

  void addUserComment(String message) {
    if (message.trim().isEmpty) return;

    final userComment = LiveComment(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      userName: 'You',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
      message: message.trim(),
      timestamp: DateTime.now(),
    );

    final updatedList = List<LiveComment>.from(state.comments)..add(userComment);

    state = state.copyWith(
      comments: updatedList,
      commentsCount: state.commentsCount + 1,
    );
  }

  void toggleLike() {
    final newIsLiked = !state.isLiked;
    state = state.copyWith(
      isLiked: newIsLiked,
      likesCount: state.likesCount + (newIsLiked ? 1 : -1),
    );
  }

  void incrementLikesQuickTap() {
    state = state.copyWith(
      likesCount: state.likesCount + 1,
      isLiked: true,
    );
  }

  void toggleFollow() {
    state = state.copyWith(isFollowing: !state.isFollowing);
  }

  void sendGift(GiftItem gift) {
    final giftComment = LiveComment(
      id: 'gift_${DateTime.now().millisecondsSinceEpoch}',
      userName: 'You',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
      message: 'Sent ${gift.name} ${gift.icon} (+${gift.diamonds}💎)',
      timestamp: DateTime.now(),
    );

    final updatedList = List<LiveComment>.from(state.comments)..add(giftComment);
    state = state.copyWith(
      comments: updatedList,
      likesCount: state.likesCount + (gift.diamonds * 2),
      commentsCount: state.commentsCount + 1,
    );
  }

  @override
  void dispose() {
    _commentTimer?.cancel();
    super.dispose();
  }
}

final liveStreamControllerProvider = StateNotifierProvider.autoDispose
    .family<LiveStreamController, LiveStreamState, String>((ref, streamId) {
  return LiveStreamController();
});
