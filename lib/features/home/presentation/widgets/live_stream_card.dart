import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/live_badge.dart';
import '../../../../core/widgets/live_video_player.dart';
import '../../domain/models/live_stream_card_model.dart';

class LiveStreamCard extends StatelessWidget {
  final LiveStreamCardModel stream;
  final VoidCallback? onCardTap;
  final VoidCallback? onFollowTap;

  const LiveStreamCard({super.key, required this.stream, this.onCardTap, this.onFollowTap});

  @override
  Widget build(BuildContext context) {
    final cardHeight = (context.screenHeight * 0.58).clamp(380.0, 560.0);

    final card = RepaintBoundary(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onCardTap,
        child: Container(
          height: cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.primaryYellow.withValues(alpha: 0.45), width: 1.2),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 24, offset: const Offset(0, 12)),
              if (stream.isLive)
                BoxShadow(color: AppColors.primaryYellow.withValues(alpha: 0.22), blurRadius: 28, spreadRadius: -6),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: Stack(
              children: [
                // 1. Background Live Streamer Video / Image
                Positioned.fill(child: _buildCoverMedia()),

                // 2. Cinematic Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0x80000000), Colors.transparent, Colors.transparent, Color(0xC0000000)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.0, 0.22, 0.60, 1.0],
                      ),
                    ),
                  ),
                ),

                // 3. Top Badges: LIVE, Viewers (100M), Diamonds (24.2K)
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left Badges: LIVE + Viewers
                      Row(
                        children: [
                          if (stream.isLive) ...[const LiveBadge(), const SizedBox(width: 8)],
                          MetricBadge(
                            text: stream.viewersCount,
                            icon: const Icon(Icons.visibility_outlined, color: Colors.white, size: 15),
                          ),
                        ],
                      ),

                      // Right Badges: 💎 24.2K + Mute button matching Image 2
                      Row(
                        children: [
                          MetricBadge(
                            text: stream.diamondsCount,
                            icon: const Text('💎', style: TextStyle(fontSize: 12)),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha: 0.55),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1),
                            ),
                            child: const Icon(Icons.volume_off_rounded, color: Colors.white, size: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 4. Bottom Streamer Bar Overlay matching screenshot
                Positioned(
                  bottom: 14,
                  left: 14,
                  right: 14,
                  child: GlassContainer(
                    enableBlur: false,
                    blur: 0,
                    opacity: 0.85,
                    borderRadius: BorderRadius.circular(28),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        // Streamer Avatar
                        CustomAvatar(
                          radius: 23,
                          assetPath: stream.streamerAssetPath,
                          imageUrl: stream.streamerAvatarUrl,
                        ),
                        const SizedBox(width: 12),

                        // Streamer Name + Verified Icon + Bio
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
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (stream.isVerified) ...[
                                    const SizedBox(width: 5),
                                    const Icon(Icons.verified, color: Colors.white, size: 16),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                stream.streamerBio,
                                style: AppTextStyles.streamerTagline.copyWith(fontSize: 12.5, color: Colors.white70),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Follow Action Button (Pink to Blue gradient pill)
                        GestureDetector(
                          onTap: onFollowTap,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: stream.isFollowing
                                  ? const LinearGradient(colors: [Color(0x55FFFFFF), Color(0x33FFFFFF)])
                                  : AppColors.followButtonGradient,
                              boxShadow: stream.isFollowing
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: AppColors.primaryYellow.withValues(alpha: 0.35),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                            ),
                            child: Text(
                              stream.isFollowing ? 'Following' : 'Follow',
                              style: AppTextStyles.buttonSmall.copyWith(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: stream.isFollowing ? Colors.white : AppColors.textOnPrimary,
                              ),
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

    if (context.isTablet) {
      return Center(
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 480), child: card),
      );
    }
    return card;
  }

  Widget _buildCoverMedia() {
    if (stream.videoAssetPath != null && stream.videoAssetPath!.isNotEmpty) {
      return LiveVideoPlayer(
        playerId: stream.id,
        videoAssetPath: stream.videoAssetPath!,
        placeholderAssetPath: stream.coverAssetPath,
        placeholderImageUrl: stream.coverImageUrl,
        autoPlay: true,
        isMuted: true,
        showSoundToggle: true,
        fit: BoxFit.cover,
      );
    }
    if (stream.coverAssetPath != null && stream.coverAssetPath!.isNotEmpty) {
      return Image.asset(stream.coverAssetPath!, fit: BoxFit.cover, cacheWidth: 600);
    }
    if (stream.coverImageUrl != null && stream.coverImageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: stream.coverImageUrl!,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 150),
        fadeOutDuration: Duration.zero,
        memCacheWidth: 1000,
        memCacheHeight: 1400,
        placeholder: (context, url) => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1F1F30), Color(0xFF13131E)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPink),
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: AppColors.surfaceColor,
          child: const Icon(Icons.broken_image, color: Colors.white54, size: 40),
        ),
      );
    }
    return Container(color: AppColors.surfaceColor);
  }
}
