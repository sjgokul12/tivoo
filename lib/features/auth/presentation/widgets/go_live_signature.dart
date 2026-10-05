import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

/// Handwritten "Go Live · Make New Friends" flourish under the login card.
class GoLiveSignature extends StatelessWidget {
  const GoLiveSignature({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.08,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FaIcon(FontAwesomeIcons.crown, color: Colors.white, size: 11),
          const Text(
            'Go Live',
            style: TextStyle(
              fontFamily: AppTheme.scriptFontFamily,
              fontSize: 34,
              height: 1.1,
              color: Colors.white,
              shadows: [Shadow(color: Color(0x88FF4FB0), blurRadius: 12)],
            ),
          ),
          const Text(
            'Make New Friends',
            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Container(
            width: 104,
            height: 1.5,
            decoration: BoxDecoration(
              gradient: AppColors.pinkPurpleGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}
