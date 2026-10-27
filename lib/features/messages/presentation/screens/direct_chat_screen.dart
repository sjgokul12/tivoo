import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/luxe_theme.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../profile/presentation/controllers/follow_controller.dart';
import '../../domain/models/chat_message.dart';
import '../controllers/messages_controller.dart';

class DirectChatScreen extends ConsumerStatefulWidget {
  final String peerId;
  final String peerName;
  final String peerAvatar;
  final String peerUsername;
  final bool isVerified;
  final bool isOnline;

  const DirectChatScreen({
    super.key,
    required this.peerId,
    required this.peerName,
    required this.peerAvatar,
    this.peerUsername = '',
    this.isVerified = false,
    this.isOnline = true,
  });

  @override
  ConsumerState<DirectChatScreen> createState() => _DirectChatScreenState();
}

class _DirectChatScreenState extends ConsumerState<DirectChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(messagesControllerProvider.notifier).markAsRead(widget.peerId);
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 90,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    setState(() => _isComposing = false);

    ref.read(messagesControllerProvider.notifier).sendMessage(
          peerId: widget.peerId,
          text: text,
        );

    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _handleSendHeart() {
    ref.read(messagesControllerProvider.notifier).sendMessage(
          peerId: widget.peerId,
          text: '❤️',
          type: MessageType.heart,
        );
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  Future<void> _handlePickImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (picked != null) {
        ref.read(messagesControllerProvider.notifier).sendMessage(
              peerId: widget.peerId,
              text: 'Sent a photo',
              mediaPath: picked.path,
            );
        Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final messagesState = ref.watch(messagesControllerProvider);
    final followState = ref.watch(followControllerProvider);
    final rel = followState[widget.peerId];
    final isFollowing = rel?.isFollowingOrMutual ?? false;

    final canMessage = ref
        .read(messagesControllerProvider.notifier)
        .canMessageUser(widget.peerId, isFollowing: isFollowing);

    final thread = messagesState.threadMessages[widget.peerId] ?? [];

    return Scaffold(
      backgroundColor: LuxeColors.bg,
      body: Stack(
        children: [
          // 1. Global Luxe Atmosphere Backdrop
          const Positioned.fill(
            child: LuxeBackdrop(),
          ),

          // 2. Chat Layout
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                if (!canMessage) _buildFollowersOnlyWarning(context),
                Expanded(
                  child: thread.isEmpty
                      ? _buildEmptyChatPrompt()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          physics: const BouncingScrollPhysics(),
                          itemCount: thread.length,
                          itemBuilder: (context, index) {
                            final msg = thread[index];
                            final showDateHeader = index == 0 ||
                                _isDifferentDay(thread[index - 1].timestamp, msg.timestamp);
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (showDateHeader) _buildDateHeader(msg.timestamp),
                                _buildMessageBubble(msg),
                              ],
                            );
                          },
                        ),
                ),
                _buildInputBar(canMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isDifferentDay(DateTime a, DateTime b) {
    return a.year != b.year || a.month != b.month || a.day != b.day;
  }

  Widget _buildDateHeader(DateTime timestamp) {
    final now = DateTime.now();
    String label;
    if (now.difference(timestamp).inDays == 0 && now.day == timestamp.day) {
      label = 'Today';
    } else if (now.difference(timestamp).inDays <= 1) {
      label = 'Yesterday';
    } else {
      label = '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: LuxeColors.panel.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: LuxeColors.purple.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: LuxeColors.textDim,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: LuxeColors.bgTop.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: LuxeColors.purple.withValues(alpha: 0.22),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          LuxeCircleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            label: 'Back',
            size: 38,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 10),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      LuxeColors.goldLight,
                      LuxeColors.pink,
                      LuxeColors.violet,
                      LuxeColors.blue,
                      LuxeColors.goldLight,
                    ],
                  ),
                ),
                child: CustomAvatar(
                  radius: 19,
                  assetPath: widget.peerAvatar.startsWith('assets/') ? widget.peerAvatar : null,
                  imageUrl: !widget.peerAvatar.startsWith('assets/') ? widget.peerAvatar : null,
                ),
              ),
              if (widget.isOnline)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676),
                      shape: BoxShape.circle,
                      border: Border.all(color: LuxeColors.bgTop, width: 2),
                      boxShadow: const [
                        BoxShadow(color: Color(0x8800E676), blurRadius: 4),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.peerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified_rounded, color: LuxeColors.gold, size: 15),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (widget.isOnline) ...[
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 5),
                        decoration: const BoxDecoration(
                          color: Color(0xFF00E676),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                    Text(
                      widget.isOnline ? 'Active now' : (widget.peerUsername.isNotEmpty ? widget.peerUsername : 'Offline'),
                      style: TextStyle(
                        color: widget.isOnline ? const Color(0xFF00E676) : LuxeColors.textDim,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          LuxeCircleButton(
            icon: Icons.call_rounded,
            label: 'Voice call',
            size: 38,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: LuxeColors.panel,
                  content: Text('Starting audio call with ${widget.peerName}...', style: const TextStyle(color: Colors.white)),
                ),
              );
            },
          ),
          const SizedBox(width: 6),
          LuxeCircleButton(
            icon: Icons.videocam_rounded,
            label: 'Video call',
            size: 38,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: LuxeColors.panel,
                  content: Text('Calling ${widget.peerName} in HD video...', style: const TextStyle(color: Colors.white)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFollowersOnlyWarning(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: LuxeColors.panel.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: LuxeColors.gold.withValues(alpha: 0.35), width: 1.1),
        boxShadow: const [
          BoxShadow(color: Color(0x33FFC928), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: LuxeColors.gold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_rounded, color: LuxeColors.gold, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${widget.peerName} only accepts messages from followers.',
              style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.3),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              ref.read(followControllerProvider.notifier).sendFollowRequest(
                    widget.peerId,
                    targetName: widget.peerName,
                    targetAvatar: widget.peerAvatar,
                  );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: LuxeDecor.goldButton(radius: 12),
              child: const Text(
                'Follow',
                style: TextStyle(
                  color: Color(0xFF161200),
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChatPrompt() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  LuxeColors.goldLight,
                  LuxeColors.pink,
                  LuxeColors.violet,
                  LuxeColors.blue,
                  LuxeColors.goldLight,
                ],
              ),
            ),
            child: CustomAvatar(
              radius: 44,
              assetPath: widget.peerAvatar.startsWith('assets/') ? widget.peerAvatar : null,
              imageUrl: !widget.peerAvatar.startsWith('assets/') ? widget.peerAvatar : null,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.peerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (widget.isVerified) ...[
                const SizedBox(width: 4),
                const Icon(Icons.verified_rounded, color: LuxeColors.gold, size: 16),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            widget.peerUsername.isNotEmpty ? widget.peerUsername : 'VIP Creator',
            style: const TextStyle(color: LuxeColors.textDim, fontSize: 12.5),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: LuxeColors.panel.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: LuxeColors.purple.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.waving_hand_rounded, color: LuxeColors.gold, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Say hello to ${widget.peerName.split(' ').first}!',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isMe = msg.isMe;
    final isHeart = msg.type == MessageType.heart;

    if (isHeart) {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: LuxeColors.panel.withValues(alpha: 0.4),
              border: Border.all(color: LuxeColors.pink.withValues(alpha: 0.4)),
              boxShadow: const [
                BoxShadow(color: Color(0x44FF2D78), blurRadius: 12),
              ],
            ),
            child: const Text('❤️', style: TextStyle(fontSize: 32)),
          ),
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.76),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          gradient: isMe
              ? LuxeColors.goldGradient
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    LuxeColors.panel.withValues(alpha: 0.85),
                    LuxeColors.panelDeep.withValues(alpha: 0.95),
                  ],
                ),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          border: isMe
              ? null
              : Border.all(
                  color: LuxeColors.purple.withValues(alpha: 0.35),
                  width: 1.1,
                ),
          boxShadow: [
            BoxShadow(
              color: isMe
                  ? const Color(0x4DFFC928)
                  : LuxeColors.purple.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (msg.mediaPath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(msg.mediaPath!),
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, color: Colors.white54),
                ),
              ),
              const SizedBox(height: 6),
            ],
            Text(
              msg.text,
              style: TextStyle(
                color: isMe ? const Color(0xFF161200) : Colors.white,
                fontSize: 14.5,
                fontWeight: isMe ? FontWeight.w700 : FontWeight.w500,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: isMe ? const Color(0x99161200) : LuxeColors.textDim,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    msg.status == MessageStatus.read
                        ? Icons.done_all_rounded
                        : Icons.done_rounded,
                    size: 13,
                    color: isMe ? const Color(0xCC161200) : Colors.white54,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(bool canMessage) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: LuxeColors.bgTop.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
            color: LuxeColors.purple.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          LuxeCircleButton(
            icon: Icons.photo_camera_back_rounded,
            label: 'Send photo',
            size: 38,
            onTap: canMessage ? _handlePickImage : null,
          ),
          const SizedBox(width: 6),
          LuxeCircleButton(
            icon: Icons.favorite_rounded,
            label: 'Send heart',
            size: 38,
            iconColor: const Color(0xFFFF2D78),
            onTap: canMessage ? _handleSendHeart : null,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: LuxeColors.panel.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: LuxeColors.purple.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _textController,
                enabled: canMessage,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                cursorColor: LuxeColors.gold,
                decoration: InputDecoration(
                  hintText: canMessage ? 'Message ${widget.peerName}...' : 'Follow to send messages',
                  hintStyle: const TextStyle(color: LuxeColors.textDim, fontSize: 13),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onChanged: (val) {
                  setState(() => _isComposing = val.trim().isNotEmpty);
                },
                onSubmitted: (_) => _handleSend(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          LuxeCircleButton(
            icon: Icons.send_rounded,
            label: 'Send',
            size: 40,
            gold: true,
            iconColor: const Color(0xFF161200),
            onTap: (_isComposing && canMessage) ? _handleSend : null,
          ),
        ],
      ),
    );
  }
}
