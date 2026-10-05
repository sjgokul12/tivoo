import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Frosted-glass surface used by every card/panel in the app.
///
/// [blur] adds a real BackdropFilter — keep it for a few large, static panels
/// (login card, bottom nav, sheets). List items should leave it at 0 and rely
/// on the translucent fill, which is far cheaper while scrolling.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 24,
    this.blur = 0,
    this.color,
    this.gradient,
    this.borderColor,
    this.borderGradient,
    this.borderWidth = 1,
    this.glowColor,
    this.glowBlur = 22,
    this.shadows,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double blur;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final Gradient? borderGradient;
  final double borderWidth;
  final Color? glowColor;
  final double glowBlur;

  /// Custom outer glows (e.g. two-tone rim light). Overrides [glowColor].
  final List<BoxShadow>? shadows;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    Widget content = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        color: gradient == null ? (color ?? AppColors.glassFill) : null,
        gradient: gradient,
        border: borderGradient == null
            ? Border.all(color: borderColor ?? AppColors.glassBorder, width: borderWidth)
            : null,
      ),
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );

    if (borderGradient != null) {
      content = CustomPaint(
        foregroundPainter: GradientBorderPainter(
          gradient: borderGradient!,
          radius: borderRadius,
          width: borderWidth,
        ),
        child: content,
      );
    }

    if (blur > 0) {
      content = ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: content,
        ),
      );
    }

    if (glowColor != null || shadows != null) {
      content = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: shadows ??
              [
                BoxShadow(
                  color: glowColor!.withValues(alpha: 0.6),
                  blurRadius: glowBlur,
                  blurStyle: BlurStyle.outer,
                ),
              ],
        ),
        child: content,
      );
    }
    return content;
  }
}

/// Paints a rounded-rect stroke filled with a gradient (neon rim).
class GradientBorderPainter extends CustomPainter {
  const GradientBorderPainter({
    required this.gradient,
    required this.radius,
    this.width = 1,
    this.inset = 0,
  });

  final Gradient gradient;
  final double radius;
  final double width;

  /// Draws the rim this far inside the bounds (for an inner highlight line).
  final double inset;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..shader = gradient.createShader(rect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(inset + width / 2), Radius.circular(radius)),
      paint,
    );
  }

  @override
  bool shouldRepaint(GradientBorderPainter old) =>
      old.gradient != gradient || old.radius != radius || old.width != width || old.inset != inset;
}
