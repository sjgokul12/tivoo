import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
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
    this.allStreams = const [],
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
  final Ref? _ref;
  HomeController([this._ref]) : super(const HomeState());

  void selectCategory(int index) {
    if (state.selectedCategoryIndex != index) {
      state = state.copyWith(selectedCategoryIndex: index);
    }
  }

  void addLiveStream(LiveStreamCardModel stream) {
    final updated = [stream, ...state.allStreams.where((s) => s.id != stream.id)];
    state = state.copyWith(allStreams: updated);
  }

  void removeLiveStream(String streamId) {
    state = state.copyWith(
      allStreams: state.allStreams.where((s) => s.id != streamId).toList(),
    );
  }

  void setStreams(List<LiveStreamCardModel> streams) {
    state = state.copyWith(allStreams: streams);
  }

  void clearStreams() {
    state = state.copyWith(allStreams: const []);
  }

  void toggleFollow(String streamId) {
    bool? nowFollowing;
    final updatedStreams = state.allStreams.map((stream) {
      if (stream.id == streamId) {
        nowFollowing = !stream.isFollowing;
        return stream.copyWith(isFollowing: nowFollowing);
      }
      return stream;
    }).toList();

    state = state.copyWith(allStreams: updatedStreams);
    if (nowFollowing != null && _ref != null) {
      _ref.read(profileControllerProvider.notifier).modifyFollowing(nowFollowing! ? 1 : -1);
      _ref.read(profileControllerProvider.notifier).modifyFollowers(nowFollowing! ? 1 : -1);
    }
  }
}

final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>((ref) {
  return HomeController(ref);
});

// Selected navigation bar tab index provider
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
