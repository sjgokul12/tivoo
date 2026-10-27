import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:tivoo/features/explore/domain/models/video_post.dart';
import 'package:tivoo/features/explore/data/local_posts_repository.dart';
import 'package:tivoo/features/explore/data/posts_repository.dart';

/// Talks to the Tivoo backend (see backend/README.md for the API).
class RemotePostsRepository implements PostsRepository {
  final String baseUrl;
  final http.Client _client = http.Client();

  RemotePostsRepository(String baseUrl)
    : baseUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  /// The server may return paths like "/uploads/x.mp4"; make them absolute.
  String _absolute(String? url) {
    if (url == null || url.isEmpty) return '';
    return url.startsWith('/') ? '$baseUrl$url' : url;
  }

  VideoPost _parse(Map<String, dynamic> json) {
    final post = VideoPost.fromJson(json);
    final thumb = _absolute(post.thumbnailUrl);
    return VideoPost.fromJson({
      ...post.toJson(),
      'videoUrl': _absolute(post.videoUrl),
      'thumbnailUrl': thumb.isEmpty ? null : thumb,
    });
  }

  Never _fail(http.Response res) {
    String message = 'Server error ${res.statusCode}';
    try {
      final body = jsonDecode(res.body);
      if (body is Map && body['error'] is String) message = body['error'] as String;
    } catch (_) {}
    throw HttpException(message);
  }

  @override
  Future<List<VideoPost>> fetchFeed() async {
    final res = await _client.get(_uri('/api/videos')).timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) _fail(res);
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    return (body['videos'] as List<dynamic>).map((e) => _parse(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<VideoPost> uploadVideo({
    required File video,
    File? thumbnail,
    required PostAuthor author,
    String caption = '',
    void Function(double progress)? onProgress,
  }) async {
    final multipart = http.MultipartRequest('POST', _uri('/api/videos'))
      ..fields.addAll({
        'authorId': author.id,
        'authorName': author.name,
        'authorUsername': author.username,
        // Only URLs make sense to other users; local file / asset avatars are dropped.
        'authorAvatar': author.avatar.startsWith('http') ? author.avatar : '',
        'caption': caption,
      })
      ..files.add(await http.MultipartFile.fromPath('video', video.path));
    if (thumbnail != null) multipart.files.add(await http.MultipartFile.fromPath('thumbnail', thumbnail.path));

    // Re-stream the multipart body so we can report upload progress.
    final total = multipart.contentLength;
    final body = multipart.finalize();
    final request = http.StreamedRequest('POST', multipart.url)
      ..headers.addAll(multipart.headers)
      ..headers['X-Device-Id'] = author.id
      ..contentLength = total;
    var sent = 0;
    body.listen(
      (chunk) {
        sent += chunk.length;
        if (total > 0) onProgress?.call((sent / total).clamp(0.0, 0.99));
        request.sink.add(chunk);
      },
      onError: request.sink.addError,
      onDone: request.sink.close,
      cancelOnError: true,
    );

    final res = await http.Response.fromStream(await _client.send(request));
    if (res.statusCode != 200 && res.statusCode != 201) _fail(res);
    onProgress?.call(1);
    return _parse(jsonDecode(res.body) as Map<String, dynamic>);
  }

  @override
  Future<void> deletePost(VideoPost post) async {
    final res = await _client.delete(
      _uri('/api/videos/${Uri.encodeComponent(post.id)}'),
      headers: {'X-Device-Id': await deviceId()},
    );
    if (res.statusCode != 200 && res.statusCode != 204) _fail(res);
  }

  @override
  Future<String> deviceId() => readOrCreateDeviceId();
}
