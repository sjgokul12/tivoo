import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../data/models/chat_message.dart';

/// Reversed chat list (newest at the bottom) with a top fade and a
/// "New Messages" jump pill that appears when the user scrolls back.
class LiveChatList extends StatefulWidget {
  const LiveChatList({super.key, required this.messages, this.showTime = false, this.bubbles = true});

  /// Oldest first.
  final List<ChatMessage> messages;
  final bool showTime;

  /// Draws a dark pill behind each line — needed when chat floats over video.
  final bool bubbles;

  @override
  State<LiveChatList> createState() => _LiveChatListState();
}

class _LiveChatListState extends State<LiveChatList> {
  final _controller = ScrollController();
  final _showJump = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => _showJump.value = _controller.offset > 60);
  }

  @override
  void dispose() {
    _controller.dispose();
    _showJump.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = widget.messages;
    return Stack(
      children: [
        ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (rect) => const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black],
            stops: [0, 0.18],
          ).createShader(rect),
          child: ListView.builder(
            controller: _controller,
            reverse: true,
            padding: const EdgeInsets.only(top: 24, bottom: 4),
            itemCount: messages.length,
            itemBuilder: (_, i) {
              final message = messages[messages.length - 1 - i];
              return ChatMessageTile(
                key: ValueKey(message.id),
                message: message,
                showTime: widget.showTime,
                bubble: widget.bubbles,
              );
            },
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 6,
          child: ValueListenableBuilder<bool>(
            valueListenable: _showJump,
            builder: (_, show, _) => AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: !show
                  ? const SizedBox.shrink()
                  : Center(
                      child: GestureDetector(
                        onTap: () => _controller.animateTo(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        ),
                        child: const GlassContainer(
                          borderRadius: 20,
                          color: Color(0xE61A1545),
                          borderColor: Color(0x66B44CFF),
                          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('New Messages', style: TextStyle(color: Colors.white, fontSize: 12)),
                              SizedBox(width: 4),
                              Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class ChatMessageTile extends StatelessWidget {
  const ChatMessageTile({super.key, required this.message, this.showTime = false, this.bubble = true});

  final ChatMessage message;
  final bool showTime;
  final bool bubble;

  @override
  Widget build(BuildContext context) {
    if (bubble) return _FloatingTile(message: message);
    final gift = message.gift;
    final content = Row(
      mainAxisSize: bubble ? MainAxisSize.min : MainAxisSize.max,
      children: [
        Avatar(image: message.avatar, size: bubble ? 28 : 26, ringWidth: 1.2),
        const SizedBox(width: 8),
        Flexible(
          fit: bubble ? FlexFit.loose : FlexFit.tight,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${message.senderName}  ',
                  style: TextStyle(
                    color: message.isMine ? AppColors.gold : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (gift == null)
                  TextSpan(
                    text: message.text,
                    style: TextStyle(color: message.isMine ? AppColors.cyan : const Color(0xFFC7B8FF)),
                  )
                else
                  TextSpan(
                    text: 'sent ${gift.name} ${gift.emoji} x${message.giftCount}',
                    style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.w500),
                  ),
              ],
            ),
            // Panel chat (PK) is one tidy line per message; floating chat may wrap.
            maxLines: bubble ? 3 : 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: bubble ? 13 : 12, height: 1.3),
          ),
        ),
        if (showTime) ...[
          const SizedBox(width: 6),
          Text(
            Formatters.clock(message.sentAt),
            style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
          ),
        ],
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
      child: content,
    );
  }
}

/// Chat over video: avatar, cyan name + time, message underneath, on a dark
/// strip that fades out to the right.
class _FloatingTile extends StatelessWidget {
  const _FloatingTile({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final gift = message.gift;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(colors: [Color(0x99070616), Color(0x40070616), Color(0x00070616)]),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
          child: Row(
            children: [
              Avatar(image: message.avatar, size: 34, ringWidth: 1.4),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            message.senderName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: message.isMine ? AppColors.gold : const Color(0xFF5EEAD4),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          Formatters.clock(message.sentAt),
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 10, height: 1.2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      gift == null ? message.text : 'sent ${gift.name} ${gift.emoji} x${message.giftCount}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: gift == null ? Colors.white : AppColors.gold,
                        fontSize: 13,
                        height: 1.3,
                        fontWeight: gift == null ? FontWeight.w400 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
