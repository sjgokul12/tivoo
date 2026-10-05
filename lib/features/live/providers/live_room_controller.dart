import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/mock/mock_data.dart';
import '../../../data/models/chat_message.dart';
import '../../../data/repositories/live_repository.dart';
import '../../auth/providers/auth_providers.dart';
import '../../gifts/providers/wallet_provider.dart';

const kMaxChatMessages = 60;
const kMaxChatLength = 150;

/// Appends [message] keeping only the most recent [kMaxChatMessages].
List<ChatMessage> appendCapped(List<ChatMessage> messages, ChatMessage message) {
  final start = messages.length >= kMaxChatMessages ? messages.length - kMaxChatMessages + 1 : 0;
  return [...messages.sublist(start), message];
}

/// Builds a chat message authored by the signed-in viewer.
ChatMessage myMessage(Ref ref, String id, {String text = '', GiftSelection? gift}) {
  final user = ref.read(sessionProvider);
  return ChatMessage(
    id: id,
    senderName: user?.name ?? 'You',
    avatar: user?.avatar ?? MockData.currentUserAvatar,
    sentAt: DateTime.now(),
    text: text,
    gift: gift?.gift,
    giftCount: gift?.quantity ?? 1,
    isMine: true,
  );
}

@immutable
class LiveRoomState {
  const LiveRoomState({
    this.messages = const [],
    this.likes = 0,
    this.isFollowing = false,
    this.lastGift,
  });

  /// Oldest first.
  final List<ChatMessage> messages;
  final int likes;
  final bool isFollowing;
  final ChatMessage? lastGift;

  LiveRoomState copyWith({
    List<ChatMessage>? messages,
    int? likes,
    bool? isFollowing,
    ChatMessage? lastGift,
  }) {
    return LiveRoomState(
      messages: messages ?? this.messages,
      likes: likes ?? this.likes,
      isFollowing: isFollowing ?? this.isFollowing,
      lastGift: lastGift ?? this.lastGift,
    );
  }
}

/// One instance per live room; disposed (and its chat socket closed) when
/// the room leaves the screen.
final liveRoomProvider =
    NotifierProvider.autoDispose.family<LiveRoomController, LiveRoomState, String>(LiveRoomController.new);

class LiveRoomController extends Notifier<LiveRoomState> {
  LiveRoomController(this.streamId);

  final String streamId;
  var _localSeq = 0;

  @override
  LiveRoomState build() {
    final subscription = ref.read(liveRepositoryProvider).watchChat(streamId).listen(_onRemoteMessage);
    ref.onDispose(subscription.cancel);
    return const LiveRoomState();
  }

  void _onRemoteMessage(ChatMessage message) {
    state = state.copyWith(
      messages: appendCapped(state.messages, message),
      likes: state.likes + 1,
      lastGift: message.isGift ? message : null,
    );
  }

  void sendMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final safe = trimmed.length > kMaxChatLength ? trimmed.substring(0, kMaxChatLength) : trimmed;
    // Optimistic append; the real implementation also sends it over the room socket.
    state = state.copyWith(messages: appendCapped(state.messages, myMessage(ref, _nextId(), text: safe)));
  }

  void like() => state = state.copyWith(likes: state.likes + 1);

  void toggleFollow() => state = state.copyWith(isFollowing: !state.isFollowing);

  /// Charges the wallet and posts the gift. Returns false if unaffordable.
  bool sendGift(GiftSelection selection) {
    if (!ref.read(walletProvider.notifier).trySpend(selection.totalCoins)) return false;
    final message = myMessage(ref, _nextId(), gift: selection);
    state = state.copyWith(
      messages: appendCapped(state.messages, message),
      lastGift: message,
      likes: state.likes + 3,
    );
    return true;
  }

  String _nextId() => 'local_${streamId}_${_localSeq++}';
}
