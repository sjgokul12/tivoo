import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animations.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/gloss.dart';
import '../../../../core/widgets/live_badge.dart';
import '../../../live/presentation/live_screen.dart';
import '../../../search/presentation/search_screen.dart';

/// "Popular Live Streams" + "Top Creators" tiles.
class QuickActionCards extends StatelessWidget {
  const QuickActionCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            title: 'Popular\nLive Streams',
            subtitle: 'Trending Now',
            artwork: AppAssets.quickLive,
            accent: const Color(0xFFE040FB),
            subtitleColor: Colors.white,
            background: const [Color(0xFF6A1FB0), Color(0xFF3A0F75), Color(0xFF14062E)],
            border: const [Color(0xFFFF8AD8), Color(0xFFD946EF), Color(0xFF8B5CF6), Color(0xFFFF4FB0)],
            arrow: const [Color(0xFFC04BFF), Color(0xFF7A2BFF)],
            badgeGradient: AppColors.liveGradient,
            onTap: () => Navigator.of(context).push(LiveScreen.route()),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            title: 'Top\nCreators',
            subtitle: 'Follow Your Favourites',
            artwork: AppAssets.quickCreators,
            accent: AppColors.gold,
            subtitleColor: const Color(0xFFFFE07A),
            background: const [Color(0xFF6B4A0E), Color(0xFF3A2808), Color(0xFF120C03)],
            border: const [Color(0xFFFFF0A8), AppColors.gold, Color(0xFFFF9F1C), Color(0xFFFFE07A)],
            arrow: const [Color(0xFFFFD54F), Color(0xFFFF9500)],
            badgeGradient: const LinearGradient(colors: [Color(0xFFFF8A3D), Color(0xFFFF5A1F)]),
            onTap: () => Navigator.of(context).push(SearchScreen.route()),
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.artwork,
    required this.accent,
    required this.subtitleColor,
    required this.background,
    required this.border,
    required this.arrow,
    required this.badgeGradient,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String artwork;
  final Color accent;
  final Color subtitleColor;
  final List<Color> background;
  final List<Color> border;
  final List<Color> arrow;
  final Gradient badgeGradient;
  final VoidCallback onTap;

  static const _radius = 20.0;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return Pressable(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1.72,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            return GlassContainer(
              borderRadius: _radius,
              borderWidth: 1.8,
              shadows: [
                BoxShadow(color: accent.withValues(alpha: 0.75), blurRadius: 22, blurStyle: BlurStyle.outer),
                const BoxShadow(color: Color(0x99000000), blurRadius: 12, offset: Offset(0, 8)),
              ],
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: background,
              ),
              borderGradient: SweepGradient(colors: [...border, border.first]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(_radius),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Coloured light pooling behind the artwork.
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0.6, -0.1),
                          radius: 0.85,
                          colors: [accent.withValues(alpha: 0.5), accent.withValues(alpha: 0)],
                        ),
                      ),
                    ),
                    const DecoratedBox(decoration: BoxDecoration(gradient: Gloss.reflection)),
                    Positioned(
                      right: -w * 0.02,
                      top: -w * 0.03,
                      width: w * 0.56,
                      child: Breathing(
                        float: 3,
                        scale: 0.03,
                        period: const Duration(milliseconds: 2400),
                        child: Image.asset(artwork, cacheWidth: (w * 0.56 * dpr).round()),
                      ),
                    ),
                    Positioned(
                      right: w * 0.05,
                      bottom: w * 0.05,
                      child: Container(
                        width: w * 0.15,
                        height: w * 0.15,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: arrow,
                          ),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.75), width: 1.3),
                          boxShadow: [
                            BoxShadow(color: arrow.last.withValues(alpha: 0.8), blurRadius: 12),
                          ],
                        ),
                        foregroundDecoration: const BoxDecoration(shape: BoxShape.circle, gradient: Gloss.sheen),
                        child: Icon(Icons.chevron_right_rounded, color: Colors.white, size: w * 0.1),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(w * 0.07, w * 0.065, w * 0.22, w * 0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LiveBadge(fontSize: w * 0.05, gradient: badgeGradient),
                          const Spacer(),
                          Padding(
                            padding: EdgeInsets.only(right: w * 0.12),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                title,
                                maxLines: 2,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: w * 0.08,
                                  height: 1.18,
                                  fontWeight: FontWeight.w600,
                                  shadows: const [Shadow(color: Color(0x99000000), blurRadius: 6, offset: Offset(0, 2))],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: w * 0.025),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              subtitle,
                              maxLines: 1,
                              style: TextStyle(color: subtitleColor, fontSize: w * 0.05),
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    // Inner highlight line = thick glass edge.
                    const IgnorePointer(
                      child: CustomPaint(
                        painter: GradientBorderPainter(
                          radius: _radius - 4,
                          inset: 4,
                          width: 0.8,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0x80FFFFFF), Color(0x0AFFFFFF), Color(0x33FFFFFF)],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
