// Command section state: the comment list, simulated audience messages and auto-scroll.

import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../live_stream/domain/models/live_comment.dart';
import '../core/pk_models.dart';

/// Owns the PK chat. Listeners (the Command List) rebuild when a comment is added,
/// so new messages don't repaint the whole screen.
class PkChatController extends ChangeNotifier {
  PkChatController({required String hostName}) : _comments = _initialComments(hostName);

  static const int maxComments = 100;

  final ScrollController scroll = ScrollController();
  List<LiveComment> _comments;
  int _poolIndex = 0;

  List<LiveComment> get comments => _comments;

  static List<LiveComment> _initialComments(String hostName) {
    final now = DateTime.now();
    LiveComment c(String name, String avatar, String msg, int minute, {bool gift = true}) => LiveComment(
      id: 'init_$minute',
      userName: name,
      userAssetPath: avatar,
      message: msg,
      type: gift ? LiveCommentType.gift : LiveCommentType.chat,
      timestamp: DateTime(now.year, now.month, now.day, 10, minute),
    );
    return [
      c('Diya', AppAssets.status4, 'sent Rose 🌹 x 1', 21),
      c('Ananya', AppAssets.status3, 'sent Ocean Whale 🐳 x 1', 22),
      c('Sanjay', AppAssets.status5, 'sent Angel Vehicle 🏹 x 1', 23),
      c('Rahul', AppAssets.avatarSaran, 'sent Car 🚗 x 1', 24),
      c('Sneha', AppAssets.status3, 'Keep going $hostName! ⭐', 25, gift: false),
    ];
  }

  /// Adds a comment (keeping the newest [maxComments]) and scrolls to it.
  void add({required String userName, required String avatar, required String message, bool isGift = false}) {
    final comment = LiveComment(
      id: 'c_${DateTime.now().microsecondsSinceEpoch}',
      userName: userName,
      userAssetPath: avatar,
      message: message,
      type: isGift ? LiveCommentType.gift : LiveCommentType.chat,
      timestamp: DateTime.now(),
    );
    final next = [..._comments, comment];
    _comments = next.length > maxComments ? next.sublist(next.length - maxComments) : next;
    notifyListeners();
    scrollToLatest();
  }

  /// Posts the next simulated audience message and returns it.
  ({String name, String avatar, String message, bool isGift}) addAudienceComment() {
    final pool = PkDemoData.incomingComments;
    final (name, avatar, message, isGift) = pool[_poolIndex++ % pool.length];
    add(userName: name, avatar: avatar, message: message, isGift: isGift);
    return (name: name, avatar: avatar, message: message, isGift: isGift);
  }

  void scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scroll.hasClients) return;
      scroll.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    });
  }

  @override
  void dispose() {
    scroll.dispose();
    super.dispose();
  }
}
