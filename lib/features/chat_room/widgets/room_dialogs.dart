import 'package:flutter/material.dart';

import '../../../core/theme/luxe_theme.dart';
import '../data/chat_room_data.dart';
import 'chat_room_common.dart';

/// Step 2: room preview with Join / Cancel.
class JoinRoomModal extends StatelessWidget {
  final ChatRoom room;
  final VoidCallback onJoin;
  final VoidCallback onCancel;

  const JoinRoomModal({super.key, required this.room, required this.onJoin, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return ChatModalCard(
      onDismiss: onCancel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: _CloseButton(onTap: onCancel),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              GoldRingAvatar(asset: room.avatar, radius: 44, ring: 3),
              Positioned(
                right: -4,
                bottom: 4,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LuxeColors.goldGradient,
                    border: Border.all(color: LuxeColors.bg, width: 2),
                  ),
                  child: const Icon(Icons.workspace_premium_rounded, color: kGoldInk, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  room.hostName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ),
              if (room.isVerified) ...[
                const SizedBox(width: 5),
                const Icon(Icons.verified_rounded, color: LuxeColors.gold, size: 17),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            room.tagline,
            textAlign: TextAlign.center,
            style: const TextStyle(color: LuxeColors.textMuted, fontSize: 13.5),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: GoldTagPill(text: room.tag, icon: room.tagIcon, fontSize: 12.5),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.people_alt_rounded, color: LuxeColors.textMuted, size: 16),
              const SizedBox(width: 4),
              Text(
                room.capacity,
                style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 22),
          ChatPillButton(label: 'Join', icon: room.isVideo ? Icons.videocam_rounded : Icons.mic_rounded, onTap: onJoin),
          const SizedBox(height: 12),
          ChatPillButton(label: 'Cancel', style: ChatButtonStyle.ghost, onTap: onCancel),
        ],
      ),
    );
  }
}

/// Step 4: "End Chat Room?" confirmation.
class EndRoomModal extends StatelessWidget {
  final VoidCallback onEnd;
  final VoidCallback onCancel;

  const EndRoomModal({super.key, required this.onEnd, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return ChatModalCard(
      onDismiss: onCancel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: LuxeColors.pink.withValues(alpha: 0.14),
              border: Border.all(color: LuxeColors.pink, width: 2),
              boxShadow: const [BoxShadow(color: Color(0x66FF2D78), blurRadius: 18, spreadRadius: 2)],
            ),
            child: const Icon(Icons.power_settings_new_rounded, color: LuxeColors.pink, size: 34),
          ),
          const SizedBox(height: 18),
          const Text(
            'End Chat Room?',
            style: TextStyle(color: Colors.white, fontSize: 21, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'All members will be removed\nand the room will end.',
            textAlign: TextAlign.center,
            style: TextStyle(color: LuxeColors.textMuted, fontSize: 13.5, height: 1.4),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ChatPillButton(label: 'Cancel', style: ChatButtonStyle.ghost, height: 44, onTap: onCancel),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChatPillButton(label: 'End Room', style: ChatButtonStyle.danger, height: 44, onTap: onEnd),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Host sees a speaker request and can accept (fills the Invite seat) or reject it.
void showJoinRequestDialog(
  BuildContext context, {
  required JoinRequest request,
  required VoidCallback onAccept,
  required VoidCallback onReject,
}) {
  showDialog(
    context: context,
    builder: (ctx) {
      void close(VoidCallback action) {
        Navigator.pop(ctx);
        action();
      }

      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: LuxePanel(
            radius: 26,
            borderColors: LuxeColors.goldToNeon,
            glow: 22,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: LuxeColors.gold.withValues(alpha: 0.16)),
                      child: const Icon(Icons.notifications_active_rounded, color: LuxeColors.gold, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Join Request (1)',
                        style: TextStyle(color: Colors.white, fontSize: 17.5, fontWeight: FontWeight.w900),
                      ),
                    ),
                    _CloseButton(onTap: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 16),
                LuxePanel(
                  radius: 16,
                  glow: 0,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      GoldRingAvatar(asset: request.avatar, radius: 22, ring: 2),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    request.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GoldTagPill(text: request.level, icon: '⭐', fontSize: 10),
                              ],
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'wants to join your room as speaker',
                              style: TextStyle(color: LuxeColors.textMuted, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ChatPillButton(
                        label: 'Reject',
                        style: ChatButtonStyle.ghost,
                        height: 44,
                        onTap: () => close(onReject),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChatPillButton(
                        label: 'Accept & Join',
                        icon: Icons.mic_rounded,
                        height: 44,
                        onTap: () => close(onAccept),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Tapping a seat: profile with Send Gift / Give Star / Mute.
void showSeatSheet(
  BuildContext context, {
  required ChatSeat seat,
  required VoidCallback onGift,
  required VoidCallback onStar,
  required VoidCallback onToggleMic,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      Widget action(IconData icon, String label, VoidCallback onTap) => Expanded(
        child: GestureDetector(
          onTap: () {
            Navigator.pop(ctx);
            onTap();
          },
          child: Column(
            children: [
              LuxeCircleButton(icon: icon, label: label, size: 50, gold: icon == Icons.card_giftcard_rounded),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(color: LuxeColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );

      return ChatSheetFrame(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GoldRingAvatar(asset: seat.avatar, radius: 36),
            const SizedBox(height: 10),
            Text(
              seat.name,
              style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              seat.isHost ? '👑 Room Host' : '🎙️ Audio Speaker',
              style: const TextStyle(color: LuxeColors.gold, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                action(Icons.card_giftcard_rounded, 'Send Gift', onGift),
                action(Icons.star_rounded, 'Give Star', onStar),
                action(
                  seat.micOn ? Icons.mic_off_rounded : Icons.mic_rounded,
                  seat.micOn ? 'Mute' : 'Unmute',
                  onToggleMic,
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

/// Room "More" menu: share, switch audio / video, rules.
void showRoomMoreMenu(
  BuildContext context, {
  required bool isVideo,
  required VoidCallback onShare,
  required VoidCallback onToggleMode,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      Widget item(IconData icon, String title, VoidCallback? onTap) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: LuxeColors.gold.withValues(alpha: 0.14), shape: BoxShape.circle),
          child: Icon(icon, color: LuxeColors.gold, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.w600),
        ),
        onTap: () {
          Navigator.pop(ctx);
          onTap?.call();
        },
      );

      return ChatSheetFrame(
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              item(Icons.share_rounded, 'Share Room', onShare),
              item(
                isVideo ? Icons.mic_rounded : Icons.videocam_rounded,
                isVideo ? 'Switch to Audio Mode' : 'Switch to Video Mode',
                onToggleMode,
              ),
              item(Icons.rule_rounded, 'Room Rules & Help', null),
            ],
          ),
        ),
      );
    },
  );
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Close',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), shape: BoxShape.circle),
          child: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
        ),
      ),
    );
  }
}
