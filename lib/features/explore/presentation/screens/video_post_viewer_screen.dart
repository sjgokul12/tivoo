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

/// Full-screen vertical player for uploaded video posts.
class VideoPostViewerScreen extends ConsumerStatefulWidget {
  final List<VideoPost> posts;
  final int initialIndex;

  const VideoPostViewerScreen({super.key, required this.posts, this.initialIndex = 0});

  static Future<void> open(BuildContext context, List<VideoPost> posts, {int initialIndex = 0}) {
    // Release the Explore players so this screen always gets a free video decoder;
    // Explore reloads its video when it's shown again.
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
        title: const Text('Delete video?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This video will be removed from your profile and Explore.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
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
  late final VideoPlayerController _c = videoControllerFor(widget.post.videoUrl);
  bool _ready = false;
  bool _error = false;
  bool _liked = false;
  late int _likes = widget.post.likes;

  @override
  void initState() {
    super.initState();
    _c.addListener(_onTick);
    _c
        .initialize()
        .then((_) {
          if (!mounted) return;
          _c.setLooping(true);
          if (widget.isActive) _c.play();
          setState(() => _ready = true);
        })
        .catchError((_) {
          if (mounted) setState(() => _error = true);
        });
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
          if (_ready)
            FittedBox(
              fit: value.aspectRatio < 0.75 ? BoxFit.cover : BoxFit.contain,
              child: SizedBox(width: value.size.width, height: value.size.height, child: VideoPlayer(_c)),
            )
          else if (_error)
            const Center(
              child: Text('Could not play this video', style: TextStyle(color: Colors.white70)),
            )
          else
            const Center(child: CircularProgressIndicator(color: LuxeColors.gold)),
          if (_ready && !value.isPlaying)
            const Center(child: Icon(Icons.play_arrow_rounded, color: Colors.white70, size: 84)),
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
            left: 16,
            right: 84,
            bottom: 36 + MediaQuery.paddingOf(context).bottom,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    CustomAvatar(radius: 17, imageUrl: post.authorAvatar),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '@${post.authorUsername}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                if (post.caption.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    post.caption,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 13.5),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            right: 10,
            bottom: 36 + MediaQuery.paddingOf(context).bottom,
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
              bottom: MediaQuery.paddingOf(context).bottom,
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
      padding: const EdgeInsets.only(top: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
              shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
