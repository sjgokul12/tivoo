import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PageIndicator extends StatelessWidget {
  final int count;
  final int activeIndex;
  final double dotSize;
  final double spacing;

  const PageIndicator({
    super.key,
    this.count = 5,
    this.activeIndex = 0,
    this.dotSize = 7.0,
    this.spacing = 6.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == activeIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: EdgeInsets.symmetric(horizontal: spacing / 2),
          width: isActive ? dotSize * 1.8 : dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : AppColors.dotInactive,
            borderRadius: BorderRadius.circular(dotSize / 2),
          ),
        );
      }),
    );
  }
}
