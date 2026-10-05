import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static const fontFamily = 'Poppins';
  static const scriptFontFamily = 'GreatVibes';

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.pink,
        secondary: AppColors.purple,
        tertiary: AppColors.gold,
        surface: AppColors.navy,
        error: AppColors.live,
      ),
    );
    return base.copyWith(
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.pink,
        selectionColor: Color(0x55FF3FA4),
        selectionHandleColor: AppColors.pink,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.navy.withValues(alpha: 0.95),
        contentTextStyle: const TextStyle(fontFamily: fontFamily, color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.pink),
      splashFactory: InkSparkle.splashFactory,
    );
  }
}
