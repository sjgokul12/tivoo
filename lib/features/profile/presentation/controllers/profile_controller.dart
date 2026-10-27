import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/mock_profile_data.dart';
import '../../domain/models/user_profile_model.dart';

class ProfileState {
  final UserProfileModel profile;
  final int selectedTab; // 0 = Videos, 1 = Images
  final String selectedSort; // 'Recent', 'Most Viewed', 'Popular'
  final bool isUploading;

  const ProfileState({
    required this.profile,
    this.selectedTab = 0,
    this.selectedSort = 'Recent',
    this.isUploading = false,
  });

  List<ProfileMediaPost> get currentPosts {
    final targetType = selectedTab == 0 ? ProfileMediaType.video : ProfileMediaType.image;
    final list = profile.posts.where((p) => p.type == targetType).toList();

    if (selectedSort == 'Recent') {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return list;
  }

  ProfileState copyWith({UserProfileModel? profile, int? selectedTab, String? selectedSort, bool? isUploading}) {
    return ProfileState(
      profile: profile ?? this.profile,
      selectedTab: selectedTab ?? this.selectedTab,
      selectedSort: selectedSort ?? this.selectedSort,
      isUploading: isUploading ?? this.isUploading,
    );
  }
}

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController() : super(ProfileState(profile: MockProfileData.defaultProfile));

  void selectTab(int index) {
    if (state.selectedTab != index) {
      state = state.copyWith(selectedTab: index);
    }
  }

  void setSortFilter(String sort) {
    state = state.copyWith(selectedSort: sort);
  }

  void updateProfile({
    String? name,
    String? username,
    String? bio,
    String? aboutMe,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
  }) {
    state = state.copyWith(
      profile: state.profile.copyWith(
        name: name,
        username: username,
        bio: bio,
        aboutMe: aboutMe,
        email: email,
        phoneNumber: phoneNumber,
        avatarUrl: avatarUrl,
      ),
    );
  }

  void addPost({
    required ProfileMediaType type,
    required String title,
    required String mediaUrl,
    String duration = '05:00',
  }) {
    final newPost = ProfileMediaPost(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      title: title,
      mediaUrl: mediaUrl,
      duration: duration,
      viewsCount: '1.1K',
      likesCount: '450',
      createdAt: DateTime.now(),
    );

    final updatedPosts = [newPost, ...state.profile.posts];
    state = state.copyWith(profile: state.profile.copyWith(posts: updatedPosts));
  }

  void deletePost(String postId) {
    final updatedPosts = state.profile.posts.where((p) => p.id != postId).toList();
    state = state.copyWith(profile: state.profile.copyWith(posts: updatedPosts));
  }

  void modifyFollowing(int delta) {
    final nextFollowing = (state.profile.followingCount + delta).clamp(0, 9999999);
    state = state.copyWith(profile: state.profile.copyWith(followingCount: nextFollowing));
  }

  void modifyFollowers(int delta) {
    int current = int.tryParse(state.profile.followersCount.replaceAll(RegExp(r'[^0-9]'), '')) ?? 4700;
    int next = (current + delta).clamp(0, 9999999);
    String formatted = next >= 1000 ? '${(next / 1000).toStringAsFixed(1)}K' : '$next';
    state = state.copyWith(profile: state.profile.copyWith(followersCount: formatted));
  }
}

final profileControllerProvider = StateNotifierProvider<ProfileController, ProfileState>((ref) {
  return ProfileController();
});
