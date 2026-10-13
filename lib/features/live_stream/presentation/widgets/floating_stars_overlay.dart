import 'dart:math';
import 'package:flutter/material.dart';

class FloatingStarsOverlay extends StatefulWidget {
  final Widget child;

  const FloatingStarsOverlay({
    super.key,
    required this.child,
  });

  static FloatingStarsOverlayState? of(BuildContext context) {
    return context.findAncestorStateOfType<FloatingStarsOverlayState>();
  }

  @override
  State<FloatingStarsOverlay> createState() => FloatingStarsOverlayState();
}

class FloatingStarsOverlayState extends State<FloatingStarsOverlay>
    with TickerProviderStateMixin {
  final List<_StarAnimationItem> _stars = [];
  final Random _random = Random();

  void addStars([int count = 3]) {
    for (int i = 0; i < count; i++) {
      Future.delayed(Duration(milliseconds: i * 120), () {
        if (!mounted) return;
        _spawnSingleStar();
      });
    }
  }

  void _spawnSingleStar() {
    if (_stars.length >= 12) return;

    final goldColors = [
      const Color(0xFFFFD700), // Gold
      const Color(0xFFFFC107), // Amber
      const Color(0xFFFFE082), // Light Gold
      const Color(0xFFFFB300), // Rich Gold
      const Color(0xFFFFF176), // Bright Star
    ];

    final controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1800 + _random.nextInt(600)),
    );

    final item = _StarAnimationItem(
      controller: controller,
      color: goldColors[_random.nextInt(goldColors.length)],
      startX: _random.nextDouble() * 70 - 35,
      size: _random.nextDouble() * 16 + 26,
      rotationSpeed: (_random.nextDouble() - 0.5) * 4,
    );

    setState(() {
      _stars.add(item);
    });

    controller.forward().then((_) {
      if (mounted) {
        setState(() {
          _stars.remove(item);
        });
        controller.dispose();
      }
    });
  }

  @override
  void dispose() {
    for (var item in _stars) {
      item.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        RepaintBoundary(
          child: Stack(
            fit: StackFit.passthrough,
            children: _stars.map((item) => _buildAnimatedStar(item)).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAnimatedStar(_StarAnimationItem item) {
    return AnimatedBuilder(
      animation: item.controller,
      builder: (context, child) {
        final progress = item.controller.value;
        // Sway sideways smoothly as it ascends
        final sway = sin(progress * pi * 3) * 26.0;
        final translateY = -progress * 420.0;
        final opacity = (1.0 - progress).clamp(0.0, 1.0);
        final scale = progress < 0.2
            ? progress / 0.2
            : (1.0 - (progress - 0.7).clamp(0.0, 0.3) / 0.3 * 0.3);

        return Positioned(
          right: 32 + item.startX + sway,
          bottom: 110 - translateY,
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: Transform.rotate(
                angle: progress * item.rotationSpeed * pi,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: item.color.withValues(alpha: 0.6),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    size: item.size,
                    color: item.color,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StarAnimationItem {
  final AnimationController controller;
  final Color color;
  final double startX;
  final double size;
  final double rotationSpeed;

  _StarAnimationItem({
    required this.controller,
    required this.color,
    required this.startX,
    required this.size,
    required this.rotationSpeed,
  });
}
