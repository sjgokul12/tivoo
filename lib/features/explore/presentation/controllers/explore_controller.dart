import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_explore_data.dart';
import '../../domain/models/explore_stream_model.dart';

class ExploreState {
  final List<ExploreStreamModel> allStreams;
  final String searchQuery;
  final bool isReelsView;

  const ExploreState({
    this.allStreams = MockExploreData.exploreStreams,
    this.searchQuery = '',
    this.isReelsView = true,
  });

  List<ExploreStreamModel> get filteredStreams {
    if (searchQuery.trim().isEmpty) {
      return allStreams;
    }

    final query = searchQuery.toLowerCase().trim();
    return allStreams.where((s) {
      return s.streamerName.toLowerCase().contains(query) ||
          s.subCategory.toLowerCase().contains(query) ||
          s.category.toLowerCase().contains(query);
    }).toList();
  }

  ExploreState copyWith({List<ExploreStreamModel>? allStreams, String? searchQuery, bool? isReelsView}) {
    return ExploreState(
      allStreams: allStreams ?? this.allStreams,
      searchQuery: searchQuery ?? this.searchQuery,
      isReelsView: isReelsView ?? this.isReelsView,
    );
  }
}

class ExploreController extends StateNotifier<ExploreState> {
  ExploreController() : super(const ExploreState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void toggleViewMode() {
    state = state.copyWith(isReelsView: !state.isReelsView);
  }

  void setViewMode(bool isReels) {
    if (state.isReelsView != isReels) {
      state = state.copyWith(isReelsView: isReels);
    }
  }

  void toggleLike(String streamId) {
    final updated = state.allStreams.map((stream) {
      if (stream.id == streamId) {
        return stream.copyWith(isLiked: !stream.isLiked);
      }
      return stream;
    }).toList();

    state = state.copyWith(allStreams: updated);
  }
}

final exploreControllerProvider = StateNotifierProvider<ExploreController, ExploreState>((ref) {
  return ExploreController();
});
