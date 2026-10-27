// Command section state: the comment list, simulated audience messages and auto-scroll.

import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../live_stream/domain/models/live_comment.dart';
import '../core/pk_models.dart';

/// Owns the PK chat. Listeners (the Command List) rebuild when a comment is added,
/// so new messages don't repaint the whole screen.
class PkChatController extends ChangeNotifier {
  PkChatController({
    required String hostName,
    List<LiveComment>? initialComments,
    List<(String, String, String, bool)>? commentPool,
  }) : _comments = initialComments ?? _initialComments(hostName),
       _pool = commentPool ?? PkDemoData.incomingComments;

  static const int maxComments = 100;

  final ScrollController scroll = ScrollController();
  List<LiveComment> _comments;
  final List<(String, String, String, bool)> _pool;
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
      c('Meena', AppAssets.avatarMeena, 'What a battle 😍', 21, gift: false),
      c('Ananya', AppAssets.avatarDiya, 'sent Ocean Tornado 🌪️ x 1', 22, gift: true),
      c('Vicky', AppAssets.avatarVicky, 'Both are amazing 👏', 23, gift: false),
      c('Sneha', AppAssets.avatarSneha, 'Love this PK 🔥', 24, gift: false),
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

  bool _isPaused = false;
  bool get isPaused => _isPaused;

  void pause() {
    _isPaused = true;
  }

  void resume() {
    _isPaused = false;
  }

  void deleteComment(String commentId) {
    _comments = _comments.where((c) => c.id != commentId).toList();
    notifyListeners();
  }

  void reportComment(String commentId) {
    _comments = _comments.map((c) {
      if (c.id == commentId) {
        return c.copyWith(message: 'This comment has been reported', isReported: true);
      }
      return c;
    }).toList();
    notifyListeners();
  }

  void blockUser(String userName) {
    _comments = _comments.where((c) => c.userName != userName).toList();
    notifyListeners();
  }

  /// Posts the next simulated audience message and returns it.
  ({String name, String avatar, String message, bool isGift})? addAudienceComment() {
    if (_isPaused || _pool.isEmpty) return null;
    final (name, avatar, message, isGift) = _pool[_poolIndex++ % _pool.length];
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
