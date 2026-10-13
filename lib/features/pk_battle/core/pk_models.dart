// PK battle data: hosts, settings, gift events and demo data.

import '../../../core/constants/app_assets.dart';

/// One side of the PK battle.
class PkHost {
  final String name;
  final String handle;
  final String bio;
  final String avatarAsset;
  final String videoAsset;
  final String likes;
  final String viewers;
  final String teamMembers;
  final List<String> teamAvatars;

  const PkHost({
    required this.name,
    required this.avatarAsset,
    required this.videoAsset,
    required this.likes,
    required this.viewers,
    required this.teamMembers,
    required this.teamAvatars,
    this.handle = '',
    this.bio = '',
  });

  String get teamName => 'Team $name';

  PkHost copyWith({String? name, String? avatarAsset, String? videoAsset, String? likes, String? viewers}) {
    return PkHost(
      name: name ?? this.name,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      videoAsset: videoAsset ?? this.videoAsset,
      likes: likes ?? this.likes,
      viewers: viewers ?? this.viewers,
      teamMembers: teamMembers,
      teamAvatars: teamAvatars,
      handle: name != null ? '@${name.toLowerCase()}' : handle,
      bio: name != null ? '' : bio,
    );
  }
}

/// Latest gift shown as a pill at the bottom of a host's video.
class PkGiftEvent {
  final int id;
  final String sender;
  final String senderAvatar;
  final String giftName;
  final String emoji;
  final String? giftImage;
  final int count;

  const PkGiftEvent({
    required this.id,
    required this.sender,
    required this.senderAvatar,
    required this.giftName,
    required this.emoji,
    required this.count,
    this.giftImage,
  });

  static final RegExp _chatGift = RegExp(r'^sent (.+?) (\S+) x\s?(\d+)');

  /// Builds a pill from a chat message like "sent Rose 🌹 x 1" (null if it isn't a gift message).
  static PkGiftEvent? fromChatMessage({
    required int id,
    required String sender,
    required String avatar,
    required String message,
  }) {
    final match = _chatGift.firstMatch(message);
    if (match == null) return null;
    final giftName = match.group(1)!;
    return PkGiftEvent(
      id: id,
      sender: sender,
      senderAvatar: avatar,
      giftName: giftName,
      emoji: match.group(2)!,
      giftImage: PkDemoData.giftImages[giftName],
      count: int.parse(match.group(3)!),
    );
  }
}

/// User-configurable PK options (PK Settings sheet).
class PkSettings {
  final int durationSeconds;
  final bool countdownDisplay;
  final bool showTimerToAudience;
  final bool autoEnd;

  const PkSettings({
    this.durationSeconds = 300,
    this.countdownDisplay = true,
    this.showTimerToAudience = true,
    this.autoEnd = true,
  });
}

/// Demo data for the PK battle screen.
class PkDemoData {
  PkDemoData._();

  static const PkHost leftHost = PkHost(
    name: 'Neha',
    handle: '@neha_official',
    bio: '✨ Official PK Host | Singer & Creator ✨',
    avatarAsset: AppAssets.status4,
    videoAsset: AppAssets.video2,
    likes: '125.4K',
    viewers: '8.4K',
    teamMembers: '1.2K Members',
    teamAvatars: [AppAssets.status1, AppAssets.status3],
  );

  static const PkHost rightHost = PkHost(
    name: 'Arun',
    handle: '@arun_official',
    bio: '⚡ PK Warrior | Let the best team win! ⚡',
    avatarAsset: AppAssets.status5,
    videoAsset: AppAssets.video1,
    likes: '98.2K',
    viewers: '1.2K',
    teamMembers: '980 Members',
    teamAvatars: [AppAssets.status2, AppAssets.status4],
  );

  /// Viewers shown with a crown and highlighted message in the Command List.
  static const Set<String> vipNames = {'Sneha', 'Shena'};

  static const PkGiftEvent leftGift = PkGiftEvent(
    id: -1,
    sender: 'Riya',
    senderAvatar: AppAssets.status4,
    giftName: 'Rose',
    emoji: '🌹',
    giftImage: AppAssets.giftRose,
    count: 1,
  );

  static const PkGiftEvent rightGift = PkGiftEvent(
    id: -2,
    sender: 'Karthik',
    senderAvatar: AppAssets.avatarKarthik,
    giftName: 'Galaxy',
    emoji: '🔮',
    count: 5,
  );

  /// Sticker artwork for gifts mentioned in simulated chat messages.
  static const Map<String, String> giftImages = {
    'Rose': AppAssets.giftRose,
    'Golden Horse': AppAssets.giftGoldenHorse,
    'Ocean Whale': AppAssets.giftOceanWhale,
    'Angel Vehicle': AppAssets.giftAngelVehicle,
  };

  /// Rotating pool of simulated audience messages: (name, avatar, message, isGift).
  static const List<(String, String, String, bool)> incomingComments = [
    ('Priya', AppAssets.status3, 'Go Neha 💛', false),
    ('Karthik', AppAssets.status5, 'Super performance ❤️', false),
    ('Manoj', AppAssets.status2, 'sent Rose 🌹 x 1', true),
    ('Divya', AppAssets.status4, 'sent Heart 💖 x 1', true),
    ('Rahul', AppAssets.status5, 'sent Car 🏎️ x 1', true),
    ('Sneha', AppAssets.status3, 'sent Crown 👑 x 1', true),
    ('Kavya', AppAssets.status4, 'sent Golden Horse 🐎 x 1', true),
    ('Ananya', AppAssets.status3, 'sent Ocean Whale 🐋 x 1', true),
    ('Sanjay', AppAssets.status5, 'sent Angel Vehicle 🕊️ x 1', true),
    ('Vicky', AppAssets.status2, 'Both are amazing 👏', false),
    ('Diya', AppAssets.status4, 'Amazing PK 🔥', false),
  ];
}
