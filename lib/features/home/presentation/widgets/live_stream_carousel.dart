import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/models/live_stream_card_model.dart';
import 'live_stream_card.dart';

class LiveStreamCarousel extends StatefulWidget {
  final List<LiveStreamCardModel> streams;
  final Function(LiveStreamCardModel stream, int index) onCardTap;
  final Function(String streamId) onFollowTap;

  const LiveStreamCarousel({super.key, required this.streams, required this.onCardTap, required this.onFollowTap});

  @override
  State<LiveStreamCarousel> createState() => _LiveStreamCarouselState();
}

class _LiveStreamCarouselState extends State<LiveStreamCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LiveStreamCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_currentIndex >= widget.streams.length && widget.streams.isNotEmpty) {
      _currentIndex = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.streams.isEmpty) {
      return Container(
        height: 360,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.live_tv_rounded, size: 48, color: Colors.white.withValues(alpha: 0.3)),
            const SizedBox(height: 12),
            Text(
              'No live streams in this category',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
            ),
          ],
        ),
      );
    }

    final cardHeight = (context.screenHeight * 0.55).clamp(380.0, 540.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Horizontal Snap-Scroll Card PageView
        SizedBox(
          height: cardHeight,
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: widget.streams.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final stream = widget.streams[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: LiveStreamCard(
                  key: ValueKey(stream.id),
                  stream: stream,
                  onCardTap: () => widget.onCardTap(stream, index),
                  onFollowTap: () => widget.onFollowTap(stream.id),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        // Carousel Page Indicator Dots
        if (widget.streams.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.streams.length, (idx) {
              final isSelected = idx == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                margin: const EdgeInsets.symmetric(horizontal: 3.5),
                width: isSelected ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: isSelected ? AppColors.primaryYellow : Colors.white.withValues(alpha: 0.25),
                  boxShadow: isSelected
                      ? [BoxShadow(color: AppColors.primaryYellow.withValues(alpha: 0.6), blurRadius: 6)]
                      : null,
                ),
              );
            }),
          ),
      ],
    );
  }
}
