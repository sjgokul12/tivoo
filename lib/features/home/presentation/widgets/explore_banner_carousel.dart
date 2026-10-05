import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/animations.dart';
import '../../../../core/widgets/crown_icon.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/gloss.dart';
import '../../../../core/widgets/gradient_mask.dart';
import '../../../../core/widgets/neon_ribbons.dart';
import '../../../live/presentation/live_screen.dart';
import '../../../pk/presentation/pk_battle_screen.dart';
import '../../../shell/providers/shell_tab_provider.dart';

enum _BannerAction { goLive, pk, discover }

class _BannerSlide {
  const _BannerSlide({
    required this.script,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.cta,
    required this.action,
    this.artworkHasDecorations = false,
  });

  final String script;
  final String title;
  final String subtitle;
  final String image;
  final String cta;
  final _BannerAction action;

  /// The artwork already contains the LIVE tag, hearts and notes.
  final bool artworkHasDecorations;
}

const _slides = [
  _BannerSlide(
    script: "Let's",
    title: 'Explore',
    subtitle: 'Live Moments, Real People,\nEndless Connections',
    image: AppAssets.heroSinger,
    cta: 'Go Live',
    action: _BannerAction.goLive,
    artworkHasDecorations: true,
  ),
  _BannerSlide(
    script: 'Join the',
    title: 'PK Battle',
    subtitle: 'Two creators, one crown.\nSupport your favourite!',
    image: AppAssets.heroStage,
    cta: 'Watch PK',
    action: _BannerAction.pk,
  ),
  _BannerSlide(
    script: 'Feel the',
    title: 'Music',
    subtitle: 'Live concerts & chill\nsessions all night',
    image: AppAssets.heroConcert,
    cta: 'Discover',
    action: _BannerAction.discover,
  ),
];

/// Auto-advancing hero banner. Only the dots listen to the page index, so
/// page changes don't rebuild the slides.
class ExploreBannerCarousel extends ConsumerStatefulWidget {
  const ExploreBannerCarousel({super.key});

  @override
  ConsumerState<ExploreBannerCarousel> createState() => _ExploreBannerCarouselState();
}

class _ExploreBannerCarouselState extends ConsumerState<ExploreBannerCarousel> {
  static const _interval = Duration(seconds: 5);

  final _controller = PageController();
  final _page = ValueNotifier(0);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _restartTimer();
  }

  void _restartTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) {
      if (!_controller.hasClients) return;
      final next = (_page.value + 1) % _slides.length;
      _controller.animateToPage(next, duration: const Duration(milliseconds: 600), curve: Curves.easeOutCubic);
    });
  }

  void _onAction(_BannerAction action) {
    final navigator = Navigator.of(context);
    switch (action) {
      case _BannerAction.goLive:
        ref.read(shellTabProvider.notifier).select(ShellTab.goLive);
      case _BannerAction.pk:
        navigator.push(PkBattleScreen.route());
      case _BannerAction.discover:
        navigator.push(LiveScreen.route());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = math.min(constraints.maxWidth / 2.0, 300.0);
        final card = GlassContainer(
          borderRadius: 26,
          borderWidth: 1.4,
          shadows: const [
            BoxShadow(color: Color(0x668B5CF6), blurRadius: 22, blurStyle: BlurStyle.outer),
            BoxShadow(color: Color(0xB3000000), blurRadius: 16, offset: Offset(0, 10)),
          ],
          borderGradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0x99FFFFFF), Color(0x33B44CFF), Color(0x33B44CFF), Color(0xCCFFC83D)],
            stops: [0, 0.35, 0.7, 1],
          ),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF070720), Color(0xFF140C3A), Color(0xFF2A0F5C)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                NotificationListener<ScrollStartNotification>(
                  onNotification: (n) {
                    if (n.dragDetails != null) _restartTimer();
                    return false;
                  },
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _slides.length,
                    onPageChanged: (i) => _page.value = i,
                    itemBuilder: (_, i) => _BannerSlideView(
                      slide: _slides[i],
                      height: height,
                      onAction: () => _onAction(_slides[i].action),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: height * 0.05,
                  child: ValueListenableBuilder<int>(
                    valueListenable: _page,
                    builder: (_, page, _) => _Dots(count: _slides.length, active: page),
                  ),
                ),
                // Glass reflection across the whole card.
                const Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(decoration: BoxDecoration(gradient: Gloss.reflection)),
                  ),
                ),
              ],
            ),
          ),
        );

        return SizedBox(
          height: height,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(child: card),
              // Neon ribbons hugging the bottom corners, with travelling light.
              const Positioned.fill(child: NeonRibbons(flares: true)),
            ],
          ),
        );
      },
    );
  }
}

class _BannerSlideView extends StatelessWidget {
  const _BannerSlideView({required this.slide, required this.height, required this.onAction});

  final _BannerSlide slide;
  final double height;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final h = height;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Photo fades into the dark card from the left.
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          width: h * 1.42,
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (rect) => const LinearGradient(
              colors: [Colors.transparent, Colors.black],
              stops: [0.0, 0.32],
            ).createShader(rect),
            child: Image.asset(
              slide.image,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              cacheHeight: (h * dpr).round(),
            ),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-1, 1),
              radius: 1.1,
              colors: [Color(0x4DFF3FA4), Color(0x00FF3FA4)],
            ),
          ),
        ),
        const RepaintBoundary(child: CustomPaint(painter: _LightStreaksPainter())),
        if (!slide.artworkHasDecorations) ...[
          _Sparkle(left: h * 1.45, top: h * 0.12, size: h * 0.12),
          _Sparkle(right: h * 0.08, top: h * 0.55, size: h * 0.13),
          _Sparkle(left: h * 1.5, bottom: h * 0.15, size: h * 0.08),
          Positioned(
            right: h * 0.06,
            bottom: h * 0.08,
            child: Icon(
              Icons.music_note_rounded,
              color: AppColors.pink,
              size: h * 0.12,
              shadows: const [Shadow(color: AppColors.pink, blurRadius: 12)],
            ),
          ),
          Positioned(
            top: h * 0.13,
            right: h * 0.06,
            child: _LiveTag(height: h * 0.15),
          ),
        ],
        Positioned(
          left: h * 0.08,
          top: h * 0.08,
          bottom: h * 0.12,
          width: h * 1.25,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Scales down (never overflows) if fonts/text scaling make it taller.
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tilted headline, like a hand-placed sticker.
                      Padding(
                        padding: EdgeInsets.only(top: h * 0.05),
                        child: Transform.rotate(
                          angle: -0.045,
                          alignment: Alignment.bottomLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                slide.script,
                                style: TextStyle(
                                  fontFamily: AppTheme.scriptFontFamily,
                                  fontSize: h * 0.2,
                                  height: 0.95,
                                  color: Colors.white,
                                  shadows: const [Shadow(color: Color(0x99FF4FB0), blurRadius: 10)],
                                ),
                              ),
                              GradientText(
                                slide.title,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFFFE066), Color(0xFFFFA63D), Color(0xFFFF5FC8), Color(0xFFC86BFF)],
                                  stops: [0, 0.38, 0.72, 1],
                                ),
                                style: TextStyle(
                                  fontSize: h * 0.215,
                                  height: 1.05,
                                  fontWeight: FontWeight.w800,
                                  shadows: const [Shadow(color: Color(0x80FF9500), blurRadius: 14)],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: h * 0.04),
                      Text(
                        slide.subtitle,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: h * 0.058, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: h * 0.03),
              _CtaButton(label: slide.cta, height: h * 0.19, onTap: onAction),
            ],
          ),
        ),
      ],
    );
  }
}

/// Sweeping gold / pink light trails behind the content.
class _LightStreaksPainter extends CustomPainter {
  const _LightStreaksPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;

    void streak(Path path, List<Color> colors, double width) {
      final shader = LinearGradient(colors: colors).createShader(rect);
      canvas
        ..drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = width * 3.5
            ..shader = shader
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        )
        ..drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = width
            ..shader = shader,
        );
    }

    streak(
      Path()
        ..moveTo(-8, h * 0.66)
        ..quadraticBezierTo(w * 0.28, h * 1.16, w * 0.72, h * 0.95)
        ..quadraticBezierTo(w * 0.9, h * 0.87, w + 8, h * 0.7),
      const [Color(0x00FFC83D), Color(0xFFFFC83D), Color(0xFFFF9F1C), Color(0x66FF4FB0)],
      1.4,
    );
    streak(
      Path()
        ..moveTo(w * 0.5, -6)
        ..quadraticBezierTo(w * 0.78, h * 0.13, w + 8, h * 0.02),
      const [Color(0x00B44CFF), Color(0xCCB44CFF), Color(0xCCFF4FB0)],
      1,
    );
  }

  @override
  bool shouldRepaint(_LightStreaksPainter oldDelegate) => false;
}

/// Bright gold neon "Go Live" pill.
class _CtaButton extends StatelessWidget {
  const _CtaButton({required this.label, required this.height, required this.onTap});

  final String label;
  final double height;
  final VoidCallback onTap;

  static const _gold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF4B0), Color(0xFFFFD23D), Color(0xFFFFA000), Color(0xFFFFE680)],
    stops: [0, 0.35, 0.7, 1],
  );

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: ShimmerSweep(
        period: const Duration(milliseconds: 3200),
        color: const Color(0x80FFF4B0),
        child: GlassContainer(
          borderRadius: height,
          borderWidth: 2.2,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xCC3A2A08), Color(0xE6140C02)],
          ),
          borderGradient: _gold,
          shadows: const [
            BoxShadow(color: Color(0xE6FFC83D), blurRadius: 16, blurStyle: BlurStyle.outer),
            BoxShadow(color: Color(0x66FF9F1C), blurRadius: 28, blurStyle: BlurStyle.outer),
          ],
          padding: EdgeInsets.symmetric(horizontal: height * 0.42),
          child: SizedBox(
            height: height,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GradientMask(
                  gradient: _gold,
                  child: Icon(
                    Icons.sensors_rounded,
                    size: height * 0.6,
                    shadows: const [Shadow(color: Color(0xFFFFC83D), blurRadius: 10)],
                  ),
                ),
                SizedBox(width: height * 0.2),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: height * 0.38,
                    fontWeight: FontWeight.w600,
                    shadows: const [Shadow(color: Color(0x99FFC83D), blurRadius: 8)],
                  ),
                ),
                SizedBox(width: height * 0.22),
                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: height * 0.42),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LiveTag extends StatelessWidget {
  const _LiveTag({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GlassContainer(
          borderRadius: height * 0.35,
          color: const Color(0x55FF3FA4),
          borderColor: const Color(0xCCFF8AD0),
          borderWidth: 1.5,
          glowColor: AppColors.pink,
          glowBlur: 14,
          padding: EdgeInsets.symmetric(horizontal: height * 0.35, vertical: height * 0.12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: height * 0.36,
                height: height * 0.36,
                decoration: const BoxDecoration(color: AppColors.live, shape: BoxShape.circle),
              ),
              SizedBox(width: height * 0.2),
              Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: height * 0.52,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: height * 0.3,
          top: -height * 0.62,
          child: CrownIcon(size: height * 0.62),
        ),
      ],
    );
  }
}

class _Sparkle extends StatelessWidget {
  const _Sparkle({required this.size, this.left, this.right, this.top, this.bottom});

  final double size;
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Icon(
        Icons.favorite_rounded,
        size: size,
        color: const Color(0xFFFF4FA3),
        shadows: const [Shadow(color: Color(0xCCFF4FA3), blurRadius: 14)],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.active});

  final int count;
  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == active ? 18 : 7,
            height: 7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: i == active ? AppColors.goldGradient : null,
              color: i == active ? null : Colors.white.withValues(alpha: 0.35),
            ),
          ),
      ],
    );
  }
}
