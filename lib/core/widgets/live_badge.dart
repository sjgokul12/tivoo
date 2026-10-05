import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'animations.dart';

/// Pink "● LIVE" pill.
class LiveBadge extends StatelessWidget {
  const LiveBadge({super.key, this.fontSize = 11, this.showDot = true, this.gradient, this.pulse = false});

  final double fontSize;
  final bool showDot;
  final Gradient? gradient;

  /// Makes the dot "breathe" like a recording light.
  final bool pulse;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient ?? AppColors.liveGradient,
        borderRadius: BorderRadius.circular(fontSize * 2),
        boxShadow: [
          BoxShadow(
            color: (gradient?.colors.first ?? AppColors.live).withValues(alpha: 0.6),
            blurRadius: 10,
            blurStyle: BlurStyle.outer,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: fontSize * 0.8, vertical: fontSize * 0.25),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showDot) ...[
              if (pulse)
                Breathing(
                  scale: 0.45,
                  period: const Duration(milliseconds: 1100),
                  child: _dot(),
                )
              else
                _dot(),
              SizedBox(width: fontSize * 0.4),
            ],
            Text(
              'LIVE',
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot() => Container(
        width: fontSize * 0.5,
        height: fontSize * 0.5,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.white, blurRadius: 4)],
        ),
      );
}

/// Dark translucent pill with an icon and a label, e.g. "👁 8.4K", "🔥 1.2K".
class InfoPill extends StatelessWidget {
  const InfoPill({super.key, required this.leading, required this.label, this.fontSize = 11});

  final Widget leading;
  final String label;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(fontSize * 2),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: fontSize * 0.75, vertical: fontSize * 0.25),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            leading,
            SizedBox(width: fontSize * 0.35),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
