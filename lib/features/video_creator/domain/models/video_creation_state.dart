import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import '../../../broadcast/domain/models/camera_filter_model.dart';

/// Holds the active state of a video creation and editing session.
class VideoCreationState {
  final File videoFile;
  final String? videoPath;
  final Uint8List? videoBytes;
  File? coverThumbnail;
  Uint8List? coverBytes;
  String? coverPath;

  String get effectivePath => (videoPath != null && videoPath!.isNotEmpty) ? videoPath! : videoFile.path;
  Duration duration;
  Duration trimStart;
  Duration trimEnd;
  double playbackSpeed;
  double originalVolume;
  double musicVolume;
  String? selectedMusicTitle;
  String? selectedMusicArtist;
  String? textOverlay;
  Color textOverlayColor;
  String? stickerEmoji;
  String filterName;
  ColorFilter? colorFilter;
  double brightness;
  double contrast;
  double saturation;
  String? activeEffectName;
  CameraFilterModel? activeSnapLens;

  // Post metadata
  String caption;
  List<String> hashtags;
  String audience;
  bool allowComments;
  bool allowDownload;
  bool allowShare;
  String? location;
  String category;
  List<String> taggedPeople;

  VideoCreationState({
    required this.videoFile,
    this.videoPath,
    this.videoBytes,
    this.coverThumbnail,
    this.coverBytes,
    this.coverPath,
    this.duration = const Duration(seconds: 15),
    this.trimStart = Duration.zero,
    Duration? trimEnd,
    this.playbackSpeed = 1.0,
    this.originalVolume = 1.0,
    this.musicVolume = 0.7,
    this.selectedMusicTitle,
    this.selectedMusicArtist,
    this.textOverlay,
    this.textOverlayColor = const Color(0xFFFFD700),
    this.stickerEmoji,
    this.filterName = 'Natural',
    this.colorFilter,
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.saturation = 1.0,
    this.activeEffectName,
    this.activeSnapLens,
    this.caption = '',
    List<String>? hashtags,
    this.audience = 'Public',
    this.allowComments = true,
    this.allowDownload = true,
    this.allowShare = true,
    this.location,
    this.category = 'Dance',
    List<String>? taggedPeople,
  })  : trimEnd = trimEnd ?? duration,
        hashtags = hashtags ?? ['#Tivoo', '#Reels'],
        taggedPeople = taggedPeople ?? [];

  Duration get effectiveDuration {
    final diff = trimEnd - trimStart;
    return diff.isNegative ? Duration.zero : diff;
  }
}
