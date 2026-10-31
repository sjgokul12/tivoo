import 'dart:async';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/luxe_theme.dart';
import '../../../../core/widgets/glow_icon_button.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/live_badge.dart';
import '../../domain/models/camera_filter_model.dart';
import '../widgets/filter_overlay_widget.dart';
import '../widgets/filter_selection_carousel.dart';
import '../widgets/live_filter_bottom_sheet.dart';
import '../../../live_stream/presentation/widgets/creator_more_options_sheet.dart';
import '../../../pk_battle/core/pk_models.dart';
import '../../../pk_battle/sheets/pk_match_flow.dart';

enum _BroadcastStatus { requesting, denied, error, ready }

/// Go Live camera broadcast screen featuring Instagram/Snapchat-style AR camera filters.
/// Supports pre-live filter selection, real-time animated filter overlays, live broadcasting,
/// on-the-fly filter switching, quick filter carousel, and bottom sheet studio.
class GoLiveBroadcastScreen extends StatefulWidget {
  const GoLiveBroadcastScreen({super.key});

  @override
  State<GoLiveBroadcastScreen> createState() => _GoLiveBroadcastScreenState();
}

class _GoLiveBroadcastScreenState extends State<GoLiveBroadcastScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0;

  _BroadcastStatus _status = _BroadcastStatus.requesting;
  String? _errorMessage;
  bool _useFallbackFeed = false;
  bool _isFlashOn = false;

  // Broadcast state
  bool _isLive = false;
  CameraFilterModel _selectedFilter = MockFilterData.allFilters[1]; // Defaults to Butterfly

  // Live metrics
  Timer? _viewerTimer;
  Timer? _elapsedTimer;
  int _viewerCount = 1240;
  Duration _elapsed = Duration.zero;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setup();
  }

  Future<void> _setup() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (!mounted) return;
    if (!cameraStatus.isGranted || !micStatus.isGranted) {
      setState(() => _status = _BroadcastStatus.denied);
      return;
    }

    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        // Fallback to high quality mock camera feed so reviewers can test filters on simulator
        setState(() {
          _useFallbackFeed = true;
          _status = _BroadcastStatus.ready;
        });
        return;
      }

      final frontIndex = _cameras.indexWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
      );
      _cameraIndex = frontIndex >= 0 ? frontIndex : 0;

      await _startCamera(_cameras[_cameraIndex]);
      if (!mounted) return;
      setState(() => _status = _BroadcastStatus.ready);
    } catch (e) {
      if (!mounted) return;
      // If camera controller initialization errors (e.g. on macOS desktop/simulator), fallback gracefully
      setState(() {
        _useFallbackFeed = true;
        _status = _BroadcastStatus.ready;
      });
    }
  }

  Future<void> _startCamera(CameraDescription description) async {
    final previous = _cameraController;
    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: true,
    );
    _cameraController = controller;
    await controller.initialize();
    await previous?.dispose();
    if (mounted) setState(() {});
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) {
      // Toggle simulated front/back feed
      setState(() => _cameraIndex = (_cameraIndex + 1) % 2);
      return;
    }
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _startCamera(_cameras[_cameraIndex]);
  }

  Future<void> _toggleFlash() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      setState(() => _isFlashOn = !_isFlashOn);
      return;
    }
    try {
      if (_isFlashOn) {
        await controller.setFlashMode(FlashMode.off);
      } else {
        await controller.setFlashMode(FlashMode.torch);
      }
      setState(() => _isFlashOn = !_isFlashOn);
    } catch (_) {
      setState(() => _isFlashOn = !_isFlashOn);
    }
  }

  void _startGoLive() {
    setState(() {
      _isLive = true;
      _elapsed = Duration.zero;
      _viewerCount = 1240;
    });

    _viewerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() {
        _viewerCount = max(100, _viewerCount + _random.nextInt(17) - 7);
      });
    });

    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  void _openLiveFilterSheet() {
    LiveFilterBottomSheet.show(
      context,
      selectedFilter: _selectedFilter,
      onSelectFilter: (newFilter) {
        setState(() => _selectedFilter = newFilter);
      },
    );
  }

  void _openPkBattle() {
    PkMatchFlow(
      context: context,
      host: PkHost(
        name: 'Leena',
        avatarAsset: AppAssets.avatarPriya,
        videoAsset: AppAssets.video1,
        likes: '24.5K',
        viewers: _formattedViewers,
      ),
    ).start();
  }

  void _endLiveConfirm() {
    if (!_isLive) {
      Navigator.of(context).pop();
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16113A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0x33FF2DC0), width: 1.2),
        ),
        title: const Row(
          children: [
            Icon(Icons.sensors_off_rounded, color: AppColors.liveRed, size: 24),
            SizedBox(width: 10),
            Text('End Live Stream?', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'You currently have $_formattedViewers viewers watching your broadcast. Are you sure you want to end this stream?',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Stay Live', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.liveRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('End Stream', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String get _formattedElapsed {
    final minutes = _elapsed.inMinutes.toString().padLeft(2, '0');
    final seconds = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get _formattedViewers {
    if (_viewerCount >= 1000) {
      return '${(_viewerCount / 1000).toStringAsFixed(1)}K';
    }
    return _viewerCount.toString();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _startCamera(controller.description);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewerTimer?.cancel();
    _elapsedTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLive,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _endLiveConfirm();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF070514),
        resizeToAvoidBottomInset: false,
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    switch (_status) {
      case _BroadcastStatus.requesting:
        return const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPink),
          ),
        );
      case _BroadcastStatus.denied:
        return _buildMessageState(
          icon: Icons.no_photography_rounded,
          title: 'Camera access needed',
          message: 'Tivoo needs camera and microphone access to start a live broadcast and apply beauty filters. Please enable them in your device settings.',
          actionLabel: 'Open Settings',
          onAction: openAppSettings,
        );
      case _BroadcastStatus.error:
        return _buildMessageState(
          icon: Icons.error_outline_rounded,
          title: 'Camera unavailable',
          message: _errorMessage ?? 'Something went wrong starting the camera.',
          actionLabel: 'Retry Camera',
          onAction: _setup,
        );
      case _BroadcastStatus.ready:
        return Stack(
          fit: StackFit.expand,
          children: [
            // 1. Full-screen Camera / Stream Preview
            _buildCameraPreview(),

            // 2. Animated AR / Visual Filter Overlay
            FilterOverlayWidget(filter: _selectedFilter),

            // 3. UI Chrome (Pre-Live Screen vs Active Live Screen)
            if (!_isLive)
              _buildPreLiveUI()
            else
              _buildActiveLiveUI(),
          ],
        );
    }
  }

  Widget _buildCameraPreview() {
    final controller = _cameraController;
    if (!_useFallbackFeed && controller != null && controller.value.isInitialized) {
      final previewSize = controller.value.previewSize;
      if (previewSize != null) {
        return SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: previewSize.height,
              height: previewSize.width,
              child: CameraPreview(controller),
            ),
          ),
        );
      }
    }

    // High quality live streamer portrait fallback (for simulator / testing)
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            _cameraIndex == 0 ? AppAssets.avatarPriya : AppAssets.avatarNeha,
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),
          // Subtle warm studio lighting overlay
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.2),
                radius: 1.0,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // SCREEN 2: Pre-Live Filter Selection Studio
  // ---------------------------------------------------------------------------
  Widget _buildPreLiveUI() {
    final topPadding = MediaQuery.paddingOf(context).top;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Top Header: [ X ] [ Go Live Title ] [ Flip Camera ]
        Positioned(
          top: topPadding + 8,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GlowIconButton(
                icon: Icons.close_rounded,
                onTap: () => Navigator.of(context).pop(),
              ),
              const Text(
                'Go Live',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              GlowIconButton(
                icon: Icons.cameraswitch_rounded,
                onTap: _flipCamera,
              ),
            ],
          ),
        ),

        // Bottom Filter Studio Panel
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: FilterSelectionCarousel(
            selectedFilter: _selectedFilter,
            onSelectFilter: (newFilter) {
              setState(() => _selectedFilter = newFilter);
            },
            onGoLiveTap: _startGoLive,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // SCREEN 3: Active Live Broadcast UI
  // ---------------------------------------------------------------------------
  Widget _buildActiveLiveUI() {
    final topPadding = MediaQuery.paddingOf(context).top;
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Top gradient for readability
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 120,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withValues(alpha: 0.65), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),

        // Top Live Bar: [ Avatar + Leena ♡ ] [ LIVE ] [ 👁 1.2K ] [ X ]
        Positioned(
          top: topPadding + 8,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Host Profile Tag + LIVE + Viewers
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0x99000000),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                    ),
                    child: Row(
                      children: [
                        ClipOval(
                          child: Image.asset(
                            AppAssets.avatarNeha,
                            width: 26,
                            height: 26,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Leena ♡',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const LiveBadge(),
                  const SizedBox(width: 6),
                  MetricBadge(
                    text: _formattedViewers,
                    icon: const Icon(Icons.visibility_outlined, color: Colors.white, size: 14),
                  ),
                  const SizedBox(width: 6),
                  MetricBadge(
                    text: _formattedElapsed,
                    icon: const Icon(Icons.fiber_manual_record, color: AppColors.liveRed, size: 10),
                  ),
                ],
              ),

              // End Live Button [ X ]
              GlowIconButton(
                icon: Icons.close_rounded,
                onTap: _endLiveConfirm,
              ),
            ],
          ),
        ),

        // Right Floating Action Column: PK Battle, Flip, Flash, Filter Wand, More Options
        Positioned(
          right: 16,
          top: topPadding + 64,
          child: Column(
            children: [
              _buildRightAction(
                icon: Icons.flash_on_rounded,
                color: const Color(0xFFFF2D55),
                onTap: _openPkBattle,
                label: 'PK',
                hasGlow: true,
              ),
              const SizedBox(height: 12),
              _buildRightAction(
                icon: Icons.cameraswitch_rounded,
                onTap: _flipCamera,
                label: 'Flip',
              ),
              const SizedBox(height: 12),
              _buildRightAction(
                icon: _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                color: _isFlashOn ? const Color(0xFFFFD600) : Colors.white,
                onTap: _toggleFlash,
                label: 'Flash',
              ),
              const SizedBox(height: 12),
              _buildRightAction(
                icon: Icons.auto_awesome_rounded,
                color: const Color(0xFFFF2DC0),
                onTap: _openLiveFilterSheet,
                label: 'Filters',
                hasGlow: true,
              ),
              const SizedBox(height: 12),
              _buildRightAction(
                icon: Icons.more_horiz_rounded,
                onTap: () => CreatorMoreOptionsSheet.show(
                  context,
                  streamTitle: 'My Live Broadcast',
                  onPkBattleTap: _openPkBattle,
                ),
                label: 'More',
              ),
            ],
          ),
        ),

        // Bottom: Quick Horizontal Filter Carousel (Screenshot 3)
        Positioned(
          left: 0,
          right: 0,
          bottom: bottomPadding > 0 ? bottomPadding + 12 : 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Filter Carousel Label Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filter: ${_selectedFilter.name}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                    ),
                    GestureDetector(
                      onTap: _openLiveFilterSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0x66000000),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white24, width: 0.8),
                        ),
                        child: const Row(
                          children: [
                            Text(
                              'All Filters',
                              style: TextStyle(color: LuxeColors.gold, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                            Icon(Icons.keyboard_arrow_up_rounded, color: LuxeColors.gold, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),

              // Horizontal Quick Filters Bar
              SizedBox(
                height: 94,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: MockFilterData.allFilters.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final filter = MockFilterData.allFilters[index];
                    final isSelected = filter.id == _selectedFilter.id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedFilter = filter),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOutCubic,
                            width: isSelected ? 52 : 46,
                            height: isSelected ? 52 : 46,
                            padding: const EdgeInsets.all(2.5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: isSelected
                                  ? LinearGradient(
                                      colors: [filter.primaryColor, const Color(0xFFFFD600)],
                                    )
                                  : const LinearGradient(
                                      colors: [Colors.white24, Colors.white12],
                                    ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: filter.primaryColor.withValues(alpha: 0.7),
                                        blurRadius: 12,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: ClipOval(
                              child: Container(
                                color: const Color(0xFF140F30),
                                child: filter.isNone
                                    ? const Center(
                                        child: Icon(Icons.block_flipped, color: Colors.white70, size: 22),
                                      )
                                    : filter.thumbnailAsset != null
                                        ? Image.asset(
                                            filter.thumbnailAsset!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Icon(
                                              filter.fallbackIcon ?? Icons.auto_awesome,
                                              color: filter.primaryColor,
                                              size: 20,
                                            ),
                                          )
                                        : Icon(
                                            filter.fallbackIcon ?? Icons.auto_awesome,
                                            color: filter.primaryColor,
                                            size: 20,
                                          ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 58,
                            child: Text(
                              filter.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isSelected ? LuxeColors.gold : Colors.white70,
                                fontSize: 10.5,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRightAction({
    required IconData icon,
    required VoidCallback onTap,
    required String label,
    Color color = Colors.white,
    bool hasGlow = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0x66000000),
              border: Border.all(
                color: hasGlow ? const Color(0xFFFF2DC0) : Colors.white.withValues(alpha: 0.25),
                width: 1.2,
              ),
              boxShadow: hasGlow
                  ? [
                      const BoxShadow(
                        color: Color(0x66FF2DC0),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageState({
    required IconData icon,
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.primaryPink, size: 56),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTextStyles.heroHeading.copyWith(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: AppTextStyles.heroSubtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GradientButton(text: actionLabel, onPressed: onAction),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
