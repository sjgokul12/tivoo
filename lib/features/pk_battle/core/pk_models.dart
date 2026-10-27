// PK battle data: hosts, matches, settings, gift events and demo data.

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

  const PkHost({
    required this.name,
    required this.avatarAsset,
    required this.videoAsset,
    required this.likes,
    required this.viewers,
    this.handle = '',
    this.bio = '',
  });

  PkHost copyWith({String? name, String? avatarAsset, String? videoAsset, String? likes, String? viewers}) {
    return PkHost(
      name: name ?? this.name,
      avatarAsset: avatarAsset ?? this.avatarAsset,
      videoAsset: videoAsset ?? this.videoAsset,
      likes: likes ?? this.likes,
      viewers: viewers ?? this.viewers,
      handle: name != null ? '@${name.toLowerCase()}' : handle,
      bio: name != null ? '' : bio,
    );
  }
}

enum PkMatchStatus { ongoing, upcoming, ended }

/// A PK battle listed on the PK Home screen.
class PkMatch {
  final String id;
  final PkHost left;
  final PkHost right;
  final PkMatchStatus status;

  /// Everyone watching the battle (e.g. "12.4K").
  final String viewers;

  /// Split cover artwork for the list card (assets/pk/).
  final String cover;
  final int leftScore;
  final int rightScore;

  /// Seconds left in the battle when it is opened.
  final int secondsLeft;

  /// Start time label for upcoming battles (e.g. "8:30 PM").
  final String? startsAt;

  const PkMatch({
    required this.id,
    required this.left,
    required this.right,
    required this.status,
    required this.viewers,
    required this.cover,
    this.leftScore = 0,
    this.rightScore = 0,
    this.secondsLeft = 300,
    this.startsAt,
  });

  PkHost get winner => leftScore >= rightScore ? left : right;
}

/// A gift sent in the battle (gift pill on a live card, or parsed from a chat message).
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

  /// Builds a gift event from a chat message like "sent Rose 🌹 x 1" (null if it isn't a gift message).
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

/// Someone who sent gifts to a host in this battle, with their running total in stars.
class PkGifter {
  final String name;
  final String avatar;
  final int total;

  const PkGifter({required this.name, required this.avatar, required this.total});

  PkGifter add(int stars) => PkGifter(name: name, avatar: avatar, total: total + stars);
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

/// Demo data for the PK screens.
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
  );

  static const PkHost rightHost = PkHost(
    name: 'Arun',
    handle: '@arun_official',
    bio: '⚡ PK Warrior | Let the best team win! ⚡',
    avatarAsset: AppAssets.status5,
    videoAsset: AppAssets.video1,
    likes: '98.2K',
    viewers: '1.2K',
  );

  /// The battle opened when no match is chosen (e.g. from a home grid card).
  static const PkMatch featured = PkMatch(
    id: 'pk_neha_arun',
    left: leftHost,
    right: rightHost,
    status: PkMatchStatus.ongoing,
    viewers: '2.4K',
    cover: AppAssets.pkCoverNehaArun,
    leftScore: 12340,
    rightScore: 10980,
    secondsLeft: 135,
  );

  static PkHost _host(String name, String avatar, String video, String likes, String viewers) => PkHost(
    name: name,
    handle: '@${name.toLowerCase()}',
    avatarAsset: avatar,
    videoAsset: video,
    likes: likes,
    viewers: viewers,
  );

  /// Battles listed on the PK Home screen (all play the original PK streams).
  static final List<PkMatch> matches = [
    PkMatch(
      id: 'pk_priya_anu',
      left: _host('Priya', AppAssets.avatarPriya, AppAssets.video2, '88.1K', '6.2K'),
      right: _host('Anu', AppAssets.avatarMeena, AppAssets.video1, '74.5K', '6.2K'),
      status: PkMatchStatus.ongoing,
      viewers: '12.4K',
      cover: AppAssets.pkCoverPriyaAnu,
      leftScore: 19020,
      rightScore: 16640,
      secondsLeft: 212,
    ),
    PkMatch(
      id: 'pk_sweety_nila',
      left: _host('Sweety', AppAssets.homeCard1, AppAssets.video2, '61.0K', '4.8K'),
      right: _host('Nila', AppAssets.avatarSneha, AppAssets.video1, '57.3K', '4.8K'),
      status: PkMatchStatus.ongoing,
      viewers: '9.6K',
      cover: AppAssets.pkCoverSweetyNila,
      leftScore: 9870,
      rightScore: 11340,
      secondsLeft: 168,
    ),
    PkMatch(
      id: 'pk_angel_divya',
      left: _host('Angel', AppAssets.status3, AppAssets.video2, '44.9K', '2.6K'),
      right: _host('Divya', AppAssets.avatarDiya, AppAssets.video1, '39.2K', '2.6K'),
      status: PkMatchStatus.ongoing,
      viewers: '5.2K',
      cover: AppAssets.pkCoverAngelDivya,
      leftScore: 7420,
      rightScore: 6980,
      secondsLeft: 95,
    ),
    featured,
    PkMatch(
      id: 'pk_meena_sneha',
      left: _host('Meena', AppAssets.avatarMeena, AppAssets.video2, '52.7K', '0'),
      right: _host('Sneha', AppAssets.avatarSneha, AppAssets.video1, '49.8K', '0'),
      status: PkMatchStatus.upcoming,
      viewers: '1.1K',
      cover: AppAssets.pkCoverMeenaSneha,
      startsAt: '8:30 PM',
    ),
    PkMatch(
      id: 'pk_diya_priya',
      left: _host('Diya', AppAssets.avatarDiya, AppAssets.video2, '70.3K', '0'),
      right: _host('Priya', AppAssets.avatarPriya, AppAssets.video1, '88.1K', '0'),
      status: PkMatchStatus.ended,
      viewers: '15.8K',
      cover: AppAssets.pkCoverDiyaPriya,
      leftScore: 24110,
      rightScore: 19870,
    ),
  ];

  /// Latest gift shown at the bottom of each live card when a battle opens.
  static const PkGiftEvent leftGift = PkGiftEvent(
    id: -1,
    sender: 'Ana..',
    senderAvatar: AppAssets.avatarDiya,
    giftName: 'Ocean Tornado',
    emoji: '🌪️',
    count: 7,
  );

  static const PkGiftEvent rightGift = PkGiftEvent(
    id: -2,
    sender: 'Rahul',
    senderAvatar: AppAssets.avatarArun,
    giftName: 'Golden Lion',
    emoji: '🦁',
    giftImage: AppAssets.giftGoldenLion,
    count: 7,
  );

  /// Gifters already supporting each host when a battle opens.
  static const List<PkGifter> leftGifters = [
    PkGifter(name: 'Manoj', avatar: AppAssets.status1, total: 521),
    PkGifter(name: 'Diya', avatar: AppAssets.avatarDiya, total: 340),
    PkGifter(name: 'Meena', avatar: AppAssets.avatarMeena, total: 180),
    PkGifter(name: 'Sneha', avatar: AppAssets.avatarSneha, total: 90),
  ];

  static const List<PkGifter> rightGifters = [
    PkGifter(name: 'Rahul', avatar: AppAssets.avatarArun, total: 500),
    PkGifter(name: 'Karthik', avatar: AppAssets.avatarKarthik, total: 450),
    PkGifter(name: 'Saran', avatar: AppAssets.avatarSaran, total: 280),
    PkGifter(name: 'Vicky', avatar: AppAssets.avatarVicky, total: 120),
  ];

  /// Star value of gifts mentioned in chat messages (per gift); unknown gifts count as 10.
  static const Map<String, int> giftValues = {
    'Rose': 1,
    'Heart': 5,
    'Car': 200,
    'Crown': 100,
    'Golden Horse': 500,
    'Ocean Whale': 300,
    'Ocean Tornado': 300,
    'Golden Lion': 500,
    'Angel Vehicle': 800,
  };

  /// Viewers shown with a crown in the comments.
  static const Set<String> vipNames = {'Sneha', 'Rahul', 'Ana..'};

  /// Sticker artwork for gifts mentioned in simulated chat messages.
  static const Map<String, String> giftImages = {
    'Rose': AppAssets.giftRose,
    'Golden Horse': AppAssets.giftGoldenHorse,
    'Ocean Whale': AppAssets.giftOceanWhale,
    'Angel Vehicle': AppAssets.giftAngelVehicle,
  };

  /// Rotating pool of simulated audience messages: (name, avatar, message, isGift).
  static const List<(String, String, String, bool)> incomingComments = [
    ('Meena', AppAssets.avatarMeena, 'What a battle 😍', false),
    ('Karthik', AppAssets.avatarKarthik, 'Super performance ❤️', false),
    ('Manoj', AppAssets.avatarSaran, 'sent Rose 🌹 x 1', true),
    ('Priya', AppAssets.avatarPriya, 'Go go go 💛', false),
    ('Rahul', AppAssets.avatarArun, 'sent Golden Horse 🐎 x 1', true),
    ('Sneha', AppAssets.avatarSneha, 'Love this PK 🔥', false),
    ('Vicky', AppAssets.avatarVicky, 'Both are amazing 👏', false),
    ('Ananya', AppAssets.avatarDiya, 'sent Ocean Whale 🐋 x 1', true),
  ];
}
