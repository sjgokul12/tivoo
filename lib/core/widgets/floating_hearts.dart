import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Hearts that float up whenever [count] increases (likes). Each heart owns a
/// short-lived controller that is disposed when its animation completes.
class FloatingHearts extends StatefulWidget {
  const FloatingHearts({super.key, required this.count});

  final int count;

  @override
  State<FloatingHearts> createState() => _FloatingHeartsState();
}

class _FloatingHeartsState extends State<FloatingHearts> with TickerProviderStateMixin {
  static const _maxHearts = 14;
  static const _colors = [Color(0xFFFF4FA3), Color(0xFFFF7AB8), Color(0xFFE040FB), Color(0xFFFF3B6B)];

  final _random = math.Random();
  final _hearts = <_Heart>[];

  @override
  void didUpdateWidget(FloatingHearts oldWidget) {
    super.didUpdateWidget(oldWidget);
    final added = widget.count - oldWidget.count;
    for (var i = 0; i < math.min(added, 3); i++) {
      _spawn();
    }
  }

  void _spawn() {
    if (_hearts.length >= _maxHearts) return;
    final controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1600 + _random.nextInt(800)),
    );
    final heart = _Heart(
      controller: controller,
      color: _colors[_random.nextInt(_colors.length)],
      size: 22 + _random.nextDouble() * 14,
      drift: 10 + _random.nextDouble() * 18,
      phase: _random.nextDouble() * math.pi * 2,
    );
    controller.forward().whenComplete(() {
      if (!mounted) return;
      setState(() => _hearts.remove(heart));
      controller.dispose();
    });
    setState(() => _hearts.add(heart));
  }

  @override
  void dispose() {
    for (final heart in _hearts) {
      heart.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight;
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                for (final heart in _hearts)
                  AnimatedBuilder(
                    animation: heart.controller,
                    builder: (context, child) {
                      final t = heart.controller.value;
                      return Transform.translate(
                        offset: Offset(math.sin(t * math.pi * 2 + heart.phase) * heart.drift, -t * height),
                        child: Opacity(
                          opacity: (1 - t).clamp(0.0, 1.0),
                          child: Transform.scale(scale: 0.5 + math.min(t * 4, 1) * 0.6, child: child),
                        ),
                      );
                    },
                    child: Icon(Icons.favorite_rounded, color: heart.color, size: heart.size),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Heart {
  _Heart({
    required this.controller,
    required this.color,
    required this.size,
    required this.drift,
    required this.phase,
  });

  final AnimationController controller;
  final Color color;
  final double size;
  final double drift;
  final double phase;
}
