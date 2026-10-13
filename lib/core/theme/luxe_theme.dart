import 'package:flutter/material.dart';

/// "Luxe" theme shared by Home, Profile, Chat Room and the PK command section:
/// deep indigo/purple background with gold light streaks, dark glass panels with
/// purple → blue neon borders, and gold for anything active or primary.
class LuxeColors {
  LuxeColors._();

  static const Color bgTop = Color(0xFF100A2A);
  static const Color bg = Color(0xFF08071A);
  static const Color bgBottom = Color(0xFF050412);

  static const Color panel = Color(0xF0171340);
  static const Color panelDeep = Color(0xF00D0B28);

  static const Color gold = Color(0xFFFFC928);
  static const Color goldLight = Color(0xFFFFE680);
  static const Color goldDeep = Color(0xFFE59A00);
  static const Color purple = Color(0xFF7B4DFF);
  static const Color violet = Color(0xFFB04DFF);
  static const Color blue = Color(0xFF3D6BFF);
  static const Color pink = Color(0xFFFF2D78);

  static const Color textMuted = Color(0xFFB9B5DA);
  static const Color textDim = Color(0xFF8C88B5);

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [goldLight, gold, goldDeep],
  );

  /// Neon border for glass panels.
  static const List<Color> neon = [Color(0xFF5B3CFF), violet, blue];

  /// Border that starts gold and fades into the neon purple / blue (as on the profile bars).
  static const List<Color> goldToNeon = [gold, violet, blue];
}

/// Shared decorations.
class LuxeDecor {
  LuxeDecor._();

  /// Outer layer of a glass panel: the gradient border + glow.
  static BoxDecoration border({
    double radius = 20,
    List<Color> colors = LuxeColors.neon,
    double glow = 12,
    Color? glowColor,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(colors: colors),
      boxShadow: glow > 0
          ? [BoxShadow(color: glowColor ?? colors[colors.length ~/ 2].withValues(alpha: 0.35), blurRadius: glow)]
          : null,
    );
  }

  /// Inner fill of a glass panel.
  static BoxDecoration fill({double radius = 20}) => BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [LuxeColors.panel, LuxeColors.panelDeep],
    ),
  );

  /// Solid gold pill / button.
  static BoxDecoration goldButton({double radius = 18}) => BoxDecoration(
    borderRadius: BorderRadius.circular(radius),
    gradient: LuxeColors.goldGradient,
    boxShadow: const [BoxShadow(color: Color(0x77FFC928), blurRadius: 14, offset: Offset(0, 3))],
  );
}

/// Glass panel with a neon gradient border (1.3 px).
class LuxePanel extends StatelessWidget {
  final Widget child;
  final double radius;
  final List<Color> borderColors;
  final double glow;
  final EdgeInsetsGeometry padding;
  final double? height;
  final double? width;

  const LuxePanel({
    super.key,
    required this.child,
    this.radius = 20,
    this.borderColors = LuxeColors.neon,
    this.glow = 12,
    this.padding = EdgeInsets.zero,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: const EdgeInsets.all(1.3),
      decoration: LuxeDecor.border(radius: radius, colors: borderColors, glow: glow),
      child: Container(
        padding: padding,
        decoration: LuxeDecor.fill(radius: radius - 1.3),
        child: child,
      ),
    );
  }
}

/// Round glass button with a purple neon ring (top-bar icons) and an optional badge.
class LuxeCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final String label;
  final int badge;
  final bool gold;

  const LuxeCircleButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.size = 42,
    this.badge = 0,
    this.gold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(1.4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: gold
                      ? const SweepGradient(colors: [LuxeColors.goldLight, LuxeColors.goldDeep, LuxeColors.goldLight])
                      : const SweepGradient(
                          colors: [Color(0xFF5B3CFF), LuxeColors.violet, LuxeColors.blue, Color(0xFF5B3CFF)],
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: (gold ? LuxeColors.gold : LuxeColors.purple).withValues(alpha: 0.4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [Color(0xFF241B5C), Color(0xFF0E0B2C)]),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: Colors.white, size: size * 0.5),
                ),
              ),
              if (badge > 0) Positioned(right: -3, top: -3, child: LuxeBadge(count: badge)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small red count badge.
class LuxeBadge extends StatelessWidget {
  final int count;
  const LuxeBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 18),
      height: 18,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFFF2D55), LuxeColors.pink]),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: LuxeColors.bg, width: 1.5),
        boxShadow: const [BoxShadow(color: Color(0x88FF2D55), blurRadius: 6)],
      ),
      child: Text(
        '$count',
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
      ),
    );
  }
}

/// Text painted with the gold gradient.
class LuxeGoldText extends StatelessWidget {
  final String text;
  final TextStyle style;
  const LuxeGoldText(this.text, {super.key, required this.style});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [LuxeColors.goldLight, LuxeColors.gold, LuxeColors.goldDeep],
      ).createShader,
      child: Text(text, style: style.copyWith(color: Colors.white)),
    );
  }
}

/// Background: deep indigo with purple glows and diagonal gold light streaks in the corners.
class LuxeBackdrop extends StatelessWidget {
  const LuxeBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [LuxeColors.bgTop, LuxeColors.bg, LuxeColors.bgBottom],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-1.0, -0.2),
              radius: 0.8,
              colors: [Color(0x3D7B4DFF), Colors.transparent],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(1.0, 0.45),
              radius: 0.8,
              colors: [Color(0x33B04DFF), Colors.transparent],
            ),
          ),
        ),
        RepaintBoundary(child: CustomPaint(painter: _GoldStreaksPainter())),
      ],
    );
  }
}

class _GoldStreaksPainter extends CustomPainter {
  const _GoldStreaksPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    void streak(Offset a, Offset b, double width, double alpha) {
      final paint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            LuxeColors.gold.withValues(alpha: alpha),
            Colors.transparent,
          ],
        ).createShader(Rect.fromPoints(a, b))
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, width * 0.9);
      canvas.drawLine(a, b, paint);
    }

    // Top-left and top-right corners
    streak(Offset(-w * 0.05, h * 0.16), Offset(w * 0.28, -h * 0.02), 26, 0.55);
    streak(Offset(w * 0.55, h * 0.06), Offset(w * 0.78, -h * 0.03), 14, 0.35);
    streak(Offset(w * 0.86, h * 0.1), Offset(w * 1.05, h * 0.0), 18, 0.45);
    // Side edges
    streak(Offset(-w * 0.04, h * 0.48), Offset(w * 0.1, h * 0.38), 14, 0.35);
    streak(Offset(w * 0.92, h * 0.62), Offset(w * 1.04, h * 0.52), 14, 0.35);
    // Bottom corners
    streak(Offset(-w * 0.05, h * 0.98), Offset(w * 0.22, h * 0.84), 24, 0.5);
    streak(Offset(w * 0.8, h * 1.0), Offset(w * 1.05, h * 0.86), 24, 0.5);

    // Gold bokeh sparkles
    final dot = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    for (final (x, y, r, a) in const [
      (0.08, 0.3, 2.5, 0.7),
      (0.94, 0.26, 3.0, 0.6),
      (0.05, 0.7, 2.0, 0.5),
      (0.96, 0.78, 2.5, 0.6),
      (0.5, 0.02, 2.0, 0.5),
    ]) {
      dot.color = LuxeColors.goldLight.withValues(alpha: a);
      canvas.drawCircle(Offset(w * x, h * y), r, dot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Gold three-point crown with jewels (VIP pill, avatar, "Good Vibes", video tiles).
class LuxeCrown extends StatelessWidget {
  final double size;
  const LuxeCrown({super.key, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size(size, size * 0.8), painter: const _CrownPainter());
  }
}

class _CrownPainter extends CustomPainter {
  const _CrownPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final body = Path()
      ..moveTo(w * 0.08, h * 0.86)
      ..lineTo(0, h * 0.3)
      ..lineTo(w * 0.3, h * 0.55)
      ..lineTo(w * 0.5, h * 0.08)
      ..lineTo(w * 0.7, h * 0.55)
      ..lineTo(w, h * 0.3)
      ..lineTo(w * 0.92, h * 0.86)
      ..close();
    final rect = Offset.zero & size;
    canvas.drawPath(
      body,
      Paint()
        ..color = const Color(0x99FFC928)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.08),
    );
    canvas.drawPath(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF4C2), LuxeColors.gold, LuxeColors.goldDeep],
        ).createShader(rect),
    );
    // Band
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(w * 0.08, h * 0.8, w * 0.84, h * 0.17), Radius.circular(h * 0.05)),
      Paint()
        ..shader = const LinearGradient(
          colors: [LuxeColors.goldDeep, LuxeColors.goldLight, LuxeColors.goldDeep],
        ).createShader(rect),
    );
    // Tip pearls
    final pearl = Paint()..color = const Color(0xFFFFF4C2);
    for (final p in [Offset(0, h * 0.28), Offset(w * 0.5, h * 0.07), Offset(w, h * 0.28)]) {
      canvas.drawCircle(p, w * 0.07, pearl);
    }
    canvas.drawCircle(Offset(w * 0.5, h * 0.6), w * 0.07, Paint()..color = const Color(0xFFFF2D78));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
