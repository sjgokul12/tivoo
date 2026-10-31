import 'package:flutter/material.dart';

import '../../domain/models/gifter_level_model.dart';

/// A premium milestone badge widget matching the Gifter Tier.
///
/// Displays the level number with glowing neon/gold gradients, jewel borders,
/// and subtle animated shine.
class GifterBadgeWidget extends StatelessWidget {
  final int level;
  final GifterTierBracket bracket;
  final double size;
  final bool showLabel;
  final bool isLocked;

  const GifterBadgeWidget({
    super.key,
    required this.level,
    required this.bracket,
    this.size = 28,
    this.showLabel = false,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final s = size;
    final colors = isLocked
        ? [const Color(0xFF424242), const Color(0xFF212121)]
        : bracket.gradientColors;

    final glow = isLocked
        ? Colors.transparent
        : bracket.glowColor.withValues(alpha: 0.5);

    return Container(
      constraints: BoxConstraints(minWidth: s * 1.5),
      height: s,
      padding: EdgeInsets.symmetric(horizontal: s * 0.22, vertical: s * 0.08),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(s * 0.4),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors.length > 2 ? colors.sublist(0, 3) : colors,
        ),
        boxShadow: [
          BoxShadow(
            color: glow,
            blurRadius: s * 0.35,
            spreadRadius: 0.5,
          ),
          const BoxShadow(
            color: Color(0x66000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isLocked
              ? Colors.white24
              : Colors.white.withValues(alpha: 0.8),
          width: 1.1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isLocked ? Icons.lock_rounded : Icons.star_rounded,
            size: s * 0.5,
            color: isLocked ? Colors.white54 : bracket.jewelColor,
          ),
          SizedBox(width: s * 0.12),
          Text(
            'Lv $level',
            style: TextStyle(
              color: isLocked ? Colors.white60 : Colors.white,
              fontSize: s * 0.44,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
              shadows: isLocked
                  ? null
                  : const [
                      Shadow(color: Color(0x99000000), blurRadius: 3, offset: Offset(0, 1)),
                    ],
            ),
          ),
          if (showLabel) ...[
            SizedBox(width: s * 0.15),
            Text(
              bracket.name.toUpperCase(),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: s * 0.36,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

