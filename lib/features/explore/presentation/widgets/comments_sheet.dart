import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../domain/models/post_comment.dart';
import '../controllers/comments_controller.dart';

const _gold = Color(0xFFFFC928);
const _sheetBg = Color(0xFF121218);
const _muted = Color(0xFF9A98AE);

/// Instagram-style comments sheet: drag to expand, scroll the list, type at the bottom.
class CommentsSheet extends ConsumerStatefulWidget {
  final String itemId;
  final bool seed;

  const CommentsSheet({super.key, required this.itemId, this.seed = true});

  /// [seed] adds sample comments (for demo videos); pass false for real uploads.
  static Future<void> show(BuildContext context, {required String itemId, bool seed = true}) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => CommentsSheet(itemId: itemId, seed: seed),
    );
  }

  @override
  ConsumerState<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<CommentsSheet> {
  final _input = TextEditingController();
  final _focus = FocusNode();

  static const _quickEmojis = ['❤️', '🙌', '🔥', '👏', '😢', '😍', '😮', '😂'];

  (String, bool) get _key => (widget.itemId, widget.seed);

  @override
  void initState() {
    super.initState();
    _input.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _send() {
    ref.read(commentsProvider(_key).notifier).add(_input.text);
    _input.clear();
  }

  void _reply(PostComment c) {
    _input.text = '@${c.authorName} ';
    _input.selection = TextSelection.collapsed(offset: _input.text.length);
    _focus.requestFocus();
  }

  Future<void> _confirmDelete(PostComment c) async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: const Color(0xFF1C1C24),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: ListTile(
          leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
          title: const Text(
            'Delete comment',
            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
          ),
          onTap: () => Navigator.pop(ctx, true),
        ),
      ),
    );
    if (ok == true) ref.read(commentsProvider(_key).notifier).delete(c.id);
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(commentsProvider(_key));
    final profile = ref.watch(profileControllerProvider).profile;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final maxWidth = MediaQuery.sizeOf(context).width > 700 ? 600.0 : double.infinity;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboard),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: keyboard > 0 ? 0.92 : 0.68,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder: (context, scroll) => Container(
              decoration: const BoxDecoration(
                color: _sheetBg,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Column(
                children: [
                  // Handle + title
                  const SizedBox(height: 10),
                  Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    comments.isEmpty ? 'Comments' : 'Comments  ·  ${comments.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
                  // List
                  Expanded(
                    child: comments.isEmpty
                        ? ListView(controller: scroll, children: const [SizedBox(height: 70), _EmptyState()])
                        : ListView.builder(
                            controller: scroll,
                            padding: const EdgeInsets.fromLTRB(16, 10, 8, 16),
                            itemCount: comments.length,
                            itemBuilder: (_, i) => _CommentTile(
                              comment: comments[i],
                              onLike: () => ref.read(commentsProvider(_key).notifier).toggleLike(comments[i].id),
                              onReply: () => _reply(comments[i]),
                              onLongPress: comments[i].isMine ? () => _confirmDelete(comments[i]) : null,
                            ),
                          ),
                  ),
                  Divider(height: 1, color: Colors.white.withValues(alpha: 0.08)),
                  // Quick emoji row
                  SizedBox(
                    height: 46,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      children: [
                        for (final e in _quickEmojis)
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              _input.text += e;
                              _input.selection = TextSelection.collapsed(offset: _input.text.length);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 9),
                              child: Center(child: Text(e, style: const TextStyle(fontSize: 22))),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Input bar
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 2, 8, 10),
                      child: Row(
                        children: [
                          CustomAvatar(
                            radius: 17,
                            imageUrl: profile.avatarUrl.isNotEmpty ? profile.avatarUrl : AppAssets.status5,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _input,
                              focusNode: _focus,
                              minLines: 1,
                              maxLines: 4,
                              maxLength: 500,
                              textCapitalization: TextCapitalization.sentences,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                              cursorColor: _gold,
                              onSubmitted: (_) => _send(),
                              decoration: InputDecoration(
                                counterText: '',
                                isDense: true,
                                hintText: 'Add a comment…',
                                hintStyle: const TextStyle(color: _muted, fontSize: 14),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.07),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide(color: _gold.withValues(alpha: 0.6)),
                                ),
                              ),
                            ),
                          ),
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 150),
                            opacity: _input.text.trim().isEmpty ? 0.4 : 1,
                            child: IconButton(
                              tooltip: 'Post',
                              onPressed: _input.text.trim().isEmpty ? null : _send,
                              icon: const Icon(Icons.arrow_upward_rounded),
                              style: IconButton.styleFrom(
                                backgroundColor: _gold,
                                foregroundColor: const Color(0xFF1A1300),
                                disabledBackgroundColor: _gold,
                                disabledForegroundColor: const Color(0xFF1A1300),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final PostComment comment;
  final VoidCallback onLike;
  final VoidCallback onReply;
  final VoidCallback? onLongPress;

  const _CommentTile({required this.comment, required this.onLike, required this.onReply, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: onLongPress,
      onDoubleTap: comment.isLiked ? null : onLike,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomAvatar(radius: 17, imageUrl: comment.authorAvatar),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          comment.authorName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(comment.age, style: const TextStyle(color: _muted, fontSize: 12)),
                      if (comment.isMine) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: _gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'You',
                            style: TextStyle(color: _gold, fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(comment.text, style: const TextStyle(color: Color(0xFFEDEDF5), fontSize: 14, height: 1.35)),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: onReply,
                    child: const Text(
                      'Reply',
                      style: TextStyle(color: _muted, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 44,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onLike,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Column(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
                        child: Icon(
                          comment.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          key: ValueKey(comment.isLiked),
                          size: 17,
                          color: comment.isLiked ? const Color(0xFFFF3B5C) : _muted,
                        ),
                      ),
                      if (comment.likes > 0) ...[
                        const SizedBox(height: 2),
                        Text('${comment.likes}', style: const TextStyle(color: _muted, fontSize: 11)),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.chat_bubble_outline_rounded, color: Colors.white24, size: 54),
        SizedBox(height: 14),
        Text(
          'No comments yet',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 6),
        Text('Start the conversation.', style: TextStyle(color: _muted, fontSize: 13.5)),
      ],
    );
  }
}
