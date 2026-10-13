import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/tivoo_logo.dart';

class LoginHeroSection extends StatelessWidget {
  const LoginHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const TivooLogo(fontSize: 28),

        const SizedBox(height: 14),

        // Live. Stream. Connect. Hero Gradient Heading
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live.',
              style: AppTextStyles.heroHeading.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryYellow,
                height: 1.12,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              'Stream.',
              style: AppTextStyles.heroHeading.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFAF52DE),
                height: 1.12,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              'Connect.',
              style: AppTextStyles.heroHeading.copyWith(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryYellow,
                height: 1.12,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Subtitle with proper line height and clear letter spacing
        SizedBox(
          width: 320,
          child: Text(
            'Join a community of amazing streamers and enjoy live moments together.',
            style: AppTextStyles.heroSubtitle.copyWith(
              fontSize: 13.5,
              color: Colors.white.withValues(alpha: 0.75),
              height: 1.42,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}
