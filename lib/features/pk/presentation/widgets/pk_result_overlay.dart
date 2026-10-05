import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/crown_icon.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/gradient_mask.dart';
import '../../../../data/models/pk_battle.dart';
import 'pk_header.dart';

/// Winner announcement shown when the countdown hits zero.
class PkResultOverlay extends StatelessWidget {
  const PkResultOverlay({
    super.key,
    required this.battle,
    required this.winner,
    required this.leftScore,
    required this.rightScore,
    required this.onRematch,
    required this.onLeave,
  });

  final PkBattle battle;
  final PkSide? winner;
  final int leftScore;
  final int rightScore;
  final VoidCallback onRematch;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final winnerStream = switch (winner) {
      PkSide.left => battle.left,
      PkSide.right => battle.right,
      null => null,
    };

    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: GlassContainer(
              blur: 16,
              borderRadius: 32,
              borderWidth: 1.6,
              glowColor: AppColors.gold,
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xCC3A1675), Color(0xE60E0A2E)],
              ),
              borderGradient: const LinearGradient(colors: [AppColors.pink, AppColors.gold, AppColors.cyan]),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CrownIcon(size: 40),
                  const SizedBox(height: 8),
                  if (winnerStream != null)
                    DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: winner!.color, blurRadius: 24, blurStyle: BlurStyle.outer)],
                      ),
                      child: Avatar(
                        image: winnerStream.streamer.avatar,
                        size: 96,
                        ringWidth: 3,
                        ringGradient: AppColors.goldGradient,
                      ),
                    ),
                  const SizedBox(height: 14),
                  GradientText(
                    winnerStream == null ? "It's a Draw!" : '${winnerStream.streamer.name} Wins!',
                    gradient: AppColors.goldGradient,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _Score(value: leftScore, color: PkSide.left.color),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text('VS', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                      ),
                      _Score(value: rightScore, color: PkSide.right.color),
                    ],
                  ),
                  const SizedBox(height: 24),
                  GradientButton(label: 'Rematch', height: 50, onPressed: onRematch),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onLeave,
                    style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
                    child: const Text('Leave Battle'),
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

class _Score extends StatelessWidget {
  const _Score({required this.value, required this.color});

  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          Formatters.grouped(value),
          style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
