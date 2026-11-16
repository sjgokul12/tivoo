import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  final String? fallbackText;

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
    this.fallbackText,
  });

  Widget _buildDefaultPlaceholder() {
    final letter = (fallbackText != null && fallbackText!.trim().isNotEmpty)
        ? fallbackText!.trim().substring(0, 1).toUpperCase()
        : null;

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF3B1E6D), Color(0xFF1B1438)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: letter != null
            ? Text(
                letter,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: radius * 0.9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              )
            : Icon(
                Icons.person_rounded,
                size: radius * 1.15,
                color: Colors.white.withValues(alpha: 0.85),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget avatarImage;

    // Generous retina-quality decode dimension without squashing aspect ratio
    final pixelDim = (radius * 2 * 3.5).toInt().clamp(150, 600);
    final effectiveAlignment = alignment ?? Alignment.center;

    if (assetPath != null && assetPath!.isNotEmpty) {
      avatarImage = Image.asset(
        assetPath!,
        fit: BoxFit.cover,
        alignment: effectiveAlignment,
        filterQuality: FilterQuality.high,
        width: radius * 2,
        height: radius * 2,
        cacheWidth: pixelDim,
        errorBuilder: (context, error, stackTrace) => _buildDefaultPlaceholder(),
      );
    } else if (imageUrl != null && imageUrl!.trim().isNotEmpty) {
      final url = imageUrl!.trim();
      final isAsset = url.startsWith('assets/');
      final isBlob = url.startsWith('blob:');
      final isHttp = url.startsWith('http://') || url.startsWith('https://');

      if (isAsset) {
        avatarImage = Image.asset(
          url,
          fit: BoxFit.cover,
          alignment: effectiveAlignment,
          filterQuality: FilterQuality.high,
          width: radius * 2,
          height: radius * 2,
          cacheWidth: pixelDim,
          errorBuilder: (context, error, stackTrace) => _buildDefaultPlaceholder(),
        );
      } else if (isBlob || kIsWeb) {
        avatarImage = Image.network(
          url,
          fit: BoxFit.cover,
          alignment: effectiveAlignment,
          width: radius * 2,
          height: radius * 2,
          errorBuilder: (context, error, stackTrace) => _buildDefaultPlaceholder(),
        );
      } else if (isHttp) {
        avatarImage = CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          alignment: effectiveAlignment,
          filterQuality: FilterQuality.high,
          width: radius * 2,
          height: radius * 2,
          memCacheWidth: pixelDim,
          placeholder: (context, url) => _buildDefaultPlaceholder(),
          errorWidget: (context, url, error) => _buildDefaultPlaceholder(),
        );
      } else {
        // Native local file path (or web fallback)
        if (kIsWeb) {
          avatarImage = Image.network(
            url,
            fit: BoxFit.cover,
            alignment: effectiveAlignment,
            width: radius * 2,
            height: radius * 2,
            errorBuilder: (context, error, stackTrace) => _buildDefaultPlaceholder(),
          );
        } else {
          try {
            final filePath = url.replaceFirst('file://', '');
            avatarImage = Image.file(
              File(filePath),
              fit: BoxFit.cover,
              alignment: effectiveAlignment,
              filterQuality: FilterQuality.high,
              width: radius * 2,
              height: radius * 2,
              errorBuilder: (context, error, stackTrace) => _buildDefaultPlaceholder(),
            );
          } catch (_) {
            avatarImage = _buildDefaultPlaceholder();
          }
        }
      }
    } else {
      avatarImage = _buildDefaultPlaceholder();
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
    }

    if (isUserAdd) {
      content = Stack(
        clipBehavior: Clip.none,
        children: [
          content,
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: AppColors.accentPink,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(color: AppColors.accentPink.withValues(alpha: 0.5), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 12),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, behavior: HitTestBehavior.opaque, child: content);
    }

    return content;
  }
}
