import 'package:flutter/widgets.dart';

/// Screen-level sizing helpers. Uses [MediaQuery.sizeOf] so widgets only
/// rebuild when the size changes (not on keyboard/padding changes).
extension ResponsiveContext on BuildContext {
  static const _designWidth = 390.0;

  Size get screenSize => MediaQuery.sizeOf(this);

  bool get isTablet => screenSize.shortestSide >= 600;

  /// Scales a design value (from a 390pt-wide mock) to the current width,
  /// clamped so tablets and tiny phones stay readable.
  double scaled(double value) {
    final factor = (screenSize.width / _designWidth).clamp(0.82, 1.25);
    return value * factor;
  }
}

/// Max width for phone-first layouts so they stay centered on tablets.
const double kMaxContentWidth = 640;
