// Streamer end-of-battle popup: winner announcement with Exit / Rebattle.

import 'package:flutter/material.dart';

import '../core/pk_models.dart';
import '../core/pk_responsive.dart';
import '../overlays/pk_winner_overlay.dart';

class PkStreamerEndOverlay extends StatelessWidget {
  final PkHost left;
  final PkHost right;
  final int leftScore;
  final int rightScore;
  final VoidCallback onRebattle;
  final VoidCallback onExit;

  const PkStreamerEndOverlay({
    super.key,
    required this.left,
    required this.right,
    required this.leftScore,
    required this.rightScore,
    required this.onRebattle,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final r = PkResponsive.of(context);
    final youWon = leftScore > rightScore;
    final isDraw = leftScore == rightScore;

    return PkEndFrame(
      glow: isDraw ? const Color(0xFF7B52FF) : const Color(0xFFFFC928),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PkResultHeader(left: left, right: right, leftScore: leftScore, rightScore: rightScore),
          SizedBox(height: r.s(12)),
          Text(
            isDraw
                ? 'Neck and neck! Run it back to settle it.'
                : youWon
                ? 'You won this round — defend your crown!'
                : 'So close! Challenge ${right.name} again.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: r.s(12.5)),
          ),
          SizedBox(height: r.s(4)),
          Text(
            'Your viewers can rewatch only if you rebattle.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: r.s(11)),
          ),
          SizedBox(height: r.s(16)),
          Row(
            children: [
              Expanded(
                child: PkEndButton(label: 'Exit', icon: Icons.logout_rounded, onTap: onExit),
              ),
              SizedBox(width: r.s(10)),
              Expanded(
                child: PkEndButton(label: 'Rebattle', icon: Icons.sports_mma_rounded, primary: true, onTap: onRebattle),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
