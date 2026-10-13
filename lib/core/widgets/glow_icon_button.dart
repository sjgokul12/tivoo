import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Shared circular glass icon button with an optional neon glow, used to
/// replace the near-identical ad hoc circular buttons duplicated across
/// screen headers and action bars.
class GlowIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double iconSize;
  final bool showBadge;
  final Color badgeColor;

  /// When true, renders a soft neon glow behind the button at all times
  /// (use for an "active"/highlighted state); otherwise the button only
  /// looks like a plain glass circle.
  final bool glow;
  final Color glowColor;
  final Color? iconColor;
  final Color? backgroundColor;

  const GlowIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 44,
    this.iconSize = 21,
    this.showBadge = false,
    this.badgeColor = AppColors.liveRed,
    this.glow = false,
    this.glowColor = AppColors.glowPink,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        backgroundColor ??
        (isDark ? AppColors.surfaceColor.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.06));
    final defaultIconColor = iconColor ?? (isDark ? AppColors.textPrimary : const Color(0xFF1F1F2C));
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(size / 2),
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bgColor,
                border: Border.all(color: borderColor, width: 0.8),
                boxShadow: glow
                    ? [BoxShadow(color: glowColor.withValues(alpha: 0.45), blurRadius: 16, spreadRadius: 1)]
                    : null,
              ),
              child: Icon(icon, color: defaultIconColor, size: iconSize),
            ),
          ),
        ),
        if (showBadge)
          Positioned(
            top: size * 0.22,
            right: size * 0.25,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: badgeColor.withValues(alpha: 0.6), blurRadius: 4)],
              ),
            ),
          ),
      ],
    );
  }
}
