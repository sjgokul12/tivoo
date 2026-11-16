import 'package:flutter/material.dart';

class VideoFilterItem {
  final String id;
  final String name;
  final String category;
  final String coverUrl;
  final Color previewColor;
  final String overlayType;
  final List<double> matrix;

  const VideoFilterItem({
    required this.id,
    required this.name,
    this.category = 'Filter',
    required this.coverUrl,
    this.previewColor = const Color(0xFFFF2A85),
    this.overlayType = 'none',
    required this.matrix,
  });

  bool get isOriginal => id == 'original';

  /// Generates an interpolated ColorFilter based on user-selected intensity (0.0 to 1.0).
  ColorFilter? getColorFilter(double intensity) {
    if (isOriginal) return null;
    final clamped = intensity.clamp(0.0, 1.0);
    if (clamped <= 0.01) return null;

    final identity = VideoFilterRepository.identityMatrix;
    final blended = List<double>.generate(20, (i) {
      return identity[i] + (matrix[i] - identity[i]) * clamped;
    });

    return ColorFilter.matrix(blended);
  }
}

class VideoFilterRepository {
  VideoFilterRepository._();

  static const List<double> identityMatrix = [
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ];

  static const List<VideoFilterItem> filters = [
    VideoFilterItem(
      id: 'original',
      name: 'Original',
      category: 'Raw',
      coverUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=300&q=80',
      previewColor: Colors.grey,
      overlayType: 'none',
      matrix: identityMatrix,
    ),
    VideoFilterItem(
      id: 'beauty',
      name: 'Beauty / Skin Smooth',
      category: 'Face',
      coverUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=300&q=80',
      previewColor: Color(0xFFFF8AE6),
      overlayType: 'beauty_glow',
      matrix: [
        1.08, 0.02, 0.0, 0.0, 14.0,
        0.02, 1.05, 0.0, 0.0, 10.0,
        0.0, 0.02, 1.02, 0.0, 6.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
    ),
    VideoFilterItem(
      id: 'makeup',
      name: 'Makeup',
      category: 'Face',
      coverUrl: 'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?auto=format&fit=crop&w=300&q=80',
      previewColor: Color(0xFFFF2A85),
      overlayType: 'makeup_glam',
      matrix: [
        1.22, 0.0, 0.0, 0.0, 18.0,
        0.0, 1.02, 0.0, 0.0, 4.0,
        0.0, 0.0, 1.05, 0.0, 8.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
    ),
    VideoFilterItem(
      id: 'animal',
      name: 'Animal Effects',
      category: 'AR Lens',
      coverUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300&q=80',
      previewColor: Color(0xFFFFB300),
      overlayType: 'animal_whiskers',
      matrix: [
        1.12, 0.0, 0.0, 0.0, 10.0,
        0.0, 1.08, 0.0, 0.0, 10.0,
        0.0, 0.0, 0.95, 0.0, -2.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
    ),
    VideoFilterItem(
      id: 'accessories',
      name: '3D Accessories',
      category: 'AR Lens',
      coverUrl: 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?auto=format&fit=crop&w=300&q=80',
      previewColor: Color(0xFF00E5FF),
      overlayType: 'accessories_3d',
      matrix: [
        1.10, 0.0, 0.12, 0.0, 10.0,
        0.0, 1.05, 0.05, 0.0, 5.0,
        0.08, 0.0, 1.25, 0.0, 15.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
    ),
    VideoFilterItem(
      id: 'cinematic',
      name: 'Cinematic',
      category: 'Cinema',
      coverUrl: 'https://images.unsplash.com/photo-1531746020798-e6953c6e8e04?auto=format&fit=crop&w=300&q=80',
      previewColor: Color(0xFFFF6D00),
      overlayType: 'cinematic_bars',
      matrix: [
        1.25, 0.0, 0.0, 0.0, 14.0,
        0.0, 1.02, 0.0, 0.0, 2.0,
        0.0, 0.0, 1.20, 0.0, 18.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
    ),
    VideoFilterItem(
      id: 'aesthetic',
      name: 'Aesthetic',
      category: 'Atmosphere',
      coverUrl: 'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=300&q=80',
      previewColor: Color(0xFFFFD54F),
      overlayType: 'aesthetic_haze',
      matrix: [
        1.18, 0.05, 0.0, 0.0, 14.0,
        0.0, 1.08, 0.05, 0.0, 8.0,
        0.0, 0.0, 0.88, 0.0, -10.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
    ),
    VideoFilterItem(
      id: 'cartoon',
      name: 'Cartoon',
      category: 'Stylize',
      coverUrl: 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?auto=format&fit=crop&w=300&q=80',
      previewColor: Color(0xFFE040FB),
      overlayType: 'cartoon_pop',
      matrix: [
        1.38, -0.15, -0.15, 0.0, -4.0,
        -0.15, 1.38, -0.15, 0.0, -4.0,
        -0.15, -0.15, 1.38, 0.0, -4.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
    ),
    VideoFilterItem(
      id: 'portrait_blur',
      name: 'Portrait Blur',
      category: 'Focus',
      coverUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
      previewColor: Color(0xFF64B5F6),
      overlayType: 'portrait_bokeh',
      matrix: [
        1.06, 0.0, 0.0, 0.0, 6.0,
        0.0, 1.04, 0.0, 0.0, 4.0,
        0.0, 0.0, 1.02, 0.0, 2.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
    ),
    VideoFilterItem(
      id: 'retro_vhs',
      name: 'Retro / VHS',
      category: 'Vintage',
      coverUrl: 'https://images.unsplash.com/photo-1509281373149-e957c6296406?auto=format&fit=crop&w=300&q=80',
      previewColor: Color(0xFFFF5252),
      overlayType: 'vhs_camcorder',
      matrix: [
        1.18, 0.08, -0.05, 0.0, 20.0,
        0.05, 0.96, 0.05, 0.0, 8.0,
        -0.08, 0.08, 0.76, 0.0, -12.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
    ),
    VideoFilterItem(
      id: 'neon',
      name: 'Neon',
      category: 'Cyber',
      coverUrl: 'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?auto=format&fit=crop&w=300&q=80',
      previewColor: Color(0xFF7C4DFF),
      overlayType: 'neon_pulse',
      matrix: [
        1.32, 0.0, 0.20, 0.0, 22.0,
        0.0, 0.85, 0.15, 0.0, -10.0,
        0.15, 0.0, 1.48, 0.0, 26.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
    ),
    VideoFilterItem(
      id: 'fantasy',
      name: 'Fantasy',
      category: 'Magical',
      coverUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=300&q=80',
      previewColor: Color(0xFFB388FF),
      overlayType: 'fantasy_sparkles',
      matrix: [
        1.18, 0.0, 0.15, 0.0, 16.0,
        0.05, 1.05, 0.10, 0.0, 8.0,
        0.12, 0.05, 1.35, 0.0, 24.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
    ),
    VideoFilterItem(
      id: 'black_and_white',
      name: 'Black & White',
      category: 'Monochrome',
      coverUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=300&q=80',
      previewColor: Colors.white,
      overlayType: 'bw_grain',
      matrix: [
        0.37, 0.73, 0.14, 0.0, -8.0,
        0.37, 0.73, 0.14, 0.0, -8.0,
        0.37, 0.73, 0.14, 0.0, -8.0,
        0.0, 0.0, 0.0, 1.0, 0.0,
      ],
    ),
  ];
}
