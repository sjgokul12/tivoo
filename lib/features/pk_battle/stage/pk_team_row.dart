// Team cards and the Battle Time countdown.

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import '../core/pk_common_widgets.dart';
import '../core/pk_models.dart';
import '../core/pk_theme.dart';

/// Second row: [Team Left]  [Battle Time 01:46]  [Team Right]
class PkTeamRow extends StatelessWidget {
  final PkHost left;
  final PkHost right;
  final ValueListenable<int> secondsRemaining;
  final bool showCountdown;
  final VoidCallback onTeamTap;
  final VoidCallback onTimerTap;

  const PkTeamRow({
    super.key,
    required this.left,
    required this.right,
    required this.secondsRemaining,
    required this.showCountdown,
    required this.onTeamTap,
    required this.onTimerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _TeamCard(host: left, isLeft: true, onTap: onTeamTap),
          ),
          const SizedBox(width: 6),
          _BattleTimer(secondsRemaining: secondsRemaining, showCountdown: showCountdown, onTap: onTimerTap),
          const SizedBox(width: 6),
          Expanded(
            child: _TeamCard(host: right, isLeft: false, onTap: onTeamTap),
          ),
        ],
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  final PkHost host;
  final bool isLeft;
  final VoidCallback onTap;

  const _TeamCard({required this.host, required this.isLeft, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: PkDecor.glass(
          border: PkColors.side(isLeft).withValues(alpha: 0.85),
          radius: 14,
          borderWidth: 1.2,
          glow: 8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    host.teamName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: PkColors.textPrimary, fontSize: 11.5, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 4),
                const PkGoldCrown(size: 11),
              ],
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                PkAvatarPair(assets: host.teamAvatars),
                const SizedBox(width: 5),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      host.teamMembers,
                      maxLines: 1,
                      style: const TextStyle(color: PkColors.textSecondary, fontSize: 9.5, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BattleTimer extends StatelessWidget {
  final ValueListenable<int> secondsRemaining;

  /// When off (PK Settings → Countdown Display / Show Timer to Audience), "LIVE" replaces the clock.
  final bool showCountdown;
  final VoidCallback onTap;

  const _BattleTimer({required this.secondsRemaining, required this.showCountdown, required this.onTap});

  static String format(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
        decoration: PkDecor.glass(border: PkColors.cyan.withValues(alpha: 0.8), radius: 14, borderWidth: 1.3, glow: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.access_time_rounded, color: Colors.white70, size: 9),
                SizedBox(width: 4),
                Text(
                  'Battle Time',
                  style: TextStyle(color: Colors.white70, fontSize: 9.5, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            ValueListenableBuilder<int>(
              valueListenable: secondsRemaining,
              builder: (_, remaining, _) => Text(
                showCountdown ? format(remaining) : 'LIVE',
                style: TextStyle(
                  color: showCountdown && remaining <= 10 ? const Color(0xFFFF5252) : Colors.white,
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
