import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock_explore_data.dart';
import '../../domain/models/explore_stream_model.dart';

/// Search text for the Explore feed.
final exploreSearchProvider = StateProvider<String>((ref) => '');

/// Demo videos matching the current search.
final exploreStreamsProvider = Provider<List<ExploreStreamModel>>((ref) {
  final query = ref.watch(exploreSearchProvider).trim().toLowerCase();
  const all = MockExploreData.exploreStreams;
  if (query.isEmpty) return all;
  return all
      .where(
        (s) =>
            s.streamerName.toLowerCase().contains(query) ||
            s.subCategory.toLowerCase().contains(query) ||
            s.category.toLowerCase().contains(query),
      )
      .toList();
});
