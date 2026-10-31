import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock_gifter_data.dart';
import '../../domain/models/gifter_level_model.dart';

enum MilestoneFilter {
  all,
  unlocked,
  locked,
}

extension MilestoneFilterX on MilestoneFilter {
  String get label {
    switch (this) {
      case MilestoneFilter.all:
        return 'All (19)';
      case MilestoneFilter.unlocked:
        return 'Unlocked';
      case MilestoneFilter.locked:
        return 'Locked';
    }
  }
}

class GifterLevelState {
  final GifterUserStatus userStatus;
  final List<GifterMilestone> milestones;
  final MilestoneFilter filter;
  final bool isGridView;
  final GifterMilestone? selectedMilestone;

  const GifterLevelState({
    required this.userStatus,
    required this.milestones,
    this.filter = MilestoneFilter.all,
    this.isGridView = true,
    this.selectedMilestone,
  });

  /// Filtered milestones based on current filter.
  List<GifterMilestone> get filteredMilestones {
    switch (filter) {
      case MilestoneFilter.all:
        return milestones;
      case MilestoneFilter.unlocked:
        return milestones.where((m) => m.isUnlocked(userStatus.currentLevel)).toList();
      case MilestoneFilter.locked:
        return milestones.where((m) => !m.isUnlocked(userStatus.currentLevel)).toList();
    }
  }

  int get unlockedCount => milestones.where((m) => m.isUnlocked(userStatus.currentLevel)).length;
  int get lockedCount => milestones.where((m) => !m.isUnlocked(userStatus.currentLevel)).length;

  GifterLevelState copyWith({
    GifterUserStatus? userStatus,
    List<GifterMilestone>? milestones,
    MilestoneFilter? filter,
    bool? isGridView,
    GifterMilestone? selectedMilestone,
    bool clearSelectedMilestone = false,
  }) {
    return GifterLevelState(
      userStatus: userStatus ?? this.userStatus,
      milestones: milestones ?? this.milestones,
      filter: filter ?? this.filter,
      isGridView: isGridView ?? this.isGridView,
      selectedMilestone:
          clearSelectedMilestone ? null : (selectedMilestone ?? this.selectedMilestone),
    );
  }
}

class GifterLevelController extends StateNotifier<GifterLevelState> {
  GifterLevelController()
      : super(
          GifterLevelState(
            userStatus: MockGifterData.computeStatusForLevel(
              level: MockGifterData.demoInitialLevel,
              customStarsSpent: MockGifterData.demoInitialStarsSpent,
            ),
            milestones: MockGifterData.milestones,
          ),
        );

  void setFilter(MilestoneFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void toggleViewMode() {
    state = state.copyWith(isGridView: !state.isGridView);
  }

  void setGridView(bool isGrid) {
    state = state.copyWith(isGridView: isGrid);
  }

  void selectMilestone(GifterMilestone? milestone) {
    if (milestone == null) {
      state = state.copyWith(clearSelectedMilestone: true);
    } else {
      state = state.copyWith(selectedMilestone: milestone);
    }
  }

  /// Changes the demo simulated level for interactive testing & previewing.
  void setDemoLevel(int level) {
    final newStatus = MockGifterData.computeStatusForLevel(level: level);
    state = state.copyWith(userStatus: newStatus);
  }

  /// Resets to default demo level.
  void resetDemo() {
    setDemoLevel(MockGifterData.demoInitialLevel);
  }
}

final gifterLevelControllerProvider =
    StateNotifierProvider<GifterLevelController, GifterLevelState>((ref) {
  return GifterLevelController();
});

