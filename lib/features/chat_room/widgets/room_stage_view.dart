import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/luxe_theme.dart';
import '../../../core/widgets/custom_avatar.dart';
import '../../../core/widgets/tivoo_share_sheet.dart';
import '../../live_stream/domain/models/live_comment.dart';
import '../data/chat_room_data.dart';
import 'chat_room_common.dart';

/// Step 3: inside the room — header, tagline, 3×3 seats, recent chat and the action dock.
class RoomStageView extends StatefulWidget {
  final ChatRoom room;
  final List<ChatSeat?> seats;
  final List<LiveComment> messages;
  final bool isVideo;
  final bool micMuted;
  final bool isHost;
  final VoidCallback? onShowMembers;
  final bool soundMuted;
  final bool isJoined;
  final bool isJoinRequested;
  final int pendingRequestsCount;
  final int selectedSeatIndex;
  final bool isHostFollowing;
  final bool isHostRequested;
  final VoidCallback? onHostFollowTap;
  final VoidCallback? onHostProfileTap;
  final ValueChanged<LiveComment>? onCommentTap;
  final ValueChanged<LiveComment>? onCommentLongPress;
  final VoidCallback onJoinConversation;
  final VoidCallback? onCancelJoinRequest;
  final VoidCallback? onReviewRequests;
  final ValueChanged<int> onSeatSelected;
  final ValueChanged<int> onSeatLongPress;
  final VoidCallback onBack;
  final VoidCallback onLeave;
  final VoidCallback onMore;
  final ValueChanged<int> onSeatTap;
  final VoidCallback onInvite;
  final VoidCallback onMic;
  final VoidCallback onSound;
  final VoidCallback onGift;
  final VoidCallback onStar;
  final ValueChanged<String> onSend;
  final List<GlobalKey>? seatKeys;

  const RoomStageView({
    super.key,
    required this.room,
    required this.seats,
    required this.messages,
    required this.isVideo,
    this.isHost = false,
    this.onShowMembers,
    required this.micMuted,
    required this.soundMuted,
    required this.isJoined,
    this.isJoinRequested = false,
    this.pendingRequestsCount = 0,
    this.isHostFollowing = false,
    this.isHostRequested = false,
    this.onHostFollowTap,
    this.onHostProfileTap,
    this.onCommentTap,
    this.onCommentLongPress,
    required this.selectedSeatIndex,
    required this.onJoinConversation,
    this.onCancelJoinRequest,
    this.onReviewRequests,
    required this.onSeatSelected,
    required this.onSeatLongPress,
    required this.onBack,
    required this.onLeave,
    required this.onMore,
    required this.onSeatTap,
    required this.onInvite,
    required this.onMic,
    required this.onSound,
    required this.onGift,
    required this.onStar,
    required this.onSend,
    this.seatKeys,
  });

  @override
  State<RoomStageView> createState() => _RoomStageViewState();
}

class _RoomStageViewState extends State<RoomStageView> {
  bool _isCommentInputOpen = false;

  void _openCommentInput() {
    setState(() => _isCommentInputOpen = true);
  }

  void _closeCommentInput() {
    FocusScope.of(context).unfocus();
    setState(() => _isCommentInputOpen = false);
  }

  @override
  Widget build(BuildContext context) {
    final viewInset = MediaQuery.viewInsetsOf(context).bottom;
    final isTyping = _isCommentInputOpen || viewInset > 50;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: isTyping ? _closeCommentInput : null,
      child: Column(
        children: [
          const SizedBox(height: 6),
          _RoomHeader(
            room: widget.room,
            seats: widget.seats,
            isVideo: widget.isVideo,
            isHost: widget.isHost,
            onShowMembers: widget.onShowMembers,
            pendingRequestsCount: widget.pendingRequestsCount,
            onReviewRequests: widget.onReviewRequests,
            isHostFollowing: widget.isHostFollowing,
            isHostRequested: widget.isHostRequested,
            onHostFollowTap: widget.onHostFollowTap,
            onHostProfileTap: widget.onHostProfileTap,
            onBack: widget.onBack,
            onLeave: widget.onLeave,
            onMore: widget.onMore,
          ),
          if (!isTyping) const _TaglineBanner(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: _SeatGrid(
                seats: widget.seats,
                selectedSeatIndex: widget.selectedSeatIndex,
                onSeatSelected: widget.onSeatSelected,
                onSeatLongPress: widget.onSeatLongPress,
                onSeatTap: widget.onSeatTap,
                onInvite: widget.onInvite,
                seatKeys: widget.seatKeys,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                _ChatFeed(
                  messages: widget.messages,
                  hasJoinButton: !widget.isJoined && !isTyping,
                  isCompact: isTyping,
                  onCommentTap: widget.onCommentTap,
                  onCommentLongPress: widget.onCommentLongPress,
                ),
                if (!widget.isJoined && !isTyping)
                  Positioned(
                    right: 14,
                    bottom: 6,
                    child: _JoinFloatingButton(
                      isJoinRequested: widget.isJoinRequested,
                      onTap: widget.onJoinConversation,
                    ),
                  ),
              ],
            ),
          ),
          _RoomDock(
            micMuted: widget.micMuted,
            soundMuted: widget.soundMuted,
            isTyping: isTyping,
            onOpenCommentInput: _openCommentInput,
            onCloseCommentInput: _closeCommentInput,
            onMic: widget.onMic,
            onSound: widget.onSound,
            onGift: widget.onGift,
            onStar: widget.onStar,
            onMore: widget.onMore,
            onSend: widget.onSend,
          ),
        ],
      ),
    );
  }
}

class _RoomHeader extends StatelessWidget {
  final ChatRoom room;
  final List<ChatSeat?>? seats;
  final bool isVideo;
  final bool isHost;
  final VoidCallback? onShowMembers;
  final int pendingRequestsCount;
  final VoidCallback? onReviewRequests;
  final bool isHostFollowing;
  final bool isHostRequested;
  final VoidCallback? onHostFollowTap;
  final VoidCallback? onHostProfileTap;
  final VoidCallback onBack;
  final VoidCallback onLeave;
  final VoidCallback onMore;

  const _RoomHeader({
    required this.room,
    this.seats,
    required this.isVideo,
    this.isHost = false,
    this.onShowMembers,
    this.pendingRequestsCount = 0,
    this.onReviewRequests,
    this.isHostFollowing = false,
    this.isHostRequested = false,
    this.onHostFollowTap,
    this.onHostProfileTap,
    required this.onBack,
    required this.onLeave,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final occupiedCount = seats != null ? seats!.where((s) => s != null).length : room.members;
    final capacityLabel = '$occupiedCount/${ChatRoom.seatCount}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          LuxeCircleButton(icon: Icons.arrow_back_ios_new_rounded, label: 'Back', size: 34, onTap: onBack),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onHostProfileTap,
              child: Row(
                children: [
                  GoldRingAvatar(asset: room.avatar, radius: 19, ring: 2),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                room.tagline,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: onShowMembers,
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.people_alt_rounded, color: LuxeColors.gold, size: 12),
                                      const SizedBox(width: 3),
                                      Text(
                                        ' $capacityLabel',
                                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.graphic_eq_rounded,
                                color: LuxeColors.violet,
                                size: 13,
                              ),
                              const SizedBox(width: 3),
                              const Text(
                                'Audio Room',
                                style: TextStyle(color: LuxeColors.textMuted, fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          if (pendingRequestsCount > 0 && onReviewRequests != null) ...[
            GestureDetector(
              onTap: onReviewRequests,
              child: Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFFF9800), width: 1.3),
                  boxShadow: const [BoxShadow(color: Color(0x44FF9800), blurRadius: 6)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.notifications_active_rounded, color: Color(0xFFFFB74D), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$pendingRequestsCount',
                      style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Semantics(
            button: true,
            label: isHost ? 'End room' : 'Leave room',
            child: GestureDetector(
              onTap: onLeave,
              child: Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: isHost
                      ? const Color(0xFFFF2D55).withValues(alpha: 0.16)
                      : const Color(0xFF6C3CE9).withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: isHost ? const Color(0xFFFF2D55) : const Color(0xFF9D65FF),
                    width: 1.3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isHost ? const Color(0x44FF2D55) : const Color(0x336C3CE9),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isHost ? Icons.power_settings_new_rounded : Icons.logout_rounded,
                      color: isHost ? const Color(0xFFFF2D55) : const Color(0xFFC49BFB),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isHost ? 'End' : 'Leave',
                      style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaglineBanner extends StatelessWidget {
  const _TaglineBanner();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(14, 4, 14, 6),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Good Vibes  •  Great People  •  Better Conversations',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: LuxeColors.textMuted,
              fontSize: 11.5,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

/// 3×3 seats sized to fill the space without overflowing; the selected seat glows golden-yellow.
class _SeatGrid extends StatefulWidget {
  final List<ChatSeat?> seats;
  final int selectedSeatIndex;
  final ValueChanged<int> onSeatSelected;
  final ValueChanged<int> onSeatLongPress;
  final ValueChanged<int> onSeatTap;
  final VoidCallback onInvite;
  final List<GlobalKey>? seatKeys;

  const _SeatGrid({
    required this.seats,
    required this.selectedSeatIndex,
    required this.onSeatSelected,
    required this.onSeatLongPress,
    required this.onSeatTap,
    required this.onInvite,
    this.seatKeys,
  });

  @override
  State<_SeatGrid> createState() => _SeatGridState();
}

class _SeatGridState extends State<_SeatGrid> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 950))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        const gap = 8.0;
        final cellW = (c.maxWidth - gap * 2) / 3;
        final availableH = c.maxHeight.isFinite ? c.maxHeight : 260.0;
        final cellH = (availableH - gap * 2) / 3;
        // Keep a portrait card shape and clamp min/max so seats never overflow
        final w = math.min(cellW, math.max(cellH * 0.80, 50.0)).clamp(50.0, 110.0);
        final h = math.min(cellH, w / 0.72).clamp(56.0, 138.0);

        return Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var row = 0; row < 3; row++) ...[
                  if (row > 0) const SizedBox(height: gap),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var col = 0; col < 3; col++) ...[
                        if (col > 0) const SizedBox(width: gap),
                        SizedBox(width: w, height: h, child: _cell(row * 3 + col)),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _cell(int i) {
    final seat = i < widget.seats.length ? widget.seats[i] : null;
    final isSelected = i == widget.selectedSeatIndex;

    final child = seat == null
        ? _InviteSeat(onTap: widget.onInvite)
        : GestureDetector(
            onTap: () => widget.onSeatSelected(i),
            onLongPress: () => widget.onSeatLongPress(i),
            child: seat.isHost
                ? AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, c) => _SeatFrame(
                      host: true,
                      selected: isSelected,
                      glow: 0.5 + _pulse.value * 0.5,
                      child: c!,
                    ),
                    child: _SeatContent(seat: seat, selected: isSelected, pulse: _pulse),
                  )
                : _SeatFrame(
                    host: false,
                    selected: isSelected,
                    glow: 0,
                    child: _SeatContent(seat: seat, selected: isSelected, pulse: _pulse),
                  ),
          );

    if (widget.seatKeys != null && i < widget.seatKeys!.length) {
      return KeyedSubtree(key: widget.seatKeys![i], child: child);
    }
    return child;
  }
}

class _SeatFrame extends StatelessWidget {
  final bool host;
  final bool selected;
  final double glow;
  final Widget child;

  const _SeatFrame({
    required this.host,
    this.selected = false,
    required this.glow,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.all(selected ? 2.4 : 1.2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: selected
              ? const [Color(0xFFFFF176), Color(0xFFFFD700), Color(0xFFFFA000)]
              : [LuxeColors.purple.withValues(alpha: 0.6), LuxeColors.blue.withValues(alpha: 0.4)],
        ),
        boxShadow: [
          if (selected)
            const BoxShadow(
              color: Color(0x99FFD700),
              blurRadius: 16,
              spreadRadius: 1.5,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(selected ? 15.6 : 16.8),
        child: child,
      ),
    );
  }
}

class _SeatContent extends StatelessWidget {
  final ChatSeat seat;
  final bool selected;
  final Animation<double> pulse;

  const _SeatContent({
    required this.seat,
    this.selected = false,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          seat.avatar,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            color: LuxeColors.panel,
            child: const Icon(Icons.person_rounded, color: Colors.white30, size: 36),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.45, 1.0],
              colors: [Colors.transparent, Color(0xE60A0820)],
            ),
          ),
        ),
        if (seat.isHost) ...[
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
              decoration: LuxeDecor.goldButton(radius: 8),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.workspace_premium_rounded, color: kGoldInk, size: 11),
                  SizedBox(width: 2),
                  Text(
                    'Host',
                    style: TextStyle(color: kGoldInk, fontSize: 10, fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          ),
          Positioned(top: 8, right: 8, child: _EqualizerBars(animation: pulse)),
        ],
        Positioned(
          left: 5,
          right: 5,
          bottom: 5,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.bottomLeft,
            child: SizedBox(
              width: 86,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      seat.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: seat.isHost ? LuxeColors.goldGradient : null,
                      color: seat.isHost ? null : const Color(0xD9171340),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: Icon(
                      seat.micOn ? Icons.mic_rounded : Icons.mic_off_rounded,
                      color: seat.isHost ? kGoldInk : (seat.micOn ? Colors.white : LuxeColors.pink),
                      size: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EqualizerBars extends StatelessWidget {
  final Animation<double> animation;
  const _EqualizerBars({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, _) {
        final v = animation.value;
        Widget bar(double h) => Container(
          width: 2.4,
          height: h,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(color: LuxeColors.gold, borderRadius: BorderRadius.circular(1.5)),
        );
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [bar(5 + v * 7), bar(12 - v * 6), bar(4 + (1 - v) * 8)],
        );
      },
    );
  }
}

/// Empty ninth seat: dashed gold/violet border with a radiating "+".
class _InviteSeat extends StatelessWidget {
  final VoidCallback onTap;
  const _InviteSeat({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Invite',
      child: GestureDetector(
        onTap: onTap,
        child: CustomPaint(
          painter: const _DashedBorderPainter(),
          child: Container(
            decoration: BoxDecoration(color: LuxeColors.panelDeep, borderRadius: BorderRadius.circular(18)),
            padding: const EdgeInsets.all(6),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 46,
                    height: 46,
                    child: CustomPaint(
                      painter: const _TicksPainter(),
                      child: Center(
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF221A50),
                            border: Border.all(color: LuxeColors.gold, width: 1.5),
                            boxShadow: const [BoxShadow(color: Color(0x55FFC928), blurRadius: 8)],
                          ),
                          child: const Icon(Icons.add_rounded, color: LuxeColors.gold, size: 20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Invite',
                    style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Bring your friends\ninto the room',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: LuxeColors.textDim, fontSize: 9.5, height: 1.25),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Glassmorphic continuous live chat feed, streaming upwards like PK and Live Streaming.
class _ChatFeed extends StatefulWidget {
  final List<LiveComment> messages;
  final bool hasJoinButton;
  final bool isCompact;
  final ValueChanged<LiveComment>? onCommentTap;
  final ValueChanged<LiveComment>? onCommentLongPress;

  const _ChatFeed({
    required this.messages,
    this.hasJoinButton = false,
    this.isCompact = false,
    this.onCommentTap,
    this.onCommentLongPress,
  });

  @override
  State<_ChatFeed> createState() => _ChatFeedState();
}

class _ChatFeedState extends State<_ChatFeed> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(covariant _ChatFeed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages.length != oldWidget.messages.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0.0,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.messages.isEmpty) {
      return widget.hasJoinButton
          ? const SizedBox(height: 48, width: double.infinity)
          : const SizedBox.shrink();
    }

    // Media query responsive height adapting gracefully to small & large phone viewports
    final screenH = MediaQuery.sizeOf(context).height;
    final feedHeight = widget.isCompact
        ? 44.0
        : (screenH * 0.155).clamp(105.0, 140.0);

    return SizedBox(
      height: feedHeight,
      width: double.infinity,
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.white,
            Colors.white,
          ],
          stops: [0.0, 0.14, 1.0],
        ).createShader(bounds),
        child: ListView.builder(
          controller: _scrollController,
          reverse: true, // Anchor to bottom, streaming upwards!
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(14, 2, widget.hasJoinButton ? 115 : 14, 2),
          itemCount: widget.messages.length,
          itemBuilder: (context, index) {
            final itemIndex = widget.messages.length - 1 - index;
            if (itemIndex < 0 || itemIndex >= widget.messages.length) {
              return const SizedBox.shrink();
            }
            final comment = widget.messages[itemIndex];
            return Padding(
              padding: const EdgeInsets.only(bottom: 4.5),
              child: _ChatLine(
                key: ValueKey(comment.id),
                comment: comment,
                onTap: widget.onCommentTap,
                onLongPress: widget.onCommentLongPress,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ChatLine extends StatelessWidget {
  final LiveComment comment;
  final ValueChanged<LiveComment>? onTap;
  final ValueChanged<LiveComment>? onLongPress;

  const _ChatLine({
    super.key,
    required this.comment,
    this.onTap,
    this.onLongPress,
  });

  String _getAvatarForComment(LiveComment comment) {
    if (comment.userAssetPath != null && comment.userAssetPath!.isNotEmpty) {
      return comment.userAssetPath!;
    }
    const avatars = [
      AppAssets.avatarArun,
      AppAssets.avatarSneha,
      AppAssets.avatarKarthik,
      AppAssets.avatarNeha,
      AppAssets.avatarDiya,
      AppAssets.avatarVicky,
      AppAssets.avatarMeena,
      AppAssets.status4,
      AppAssets.status5,
    ];
    final hash = comment.userName.hashCode.abs();
    return avatars[hash % avatars.length];
  }

  @override
  Widget build(BuildContext context) {
    final isReported = comment.isReported;
    final isGift = !isReported &&
        (comment.type == LiveCommentType.gift ||
            comment.message.toLowerCase().contains('sent a') ||
            comment.message.toLowerCase().contains('star') ||
            comment.message.toLowerCase().contains('rose') ||
            comment.message.toLowerCase().contains('crown'));

    final avatarAsset = _getAvatarForComment(comment);

    return TweenAnimationBuilder<double>(
      key: ValueKey(comment.id),
      duration: const Duration(milliseconds: 260),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, val, child) {
        return Transform.translate(
          offset: Offset(0, (1.0 - val) * 10.0),
          child: Opacity(
            opacity: val.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Align(
        alignment: Alignment.centerLeft,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onTap?.call(comment),
          onLongPress: () => onLongPress?.call(comment),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.84,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
            decoration: BoxDecoration(
              color: isReported
                  ? const Color(0x99100C2E)
                  : isGift
                      ? const Color(0xCC1A1608)
                      : const Color(0xB3100C2E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isReported
                    ? Colors.white24
                    : isGift
                        ? LuxeColors.gold.withValues(alpha: 0.55)
                        : LuxeColors.purple.withValues(alpha: 0.42),
                width: isGift ? 1.1 : 0.9,
              ),
              boxShadow: isGift
                  ? [
                      BoxShadow(
                        color: LuxeColors.gold.withValues(alpha: 0.16),
                        blurRadius: 6,
                        spreadRadius: 0.5,
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Compact user avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isReported
                          ? Colors.white24
                          : isGift
                              ? LuxeColors.gold
                              : LuxeColors.purple.withValues(alpha: 0.6),
                      width: 1.0,
                    ),
                  ),
                  child: ClipOval(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CustomAvatar(
                        assetPath: avatarAsset,
                        imageUrl: comment.userAvatarUrl,
                        radius: 9,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${comment.userName}  ',
                          style: TextStyle(
                            color: isReported
                                ? LuxeColors.gold.withValues(alpha: 0.55)
                                : LuxeColors.gold,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                        if (isReported)
                          const TextSpan(
                            text: 'This comment has been reported',
                            style: TextStyle(
                              color: Colors.white54,
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                            ),
                          )
                        else
                          TextSpan(
                            text: comment.message,
                            style: TextStyle(
                              color: isGift ? LuxeColors.goldLight : Colors.white,
                              fontSize: 12,
                              fontWeight: isGift ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                      ],
                    ),
                    maxLines: 2,
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

/// Floating Join button positioned above the bottom dock near the streaming live comments.
class _JoinFloatingButton extends StatelessWidget {
  final bool isJoinRequested;
  final VoidCallback onTap;

  const _JoinFloatingButton({
    required this.isJoinRequested,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 38,
        padding: EdgeInsets.symmetric(horizontal: isJoinRequested ? 12 : 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          gradient: isJoinRequested
              ? const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                )
              : const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFFFF2A85), Color(0xFFC2185B)],
                ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: (isJoinRequested
                      ? const Color(0xFFFF9800)
                      : const Color(0xFFFF2A85))
                  .withValues(alpha: 0.5),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: isJoinRequested
              ? const [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Requested',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ]
              : const [
                  Icon(Icons.groups_rounded, color: Colors.white, size: 17),
                  SizedBox(width: 5),
                  Text(
                    'Join',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
        ),
      ),
    );
  }
}

/// Dock: Mic / Sound / Stars / Comments / Share (evenly spaced bottom panel).
class _RoomDock extends StatefulWidget {
  final bool micMuted;
  final bool soundMuted;
  final bool isTyping;
  final VoidCallback onOpenCommentInput;
  final VoidCallback onCloseCommentInput;
  final VoidCallback onMic;
  final VoidCallback onSound;
  final VoidCallback onGift;
  final VoidCallback onStar;
  final VoidCallback onMore;
  final ValueChanged<String> onSend;

  const _RoomDock({
    required this.micMuted,
    required this.soundMuted,
    required this.isTyping,
    required this.onOpenCommentInput,
    required this.onCloseCommentInput,
    required this.onMic,
    required this.onSound,
    required this.onGift,
    required this.onStar,
    required this.onMore,
    required this.onSend,
  });

  @override
  State<_RoomDock> createState() => _RoomDockState();
}

class _RoomDockState extends State<_RoomDock> {
  final _input = TextEditingController();
  final _focusNode = FocusNode();
  bool _showEmojiPicker = false;

  static const List<String> _quickEmojis = [
    '❤️', '😍', '🔥', '👏', '⭐', '🎉', '🌹', '💯', '😂', '✨',
    '🙌', '🥰', '🥳', '😎', '💖', '🤩', '👍', '🎁', '👑', '💃',
  ];

  @override
  void didUpdateWidget(covariant _RoomDock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isTyping && !oldWidget.isTyping) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    } else if (!widget.isTyping && oldWidget.isTyping) {
      _focusNode.unfocus();
      setState(() => _showEmojiPicker = false);
    }
  }

  void _insertEmoji(String emoji) {
    final text = _input.text;
    final selection = _input.selection;
    if (selection.start >= 0 && selection.end >= 0) {
      final newText = text.replaceRange(selection.start, selection.end, emoji);
      _input.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start + emoji.length),
      );
    } else {
      _input.text += emoji;
      _input.selection = TextSelection.collapsed(offset: _input.text.length);
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _input.clear();
    setState(() => _showEmojiPicker = false);
    widget.onCloseCommentInput();
  }

  @override
  Widget build(BuildContext context) {
    final viewInset = MediaQuery.viewInsetsOf(context).bottom;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 375;
    final iconSize = isCompact ? 38.0 : 42.0;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.fromLTRB(14, 2, 14, 8 + (viewInset > 0 ? viewInset : bottomInset)),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xEE0E0B2A),
          borderRadius: BorderRadius.circular(widget.isTyping ? 24 : 30),
          border: Border.all(
            color: const Color(0xFF6C3CE9).withValues(alpha: 0.65),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C3CE9).withValues(alpha: 0.28),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 10 : 12,
          vertical: widget.isTyping ? 6 : 8,
        ),
        child: widget.isTyping
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_showEmojiPicker) ...[
                    SizedBox(
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
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(emoji, style: const TextStyle(fontSize: 18)),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _showEmojiPicker = !_showEmojiPicker),
                        behavior: HitTestBehavior.opaque,
                        child: Icon(
                          _showEmojiPicker ? Icons.keyboard_rounded : Icons.sentiment_satisfied_alt_rounded,
                          color: LuxeColors.gold,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _input,
                          focusNode: _focusNode,
                          autofocus: true,
                          cursorColor: LuxeColors.gold,
                          cursorWidth: 2,
                          keyboardType: TextInputType.text,
                          enableSuggestions: true,
                          autocorrect: true,
                          style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600),
                          decoration: const InputDecoration(
                            hintText: 'Type a message to the room...',
                            hintStyle: TextStyle(color: Color(0xFF9E9EAF), fontSize: 13),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          onSubmitted: (_) => _send(),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _input.clear();
                          widget.onCloseCommentInput();
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 26,
                          height: 26,
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                          child: const Icon(Icons.close_rounded, color: Colors.white60, size: 15),
                        ),
                      ),
                      GestureDetector(
                        onTap: _send,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: LuxeDecor.goldButton(radius: 17),
                          child: const Icon(Icons.send_rounded, color: kGoldInk, size: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _DockIconButton(
                    size: iconSize,
                    icon: Icons.mic_rounded,
                    label: 'Mic',
                    isStriked: widget.micMuted,
                    onTap: widget.onMic,
                  ),
                  _DockIconButton(
                    size: iconSize,
                    icon: Icons.volume_up_rounded,
                    label: 'Sound',
                    isStriked: widget.soundMuted,
                    onTap: widget.onSound,
                  ),
                  _DockIconButton(
                    size: iconSize,
                    label: 'Stars',
                    onTap: widget.onGift,
                    child: Image.asset(
                      AppAssets.goldenStar,
                      width: iconSize * 0.52,
                      height: iconSize * 0.52,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Icon(
                        Icons.star_rounded,
                        color: const Color(0xFFFFD700),
                        size: iconSize * 0.52,
                      ),
                    ),
                  ),
                  _DockIconButton(
                    size: iconSize,
                    icon: Icons.chat_bubble_rounded,
                    label: 'Comments',
                    onTap: widget.onOpenCommentInput,
                  ),
                  _DockIconButton(
                    size: iconSize,
                    icon: Icons.share_rounded,
                    label: 'Share',
                    onTap: () {
                      TivooShareSheet.show(
                        context,
                        title: 'Share Chat Room',
                        subtitle: 'Invite friends to the room party',
                        shareUrl: 'https://tivoo.app/chatroom/party',
                        shareText: 'Join our live room party on Tivoo! https://tivoo.app/chatroom/party',
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }
}

class _DockIconButton extends StatelessWidget {
  final IconData? icon;
  final Widget? child;
  final String label;
  final VoidCallback onTap;
  final bool isStriked;
  final double size;

  const _DockIconButton({
    this.icon,
    this.child,
    required this.label,
    required this.onTap,
    this.isStriked = false,
    this.size = 42.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x551E1848),
              border: Border.all(
                color: isStriked
                    ? const Color(0xFFFF3B30).withValues(alpha: 0.75)
                    : Colors.white.withValues(alpha: 0.16),
                width: 1.2,
              ),
            ),
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (child != null)
                    child!
                  else if (icon != null)
                    Icon(
                      icon,
                      color: const Color(0xFFFFD700),
                      size: 21,
                    ),
                  if (isStriked)
                    CustomPaint(
                      size: const Size(22, 22),
                      painter: const _RedStrikePainter(),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: LuxeColors.goldLight,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RedStrikePainter extends CustomPainter {
  const _RedStrikePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF2D55)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.15),
      Offset(size.width * 0.85, size.height * 0.85),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 1.4, dash = 6.0, gapLen = 4.0;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    final paint = Paint()
      ..shader = const LinearGradient(colors: [LuxeColors.gold, LuxeColors.violet]).createShader(rect)
      ..strokeWidth = stroke
      ..style = PaintingStyle.stroke;
    final path = Path()..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(18)));
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += dash + gapLen) {
        canvas.drawPath(metric.extractPath(d, math.min(d + dash, metric.length)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TicksPainter extends CustomPainter {
  const _TicksPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final paint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 6; i++) {
      final a = i * math.pi / 3 - math.pi / 6;
      paint.color = i.isEven ? LuxeColors.gold : LuxeColors.violet;
      final dir = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(c + dir * 20, c + dir * 25, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
