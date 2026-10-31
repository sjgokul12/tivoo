import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';

/// Categories for camera AR filters matching Instagram / Snapchat experience.
enum FilterCategory {
  all('All', Icons.auto_awesome_rounded),
  beauty('Beauty', Icons.face_retouching_natural_rounded),
  fun('Fun', Icons.sentiment_very_satisfied_rounded),
  anime('Anime', Icons.pets_rounded),
  love('Love', Icons.favorite_rounded),
  nature('Nature', Icons.eco_rounded),
  frames('Frames', Icons.crop_original_rounded),
  makeup('Makeup', Icons.brush_rounded),
  style('Style', Icons.style_rounded);

  final String label;
  final IconData icon;

  const FilterCategory(this.label, this.icon);
}

/// Type of visual / AR overlay applied to the live camera feed.
enum FilterOverlayType {
  none,
  butterfly,
  bunny,
  heart,
  galaxy,
  vintage,
  naturalGlow,
  catAnime,
  dog,
  angelHalo,
  cyberGlasses,
}

/// Represents a single camera filter / AR lens option.
class CameraFilterModel {
  final String id;
  final String name;
  final FilterCategory category;
  final String? thumbnailAsset;
  final IconData? fallbackIcon;
  final Color primaryColor;
  final Color secondaryColor;
  final FilterOverlayType overlayType;
  final String description;

  const CameraFilterModel({
    required this.id,
    required this.name,
    required this.category,
    this.thumbnailAsset,
    this.fallbackIcon,
    this.primaryColor = const Color(0xFFFF2DC0),
    this.secondaryColor = const Color(0xFF9B3CFF),
    required this.overlayType,
    this.description = '',
  });

  bool get isNone => id == 'none';
}

/// Mock curated filters list matching Tivoo's luxury neon dark purple theme.
class MockFilterData {
  MockFilterData._();

  static const CameraFilterModel noneFilter = CameraFilterModel(
    id: 'none',
    name: 'None',
    category: FilterCategory.all,
    fallbackIcon: Icons.block_flipped,
    primaryColor: Colors.white54,
    secondaryColor: Colors.white24,
    overlayType: FilterOverlayType.none,
    description: 'No filter applied',
  );

  static final List<CameraFilterModel> allFilters = [
    noneFilter,
    const CameraFilterModel(
      id: 'butterfly',
      name: 'Butterfly',
      category: FilterCategory.fun,
      thumbnailAsset: AppAssets.avatarPriya,
      fallbackIcon: Icons.flutter_dash_rounded,
      primaryColor: Color(0xFFFF2DC0),
      secondaryColor: Color(0xFFC04DFF),
      overlayType: FilterOverlayType.butterfly,
      description: 'Fluttering neon pink butterflies around your head',
    ),
    const CameraFilterModel(
      id: 'bunny',
      name: 'Bunny',
      category: FilterCategory.fun,
      thumbnailAsset: AppAssets.avatarNeha,
      fallbackIcon: Icons.cruelty_free_rounded,
      primaryColor: Color(0xFFFF8AE6),
      secondaryColor: Color(0xFFFF2DC0),
      overlayType: FilterOverlayType.bunny,
      description: 'Cute fluffy animated bunny ears & cheek blush',
    ),
    const CameraFilterModel(
      id: 'natural',
      name: 'Natural',
      category: FilterCategory.beauty,
      thumbnailAsset: AppAssets.status4,
      fallbackIcon: Icons.face_rounded,
      primaryColor: Color(0xFFFFD1A9),
      secondaryColor: Color(0xFFFF8AE6),
      overlayType: FilterOverlayType.naturalGlow,
      description: 'Subtle skin smoothing and radiant golden light',
    ),
    const CameraFilterModel(
      id: 'glow',
      name: 'Glow',
      category: FilterCategory.beauty,
      thumbnailAsset: AppAssets.status3,
      fallbackIcon: Icons.wb_sunny_rounded,
      primaryColor: Color(0xFFFFC928),
      secondaryColor: Color(0xFFFF6FD8),
      overlayType: FilterOverlayType.naturalGlow,
      description: 'Radiant golden aura & soft-focus studio glow',
    ),
    const CameraFilterModel(
      id: 'heart',
      name: 'Heart',
      category: FilterCategory.love,
      thumbnailAsset: AppAssets.avatarDiya,
      fallbackIcon: Icons.favorite_rounded,
      primaryColor: Color(0xFFFF2D55),
      secondaryColor: Color(0xFFFF7AD9),
      overlayType: FilterOverlayType.heart,
      description: 'Floating neon 3D hearts & sparkling aura',
    ),
    const CameraFilterModel(
      id: 'galaxy',
      name: 'Galaxy',
      category: FilterCategory.style,
      thumbnailAsset: AppAssets.avatarMeena,
      fallbackIcon: Icons.nightlight_round,
      primaryColor: Color(0xFF00F0FF),
      secondaryColor: Color(0xFF7E3CFF),
      overlayType: FilterOverlayType.galaxy,
      description: 'Deep cosmic stardust vignette & constellation glints',
    ),
    const CameraFilterModel(
      id: 'vintage',
      name: 'Vintage',
      category: FilterCategory.frames,
      thumbnailAsset: AppAssets.status1,
      fallbackIcon: Icons.camera_roll_rounded,
      primaryColor: Color(0xFFFFB300),
      secondaryColor: Color(0xFFB0203E),
      overlayType: FilterOverlayType.vintage,
      description: 'Warm retro cinema grain with soft golden film flare',
    ),
    const CameraFilterModel(
      id: 'cat',
      name: 'Cat',
      category: FilterCategory.anime,
      thumbnailAsset: AppAssets.avatarSneha,
      fallbackIcon: Icons.pets_rounded,
      primaryColor: Color(0xFFFF7AD9),
      secondaryColor: Color(0xFF2E9BFF),
      overlayType: FilterOverlayType.catAnime,
      description: 'Anime cat ears, whiskers & sparkling eyes',
    ),
    const CameraFilterModel(
      id: 'dog',
      name: 'Dog',
      category: FilterCategory.fun,
      thumbnailAsset: AppAssets.status2,
      fallbackIcon: Icons.pets_rounded,
      primaryColor: Color(0xFFFF9F1C),
      secondaryColor: Color(0xFFFFD1A9),
      overlayType: FilterOverlayType.dog,
      description: 'Playful floppy puppy ears & button nose',
    ),
    const CameraFilterModel(
      id: 'angel',
      name: 'Angel',
      category: FilterCategory.nature,
      thumbnailAsset: AppAssets.avatarSaran,
      fallbackIcon: Icons.wb_incandescent_rounded,
      primaryColor: Color(0xFFFFD600),
      secondaryColor: Color(0xFF00F0FF),
      overlayType: FilterOverlayType.angelHalo,
      description: 'Glowing golden halo & drifting heavenly stardust',
    ),
    const CameraFilterModel(
      id: 'style',
      name: 'Cyber',
      category: FilterCategory.style,
      thumbnailAsset: AppAssets.avatarKarthik,
      fallbackIcon: Icons.smart_toy_rounded,
      primaryColor: Color(0xFF00E5FF),
      secondaryColor: Color(0xFFD600FF),
      overlayType: FilterOverlayType.cyberGlasses,
      description: 'Futuristic neon spectacles & holographic grid tint',
    ),
  ];

  static List<CameraFilterModel> getFiltersForCategory(FilterCategory category) {
    if (category == FilterCategory.all) return allFilters;
    return allFilters.where((f) => f.isNone || f.category == category).toList();
  }
}
