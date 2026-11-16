import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String formatFamilyStars(int value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  } else if (value >= 1000) {
    return '${(value / 1000).toStringAsFixed(1)}K';
  }
  return NumberFormat('#,###').format(value);
}

/// Big, highly visible gold STARS badge displayed on the right side of Leader & Member cards.
class FamilyStarsBadge extends StatelessWidget {
  final int stars;
  final bool isLeader;

  const FamilyStarsBadge({
    super.key,
    required this.stars,
    this.isLeader = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: isLeader
            ? const LinearGradient(
                colors: [Color(0xFF2E2200), Color(0xFF1B1400)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFF1E1738), Color(0xFF140F26)],
              ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLeader
              ? const Color(0xFFFFD700)
              : const Color(0xFFFFD700).withValues(alpha: 0.4),
          width: isLeader ? 1.4 : 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: isLeader ? const Color(0x55FFD700) : const Color(0x22FFD700),
            blurRadius: isLeader ? 10 : 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star_rounded,
                  color: const Color(0xFFFFD700),
                  size: isLeader ? 18 : 16,
                ),
                const SizedBox(width: 3),
                Text(
                  formatFamilyStars(stars),
                  style: TextStyle(
                    color: const Color(0xFFFFD700),
                    fontSize: isLeader ? 15 : 13.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 1),
            const Text(
              'STARS',
              style: TextStyle(
                color: Color(0xBBFFD700),
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

