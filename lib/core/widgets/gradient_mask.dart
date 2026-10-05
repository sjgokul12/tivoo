import 'package:flutter/material.dart';

/// Paints [child] (text or icon) with [gradient].
class GradientMask extends StatelessWidget {
  const GradientMask({super.key, required this.gradient, required this.child});

  final Gradient gradient;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(Offset.zero & bounds.size),
      child: child,
    );
  }
}

class GradientText extends StatelessWidget {
  const GradientText(
    this.text, {
    super.key,
    required this.gradient,
    this.style,
    this.textAlign,
    this.maxLines,
  });

  final String text;
  final Gradient gradient;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return GradientMask(
      gradient: gradient,
      child: Text(
        text,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: maxLines == null ? null : TextOverflow.ellipsis,
      ),
    );
  }
}
