// MediaQuery-based sizing shared by the viewer and streamer PK screens.

import 'dart:math';

import 'package:flutter/material.dart';

/// Breakpoints and scaled sizes for the PK battle screens.
///
/// Phones are designed against a 390px wide screen; everything scales from
/// there and is clamped so small phones and tablets / desktop web stay usable.
class PkResponsive {
  final Size size;
  final EdgeInsets padding;
  final double keyboardInset;

  const PkResponsive._(this.size, this.padding, this.keyboardInset);

  factory PkResponsive.of(BuildContext context) {
    final mq = MediaQuery.of(context);
    return PkResponsive._(mq.size, mq.padding, mq.viewInsets.bottom);
  }

  /// Widest the PK layout gets; wider screens (tablet, desktop web) centre it.
  static const double maxContentWidth = 520;

  double get width => size.width;
  double get height => size.height;

  /// Phones narrower than 360px (e.g. small Androids, iPhone SE 1st gen).
  bool get isCompact => width < 360;

  /// Phones shorter than 700px, where vertical space is tight.
  bool get isShort => height < 700;

  /// Tablets and desktop browsers.
  bool get isWide => width >= 600;

  bool get isKeyboardOpen => keyboardInset > 50;

  /// Scale factor relative to a 390px wide phone.
  double get scale => (min(width, maxContentWidth) / 390).clamp(0.82, 1.18);

  /// Scales a design size by [scale].
  double s(double value) => value * scale;

  /// Width for centred dialogs / end-of-battle cards.
  double get dialogWidth => (width * 0.9).clamp(280.0, 400.0);
}
