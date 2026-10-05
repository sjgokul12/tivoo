import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/animations.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/live_badge.dart';
import '../../../../data/models/live_stream.dart';
import '../../../../data/models/pk_battle.dart';
import '../../providers/pk_battle_controller.dart';
import 'pk_header.dart';
import 'slanted_pill.dart';

/// One creator's stream in the battle, with viewers, LIVE tag, the live
/// score plate and a WIN/LOSE stamp once time is up.
class PkVideoPanel extends StatelessWidget {
  const PkVideoPanel({super.key, required this.stream, required this.side, required this.cover});

  final LiveStream stream;
  final PkSide side;

  /// Stream frame, animated with a slow zoom-and-pan.
  final String cover;

  static const _radius = 22.0;

  @override
  Widget build(BuildContext context) {
    final isLeft = side == PkSide.left;
    return GlassContainer(
      borderRadius: _radius,
      borderWidth: 2,
      glowColor: side.color,
      glowBlur: 16,
      color: Colors.black,
      borderGradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [side.color.withValues(alpha: 0.9), side.color.withValues(alpha: 0.4), side.color],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            KenBurns(
              reverse: !isLeft,
              child: AppImage(path: cover, cacheWidth: 260),
            ),
            // Top shade so the badges stay readable on bright skies.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x66000000), Color(0x00000000)],
                  stops: [0, 0.3],
                ),
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: InfoPill(
                fontSize: 11,
                leading: const Text('🔥', style: TextStyle(fontSize: 12)),
                label: Formatters.compact(stream.viewers),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: LiveBadge(fontSize: 11, showDot: false, gradient: side.gradient),
            ),
            Positioned(left: 6, right: 6, bottom: 6, child: _ScorePlate(side: side)),
            _ResultStamp(side: side),
          ],
        ),
      ),
    );
  }
}

/// Slanted glass score plate with a floating 3D gift box at its outer end.
class _ScorePlate extends ConsumerWidget {
  const _ScorePlate({required this.side});

  final PkSide side;

  static const _height = 44.0;
  static const _giftSize = 56.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLeft = side == PkSide.left;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final score = ref.watch(pkBattleProvider.select(
      (a) => isLeft ? a.value?.leftScore : a.value?.rightScore,
    ));

    return SizedBox(
      height: _giftSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: isLeft ? _giftSize * 0.45 : 0,
            right: isLeft ? 0 : _giftSize * 0.45,
            bottom: 0,
            height: _height,
            child: SlantedPill(
              color: side.color,
              mirrored: !isLeft,
              slant: 14,
              fill: [side.color.withValues(alpha: 0.9), side.color.withValues(alpha: 0.35)],
              padding: EdgeInsets.only(left: isLeft ? _giftSize * 0.62 : 18, right: isLeft ? 18 : _giftSize * 0.62),
              child: Align(
                alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: Tween(begin: 1.25, end: 1.0).animate(animation),
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: Text(
                      Formatters.grouped(score ?? 0),
                      key: ValueKey(score),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        shadows: [Shadow(color: Color(0x99000000), blurRadius: 4, offset: Offset(0, 1))],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: isLeft ? -4 : null,
            right: isLeft ? null : -4,
            bottom: -2,
            child: Breathing(
              float: 3,
              scale: 0.06,
              period: Duration(milliseconds: isLeft ? 1700 : 1900),
              child: Image.asset(
                isLeft ? AppAssets.giftPink : AppAssets.giftBlue,
                width: _giftSize,
                cacheWidth: (_giftSize * dpr).round(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultStamp extends ConsumerWidget {
  const _ResultStamp({required this.side});

  final PkSide side;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (finished, result) = ref.watch(
      pkBattleProvider.select((a) => (a.value?.isFinished ?? false, a.value?.leader)),
    );
    if (!finished) return const SizedBox.shrink();

    final label = result == null ? 'DRAW' : (result == side ? 'WIN' : 'LOSE');
    final won = result == side;
    return ColoredBox(
      color: Colors.black.withValues(alpha: won ? 0.15 : 0.45),
      child: Center(
        child: Transform.rotate(
          angle: -0.2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
              color: won ? const Color(0xFFFFD54F) : Colors.white70,
              shadows: [Shadow(color: won ? const Color(0xFFFF9500) : Colors.black, blurRadius: 18)],
            ),
          ),
        ),
      ),
    );
  }
}
