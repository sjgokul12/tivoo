import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/reel_video_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../../core/widgets/reel_media_view.dart';
import '../../../../core/widgets/tivoo_share_sheet.dart';
import '../../../home/domain/models/live_stream_card_model.dart';
import '../../../home/presentation/widgets/streamer_id_profile_sheet.dart';
import '../../../live_stream/presentation/widgets/floating_hearts_overlay.dart';
import '../../../profile/presentation/controllers/follow_controller.dart';
import '../../../profile/presentation/widgets/instagram_follow_actions_sheet.dart';
import '../../../profile/presentation/widgets/instagram_follow_button.dart';
import '../../domain/models/explore_stream_model.dart';
import '../controllers/comments_controller.dart';
import '../controllers/posts_controller.dart';
import 'comments_sheet.dart';

/// One full-screen Explore video with the creator info and the action rail.
class ExploreReelCard extends ConsumerStatefulWidget {
  final ExploreStreamModel stream;
  final bool isActive;

  const ExploreReelCard({super.key, required this.stream, this.isActive = true});

  @override
  ConsumerState<ExploreReelCard> createState() => _ExploreReelCardState();
}

class _ExploreReelCardState extends ConsumerState<ExploreReelCard> with SingleTickerProviderStateMixin {
  final _heartsKey = GlobalKey<FloatingHeartsOverlayState>();
  late final AnimationController _likePop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );
  late bool _isLiked = widget.stream.isLiked;
  late int _likes = _parseCount(widget.stream.diamondsCount);

  ExploreStreamModel get _s => widget.stream;

  /// Comments for demo videos get sample comments; real uploads start empty.
  (String, bool) get _commentsKey => (_s.id, _s.post == null);

  bool get _isOwnPost => _s.post != null && ref.watch(postsControllerProvider).isMine(_s.post!);

  static int _parseCount(String s) {
    final clean = s.trim().toUpperCase().replaceAll(',', '');
    final n = double.tryParse(clean.replaceAll(RegExp('[KM]'), '')) ?? 0;
    return (clean.endsWith('M') ? n * 1e6 : clean.endsWith('K') ? n * 1e3 : n).toInt();
  }

  static String _format(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  @override
  void dispose() {
    _likePop.dispose();
    super.dispose();
  }

  void _like({bool fromDoubleTap = false}) {
    setState(() {
      if (_isLiked && !fromDoubleTap) {
        _isLiked = false;
        _likes--;
      } else if (!_isLiked) {
        _isLiked = true;
        _likes++;
      }
    });
    if (_isLiked) {
      _likePop.forward(from: 0);
      _heartsKey.currentState?.addPinkHearts(count: fromDoubleTap ? 3 : 1);
    }
  }

  void _share() {
    final url = 'https://tivoo.app/video/${_s.id}';
    TivooShareSheet.show(
      context,
      title: 'Share Video',
      subtitle: _s.streamerName,
      shareUrl: url,
      shareText: 'Watch ${_s.streamerName}\'s video on Tivoo! $url',
    );
  }

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).height < 720;
    final button = compact ? 44.0 : 48.0;
    final gap = compact ? 14.0 : 18.0;
    final bottom = compact ? 86.0 : 96.0;
    final comments = ref.watch(commentsProvider(_commentsKey)).length;

    return FloatingHeartsOverlay(
      key: _heartsKey,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Video (double-tap to like). Only this layer listens for double taps so the
          // buttons react instantly.
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onDoubleTap: () => _like(fromDoubleTap: true),
            child: ReelMediaView(
              videoAssetPath: _s.videoAssetPath,
              coverAssetPath: _s.coverAssetPath,
              coverImageUrl: _s.coverImageUrl,
              isActive: widget.isActive,
            ),
          ),
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x88000000), Colors.transparent, Colors.transparent, Color(0xCC000000)],
                  stops: [0.0, 0.18, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // Action rail
          Positioned(
            right: 10,
            bottom: bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAvatar(),
                SizedBox(height: gap + 6),
                ScaleTransition(
                  scale: TweenSequence<double>([
                    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 40),
                    TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 60),
                  ]).animate(CurvedAnimation(parent: _likePop, curve: Curves.easeOut)),
                  child: _GlassAction(
                    size: button,
                    count: _format(_likes),
                    highlighted: _isLiked,
                    semantics: _isLiked ? 'Unlike' : 'Like',
                    onTap: _like,
                    icon: _isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                  ),
                ),
                SizedBox(height: gap),
                _GlassAction(
                  size: button,
                  count: comments == 0 ? null : _format(comments),
                  semantics: 'Comments',
                  onTap: () => CommentsSheet.show(context, itemId: _s.id, seed: _s.post == null),
                  icon: Icons.mode_comment_outlined,
                  flipIcon: true,
                ),
                SizedBox(height: gap),
                _GlassAction(
                  size: button,
                  semantics: 'Share',
                  onTap: _share,
                  icon: Icons.send_rounded,
                  iconTurn: -0.42,
                ),
                SizedBox(height: gap),
                ValueListenableBuilder<bool>(
                  valueListenable: ReelVideoManager.instance.isMutedNotifier,
                  builder: (context, muted, _) => _GlassAction(
                    size: button,
                    semantics: muted ? 'Unmute' : 'Mute',
                    onTap: ReelVideoManager.instance.toggleMute,
                    icon: muted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  ),
                ),
                SizedBox(height: gap + 2),
                _SpinningDisc(
                  size: button * 0.8,
                  spinning: widget.isActive,
                  assetPath: _s.avatarAssetPath,
                  imageUrl: _s.avatarUrl,
                ),
              ],
            ),
          ),

          // Creator + caption
          Positioned(
            left: 16,
            right: button + 30,
            bottom: bottom,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _s.streamerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: compact ? 15 : 16.5,
                          fontWeight: FontWeight.w700,
                          shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
                        ),
                      ),
                    ),
                    if (_s.isVerified) ...[
                      const SizedBox(width: 5),
                      const Icon(Icons.verified, color: AppColors.primaryYellow, size: 16),
                    ],
                    if (!_isOwnPost) ...[
                      const SizedBox(width: 10),
                      InstagramFollowButton(
                        userId: _s.id,
                        userName: _s.streamerName,
                        userAvatar: _s.avatarAssetPath ?? _s.avatarUrl ?? '',
                        initialFollowers: 120400,
                        initialFollowing: false,
                        height: 30,
                        fontSize: 11.5,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _s.subCategory,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final rel =
        ref.watch(followControllerProvider)[_s.id] ??
        ref
            .read(followControllerProvider.notifier)
            .getRelationship(
              _s.id,
              defaultName: _s.streamerName,
              defaultAvatar: _s.avatarAssetPath ?? _s.avatarUrl ?? '',
              initialFollowers: 120400,
              initialFollowing: false,
            );

    void onBadgeTap() {
      final follow = ref.read(followControllerProvider.notifier);
      if (rel.isNotFollowing) {
        follow.sendFollowRequest(
          _s.id,
          targetName: _s.streamerName,
          targetAvatar: _s.avatarAssetPath ?? _s.avatarUrl ?? '',
          onStatusNotify: (msg) => ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2))),
        );
      } else if (rel.isRequested) {
        InstagramFollowActionsSheet.showRequestedSheet(
          context,
          relationship: rel,
          streamerId: _s.id,
          onCancelRequest: () => follow.cancelFollowRequest(_s.id),
        );
      } else {
        InstagramFollowActionsSheet.show(context, relationship: rel, streamerId: _s.id);
      }
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () => StreamerIdProfileSheet.show(
            context,
            stream: LiveStreamCardModel(
              id: _s.id,
              userId: '109284',
              streamerName: _s.streamerName,
              streamerBio: _s.subCategory,
              streamerAssetPath: _s.avatarAssetPath,
              streamerAvatarUrl: _s.avatarUrl,
              viewersCount: _s.viewersCount,
              diamondsCount: _s.diamondsCount,
              isFollowing: rel.isFollowingOrMutual,
              isVerified: _s.isVerified,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(2.2),
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: _ringGradient),
            child: CustomAvatar(radius: 22, assetPath: _s.avatarAssetPath, imageUrl: _s.avatarUrl),
          ),
        ),
        if (!_isOwnPost)
          Positioned(
            bottom: -7,
            child: GestureDetector(
              onTap: onBadgeTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: rel.isFollowingOrMutual
                      ? const LinearGradient(colors: [Color(0xFF4CD964), Color(0xFF2E7D32)])
                      : _likeGradient,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Icon(
                  rel.isFollowingOrMutual
                      ? Icons.check_rounded
                      : rel.isRequested
                      ? Icons.schedule_rounded
                      : Icons.add_rounded,
                  color: Colors.white,
                  size: 13,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

const _ringGradient = SweepGradient(colors: [Color(0xFFFFD54F), Color(0xFFFF3B8D), Color(0xFF8E5BFF), Color(0xFFFFD54F)]);
const _likeGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFF6A88), Color(0xFFFF2D55), Color(0xFFE0115F)],
);

/// Frosted-glass round button with an optional count under it; springs while pressed.
class _GlassAction extends StatefulWidget {
  final IconData icon;
  final double size;
  final String semantics;
  final VoidCallback onTap;
  final String? count;
  final bool highlighted;
  final bool flipIcon;
  final double iconTurn;

  const _GlassAction({
    required this.icon,
    required this.size,
    required this.semantics,
    required this.onTap,
    this.count,
    this.highlighted = false,
    this.flipIcon = false,
    this.iconTurn = 0,
  });

  @override
  State<_GlassAction> createState() => _GlassActionState();
}

class _GlassActionState extends State<_GlassAction> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    Widget icon = Icon(widget.icon, color: Colors.white, size: s * 0.5);
    if (widget.flipIcon) icon = Transform.flip(flipX: true, child: icon);
    if (widget.iconTurn != 0) icon = Transform.rotate(angle: widget.iconTurn, child: icon);

    return Semantics(
      button: true,
      label: widget.semantics,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedScale(
              scale: _pressed ? 0.86 : 1,
              duration: const Duration(milliseconds: 110),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: s,
                    height: s,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: widget.highlighted
                          ? _likeGradient
                          : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.white.withValues(alpha: 0.26), Colors.white.withValues(alpha: 0.08)],
                            ),
                      border: Border.all(color: Colors.white.withValues(alpha: widget.highlighted ? 0.6 : 0.28)),
                    ),
                    child: Center(child: icon),
                  ),
                ),
              ),
            ),
            if (widget.count != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.count!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  shadows: [Shadow(color: Color(0x99000000), blurRadius: 8)],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Rotating record with the creator's photo, like the sound disc on Reels / TikTok.
class _SpinningDisc extends StatefulWidget {
  final double size;
  final bool spinning;
  final String? assetPath;
  final String? imageUrl;

  const _SpinningDisc({required this.size, required this.spinning, this.assetPath, this.imageUrl});

  @override
  State<_SpinningDisc> createState() => _SpinningDiscState();
}

class _SpinningDiscState extends State<_SpinningDisc> with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(vsync: this, duration: const Duration(seconds: 5));

  @override
  void initState() {
    super.initState();
    if (widget.spinning) _spin.repeat();
  }

  @override
  void didUpdateWidget(covariant _SpinningDisc old) {
    super.didUpdateWidget(old);
    if (widget.spinning && !_spin.isAnimating) {
      _spin.repeat();
    } else if (!widget.spinning && _spin.isAnimating) {
      _spin.stop();
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _spin,
      child: Container(
        width: widget.size,
        height: widget.size,
        padding: EdgeInsets.all(widget.size * 0.2),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            colors: [Color(0xFF1B1B1F), Color(0xFF3A3A42), Color(0xFF1B1B1F), Color(0xFF3A3A42), Color(0xFF1B1B1F)],
          ),
          boxShadow: [BoxShadow(color: Color(0x88000000), blurRadius: 8)],
        ),
        child: CustomAvatar(radius: widget.size * 0.3, assetPath: widget.assetPath, imageUrl: widget.imageUrl),
      ),
    );
  }
}
