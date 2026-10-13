import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color? color;
  final BorderRadius? borderRadius;
  final Border? border;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;

  /// Optional neon glow rendered as a soft outer shadow behind the glass.
  final Color? glowColor;
  final double glowBlur;
  final double glowSpread;

  /// Optional gradient border (takes precedence over [border] when set).
  final Gradient? gradientBorder;
  final double gradientBorderWidth;

  /// Whether to use BackdropFilter. When false or blur == 0, uses high-performance pure glass styling.
  final bool enableBlur;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 16.0,
    this.opacity = 0.65,
    this.enableBlur = true,
    this.color,
    this.borderRadius,
    this.border,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.glowColor,
    this.glowBlur = 24.0,
    this.glowSpread = 0.0,
    this.gradientBorder,
    this.gradientBorderWidth = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(20);
    final effectiveColor = color ?? AppColors.glassBackground.withValues(alpha: opacity);

    Widget content;
    if (enableBlur && blur > 0) {
      content = ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(padding: padding, color: effectiveColor, child: child),
        ),
      );
    } else {
      content = Container(
        padding: padding,
        decoration: BoxDecoration(borderRadius: radius, color: effectiveColor),
        child: child,
      );
    }

    if (gradientBorder != null) {
      content = Container(
        decoration: BoxDecoration(borderRadius: radius, gradient: gradientBorder),
        padding: EdgeInsets.all(gradientBorderWidth),
        child: ClipRRect(borderRadius: radius, child: content),
      );
    }

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        border: gradientBorder == null ? (border ?? Border.all(color: AppColors.borderSubtle, width: 0.8)) : null,
        boxShadow: glowColor == null
            ? null
            : [BoxShadow(color: glowColor!.withValues(alpha: 0.45), blurRadius: glowBlur, spreadRadius: glowSpread)],
      ),
      child: content,
    );
  }
}
