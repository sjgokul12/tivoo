import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/luxe_theme.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../profile/domain/models/follow_relationship.dart';
import '../../../profile/presentation/controllers/follow_controller.dart';
import '../../../profile/presentation/widgets/instagram_follow_actions_sheet.dart';
import '../../domain/models/live_stream_card_model.dart';
import 'home_header.dart';

/// Neon-framed live card: LIVE + viewers, a top-right badge, avatar, name with a
/// verified tick, heat score, interest tags and a Follow button.
class HomeGridStreamCard extends ConsumerWidget {
  final LiveStreamCardModel stream;
  final VoidCallback? onTap;
  final VoidCallback? onFollowTap;

  /// Position in the grid; picks the neon frame colour so neighbours differ.
  final int index;

  const HomeGridStreamCard({super.key, required this.stream, this.onTap, this.onFollowTap, this.index = 0});

  static const List<List<Color>> _frames = [
    [Color(0xFFFFE27A), Color(0xFFFFB300)], // gold
    [Color(0xFF7FE7FF), Color(0xFF2E9BFF)], // cyan
    [Color(0xFFFF7AD9), Color(0xFFE81CFF)], // pink
    [Color(0xFFB98CFF), Color(0xFF5B4BFF)], // purple
    [Color(0xFFFFE27A), Color(0xFFFF9F1C)], // amber
    [Color(0xFFFF6FD8), Color(0xFF9B3CFF)], // magenta
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final frame = _frames[index % _frames.length];
    return RepaintBoundary(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: frame),
            boxShadow: [BoxShadow(color: frame.last.withValues(alpha: 0.45), blurRadius: 14)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: LayoutBuilder(
              builder: (context, c) {
                // Everything scales from the card width so it fits any phone.
                final u = (c.maxWidth / 190).clamp(0.78, 1.25);
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    _cover(),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x55000000), Colors.transparent, Color(0x99000000), Color(0xF2000000)],
                          stops: [0, 0.3, 0.62, 1],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 8 * u,
                      top: 8 * u,
                      child: _LiveViewers(viewers: stream.viewersCount, u: u),
                    ),
                    if (stream.badge != null)
                      Positioned(
                        right: 7 * u,
                        top: 8 * u,
                        child: _Badge(label: stream.badge!, u: u),
                      ),
                    Positioned(left: 8 * u, right: 8 * u, bottom: 8 * u, child: _info(context, ref, u, frame)),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _info(BuildContext context, WidgetRef ref, double u, List<Color> frame) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(1.6 * u),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: frame),
              ),
              child: CustomAvatar(
                radius: 17 * u,
                assetPath: stream.streamerAssetPath ?? AppAssets.status1,
                imageUrl: stream.streamerAvatarUrl,
              ),
            ),
            SizedBox(width: 7 * u),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          stream.streamerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white, fontSize: 14 * u, fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (stream.isVerified) ...[
                        SizedBox(width: 3 * u),
                        Icon(Icons.verified_rounded, color: const Color(0xFF2E9BFF), size: 14 * u),
                      ],
                    ],
                  ),
                  SizedBox(height: 1 * u),
                  Row(
                    children: [
                      Icon(Icons.local_fire_department_rounded, color: const Color(0xFFFF8A00), size: 15 * u),
                      SizedBox(width: 2 * u),
                      Text(
                        '${stream.heatScore ?? 0}',
                        style: TextStyle(color: kHomeGold, fontSize: 13 * u, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(width: 4 * u),
                      // Shrinks instead of overflowing on narrow cards / large text.
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: _buildFollowButtonWidget(context, ref, u),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 5 * u),
        Text(
          stream.tags.join(' | '),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: const Color(0xFFE2E6F0), fontSize: 11 * u),
        ),
      ],
    );
  }

  Widget _cover() {
    final path = (stream.coverAssetPath?.isNotEmpty ?? false)
        ? stream.coverAssetPath!
        : (stream.streamerAssetPath?.isNotEmpty ?? false)
        ? stream.streamerAssetPath!
        : AppAssets.status1;
    return Image.asset(path, fit: BoxFit.cover, cacheWidth: 480, filterQuality: FilterQuality.medium);
  }
  Widget _buildFollowButtonWidget(BuildContext context, WidgetRef ref, double u) {
    final followMap = ref.watch(followControllerProvider);
    final rel = followMap[stream.id] ??
        ref.read(followControllerProvider.notifier).getRelationship(
              stream.id,
              defaultName: stream.streamerName,
              defaultAvatar: stream.streamerAssetPath ?? stream.streamerAvatarUrl ?? '',
              initialFollowers: 120400,
              initialFollowing: stream.isFollowing,
            );

    return _FollowButton(
      status: rel.status,
      u: u,
      onTap: () {
        if (rel.isNotFollowing) {
          ref.read(followControllerProvider.notifier).sendFollowRequest(
                stream.id,
                targetName: stream.streamerName,
                targetAvatar: stream.streamerAssetPath ?? stream.streamerAvatarUrl ?? '',
                onStatusNotify: (msg) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(msg),
                      backgroundColor: const Color(0xFF192233),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
        } else if (rel.isRequested) {
          ref.read(followControllerProvider.notifier).cancelFollowRequest(
                stream.id,
                onStatusNotify: (msg) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(msg),
                      backgroundColor: const Color(0xFF192233),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
        } else if (rel.isFollowingOrMutual) {
          InstagramFollowActionsSheet.show(
            context,
            relationship: rel,
            streamerId: stream.id,
          );
        }
      },
    );
  }
}

class _LiveViewers extends StatelessWidget {
  final String viewers;
  final double u;
  const _LiveViewers({required this.viewers, required this.u});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24 * u,
      decoration: BoxDecoration(color: const Color(0x99000000), borderRadius: BorderRadius.circular(12 * u)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 7 * u),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFF2D55), Color(0xFFFF1F8E)]),
              borderRadius: BorderRadius.circular(12 * u),
            ),
            alignment: Alignment.center,
            child: Row(
              children: [
                Icon(Icons.sensors_rounded, color: Colors.white, size: 12 * u),
                SizedBox(width: 2 * u),
                Text(
                  'LIVE',
                  style: TextStyle(color: Colors.white, fontSize: 10.5 * u, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          SizedBox(width: 5 * u),
          Icon(Icons.visibility_outlined, color: Colors.white, size: 12 * u),
          SizedBox(width: 3 * u),
          Text(
            viewers,
            style: TextStyle(color: Colors.white, fontSize: 11 * u, fontWeight: FontWeight.w700),
          ),
          SizedBox(width: 7 * u),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final double u;
  const _Badge({required this.label, required this.u});

  @override
  Widget build(BuildContext context) {
    final (icon, color, border) = switch (label) {
      'Top Host' => (Icons.workspace_premium_rounded, kHomeGold, Colors.white24),
      'Rising Star' => (Icons.star_rounded, kHomeGold, Colors.white24),
      'Popular' => (Icons.favorite_rounded, const Color(0xFFFF5CC8), const Color(0x66FF5CC8)),
      'New' => (Icons.auto_awesome_rounded, const Color(0xFF3DFFA0), const Color(0x663DFFA0)),
      'Trending' => (Icons.local_fire_department_rounded, const Color(0xFFFF8A00), Colors.white24),
      _ => (Icons.star_rounded, kHomeGold, Colors.white24),
    };
    return Container(
      height: 23 * u,
      padding: EdgeInsets.symmetric(horizontal: 7 * u),
      decoration: BoxDecoration(
        color: const Color(0xB3000000),
        borderRadius: BorderRadius.circular(12 * u),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13 * u),
          SizedBox(width: 3 * u),
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 10 * u, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _FollowButton extends StatelessWidget {
  final FollowStatus status;
  final VoidCallback? onTap;
  final double u;
  const _FollowButton({required this.status, required this.onTap, required this.u});

  @override
  Widget build(BuildContext context) {
    final (label, gradient, color, textColor, border) = switch (status) {
      FollowStatus.notFollowing => (
          'Follow',
          LuxeColors.goldGradient,
          null,
          const Color(0xFF241500),
          null,
        ),
      FollowStatus.requested => (
          'Requested',
          null,
          const Color(0xFF1F2839),
          const Color(0xFFFFDF00),
          Border.all(color: const Color(0x66FFDF00), width: 1.0),
        ),
      FollowStatus.following || FollowStatus.mutual => (
          'Following',
          null,
          const Color(0x99171340),
          Colors.white,
          Border.all(color: LuxeColors.violet),
        ),
      FollowStatus.blocked => (
          'Blocked',
          null,
          const Color(0x44FF2D55),
          Colors.redAccent,
          Border.all(color: Colors.redAccent),
        ),
    };

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 27 * u,
        padding: EdgeInsets.symmetric(horizontal: 10 * u),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: gradient,
          color: color,
          borderRadius: BorderRadius.circular(14 * u),
          border: border,
          boxShadow: status == FollowStatus.notFollowing
              ? const [BoxShadow(color: Color(0x77FFC928), blurRadius: 10)]
              : null,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11.5 * u,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
