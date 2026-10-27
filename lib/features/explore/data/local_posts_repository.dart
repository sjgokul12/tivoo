import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';

import 'package:tivoo/features/explore/domain/models/video_post.dart';
import 'package:tivoo/features/explore/data/posts_repository.dart';

/// Keeps uploaded videos in the app's private storage, so posts survive app restarts
/// even when the user deletes the original from their gallery.
class LocalPostsRepository implements PostsRepository {
  Future<Directory> _postsDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}${Platform.pathSeparator}tivoo_posts');
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<File> _indexFile() async => File('${(await _postsDir()).path}${Platform.pathSeparator}posts.json');

  Future<List<VideoPost>> _readIndex() async {
    try {
      final file = await _indexFile();
      if (!await file.exists()) return [];
      final list = jsonDecode(await file.readAsString()) as List<dynamic>;
      return list.map((e) => VideoPost.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _writeIndex(List<VideoPost> posts) async {
    final file = await _indexFile();
    await file.writeAsString(jsonEncode(posts.map((p) => p.toJson()).toList()), flush: true);
  }

  @override
  Future<List<VideoPost>> fetchFeed() async {
    final posts = await _readIndex();
    // Drop posts whose video file is gone.
    final alive = <VideoPost>[];
    for (final p in posts) {
      if (await File(p.videoUrl).exists()) alive.add(p);
    }
    alive.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return alive;
  }

  @override
  Future<VideoPost> uploadVideo({
    required File video,
    File? thumbnail,
    required PostAuthor author,
    String caption = '',
    void Function(double progress)? onProgress,
  }) async {
    final id = 'post_${DateTime.now().millisecondsSinceEpoch}';
    final dir = (await _postsDir()).path;
    final sep = Platform.pathSeparator;
    // Keep private copies so posts survive cache cleanup and gallery deletes.
    final savedVideo = await video.copy('$dir$sep$id.mp4');
    final savedThumb = thumbnail == null ? null : await thumbnail.copy('$dir$sep$id.jpg');

    final post = VideoPost(
      id: id,
      authorId: author.id,
      authorName: author.name,
      authorUsername: author.username,
      authorAvatar: author.avatar,
      videoUrl: savedVideo.path,
      thumbnailUrl: savedThumb?.path,
      caption: caption,
      createdAt: DateTime.now(),
    );
    await _writeIndex([post, ...await _readIndex()]);
    onProgress?.call(1);
    return post;
  }

  @override
  Future<void> deletePost(VideoPost post) async {
    await _writeIndex((await _readIndex()).where((p) => p.id != post.id).toList());
    for (final path in [post.videoUrl, post.thumbnailUrl]) {
      if (path != null && await File(path).exists()) await File(path).delete();
    }
  }

  @override
  Future<String> deviceId() => readOrCreateDeviceId();
}

/// Random id saved once per install.
Future<String> readOrCreateDeviceId() async {
  final docs = await getApplicationDocumentsDirectory();
  final file = File('${docs.path}${Platform.pathSeparator}tivoo_device_id');
  if (await file.exists()) {
    final id = (await file.readAsString()).trim();
    if (id.isNotEmpty) return id;
  }
  final r = Random.secure();
  final id = 'u_${List.generate(16, (_) => r.nextInt(16).toRadixString(16)).join()}';
  await file.writeAsString(id, flush: true);
  return id;
}
