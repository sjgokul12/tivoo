import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Bundled image decoded at display size: [cacheWidth] (logical px) keeps
/// memory low, and Flutter's ImageCache reuses the decoded frame everywhere
/// the same image appears.
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.cacheWidth,
  });

  final String path;
  final BoxFit fit;
  final Alignment alignment;
  final double? cacheWidth;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return Image.asset(
      path,
      fit: fit,
      alignment: alignment,
      cacheWidth: cacheWidth == null ? null : (cacheWidth! * dpr).round(),
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => const ColoredBox(
        color: Color(0xFF1A1740),
        child: Center(child: Icon(Icons.person_rounded, color: AppColors.textMuted)),
      ),
    );
  }
}

/// Circular avatar with a gradient ring.
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.image,
    this.size = 40,
    this.ringGradient = AppColors.brandGradient,
    this.ringWidth = 2,
  });

  final String image;
  final double size;
  final Gradient ringGradient;
  final double ringWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(ringWidth),
      decoration: BoxDecoration(shape: BoxShape.circle, gradient: ringGradient),
      child: ClipOval(child: AppImage(path: image, cacheWidth: size)),
    );
  }
}

/// Overlapping avatars row (viewers, supporters, team members).
class AvatarStack extends StatelessWidget {
  const AvatarStack({super.key, required this.images, this.size = 26, this.overlap = 0.35});

  final List<String> images;
  final double size;
  final double overlap;

  @override
  Widget build(BuildContext context) {
    final step = size * (1 - overlap);
    return SizedBox(
      width: images.isEmpty ? 0 : step * (images.length - 1) + size,
      height: size,
      child: Stack(
        children: [
          for (var i = 0; i < images.length; i++)
            Positioned(
              left: step * i,
              child: Avatar(image: images[i], size: size, ringWidth: 1.5),
            ),
        ],
      ),
    );
  }
}
