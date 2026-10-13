import 'package:flutter/material.dart';

import '../theme/luxe_theme.dart';

/// Tivoo wordmark in a flowing script (Pacifico): "Tiv" in gold and "oo" in neon
/// violet → blue, with a dark outline and glow so it reads on any background, a crown
/// over the T and an optional spaced tagline. An optional gold play emblem sits in front.
class LuxeTivooLogo extends StatelessWidget {
  /// Font size of the wordmark; everything else scales from it.
  final double size;
  final bool showTagline;
  final bool showEmblem;

  const LuxeTivooLogo({super.key, this.size = 34, this.showTagline = true, this.showEmblem = false});

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(fontFamily: 'Pacifico', fontSize: size, height: 1.15, letterSpacing: 0.5);

    // One layer of the wordmark: outline, glow and the gradient fill are stacked copies.
    Widget word(String text, Gradient fill, Color glow) => Stack(
      children: [
        Text(
          text,
          style: base.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = size * 0.12
              ..color = const Color(0xFF1A0B3D),
            shadows: [
              Shadow(color: glow, blurRadius: size * 0.5),
              Shadow(color: const Color(0xCC000000), blurRadius: 4, offset: Offset(0, size * 0.08)),
            ],
          ),
        ),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: fill.createShader,
          child: Text(text, style: base.copyWith(color: Colors.white)),
        ),
      ],
    );

    final wordmark = Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            word(
              'Tiv',
              const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFF6CF), LuxeColors.goldLight, LuxeColors.gold, LuxeColors.goldDeep],
                stops: [0.0, 0.35, 0.6, 1.0],
              ),
              const Color(0x99FFC928),
            ),
            word(
              'oo',
              const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFE2C6FF), LuxeColors.violet, LuxeColors.blue],
              ),
              const Color(0x99B04DFF),
            ),
          ],
        ),
        Positioned(
          left: size * 0.05,
          top: -size * 0.32,
          child: Transform.rotate(angle: -0.3, child: LuxeCrown(size: size * 0.5)),
        ),
        // Sparkle on the last "o".
        Positioned(
          right: -size * 0.12,
          top: size * 0.12,
          child: Icon(Icons.auto_awesome_rounded, color: LuxeColors.goldLight, size: size * 0.3),
        ),
      ],
    );

    final textBlock = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        wordmark,
        if (showTagline)
          Padding(
            padding: EdgeInsets.only(left: size * 0.08),
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: 'LIVE '),
                  _dot(),
                  const TextSpan(text: ' CONNECT '),
                  _dot(),
                  const TextSpan(text: ' BE REAL'),
                ],
              ),
              style: TextStyle(
                color: LuxeColors.textMuted,
                fontSize: size * 0.2,
                fontWeight: FontWeight.w700,
                letterSpacing: size * 0.02,
                height: 1.0,
              ),
            ),
          ),
      ],
    );

    if (!showEmblem) return textBlock;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Emblem(size: size * 1.2),
        SizedBox(width: size * 0.25),
        textBlock,
      ],
    );
  }

  static TextSpan _dot() => const TextSpan(
    text: '•',
    style: TextStyle(color: LuxeColors.gold),
  );
}

/// Round emblem: gold sweep ring, deep indigo core and a gold play triangle.
class _Emblem extends StatelessWidget {
  final double size;
  const _Emblem({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.06),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [LuxeColors.goldLight, LuxeColors.goldDeep, LuxeColors.violet, LuxeColors.gold, LuxeColors.goldLight],
        ),
        boxShadow: [BoxShadow(color: Color(0x66FFC928), blurRadius: 14)],
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [Color(0xFF2B1F6B), Color(0xFF0E0B2C)]),
        ),
        alignment: Alignment.center,
        child: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: LuxeColors.goldGradient.createShader,
          child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: size * 0.62),
        ),
      ),
    );
  }
}
