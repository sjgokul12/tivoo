import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/luxe_theme.dart';
import '../../../profile/presentation/controllers/follow_controller.dart';
import '../controllers/messages_controller.dart';
import '../screens/direct_chat_screen.dart';

/// Reusable Instagram-style "Message" button placed next to Follow buttons
/// in all profile screens and bottom sheets.
class ProfileMessageButton extends ConsumerWidget {
  final String userId;
  final String userName;
  final String userAvatar;
  final String userUsername;
  final bool isVerified;
  final double height;
  final double fontSize;
  final bool isIconOnly;

  const ProfileMessageButton({
    super.key,
    required this.userId,
    required this.userName,
    this.userAvatar = '',
    this.userUsername = '',
    this.isVerified = false,
    this.height = 42.0,
    this.fontSize = 13.0,
    this.isIconOnly = false,
  });

  static void openChat(
    BuildContext context,
    WidgetRef ref, {
    required String userId,
    required String userName,
    required String userAvatar,
    String userUsername = '',
    bool isVerified = false,
  }) {
    final followState = ref.read(followControllerProvider);
    final rel = followState[userId];
    final isFollowing = rel?.isFollowingOrMutual ?? false;

    final canMessage = ref
        .read(messagesControllerProvider.notifier)
        .canMessageUser(userId, isFollowing: isFollowing);

    if (!canMessage) {
      _showFollowersOnlyModal(
        context,
        ref,
        userId: userId,
        userName: userName,
        userAvatar: userAvatar,
      );
      return;
    }

    final conv = ref.read(messagesControllerProvider.notifier).getOrCreateConversation(
          peerId: userId,
          peerName: userName,
          peerAvatar: userAvatar,
          peerUsername: userUsername,
          isVerified: isVerified,
        );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DirectChatScreen(
          peerId: conv.peerId,
          peerName: conv.peerName,
          peerAvatar: conv.peerAvatar,
          peerUsername: conv.peerUsername,
          isVerified: conv.isVerified,
          isOnline: true,
        ),
      ),
    );
  }

  static void _showFollowersOnlyModal(
    BuildContext context,
    WidgetRef ref, {
    required String userId,
    required String userName,
    required String userAvatar,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: LuxeColors.bgTop,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: LuxeColors.purple.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66100A2A),
              blurRadius: 24,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: LuxeColors.goldGradient,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        LuxeColors.gold.withValues(alpha: 0.2),
                        Colors.transparent,
                      ],
                    ),
                    border: Border.all(
                      color: LuxeColors.gold.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_person_rounded,
                    color: LuxeColors.gold,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Follow to Message $userName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '$userName has direct messaging set to "Followers Only". Follow them first to start a private conversation.',
                  style: const TextStyle(
                    color: LuxeColors.textDim,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(ctx),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: LuxeColors.panel.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: LuxeColors.purple.withValues(alpha: 0.3),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: LuxeColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          ref.read(followControllerProvider.notifier).sendFollowRequest(
                                userId,
                                targetName: userName,
                                targetAvatar: userAvatar,
                              );
                          openChat(context, ref,
                              userId: userId, userName: userName, userAvatar: userAvatar);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: LuxeDecor.goldButton(radius: 16),
                          alignment: Alignment.center,
                          child: const Text(
                            'Follow & Chat',
                            style: TextStyle(
                              color: Color(0xFF161200),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isIconOnly) {
      return SizedBox(
        width: height,
        height: height,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => openChat(
              context,
              ref,
              userId: userId,
              userName: userName,
              userAvatar: userAvatar,
              userUsername: userUsername,
              isVerified: isVerified,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: LuxeColors.panel.withValues(alpha: 0.45),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: LuxeColors.purple.withValues(alpha: 0.35),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: LuxeColors.purple.withValues(alpha: 0.1),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: LuxeColors.gold,
                  size: 19,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => openChat(
            context,
            ref,
            userId: userId,
            userName: userName,
            userAvatar: userAvatar,
            userUsername: userUsername,
            isVerified: isVerified,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  LuxeColors.panel.withValues(alpha: 0.6),
                  LuxeColors.panelDeep.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: LuxeColors.purple.withValues(alpha: 0.35),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: LuxeColors.purple.withValues(alpha: 0.12),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 15,
                  color: LuxeColors.gold,
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    'Message',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
