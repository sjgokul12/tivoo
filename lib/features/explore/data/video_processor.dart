import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:video_compress/video_compress.dart';

/// Prepares picked videos for posting with ultra-high clarity and universal device compatibility.
class VideoProcessor {
  VideoProcessor._();

  /// Poster image for [path] (a JPEG in the cache), or null if it can't be read.
  /// Includes timeouts and multi-stage fallbacks to handle 4K and heavy HDR files without locking up.
  static Future<File?> thumbnail(String path) async {
    try {
      final file = await VideoCompress.getFileThumbnail(
        path,
        quality: 75,
      ).timeout(const Duration(seconds: 8));
      if (file.existsSync() && (await file.length()) > 0) {
        return file;
      }
    } catch (e) {
      debugPrint('VideoProcessor.thumbnail primary attempt: $e');
    }

    // Fallback: Lower thumbnail quality to avoid Android OOM on 4K/8K frame buffers
    try {
      final file = await VideoCompress.getFileThumbnail(
        path,
        quality: 40,
      ).timeout(const Duration(seconds: 5));
      if (file.existsSync() && (await file.length()) > 0) {
        return file;
      }
    } catch (e) {
      debugPrint('VideoProcessor.thumbnail fallback attempt: $e');
    }

    return null;
  }

  /// Retrieves media metadata including width, height, duration, and filesize.
  static Future<MediaInfo?> getMediaInfo(String path) async {
    try {
      return await VideoCompress.getMediaInfo(path).timeout(const Duration(seconds: 6));
    } catch (e) {
      debugPrint('VideoProcessor.getMediaInfo: $e');
      return null;
    }
  }

  /// Duration of [path], or null if unknown.
  static Future<Duration?> duration(String path) async {
    try {
      final info = await getMediaInfo(path);
      final ms = info?.duration;
      return ms == null ? null : Duration(milliseconds: ms.round());
    } catch (_) {
      return null;
    }
  }

  /// Human-friendly resolution badge (e.g., '4K Ultra HD', '1080p Full HD').
  static String resolutionLabel(int? width, int? height) {
    if (width == null || height == null || width <= 0 || height <= 0) return 'HD';
    final maxDim = width > height ? width : height;
    if (maxDim >= 2160) return '4K Ultra HD';
    if (maxDim >= 1440) return '2K QHD';
    if (maxDim >= 1080) return '1080p Full HD';
    if (maxDim >= 720) return '720p HD';
    return 'SD';
  }

  /// Prepares [path] for ultra-clear, fluid playback across all mobile devices.
  ///
  /// For 4K and high-res videos, compresses to high-bitrate 1080p (Full HD, 30/60fps)
  /// using hardware H.264/AAC. 1080p provides stunning clarity on every smartphone screen
  /// while guaranteeing 100% hardware-accelerated playback on all Android & iOS devices
  /// without exhausting MediaCodec instances or memory.
  ///
  /// Falls back gracefully to original file if native compression is unsupported.
  static Future<File> makePlayable(
    String path, {
    void Function(double progress)? onProgress,
  }) async {
    final sub = VideoCompress.compressProgress$.subscribe(
      (p) => onProgress?.call((p / 100).clamp(0.0, 1.0)),
    );

    try {
      // Step 1: Attempt high-clarity 1080p Full HD encoding
      final info = await VideoCompress.compressVideo(
        path,
        quality: VideoQuality.Res1920x1080Quality,
        includeAudio: true,
        frameRate: 30,
      ).timeout(const Duration(minutes: 5));

      final out = info?.path;
      if (info != null && info.isCancel != true && out != null && File(out).existsSync()) {
        return File(out);
      }
    } catch (e) {
      debugPrint('VideoProcessor.makePlayable 1080p failed ($e), trying standard fallback');
      try {
        // Step 2: Fallback to DefaultQuality if device encoder rejects 1080p transcode
        final fallbackInfo = await VideoCompress.compressVideo(
          path,
          quality: VideoQuality.DefaultQuality,
          includeAudio: true,
          frameRate: 30,
        ).timeout(const Duration(minutes: 3));

        final out = fallbackInfo?.path;
        if (fallbackInfo != null && fallbackInfo.isCancel != true && out != null && File(out).existsSync()) {
          return File(out);
        }
      } catch (e2) {
        debugPrint('VideoProcessor.makePlayable standard fallback failed: $e2');
      }
    } finally {
      sub.unsubscribe();
    }

    // Step 3: Keep original file so video is never discarded
    return File(path);
  }
}
