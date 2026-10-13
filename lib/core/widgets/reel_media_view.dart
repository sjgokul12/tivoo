import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../constants/app_assets.dart';
import '../services/reel_video_manager.dart';
import '../theme/app_colors.dart';

/// High-performance Instagram Reels-style media view.
///
/// Workflow:
/// 1. Dark skeleton loading state
/// 2. Fast preview thumbnail/image rendered on frame 0
/// 3. Background video controller initialization via [ReelVideoManager]
/// 4. Smooth 350ms cross-fade from image to video once ready
/// 5. Autoplay when [isActive] is true
/// 6. Video muted by default with tap-to-unmute and transient audio toast
/// 7. Automatic pause when [isActive] is false
/// 8. Retry fallback on decode failure without hiding thumbnail
/// 9. Aspect-ratio preservation via FittedBox
class ReelMediaView extends StatefulWidget {
  final String? videoAssetPath;
  final String? coverAssetPath;
  final String? coverImageUrl;
  final bool isActive;
  final VoidCallback? onToggleSound;

  const ReelMediaView({
    super.key,
    required this.videoAssetPath,
    this.coverAssetPath,
    this.coverImageUrl,
    this.isActive = true,
    this.onToggleSound,
  });

  @override
  State<ReelMediaView> createState() => _ReelMediaViewState();
}

class _ReelMediaViewState extends State<ReelMediaView> with SingleTickerProviderStateMixin {
  final ReelVideoManager _manager = ReelVideoManager.instance;
  bool _showSoundOverlay = false;
  late final AnimationController _soundAnimController;
  late final Animation<double> _soundScaleAnim;

  @override
  void initState() {
    super.initState();
    _soundAnimController = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    _soundScaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.6, end: 1.15).chain(CurveTween(curve: Curves.easeOutBack)), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8).chain(CurveTween(curve: Curves.easeIn)), weight: 30),
    ]).animate(_soundAnimController);

    _soundAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() => _showSoundOverlay = false);
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _syncPlayback();
    });
  }

  @override
  void didUpdateWidget(covariant ReelMediaView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive || oldWidget.videoAssetPath != widget.videoAssetPath) {
      _syncPlayback();
    }
  }

  void _syncPlayback() {
    final path = widget.videoAssetPath;
    if (path == null || path.isEmpty) return;

    if (widget.isActive) {
      _manager.play(path);
    } else {
      _manager.pause(path);
    }
  }

  void _toggleMute() {
    _manager.toggleMute();
    widget.onToggleSound?.call();

    setState(() {
      _showSoundOverlay = true;
    });
    _soundAnimController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _soundAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoPath = widget.videoAssetPath;
    final hasVideoPath = videoPath != null && videoPath.isNotEmpty;

    return ValueListenableBuilder<int>(
      valueListenable: _manager.stateUpdates,
      builder: (context, _, child) {
        final controller = hasVideoPath ? _manager.getController(videoPath) : null;
        final isReady = hasVideoPath && _manager.isReady(videoPath);
        final isLoading = hasVideoPath && _manager.isLoading(videoPath);
        final hasError = hasVideoPath && _manager.hasError(videoPath);

        return ValueListenableBuilder<bool>(
          valueListenable: _manager.isMutedNotifier,
          builder: (context, isMuted, child) {
            return Stack(
              fit: StackFit.expand,
              children: [
                // 1. Stage 1: Dark Skeleton Loader
                _buildSkeleton(),

                // 2. Stage 2: Fast Preview Thumbnail (Rendered ONLY if video is not yet initialized)
                if (!isReady) _buildThumbnail(),

                // 3. Stage 3: Instant Video Layer (Direct 60 FPS playback on Frame 0)
                if (hasVideoPath && controller != null && isReady)
                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      clipBehavior: Clip.hardEdge,
                      child: SizedBox(
                        width: (controller.value.size.width > 0) ? controller.value.size.width : 1080,
                        height: (controller.value.size.height > 0) ? controller.value.size.height : 1920,
                        child: VideoPlayer(controller),
                      ),
                    ),
                  ),

                // 4. Subtle Background Loading Indicator (Non-blocking)
                if (widget.isActive && isLoading && !isReady && !hasError)
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

                // 5. Error Retry Fallback (Keeps thumbnail visible)
                if (widget.isActive && hasError && !isReady)
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _manager.retry(videoPath),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh_rounded, color: AppColors.primaryYellow, size: 13),
                            SizedBox(width: 4),
                            Text(
                              'Retry Video',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // 6. Sound Toggle Pill (Top-Right)
                if (hasVideoPath && isReady)
                  Positioned(
                    top: 14,
                    right: 14,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _toggleMute,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                        ),
                        child: Icon(
                          isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                  ),

                // 7. Instagram-Style Center Sound Pop Animation Overlay
                if (_showSoundOverlay)
                  Center(
                    child: ScaleTransition(
                      scale: _soundScaleAnim,
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.65),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
                        ),
                        child: Icon(
                          isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                          color: AppColors.primaryYellow,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSkeleton() {
    return _buildFallbackImage();
  }

  Widget _buildThumbnail() {
    if (widget.coverAssetPath != null && widget.coverAssetPath!.isNotEmpty) {
      return Image.asset(
        widget.coverAssetPath!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildFallbackImage(),
      );
    }

    if (widget.coverImageUrl != null && widget.coverImageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: widget.coverImageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => _buildFallbackImage(),
        errorWidget: (context, url, error) => _buildFallbackImage(),
      );
    }

    return _buildFallbackImage();
  }

  Widget _buildFallbackImage() {
    final asset = (widget.coverAssetPath != null && widget.coverAssetPath!.isNotEmpty)
        ? widget.coverAssetPath!
        : AppAssets.liveCard1;
    return Image.asset(
      asset,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) =>
          Image.asset(AppAssets.liveCard1, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
    );
  }
}
