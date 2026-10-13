import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_live_data.dart';
import '../../domain/models/live_stream_card_model.dart';
import '../../domain/models/streamer_story.dart';

class HomeState {
  final int selectedCategoryIndex;
  final List<String> categories;
  final List<StreamerStory> stories;
  final List<LiveStreamCardModel> allStreams;
  final bool isLoading;

  const HomeState({
    this.selectedCategoryIndex = 0,
    this.categories = MockLiveData.categories,
    this.stories = MockLiveData.stories,
    this.allStreams = MockLiveData.liveStreams,
    this.isLoading = false,
  });

  List<LiveStreamCardModel> get filteredStreams {
    if (selectedCategoryIndex == 0) return allStreams;
    final categoryName = categories[selectedCategoryIndex];
    final filtered = allStreams.where((s) => s.category.toLowerCase() == categoryName.toLowerCase()).toList();
    return filtered.isNotEmpty ? filtered : allStreams;
  }

  HomeState copyWith({
    int? selectedCategoryIndex,
    List<String>? categories,
    List<StreamerStory>? stories,
    List<LiveStreamCardModel>? allStreams,
    bool? isLoading,
  }) {
    return HomeState(
      selectedCategoryIndex: selectedCategoryIndex ?? this.selectedCategoryIndex,
      categories: categories ?? this.categories,
      stories: stories ?? this.stories,
      allStreams: allStreams ?? this.allStreams,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class HomeController extends StateNotifier<HomeState> {
  HomeController() : super(const HomeState());

  void selectCategory(int index) {
    if (state.selectedCategoryIndex != index) {
      state = state.copyWith(selectedCategoryIndex: index);
    }
  }

  void toggleFollow(String streamId) {
    final updatedStreams = state.allStreams.map((stream) {
      if (stream.id == streamId) {
        return stream.copyWith(isFollowing: !stream.isFollowing);
      }
      return stream;
    }).toList();

    state = state.copyWith(allStreams: updatedStreams);
  }
}

final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>((ref) {
  return HomeController();
});

// Selected navigation bar tab index provider
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
