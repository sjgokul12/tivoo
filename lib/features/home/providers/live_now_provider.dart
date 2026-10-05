import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/live_stream.dart';
import '../../../data/repositories/live_repository.dart';

@immutable
class LiveNowState {
  const LiveNowState({
    required this.items,
    required this.nextPage,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  final List<LiveStream> items;
  final int nextPage;
  final bool hasMore;
  final bool isLoadingMore;
  final Object? loadMoreError;

  LiveNowState copyWith({
    List<LiveStream>? items,
    int? nextPage,
    bool? hasMore,
    bool? isLoadingMore,
    Object? loadMoreError,
  }) {
    return LiveNowState(
      items: items ?? this.items,
      nextPage: nextPage ?? this.nextPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: loadMoreError,
    );
  }
}

/// Paginated "Live Now" feed shared by Home and the Discover live viewer.
/// Kept alive so returning to Home doesn't refetch (acts as the page cache).
final liveNowProvider = AsyncNotifierProvider<LiveNowNotifier, LiveNowState>(LiveNowNotifier.new);

class LiveNowNotifier extends AsyncNotifier<LiveNowState> {
  @override
  Future<LiveNowState> build() async {
    final page = await ref.read(liveRepositoryProvider).fetchLiveStreams(page: 0);
    return LiveNowState(items: page.items, nextPage: 1, hasMore: page.hasMore);
  }

  /// Safe to call from scroll callbacks: those can fire mid-layout (e.g. when
  /// new items grow the list), so the state change is deferred a microtask.
  Future<void> loadMore() async {
    await Future<void>.microtask(() {});
    if (!ref.mounted) return;
    final current = state.value;
    if (current == null || state.isLoading || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final page = await ref.read(liveRepositoryProvider).fetchLiveStreams(page: current.nextPage);
      if (!ref.mounted) return;
      state = AsyncData(
        current.copyWith(
          items: [...current.items, ...page.items],
          nextPage: current.nextPage + 1,
          hasMore: page.hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (error) {
      if (!ref.mounted) return;
      state = AsyncData(current.copyWith(isLoadingMore: false, loadMoreError: error));
    }
  }
}
