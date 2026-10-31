import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../services/reel_video_manager.dart';
import '../theme/app_colors.dart';

/// Full-screen reel media: the cover (or a dark placeholder) until the video's first
/// frame is ready, then the video. Playback is driven by [ReelVideoManager] and
/// follows [isActive]. Without a video it just shows the cover.
class ReelMediaView extends StatefulWidget {
  final String? videoAssetPath;
  final String? coverAssetPath;
  final String? coverImageUrl;
  final bool isActive;

  const ReelMediaView({
    super.key,
    required this.videoAssetPath,
    this.coverAssetPath,
    this.coverImageUrl,
    this.isActive = true,
  });

  @override
  State<ReelMediaView> createState() => _ReelMediaViewState();
}

class _ReelMediaViewState extends State<ReelMediaView> {
  final _manager = ReelVideoManager.instance;

  String? get _path => (widget.videoAssetPath?.isNotEmpty ?? false) ? widget.videoAssetPath : null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _sync();
    });
  }

  @override
  void didUpdateWidget(covariant ReelMediaView old) {
    super.didUpdateWidget(old);
    if (old.isActive != widget.isActive || old.videoAssetPath != widget.videoAssetPath) _sync();
  }

  void _sync() {
    final path = _path;
    if (path == null) return;
    widget.isActive ? _manager.play(path) : _manager.pause(path);
  }

  @override
  Widget build(BuildContext context) {
    final path = _path;
    if (path == null) return _cover();

    return ValueListenableBuilder<int>(
      valueListenable: _manager.stateUpdates,
      builder: (context, _, _) {
        final controller = _manager.getController(path);
        final ready = controller != null && _manager.isReady(path);
        return Stack(
          fit: StackFit.expand,
          children: [
            if (!ready) _cover(),
            if (ready) ...[
              FittedBox(
                fit: BoxFit.cover,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              ),
              if (controller.value.size.width >= 1080 || controller.value.size.height >= 1080)
                Positioned(
                  top: 54,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: (controller.value.size.width >= 2160 || controller.value.size.height >= 2160)
                            ? AppColors.primaryYellow
                            : Colors.cyanAccent.withValues(alpha: 0.7),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      (controller.value.size.width >= 2160 || controller.value.size.height >= 2160)
                          ? '4K UHD'
                          : '1080p FHD',
                      style: TextStyle(
                        color: (controller.value.size.width >= 2160 || controller.value.size.height >= 2160)
                            ? AppColors.primaryYellow
                            : Colors.cyanAccent,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ),
            ],
            if (widget.isActive && !ready && !_manager.hasError(path))
              Center(
                child: SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primaryYellow.withValues(alpha: 0.8)),
                ),
              ),
            if (widget.isActive && _manager.hasError(path))
              Center(
                child: TextButton.icon(
                  onPressed: () => _manager.retry(path),
                  style: TextButton.styleFrom(backgroundColor: Colors.black54, foregroundColor: Colors.white),
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryYellow),
                  label: const Text('Tap to retry'),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _cover() {
    const placeholder = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF15122B), Color(0xFF07060F)],
        ),
      ),
    );
    final asset = widget.coverAssetPath;
    if (asset != null && asset.isNotEmpty) {
      return Image.asset(asset, fit: BoxFit.cover, errorBuilder: (_, _, _) => placeholder);
    }
    final url = widget.coverImageUrl;
    if (url != null && url.isNotEmpty) {
      return url.startsWith('http')
          ? CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              placeholder: (_, _) => placeholder,
              errorWidget: (_, _, _) => placeholder,
            )
          : Image.file(File(url), fit: BoxFit.cover, errorBuilder: (_, _, _) => placeholder);
    }
    return placeholder;
  }
}
