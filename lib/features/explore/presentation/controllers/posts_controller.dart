import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tivoo/core/constants/app_assets.dart';
import 'package:tivoo/features/profile/presentation/controllers/profile_controller.dart';
import 'package:tivoo/features/explore/data/posts_repository.dart';
import 'package:tivoo/features/explore/data/video_processor.dart';
import 'package:tivoo/features/explore/domain/models/video_post.dart';

enum UploadStep { converting, uploading }

class PostsState {
  /// All uploaded posts, newest first.
  final List<VideoPost> posts;

  /// This install's author id (null until loaded).
  final String? myId;
  final bool isLoading;
  final String? loadError;

  const PostsState({this.posts = const [], this.myId, this.isLoading = false, this.loadError});

  List<VideoPost> get myPosts => myId == null ? const [] : posts.where((p) => p.authorId == myId).toList();

  bool isMine(VideoPost post) => post.authorId == myId;

  PostsState copyWith({
    List<VideoPost>? posts,
    String? myId,
    bool? isLoading,
    String? loadError,
    bool clearError = false,
  }) {
    return PostsState(
      posts: posts ?? this.posts,
      myId: myId ?? this.myId,
      isLoading: isLoading ?? this.isLoading,
      loadError: clearError ? null : (loadError ?? this.loadError),
    );
  }
}

class PostsController extends StateNotifier<PostsState> {
  final Ref _ref;
  final PostsRepository _repo;

  PostsController(this._ref, this._repo) : super(const PostsState()) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final id = state.myId ?? await _repo.deviceId();
      final posts = await _repo.fetchFeed();
      if (!mounted) return;
      state = state.copyWith(posts: posts, myId: id, isLoading: false);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, loadError: '$e');
    }
  }

  /// Converts [video] to a phone-friendly MP4, then posts it as the current profile and
  /// puts it at the top of every feed. [onProgress] reports the step and 0 – 1 within it.
  Future<VideoPost> upload(
    File video, {
    File? thumbnail,
    String caption = '',
    void Function(UploadStep step, double progress)? onProgress,
  }) async {
    final playable = await VideoProcessor.makePlayable(
      video.path,
      onProgress: (p) => onProgress?.call(UploadStep.converting, p),
    );
    thumbnail ??= await VideoProcessor.thumbnail(playable.path);
    final profile = _ref.read(profileControllerProvider).profile;
    final id = state.myId ?? await _repo.deviceId();
    final post = await _repo.uploadVideo(
      video: playable,
      thumbnail: thumbnail,
      caption: caption,
      onProgress: (p) => onProgress?.call(UploadStep.uploading, p),
      author: PostAuthor(
        id: id,
        name: profile.name,
        username: profile.username,
        avatar: profile.avatarUrl.isNotEmpty ? profile.avatarUrl : AppAssets.status5,
      ),
    );
    if (mounted) state = state.copyWith(myId: id, posts: [post, ...state.posts.where((p) => p.id != post.id)]);
    return post;
  }

  Future<void> delete(VideoPost post) async {
    await _repo.deletePost(post);
    if (mounted) state = state.copyWith(posts: state.posts.where((p) => p.id != post.id).toList());
  }
}

final postsRepositoryProvider = Provider<PostsRepository>((ref) => PostsRepository.create());

final postsControllerProvider = StateNotifierProvider<PostsController, PostsState>((ref) {
  return PostsController(ref, ref.watch(postsRepositoryProvider));
});
