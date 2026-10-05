import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/animations.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/crown_icon.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/live_badge.dart';
import '../../../../data/mock/mock_data.dart';
import '../../../../data/models/live_stream.dart';
import '../../providers/live_room_controller.dart';

/// Host card (left) + follow / menu / top supporters (right).
class LiveTopBar extends StatelessWidget {
  const LiveTopBar({super.key, required this.stream, required this.onMenu});

  final LiveStream stream;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final supporters = MockData.streams
        .where((s) => s.id != stream.id)
        .take(3)
        .map((s) => s.streamer.avatar)
        .toList(growable: false);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _HostCard(stream: stream)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FollowButton(streamId: stream.id),
                const SizedBox(width: 8),
                _CircleButton(icon: Icons.more_vert_rounded, onTap: onMenu),
              ],
            ),
            const SizedBox(height: 8),
            _TopSupporters(images: supporters),
          ],
        ),
      ],
    );
  }
}

class _HostCard extends StatelessWidget {
  const _HostCard({required this.stream});

  final LiveStream stream;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            // Glowing avatar ring with a crown on top.
            SizedBox(
              width: 62,
              height: 66,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  DecoratedBox(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Color(0xAAFF3FA4), blurRadius: 14, blurStyle: BlurStyle.outer)],
                    ),
                    child: Avatar(
                      image: stream.streamer.avatar,
                      size: 60,
                      ringWidth: 2.6,
                      ringGradient: const SweepGradient(
                        colors: [AppColors.pink, AppColors.purple, AppColors.gold, AppColors.pink],
                      ),
                    ),
                  ),
                  const Positioned(top: -4, left: 4, child: Breathing(scale: 0.12, child: CrownIcon(size: 18))),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: GlassContainer(
                borderRadius: 20,
                color: const Color(0x8C0B0A22),
                borderColor: Colors.white.withValues(alpha: 0.14),
                padding: const EdgeInsets.fromLTRB(10, 6, 12, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            stream.streamer.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const CrownIcon(size: 13),
                      ],
                    ),
                    const SizedBox(height: 3),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const LiveBadge(fontSize: 9.5, pulse: true),
                          const SizedBox(width: 8),
                          const Icon(Icons.visibility_outlined, size: 13, color: Colors.white),
                          const SizedBox(width: 3),
                          Text(
                            Formatters.compact(stream.viewers),
                            style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.only(left: 66),
          child: GlassContainer(
            borderRadius: 16,
            color: const Color(0x8C0B0A22),
            borderColor: const Color(0x55B44CFF),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_rounded, size: 14, color: Color(0xFFE879F9)),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    stream.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFFE879F9), fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FollowButton extends ConsumerWidget {
  const _FollowButton({required this.streamId});

  final String streamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = liveRoomProvider(streamId);
    final following = ref.watch(provider.select((s) => s.isFollowing));
    return Pressable(
      onTap: () => ref.read(provider.notifier).toggleFollow(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(19),
          gradient: following ? null : const LinearGradient(colors: [Color(0xCC3B2A8A), Color(0xCC1E1B4B)]),
          color: following ? const Color(0x33FFFFFF) : null,
          border: Border.all(color: following ? Colors.white24 : const Color(0x99A5B4FC)),
          boxShadow: following
              ? null
              : const [BoxShadow(color: Color(0x668B5CF6), blurRadius: 12, blurStyle: BlurStyle.outer)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              following ? Icons.check_rounded : Icons.person_add_alt_1_rounded,
              size: 18,
              color: following ? Colors.white : AppColors.gold,
            ),
            const SizedBox(width: 6),
            Text(
              following ? 'Following' : 'Follow',
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      scale: 0.88,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xB30B0A22),
          border: Border.all(color: const Color(0x66A5B4FC)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _TopSupporters extends StatelessWidget {
  const _TopSupporters({required this.images});

  final List<String> images;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 18,
      borderWidth: 1.2,
      gradient: const LinearGradient(colors: [Color(0xB31A1440), Color(0xB30B0A22)]),
      borderGradient: const LinearGradient(colors: [Color(0xFFFFC83D), Color(0x33FFFFFF), Color(0xFFB44CFF)]),
      shadows: const [BoxShadow(color: Color(0x55FFB020), blurRadius: 12, blurStyle: BlurStyle.outer)],
      padding: const EdgeInsets.fromLTRB(10, 6, 8, 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CrownIcon(size: 18),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Top Supporters',
                style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 3),
              AvatarStack(images: images, size: 24, overlap: 0.25),
            ],
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 20),
        ],
      ),
    );
  }
}
