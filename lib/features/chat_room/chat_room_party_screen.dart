import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/luxe_theme.dart';
import '../live_stream/domain/models/gift_item.dart';
import '../live_stream/domain/models/live_comment.dart';
import '../live_stream/presentation/widgets/active_gift_animation_overlay.dart';
import '../live_stream/presentation/widgets/floating_hearts_overlay.dart';
import '../live_stream/presentation/widgets/floating_stars_overlay.dart';
import '../live_stream/presentation/widgets/gift_bottom_sheet.dart';
import 'data/chat_room_data.dart';
import 'widgets/chat_room_common.dart';
import 'widgets/create_room_sheet.dart';
import 'widgets/room_dialogs.dart';
import 'widgets/room_ended_view.dart';
import 'widgets/room_list_view.dart';
import 'widgets/room_stage_view.dart';

/// Chat room flow:
/// 1 room list → 2 join preview → 3 inside the room → 4 "End room?" → 5 room ended summary.
/// The host can also create a room (straight to 3) and accept / reject speaker requests.
class ChatRoomPartyScreen extends StatefulWidget {
  final int initialStage;
  final VoidCallback? onBack;

  const ChatRoomPartyScreen({super.key, this.initialStage = 1, this.onBack});

  @override
  State<ChatRoomPartyScreen> createState() => _ChatRoomPartyScreenState();
}

class _ChatRoomPartyScreenState extends State<ChatRoomPartyScreen> {
  final _giftKey = GlobalKey<ActiveGiftAnimationOverlayState>();
  final _heartsKey = GlobalKey<FloatingHeartsOverlayState>();
  final _starsKey = GlobalKey<FloatingStarsOverlayState>();

  late int _stage = widget.initialStage.clamp(1, 5);
  final List<ChatRoom> _rooms = [...ChatRoomData.rooms];
  late ChatRoom _room = _rooms.first;
  final List<ChatSeat?> _seats = [...ChatRoomData.seats];
  JoinRequest? _pendingRequest = ChatRoomData.pendingRequest;

  late bool _isVideo = _room.isVideo;
  bool _micMuted = false;
  bool _soundMuted = false;
  int _totalStars = 12560;

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
  }

  @override
  void dispose() {
    _ambientHearts?.cancel();
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

  void _openJoin(ChatRoom room) {
    setState(() {
      _room = room;
      _isVideo = room.isVideo;
      _stage = 2;
    });
  }

  void _createRoom() {
    CreateRoomSheet.show(context, (room) {
      setState(() {
        _rooms.insert(0, room);
        _room = room;
        _isVideo = room.isVideo;
        _stage = 3;
      });
      showChatToast(context, '🎉 Chat Room Created! You are the Host.');
    });
  }

  // --- Inside the room -------------------------------------------------------

  void _onInvite() {
    final request = _pendingRequest;
    if (request == null) {
      showChatToast(context, 'Invite link copied! 🔗');
      return;
    }
    showJoinRequestDialog(
      context,
      request: request,
      onAccept: () {
        setState(() {
          _seats[8] = ChatSeat(name: request.name, avatar: request.avatar);
          _room = _room.copyWith(members: ChatRoom.seatCount);
          _pendingRequest = null;
        });
        _heartsKey.currentState?.addHeart();
        _starsKey.currentState?.addStars(4);
        showChatToast(context, '🎉 Accepted! ${request.name} joined audio seat 9.');
      },
      onReject: () {
        setState(() => _pendingRequest = null);
        showChatToast(context, '❌ Join request rejected. User stays as listener.');
      },
    );
  }

  void _onSeatTap(int index) {
    final seat = _seats[index];
    if (seat == null) return;
    showSeatSheet(
      context,
      seat: seat,
      onGift: _openGifts,
      onStar: _sendStar,
      onToggleMic: () => setState(() => _seats[index] = seat.copyWith(micOn: !seat.micOn)),
    );
  }

  void _sendStar() {
    _starsKey.currentState?.addStars(3);
    _totalStars += 10;
    _addMessage('sent a Star ⭐ to Diya', gift: true);
  }

  void _openGifts() {
    GiftBottomSheet.show(
      context,
      (GiftItem gift) {
        _giftKey.currentState?.playGift(gift);
        _addMessage('sent a ${gift.name} 🎁 to Diya', gift: true);
      },
      recipients: const ['Diya', 'Arun', 'Sneha', 'Karthik', 'All'],
      initialRecipient: 'Diya',
    );
  }

  void _openMore() {
    showRoomMoreMenu(
      context,
      isVideo: _isVideo,
      onShare: () => showChatToast(context, 'Room link copied! 🔗'),
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
    final Widget page = switch (_stage) {
      1 || 2 => RoomListView(rooms: _rooms, onBack: _exit, onJoin: _openJoin, onCreate: _createRoom),
      5 => RoomEndedView(room: _room, totalStars: _totalStars, onHome: _exit),
      _ => RoomStageView(
        room: _room,
        seats: _seats,
        messages: _messages,
        isVideo: _isVideo,
        micMuted: _micMuted,
        soundMuted: _soundMuted,
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
            resizeToAvoidBottomInset: true,
            body: Stack(
              fit: StackFit.expand,
              children: [
                const LuxeBackdrop(),
                SafeArea(child: page),
                if (_stage == 2) JoinRoomModal(room: _room, onJoin: () => _setStage(3), onCancel: () => _setStage(1)),
                if (_stage == 4) EndRoomModal(onEnd: () => _setStage(5), onCancel: () => _setStage(3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
