import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class TivooLogo extends StatelessWidget {
  final double fontSize;
  final bool isUppercase;
  final bool showPlayIcons;

  const TivooLogo({super.key, this.fontSize = 44, this.isUppercase = false, this.showPlayIcons = true});

  @override
  Widget build(BuildContext context) {
    if (isUppercase) {
      return ShaderMask(
        shaderCallback: (bounds) =>
            AppColors.brandLogoGradient.createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
        child: Text(
          'TIVOO',
          style: GoogleFonts.outfit(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
      );
    }

    // Splash logo with 'Tiv' and 'oo' having play icons
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => AppColors.logoSplashGradient.createShader(bounds),
          child: Text(
            'Tiv',
            style: GoogleFonts.outfit(
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 2),
        _buildPlayO(size: fontSize * 0.68, gradient: AppColors.logoPlayOGradient1),
        const SizedBox(width: 3),
        _buildPlayO(size: fontSize * 0.68, gradient: AppColors.logoPlayOGradient2),
      ],
    );
  }

  Widget _buildPlayO({required double size, required Gradient gradient}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: gradient),
      child: Center(
        child: Container(
          width: size * 0.62,
          height: size * 0.62,
          decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
          child: Center(
            child: Icon(Icons.play_arrow_rounded, size: size * 0.44, color: AppColors.primaryYellow),
          ),
        ),
      ),
    );
  }
}
