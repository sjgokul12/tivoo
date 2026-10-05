import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_container.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.leading,
    required this.onViewAll,
  });

  final String title;
  final String subtitle;
  final String leading;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          leading,
          style: const TextStyle(fontSize: 26, shadows: [Shadow(color: Color(0xAAFF7A00), blurRadius: 14)]),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600, height: 1.25),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 10.5),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onViewAll,
            child: const GlassContainer(
              borderRadius: 20,
              color: Color(0xCC0B0A1E),
              borderWidth: 1.3,
              borderGradient: LinearGradient(colors: [AppColors.gold, AppColors.pink, AppColors.purple]),
              shadows: [BoxShadow(color: Color(0x66FFB020), blurRadius: 10, blurStyle: BlurStyle.outer)],
              padding: EdgeInsets.fromLTRB(14, 6, 8, 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('View All', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
                  SizedBox(width: 2),
                  Icon(Icons.chevron_right_rounded, color: AppColors.gold, size: 16),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
