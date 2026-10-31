import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import 'package:tivoo/core/services/reel_video_manager.dart';
import 'package:tivoo/core/theme/luxe_theme.dart';
import 'package:tivoo/core/utils/video_source.dart';
import 'package:tivoo/core/widgets/custom_avatar.dart';
import 'package:tivoo/core/widgets/tivoo_share_sheet.dart';
import 'package:tivoo/features/explore/domain/models/video_post.dart';
import 'package:tivoo/features/explore/presentation/controllers/posts_controller.dart';
import 'package:tivoo/features/explore/presentation/widgets/comments_sheet.dart';

/// Full-screen vertical player for uploaded video posts with 4K clarity and mobile responsiveness.
class VideoPostViewerScreen extends ConsumerStatefulWidget {
  final List<VideoPost> posts;
  final int initialIndex;

  const VideoPostViewerScreen({super.key, required this.posts, this.initialIndex = 0});

  static Future<void> open(BuildContext context, List<VideoPost> posts, {int initialIndex = 0}) {
    ReelVideoManager.instance.disposeAll();
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VideoPostViewerScreen(posts: posts, initialIndex: initialIndex),
      ),
    );
  }

  @override
  ConsumerState<VideoPostViewerScreen> createState() => _VideoPostViewerScreenState();
}

class _VideoPostViewerScreenState extends ConsumerState<VideoPostViewerScreen> {
  late final PageController _pages = PageController(initialPage: widget.initialIndex);
  late List<VideoPost> _posts = List.of(widget.posts);
  late int _current = widget.initialIndex;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _delete(VideoPost post) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141927),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete video?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'This video will be removed from your profile and Explore.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel', style: TextStyle(color: Colors.white60))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(postsControllerProvider.notifier).delete(post);
      messenger.showSnackBar(const SnackBar(content: Text('Video deleted')));
      if (!mounted) return;
      if (_posts.length == 1) {
        Navigator.of(context).pop();
      } else {
        setState(() {
          _posts = _posts.where((p) => p.id != post.id).toList();
          _current = _current.clamp(0, _posts.length - 1);
        });
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Could not delete: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final posts = ref.watch(postsControllerProvider);
    final mq = MediaQuery.of(context);
    final isTablet = mq.size.width >= 600;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isTablet ? 480 : double.infinity),
          child: Stack(
            children: [
              PageView.builder(
                controller: _pages,
                scrollDirection: Axis.vertical,
                itemCount: _posts.length,
                onPageChanged: (i) => setState(() => _current = i),
                itemBuilder: (_, i) => _PostPage(
                  key: ValueKey(_posts[i].id),
                  post: _posts[i],
                  isActive: i == _current,
                  isMine: posts.isMine(_posts[i]),
                  onDelete: () => _delete(_posts[i]),
                ),
              ),
              Positioned(
                top: mq.padding.top + 6,
                left: 8,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostPage extends StatefulWidget {
  final VideoPost post;
  final bool isActive;
  final bool isMine;
  final VoidCallback onDelete;

  const _PostPage({
    super.key,
    required this.post,
    required this.isActive,
    required this.isMine,
    required this.onDelete,
  });

  @override
  State<_PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<_PostPage> {
  late VideoPlayerController _c;
  bool _ready = false;
  bool _error = false;
  bool _liked = false;
  late int _likes = widget.post.likes;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    _c = videoControllerFor(widget.post.videoUrl);
    _c.addListener(_onTick);
    _c
        .initialize()
        .then((_) {
          if (!mounted) return;
          _c.setLooping(true);
          if (widget.isActive) _c.play();
          setState(() {
            _ready = true;
            _error = false;
          });
        })
        .catchError((err) {
          debugPrint('VideoPostViewer: playback init error for ${widget.post.videoUrl}: $err');
          if (mounted) setState(() => _error = true);
        });
  }

  void _retry() {
    setState(() {
      _error = false;
      _ready = false;
    });
    _c.removeListener(_onTick);
    _c.dispose();
    _initController();
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(covariant _PostPage old) {
    super.didUpdateWidget(old);
    if (!_ready || old.isActive == widget.isActive) return;
    widget.isActive ? _c.play() : _c.pause();
  }

  @override
  void dispose() {
    _c.removeListener(_onTick);
    _c.dispose();
    super.dispose();
  }

  void _toggleLike() => setState(() {
        _liked = !_liked;
        _likes += _liked ? 1 : -1;
      });

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final value = _c.value;
    final mq = MediaQuery.of(context);
    final isSmall = mq.size.width < 360;
    final bottomInset = mq.padding.bottom + (isSmall ? 18 : 26);
    final is4K = value.isInitialized && (value.size.width >= 2160 || value.size.height >= 2160);
    final is1080 = value.isInitialized && (value.size.width >= 1080 || value.size.height >= 1080);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!_ready) return;
        value.isPlaying ? _c.pause() : _c.play();
      },
      onDoubleTap: () {
        if (!_liked) _toggleLike();
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_ready) ...[
            FittedBox(
              fit: value.aspectRatio < 0.75 ? BoxFit.cover : BoxFit.contain,
              child: SizedBox(width: value.size.width, height: value.size.height, child: VideoPlayer(_c)),
            ),
            if (is1080)
              Positioned(
                top: mq.padding.top + 10,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: is4K ? LuxeColors.gold : Colors.cyanAccent.withValues(alpha: 0.8),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.high_quality_rounded,
                        color: is4K ? LuxeColors.gold : Colors.cyanAccent,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        is4K ? '4K Ultra HD' : '1080p Full HD',
                        style: TextStyle(
                          color: is4K ? LuxeColors.gold : Colors.cyanAccent,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ] else if (_error)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.white54, size: 36),
                  const SizedBox(height: 10),
                  const Text('Video player initializing...', style: TextStyle(color: Colors.white70, fontSize: 13.5)),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _retry,
                    style: TextButton.styleFrom(backgroundColor: Colors.white12, foregroundColor: Colors.white),
                    icon: const Icon(Icons.refresh_rounded, color: LuxeColors.gold, size: 16),
                    label: const Text('Tap to Retry', style: TextStyle(fontSize: 13)),
                  ),
                ],
              ),
            )
          else
            const Center(child: CircularProgressIndicator(color: LuxeColors.gold, strokeWidth: 2.5)),
          if (_ready && !value.isPlaying)
            const Center(child: Icon(Icons.play_arrow_rounded, color: Colors.white70, size: 76)),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x66000000), Colors.transparent, Colors.transparent, Color(0xB3000000)],
                stops: [0, 0.2, 0.6, 1],
              ),
            ),
          ),
          Positioned(
            left: 14,
            right: 80,
            bottom: bottomInset,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CustomAvatar(radius: isSmall ? 15 : 17, imageUrl: post.authorAvatar),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '@${post.authorUsername}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white, fontSize: isSmall ? 14 : 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                if (post.caption.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    post.caption,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white, fontSize: isSmall ? 12.5 : 13.5),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            right: 8,
            bottom: bottomInset,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SideButton(
                  icon: _liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: _liked ? const Color(0xFFFF2D55) : Colors.white,
                  label: '$_likes',
                  onTap: _toggleLike,
                ),
                _SideButton(
                  icon: Icons.mode_comment_outlined,
                  label: 'Comment',
                  onTap: () => CommentsSheet.show(context, itemId: post.id, seed: false),
                ),
                _SideButton(
                  icon: Icons.share_rounded,
                  label: 'Share',
                  onTap: () => TivooShareSheet.show(
                    context,
                    title: 'Share Video',
                    subtitle: '@${post.authorUsername}',
                    shareUrl: isNetworkVideo(post.videoUrl) ? post.videoUrl : 'https://tivoo.app/video/${post.id}',
                    shareText: 'Watch @${post.authorUsername} on Tivoo!',
                  ),
                ),
                if (widget.isMine)
                  _SideButton(icon: Icons.delete_outline_rounded, label: 'Delete', onTap: widget.onDelete),
              ],
            ),
          ),
          if (_ready)
            Positioned(
              left: 0,
              right: 0,
              bottom: mq.padding.bottom,
              child: VideoProgressIndicator(
                _c,
                allowScrubbing: true,
                colors: const VideoProgressColors(playedColor: LuxeColors.gold, bufferedColor: Colors.white24),
              ),
            ),
        ],
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SideButton({required this.icon, required this.label, required this.onTap, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 30,
              shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
