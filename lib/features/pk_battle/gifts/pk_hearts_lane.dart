// Rising 3D hearts lane (likes / double-tap), drawn with [Heart3D].

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/widgets/heart_3d.dart';

/// Vertical lane of glossy 3D hearts that rise, sway and flip around their
/// vertical axis while fading out. Owns its own animation state so the rest of
/// the screen doesn't rebuild per heart.
class PkHeartsLane extends StatefulWidget {
  final bool ambient;

  const PkHeartsLane({super.key, this.ambient = false});

  @override
  State<PkHeartsLane> createState() => PkHeartsLaneState();
}

class PkHeartsLaneState extends State<PkHeartsLane> with TickerProviderStateMixin {
  static const int _maxHearts = 20;
  // Bright neon pinks only, like the design.
  static const List<Color> _colors = [Color(0xFFFF2DAA), Color(0xFFFF4FD8), Color(0xFFFF3D9A), Color(0xFFFF5CC4)];

  final List<_Heart> _hearts = [];
  final Random _random = Random();
  Timer? _ambientTimer;

  @override
  void initState() {
    super.initState();
    _syncAmbient();
  }

  @override
  void didUpdateWidget(covariant PkHeartsLane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ambient != widget.ambient) _syncAmbient();
  }

  void _syncAmbient() {
    _ambientTimer?.cancel();
    if (!widget.ambient) return;
    _ambientTimer = Timer.periodic(const Duration(milliseconds: 700), (_) {
      if (_hearts.length < 8) spawn();
    });
  }

  /// Adds one rising heart. Higher [speed] = faster rise.
  void spawn({double speed = 1.0}) {
    if (!mounted) return;
    if (_hearts.length >= _maxHearts) {
      _hearts.removeAt(0).controller.dispose();
    }
    final controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (3200 / speed).round().clamp(1800, 4000)),
    );
    final heart = _Heart(
      controller: controller,
      startX: _random.nextDouble() * 0.24 - 0.12,
      size: 0.8 + _random.nextDouble() * 0.4,
      color: _colors[_random.nextInt(_colors.length)],
      sway: (_random.nextDouble() * 2 - 1) * 0.18,
      spin: 0.6 + _random.nextDouble() * 0.8,
    );

    setState(() => _hearts.add(heart));
    controller.forward().whenComplete(() {
      if (!mounted) return;
      setState(() => _hearts.remove(heart));
      controller.dispose();
    });
  }

  /// Short staggered burst of hearts (like / supporter heart).
  void burst() {
    for (var i = 0; i < 6; i++) {
      Future.delayed(Duration(milliseconds: i * 65), () => spawn(speed: 1.35 - i * 0.08));
    }
  }

  @override
  void dispose() {
    _ambientTimer?.cancel();
    for (final h in _hearts) {
      h.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final laneWidth = constraints.maxWidth.isFinite ? constraints.maxWidth : 60.0;
          final rise = constraints.maxHeight.isFinite ? constraints.maxHeight : 260.0;
          final base = (laneWidth * 0.7).clamp(26.0, 52.0); // heart size before the random factor
          return Stack(
            clipBehavior: Clip.none,
            children: [
              for (final h in _hearts) _RisingHeart(heart: h, laneWidth: laneWidth, rise: rise, baseSize: base),
            ],
          );
        },
      ),
    );
  }
}

class _RisingHeart extends StatelessWidget {
  final _Heart heart;
  final double laneWidth;
  final double rise;
  final double baseSize;

  const _RisingHeart({required this.heart, required this.laneWidth, required this.rise, required this.baseSize});

  @override
  Widget build(BuildContext context) {
    final size = baseSize * heart.size;
    return AnimatedBuilder(
      animation: heart.controller,
      builder: (context, child) {
        final t = Curves.easeOut.transform(heart.controller.value);
        final x = (laneWidth - size) / 2 + (heart.startX + sin(t * 2 * pi) * heart.sway) * laneWidth;
        return Positioned(
          bottom: t * (rise - size),
          left: x,
          child: Opacity(
            // Fully visible for most of the rise, fading out near the top.
            opacity: heart.controller.value < 0.7 ? 1 : ((1 - heart.controller.value) / 0.3).clamp(0.0, 1.0),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002) // perspective
                ..rotateY(sin(t * 2 * pi * heart.spin) * 0.5)
                ..rotateZ(sin(t * pi * 2) * 0.12)
                ..scaleByDouble(0.75 + t * 0.35, 0.75 + t * 0.35, 1, 1),
              child: child,
            ),
          ),
        );
      },
      child: Heart3D(size: size, color: heart.color),
    );
  }
}

class _Heart {
  final AnimationController controller;
  final double startX;
  final double size;
  final Color color;
  final double sway;
  final double spin;

  _Heart({
    required this.controller,
    required this.startX,
    required this.size,
    required this.color,
    required this.sway,
    required this.spin,
  });
}
