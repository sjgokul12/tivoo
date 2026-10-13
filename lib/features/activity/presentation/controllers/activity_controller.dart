import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_activity_data.dart';
import '../../domain/models/activity_item_model.dart';

class ActivityState {
  final int selectedCategoryIndex;
  final List<String> categories;
  final List<ActivityItemModel> allActivities;

  const ActivityState({
    this.selectedCategoryIndex = 0,
    this.categories = MockActivityData.categories,
    this.allActivities = MockActivityData.activities,
  });

  List<ActivityItemModel> get filteredActivities {
    if (selectedCategoryIndex == 0) return allActivities;
    final category = categories[selectedCategoryIndex].toLowerCase();
    final results = allActivities.where((a) {
      return a.category.toLowerCase() == category;
    }).toList();
    return results.isNotEmpty ? results : allActivities;
  }

  ActivityState copyWith({
    int? selectedCategoryIndex,
    List<String>? categories,
    List<ActivityItemModel>? allActivities,
  }) {
    return ActivityState(
      selectedCategoryIndex:
          selectedCategoryIndex ?? this.selectedCategoryIndex,
      categories: categories ?? this.categories,
      allActivities: allActivities ?? this.allActivities,
    );
  }
}

class ActivityController extends StateNotifier<ActivityState> {
  ActivityController() : super(const ActivityState());

  void selectCategory(int index) {
    if (state.selectedCategoryIndex != index) {
      state = state.copyWith(selectedCategoryIndex: index);
    }
  }

  void toggleFollow(String id) {
    final updated = state.allActivities.map((act) {
      if (act.id == id) {
        return act.copyWith(isFollowing: !act.isFollowing);
      }
      return act;
    }).toList();

    state = state.copyWith(allActivities: updated);
  }
}

final activityControllerProvider =
    StateNotifierProvider<ActivityController, ActivityState>((ref) {
  return ActivityController();
});
