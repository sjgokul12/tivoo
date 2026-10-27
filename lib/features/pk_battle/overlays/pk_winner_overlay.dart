// "PK Ended" winner celebration overlay that keeps both hosts live on screen.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/luxe_theme.dart';
import '../../../core/widgets/custom_avatar.dart';
import '../core/pk_models.dart';

/// In-stream celebration overlay shown when PK battle ends:
/// - Both winner and loser stay active in live stream on the same screen
/// - Winner announcement badges displayed over the live video arena
/// - Interactive decision card: "Rebattle (PK Again)" vs "Skip"
class PkWinnerOverlay extends StatelessWidget {
  final PkHost winner;
  final PkHost loser;
  final bool isLeftWinner;
  final int winnerScore;
  final int loserScore;
  final VoidCallback onPlayAgain;
  final VoidCallback onSkip;
  final VoidCallback? onBackToLive;

  const PkWinnerOverlay({
    super.key,
    required this.winner,
    required this.loser,
    required this.isLeftWinner,
    required this.winnerScore,
    required this.loserScore,
    required this.onPlayAgain,
    required this.onSkip,
    this.onBackToLive,
  });

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat('#,###');
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;

    return Stack(
      children: [
        // 1. Top Announcement Banner below header
        Positioned(
          top: topPadding + 44,
          left: 14,
          right: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(colors: [Color(0xF0181438), Color(0xF02A1E5C), Color(0xF0181438)]),
              border: Border.all(color: LuxeColors.gold.withValues(alpha: 0.7), width: 1.2),
              boxShadow: const [BoxShadow(color: Color(0x77FFD600), blurRadius: 14, offset: Offset(0, 2))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('👑', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  '${winner.name} Won! ',
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
                ),
                Text(
                  '(${format.format(winnerScore)} vs ${format.format(loserScore)})',
                  style: const TextStyle(color: LuxeColors.gold, fontSize: 13, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),

        // 2. Badges directly over the video arena (Left & Right)
        Positioned(
          top: topPadding + 88,
          left: 14,
          right: 14,
          child: Row(
            children: [
              Expanded(child: isLeftWinner ? const _WinnerBadge() : const _LoserBadge()),
              const SizedBox(width: 8),
              Expanded(child: !isLeftWinner ? const _WinnerBadge() : const _LoserBadge()),
            ],
          ),
        ),

        // 3. Floating Interactive Decision Card at bottom (Rebattle or Skip)
        Positioned(
          bottom: mediaQuery.padding.bottom + 12,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xF514112E), Color(0xFA09081A)],
              ),
              border: Border.all(color: LuxeColors.gold.withValues(alpha: 0.65), width: 1.5),
              boxShadow: const [
                BoxShadow(color: Color(0x66FFC928), blurRadius: 18, offset: Offset(0, 4)),
                BoxShadow(color: Color(0xD9000000), blurRadius: 20),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with winner avatar thumbnail and announcement
                Row(
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LuxeColors.goldGradient),
                          child: CustomAvatar(radius: 20, assetPath: winner.avatarAsset),
                        ),
                        const Positioned(top: -6, right: -4, child: Text('👑', style: TextStyle(fontSize: 14))),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                winner.name,
                                style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  gradient: LuxeColors.goldGradient,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'WINNER',
                                  style: TextStyle(
                                    color: Color(0xFF1F1400),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'PK ended • Do you want to rebattle or skip?',
                            style: TextStyle(color: Color(0xFFB0B0B8), fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Action Buttons Row: Rebattle (PK Again) vs Skip
                Row(
                  children: [
                    // Skip button
                    Expanded(
                      flex: 4,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1.2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: onSkip,
                        child: const Text(
                          'Skip',
                          style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Rebattle (PK Again) button
                    Expanded(
                      flex: 6,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LuxeColors.goldGradient,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: const [BoxShadow(color: Color(0x88FFC928), blurRadius: 12, offset: Offset(0, 2))],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),
                            onTap: onPlayAgain,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.refresh_rounded, color: Color(0xFF1F1400), size: 18),
                                  SizedBox(width: 6),
                                  Text(
                                    'Rebattle (PK Again)',
                                    style: TextStyle(
                                      color: Color(0xFF1F1400),
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WinnerBadge extends StatelessWidget {
  const _WinnerBadge();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFFFFEA79), Color(0xFFFFC928), Color(0xFFE59A00)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [BoxShadow(color: Color(0xAAFFD600), blurRadius: 10, offset: Offset(0, 2))],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('👑', style: TextStyle(fontSize: 13)),
            SizedBox(width: 4),
            Text(
              'WINNER',
              style: TextStyle(color: Color(0xFF1F1400), fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoserBadge extends StatelessWidget {
  const _LoserBadge();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: const Text(
          'DEFEATED',
          style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5),
        ),
      ),
    );
  }
}
