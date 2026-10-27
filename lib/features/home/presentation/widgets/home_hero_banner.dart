import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/luxe_theme.dart';

class _Slide {
  final String image;
  final String tag;
  final IconData tagIcon;
  final List<Color> tagColors;
  final String title;
  final String highlight;
  final String subtitle;
  final String cta;
  final IconData ctaIcon;

  const _Slide({
    required this.image,
    required this.tag,
    required this.tagIcon,
    required this.tagColors,
    required this.title,
    required this.highlight,
    required this.subtitle,
    required this.cta,
    required this.ctaIcon,
  });
}

/// Hero carousel: full-bleed banner artwork with parallax between slides and a slow
/// zoom on the active one, a tag chip, title with a gold script highlight, subtitle and
/// a gold call-to-action. Dots sit under the card.
class HomeHeroBanner extends StatefulWidget {
  final VoidCallback? onTap;
  const HomeHeroBanner({super.key, this.onTap});

  @override
  State<HomeHeroBanner> createState() => _HomeHeroBannerState();
}

class _HomeHeroBannerState extends State<HomeHeroBanner> with SingleTickerProviderStateMixin {
  static const _slides = [
    _Slide(
      image: AppAssets.bannerLive,
      tag: 'LIVE NOW',
      tagIcon: Icons.sensors_rounded,
      tagColors: [Color(0xFFFF2D55), LuxeColors.pink],
      title: 'Real People',
      highlight: 'Live Moments',
      subtitle: '12.4K watching right now',
      cta: 'Watch Now',
      ctaIcon: Icons.play_arrow_rounded,
    ),
    _Slide(
      image: AppAssets.bannerPk,
      tag: 'PK BATTLE',
      tagIcon: Icons.bolt_rounded,
      tagColors: [Color(0xFFFF4FB8), Color(0xFF4F8BFF)],
      title: 'Tonight 9 PM',
      highlight: 'Clash of Stars',
      subtitle: 'Pick a side & send power',
      cta: 'Join PK',
      ctaIcon: Icons.sports_kabaddi_rounded,
    ),
    _Slide(
      image: AppAssets.bannerGifts,
      tag: 'NEW GIFTS',
      tagIcon: Icons.auto_awesome_rounded,
      tagColors: [LuxeColors.goldDeep, LuxeColors.gold],
      title: 'Send 3D Gifts',
      highlight: 'Win Rewards',
      subtitle: 'Crowns, castles & rockets',
      cta: 'Send Gift',
      ctaIcon: Icons.card_giftcard_rounded,
    ),
  ];

  final PageController _pages = PageController();
  Timer? _auto;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _auto = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_pages.hasClients) return;
      _pages.animateToPage(
        (_index + 1) % _slides.length,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final slide in _slides) {
      precacheImage(AssetImage(slide.image), context);
    }
  }

  @override
  void dispose() {
    _auto?.cancel();
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 280),
          child: AspectRatio(
            aspectRatio: width >= 600 ? 2.8 : 2.2,
            child: Container(
              padding: const EdgeInsets.all(1.5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [LuxeColors.goldLight, LuxeColors.gold, LuxeColors.violet, LuxeColors.blue],
                  stops: [0, 0.25, 0.65, 1],
                ),
                boxShadow: const [
                  BoxShadow(color: Color(0x55FFC928), blurRadius: 18, offset: Offset(-4, 4)),
                  BoxShadow(color: Color(0x557B4DFF), blurRadius: 18, offset: Offset(4, 4)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.5),
                child: PageView.builder(
                  controller: _pages,
                  itemCount: _slides.length,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (i) {
                    setState(() => _index = i);
                  },
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: widget.onTap,
                    child: _SlideView(slide: _slides[i]),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _slides.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _index ? 22 : 7,
                height: 6,
                decoration: BoxDecoration(
                  gradient: i == _index ? LuxeColors.goldGradient : null,
                  color: i == _index ? null : Colors.white24,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: i == _index ? const [BoxShadow(color: Color(0x99FFC928), blurRadius: 6)] : null,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _SlideView extends StatelessWidget {
  final _Slide slide;

  const _SlideView({required this.slide});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final h = c.maxHeight;
        final w = c.maxWidth;
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              slide.image,
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (_, _, _) => const ColoredBox(color: LuxeColors.bgTop),
            ),
            // Bottom vignette
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x660A0820)],
                  stops: [0.55, 1],
                ),
              ),
            ),
            Positioned(
              left: h * 0.09,
              top: h * 0.09,
              bottom: h * 0.09,
              width: w * 0.58,
              child: DefaultTextStyle.merge(
                style: const TextStyle(fontFamily: 'Poppins'),
                child: _Copy(slide: slide, h: h),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Copy extends StatelessWidget {
  final _Slide slide;
  final double h;
  const _Copy({required this.slide, required this.h});

  @override
  Widget build(BuildContext context) {
    const shadow = [Shadow(color: Color(0xCC000000), blurRadius: 8, offset: Offset(0, 2))];
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tag chip
          Container(
            padding: EdgeInsets.symmetric(horizontal: h * 0.05, vertical: h * 0.015),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: slide.tagColors),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: slide.tagColors.first.withValues(alpha: 0.55), blurRadius: 10)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(slide.tagIcon, color: Colors.white, size: h * 0.075),
                SizedBox(width: h * 0.02),
                Text(
                  slide.tag,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: h * 0.058,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: h * 0.05),
          Text(
            slide.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: h * 0.12,
              fontWeight: FontWeight.w700,
              height: 1.05,
              shadows: shadow,
            ),
          ),
          LuxeGoldText(
            slide.highlight,
            style: TextStyle(
              fontFamily: 'Pacifico',
              fontSize: h * 0.115,
              height: 1.35,
              shadows: const [Shadow(color: Color(0x99FFC928), blurRadius: 10)],
            ),
          ),
          Text(
            slide.subtitle,
            style: TextStyle(color: const Color(0xFFDCD6F5), fontSize: h * 0.062, shadows: shadow),
          ),
          SizedBox(height: h * 0.06),
          // Call to action
          Container(
            padding: EdgeInsets.fromLTRB(h * 0.05, h * 0.025, h * 0.06, h * 0.025),
            decoration: LuxeDecor.goldButton(radius: 30),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(slide.ctaIcon, color: const Color(0xFF241500), size: h * 0.08),
                SizedBox(width: h * 0.02),
                Text(
                  slide.cta,
                  style: TextStyle(color: const Color(0xFF241500), fontSize: h * 0.065, fontWeight: FontWeight.w700),
                ),
                SizedBox(width: h * 0.02),
                Icon(Icons.arrow_forward_rounded, color: const Color(0xFF241500), size: h * 0.07),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
