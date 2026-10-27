import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../theme/app_colors.dart';
import '../utils/video_source.dart';

class LiveVideoPlayer extends StatefulWidget {
  final String playerId;
  final String videoAssetPath;
  final String? placeholderAssetPath;
  final String? placeholderImageUrl;
  final bool autoPlay;
  final bool isMuted;
  final bool showSoundToggle;
  final BoxFit fit;

  const LiveVideoPlayer({
    super.key,
    required this.playerId,
    required this.videoAssetPath,
    this.placeholderAssetPath,
    this.placeholderImageUrl,
    this.autoPlay = true,
    this.isMuted = true,
    this.showSoundToggle = false,
    this.fit = BoxFit.cover,
  });

  @override
  State<LiveVideoPlayer> createState() => _LiveVideoPlayerState();
}

class _LiveVideoPlayerState extends State<LiveVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  late bool _isMuted;
  bool _hasError = false;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _isMuted = widget.isMuted;
    if (widget.autoPlay) {
      _initializeVideo();
    }
  }

  void _handleVisibilityChanged(VisibilityInfo info) {
    if (!mounted) return;
    final visibleFraction = info.visibleFraction;

    if (_controller == null) {
      if (!_isInitializing && visibleFraction > 0.1) {
        _initializeVideo();
      }
      return;
    }

    if (!_controller!.value.isInitialized) return;

    final shouldPlay = widget.autoPlay && visibleFraction > 0.6;
    if (shouldPlay && !_controller!.value.isPlaying) {
      _controller!.play();
    } else if (!shouldPlay && _controller!.value.isPlaying) {
      _controller!.pause();
    }
  }

  void _videoListener() {
    if (!mounted) return;
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      if (!_isInitialized) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  Future<void> _initializeVideo() async {
    if (_isInitializing || _controller != null) return;
    _isInitializing = true;
    try {
      final controller = videoControllerFor(widget.videoAssetPath);
      _controller = controller;
      controller.addListener(_videoListener);

      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }

      await controller.setLooping(true);
      await controller.setVolume(_isMuted ? 0.0 : 1.0);

      if (widget.autoPlay) {
        try {
          await controller.play();
        } catch (playErr) {
          debugPrint('Autoplay blocked, muting and retrying: $playErr');
          _isMuted = true;
          await controller.setVolume(0.0);
          await controller.play();
        }
      }

      if (mounted) {
        setState(() {
          _isInitialized = controller.value.isInitialized;
        });
      }
    } catch (e) {
      debugPrint('LiveVideoPlayer init error for ${widget.videoAssetPath}: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    } finally {
      _isInitializing = false;
    }
  }

  @override
  void didUpdateWidget(covariant LiveVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoAssetPath != widget.videoAssetPath) {
      _cleanupController();
      _isInitialized = false;
      _hasError = false;
      _initializeVideo();
    } else if (oldWidget.isMuted != widget.isMuted) {
      _isMuted = widget.isMuted;
      _controller?.setVolume(_isMuted ? 0.0 : 1.0);
    } else if (oldWidget.autoPlay != widget.autoPlay) {
      if (widget.autoPlay && !(_controller?.value.isPlaying ?? false)) {
        _controller?.play();
      } else if (!widget.autoPlay && (_controller?.value.isPlaying ?? false)) {
        _controller?.pause();
      }
    }
  }

  void _toggleSound() {
    setState(() {
      _isMuted = !_isMuted;
      _controller?.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _cleanupController() {
    if (_controller != null) {
      _controller!.removeListener(_videoListener);
      _controller!.pause();
      _controller!.dispose();
      _controller = null;
    }
  }

  @override
  void dispose() {
    _cleanupController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveVideo = _isInitialized && _controller != null && _controller!.value.isInitialized && !_hasError;

    return VisibilityDetector(
      key: ValueKey('live-video-${widget.playerId}'),
      onVisibilityChanged: _handleVisibilityChanged,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Placeholder while initializing or on error
          Positioned.fill(child: _buildPlaceholder()),

          // 2. Video Player with smooth cross-fade rendering
          if (_controller != null && _controller!.value.isInitialized)
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: hasActiveVideo ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: widget.fit,
                    clipBehavior: Clip.hardEdge,
                    child: SizedBox(
                      width: (_controller!.value.size.width > 0) ? _controller!.value.size.width : 1080,
                      height: (_controller!.value.size.height > 0) ? _controller!.value.size.height : 1920,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                ),
              ),
            ),

          // 3. Subtle non-blocking loading indicator if video is still preparing
          if (!_isInitialized && !_hasError)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                minHeight: 2.0,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryYellow.withValues(alpha: 0.75)),
              ),
            ),

          // 4. Sound Toggle Button (Optional)
          if (widget.showSoundToggle && hasActiveVideo)
            Positioned(
              top: 56,
              right: 16,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleSound,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                  ),
                  child: Icon(
                    _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    if (widget.placeholderAssetPath != null && widget.placeholderAssetPath!.isNotEmpty) {
      return Image.asset(
        widget.placeholderAssetPath!,
        fit: widget.fit,
        alignment: Alignment.center,
        errorBuilder: (context, error, stackTrace) => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B1B2C), Color(0xFF0D0D17)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      );
    }
    if (widget.placeholderImageUrl != null && widget.placeholderImageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.placeholderImageUrl!,
        fit: widget.fit,
        alignment: Alignment.center,
        placeholder: (context, url) => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B1B2C), Color(0xFF0D0D17)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(color: const Color(0xFF1B1B2C)),
      );
    }
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1B1B2C), Color(0xFF0D0D17)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}
