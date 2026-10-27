import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../constants/app_assets.dart';
import '../theme/app_colors.dart';

class CustomAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? assetPath;
  final double radius;
  final bool hasStoryRing;
  final bool isUserAdd;
  final VoidCallback? onTap;
  final Gradient? ringGradient;
  final Alignment? alignment;

  const CustomAvatar({
    super.key,
    this.imageUrl,
    this.assetPath,
    this.radius = 28,
    this.hasStoryRing = false,
    this.isUserAdd = false,
    this.onTap,
    this.ringGradient,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatarImage;

    final fallbackAsset = (assetPath != null && assetPath!.isNotEmpty) ? assetPath! : AppAssets.liveCard1;

    // Center on face for tall vertical portrait assets (status1 to status5)
    final effectiveAlignment =
        alignment ??
        ((assetPath != null && assetPath!.contains('status')) ? const Alignment(0.0, -0.55) : Alignment.center);

    // Generous retina-quality decode dimension without squashing aspect ratio
    final pixelDim = (radius * 2 * 3.5).toInt().clamp(150, 600);

    if (assetPath != null && assetPath!.isNotEmpty) {
      avatarImage = Image.asset(
        assetPath!,
        fit: BoxFit.cover,
        alignment: effectiveAlignment,
        filterQuality: FilterQuality.high,
        width: radius * 2,
        height: radius * 2,
        cacheWidth: pixelDim,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          AppAssets.liveCard1,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          filterQuality: FilterQuality.high,
          width: radius * 2,
          height: radius * 2,
          cacheWidth: pixelDim,
        ),
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      final isAsset = imageUrl!.startsWith('assets/');
      final isLocalFile = !isAsset &&
          !imageUrl!.startsWith('http://') &&
          !imageUrl!.startsWith('https://');

      if (isAsset) {
        avatarImage = Image.asset(
          imageUrl!,
          fit: BoxFit.cover,
          alignment: effectiveAlignment,
          filterQuality: FilterQuality.high,
          width: radius * 2,
          height: radius * 2,
          cacheWidth: pixelDim,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            fallbackAsset,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            filterQuality: FilterQuality.high,
            width: radius * 2,
            height: radius * 2,
            cacheWidth: pixelDim,
          ),
        );
      } else if (isLocalFile) {
        final filePath = imageUrl!.replaceFirst('file://', '');
        avatarImage = Image.file(
          File(filePath),
          fit: BoxFit.cover,
          alignment: effectiveAlignment,
          filterQuality: FilterQuality.high,
          width: radius * 2,
          height: radius * 2,
          errorBuilder: (context, error, stackTrace) => Image.asset(
            fallbackAsset,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            filterQuality: FilterQuality.high,
            width: radius * 2,
            height: radius * 2,
            cacheWidth: pixelDim,
          ),
        );
      } else {
        avatarImage = CachedNetworkImage(
          imageUrl: imageUrl!,
          fit: BoxFit.cover,
          alignment: effectiveAlignment,
          filterQuality: FilterQuality.high,
          width: radius * 2,
          height: radius * 2,
          memCacheWidth: pixelDim,
          placeholder: (context, url) => Image.asset(
            fallbackAsset,
            fit: BoxFit.cover,
            alignment: effectiveAlignment,
            filterQuality: FilterQuality.high,
            width: radius * 2,
            height: radius * 2,
            cacheWidth: pixelDim,
          ),
          errorWidget: (context, url, error) => Image.asset(
            fallbackAsset,
            fit: BoxFit.cover,
            alignment: effectiveAlignment,
            filterQuality: FilterQuality.high,
            width: radius * 2,
            height: radius * 2,
            cacheWidth: pixelDim,
          ),
        );
      }
    } else {
      avatarImage = Image.asset(
        AppAssets.liveCard1,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
        width: radius * 2,
        height: radius * 2,
        cacheWidth: pixelDim,
      );
    }

    Widget content = ClipOval(child: avatarImage);

    if (hasStoryRing) {
      content = Container(
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: ringGradient ?? AppColors.storyRingGradient),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).scaffoldBackgroundColor),
          child: ClipOval(
            child: SizedBox(width: radius * 2, height: radius * 2, child: avatarImage),
          ),
        ),
      );
    } else {
      content = SizedBox(width: radius * 2, height: radius * 2, child: content);
    }

    if (isUserAdd) {
      return GestureDetector(
        onTap: onTap,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            content,
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(color: AppColors.background, shape: BoxShape.circle),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.add, size: 11, color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(onTap: onTap, child: content);
  }
}
