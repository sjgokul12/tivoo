import 'package:flutter/foundation.dart';

@immutable
class Streamer {
  const Streamer({
    required this.id,
    required this.name,
    required this.avatar,
    this.isVerified = true,
  });

  final String id;
  final String name;
  final String avatar;
  final bool isVerified;

  @override
  bool operator ==(Object other) => other is Streamer && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

@immutable
class LiveStream {
  const LiveStream({
    required this.id,
    required this.streamer,
    required this.title,
    required this.category,
    required this.thumbnail,
    required this.viewers,
    required this.videoAsset,
  });

  final String id;
  final Streamer streamer;

  /// Stream headline, e.g. "Good Vibes Only ✨".
  final String title;
  final String category;
  final String thumbnail;
  final int viewers;
  final String videoAsset;

  @override
  bool operator ==(Object other) => other is LiveStream && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
