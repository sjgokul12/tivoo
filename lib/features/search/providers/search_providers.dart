import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/live_stream.dart';
import '../../../data/repositories/live_repository.dart';

const _debounce = Duration(milliseconds: 350);

final searchQueryProvider = NotifierProvider.autoDispose<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

/// Debounced search: each keystroke rebuilds this provider, and a rebuild
/// during the wait discards the pending request, so only the last query in a
/// typing burst reaches the API. Empty query lists every live creator.
final searchResultsProvider = FutureProvider.autoDispose<List<LiveStream>>((ref) async {
  final query = ref.watch(searchQueryProvider).trim();
  final repository = ref.read(liveRepositoryProvider);
  if (query.isNotEmpty) {
    await Future<void>.delayed(_debounce);
    if (!ref.mounted) return const [];
  }
  return repository.search(query);
});
