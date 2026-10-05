import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/animations.dart';
import '../../../../core/widgets/app_image.dart';
import '../../../../core/widgets/crown_icon.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/gloss.dart';
import '../../../../core/widgets/live_badge.dart';
import '../../../../data/models/live_stream.dart';

/// Neon accent for a card's rim and glow.
enum CardAccent {
  gold([Color(0xFFFFF0A8), Color(0xFFFFC83D), Color(0x80FFFFFF), Color(0xFFFF9F1C)], Color(0xFFFFB020)),
  blue([Color(0xFFA8D8FF), Color(0xFF4F8CFF), Color(0x80FFFFFF), Color(0xFFB44CFF)], Color(0xFF3B82F6));

  const CardAccent(this.rim, this.glow);

  final List<Color> rim;
  final Color glow;
}

/// Live-stream card: photo, LIVE + viewers, stream title, host with
/// verified badge, category chip and a breathing neon rim.
class LiveStreamCard extends StatelessWidget {
  const LiveStreamCard({
    super.key,
    required this.stream,
    required this.onTap,
    this.accent = CardAccent.gold,
    this.featured = false,
  });

  final LiveStream stream;
  final VoidCallback onTap;
  final CardAccent accent;

  /// Shows a crown on the top-ranked stream.
  final bool featured;

  static const _radius = 22.0;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(_radius);
    return Pressable(
      onTap: onTap,
      child: _BreathingGlow(
        color: accent.glow,
        radius: _radius,
        child: CustomPaint(
          foregroundPainter: GradientBorderPainter(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: accent.rim,
              stops: const [0, 0.3, 0.6, 1],
            ),
            radius: _radius,
            width: 1.8,
          ),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                AppImage(path: stream.thumbnail, cacheWidth: 260, alignment: const Alignment(0, -0.3)),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x66000000), Color(0x00000000), Color(0x8C12062E), Color(0xF20C0424)],
                      stops: [0, 0.25, 0.55, 1],
                    ),
                  ),
                ),
                const DecoratedBox(decoration: BoxDecoration(gradient: Gloss.reflection)),
                Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: Row(
                    children: [
                      const LiveBadge(fontSize: 10, pulse: true),
                      const SizedBox(width: 6),
                      InfoPill(
                        fontSize: 10,
                        leading: const Icon(Icons.visibility_outlined, size: 12, color: Colors.white),
                        label: Formatters.compact(stream.viewers),
                      ),
                      const Spacer(),
                      if (featured) const Breathing(scale: 0.15, child: CrownIcon(size: 18)),
                    ],
                  ),
                ),
                Positioned(left: 10, right: 6, bottom: 10, child: _Details(stream: stream)),
                // Inner glass edge.
                const IgnorePointer(
                  child: CustomPaint(
                    painter: GradientBorderPainter(
                      radius: _radius - 4,
                      inset: 4,
                      width: 0.8,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0x66FFFFFF), Color(0x00FFFFFF), Color(0x26FFFFFF)],
                      ),
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
}

class _Details extends StatelessWidget {
  const _Details({required this.stream});

  final LiveStream stream;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          stream.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            height: 1.25,
            shadows: [Shadow(color: Color(0xCC000000), blurRadius: 6)],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Avatar(image: stream.streamer.avatar, size: 34, ringWidth: 1.6),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          stream.streamer.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFFFE07A),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                      ),
                      if (stream.streamer.isVerified) ...[
                        const SizedBox(width: 3),
                        const Icon(Icons.verified_rounded, size: 13, color: AppColors.gold),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  _CategoryChip(label: stream.category),
                ],
              ),
            ),
            const Icon(Icons.more_vert_rounded, size: 18, color: Colors.white70),
          ],
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0x597C3AED),
        border: Border.all(color: const Color(0x66B44CFF)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome_rounded, size: 9, color: Color(0xFFE2B8FF)),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFFE2DCFF), fontSize: 9.5, height: 1.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Neon halo that slowly brightens and dims. Only the halo layer repaints.
class _BreathingGlow extends StatefulWidget {
  const _BreathingGlow({required this.child, required this.color, required this.radius});

  final Widget child;
  final Color color;
  final double radius;

  @override
  State<_BreathingGlow> createState() => _BreathingGlowState();
}

class _BreathingGlowState extends State<_BreathingGlow> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = RepaintBoundary(child: widget.child);
    return AnimatedBuilder(
      animation: _controller,
      child: child,
      builder: (context, child) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.35 + 0.45 * _controller.value),
              blurRadius: 14 + 8 * _controller.value,
              blurStyle: BlurStyle.outer,
            ),
            const BoxShadow(color: Color(0xB3000000), blurRadius: 14, offset: Offset(0, 10)),
          ],
        ),
        child: child,
      ),
    );
  }
}
