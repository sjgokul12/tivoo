import 'package:flutter/foundation.dart';

import 'chat_message.dart';
import 'live_stream.dart';

enum PkSide { left, right }

@immutable
class PkBattle {
  const PkBattle({
    required this.id,
    required this.left,
    required this.right,
    required this.duration,
    required this.remaining,
    required this.leftScore,
    required this.rightScore,
    required this.leftSupporters,
    required this.rightSupporters,
    required this.leftCover,
    required this.rightCover,
  });

  final String id;
  final LiveStream left;
  final LiveStream right;
  final Duration duration;

  /// Snapshot of a battle already in progress when the viewer joins.
  final Duration remaining;
  final int leftScore;
  final int rightScore;
  final List<String> leftSupporters;
  final List<String> rightSupporters;

  /// Stream frames shown in each battle panel.
  final String leftCover;
  final String rightCover;
}

/// Realtime event pushed by the PK server: a chat line and/or score points.
@immutable
class PkEvent {
  const PkEvent({required this.side, required this.message, this.points = 0});

  final PkSide side;
  final ChatMessage message;
  final int points;
}
