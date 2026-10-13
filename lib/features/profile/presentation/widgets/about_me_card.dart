import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';

class AboutMeCard extends StatelessWidget {
  final String aboutMe;

  const AboutMeCard({super.key, required this.aboutMe});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: isDark ? const Color(0xFF13131E) : Colors.white,
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About Me',
            style: AppTextStyles.heroHeading.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF161622),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            aboutMe,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: isDark ? Colors.white70 : const Color(0xFF444455),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
