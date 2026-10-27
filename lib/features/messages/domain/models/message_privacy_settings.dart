import 'package:flutter/foundation.dart';

/// Privacy modes for incoming Direct Messages (Instagram-style).
enum MessagePrivacyMode {
  /// Open DMs: Anyone in the app can message the user.
  everyone,

  /// Protected DMs: Only followers can message the user.
  followersOnly,
}

@immutable
class MessagePrivacySettings {
  final MessagePrivacyMode mode;

  const MessagePrivacySettings({
    this.mode = MessagePrivacyMode.everyone,
  });

  /// True when private messaging is open to everyone on the platform.
  bool get isEveryoneAllowed => mode == MessagePrivacyMode.everyone;

  /// True when restricted to followers only.
  bool get isFollowersOnly => mode == MessagePrivacyMode.followersOnly;

  /// Trendy, user-friendly badge label.
  String get badgeLabel => isEveryoneAllowed ? 'Open DMs' : 'Followers Only';

  /// Primary readable title.
  String get title => isEveryoneAllowed ? 'Everyone' : 'Followers Only';

  /// Trendy subtitle for settings UI.
  String get subtitle => isEveryoneAllowed
      ? 'Anyone on Tivoo can message you'
      : 'Only followers can send you direct messages';

  MessagePrivacySettings copyWith({
    MessagePrivacyMode? mode,
  }) {
    return MessagePrivacySettings(
      mode: mode ?? this.mode,
    );
  }
}
