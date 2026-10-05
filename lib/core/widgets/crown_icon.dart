import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../theme/app_colors.dart';
import 'gradient_mask.dart';

/// Gold glowing crown used for verified creators, logo and PK badges.
class CrownIcon extends StatelessWidget {
  const CrownIcon({super.key, this.size = 14});

  final double size;

  @override
  Widget build(BuildContext context) {
    return GradientMask(
      gradient: AppColors.goldGradient,
      child: FaIcon(
        FontAwesomeIcons.crown,
        size: size,
        shadows: const [Shadow(color: Color(0xAAFFB300), blurRadius: 8)],
      ),
    );
  }
}
