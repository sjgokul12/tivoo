import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/responsive.dart';
import '../../../core/widgets/animations.dart';
import '../../live/presentation/live_screen.dart';
import '../providers/live_now_provider.dart';
import 'widgets/explore_banner_carousel.dart';
import 'widgets/home_header.dart';
import 'widgets/live_now_grid.dart';
import 'widgets/quick_action_cards.dart';
import 'widgets/section_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  bool _onScroll(ScrollNotification notification, WidgetRef ref) {
    // Prefetch the next page before the user reaches the end.
    if (notification.metrics.axis == Axis.vertical && notification.metrics.extentAfter < 500) {
      ref.read(liveNowProvider.notifier).loadMore();
    }
    return false;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padding = MediaQuery.paddingOf(context);
    final gap = context.scaled(20);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
        child: RefreshIndicator(
          edgeOffset: padding.top,
          onRefresh: () => ref.refresh(liveNowProvider.future),
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) => _onScroll(n, ref),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, padding.top + 8, 16, 0),
                  sliver: SliverList.list(
                    children: [
                      const FadeSlideIn(child: HomeHeader()),
                      SizedBox(height: gap),
                      const FadeSlideIn(delay: Duration(milliseconds: 90), child: ExploreBannerCarousel()),
                      SizedBox(height: gap),
                      const FadeSlideIn(delay: Duration(milliseconds: 180), child: QuickActionCards()),
                      SizedBox(height: gap * 1.2),
                      FadeSlideIn(
                        delay: const Duration(milliseconds: 260),
                        child: SectionHeader(
                          title: 'Live Now',
                          subtitle: 'Real People · Real Moments',
                          leading: '🔥',
                          onViewAll: () => Navigator.of(context).push(LiveScreen.route()),
                        ),
                      ),
                      SizedBox(height: gap * 0.8),
                    ],
                  ),
                ),
                const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  sliver: LiveNowGrid(),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 120 + padding.bottom)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
