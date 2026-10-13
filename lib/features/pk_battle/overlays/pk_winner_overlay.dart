// "PK Ended" winner celebration overlay.

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/custom_avatar.dart';
import '../core/pk_models.dart';
import '../core/pk_theme.dart';
import '../sheets/pk_sheets.dart';

/// "PK Ended" celebration card shown over a blurred backdrop.
class PkWinnerOverlay extends StatelessWidget {
  final PkHost winner;
  final int winnerScore;
  final int loserScore;
  final VoidCallback onPlayAgain;
  final VoidCallback onBackToLive;

  const PkWinnerOverlay({
    super.key,
    required this.winner,
    required this.winnerScore,
    required this.loserScore,
    required this.onPlayAgain,
    required this.onBackToLive,
  });

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat('#,###');
    return Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 9, sigmaY: 9),
            child: ColoredBox(color: Colors.black.withValues(alpha: 0.58)),
          ),
        ),
        Center(
          child: SingleChildScrollView(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xF2181433), Color(0xF80A0C1E)],
                ),
                border: Border.all(color: PkColors.gold.withValues(alpha: 0.65), width: 1.8),
                boxShadow: [
                  BoxShadow(color: PkColors.gold.withValues(alpha: 0.25), blurRadius: 30, spreadRadius: 2),
                  const BoxShadow(color: Color(0xD9000000), blurRadius: 24, offset: Offset(0, 12)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'PK Ended',
                    style: TextStyle(color: PkColors.gold, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                  const SizedBox(height: 10),
                  const Text('👑', style: TextStyle(fontSize: 46)),
                  const SizedBox(height: 4),
                  _WinnerAvatar(asset: winner.avatarAsset),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFFEA00), Color(0xFFFF9100), Color(0xFFFF6D00)]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Color(0xCCFFD600), blurRadius: 18, offset: Offset(0, 4))],
                    ),
                    child: const Text(
                      'WINNER',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    winner.name,
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Congrats! 🎉',
                    style: TextStyle(color: PkColors.gold, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Final Score: ${format.format(winnerScore)} vs ${format.format(loserScore)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  PkPrimaryButton(label: 'Play Again', onPressed: onPlayAgain),
                  const SizedBox(height: 12),
                  PkSecondaryButton(label: 'Back to Live', onPressed: onBackToLive),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WinnerAvatar extends StatelessWidget {
  final String asset;
  const _WinnerAvatar({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFFFFD600).withValues(alpha: 0.6),
                const Color(0xFFFF8F00).withValues(alpha: 0.2),
                Colors.transparent,
              ],
            ),
          ),
        ),
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🪽', style: TextStyle(fontSize: 50)),
            SizedBox(width: 80),
            Text('🪽', style: TextStyle(fontSize: 50)),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFFD600), width: 3),
            boxShadow: const [BoxShadow(color: Color(0xFFFFD600), blurRadius: 20, spreadRadius: 2)],
          ),
          child: CustomAvatar(radius: 48, assetPath: asset),
        ),
      ],
    );
  }
}
