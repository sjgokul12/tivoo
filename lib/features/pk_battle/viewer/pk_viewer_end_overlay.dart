// Viewer end-of-battle popup: who won and how many stars the viewer used.
// No buttons — it closes by itself after a few seconds.

import 'dart:async';

import 'package:flutter/material.dart';

import '../core/pk_models.dart';
import '../core/pk_responsive.dart';
import '../overlays/pk_winner_overlay.dart';

class PkViewerResultPopup extends StatefulWidget {
  final PkHost left;
  final PkHost right;
  final int leftScore;
  final int rightScore;
  final int giftsSent;
  final int starsUsed;
  final Duration visibleFor;
  final VoidCallback onClosed;

  const PkViewerResultPopup({
    super.key,
    required this.left,
    required this.right,
    required this.leftScore,
    required this.rightScore,
    required this.giftsSent,
    required this.starsUsed,
    this.visibleFor = const Duration(seconds: 3),
    required this.onClosed,
  });

  @override
  State<PkViewerResultPopup> createState() => _PkViewerResultPopupState();
}

class _PkViewerResultPopupState extends State<PkViewerResultPopup> {
  bool _closing = false;
  Timer? _timer;

  static const _fadeDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    _timer = Timer(widget.visibleFor, _close);
  }

  void _close() {
    if (!mounted || _closing) return;
    setState(() => _closing = true);
    _timer = Timer(_fadeDuration, () {
      if (mounted) widget.onClosed();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = PkResponsive.of(context);
    return AnimatedOpacity(
      opacity: _closing ? 0 : 1,
      duration: _fadeDuration,
      child: GestureDetector(
        onTap: _close,
        behavior: HitTestBehavior.opaque,
        child: PkEndFrame(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PkResultHeader(
                left: widget.left,
                right: widget.right,
                leftScore: widget.leftScore,
                rightScore: widget.rightScore,
              ),
              SizedBox(height: r.s(16)),
              _StarsUsedCard(giftsSent: widget.giftsSent, starsUsed: widget.starsUsed),
              SizedBox(height: r.s(14)),
              _CloseCountdown(duration: widget.visibleFor),
            ],
          ),
        ),
      ),
    );
  }
}

class _StarsUsedCard extends StatelessWidget {
  final int giftsSent;
  final int starsUsed;

  const _StarsUsedCard({required this.giftsSent, required this.starsUsed});

  @override
  Widget build(BuildContext context) {
    final r = PkResponsive.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: r.s(14), vertical: r.s(12)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r.s(18)),
        gradient: const LinearGradient(colors: [Color(0xFF2E1C66), Color(0xFF180F3B)]),
        border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: r.s(40),
            height: r.s(40),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [Color(0xFFFFD54F), Color(0xFFFF8F00)]),
              boxShadow: [BoxShadow(color: Color(0x88FFD54F), blurRadius: 12)],
            ),
            child: Icon(Icons.star_rounded, color: Colors.white, size: r.s(24)),
          ),
          SizedBox(width: r.s(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Stars you used',
                  style: TextStyle(color: Colors.white70, fontSize: r.s(12), fontWeight: FontWeight.w600),
                ),
                SizedBox(height: r.s(2)),
                Text(
                  '${giftsSent == 1 ? '1 gift' : '$giftsSent gifts'} sent',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white38, fontSize: r.s(11)),
                ),
              ],
            ),
          ),
          Text(
            '${formatPkStars(starsUsed)} ⭐',
            style: TextStyle(
              color: const Color(0xFFFFD54F),
              fontSize: r.s(18),
              fontWeight: FontWeight.w900,
              shadows: const [Shadow(color: Color(0x88FFB300), blurRadius: 8)],
            ),
          ),
        ],
      ),
    );
  }
}

/// Thin bar that drains while the popup is visible.
class _CloseCountdown extends StatelessWidget {
  final Duration duration;
  const _CloseCountdown({required this.duration});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1, end: 0),
        duration: duration,
        builder: (context, value, _) => LinearProgressIndicator(
          value: value,
          minHeight: 3,
          backgroundColor: Colors.white10,
          valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD54F)),
        ),
      ),
    );
  }
}

/// Small pill on the finished stage while the viewer waits for the streamer.
class PkWaitingForHostPill extends StatelessWidget {
  final String hostName;
  const PkWaitingForHostPill({super.key, required this.hostName});

  @override
  Widget build(BuildContext context) {
    final r = PkResponsive.of(context);
    return Align(
      alignment: const Alignment(0, -0.1),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: EdgeInsets.symmetric(horizontal: r.s(16), vertical: r.s(10)),
        decoration: BoxDecoration(
          color: const Color(0xE60F0B28),
          borderRadius: BorderRadius.circular(r.s(24)),
          border: Border.all(color: const Color(0xFFFFD54F).withValues(alpha: 0.6)),
          boxShadow: const [BoxShadow(color: Color(0x55FFD54F), blurRadius: 16)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: r.s(14),
              height: r.s(14),
              child: const CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFFD54F)),
            ),
            SizedBox(width: r.s(10)),
            Flexible(
              child: Text(
                'Waiting for $hostName…',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white, fontSize: r.s(13), fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
