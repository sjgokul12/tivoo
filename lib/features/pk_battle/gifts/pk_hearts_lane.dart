// Rising hearts lane (Like button / double-tap).

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

/// Vertical lane of rising pink hearts (triggered by the heart button / Like tile).
/// Owns its own animation state so the rest of the screen doesn't rebuild per heart.
class PkHeartsLane extends StatefulWidget {
  final bool ambient;

  const PkHeartsLane({super.key, this.ambient = true});

  @override
  State<PkHeartsLane> createState() => PkHeartsLaneState();
}

class PkHeartsLaneState extends State<PkHeartsLane> with TickerProviderStateMixin {
  static const int _maxHearts = 24;
  static const List<Color> _colors = [
    Color(0xFFFF2D6F),
    Color(0xFFFF2D55),
    Color(0xFFFF4081),
    Color(0xFFFF6584),
    Color(0xFFFF1744),
    Color(0xFFFF80AB),
  ];

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
    _ambientTimer = Timer.periodic(const Duration(milliseconds: 550), (_) {
      if (_hearts.length < 14) spawn();
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
      duration: Duration(milliseconds: (2800 / speed).round().clamp(1600, 3600)),
    );
    final heart = _Heart(
      controller: controller,
      startX: _random.nextDouble() * 10 - 5,
      size: 22 + _random.nextDouble() * 8,
      color: _colors[_random.nextInt(_colors.length)],
      sway: (_random.nextDouble() * 2 - 1) * 8,
    );

    setState(() => _hearts.add(heart));
    controller.forward().whenComplete(() {
      if (!mounted) return;
      setState(() => _hearts.remove(heart));
      controller.dispose();
    });
  }

  /// Short staggered burst of hearts (heart button, Like tile).
  void burst() {
    for (var i = 0; i < 5; i++) {
      Future.delayed(Duration(milliseconds: i * 60), () => spawn(speed: 1.25 - i * 0.1));
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
      child: Stack(
        clipBehavior: Clip.none,
        children: [for (final h in _hearts) _RisingHeart(heart: h)],
      ),
    );
  }
}

class _RisingHeart extends StatelessWidget {
  final _Heart heart;
  const _RisingHeart({required this.heart});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: heart.controller,
      builder: (context, child) {
        final t = heart.controller.value;
        return Positioned(
          bottom: 4 + t * 260,
          left: 8 + heart.startX + sin(t * 2 * pi) * heart.sway,
          child: Opacity(
            opacity: (1 - t * 0.92).clamp(0.0, 1.0),
            child: Transform.scale(scale: 0.8 + t * 0.45, child: child),
          ),
        );
      },
      child: Icon(
        Icons.favorite_rounded,
        color: heart.color,
        size: heart.size,
        shadows: [Shadow(color: heart.color.withValues(alpha: 0.75), blurRadius: 12)],
      ),
    );
  }
}

class _Heart {
  final AnimationController controller;
  final double startX;
  final double size;
  final Color color;
  final double sway;

  _Heart({required this.controller, required this.startX, required this.size, required this.color, required this.sway});
}
