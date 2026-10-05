import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gradient_mask.dart';
import '../../providers/live_room_controller.dart';

/// Glass "Type a message..." pill: emoji on the left, gradient send arrow on
/// the right (dimmed until there's text — only the arrow rebuilds on typing).
class ChatInputBar extends StatefulWidget {
  const ChatInputBar({super.key, required this.onSubmit});

  final ValueChanged<String> onSubmit;

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSubmit(text);
    _controller.clear();
  }

  void _insertEmoji() {
    final value = _controller.value;
    final start = value.selection.isValid ? value.selection.start : value.text.length;
    final end = value.selection.isValid ? value.selection.end : value.text.length;
    const emoji = '😍';
    _controller.value = TextEditingValue(
      text: value.text.replaceRange(start, end, emoji),
      selection: TextSelection.collapsed(offset: start + emoji.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(colors: [Color(0xD9161445), Color(0xD90B0A22)]),
        border: Border.all(color: const Color(0x808DA2FF)),
        boxShadow: const [BoxShadow(color: Color(0x408B5CF6), blurRadius: 12, blurStyle: BlurStyle.outer)],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _insertEmoji,
            tooltip: 'Emoji',
            icon: const Icon(Icons.sentiment_satisfied_alt_outlined, color: Colors.white),
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              maxLength: kMaxChatLength,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submit(),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                border: InputBorder.none,
                counterText: '',
                isDense: true,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (_, value, _) {
              final hasText = value.text.trim().isNotEmpty;
              return IconButton(
                onPressed: hasText ? _submit : null,
                tooltip: 'Send',
                icon: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: hasText ? 1 : 0.55,
                  child: const GradientMask(
                    gradient: LinearGradient(colors: [Color(0xFFFF8AD8), Color(0xFF8B5CF6)]),
                    child: Icon(Icons.send_rounded, size: 26),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
