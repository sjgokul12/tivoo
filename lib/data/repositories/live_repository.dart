import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_assets.dart';
import '../mock/mock_data.dart';
import '../models/chat_message.dart';
import '../models/live_stream.dart';
import '../models/page_result.dart';
import '../models/pk_battle.dart';

final liveRepositoryProvider = Provider<LiveRepository>((ref) => LiveRepository());

/// Live streams, room chat sockets and PK battles.
///
/// Currently backed by [MockData] with simulated latency; swap each method
/// body for the real HTTP / WebSocket call without touching the UI layer.
class LiveRepository {
  LiveRepository({math.Random? random}) : _random = random ?? math.Random();

  static const pageSize = 6;
  static const _latency = Duration(milliseconds: 700);

  final math.Random _random;
  final _searchCache = <String, List<LiveStream>>{};
  var _messageSeq = 0;

  Future<PageResult<LiveStream>> fetchLiveStreams({required int page}) async {
    await Future<void>.delayed(_latency);
    final all = MockData.streams;
    final start = page * pageSize;
    final items = all.skip(start).take(pageSize).toList(growable: false);
    return PageResult(items: items, hasMore: start + items.length < all.length);
  }

  /// Search results are cached per query for the app session.
  Future<List<LiveStream>> search(String query) async {
    final key = query.trim().toLowerCase();
    final cached = _searchCache[key];
    if (cached != null) return cached;

    await Future<void>.delayed(const Duration(milliseconds: 400));
    final results = MockData.streams
        .where((s) => s.streamer.name.toLowerCase().contains(key) || s.category.toLowerCase().contains(key))
        .toList(growable: false);
    return _searchCache[key] = results;
  }

  /// Incoming chat for a room (stands in for a WebSocket subscription).
  Stream<ChatMessage> watchChat(String streamId) async* {
    while (true) {
      await Future<void>.delayed(Duration(milliseconds: 1400 + _random.nextInt(2000)));
      yield _randomMessage(MockData.comments, giftChance: 0.25);
    }
  }

  Future<PkBattle> fetchPkBattle() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final s = MockData.streams;
    return PkBattle(
      id: 'pk_${s[0].id}_${s[1].id}',
      left: s[0],
      right: s[1],
      duration: const Duration(minutes: 3),
      remaining: const Duration(minutes: 2, seconds: 53),
      leftScore: 7558940,
      rightScore: 4834900,
      leftSupporters: [s[13].streamer.avatar, s[2].streamer.avatar, s[4].streamer.avatar],
      rightSupporters: [s[6].streamer.avatar, s[8].streamer.avatar, s[5].streamer.avatar],
      leftCover: AppAssets.pkSceneLeft,
      rightCover: AppAssets.pkSceneRight,
    );
  }

  /// Score + chat events for a running PK battle.
  Stream<PkEvent> watchPkBattle(String battleId) async* {
    while (true) {
      await Future<void>.delayed(Duration(milliseconds: 700 + _random.nextInt(900)));
      final message = _randomMessage(MockData.pkComments, giftChance: 0.5);
      final giftPoints = message.gift == null ? 0 : message.gift!.coins * message.giftCount * 100;
      yield PkEvent(
        side: _random.nextDouble() < 0.52 ? PkSide.left : PkSide.right,
        message: message,
        points: giftPoints + _random.nextInt(6000),
      );
    }
  }

  ChatMessage _randomMessage(List<String> pool, {required double giftChance}) {
    final sender = MockData.streams[_random.nextInt(MockData.streams.length)].streamer;
    final isGift = _random.nextDouble() < giftChance;
    return ChatMessage(
      id: 'remote_${_messageSeq++}',
      senderName: sender.name,
      avatar: sender.avatar,
      sentAt: DateTime.now(),
      text: isGift ? '' : pool[_random.nextInt(pool.length)],
      gift: isGift ? MockData.gifts[_random.nextInt(8)] : null,
      giftCount: isGift ? 1 + _random.nextInt(3) : 1,
    );
  }
}
