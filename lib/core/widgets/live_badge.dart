import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class LiveBadge extends StatelessWidget {
  final String text;
  final bool isLive;
  final Widget? icon;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;

  const LiveBadge({
    super.key,
    this.text = 'LIVE',
    this.isLive = true,
    this.icon,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? (isLive ? AppColors.liveRed : AppColors.surfaceColor),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isLive
            ? [BoxShadow(color: AppColors.liveRed.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 2))]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 4),
          ] else if (isLive) ...[
            const _LiveWaveIcon(),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: AppTextStyles.badgeText.copyWith(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _LiveWaveIcon extends StatelessWidget {
  const _LiveWaveIcon();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(right: 2),
      child: Icon(Icons.podcasts_rounded, color: Colors.white, size: 14),
    );
  }
}

class MetricBadge extends StatelessWidget {
  final String text;
  final Widget icon;
  final Color backgroundColor;
  final EdgeInsetsGeometry? padding;

  const MetricBadge({
    super.key,
    required this.text,
    required this.icon,
    this.backgroundColor = const Color(0x99101018),
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: AppTextStyles.badgeText.copyWith(fontSize: 11.5, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
