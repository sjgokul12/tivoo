import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class FloatingHeartsOverlay extends StatefulWidget {
  final Widget child;
  final bool alignLeft; // When true, stars & hearts float strictly on the supported streamer's side (Left - Neha ✨)

  const FloatingHeartsOverlay({
    super.key,
    required this.child,
    this.alignLeft = false,
  });

  static FloatingHeartsOverlayState? of(BuildContext context) {
    return context.findAncestorStateOfType<FloatingHeartsOverlayState>();
  }

  @override
  State<FloatingHeartsOverlay> createState() => FloatingHeartsOverlayState();
}

class FloatingHeartsOverlayState extends State<FloatingHeartsOverlay>
    with TickerProviderStateMixin {
  final List<_FloatingHeartOrStarItem> _items = [];
  final Random _random = Random();

  void addHeart({bool? toLeft}) {
    if (_items.length >= 12) return;

    final bool useLeft = toLeft ?? widget.alignLeft;
    final colors = useLeft
        ? [
            const Color(0xFFFFD600), // Electric Cyber Yellow
            const Color(0xFFFFEA00), // Bright Gold
            const Color(0xFFFF9100), // Amber Gold
            const Color(0xFFFF2D55), // Neon Magenta
            const Color(0xFFFF3366), // Rose Pink
            const Color(0xFFFFD700), // Pure Radiant Gold
          ]
        : [
            const Color(0xFF00E5FF), // Electric Cyan (Opponent team)
            const Color(0xFF00B0FF), // Bright Sky Blue
            const Color(0xFFFFD600), // Radiant Gold
            const Color(0xFFFFEA00), // Bright Gold
            const Color(0xFF7C4DFF), // Neon Purple
            const Color(0xFF00E676), // Spring Green
          ];

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // 70% glowing stars and sparkling stars, 30% neon hearts
    final double randVal = _random.nextDouble();
    final IconData icon = randVal > 0.45
        ? Icons.star_rounded
        : (randVal > 0.25 ? Icons.auto_awesome : Icons.favorite_rounded);

    final item = _FloatingHeartOrStarItem(
      controller: controller,
      color: colors[_random.nextInt(colors.length)],
      startX: _random.nextDouble() * 36 - 18,
      size: _random.nextDouble() * 12 + 22,
      toLeft: useLeft,
      icon: icon,
      rotationSpeed: (_random.nextDouble() - 0.5) * 1.2,
    );

    void doAdd() {
      if (!mounted) return;
      setState(() {
        _items.add(item);
      });
      controller.forward().then((_) {
        if (mounted) {
          setState(() {
            _items.remove(item);
          });
          controller.dispose();
        }
      });
    }

    if (WidgetsBinding.instance.schedulerPhase ==
            SchedulerPhase.persistentCallbacks ||
        WidgetsBinding.instance.schedulerPhase ==
            SchedulerPhase.midFrameMicrotasks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => doAdd());
    } else {
      doAdd();
    }
  }

  @override
  void dispose() {
    for (var item in _items) {
      item.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        RepaintBoundary(
          child: Stack(
            children: _items.map((item) {
              return AnimatedBuilder(
                animation: item.controller,
                builder: (context, child) {
                  final progress = item.controller.value;
                  final opacity = (1.0 - (progress * 0.95)).clamp(0.0, 1.0);
                  // Ascends all the way UP into the supported streamer's video arena
                  final dy = progress * 480;
                  final sway = sin(progress * 3 * pi) * 16.0;
                  final scale = 0.7 + (progress * 0.8).clamp(0.0, 0.65);

                  // If toLeft is true, strictly anchors within the LEFT streamer (Neha ✨):
                  // Clamped between 18.0 and 92.0 so it NEVER enters center or right
                  final double? leftPos = item.toLeft
                      ? (34.0 + (item.startX * 0.6) + sway).clamp(18.0, 92.0)
                      : null;
                  final double? rightPos = item.toLeft
                      ? null
                      : (32.0 - (item.startX * 0.6) - sway).clamp(16.0, 90.0);

                  return Positioned(
                    left: leftPos,
                    right: rightPos,
                    bottom: 120 + dy,
                    child: Opacity(
                      opacity: opacity,
                      child: Transform.rotate(
                        angle: item.rotationSpeed * progress * 2 * pi,
                        child: Transform.scale(
                          scale: scale,
                          child: Icon(
                            item.icon,
                            color: item.color,
                            size: item.size,
                            shadows: [
                              BoxShadow(
                                color: item.color.withValues(alpha: 0.85),
                                blurRadius: 14,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _FloatingHeartOrStarItem {
  final AnimationController controller;
  final Color color;
  final double startX;
  final double size;
  final bool toLeft;
  final IconData icon;
  final double rotationSpeed;

  _FloatingHeartOrStarItem({
    required this.controller,
    required this.color,
    required this.startX,
    required this.size,
    required this.toLeft,
    required this.icon,
    required this.rotationSpeed,
  });
}
