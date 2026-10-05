import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/chat_message.dart';
import '../../../data/models/pk_battle.dart';
import '../../../data/repositories/live_repository.dart';
import '../../gifts/providers/wallet_provider.dart';
import '../../live/providers/live_room_controller.dart';

/// Score points credited per coin spent on a gift.
const kPkPointsPerCoin = 100;

@immutable
class PkBattleState {
  const PkBattleState({
    required this.battle,
    required this.leftScore,
    required this.rightScore,
    required this.remaining,
    this.messages = const [],
    this.likes = 0,
    this.lastGift,
  });

  final PkBattle battle;
  final int leftScore;
  final int rightScore;
  final Duration remaining;
  final List<ChatMessage> messages;
  final int likes;
  final ChatMessage? lastGift;

  bool get isFinished => remaining == Duration.zero;

  /// Current leader, or null when tied.
  PkSide? get leader => leftScore == rightScore ? null : (leftScore > rightScore ? PkSide.left : PkSide.right);

  PkBattleState copyWith({
    int? leftScore,
    int? rightScore,
    Duration? remaining,
    List<ChatMessage>? messages,
    int? likes,
    ChatMessage? lastGift,
  }) {
    return PkBattleState(
      battle: battle,
      leftScore: leftScore ?? this.leftScore,
      rightScore: rightScore ?? this.rightScore,
      remaining: remaining ?? this.remaining,
      messages: messages ?? this.messages,
      likes: likes ?? this.likes,
      lastGift: lastGift ?? this.lastGift,
    );
  }
}

final pkBattleProvider = AsyncNotifierProvider.autoDispose<PkBattleController, PkBattleState>(PkBattleController.new);

/// Runs the countdown and applies realtime score/chat events until time is up.
class PkBattleController extends AsyncNotifier<PkBattleState> {
  Timer? _ticker;
  StreamSubscription<PkEvent>? _events;
  var _localSeq = 0;

  @override
  Future<PkBattleState> build() async {
    ref.onDispose(_stop);
    final battle = await ref.read(liveRepositoryProvider).fetchPkBattle();
    _start(battle.id);
    return PkBattleState(
      battle: battle,
      leftScore: battle.leftScore,
      rightScore: battle.rightScore,
      remaining: battle.remaining,
    );
  }

  void _start(String battleId) {
    _stop();
    _events = ref.read(liveRepositoryProvider).watchPkBattle(battleId).listen(_onEvent);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _stop() {
    _ticker?.cancel();
    _events?.cancel();
    _ticker = null;
    _events = null;
  }

  void _update(PkBattleState Function(PkBattleState current) transform) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(transform(current));
  }

  void _tick() {
    _update((s) {
      final remaining = s.remaining - const Duration(seconds: 1);
      if (remaining > Duration.zero) return s.copyWith(remaining: remaining);
      _stop();
      return s.copyWith(remaining: Duration.zero);
    });
  }

  void _onEvent(PkEvent event) {
    _update((s) => _credit(s, event.side, event.points).copyWith(
          messages: appendCapped(s.messages, event.message),
          likes: s.likes + 1,
          lastGift: event.message.isGift ? event.message : null,
        ));
  }

  PkBattleState _credit(PkBattleState s, PkSide side, int points) => side == PkSide.left
      ? s.copyWith(leftScore: s.leftScore + points)
      : s.copyWith(rightScore: s.rightScore + points);

  void sendMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final safe = trimmed.length > kMaxChatLength ? trimmed.substring(0, kMaxChatLength) : trimmed;
    _update((s) => s.copyWith(messages: appendCapped(s.messages, myMessage(ref, _nextId(), text: safe))));
  }

  void like() => _update((s) => s.copyWith(likes: s.likes + 1));

  /// Charges the wallet and credits the chosen side. False if unaffordable
  /// or the battle has ended.
  bool sendGift(GiftSelection selection) {
    final current = state.value;
    if (current == null || current.isFinished) return false;
    if (!ref.read(walletProvider.notifier).trySpend(selection.totalCoins)) return false;
    final message = myMessage(ref, _nextId(), gift: selection);
    final side = PkSide.values[selection.recipientIndex.clamp(0, 1)];
    _update((s) => _credit(s, side, selection.totalCoins * kPkPointsPerCoin).copyWith(
          messages: appendCapped(s.messages, message),
          lastGift: message,
          likes: s.likes + 3,
        ));
    return true;
  }

  /// Starts a fresh round between the same two creators.
  void rematch() {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(PkBattleState(
      battle: current.battle,
      leftScore: 0,
      rightScore: 0,
      remaining: current.battle.duration,
      messages: current.messages,
    ));
    _start(current.battle.id);
  }

  String _nextId() => 'pk_local_${_localSeq++}';
}
