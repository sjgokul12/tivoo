import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class CategoryItem {
  final String id;
  final String label;
  final IconData icon;
  final Color accentColor;

  const CategoryItem({required this.id, required this.label, required this.icon, required this.accentColor});
}

class CategoryArcSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onCategorySelected;

  static const List<CategoryItem> defaultCategories = [
    CategoryItem(id: 'live', label: 'Live', icon: Icons.podcasts_rounded, accentColor: Color(0xFFFF2D55)),
    CategoryItem(id: 'music', label: 'Music', icon: Icons.music_note_rounded, accentColor: Color(0xFFAF52DE)),
    CategoryItem(
      id: 'gaming',
      label: 'Gaming',
      icon: Icons.sports_esports_rounded,
      accentColor: AppColors.primaryYellow,
    ),
    CategoryItem(id: 'travel', label: 'Travel', icon: Icons.flight_rounded, accentColor: Color(0xFF007AFF)),
    CategoryItem(
      id: 'comedy',
      label: 'Comedy',
      icon: Icons.sentiment_very_satisfied_rounded,
      accentColor: Color(0xFFFFCC00),
    ),
  ];

  const CategoryArcSelector({super.key, required this.selectedIndex, required this.onCategorySelected});

  void _navigatePrevious() {
    final prev = (selectedIndex - 1 + defaultCategories.length) % defaultCategories.length;
    onCategorySelected(prev);
  }

  void _navigateNext() {
    final next = (selectedIndex + 1) % defaultCategories.length;
    onCategorySelected(next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Arc Container with oval golden glow outline matching Image 2
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              border: Border.all(color: AppColors.primaryYellow.withValues(alpha: 0.35), width: 1.0),
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryYellow.withValues(alpha: 0.08),
                  Colors.black.withValues(alpha: 0.5),
                  AppColors.primaryYellow.withValues(alpha: 0.08),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(color: AppColors.primaryYellow.withValues(alpha: 0.12), blurRadius: 18, spreadRadius: -2),
              ],
            ),
            child: Row(
              children: [
                // Left chevron button
                GestureDetector(
                  onTap: _navigatePrevious,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2, right: 4),
                    child: Icon(Icons.chevron_left_rounded, color: Colors.white.withValues(alpha: 0.8), size: 22),
                  ),
                ),

                // 5 Categories evenly distributed across the available space
                Expanded(
                  child: Row(
                    children: List.generate(defaultCategories.length, (idx) {
                      final item = defaultCategories[idx];
                      final isSelected = (selectedIndex % defaultCategories.length) == idx;
                      return Expanded(
                        child: _buildCategoryIcon(item, isSelected, () {
                          onCategorySelected(idx);
                        }),
                      );
                    }),
                  ),
                ),

                // Right chevron button
                GestureDetector(
                  onTap: _navigateNext,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4, right: 2),
                    child: Icon(Icons.chevron_right_rounded, color: Colors.white.withValues(alpha: 0.8), size: 22),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 6),

        // Indicator dots underneath the arc matching Image 2 (• • •)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (dotIdx) {
            final activeDot =
                ((selectedIndex % defaultCategories.length) == 2 && dotIdx == 1) ||
                ((selectedIndex % defaultCategories.length) < 2 && dotIdx == 0) ||
                ((selectedIndex % defaultCategories.length) > 2 && dotIdx == 2);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: activeDot ? 8 : 6,
              height: activeDot ? 8 : 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: activeDot ? AppColors.primaryYellow : AppColors.primaryYellow.withValues(alpha: 0.35),
                boxShadow: activeDot
                    ? [BoxShadow(color: AppColors.primaryYellow.withValues(alpha: 0.6), blurRadius: 6)]
                    : null,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCategoryIcon(CategoryItem item, bool isSelected, VoidCallback onTap) {
    final size = isSelected ? 44.0 : 36.0;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular Icon Button
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.primaryYellow : const Color(0xFF141419),
              border: Border.all(
                color: isSelected ? AppColors.primaryYellowLight : item.accentColor.withValues(alpha: 0.6),
                width: isSelected ? 2.0 : 1.2,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: AppColors.primaryYellow.withValues(alpha: 0.65), blurRadius: 16, spreadRadius: 2)]
                  : [BoxShadow(color: item.accentColor.withValues(alpha: 0.2), blurRadius: 8)],
            ),
            child: Center(
              child: Icon(item.icon, size: isSelected ? 22 : 17, color: isSelected ? Colors.black : item.accentColor),
            ),
          ),
          const SizedBox(height: 3),

          // Label text below icon
          Text(
            item.label,
            style: TextStyle(
              fontSize: isSelected ? 11.5 : 10,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.7),
              letterSpacing: 0.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
