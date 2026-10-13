import 'package:flutter/material.dart';

extension ResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);
  bool get isSmallScreen => screenWidth < 360;
  bool get isTablet => screenWidth >= 600;

  double responsiveWidth(double mobileSize, {double? tabletSize}) {
    if (isTablet) return tabletSize ?? (mobileSize * 1.3);
    return mobileSize;
  }
}
