import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Glowing pill button with gradient fill and a built-in loading state.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.gradient = AppColors.brandGradient,
    this.height = 56,
    this.isLoading = false,
    this.trailing = const Icon(Icons.arrow_forward_rounded, color: Colors.white),
  });

  final String label;
  final VoidCallback? onPressed;
  final Gradient gradient;
  final double height;
  final bool isLoading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !isLoading;
    final radius = BorderRadius.circular(height / 2);
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled || isLoading ? 1 : 0.6,
      child: DecoratedBox(
        // Base colour + neon glow (pink on the left, blue on the right).
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: AppColors.pink.withValues(alpha: 0.65),
              blurRadius: 18,
              offset: const Offset(-4, 2),
              blurStyle: BlurStyle.outer,
            ),
            BoxShadow(
              color: AppColors.blue.withValues(alpha: 0.65),
              blurRadius: 18,
              offset: const Offset(4, 2),
              blurStyle: BlurStyle.outer,
            ),
          ],
        ),
        // 3D gloss: bright rim, highlight on the top half, shade along the bottom.
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: Colors.white.withValues(alpha: 0.75), width: 1.6),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x66FFFFFF), Color(0x1AFFFFFF), Color(0x00FFFFFF), Color(0x33000030)],
              stops: [0, 0.42, 0.55, 1],
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: radius,
            child: InkWell(
              borderRadius: radius,
              onTap: enabled ? onPressed : null,
              child: SizedBox(
                height: height,
                child: Center(
                  child: isLoading
                      ? const SizedBox.square(
                          dimension: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: height * 0.36,
                                fontWeight: FontWeight.w600,
                                shadows: const [Shadow(color: Color(0x55000040), blurRadius: 4, offset: Offset(0, 1))],
                              ),
                            ),
                            if (trailing != null) ...[const SizedBox(width: 14), trailing!],
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
