import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Widget? trailingIcon;
  final Widget? leadingIcon;
  final Gradient gradient;
  final double height;
  final double? width;
  final double borderRadius;
  final TextStyle? textStyle;
  final bool isLoading;
  final List<BoxShadow>? boxShadow;

  const GradientButton({
    super.key,
    required this.text,
    this.onPressed,
    this.trailingIcon,
    this.leadingIcon,
    this.gradient = AppColors.getStartedButtonGradient,
    this.height = 56,
    this.width,
    this.borderRadius = 32,
    this.textStyle,
    this.isLoading = false,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow:
            boxShadow ??
            [
              BoxShadow(
                color:
                    (gradient is LinearGradient ? (gradient as LinearGradient).colors.first : AppColors.primaryYellow)
                        .withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: isLoading ? null : onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: width == null ? MainAxisSize.max : MainAxisSize.min,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
                    ),
                  )
                else ...[
                  if (leadingIcon != null) ...[leadingIcon!, const SizedBox(width: 8)],
                  Flexible(
                    child: Text(
                      text,
                      style: textStyle ?? AppTextStyles.buttonLarge,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (trailingIcon != null) ...[const SizedBox(width: 10), trailingIcon!],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
