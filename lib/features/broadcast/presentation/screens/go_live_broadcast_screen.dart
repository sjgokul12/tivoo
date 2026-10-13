import 'dart:async';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glow_icon_button.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/live_badge.dart';

enum _BroadcastStatus { requesting, denied, error, ready }

/// Real camera "go live" broadcaster screen. Shows the device's own camera
/// full-screen with the app's neon-glass live chrome layered on top. There is
/// no backend in this app, so this is a local preview + mock viewer/duration
/// ticker rather than a real broadcast pipeline.
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

  Timer? _viewerTimer;
  Timer? _elapsedTimer;
  int _viewerCount = 128;
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
        setState(() {
          _status = _BroadcastStatus.error;
          _errorMessage = 'No camera was found on this device.';
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
      _startMockLiveTimers();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = _BroadcastStatus.error;
        _errorMessage = e.toString();
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

  void _startMockLiveTimers() {
    _viewerTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      setState(() {
        _viewerCount = max(1, _viewerCount + _random.nextInt(9) - 3);
      });
    });
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2) return;
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    await _startCamera(_cameras[_cameraIndex]);
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
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
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

  void _endLive() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _status != _BroadcastStatus.ready,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || _status != _BroadcastStatus.ready) return;
        _endLive();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(child: _buildBody()),
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
          message:
              'Tivoo needs camera and microphone access to start a live broadcast. '
              'Please enable them in your device settings.',
          actionLabel: 'Open Settings',
          onAction: openAppSettings,
        );
      case _BroadcastStatus.error:
        return _buildMessageState(
          icon: Icons.error_outline_rounded,
          title: 'Camera unavailable',
          message: _errorMessage ?? 'Something went wrong starting the camera.',
          actionLabel: 'Close',
          onAction: () => Navigator.of(context).pop(),
        );
      case _BroadcastStatus.ready:
        return _buildLivePreview();
    }
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

  Widget _buildLivePreview() {
    final controller = _cameraController!;
    final previewSize = controller.value.previewSize;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Full-screen camera preview (preview size is landscape-oriented
        // even in portrait mode, so width/height are swapped to fill).
        if (previewSize != null)
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: previewSize.height,
                height: previewSize.width,
                child: CameraPreview(controller),
              ),
            ),
          ),

        // Top gradient scrim for badge readability
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 120,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ),

        // Top bar: LIVE badge + viewer count, close + flip camera
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const LiveBadge(),
                  const SizedBox(width: 8),
                  MetricBadge(
                    text: _formattedViewers,
                    icon: const Icon(
                      Icons.visibility_outlined,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  MetricBadge(
                    text: _formattedElapsed,
                    icon: const Icon(
                      Icons.fiber_manual_record,
                      color: AppColors.liveRed,
                      size: 12,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (_cameras.length > 1)
                    GlowIconButton(
                      icon: Icons.cameraswitch_rounded,
                      onTap: _flipCamera,
                    ),
                  const SizedBox(width: 10),
                  GlowIconButton(
                    icon: Icons.close_rounded,
                    onTap: _endLive,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Bottom: End Live button
        Positioned(
          left: 20,
          right: 20,
          bottom: 24,
          child: GradientButton(
            text: 'End Live',
            gradient: const LinearGradient(
              colors: [AppColors.liveRed, Color(0xFFB0203E)],
            ),
            onPressed: _endLive,
          ),
        ),
      ],
    );
  }
}
