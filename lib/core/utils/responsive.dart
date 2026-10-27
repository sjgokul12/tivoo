import 'package:flutter/material.dart';

extension ResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;
  EdgeInsets get padding => MediaQuery.paddingOf(this);
  EdgeInsets get viewInsets => MediaQuery.viewInsetsOf(this);
  bool get isSmallScreen => screenWidth < 360;
  bool get isTablet => screenWidth >= 600;
  double get pageGutter => isTablet ? 24.0 : 16.0;

  double responsiveWidth(double mobileSize, {double? tabletSize}) {
    if (isTablet) return tabletSize ?? (mobileSize * 1.3);
    return mobileSize;
  }

  /// Responsive size based on a standard 390px mobile viewport width.
  double rs(num size) {
    final scale = (screenWidth / 390.0).clamp(0.85, 1.3);
    return (size * scale).toDouble();
  }

  /// Responsive font / text scale based on a standard 390px mobile viewport width.
  double sp(num size) {
    final scale = (screenWidth / 390.0).clamp(0.85, 1.3);
    return (size * scale).toDouble();
  }
}
