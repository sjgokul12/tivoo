import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/live_badge.dart';
import '../../../../core/widgets/live_video_player.dart';
import '../../domain/models/explore_stream_model.dart';

class ExploreStreamCard extends StatelessWidget {
  final ExploreStreamModel stream;
  final VoidCallback? onCardTap;
  final VoidCallback? onLikeTap;

  const ExploreStreamCard({super.key, required this.stream, this.onCardTap, this.onLikeTap});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onCardTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.glowPurple.withValues(alpha: 0.3), width: 1),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 14, offset: const Offset(0, 6)),
              if (stream.isLive)
                BoxShadow(color: AppColors.glowPink.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: -6),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // 1. Full Cover Image
                Positioned.fill(child: _buildCoverImage()),

                // 2. Top & Bottom Contrast Gradients
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0x70000000), Colors.transparent, Colors.transparent, Color(0xAA000000)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.0, 0.22, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),

                // 3. Top Badges: LIVE and Viewers Count
                Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // LIVE Red Badge
                      if (stream.isLive)
                        LiveBadge(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                          icon: stream.videoAssetPath != null
                              ? const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 14)
                              : null,
                        ),

                      // Viewers Count Pill
                      Flexible(
                        child: MetricBadge(
                          text: stream.viewersCount,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          icon: const Icon(Icons.visibility_outlined, color: Colors.white, size: 12),
                        ),
                      ),
                    ],
                  ),
                ),

                // 4. Bottom Streamer Overlay Glass Card
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: GlassContainer(
                    enableBlur: false,
                    blur: 0,
                    opacity: 0.82,
                    borderRadius: BorderRadius.circular(18),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                    child: Row(
                      children: [
                        // Streamer Avatar
                        CustomAvatar(radius: 17, assetPath: stream.avatarAssetPath, imageUrl: stream.avatarUrl),
                        const SizedBox(width: 8),

                        // Name + Tagline
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      stream.streamerName,
                                      style: AppTextStyles.streamerName.copyWith(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (stream.isVerified) ...[
                                    const SizedBox(width: 3),
                                    const Icon(Icons.verified, color: Colors.white, size: 13),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 1),
                              Text(
                                stream.subCategory,
                                style: AppTextStyles.streamerTagline.copyWith(fontSize: 10.5, color: Colors.white70),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Like Heart Button
                        GestureDetector(
                          onTap: onLikeTap,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha: 0.35),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 0.6),
                            ),
                            child: Icon(
                              stream.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: stream.isLiked ? AppColors.liveRed : Colors.white.withValues(alpha: 0.85),
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage() {
    if (stream.videoAssetPath != null && stream.videoAssetPath!.isNotEmpty) {
      return LiveVideoPlayer(
        playerId: 'grid-${stream.id}',
        videoAssetPath: stream.videoAssetPath!,
        placeholderAssetPath: stream.coverAssetPath,
        placeholderImageUrl: stream.coverImageUrl,
        autoPlay: true,
        isMuted: true,
        showSoundToggle: false,
        fit: BoxFit.cover,
      );
    }
    if (stream.coverAssetPath != null && stream.coverAssetPath!.isNotEmpty) {
      return Image.asset(stream.coverAssetPath!, fit: BoxFit.cover, cacheWidth: 400);
    }
    if (stream.coverImageUrl != null && stream.coverImageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: stream.coverImageUrl!,
        fit: BoxFit.cover,
        memCacheWidth: 400,
        memCacheHeight: 600,
        placeholder: (context, url) => Container(
          color: AppColors.surfaceColor,
          child: const Center(
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPink),
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppColors.surfaceColor,
          child: const Icon(Icons.broken_image, color: Colors.white54, size: 30),
        ),
      );
    }
    return Container(color: AppColors.surfaceColor);
  }
}
