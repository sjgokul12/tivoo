import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Circular glass button with a soft neon rim — header icons, live actions.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.child,
    required this.onTap,
    this.size = 44,
    this.glowColor,
    this.badge = false,
    this.tooltip,
  });

  final Widget child;
  final VoidCallback onTap;
  final double size;
  final Color? glowColor;
  final bool badge;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    Widget button = Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0B0B24).withValues(alpha: 0.75),
            border: Border.all(
              color: (glowColor ?? Colors.white).withValues(alpha: glowColor == null ? 0.18 : 0.7),
            ),
            boxShadow: glowColor == null
                ? null
                : [BoxShadow(color: glowColor!.withValues(alpha: 0.55), blurRadius: 14, blurStyle: BlurStyle.outer)],
          ),
          child: Center(child: child),
        ),
      ),
    );

    if (badge) {
      button = Stack(
        clipBehavior: Clip.none,
        children: [
          button,
          Positioned(
            right: size * 0.18,
            top: size * 0.16,
            child: Container(
              width: size * 0.2,
              height: size * 0.2,
              decoration: BoxDecoration(
                color: AppColors.live,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 1.5),
              ),
            ),
          ),
        ],
      );
    }
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}
