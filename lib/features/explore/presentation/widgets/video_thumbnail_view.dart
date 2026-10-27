import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/video_processor.dart';
import '../../domain/models/video_post.dart';

/// Poster image for a [VideoPost]: the saved thumbnail (file or URL), or one generated
/// from the video once and cached. Never opens a video player, so grids stay light.
class VideoThumbnailView extends StatefulWidget {
  final VideoPost post;

  const VideoThumbnailView({super.key, required this.post});

  @override
  State<VideoThumbnailView> createState() => _VideoThumbnailViewState();
}

class _VideoThumbnailViewState extends State<VideoThumbnailView> {
  /// Generated posters for posts saved without one (video path → image file).
  static final Map<String, Future<File?>> _generated = {};

  late final Future<File?>? _poster = widget.post.thumbnailUrl == null
      ? _generated.putIfAbsent(widget.post.videoUrl, () => VideoProcessor.thumbnail(widget.post.videoUrl))
      : null;

  static const _placeholder = ColoredBox(
    color: Color(0xFF15122E),
    child: Center(child: Icon(Icons.movie_rounded, color: Colors.white24, size: 28)),
  );

  @override
  Widget build(BuildContext context) {
    final thumb = widget.post.thumbnailUrl;
    if (thumb != null) {
      return thumb.startsWith('http')
          ? CachedNetworkImage(
              imageUrl: thumb,
              fit: BoxFit.cover,
              placeholder: (_, _) => _placeholder,
              errorWidget: (_, _, _) => _placeholder,
            )
          : Image.file(File(thumb), fit: BoxFit.cover, cacheWidth: 400, errorBuilder: (_, _, _) => _placeholder);
    }
    return FutureBuilder<File?>(
      future: _poster,
      builder: (context, snap) => snap.data == null
          ? _placeholder
          : Image.file(snap.data!, fit: BoxFit.cover, cacheWidth: 400, errorBuilder: (_, _, _) => _placeholder),
    );
  }
}
