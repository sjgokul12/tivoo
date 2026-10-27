import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/live_badge.dart';
import '../../../live_stream/presentation/widgets/creator_more_options_sheet.dart';
import '../../data/face_ar_engine.dart';
import '../widgets/effects_studio_panel.dart';

enum _BroadcastStatus { requesting, denied, ready }

/// Go Live camera screen: live camera with Beauty, Filters and Banuba AR effects,
/// then the live broadcast UI.
class GoLiveBroadcastScreen extends StatefulWidget {
  const GoLiveBroadcastScreen({super.key});

  @override
  State<GoLiveBroadcastScreen> createState() => _GoLiveBroadcastScreenState();
}

class _GoLiveBroadcastScreenState extends State<GoLiveBroadcastScreen> with WidgetsBindingObserver {
  final FaceArEngine _engine = FaceArEngine.create();
  _BroadcastStatus _status = _BroadcastStatus.requesting;
  bool _isFlashOn = false;
  bool _panelVisible = true;

  bool _isLive = false;
  Timer? _viewerTimer;
  Timer? _elapsedTimer;
  int _viewerCount = 1240;
  Duration _elapsed = Duration.zero;
  final _random = Random();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _engine.addListener(_onEngine);
    _setup();
  }

  void _onEngine() {
    if (mounted) setState(() {});
  }

  Future<void> _setup() async {
    setState(() => _status = _BroadcastStatus.requesting);
    final camera = await Permission.camera.request();
    final mic = await Permission.microphone.request();
    if (!mounted) return;
    if (!camera.isGranted || !mic.isGranted) {
      setState(() => _status = _BroadcastStatus.denied);
      return;
    }
    await _engine.start();
    if (mounted) setState(() => _status = _BroadcastStatus.ready);
  }

  Future<void> _toggleFlash() async {
    setState(() => _isFlashOn = !_isFlashOn);
    await _engine.setFlash(_isFlashOn);
  }

  void _startGoLive() {
    setState(() {
      _isLive = true;
      _elapsed = Duration.zero;
      _viewerCount = 1240;
    });
    _viewerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) setState(() => _viewerCount = max(100, _viewerCount + _random.nextInt(17) - 7));
    });
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsed += const Duration(seconds: 1));
    });
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
            Text(
              'End Live Stream?',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
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
            child: const Text(
              'End Stream',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
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

  String get _formattedViewers =>
      _viewerCount >= 1000 ? '${(_viewerCount / 1000).toStringAsFixed(1)}K' : _viewerCount.toString();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_status != _BroadcastStatus.ready) return;
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _engine.pause();
    } else if (state == AppLifecycleState.resumed) {
      _engine.resume();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _viewerTimer?.cancel();
    _elapsedTimer?.cancel();
    _engine.removeListener(_onEngine);
    _engine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLive,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _endLiveConfirm();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        body: switch (_status) {
          _BroadcastStatus.requesting => const Center(
            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPink)),
          ),
          _BroadcastStatus.denied => _buildMessageState(
            icon: Icons.no_photography_rounded,
            title: 'Camera access needed',
            message:
                'Tivoo needs camera and microphone access to go live and apply beauty effects. Please enable them in your device settings.',
            actionLabel: 'Open Settings',
            onAction: openAppSettings,
          ),
          _BroadcastStatus.ready => Stack(
            fit: StackFit.expand,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _isLive ? null : () => setState(() => _panelVisible = !_panelVisible),
                child: _engine.buildPreview(context),
              ),
              if (_engine.error != null) _buildErrorBanner(_engine.error!),
              if (!_isLive) _buildPreLiveUI() else _buildActiveLiveUI(),
            ],
          ),
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Pre-live: camera + effects studio
  // ---------------------------------------------------------------------------
  Widget _buildPreLiveUI() {
    final top = MediaQuery.paddingOf(context).top;
    return Stack(
      fit: StackFit.expand,
      children: [
        const _Scrim(top: true),
        Positioned(
          top: top + 8,
          left: 14,
          right: 14,
          child: Row(
            children: [
              _GlassCircle(icon: Icons.close_rounded, label: 'Close', onTap: () => Navigator.of(context).pop()),
              const Spacer(),
              const _GlassPill(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PulseDot(),
                    SizedBox(width: 8),
                    Text(
                      'Live Preview',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              _GlassCircle(icon: Icons.cameraswitch_rounded, label: 'Flip camera', onTap: _engine.flipCamera),
            ],
          ),
        ),
        Positioned(
          right: 14,
          top: top + 72,
          child: _SideRail(
            items: [
              (_isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded, 'Flash', _toggleFlash),
              (
                _panelVisible ? Icons.keyboard_arrow_down_rounded : Icons.auto_awesome_rounded,
                _panelVisible ? 'Hide' : 'Effects',
                () => setState(() => _panelVisible = !_panelVisible),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedSlide(
            offset: _panelVisible ? Offset.zero : const Offset(0, 1.1),
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            child: EffectsStudioPanel(engine: _engine, onGoLive: _startGoLive),
          ),
        ),
        if (!_panelVisible)
          Positioned(
            left: 24,
            right: 24,
            bottom: MediaQuery.paddingOf(context).bottom + 24,
            child: GradientButton(text: 'Go Live', onPressed: _startGoLive),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Live
  // ---------------------------------------------------------------------------
  Widget _buildActiveLiveUI() {
    final top = MediaQuery.paddingOf(context).top;
    return Stack(
      fit: StackFit.expand,
      children: [
        const _Scrim(top: true),
        Positioned(
          top: top + 8,
          left: 14,
          right: 14,
          child: Row(
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      _GlassPill(
                        padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipOval(
                              child: Image.asset(AppAssets.avatarNeha, width: 28, height: 28, fit: BoxFit.cover),
                            ),
                            const SizedBox(width: 7),
                            const Text(
                              'Leena ♡',
                              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
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
                ),
              ),
              const SizedBox(width: 8),
              _GlassCircle(icon: Icons.close_rounded, label: 'End live', onTap: _endLiveConfirm),
            ],
          ),
        ),
        Positioned(
          right: 14,
          top: top + 72,
          child: _SideRail(
            items: [
              (Icons.cameraswitch_rounded, 'Flip', _engine.flipCamera),
              (_isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded, 'Flash', _toggleFlash),
              (Icons.auto_awesome_rounded, 'Effects', () => EffectsStudioPanel.showSheet(context, _engine)),
              (
                Icons.more_horiz_rounded,
                'More',
                () => CreatorMoreOptionsSheet.show(context, streamTitle: 'My Live Broadcast'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String message) {
    return Positioned(
      left: 16,
      right: 16,
      top: MediaQuery.paddingOf(context).top + 64,
      child: Material(
        color: const Color(0xE6301018),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Color(0xFFFF6B6B)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 12.5)),
              ),
            ],
          ),
        ),
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
            Text(title, style: AppTextStyles.heroHeading.copyWith(fontSize: 20), textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(message, style: AppTextStyles.heroSubtitle, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            GradientButton(text: actionLabel, onPressed: onAction),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Small pieces
// =============================================================================

class _Scrim extends StatelessWidget {
  final bool top;
  const _Scrim({required this.top});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top ? 0 : null,
      bottom: top ? null : 0,
      left: 0,
      right: 0,
      height: 140,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: top ? Alignment.topCenter : Alignment.bottomCenter,
              end: top ? Alignment.bottomCenter : Alignment.topCenter,
              colors: [Colors.black.withValues(alpha: 0.55), Colors.transparent],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassCircle extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _GlassCircle({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.35),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _GlassPill({required this.child, this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 9)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: child,
    );
  }
}

/// Vertical frosted capsule of round tools with labels.
class _SideRail extends StatelessWidget {
  final List<(IconData, String, VoidCallback)> items;
  const _SideRail({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (icon, label, onTap) in items)
            Semantics(
              button: true,
              label: label,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Column(
                    children: [
                      Icon(
                        icon,
                        color: Colors.white,
                        size: 25,
                        shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        label,
                        style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.35, end: 1.0).animate(_c),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(color: AppColors.liveRed, shape: BoxShape.circle),
      ),
    );
  }
}
