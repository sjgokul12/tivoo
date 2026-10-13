// Gift panel: Gift card (from features/gift), Like / Share buttons.

import 'package:flutter/material.dart';

import '../../../core/theme/luxe_theme.dart';
import '../../gift/pk_gift_widgets.dart' show PkGiftCard;
import '../core/pk_common_widgets.dart';

/// Right column: Gift card on top, then wide ♥ Like and ↪ Share buttons.
class PkRightColumn extends StatelessWidget {
  final VoidCallback onGift;
  final VoidCallback onLike;
  final VoidCallback onShare;
  final Widget hearts;

  const PkRightColumn({
    super.key,
    required this.onGift,
    required this.onLike,
    required this.onShare,
    required this.hearts,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final pillHeight = (constraints.maxHeight * 0.17).clamp(36.0, 48.0);
        return Column(
          children: [
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(child: PkGiftCard(onTap: onGift)),
                  // Hearts rise from the Gift card (above the Like / Share buttons).
                  Positioned(left: constraints.maxWidth / 2 - 22, width: 44, top: 0, bottom: 20, child: hearts),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _SidePill(
              height: pillHeight,
              label: 'Like',
              onTap: onLike,
              icon: PkGradientIcon(
                Icons.favorite_rounded,
                size: pillHeight * 0.55,
                colors: const [Color(0xFFFFA8D8), LuxeColors.pink],
              ),
            ),
            const SizedBox(height: 8),
            _SidePill(
              height: pillHeight,
              label: 'Share',
              onTap: onShare,
              icon: PkGradientIcon(
                Icons.shortcut_rounded,
                size: pillHeight * 0.55,
                colors: const [LuxeColors.goldLight, LuxeColors.goldDeep],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SidePill extends StatelessWidget {
  final double height;
  final String label;
  final Widget icon;
  final VoidCallback onTap;

  const _SidePill({required this.height, required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: PkNeonBox(
          height: height,
          radius: height / 2,
          borderColors: LuxeColors.neon,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              children: [
                icon,
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
