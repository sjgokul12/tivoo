import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:video_compress/video_compress.dart';

/// Prepares picked videos for posting.
class VideoProcessor {
  VideoProcessor._();

  /// Poster image for [path] (a JPEG in the cache), or null if it can't be read.
  static Future<File?> thumbnail(String path) async {
    try {
      return await VideoCompress.getFileThumbnail(path, quality: 80);
    } catch (e) {
      debugPrint('VideoProcessor.thumbnail: $e');
      return null;
    }
  }

  /// Duration of [path], or null if unknown.
  static Future<Duration?> duration(String path) async {
    try {
      final ms = (await VideoCompress.getMediaInfo(path)).duration;
      return ms == null ? null : Duration(milliseconds: ms.round());
    } catch (_) {
      return null;
    }
  }

  /// Re-encodes [path] to an H.264 / AAC MP4 (at most 1280×720, 30 fps), a format every
  /// phone plays, whatever the source was (HEVC, HDR, 4K, MOV, MKV…). Falls back to
  /// the original file if re-encoding fails. [onProgress] gets 0 – 1.
  static Future<File> makePlayable(String path, {void Function(double progress)? onProgress}) async {
    final sub = VideoCompress.compressProgress$.subscribe((p) => onProgress?.call((p / 100).clamp(0.0, 1.0)));
    try {
      final info = await VideoCompress.compressVideo(
        path,
        quality: VideoQuality.Res1280x720Quality,
        includeAudio: true,
        frameRate: 30,
      );
      final out = info?.path;
      if (info != null && info.isCancel != true && out != null && File(out).existsSync()) return File(out);
    } catch (e) {
      debugPrint('VideoProcessor.makePlayable: $e');
    } finally {
      sub.unsubscribe();
    }
    return File(path);
  }
}
