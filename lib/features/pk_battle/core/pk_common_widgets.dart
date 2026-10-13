// Small widgets shared across the PK battle screen.

import 'package:flutter/material.dart';

import '../../../core/theme/luxe_theme.dart';
import '../../../core/widgets/custom_avatar.dart';

/// Neon-outlined container used by the pills, panels and input bar.
class PkNeonBox extends StatelessWidget {
  final Widget child;
  final double radius;
  final List<Color> borderColors;
  final Color glow;
  final EdgeInsetsGeometry padding;
  final double? height;

  const PkNeonBox({
    super.key,
    required this.child,
    this.radius = 20,
    this.borderColors = LuxeColors.neon,
    this.glow = const Color(0x447B4DFF),
    this.padding = EdgeInsets.zero,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(1.2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(colors: borderColors),
        boxShadow: [BoxShadow(color: glow, blurRadius: 12)],
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius - 1.2),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [LuxeColors.panel, LuxeColors.panelDeep],
          ),
        ),
        child: child,
      ),
    );
  }
}

class PkPanelCircle extends StatelessWidget {
  final double size;
  final Widget child;
  final VoidCallback onTap;
  final String label;
  final Color? accent;

  const PkPanelCircle({
    super.key,
    required this.size,
    required this.child,
    required this.onTap,
    required this.label,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final border = accent ?? LuxeColors.purple;
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(colors: [Color(0xFF241B5C), Color(0xFF0E0B2C)]),
            border: Border.all(color: border, width: 1.3),
            boxShadow: accent != null ? [BoxShadow(color: accent!.withValues(alpha: 0.5), blurRadius: 10)] : null,
          ),
          child: child,
        ),
      ),
    );
  }
}

class PkGradientIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final List<Color> colors;

  const PkGradientIcon(this.icon, {super.key, required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      ).createShader,
      child: Icon(icon, size: size, color: Colors.white),
    );
  }
}

/// Small vector gold crown used next to host and team names.
class PkGoldCrown extends StatelessWidget {
  final double size;
  const PkGoldCrown({super.key, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 0.85,
      child: CustomPaint(painter: _GoldCrownPainter()),
    );
  }
}

class _GoldCrownPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFF9C4), Color(0xFFFFD700), Color(0xFFFF8F00)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Offset.zero & size);

    final body = Path()
      ..moveTo(0, h * 0.85)
      ..lineTo(0, h * 0.35)
      ..lineTo(w * 0.25, h * 0.55)
      ..lineTo(w * 0.5, h * 0.05)
      ..lineTo(w * 0.75, h * 0.55)
      ..lineTo(w, h * 0.35)
      ..lineTo(w, h * 0.85)
      ..close();
    canvas.drawPath(body, paint);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, h * 0.85, w, h * 0.15), const Radius.circular(1)),
      Paint()..color = const Color(0xFFFFD700),
    );
    canvas.drawCircle(Offset(w * 0.5, h * 0.06), w * 0.09, Paint()..color = const Color(0xFFFF1744));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Mini stack of two overlapping member avatars.
class PkAvatarPair extends StatelessWidget {
  final List<String> assets;

  const PkAvatarPair({super.key, required this.assets});

  @override
  Widget build(BuildContext context) {
    const size = 13.0;
    return SizedBox(
      width: size + (assets.length - 1) * 10,
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < assets.length; i++)
            Positioned(
              left: i * 10.0,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: ClipOval(
                  child: CustomAvatar(radius: size / 2, assetPath: assets[i]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
