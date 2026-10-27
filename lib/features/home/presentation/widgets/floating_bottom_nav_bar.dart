import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/luxe_theme.dart';

/// Luxe floating nav: dark glass bar with a gold → violet → gold edge that rises in a
/// curve around the centre Go Live (+) button. Home · Explore · (+) · Activity · Profile.
/// The selected tab turns gold with a glowing underline. Sizes follow the screen width.
class FloatingBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int index) onTap;
  final VoidCallback onGoLiveTap;

  /// Red badge on the Activity tab (0 hides it).
  final int activityBadgeCount;

  const FloatingBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onGoLiveTap,
    this.activityBadgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final barHeight = (width * 0.17).clamp(62.0, 74.0);
    final orb = barHeight * 0.9;
    final rise = orb * 0.36; // how far the curve and the orb stand above the bar

    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.fromLTRB(12, 0, 12, 8 + bottomInset * 0.5),
        child: SizedBox(
          height: barHeight + rise,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _BarPainter(barHeight: barHeight, bumpRadius: orb / 2 + 7, rise: rise),
                ),
              ),
              Positioned(
                left: 6,
                right: 6,
                bottom: 0,
                height: barHeight,
                child: Row(
                  children: [
                    _NavItem(
                      icon: Icons.explore_rounded,
                      unselectedIcon: Icons.explore_outlined,
                      label: AppStrings.navExplore,
                      selected: currentIndex == 0,
                      height: barHeight,
                      onTap: () => onTap(0),
                    ),
                    _NavItem(
                      icon: Icons.sensors_rounded,
                      unselectedIcon: Icons.sensors_outlined,
                      label: AppStrings.navLive,
                      selected: currentIndex == 1,
                      height: barHeight,
                      onTap: () => onTap(1),
                    ),
                    SizedBox(width: orb + 14),
                    _NavItem(
                      icon: Icons.notifications_rounded,
                      unselectedIcon: Icons.notifications_outlined,
                      label: AppStrings.navActivity,
                      selected: currentIndex == 2,
                      height: barHeight,
                      badge: activityBadgeCount,
                      onTap: () => onTap(2),
                    ),
                    _NavItem(
                      icon: Icons.person_rounded,
                      unselectedIcon: Icons.person_outline_rounded,
                      label: AppStrings.navProfile,
                      selected: currentIndex == 3,
                      height: barHeight,
                      onTap: () => onTap(3),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: rise - orb * 0.3,
                child: _GoLiveOrb(size: orb, onTap: onGoLiveTap),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bar outline: a stadium with a circular rise in the middle, filled dark and stroked
/// with a glowing gold → violet → gold edge.
class _BarPainter extends CustomPainter {
  final double barHeight;
  final double bumpRadius;
  final double rise;

  const _BarPainter({required this.barHeight, required this.bumpRadius, required this.rise});

  @override
  void paint(Canvas canvas, Size size) {
    final top = size.height - barHeight;
    final bar = Path()
      ..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, top, size.width, barHeight), Radius.circular(barHeight / 2)));
    final bumpCenter = Offset(size.width / 2, top - rise + bumpRadius);
    final bump = Path()..addOval(Rect.fromCircle(center: bumpCenter, radius: bumpRadius));
    final shape = Path.combine(PathOperation.union, bar, bump);

    final bounds = Offset.zero & size;
    canvas.drawShadow(shape, Colors.black, 10, false);
    canvas.drawPath(
      shape,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xF5151236), Color(0xF5090818)],
        ).createShader(bounds),
    );

    const edge = LinearGradient(
      colors: [LuxeColors.gold, Color(0xFF9B3CFF), LuxeColors.violet, Color(0xFF9B3CFF), LuxeColors.gold],
      stops: [0, 0.3, 0.5, 0.7, 1],
    );
    canvas.drawPath(
      shape,
      Paint()
        ..shader = edge.createShader(bounds)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(
      shape,
      Paint()
        ..shader = edge.createShader(bounds)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _BarPainter old) =>
      old.barHeight != barHeight || old.bumpRadius != bumpRadius || old.rise != rise;
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData? unselectedIcon;
  final String label;
  final bool selected;
  final double height;
  final int badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    this.unselectedIcon,
    required this.label,
    required this.selected,
    required this.height,
    required this.onTap,
    this.badge = 0,
  });

  static const _idle = Color(0xFFD6D3EA);

  @override
  Widget build(BuildContext context) {
    final iconSize = height * 0.38;
    final currentIcon = selected ? icon : (unselectedIcon ?? icon);

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (selected
                                ? const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Color(0xFFFFF7C2), LuxeColors.goldLight, LuxeColors.gold, LuxeColors.goldDeep],
                                  )
                                : const LinearGradient(colors: [_idle, _idle]))
                            .createShader,
                        child: Icon(
                          currentIcon,
                          size: iconSize,
                          color: Colors.white,
                          shadows: selected
                              ? const [
                                  Shadow(color: Color(0xCCFFC928), blurRadius: 12),
                                  Shadow(color: Color(0x66FF2DC0), blurRadius: 16),
                                ]
                              : null,
                        ),
                      ),
                      if (badge > 0) Positioned(right: -8, top: -6, child: LuxeBadge(count: badge)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    style: TextStyle(
                      color: selected ? LuxeColors.gold : _idle,
                      fontSize: 11.5,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      letterSpacing: 0.2,
                      shadows: selected
                          ? const [
                              Shadow(color: Color(0x88FFC928), blurRadius: 6),
                              Shadow(color: Color(0x44FF2DC0), blurRadius: 10),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(height: 3),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    width: selected ? 28 : 0,
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFF1A8), LuxeColors.gold, Color(0xFFFF9D00)],
                      ),
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: const [
                        BoxShadow(color: Color(0xCCFFC928), blurRadius: 8, spreadRadius: 0.5),
                        BoxShadow(color: Color(0x55FF2DC0), blurRadius: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Raised Go Live button: dark core with a white +, a thick gold ring with a slowly
/// travelling highlight and a soft gold / violet pulse.
class _GoLiveOrb extends StatefulWidget {
  final double size;
  final VoidCallback onTap;
  const _GoLiveOrb({required this.size, required this.onTap});

  @override
  State<_GoLiveOrb> createState() => _GoLiveOrbState();
}

class _GoLiveOrbState extends State<_GoLiveOrb> with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(vsync: this, duration: const Duration(seconds: 4))
    ..repeat();

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return Semantics(
      button: true,
      label: 'Go live',
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _spin,
          builder: (context, child) {
            final pulse = 0.5 + 0.5 * sin(_spin.value * 4 * pi);
            return Container(
              width: size,
              height: size,
              padding: EdgeInsets.all(size * 0.065),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  transform: GradientRotation(_spin.value * 2 * pi),
                  colors: const [
                    LuxeColors.goldLight,
                    LuxeColors.gold,
                    LuxeColors.goldDeep,
                    LuxeColors.gold,
                    Color(0xFFFFF4C2),
                    LuxeColors.goldLight,
                  ],
                ),
                boxShadow: [
                  BoxShadow(color: LuxeColors.gold.withValues(alpha: 0.4 + 0.25 * pulse), blurRadius: 18),
                  BoxShadow(color: LuxeColors.violet.withValues(alpha: 0.3 + 0.2 * pulse), blurRadius: 26),
                ],
              ),
              child: child,
            );
          },
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [Color(0xFF221C55), Color(0xFF0C0A24)]),
            ),
            child: Icon(Icons.add_rounded, color: Colors.white, size: size * 0.55),
          ),
        ),
      ),
    );
  }
}
