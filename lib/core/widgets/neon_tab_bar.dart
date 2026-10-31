import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/responsive.dart';

/// Shared pill-tab-row used by Home/Explore/Activity category filters (and
/// anywhere else a horizontal filter row is needed) so the neon-glass tab
/// styling only needs to be tuned in one place.
class NeonTabBar extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onCategorySelected;

  /// Gradient used for the selected pill. Overridable per-category via
  /// [gradientForCategory] (e.g. Home's "Popular" tab uses a distinct one).
  final Gradient selectedGradient;
  final Gradient Function(String category)? gradientForCategory;

  /// Optional leading emoji shown only on the selected pill for a given
  /// category (e.g. 🔥 on "Popular").
  final String? Function(String category)? emojiForCategory;

  const NeonTabBar({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
    this.selectedGradient = AppColors.getStartedButtonGradient,
    this.gradientForCategory,
    this.emojiForCategory,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      height: context.responsiveWidth(44),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          final category = categories[index];
          final gradient = gradientForCategory?.call(category) ?? selectedGradient;
          final emoji = isSelected ? emojiForCategory?.call(category) : null;

          final unselectedBg = isDark
              ? AppColors.surfaceColor.withValues(alpha: 0.6)
              : Colors.black.withValues(alpha: 0.05);
          final unselectedBorder = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.08);
          final unselectedTextColor = isDark ? AppColors.textSecondary : const Color(0xFF555566);

          final selectedTextColor = gradient.colors.any((c) => c.computeLuminance() > 0.4)
              ? AppColors.textOnPrimary
              : Colors.white;

          return GestureDetector(
            onTap: () => onCategorySelected(index),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: isSelected ? 1.04 : 1.0,
              curve: Curves.easeOutBack,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: isSelected ? gradient : null,
                  color: isSelected ? null : unselectedBg,
                  border: Border.all(color: isSelected ? Colors.transparent : unselectedBorder, width: 0.8),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: gradient.colors.first.withValues(alpha: 0.45),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (emoji != null) ...[Text(emoji, style: const TextStyle(fontSize: 14)), const SizedBox(width: 6)],
                    Text(
                      category,
                      style: isSelected
                          ? AppTextStyles.tabSelected.copyWith(
                              color: selectedTextColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            )
                          : AppTextStyles.tabUnselected.copyWith(color: unselectedTextColor, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
