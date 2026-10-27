import 'package:flutter/material.dart';

/// Beauty retouch strengths, each 0 – 1.
class BeautySettings {
  final double smooth;
  final double brighten;
  final double teeth;
  final double eyes;
  final double slim;

  const BeautySettings({this.smooth = 0, this.brighten = 0, this.teeth = 0, this.eyes = 0, this.slim = 0});

  /// A natural starting look.
  static const natural = BeautySettings(smooth: 0.45, brighten: 0.25, teeth: 0.3, eyes: 0.2, slim: 0.15);

  bool get isOff => smooth == 0 && brighten == 0 && teeth == 0 && eyes == 0 && slim == 0;

  double valueOf(BeautyFeature f) => switch (f) {
    BeautyFeature.smooth => smooth,
    BeautyFeature.brighten => brighten,
    BeautyFeature.teeth => teeth,
    BeautyFeature.eyes => eyes,
    BeautyFeature.slim => slim,
  };

  BeautySettings withValue(BeautyFeature f, double v) => BeautySettings(
    smooth: f == BeautyFeature.smooth ? v : smooth,
    brighten: f == BeautyFeature.brighten ? v : brighten,
    teeth: f == BeautyFeature.teeth ? v : teeth,
    eyes: f == BeautyFeature.eyes ? v : eyes,
    slim: f == BeautyFeature.slim ? v : slim,
  );
}

enum BeautyFeature {
  smooth('Smooth', Icons.face_retouching_natural_rounded),
  brighten('Brighten', Icons.wb_sunny_outlined),
  teeth('Teeth', Icons.sentiment_very_satisfied_rounded),
  eyes('Eyes', Icons.remove_red_eye_outlined),
  slim('Slim', Icons.face_rounded);

  const BeautyFeature(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// A colour grade applied over the whole picture.
class ColorLook {
  final String id;
  final String name;

  /// 4×5 colour matrix (null = no change).
  final List<double>? matrix;

  /// Two colours for the round preview swatch.
  final List<Color> swatch;

  const ColorLook(this.id, this.name, this.matrix, this.swatch);

  bool get isNone => matrix == null;

  static const none = ColorLook('none', 'Original', null, [Color(0xFF3A3A44), Color(0xFF1C1C22)]);

  static const all = <ColorLook>[
    none,
    ColorLook(
      'vivid',
      'Vivid',
      [
        1.25, -0.1, -0.1, 0, 0, //
        -0.08, 1.22, -0.08, 0, 0,
        -0.08, -0.1, 1.25, 0, 0,
        0, 0, 0, 1, 0,
      ],
      [Color(0xFFFF5E62), Color(0xFFFFC371)],
    ),
    ColorLook(
      'warm',
      'Golden',
      [
        1.12, 0.05, 0, 0, 12, //
        0.02, 1.04, 0, 0, 6,
        0, 0, 0.86, 0, -6,
        0, 0, 0, 1, 0,
      ],
      [Color(0xFFFFB75E), Color(0xFFED8F03)],
    ),
    ColorLook(
      'cool',
      'Frost',
      [
        0.92, 0, 0.04, 0, -4, //
        0, 1.0, 0.06, 0, 0,
        0.02, 0.06, 1.16, 0, 12,
        0, 0, 0, 1, 0,
      ],
      [Color(0xFF83A4D4), Color(0xFFB6FBFF)],
    ),
    ColorLook(
      'rose',
      'Blush',
      [
        1.1, 0.06, 0.04, 0, 10, //
        0, 0.96, 0.04, 0, 0,
        0.04, 0.04, 1.02, 0, 8,
        0, 0, 0, 1, 0,
      ],
      [Color(0xFFFF9A9E), Color(0xFFFECFEF)],
    ),
    ColorLook(
      'film',
      'Film',
      [
        0.95, 0.1, 0.05, 0, 8, //
        0.05, 0.92, 0.05, 0, 6,
        0.05, 0.1, 0.8, 0, 4,
        0, 0, 0, 1, 0,
      ],
      [Color(0xFFB79891), Color(0xFF94716B)],
    ),
    ColorLook(
      'neon',
      'Neon',
      [
        1.1, 0, 0.15, 0, 0, //
        0, 0.95, 0.1, 0, 0,
        0.15, 0, 1.25, 0, 10,
        0, 0, 0, 1, 0,
      ],
      [Color(0xFFDA22FF), Color(0xFF9733EE)],
    ),
    ColorLook(
      'mono',
      'Noir',
      [
        0.33, 0.59, 0.11, 0, -6, //
        0.33, 0.59, 0.11, 0, -6,
        0.33, 0.59, 0.11, 0, -6,
        0, 0, 0, 1, 0,
      ],
      [Color(0xFF8E9EAB), Color(0xFF232526)],
    ),
  ];
}

/// A Banuba AR effect (mask, background, makeup look).
class ArEffect {
  final String id;
  final String name;

  /// Folder name under the project's `effects/` directory.
  final String folder;
  final IconData icon;
  final List<Color> swatch;

  const ArEffect(this.id, this.name, this.folder, this.icon, this.swatch);

  String get path => 'effects/$folder';

  /// Effects bundled with the app. To add one, download it from Banuba, put its folder in
  /// `effects/` at the project root and add an entry here.
  static const bundled = <ArEffect>[
    ArEffect('troll', 'Troll Grandma', 'TrollGrandma', Icons.face_6_rounded, [Color(0xFF7F00FF), Color(0xFFE100FF)]),
  ];

  /// Banuba's beauty effect (download "Makeup" from Banuba into `effects/Makeup`).
  static const beautyFolder = 'Makeup';
}
