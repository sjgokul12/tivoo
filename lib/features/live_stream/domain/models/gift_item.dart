class GiftItem {
  final String id;
  final String name;
  final String icon;
  final String? imageAssetPath;

  /// True when the artwork is a full picture with its own background (not a cut-out
  /// sticker). Cards show it edge-to-edge and animations fade its edges into the effects.
  final bool isSceneArt;
  final int diamonds;

  const GiftItem({
    required this.id,
    required this.name,
    required this.icon,
    this.imageAssetPath,
    this.isSceneArt = false,
    required this.diamonds,
  });
}
