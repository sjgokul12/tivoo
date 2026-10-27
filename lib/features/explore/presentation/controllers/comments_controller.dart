import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../domain/models/post_comment.dart';

/// Comments for one Explore item (keyed by its id).
///
/// Comments live in memory on this phone for now; they need a backend endpoint to be
/// shared between users.
class CommentsController extends StateNotifier<List<PostComment>> {
  final Ref _ref;

  CommentsController(this._ref, String itemId, {required bool seed}) : super(seed ? _seedFor(itemId) : const []);

  void add(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final profile = _ref.read(profileControllerProvider).profile;
    state = [
      PostComment(
        id: 'c_${DateTime.now().microsecondsSinceEpoch}',
        authorName: profile.username,
        authorAvatar: profile.avatarUrl.isNotEmpty ? profile.avatarUrl : AppAssets.status5,
        text: trimmed,
        createdAt: DateTime.now(),
        isMine: true,
      ),
      ...state,
    ];
  }

  void toggleLike(String id) {
    state = [
      for (final c in state)
        if (c.id == id) c.copyWith(isLiked: !c.isLiked, likes: c.likes + (c.isLiked ? -1 : 1)) else c,
    ];
  }

  void delete(String id) => state = state.where((c) => c.id != id).toList();

  static const _samples = [
    ('priya_vibes', AppAssets.avatarPriya, 'This is so beautiful 😍🔥'),
    ('karthik.k', AppAssets.avatarKarthik, 'Bro this edit is next level 👏'),
    ('neha_official', AppAssets.avatarNeha, 'Which song is this? Need it 🎶'),
    ('diya_dreams', AppAssets.avatarDiya, 'Can’t stop watching this 😂❤️'),
    ('arun_tivoo', AppAssets.avatarArun, 'Goals!! 🙌'),
    ('sneha.s', AppAssets.avatarSneha, 'Love the vibe ✨'),
    ('meena_live', AppAssets.avatarMeena, 'Going live later? I’ll join 💛'),
  ];

  /// A few sample comments so demo videos don't look empty (same ones every time).
  static List<PostComment> _seedFor(String itemId) {
    final h = itemId.codeUnits.fold<int>(7, (a, b) => (a * 31 + b) & 0x7fffffff);
    final count = 3 + h % 4;
    return [
      for (var i = 0; i < count; i++)
        () {
          final s = _samples[(h + i * 3) % _samples.length];
          return PostComment(
            id: '${itemId}_seed_$i',
            authorName: s.$1,
            authorAvatar: s.$2,
            text: s.$3,
            createdAt: DateTime.now().subtract(Duration(minutes: 7 + (h >> i) % 600 + i * 45)),
            likes: (h >> (i + 2)) % 240,
          );
        }(),
    ];
  }
}

/// Arguments: (item id, whether to add sample comments).
final commentsProvider = StateNotifierProvider.family<CommentsController, List<PostComment>, (String, bool)>(
  (ref, args) => CommentsController(ref, args.$1, seed: args.$2),
);
