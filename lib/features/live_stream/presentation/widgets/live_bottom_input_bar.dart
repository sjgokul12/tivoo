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

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      widget.onSendComment(text);
      _textController.clear();
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

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutQuad,
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: 6,
        bottom: 8 + bottomInset,
      ),
      child: Row(
        children: [
          // 1. "Add a comment..." capsule with smiley emoji inside (Image 4)
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.18),
                  width: 0.8,
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
                      cursorColor: const Color(0xFF2979FF),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      onSubmitted: (_) => _handleSend(),
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: TextStyle(
                          color: Colors.white60,
                          fontSize: 13.5,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),

                  // Smiley emoji icon inside right of capsule
                  IconButton(
                    icon: const Text('😊', style: TextStyle(fontSize: 18)),
                    onPressed: () {
                      _textController.text += '❤️';
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
    );
  }
}
