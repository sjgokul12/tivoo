import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/luxe_theme.dart';
import '../../../core/widgets/tivoo_share_sheet.dart';
import '../../live_stream/presentation/widgets/user_profile_bottom_sheet.dart';
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
  String? hostName,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
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
                    Expanded(
                      child: Text(
                        hostName != null ? 'Host Approval ($hostName)' : 'Join Request (1)',
                        style: const TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.w900),
                      ),
                    ),
                    _CloseButton(onTap: () => close(onReject)),
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
                            Text(
                              request.name == 'You'
                                  ? (hostName != null
                                      ? 'wants to join $hostName\'s room as speaker'
                                      : 'wants to join the room as speaker')
                                  : 'wants to join your room as speaker',
                              style: const TextStyle(color: LuxeColors.textMuted, fontSize: 12),
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

/// Bottom sheet shown when user taps the "Requested" dock button while waiting for host approval.
void showRequestPendingSheet(
  BuildContext context, {
  required String hostName,
  required VoidCallback onCancel,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) => ChatSheetFrame(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFF9800).withValues(alpha: 0.16),
              border: Border.all(color: const Color(0xFFFF9800), width: 1.5),
            ),
            child: const Icon(Icons.hourglass_top_rounded, color: Color(0xFFFF9800), size: 28),
          ),
          const SizedBox(height: 14),
          const Text(
            'Join Request Pending',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            'Your request has been sent to host $hostName. Waiting for host approval to join the chatroom.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: LuxeColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ChatPillButton(
            label: 'Cancel Request',
            style: ChatButtonStyle.danger,
            height: 44,
            onTap: () {
              Navigator.pop(ctx);
              onCancel();
            },
          ),
          const SizedBox(height: 10),
          ChatPillButton(
            label: 'Keep Waiting',
            style: ChatButtonStyle.ghost,
            height: 44,
            onTap: () => Navigator.pop(ctx),
          ),
        ],
      ),
    ),
  );
}

/// On-screen approval message shown to the user when the host approves their join request.
void showRequestApprovedDialog(
  BuildContext context, {
  required String hostName,
  required String hostAvatar,
  required VoidCallback onParticipate,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      void close() {
        Navigator.pop(ctx);
        onParticipate();
      }

      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: LuxePanel(
            radius: 26,
            borderColors: LuxeColors.goldToNeon,
            glow: 24,
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    GoldRingAvatar(asset: hostAvatar, radius: 36, ring: 3),
                    Positioned(
                      right: -4,
                      bottom: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF00E676),
                          boxShadow: [BoxShadow(color: Color(0x6600E676), blurRadius: 8)],
                        ),
                        child: const Icon(Icons.check_rounded, color: Colors.black, size: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Request Approved! 🎉',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    style: const TextStyle(color: LuxeColors.textMuted, fontSize: 13.5, height: 1.4),
                    children: [
                      TextSpan(
                        text: hostName,
                        style: const TextStyle(color: LuxeColors.gold, fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(
                        text: ' approved your request to join the chatroom. You have been assigned a speaker seat and can now participate!',
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1644),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: LuxeColors.violet.withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.mic_rounded, color: Color(0xFF00E676), size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Speaker Seat #9 Active',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                ChatPillButton(
                  label: 'Participate in Chatroom',
                  icon: Icons.campaign_rounded,
                  height: 46,
                  onTap: close,
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Tapping a seat: profile with Follow / View profile / Give stars / Mute / Remove.
/// Remove option is exclusively available to the host who created the room.
void showSeatSheet(
  BuildContext context, {
  required ChatSeat seat,
  required VoidCallback onGift,
  required VoidCallback onStar,
  required VoidCallback onToggleMic,
  bool isFollowing = false,
  bool isRequested = false,
  VoidCallback? onFollow,
  VoidCallback? onViewProfile,
  bool isHostWhoCreated = false,
  VoidCallback? onRemove,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      Widget action({
        IconData? icon,
        Widget? customIcon,
        required String label,
        required VoidCallback onTap,
        Color? iconColor,
      }) => Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            Navigator.pop(ctx);
            onTap();
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LuxeCircleButton(
                icon: icon,
                label: label,
                size: 46,
                gold: iconColor == null,
                iconColor: iconColor ?? const Color(0xFFFFD700),
                child: customIcon,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: iconColor != null ? iconColor.withValues(alpha: 0.9) : LuxeColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      );

      return ChatSheetFrame(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (seat.name.toLowerCase() != 'you')
                  action(
                    icon: isFollowing
                        ? Icons.check_circle_rounded
                        : (isRequested ? Icons.schedule_rounded : Icons.person_add_alt_1_rounded),
                    label: isFollowing ? 'Following' : (isRequested ? 'Requested' : 'Follow'),
                    iconColor: isFollowing
                        ? const Color(0xFF00E676)
                        : (isRequested ? const Color(0xFFFFD700) : null),
                    onTap: onFollow ?? () => showChatToast(context, 'Following ${seat.name} 🎉'),
                  ),
                action(
                  icon: Icons.account_circle_rounded,
                  label: 'View profile',
                  onTap: onViewProfile ??
                      () {
                        Navigator.of(context).pop();
                        UserProfileBottomSheet.show(
                          context,
                          userName: seat.name,
                          avatarAsset: seat.avatar,
                          userId: 'user_${seat.name.toLowerCase().replaceAll(' ', '_')}',
                        );
                      },
                ),
                action(
                  customIcon: SizedBox(
                    width: 24,
                    height: 24,
                    child: Image.asset(
                      AppAssets.goldenStar,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.star_rounded,
                        color: Color(0xFFFFD700),
                        size: 24,
                      ),
                    ),
                  ),
                  label: 'Give stars',
                  onTap: onGift,
                ),
                action(
                  icon: seat.micOn ? Icons.mic_off_rounded : Icons.mic_rounded,
                  label: seat.micOn ? 'Mute' : 'Unmute',
                  onTap: onToggleMic,
                ),
                // Only the host who created the chatroom can see and use the Remove option
                if (isHostWhoCreated && !seat.isHost)
                  action(
                    icon: Icons.person_remove_rounded,
                    label: 'Remove',
                    iconColor: const Color(0xFFFF5252),
                    onTap: onRemove ?? () {},
                  ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

/// Room "More" menu: share, switch audio / video, rules, and review requests.
void showRoomMoreMenu(
  BuildContext context, {
  required bool isVideo,
  required VoidCallback onShare,
  required VoidCallback onToggleMode,
  int pendingRequestsCount = 0,
  VoidCallback? onReviewRequests,
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
              if (pendingRequestsCount > 0 && onReviewRequests != null)
                item(Icons.notifications_active_rounded, 'Join Requests ($pendingRequestsCount)', onReviewRequests),
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

/// Modal bottom sheet to invite friends into the chat room.
void showInviteFriendsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _InviteFriendsSheet(),
  );
}

class _InviteFriendsSheet extends StatefulWidget {
  const _InviteFriendsSheet();

  @override
  State<_InviteFriendsSheet> createState() => _InviteFriendsSheetState();
}

class _InviteFriendItem {
  final String name;
  final String avatar;
  final String status;
  bool invited = false;

  _InviteFriendItem({
    required this.name,
    required this.avatar,
    required this.status,
  });
}

class _InviteFriendsSheetState extends State<_InviteFriendsSheet> {
  final _searchController = TextEditingController();
  late final List<_InviteFriendItem> _friends = [
    _InviteFriendItem(name: 'Rahul_Kumar', avatar: AppAssets.avatarKarthik, status: 'Online 🟢'),
    _InviteFriendItem(name: 'Priya_Sweet', avatar: AppAssets.avatarPriya, status: 'Active 2m ago'),
    _InviteFriendItem(name: 'Sneha_R', avatar: AppAssets.avatarSneha, status: 'Online 🟢'),
    _InviteFriendItem(name: 'Neha_Angel', avatar: AppAssets.avatarNeha, status: 'Active 10m ago'),
    _InviteFriendItem(name: 'Vicky_Hero', avatar: AppAssets.avatarVicky, status: 'Online 🟢'),
    _InviteFriendItem(name: 'Saran_King', avatar: AppAssets.avatarSaran, status: 'Active 1h ago'),
    _InviteFriendItem(name: 'Meena_Cutie', avatar: AppAssets.avatarMeena, status: 'Online 🟢'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? _friends
        : _friends.where((f) => f.name.toLowerCase().contains(query)).toList();

    return ChatSheetFrame(
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.group_add_rounded, color: LuxeColors.gold, size: 22),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Invite Friends',
                        style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Bring your friends into the room',
                        style: TextStyle(color: LuxeColors.textDim, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _CloseButton(onTap: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: LuxeColors.gold, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      cursorColor: LuxeColors.gold,
                      decoration: const InputDecoration(
                        hintText: 'Search friends...',
                        hintStyle: TextStyle(color: LuxeColors.textDim, fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: filtered.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No friends found',
                          style: TextStyle(color: LuxeColors.textDim, fontSize: 13),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final item = filtered[i];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.asset(
                                  item.avatar,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Container(
                                    width: 40,
                                    height: 40,
                                    color: LuxeColors.panel,
                                    child: const Icon(Icons.person_rounded, color: Colors.white30, size: 22),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.status,
                                      style: const TextStyle(color: LuxeColors.textDim, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: item.invited
                                    ? null
                                    : () {
                                        setState(() => item.invited = true);
                                        showChatToast(context, 'Invite sent to ${item.name} 📨');
                                      },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: item.invited
                                      ? BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(14),
                                        )
                                      : LuxeDecor.goldButton(radius: 14),
                                  child: Text(
                                    item.invited ? 'Invited ✓' : 'Invite',
                                    style: TextStyle(
                                      color: item.invited ? Colors.white60 : kGoldInk,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 14),
            ChatPillButton(
              label: 'Share Room Link',
              icon: Icons.share_rounded,
              style: ChatButtonStyle.ghost,
              height: 42,
              onTap: () {
                Navigator.pop(context);
                TivooShareSheet.show(
                  context,
                  title: 'Share Chat Room',
                  subtitle: 'Invite friends to the room',
                  shareUrl: 'https://tivoo.app/chatroom/party',
                  shareText: 'Join our room party on Tivoo! https://tivoo.app/chatroom/party',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
