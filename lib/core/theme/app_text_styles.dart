import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get logoTitle => GoogleFonts.outfit(fontSize: 42, fontWeight: FontWeight.w800, letterSpacing: -0.5);

  static TextStyle get logoTitleHome =>
      GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 0.5);

  static TextStyle get heroHeading =>
      GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.25);

  static TextStyle get heroSubtitle => GoogleFonts.plusJakartaSans(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  static TextStyle get buttonLarge => GoogleFonts.plusJakartaSans(
    fontSize: 17,
    fontWeight: FontWeight.w800,
    color: AppColors.textOnPrimary,
    letterSpacing: 0.2,
  );

  static TextStyle get buttonSmall =>
      GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textOnPrimary);

  static TextStyle get chatBubble =>
      GoogleFonts.plusJakartaSans(fontSize: 13.5, fontWeight: FontWeight.w500, color: AppColors.textPrimary);

  static TextStyle get storyName =>
      GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textPrimary);

  static TextStyle get streamerName =>
      GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary);

  static TextStyle get streamerTagline =>
      GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textSecondary);

  static TextStyle get badgeText => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
  );

  static TextStyle get tabSelected =>
      GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary);

  static TextStyle get tabUnselected =>
      GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textSecondary);

  static TextStyle get navLabel => GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600);
}
