import 'dart:io';

import 'package:video_player/video_player.dart';

/// Builds the right [VideoPlayerController] for a video path:
/// - `http(s)://…`  → streamed from the server (uploaded posts from other users)
/// - `assets/…`     → bundled demo video
/// - anything else  → a file on this device (videos the user uploaded)
VideoPlayerController videoControllerFor(String path) {
  final options = VideoPlayerOptions(mixWithOthers: true);
  if (isNetworkVideo(path)) {
    return VideoPlayerController.networkUrl(Uri.parse(path), videoPlayerOptions: options);
  }
  if (path.startsWith('assets/')) {
    return VideoPlayerController.asset(path, videoPlayerOptions: options);
  }
  return VideoPlayerController.file(File(path), videoPlayerOptions: options);
}

bool isNetworkVideo(String path) => path.startsWith('http://') || path.startsWith('https://');
