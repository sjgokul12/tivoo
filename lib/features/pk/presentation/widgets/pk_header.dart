import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/animations.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/crown_icon.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/live_badge.dart';
import '../../../../data/models/live_stream.dart';
import '../../../../data/models/pk_battle.dart';
import '../../providers/pk_battle_controller.dart';
import 'slanted_pill.dart';

/// Side colour scheme shared by every PK widget.
extension PkSideStyle on PkSide {
  Color get color => this == PkSide.left ? AppColors.pink : AppColors.cyan;

  LinearGradient get gradient => this == PkSide.left
      ? const LinearGradient(colors: [Color(0xFFFF4FB0), Color(0xFFB44CFF)])
      : const LinearGradient(colors: [Color(0xFF38BDF8), Color(0xFF2563EB)]);
}

/// Two creator pills with the "PK BATTLE" emblem between them.
class PkHeader extends StatelessWidget {
  const PkHeader({super.key, required this.battle});

  final PkBattle battle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88,
      // Room for the crown that sits above the emblem.
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [
          Expanded(child: _CreatorPill(stream: battle.left, side: PkSide.left)),
          const _PkEmblem(),
          Expanded(child: _CreatorPill(stream: battle.right, side: PkSide.right)),
        ],
      ),
    );
  }
}

class _CreatorPill extends StatelessWidget {
  const _CreatorPill({required this.stream, required this.side});

  final LiveStream stream;
  final PkSide side;

  @override
  Widget build(BuildContext context) {
    final isLeft = side == PkSide.left;
    final avatar = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: side.color.withValues(alpha: 0.7), blurRadius: 14, blurStyle: BlurStyle.outer)],
      ),
      child: Avatar(image: stream.streamer.avatar, size: 46, ringGradient: side.gradient, ringWidth: 2.2),
    );
    final info = Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: isLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isLeft) ...[const CrownIcon(size: 11), const SizedBox(width: 3)],
              Flexible(
                child: Text(
                  stream.streamer.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              if (isLeft) ...[const SizedBox(width: 3), const CrownIcon(size: 11)],
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              children: [
                LiveBadge(fontSize: 9, showDot: false, gradient: side.gradient),
                const SizedBox(width: 6),
                const Text('🔥', style: TextStyle(fontSize: 11)),
                const SizedBox(width: 2),
                Text(
                  Formatters.compact(stream.viewers * 15),
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return SlantedPill(
      color: side.color,
      mirrored: !isLeft,
      chevron: true,
      slant: 16,
      fill: [side.color.withValues(alpha: 0.5), const Color(0x4D120A30)],
      padding: EdgeInsets.fromLTRB(isLeft ? 4 : 15, 4, isLeft ? 15 : 4, 4),
      child: Row(
        children: isLeft
            ? [avatar, const SizedBox(width: 6), info]
            : [info, const SizedBox(width: 6), avatar],
      ),
    );
  }
}

/// "PK BATTLE" crest artwork, gently breathing.
class _PkEmblem extends StatelessWidget {
  const _PkEmblem();

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return SizedBox(
      width: 78,
      child: OverflowBox(
        maxHeight: 112,
        child: Breathing(
          scale: 0.05,
          period: const Duration(milliseconds: 2200),
          child: Image.asset(AppAssets.pkBattle, width: 104, cacheWidth: (104 * dpr).round()),
        ),
      ),
    );
  }
}

/// "Team Neha 👑 (avatars) 🏆 1.2M" strip above each video.
class PkTeamBar extends ConsumerWidget {
  const PkTeamBar({super.key, required this.name, required this.supporters, required this.side});

  final String name;
  final List<String> supporters;
  final PkSide side;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(pkBattleProvider.select(
      (a) => side == PkSide.left ? a.value?.leftScore : a.value?.rightScore,
    ));
    return GlassContainer(
      borderRadius: 14,
      color: const Color(0x99141238),
      borderColor: side.color.withValues(alpha: 0.5),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      child: Row(
        children: [
          // Shrinks to fit rather than truncating the team name.
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    'Team $name',
                    maxLines: 1,
                    style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 3),
                  const CrownIcon(size: 10),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          AvatarStack(images: supporters, size: 17, overlap: 0.5),
          const SizedBox(width: 4),
          const Text('🏆', style: TextStyle(fontSize: 11)),
          Text(
            Formatters.compact(score ?? 0),
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
