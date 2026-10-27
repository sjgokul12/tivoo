import 'dart:io';

import 'package:tivoo/core/config/api_config.dart';
import 'package:tivoo/features/explore/domain/models/video_post.dart';
import 'package:tivoo/features/explore/data/local_posts_repository.dart';
import 'package:tivoo/features/explore/data/remote_posts_repository.dart';

/// Storage for uploaded video posts. [LocalPostsRepository] keeps them on this device;
/// [RemotePostsRepository] talks to the Tivoo backend so every user sees them.
abstract class PostsRepository {
  /// Every post, newest first (Explore feed).
  Future<List<VideoPost>> fetchFeed();

  /// Uploads [video] (with its [thumbnail] image) and returns the created post.
  /// [onProgress] gets 0.0 – 1.0.
  Future<VideoPost> uploadVideo({
    required File video,
    File? thumbnail,
    required PostAuthor author,
    String caption = '',
    void Function(double progress)? onProgress,
  });

  Future<void> deletePost(VideoPost post);

  /// Stable id for this install, used as the author id until login is ready.
  Future<String> deviceId();

  factory PostsRepository.create() =>
      ApiConfig.hasBackend ? RemotePostsRepository(ApiConfig.baseUrl) : LocalPostsRepository();
}
