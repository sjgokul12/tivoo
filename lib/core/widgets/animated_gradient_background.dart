import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

/// A dark canvas with a few slow-drifting, soft-edged gradient blobs behind
/// [child]. Used to give screens like Splash/Login/LiveStream/Profile real
/// depth instead of a flat dark background, without the cost of a real blur
/// filter (the blobs fade to transparent via [RadialGradient] instead).
class AnimatedGradientBackground extends StatelessWidget {
  final Widget? child;
  final List<Color> colors;

  /// Base fill painted behind the blobs. Pass null to omit it (e.g. when
  /// layering the blobs as an ambient glow over existing photo content).
  final Color? backgroundColor;

  const AnimatedGradientBackground({
    super.key,
    this.child,
    this.colors = const [AppColors.primaryPink, AppColors.primaryPurple, AppColors.primaryCyan],
    this.backgroundColor = AppColors.background,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (backgroundColor != null) Container(color: backgroundColor),
        Positioned(
          top: -80,
          left: -60,
          child: _blob(colors[0], 260)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveX(begin: 0, end: 40, duration: 9.seconds, curve: Curves.easeInOut)
              .moveY(begin: 0, end: 24, duration: 11.seconds, curve: Curves.easeInOut),
        ),
        Positioned(
          top: 120,
          right: -100,
          child: _blob(colors[1 % colors.length], 300)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveX(begin: 0, end: -30, duration: 10.seconds, curve: Curves.easeInOut)
              .moveY(begin: 0, end: -36, duration: 8.seconds, curve: Curves.easeInOut),
        ),
        Positioned(
          bottom: -120,
          left: -40,
          child: _blob(colors[2 % colors.length], 280)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .moveX(begin: 0, end: 34, duration: 12.seconds, curve: Curves.easeInOut)
              .moveY(begin: 0, end: -20, duration: 9.seconds, curve: Curves.easeInOut),
        ),
        ?child,
      ],
    );
  }

  Widget _blob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color.withValues(alpha: 0.38), color.withValues(alpha: 0)]),
      ),
    );
  }
}
