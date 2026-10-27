import 'package:flutter/material.dart';

/// Bottom Input Bar matching Image 4:
/// - Oblong capsule: "Add a comment..." with smiley face [😊] icon inside
/// - Circular Send button: Vibrant Electric Blue gradient with white paper airplane icon
class LiveBottomInputBar extends StatefulWidget {
  final Function(String text) onSendComment;
  final VoidCallback? onStarTap;
  final VoidCallback? onGiftTap;
  final VoidCallback? onFilterTap;
  final VoidCallback? onShareTap;
  final FocusNode? focusNode;

  const LiveBottomInputBar({
    super.key,
    required this.onSendComment,
    this.onStarTap,
    this.onGiftTap,
    this.onFilterTap,
    this.onShareTap,
    this.focusNode,
  });

  @override
  State<LiveBottomInputBar> createState() => _LiveBottomInputBarState();
}

class _LiveBottomInputBarState extends State<LiveBottomInputBar> {
  final TextEditingController _textController = TextEditingController();
  bool _showEmojiPicker = false;

  static const List<String> _quickEmojis = [
    '❤️', '😍', '🔥', '👏', '⭐', '🎉', '🌹', '💯', '😂', '✨',
    '🙌', '🥰', '🥳', '😎', '💖', '🤩', '👍', '🎁', '👑', '💃',
    '💪', '🚀', '🌟', '💐', '🦄', '🌈', '⚡', '☕', '🥳', '🥰',
  ];

  void _insertEmoji(String emoji) {
    final text = _textController.text;
    final selection = _textController.selection;
    if (selection.start >= 0 && selection.end >= 0) {
      final newText = text.replaceRange(selection.start, selection.end, emoji);
      _textController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + emoji.length),
      );
    } else {
      _textController.text += emoji;
      _textController.selection = TextSelection.collapsed(offset: _textController.text.length);
    }
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      widget.onSendComment(text);
      _textController.clear();
      setState(() => _showEmojiPicker = false);
      FocusScope.of(context).unfocus();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final effectiveBottom = bottomInset > 0 ? bottomInset + 8.0 : safeBottom + 8.0;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutQuad,
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: 6,
        bottom: effectiveBottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quick Emoji Bar (displayed when tapping smiley icon or viewing emojis)
          if (_showEmojiPicker)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xF0141320),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                  width: 1.0,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x3300E5FF),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _quickEmojis.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final emoji = _quickEmojis[index];
                    return GestureDetector(
                      onTap: () => _insertEmoji(emoji),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            emoji,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          Row(
            children: [
              // 1. "Add a comment..." capsule with smiley emoji inside (Image 4)
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xE6141320),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.28),
                      width: 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          focusNode: widget.focusNode,
                          textAlignVertical: TextAlignVertical.center,
                          cursorColor: const Color(0xFF00E5FF),
                          cursorWidth: 2.2,
                          keyboardAppearance: Brightness.dark,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          enableSuggestions: true,
                          autocorrect: true,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                          ),
                          // Dismiss keypad on tick/done so user can review comment before sending
                          onSubmitted: (_) {
                            FocusScope.of(context).unfocus();
                          },
                          decoration: const InputDecoration(
                            hintText: 'Add a comment...',
                            hintStyle: TextStyle(
                              color: Color(0xFFB0B0C4),
                              fontSize: 13.5,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),

                      // Smiley emoji toggle button inside right of capsule
                      IconButton(
                        icon: Text(
                          _showEmojiPicker ? '⌨️' : '😊',
                          style: const TextStyle(fontSize: 18),
                        ),
                        onPressed: () {
                          setState(() {
                            _showEmojiPicker = !_showEmojiPicker;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      ),
                      const SizedBox(width: 6),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),

              // 2. Circular Send Button with Blue Gradient & Paper Airplane (Image 4)
              GestureDetector(
                onTap: _handleSend,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00B0FF), Color(0xFF2979FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2979FF).withValues(alpha: 0.45),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.near_me_rounded,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
