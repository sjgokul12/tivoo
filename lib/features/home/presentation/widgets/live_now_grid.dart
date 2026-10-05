import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/animations.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/state_message.dart';
import '../../../../data/repositories/live_repository.dart';
import '../../../live/presentation/live_screen.dart';
import '../../providers/live_now_provider.dart';
import 'live_stream_card.dart';

/// Sliver grid of live streams with loading / empty / error / paging states.
class LiveNowGrid extends ConsumerWidget {
  const LiveNowGrid({super.key});

  static const _gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 260,
    mainAxisSpacing: 16,
    crossAxisSpacing: 14,
    childAspectRatio: 0.9,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(liveNowProvider);

    return async.when(
      loading: () => SliverGrid.builder(
        gridDelegate: _gridDelegate,
        itemCount: 4,
        itemBuilder: (_, _) => const GlassContainer(borderRadius: 20, child: SizedBox.expand()),
      ),
      error: (error, _) => SliverToBoxAdapter(
        child: StateMessage(
          icon: Icons.wifi_off_rounded,
          title: 'Could not load live streams',
          message: 'Check your connection and try again.',
          actionLabel: 'Retry',
          onAction: () => ref.invalidate(liveNowProvider),
        ),
      ),
      data: (state) {
        if (state.items.isEmpty) {
          return const SliverToBoxAdapter(
            child: StateMessage(
              icon: Icons.live_tv_rounded,
              title: 'Nobody is live right now',
              message: 'Pull down to refresh.',
            ),
          );
        }
        return SliverMainAxisGroup(
          slivers: [
            SliverGrid.builder(
              gridDelegate: _gridDelegate,
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final stream = state.items[index];
                return FadeSlideIn(
                  key: ValueKey(stream.id),
                  // Stagger each row of the page as it arrives.
                  delay: Duration(milliseconds: 70 * (index % LiveRepository.pageSize)),
                  child: LiveStreamCard(
                    stream: stream,
                    // Alternate gold / blue rims like a checkerboard.
                    accent: (index ~/ 2 + index) % 2 == 0 ? CardAccent.gold : CardAccent.blue,
                    featured: index == 0,
                    onTap: () => Navigator.of(context).push(LiveScreen.route(initialIndex: index)),
                  ),
                );
              },
            ),
            SliverToBoxAdapter(child: _PagingFooter(state: state)),
          ],
        );
      },
    );
  }
}

class _PagingFooter extends ConsumerWidget {
  const _PagingFooter({required this.state});

  final LiveNowState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Widget child;
    if (state.isLoadingMore) {
      child = const SizedBox.square(dimension: 26, child: CircularProgressIndicator(strokeWidth: 2.5));
    } else if (state.loadMoreError != null) {
      child = TextButton.icon(
        onPressed: () => ref.read(liveNowProvider.notifier).loadMore(),
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Couldn\'t load more. Tap to retry'),
        style: TextButton.styleFrom(foregroundColor: AppColors.pink),
      );
    } else if (!state.hasMore) {
      child = const Text("You're all caught up ✨", style: TextStyle(color: AppColors.textMuted, fontSize: 12));
    } else {
      child = const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(child: child),
    );
  }
}
