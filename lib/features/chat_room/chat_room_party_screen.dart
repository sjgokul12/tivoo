import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/luxe_theme.dart';
import '../../core/widgets/comment_action_sheet.dart';
import '../home/domain/models/live_stream_card_model.dart';
import '../home/presentation/widgets/streamer_id_profile_sheet.dart';
import '../live_stream/domain/models/gift_item.dart';
import '../live_stream/domain/models/live_comment.dart';
import '../live_stream/presentation/widgets/active_gift_animation_overlay.dart';
import '../live_stream/presentation/widgets/floating_hearts_overlay.dart';
import '../live_stream/presentation/widgets/floating_stars_overlay.dart';
import '../live_stream/presentation/widgets/gift_bottom_sheet.dart';
import '../profile/presentation/controllers/follow_controller.dart';
import '../profile/presentation/widgets/instagram_follow_actions_sheet.dart';
import '../gift/gift_balance_details_dialog.dart';
import 'data/chat_room_data.dart';
import 'widgets/chat_room_common.dart';
import 'widgets/create_room_sheet.dart';
import 'widgets/room_dialogs.dart';
import 'widgets/room_ended_view.dart';
import 'widgets/room_list_view.dart';
import 'widgets/room_stage_view.dart';
import '../../core/widgets/tivoo_share_sheet.dart';

/// Chat room flow:
/// 1 room list → 2 join preview → 3 inside the room → 4 "End room?" → 5 room ended summary.
/// The host can also create a room (straight to 3) and accept / reject speaker requests.
class ChatRoomPartyScreen extends ConsumerStatefulWidget {
  final int initialStage;
  final VoidCallback? onBack;

  const ChatRoomPartyScreen({super.key, this.initialStage = 1, this.onBack});

  @override
  ConsumerState<ChatRoomPartyScreen> createState() => _ChatRoomPartyScreenState();
}

class _ChatRoomPartyScreenState extends ConsumerState<ChatRoomPartyScreen> {
  final _giftKey = GlobalKey<ActiveGiftAnimationOverlayState>();
  final _heartsKey = GlobalKey<FloatingHeartsOverlayState>();
  final _starsKey = GlobalKey<FloatingStarsOverlayState>();
  final List<GlobalKey> _seatKeys = List.generate(9, (_) => GlobalKey());

  late int _stage = widget.initialStage.clamp(1, 5);
  final List<ChatRoom> _rooms = [...ChatRoomData.rooms];
  late ChatRoom _room = _rooms.first;
  final List<ChatSeat?> _seats = [...ChatRoomData.seats];

  late bool _isVideo = _room.isVideo;
  bool _micMuted = false;
  bool _soundMuted = false;
  bool _isJoined = false;
  bool _isJoinRequested = false;
  bool _isCreatedByMe = false;
  int _selectedSeatIndex = 0;
  int _totalStars = 12560;
  Timer? _hostResponseTimer;
  final List<JoinRequest> _pendingRequests = [];

  bool _isCommentsPaused = false;
  Timer? _commentSimulationTimer;
  int _simulationIndex = 0;

  static final List<({String user, String avatar, String msg, bool isGift})> _simulatedRoomComments = [
    (user: 'Sneha', avatar: AppAssets.avatarSneha, msg: 'Loving the vibe in this room! ✨', isGift: false),
    (user: 'Karthik', avatar: AppAssets.avatarKarthik, msg: 'sent a Star ⭐ to Host', isGift: true),
    (user: 'Neha', avatar: AppAssets.avatarNeha, msg: 'Welcome everyone! 🎉', isGift: false),
    (user: 'Arun', avatar: AppAssets.avatarArun, msg: 'The audio is super crisp! 🎧', isGift: false),
    (user: 'Vicky', avatar: AppAssets.avatarVicky, msg: 'sent a Rose 🌹 x5', isGift: true),
    (user: 'Diya', avatar: AppAssets.avatarDiya, msg: 'Great discussion tonight 🌟', isGift: false),
    (user: 'Meena', avatar: AppAssets.avatarMeena, msg: 'Hey all! Happy to be here 💖', isGift: false),
    (user: 'Lucas', avatar: AppAssets.status3, msg: 'Sing a song please! 🎵🔥', isGift: false),
    (user: 'Aurora_X', avatar: AppAssets.status4, msg: 'sent a Crown 👑 to party', isGift: true),
    (user: 'Rahul', avatar: AppAssets.avatarKarthik, msg: 'Good evening everyone ✨', isGift: false),
    (user: 'Sam_99', avatar: AppAssets.status5, msg: 'Turn up the music 🎶', isGift: false),
    (user: 'Chloe', avatar: AppAssets.status2, msg: 'sent a Diamond 💎 x100', isGift: true),
  ];

  late final List<LiveComment> _messages = [
    _comment('User123', AppAssets.avatarArun, 'So amazing! 👏', ago: 40),
    _comment('Queen', AppAssets.avatarSneha, 'Super all ❤️🔥', ago: 30),
    _comment('Kavin', AppAssets.avatarKarthik, 'sent a Star ⭐ to Diya', ago: 18, gift: true),
    _comment('Anitha', AppAssets.avatarNeha, 'Happy evening everyone! ✨', ago: 8),
  ];

  Timer? _ambientHearts;

  @override
  void initState() {
    super.initState();
    _ambientHearts = Timer.periodic(const Duration(seconds: 6), (_) {
      if (mounted && _stage == 3) _heartsKey.currentState?.addHeart();
    });
    _startCommentSimulation();
  }

  void _startCommentSimulation() {
    _commentSimulationTimer?.cancel();
    _commentSimulationTimer = Timer.periodic(const Duration(milliseconds: 2800), (_) {
      if (!mounted || _isCommentsPaused || _stage != 3) return;
      final item = _simulatedRoomComments[_simulationIndex % _simulatedRoomComments.length];
      _simulationIndex++;
      setState(() {
        _messages.add(
          _comment(item.user, item.avatar, item.msg, gift: item.isGift),
        );
        if (_messages.length > 50) {
          _messages.removeAt(0);
        }
      });
      if (_simulationIndex % 4 == 0) {
        _heartsKey.currentState?.addHeart();
      }
    });
  }

  @override
  void dispose() {
    _ambientHearts?.cancel();
    _commentSimulationTimer?.cancel();
    _hostResponseTimer?.cancel();
    super.dispose();
  }

  static LiveComment _comment(String user, String avatar, String message, {int ago = 0, bool gift = false}) {
    return LiveComment(
      id: 'c_${DateTime.now().microsecondsSinceEpoch}_$user',
      userName: user,
      userAssetPath: avatar,
      message: message,
      type: gift ? LiveCommentType.gift : LiveCommentType.chat,
      timestamp: DateTime.now().subtract(Duration(seconds: ago)),
    );
  }

  void _setStage(int stage) => setState(() => _stage = stage);

  void _exit() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _addMessage(String message, {bool gift = false}) {
    setState(() => _messages.add(_comment('You', AppAssets.avatarDiya, message, gift: gift)));
  }

  // --- Room list -------------------------------------------------------------

  /// Directly enter room in spectator/watch mode (no pre-join modal)
  void _openRoom(ChatRoom room) {
    _hostResponseTimer?.cancel();
    setState(() {
      _room = room;
      _isVideo = room.isVideo;
      _isJoined = false;
      _isJoinRequested = false;
      _isCreatedByMe = false;
      _pendingRequests.clear();
      _selectedSeatIndex = 0;
      _stage = 3;
    });
  }

  void _createRoom() {
    CreateRoomSheet.show(context, (room) {
      _hostResponseTimer?.cancel();
      setState(() {
        _rooms.insert(0, room);
        _room = room;
        _isVideo = room.isVideo;
        _isJoined = true;
        _isJoinRequested = false;
        _isCreatedByMe = true;
        _seats[0] = const ChatSeat(
          name: 'You',
          avatar: AppAssets.avatarDiya,
          isHost: true,
          micOn: true,
        );
        _pendingRequests.clear();
        _stage = 3;
      });
      showChatToast(context, '🎉 Chat Room Created! You are the Host.');

      // Simulate a speaker request arriving for the host
      _hostResponseTimer = Timer(const Duration(seconds: 4), () {
        if (!mounted || _stage != 3 || !_isJoined) return;
        setState(() {
          _pendingRequests.add(ChatRoomData.pendingRequest);
        });
        showChatToast(context, '🔔 ${ChatRoomData.pendingRequest.name} requested to join the chatroom!');
      });
    });
  }

  // --- Inside the room -------------------------------------------------------

  /// When the user clicks Join in spectator mode: sends request to host.
  /// Only when host approves, the user is joined.
  void _onJoinConversation() {
    if (_isJoined) return;

    if (_isJoinRequested) {
      showRequestPendingSheet(
        context,
        hostName: _room.hostName,
        onCancel: _cancelJoinRequest,
      );
      return;
    }

    setState(() {
      _isJoinRequested = true;
      _messages.add(_comment('You', AppAssets.avatarDiya, 'sent a request to join the room ⏳', gift: false));
    });
    showChatToast(context, '📨 Request sent to host ${_room.hostName}! Waiting for approval...');

    const userRequest = JoinRequest(
      name: 'You',
      avatar: AppAssets.avatarDiya,
      level: 'Lv.12',
    );

    // Host reviews and approves request after a brief realistic pause
    _hostResponseTimer?.cancel();
    _hostResponseTimer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted || !_isJoinRequested || _stage != 3) return;

      // Host approves the request: user is seated and ready to participate
      _approveJoinRequest(userRequest);

      // Present on-screen approval message confirming host accepted
      showRequestApprovedDialog(
        context,
        hostName: _room.hostName,
        hostAvatar: _room.avatar,
        onParticipate: () {
          // User clicks Participate to start active conversation
        },
      );
    });
  }

  void _approveJoinRequest(JoinRequest request) {
    setState(() {
      _pendingRequests.removeWhere((r) => r.name == request.name);
      if (request.name == 'You') {
        _isJoinRequested = false;
        _isJoined = true;

        final emptyIndex = _seats.indexOf(null);
        if (emptyIndex != -1) {
          _seats[emptyIndex] = const ChatSeat(
            name: 'You',
            avatar: AppAssets.avatarDiya,
            isHost: false,
            micOn: true,
          );
          _selectedSeatIndex = emptyIndex;
        }

        _room = _room.copyWith(members: _room.members + 1);
        _messages.add(_comment(_room.hostName, _room.avatar, 'approved your request to join 🎉', gift: false));
      } else {
        final emptyIndex = _seats.indexOf(null);
        if (emptyIndex != -1) {
          _seats[emptyIndex] = ChatSeat(
            name: request.name,
            avatar: request.avatar,
            isHost: false,
            micOn: true,
          );
        }
        _room = _room.copyWith(members: _room.members + 1);
        _messages.add(_comment(_room.hostName, _room.avatar, 'approved ${request.name} to join 🎉', gift: false));
      }
    });

    _heartsKey.currentState?.addHeart();
    _starsKey.currentState?.addStars(5);
    showChatToast(
      context,
      request.name == 'You'
          ? '🎉 Host approved! You joined the chatroom.'
          : '🎉 ${request.name} joined as speaker!',
    );
  }

  void _rejectJoinRequest(JoinRequest request) {
    setState(() {
      _pendingRequests.removeWhere((r) => r.name == request.name);
      if (request.name == 'You') {
        _isJoinRequested = false;
        _messages.add(_comment(_room.hostName, _room.avatar, 'declined your join request', gift: false));
      }
    });
    showChatToast(
      context,
      request.name == 'You'
          ? '❌ Host ${_room.hostName} declined your join request.'
          : 'Declined ${request.name}\'s request.',
    );
  }

  void _cancelJoinRequest() {
    _hostResponseTimer?.cancel();
    setState(() {
      _isJoinRequested = false;
    });
    showChatToast(context, 'Join request cancelled');
  }

  void _reviewHostJoinRequest(JoinRequest request) {
    showJoinRequestDialog(
      context,
      hostName: _room.hostName,
      request: request,
      onAccept: () => _approveJoinRequest(request),
      onReject: () => _rejectJoinRequest(request),
    );
  }

  void _onSeatSelected(int index) {
    if (index < 0 || index >= _seats.length) return;
    final seat = _seats[index];
    if (seat == null) return;
    setState(() => _selectedSeatIndex = index);
    if (seat.isHost) {
      _openHostProfile();
    } else {
      _openUserProfile(seat.name, seat.avatar);
    }
  }

  bool get _isHostWhoCreatedRoom =>
      _isCreatedByMe ||
      _room.hostName.toLowerCase().startsWith('you');

  void _handleFollowUser(String userId, String name, String avatar) {
    final followMap = ref.read(followControllerProvider);
    final rel = followMap[userId] ??
        ref.read(followControllerProvider.notifier).getRelationship(
              userId,
              defaultName: name,
              defaultAvatar: avatar,
              initialFollowers: 14200,
            );

    if (rel.isNotFollowing) {
      ref.read(followControllerProvider.notifier).sendFollowRequest(
            userId,
            targetName: name,
            targetAvatar: avatar,
            initialFollowers: 14200,
            onStatusNotify: (msg) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(msg),
                  backgroundColor: const Color(0xFF192233),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          );
    } else if (rel.isRequested) {
      InstagramFollowActionsSheet.showRequestedSheet(
        context,
        relationship: rel,
        streamerId: userId,
        onCancelRequest: () {
          ref.read(followControllerProvider.notifier).cancelFollowRequest(
                userId,
                onStatusNotify: (msg) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(msg),
                      backgroundColor: const Color(0xFF192233),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
        },
      );
    } else if (rel.isFollowingOrMutual) {
      InstagramFollowActionsSheet.show(
        context,
        relationship: rel,
        streamerId: userId,
      );
    } else if (rel.isBlocked) {
      ref.read(followControllerProvider.notifier).unblockUser(
            userId,
            onStatusNotify: (msg) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(msg),
                  backgroundColor: const Color(0xFF192233),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          );
    }
  }

  void _openHostProfile() {
    final hostId = 'chatroom_host_${_room.hostName.toLowerCase().replaceAll(' ', '_')}';
    final rel = ref.read(followControllerProvider)[hostId];
    final streamModel = LiveStreamCardModel(
      id: hostId,
      userId: _room.hostName.toLowerCase().replaceAll(' ', '_'),
      streamerName: _room.hostName,
      streamerBio: '🎙️ Chat Room Host • ${_room.tag} • Good Vibes Only ✨',
      streamerAssetPath: _room.avatar,
      viewersCount: '${_room.members}',
      diamondsCount: '89.5K',
      category: _room.tag,
      isFollowing: rel?.isFollowingOrMutual ?? false,
    );
    StreamerIdProfileSheet.show(context, stream: streamModel);
  }

  void _openUserProfile(String name, String? avatar) {
    final userId = 'chatroom_user_${name.toLowerCase().replaceAll(' ', '_')}';
    final rel = ref.read(followControllerProvider)[userId];
    final streamModel = LiveStreamCardModel(
      id: userId,
      userId: name.toLowerCase().replaceAll(' ', '_'),
      streamerName: name,
      streamerBio: '🎙️ Chat Room Speaker • Good Vibes Only ✨',
      streamerAssetPath: avatar ?? AppAssets.avatarMeena,
      viewersCount: '1.2K',
      diamondsCount: '45.2K',
      category: 'Chat Room',
      isFollowing: rel?.isFollowingOrMutual ?? false,
    );
    StreamerIdProfileSheet.show(context, stream: streamModel);
  }

  void _onSeatLongPress(int index) {
    final seat = _seats[index];
    if (seat == null) return;
    final seatId = 'seat_${seat.name.toLowerCase().replaceAll(' ', '_')}';
    final followMap = ref.read(followControllerProvider);
    final seatRel = followMap[seatId] ??
        ref.read(followControllerProvider.notifier).getRelationship(
              seatId,
              defaultName: seat.name,
              defaultAvatar: seat.avatar,
              initialFollowers: 14200,
            );

    showSeatSheet(
      context,
      seat: seat,
      isFollowing: seatRel.isFollowingOrMutual,
      isRequested: seatRel.isRequested,
      onGift: () => _openGifts(initialRecipient: seat.name),
      onStar: () => _openGifts(initialRecipient: seat.name),
      onToggleMic: () => setState(() => _seats[index] = seat.copyWith(micOn: !seat.micOn)),
      onFollow: () => _handleFollowUser(seatId, seat.name, seat.avatar),
      onViewProfile: () => _openUserProfile(seat.name, seat.avatar),
      isHostWhoCreated: _isHostWhoCreatedRoom,
      onRemove: () => _executeRemoval(index, seat),
    );
  }

  void _executeRemoval(int index, ChatSeat seat) {
    if (!_isHostWhoCreatedRoom) {
      showChatToast(context, 'Only the host who created the room can remove participants.');
      return;
    }
    setState(() {
      _seats[index] = null;
      _room = _room.copyWith(members: (_room.members - 1).clamp(1, 999));
      _messages.add(_comment('System', AppAssets.avatarDiya, '${seat.name} was removed from the room by the host'));
    });
    showChatToast(context, '${seat.name} has been removed from the room');
  }

  void _onInvite() {
    if (!_isJoined) {
      if (_isJoinRequested) {
        showRequestPendingSheet(
          context,
          hostName: _room.hostName,
          onCancel: _cancelJoinRequest,
        );
      } else {
        _onJoinConversation();
      }
      return;
    }
    showInviteFriendsSheet(context);
  }

  void _onSeatTap(int index) {
    _onSeatSelected(index);
  }

  void _sendStar() {
    final seat = (_selectedSeatIndex >= 0 && _selectedSeatIndex < _seats.length)
        ? _seats[_selectedSeatIndex]
        : null;
    final recipient = seat?.name ?? _seats.first?.name ?? 'Diya';
    _starsKey.currentState?.addStars(3);
    _totalStars += 10;
    _addMessage('sent a Star ⭐ to $recipient', gift: true);
  }

  void _openGifts({String? initialRecipient}) {
    final selectedSeat = (_selectedSeatIndex >= 0 && _selectedSeatIndex < _seats.length)
        ? _seats[_selectedSeatIndex]
        : null;
    final defaultRecipient = initialRecipient ?? selectedSeat?.name ?? (_seats.first?.name ?? 'Diya');

    final activeRecipients = [
      ..._seats.whereType<ChatSeat>().map((s) => s.name),
      'All',
    ];

    GiftBottomSheet.show(
      context,
      (GiftItem gift) => _sendChatRoomGift(gift, 1, defaultRecipient),
      recipients: activeRecipients,
      initialRecipient: defaultRecipient,
      onGiftWithQuantitySelected: (gift, qty) => _sendChatRoomGift(gift, qty, defaultRecipient),
      onGiftWithRecipientSelected: (gift, qty, recipient) => _sendChatRoomGift(gift, qty, recipient),
    );
  }

  void _sendChatRoomGift(GiftItem gift, int quantity, String recipient) {
    int seatIndex = _seats.indexWhere((s) => s != null && s.name.toLowerCase() == recipient.toLowerCase());
    Offset? targetPosition;
    if (seatIndex != -1 && seatIndex < _seatKeys.length) {
      final box = _seatKeys[seatIndex].currentContext?.findRenderObject() as RenderBox?;
      if (box != null && box.hasSize) {
        targetPosition = box.localToGlobal(box.size.center(Offset.zero));
      }
    }
    final toLeft = seatIndex == -1 ? true : (seatIndex % 3 == 0);
    final totalCost = gift.diamonds * quantity;

    _giftKey.currentState?.playGift(
      gift,
      senderName: 'You',
      count: quantity,
      toLeft: toLeft,
      recipient: recipient,
      target: targetPosition,
      onComplete: () {
        if (!mounted) return;
        GiftBalanceDetailsDialog.show(
          context: context,
          gift: gift,
          quantity: quantity,
          recipient: recipient,
          deductedStars: totalCost,
          onSendMore: () => _openGifts(initialRecipient: recipient),
        );
      },
    );

    _addMessage('sent ${gift.name} ${gift.icon} x$quantity to $recipient', gift: true);
    _heartsKey.currentState?.addHeart();
  }

  void _openMore() {
    showRoomMoreMenu(
      context,
      isVideo: _isVideo,
      pendingRequestsCount: _pendingRequests.length,
      onReviewRequests: _pendingRequests.isNotEmpty
          ? () => _reviewHostJoinRequest(_pendingRequests.first)
          : null,
      onShare: () {
        TivooShareSheet.show(
          context,
          title: 'Share Chat Room',
          subtitle: 'Join ${_room.hostName}\'s room party',
          shareUrl: 'https://tivoo.app/chatroom/party',
          shareText: 'Join our room party on Tivoo! https://tivoo.app/chatroom/party',
        );
      },
      onToggleMode: () => setState(() => _isVideo = !_isVideo),
    );
  }

  void _toggleMic() {
    setState(() => _micMuted = !_micMuted);
    showChatToast(context, _micMuted ? 'Mic Muted 🔇' : 'Mic Active 🎙️');
  }

  // --- Build -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final hostId = 'chatroom_host_${_room.hostName.toLowerCase().replaceAll(' ', '_')}';
    final followMap = ref.watch(followControllerProvider);
    final hostRel = followMap[hostId] ??
        ref.read(followControllerProvider.notifier).getRelationship(
              hostId,
              defaultName: _room.hostName,
              defaultAvatar: _room.avatar,
              initialFollowers: 85200,
            );

    final Widget page = switch (_stage) {
      1 || 2 => RoomListView(rooms: _rooms, onBack: _exit, onJoin: _openRoom, onCreate: _createRoom),
      5 => RoomEndedView(room: _room, totalStars: _totalStars, onHome: _exit),
      _ => RoomStageView(
        room: _room,
        seats: _seats,
        seatKeys: _seatKeys,
        messages: _messages,
        isVideo: _isVideo,
        micMuted: _micMuted,
        soundMuted: _soundMuted,
        isJoined: _isJoined,
        isJoinRequested: _isJoinRequested,
        pendingRequestsCount: _pendingRequests.length,
        selectedSeatIndex: _selectedSeatIndex,
        isHostFollowing: hostRel.isFollowingOrMutual,
        isHostRequested: hostRel.isRequested,
        onHostFollowTap: () => _handleFollowUser(hostId, _room.hostName, _room.avatar),
        onHostProfileTap: _openHostProfile,
        onCommentTap: (comment) => _openUserProfile(comment.userName, comment.userAssetPath),
        onCommentLongPress: (comment) {
          CommentActionSheet.show(
            context,
            comment: comment,
            onPause: () {
              if (mounted) setState(() => _isCommentsPaused = true);
            },
            onResume: () {
              if (mounted) setState(() => _isCommentsPaused = false);
            },
            onReported: () {
              if (mounted) {
                setState(() {
                  final idx = _messages.indexWhere((m) => m.id == comment.id);
                  if (idx != -1) {
                    _messages[idx] = _messages[idx].copyWith(
                      message: 'This comment has been reported',
                      isReported: true,
                    );
                  }
                });
              }
            },
            onBlocked: () {
              if (mounted) {
                setState(() => _messages.removeWhere((m) => m.userName == comment.userName));
              }
            },
          );
        },
        onJoinConversation: _onJoinConversation,
        onCancelJoinRequest: _cancelJoinRequest,
        onReviewRequests: _pendingRequests.isNotEmpty
            ? () => _reviewHostJoinRequest(_pendingRequests.first)
            : null,
        onSeatSelected: _onSeatSelected,
        onSeatLongPress: _onSeatLongPress,
        onBack: _exit,
        onLeave: () => _setStage(4),
        onMore: _openMore,
        onSeatTap: _onSeatTap,
        onInvite: _onInvite,
        onMic: _toggleMic,
        onSound: () => setState(() => _soundMuted = !_soundMuted),
        onGift: _openGifts,
        onStar: _sendStar,
        onSend: _addMessage,
      ),
    };

    return ActiveGiftAnimationOverlay(
      key: _giftKey,
      child: FloatingStarsOverlay(
        key: _starsKey,
        child: FloatingHeartsOverlay(
          key: _heartsKey,
          child: Scaffold(
            backgroundColor: LuxeColors.bg,
            resizeToAvoidBottomInset: false,
            body: Stack(
              fit: StackFit.expand,
              children: [
                const LuxeBackdrop(),
                SafeArea(child: page),
                if (_stage == 4) EndRoomModal(onEnd: () => _setStage(5), onCancel: () => _setStage(3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
