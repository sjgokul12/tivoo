import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Looping, cover-fit video. Plays only while [isActive] and the app is in
/// the foreground; shows [placeholder] until the first frame is ready.
class AssetVideoPlayer extends StatefulWidget {
  const AssetVideoPlayer({
    super.key,
    required this.asset,
    required this.isActive,
    this.placeholder,
    this.muted = false,
  });

  final String asset;
  final bool isActive;
  final Widget? placeholder;
  final bool muted;

  @override
  State<AssetVideoPlayer> createState() => _AssetVideoPlayerState();
}

class _AssetVideoPlayerState extends State<AssetVideoPlayer> with WidgetsBindingObserver {
  late final VideoPlayerController _controller = VideoPlayerController.asset(
    widget.asset,
    videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
  );
  bool _ready = false;
  bool _appInForeground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _controller.initialize();
      await _controller.setLooping(true);
      if (widget.muted) await _controller.setVolume(0);
      if (!mounted) return;
      setState(() => _ready = true);
      _syncPlayback();
    } catch (error) {
      // Decoder/asset failure: keep showing the placeholder instead of crashing.
      debugPrint('Video init failed for ${widget.asset}: $error');
    }
  }

  void _syncPlayback() {
    if (!_ready) return;
    if (widget.isActive && _appInForeground) {
      _controller.play();
    } else {
      _controller.pause();
    }
  }

  @override
  void didUpdateWidget(AssetVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive) _syncPlayback();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appInForeground = state == AppLifecycleState.resumed;
    _syncPlayback();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final placeholder = widget.placeholder ?? const ColoredBox(color: Colors.black);
    return RepaintBoundary(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: !_ready
            ? SizedBox.expand(key: const ValueKey('placeholder'), child: placeholder)
            : SizedBox.expand(
                key: const ValueKey('video'),
                child: FittedBox(
                  fit: BoxFit.cover,
                  clipBehavior: Clip.hardEdge,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),
      ),
    );
  }
}
