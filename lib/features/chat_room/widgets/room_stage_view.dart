import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/luxe_theme.dart';
import '../../live_stream/domain/models/live_comment.dart';
import '../data/chat_room_data.dart';
import 'chat_room_common.dart';

/// Step 3: inside the room — header, tagline, 3×3 seats, recent chat and the action dock.
class RoomStageView extends StatelessWidget {
  final ChatRoom room;
  final List<ChatSeat?> seats;
  final List<LiveComment> messages;
  final bool isVideo;
  final bool micMuted;
  final bool soundMuted;
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

  const RoomStageView({
    super.key,
    required this.room,
    required this.seats,
    required this.messages,
    required this.isVideo,
    required this.micMuted,
    required this.soundMuted,
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
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 6),
        _RoomHeader(room: room, isVideo: isVideo, onBack: onBack, onLeave: onLeave, onMore: onMore),
        const _TaglineBanner(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: _SeatGrid(seats: seats, onSeatTap: onSeatTap, onInvite: onInvite),
          ),
        ),
        _ChatFeed(messages: messages),
        _RoomDock(
          micMuted: micMuted,
          soundMuted: soundMuted,
          onMic: onMic,
          onSound: onSound,
          onGift: onGift,
          onStar: onStar,
          onMore: onMore,
          onSend: onSend,
        ),
      ],
    );
  }
}

class _RoomHeader extends StatelessWidget {
  final ChatRoom room;
  final bool isVideo;
  final VoidCallback onBack;
  final VoidCallback onLeave;
  final VoidCallback onMore;

  const _RoomHeader({
    required this.room,
    required this.isVideo,
    required this.onBack,
    required this.onLeave,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          LuxeCircleButton(icon: Icons.arrow_back_ios_new_rounded, label: 'Back', size: 34, onTap: onBack),
          const SizedBox(width: 8),
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
                        room.hostName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.workspace_premium_rounded, color: LuxeColors.gold, size: 15),
                  ],
                ),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      GoldTagPill(text: room.tag, icon: room.tagIcon, fontSize: 10.5),
                      const SizedBox(width: 6),
                      const Icon(Icons.people_alt_rounded, color: LuxeColors.textMuted, size: 12),
                      Text(
                        ' ${room.capacity}',
                        style: const TextStyle(color: LuxeColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        isVideo ? Icons.videocam_rounded : Icons.graphic_eq_rounded,
                        color: LuxeColors.violet,
                        size: 13,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Semantics(
            button: true,
            label: 'Leave room',
            child: GestureDetector(
              onTap: onLeave,
              child: Container(
                height: 30,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: LuxeColors.pink.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: LuxeColors.pink, width: 1.3),
                  boxShadow: const [BoxShadow(color: Color(0x44FF2D78), blurRadius: 6)],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.logout_rounded, color: LuxeColors.pink, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Leave',
                      style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          LuxeCircleButton(icon: Icons.more_vert_rounded, label: 'More', size: 32, onTap: onMore),
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
      child: Row(
        children: [
          Icon(Icons.workspace_premium_rounded, color: LuxeColors.gold, size: 16),
          SizedBox(width: 6),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Good Vibes  •  Great People  •  Better Conversations',
                style: TextStyle(
                  color: LuxeColors.textMuted,
                  fontSize: 11.5,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          SizedBox(width: 6),
          Icon(Icons.favorite_rounded, color: LuxeColors.violet, size: 14),
        ],
      ),
    );
  }
}

/// 3×3 seats sized to fill the space without overflowing; the host glows gold.
class _SeatGrid extends StatefulWidget {
  final List<ChatSeat?> seats;
  final ValueChanged<int> onSeatTap;
  final VoidCallback onInvite;

  const _SeatGrid({required this.seats, required this.onSeatTap, required this.onInvite});

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
        const gap = 9.0;
        final cellW = (c.maxWidth - gap * 2) / 3;
        final cellH = (c.maxHeight - gap * 2) / 3;
        // Keep a portrait card shape and make all three rows fit.
        final w = math.min(cellW, cellH * 0.9);
        final h = math.min(cellH, w / 0.66);

        return Center(
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
        );
      },
    );
  }

  Widget _cell(int i) {
    final seat = i < widget.seats.length ? widget.seats[i] : null;
    if (seat == null) return _InviteSeat(onTap: widget.onInvite);
    return GestureDetector(
      onTap: () => widget.onSeatTap(i),
      child: seat.isHost
          ? AnimatedBuilder(
              animation: _pulse,
              builder: (_, child) => _SeatFrame(host: true, glow: 0.5 + _pulse.value * 0.5, child: child!),
              child: _SeatContent(seat: seat, pulse: _pulse),
            )
          : _SeatFrame(
              host: false,
              glow: 0,
              child: _SeatContent(seat: seat, pulse: _pulse),
            ),
    );
  }
}

class _SeatFrame extends StatelessWidget {
  final bool host;
  final double glow;
  final Widget child;

  const _SeatFrame({required this.host, required this.glow, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(host ? 1.8 : 1.1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: host
              ? const [LuxeColors.goldLight, LuxeColors.gold, LuxeColors.goldDeep]
              : [LuxeColors.purple.withValues(alpha: 0.7), LuxeColors.blue.withValues(alpha: 0.5)],
        ),
        boxShadow: host
            ? [
                BoxShadow(
                  color: LuxeColors.gold.withValues(alpha: 0.45 * glow),
                  blurRadius: 14 * glow,
                ),
              ]
            : null,
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(host ? 16.2 : 16.9), child: child),
    );
  }
}

class _SeatContent extends StatelessWidget {
  final ChatSeat seat;
  final Animation<double> pulse;

  const _SeatContent({required this.seat, required this.pulse});

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
          left: 7,
          right: 6,
          bottom: 6,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      seat.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 5.5,
                          height: 5.5,
                          decoration: const BoxDecoration(color: Color(0xFF00E676), shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 3.5),
                        Flexible(
                          child: Text(
                            seat.status,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: seat.isHost ? LuxeColors.goldLight : LuxeColors.textMuted,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: seat.isHost ? LuxeColors.goldGradient : null,
                  color: seat.isHost ? null : const Color(0xD9171340),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                ),
                child: Icon(
                  seat.micOn ? Icons.mic_rounded : Icons.mic_off_rounded,
                  color: seat.isHost ? kGoldInk : (seat.micOn ? Colors.white : LuxeColors.pink),
                  size: 14,
                ),
              ),
            ],
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

/// The last few chat lines, newest at the bottom, fading out at the top.
class _ChatFeed extends StatelessWidget {
  final List<LiveComment> messages;
  const _ChatFeed({required this.messages});

  @override
  Widget build(BuildContext context) {
    final recent = messages.length > 3 ? messages.sublist(messages.length - 3) : messages;
    if (recent.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < recent.length; i++)
            Opacity(
              opacity: 0.55 + 0.45 * ((i + 1) / recent.length),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _ChatLine(comment: recent[i]),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChatLine extends StatelessWidget {
  final LiveComment comment;
  const _ChatLine({required this.comment});

  @override
  Widget build(BuildContext context) {
    final gift = comment.type == LiveCommentType.gift;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xB3100C2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: (gift ? LuxeColors.gold : LuxeColors.purple).withValues(alpha: 0.4)),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '${comment.userName}  ',
              style: const TextStyle(color: LuxeColors.gold, fontWeight: FontWeight.w800),
            ),
            TextSpan(
              text: comment.message,
              style: TextStyle(color: gift ? LuxeColors.goldLight : Colors.white),
            ),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

/// Dock: Mic / Sound / Gift / Star / More plus the message input.
class _RoomDock extends StatefulWidget {
  final bool micMuted;
  final bool soundMuted;
  final VoidCallback onMic;
  final VoidCallback onSound;
  final VoidCallback onGift;
  final VoidCallback onStar;
  final VoidCallback onMore;
  final ValueChanged<String> onSend;

  const _RoomDock({
    required this.micMuted,
    required this.soundMuted,
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

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    widget.onSend(text);
    _input.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 2, 14, 10),
      child: LuxePanel(
        radius: 24,
        glow: 10,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LayoutBuilder(
              builder: (context, c) {
                final size = ((c.maxWidth / 5) - 16).clamp(40.0, 50.0);
                Widget btn(IconData icon, String label, VoidCallback onTap, {bool gold = false}) => Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LuxeCircleButton(icon: icon, label: label, size: size, gold: gold, onTap: onTap),
                      const SizedBox(height: 5),
                      Text(
                        label,
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
                return Row(
                  children: [
                    btn(widget.micMuted ? Icons.mic_off_rounded : Icons.mic_rounded, 'Mic', widget.onMic, gold: true),
                    btn(
                      widget.soundMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                      'Sound',
                      widget.onSound,
                    ),
                    btn(Icons.card_giftcard_rounded, 'Gift', widget.onGift, gold: true),
                    btn(Icons.star_rounded, 'Star', widget.onStar),
                    btn(Icons.more_horiz_rounded, 'More', widget.onMore),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Container(
              height: 46,
              padding: const EdgeInsets.only(left: 12, right: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF0E0B2C),
                borderRadius: BorderRadius.circular(23),
                border: Border.all(color: LuxeColors.purple.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _input.text += ' 😊',
                    child: const Icon(Icons.sentiment_satisfied_alt_rounded, color: LuxeColors.gold, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _input,
                      cursorColor: LuxeColors.gold,
                      style: const TextStyle(color: Colors.white, fontSize: 13.5),
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: LuxeColors.textDim, fontSize: 13.5),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  Semantics(
                    button: true,
                    label: 'Send',
                    child: GestureDetector(
                      onTap: _send,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: LuxeDecor.goldButton(radius: 18),
                        child: const Icon(Icons.send_rounded, color: kGoldInk, size: 17),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
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
