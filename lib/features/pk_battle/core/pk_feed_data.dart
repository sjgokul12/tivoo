// Mock PK battle feed data for vertical swipe scrolling.

import '../../../core/constants/app_assets.dart';
import '../../live_stream/domain/models/live_comment.dart';
import 'pk_models.dart';

/// One PK battle item in the vertical swipe feed.
class PkBattleFeedItem {
  final PkMatch match;
  final PkGiftEvent leftGift;
  final PkGiftEvent rightGift;
  final List<PkGifter> leftGifters;
  final List<PkGifter> rightGifters;
  final List<LiveComment> initialComments;
  final List<(String, String, String, bool)> commentPool;

  const PkBattleFeedItem({
    required this.match,
    required this.leftGift,
    required this.rightGift,
    required this.leftGifters,
    required this.rightGifters,
    required this.initialComments,
    required this.commentPool,
  });

  /// Factory helper to build a feed item from a generic [PkMatch].
  factory PkBattleFeedItem.fromMatch(PkMatch match) {
    return PkBattleFeedItem(
      match: match,
      leftGift: PkDemoData.leftGift,
      rightGift: PkDemoData.rightGift,
      leftGifters: PkDemoData.leftGifters,
      rightGifters: PkDemoData.rightGifters,
      initialComments: _buildComments(match.left.name, match.right.name),
      commentPool: _buildPool(match.left.name, match.right.name),
    );
  }

  static List<LiveComment> _buildComments(String left, String right) {
    final now = DateTime.now();
    return [
      LiveComment(
        id: 'c_init_1',
        userName: 'Meena',
        userAssetPath: AppAssets.avatarMeena,
        message: '$left is amazing today 😍',
        type: LiveCommentType.chat,
        timestamp: now.subtract(const Duration(minutes: 3)),
      ),
      LiveComment(
        id: 'c_init_2',
        userName: 'Ananya',
        userAssetPath: AppAssets.avatarDiya,
        message: 'sent Ocean Tornado 🌪️ x 1',
        type: LiveCommentType.gift,
        timestamp: now.subtract(const Duration(minutes: 2)),
      ),
      LiveComment(
        id: 'c_init_3',
        userName: 'Vicky',
        userAssetPath: AppAssets.avatarVicky,
        message: 'Go $right squad! 🔥',
        type: LiveCommentType.chat,
        timestamp: now.subtract(const Duration(minutes: 1)),
      ),
    ];
  }

  static List<(String, String, String, bool)> _buildPool(String left, String right) => [
    ('Karthik', AppAssets.avatarKarthik, '$left team let\'s go! 💖', false),
    ('Rahul', AppAssets.avatarArun, 'sent Golden Horse 🐎 x 1', true),
    ('Sneha', AppAssets.avatarSneha, 'Double tap for $right! ⚡', false),
    ('Manoj', AppAssets.avatarSaran, 'sent Rose 🌹 x 3', true),
    ('Priya', AppAssets.avatarPriya, 'Super performance by both! 👏', false),
    ('Vicky', AppAssets.avatarVicky, 'sent Ocean Whale 🐋 x 1', true),
  ];
}

/// Demo vertical feed battles with distinct streamers, videos, avatars, scores and comments.
class PkFeedData {
  PkFeedData._();

  static PkHost _host({
    required String name,
    required String avatar,
    required String video,
    required String viewers,
    required String likes,
    String bio = '',
  }) => PkHost(
    name: name,
    handle: '@${name.toLowerCase()}',
    bio: bio.isNotEmpty ? bio : '✨ Live Stream Host | PK Champion ✨',
    avatarAsset: avatar,
    videoAsset: video,
    likes: likes,
    viewers: viewers,
  );

  static final List<PkBattleFeedItem> feedBattles = [
    // 1. Neha vs Arun
    PkBattleFeedItem(
      match: PkMatch(
        id: 'pk_neha_arun',
        left: _host(
          name: 'Neha',
          avatar: AppAssets.avatarNeha,
          video: AppAssets.video2,
          viewers: '8.4K',
          likes: '125.4K',
          bio: '✨ Singer & PK Warrior ✨',
        ),
        right: _host(
          name: 'Arun',
          avatar: AppAssets.avatarArun,
          video: AppAssets.video1,
          viewers: '1.2K',
          likes: '98.2K',
          bio: '⚡ Let the best team win! ⚡',
        ),
        status: PkMatchStatus.ongoing,
        viewers: '9.6K',
        cover: AppAssets.pkCoverNehaArun,
        leftScore: 12340,
        rightScore: 10980,
        secondsLeft: 135,
      ),
      leftGift: const PkGiftEvent(
        id: 101,
        sender: 'Diya',
        senderAvatar: AppAssets.avatarDiya,
        giftName: 'Ocean Tornado',
        emoji: '🌪️',
        count: 7,
      ),
      rightGift: const PkGiftEvent(
        id: 102,
        sender: 'Rahul',
        senderAvatar: AppAssets.avatarArun,
        giftName: 'Golden Lion',
        emoji: '🦁',
        giftImage: AppAssets.giftGoldenLion,
        count: 5,
      ),
      leftGifters: const [
        PkGifter(name: 'Manoj', avatar: AppAssets.status1, total: 521),
        PkGifter(name: 'Diya', avatar: AppAssets.avatarDiya, total: 340),
        PkGifter(name: 'Meena', avatar: AppAssets.avatarMeena, total: 180),
        PkGifter(name: 'Sneha', avatar: AppAssets.avatarSneha, total: 90),
      ],
      rightGifters: const [
        PkGifter(name: 'Rahul', avatar: AppAssets.avatarArun, total: 500),
        PkGifter(name: 'Karthik', avatar: AppAssets.avatarKarthik, total: 450),
        PkGifter(name: 'Saran', avatar: AppAssets.avatarSaran, total: 280),
        PkGifter(name: 'Vicky', avatar: AppAssets.avatarVicky, total: 120),
      ],
      initialComments: [
        LiveComment(
          id: 'b1_1',
          userName: 'Meena',
          userAssetPath: AppAssets.avatarMeena,
          message: 'Neha voice is pure magic 😍',
          type: LiveCommentType.chat,
          timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
        ),
        LiveComment(
          id: 'b1_2',
          userName: 'Ananya',
          userAssetPath: AppAssets.avatarDiya,
          message: 'sent Ocean Tornado 🌪️ x 1',
          type: LiveCommentType.gift,
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
        LiveComment(
          id: 'b1_3',
          userName: 'Vicky',
          userAssetPath: AppAssets.avatarVicky,
          message: 'Arun bro kill it 🔥',
          type: LiveCommentType.chat,
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
        LiveComment(
          id: 'b1_4',
          userName: 'Sneha',
          userAssetPath: AppAssets.avatarSneha,
          message: 'Both teams are on fire! 👏',
          type: LiveCommentType.chat,
          timestamp: DateTime.now(),
        ),
      ],
      commentPool: const [
        ('Meena', AppAssets.avatarMeena, 'Team Neha let\'s go! 💖', false),
        ('Karthik', AppAssets.avatarKarthik, 'Arun comeback time! 🔥', false),
        ('Manoj', AppAssets.avatarSaran, 'sent Rose 🌹 x 5', true),
        ('Priya', AppAssets.avatarPriya, 'Tapping like crazy ❤️', false),
        ('Rahul', AppAssets.avatarArun, 'sent Golden Horse 🐎 x 1', true),
        ('Sneha', AppAssets.avatarSneha, 'Love this battle energy ⚡', false),
        ('Vicky', AppAssets.avatarVicky, 'Double tap for Arun squad 👏', false),
        ('Ananya', AppAssets.avatarDiya, 'sent Ocean Whale 🐋 x 1', true),
      ],
    ),

    // 2. Priya vs Anu
    PkBattleFeedItem(
      match: PkMatch(
        id: 'pk_priya_anu',
        left: _host(
          name: 'Priya',
          avatar: AppAssets.avatarPriya,
          video: AppAssets.video3,
          viewers: '6.2K',
          likes: '88.1K',
          bio: '✨ Fashion & Dance Creator ✨',
        ),
        right: _host(
          name: 'Anu',
          avatar: AppAssets.avatarMeena,
          video: AppAssets.video4,
          viewers: '6.2K',
          likes: '74.5K',
          bio: '💃 Dance Queen & Host 💃',
        ),
        status: PkMatchStatus.ongoing,
        viewers: '12.4K',
        cover: AppAssets.pkCoverPriyaAnu,
        leftScore: 19020,
        rightScore: 16640,
        secondsLeft: 212,
      ),
      leftGift: const PkGiftEvent(
        id: 201,
        sender: 'Vikram',
        senderAvatar: AppAssets.avatarKarthik,
        giftName: 'Golden Horse',
        emoji: '🐎',
        giftImage: AppAssets.giftGoldenHorse,
        count: 3,
      ),
      rightGift: const PkGiftEvent(
        id: 202,
        sender: 'Ananya',
        senderAvatar: AppAssets.avatarDiya,
        giftName: 'Rose',
        emoji: '🌹',
        giftImage: AppAssets.giftRose,
        count: 10,
      ),
      leftGifters: const [
        PkGifter(name: 'Vikram', avatar: AppAssets.avatarKarthik, total: 610),
        PkGifter(name: 'Pooja', avatar: AppAssets.status1, total: 420),
        PkGifter(name: 'Sanjay', avatar: AppAssets.avatarSaran, total: 290),
        PkGifter(name: 'Kavita', avatar: AppAssets.status4, total: 110),
      ],
      rightGifters: const [
        PkGifter(name: 'Ananya', avatar: AppAssets.avatarDiya, total: 580),
        PkGifter(name: 'Rohit', avatar: AppAssets.avatarArun, total: 390),
        PkGifter(name: 'Deepa', avatar: AppAssets.avatarSneha, total: 240),
        PkGifter(name: 'Aakash', avatar: AppAssets.avatarVicky, total: 105),
      ],
      initialComments: [
        LiveComment(
          id: 'b2_1',
          userName: 'Vikram',
          userAssetPath: AppAssets.avatarKarthik,
          message: 'Priya looks stunning today ✨',
          type: LiveCommentType.chat,
          timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
        ),
        LiveComment(
          id: 'b2_2',
          userName: 'Pooja',
          userAssetPath: AppAssets.status1,
          message: 'sent Rose 🌹 x 10',
          type: LiveCommentType.gift,
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
        LiveComment(
          id: 'b2_3',
          userName: 'Rohit',
          userAssetPath: AppAssets.avatarArun,
          message: 'Anu\'s dance is so graceful 💃',
          type: LiveCommentType.chat,
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
        LiveComment(
          id: 'b2_4',
          userName: 'Deepa',
          userAssetPath: AppAssets.avatarSneha,
          message: 'Team Anu all the way! 💖',
          type: LiveCommentType.chat,
          timestamp: DateTime.now(),
        ),
      ],
      commentPool: const [
        ('Vikram', AppAssets.avatarKarthik, 'Priya queen of PK! 👑', false),
        ('Pooja', AppAssets.status1, 'sent Golden Lion 🦁 x 1', true),
        ('Rohit', AppAssets.avatarArun, 'Anu we are with you ⚡', false),
        ('Sanjay', AppAssets.avatarSaran, 'Priya score is soaring 🚀', false),
        ('Ananya', AppAssets.avatarDiya, 'sent Rose 🌹 x 3', true),
        ('Deepa', AppAssets.avatarSneha, 'Double tap the screen guys! ❤️', false),
        ('Aakash', AppAssets.avatarVicky, 'Keep the streak alive Anu! 🔥', false),
        ('Kavita', AppAssets.status4, 'sent Ocean Tornado 🌪️ x 1', true),
      ],
    ),

    // 3. Sweety vs Nila
    PkBattleFeedItem(
      match: PkMatch(
        id: 'pk_sweety_nila',
        left: _host(
          name: 'Sweety',
          avatar: AppAssets.homeCard1,
          video: AppAssets.video5,
          viewers: '4.8K',
          likes: '61.0K',
          bio: '🌸 Smiles & Good Vibes 🌸',
        ),
        right: _host(
          name: 'Nila',
          avatar: AppAssets.avatarSneha,
          video: AppAssets.video6,
          viewers: '4.8K',
          likes: '57.3K',
          bio: '🌙 Moonchild & Gamer 🌙',
        ),
        status: PkMatchStatus.ongoing,
        viewers: '9.6K',
        cover: AppAssets.pkCoverSweetyNila,
        leftScore: 9870,
        rightScore: 11340,
        secondsLeft: 168,
      ),
      leftGift: const PkGiftEvent(
        id: 301,
        sender: 'Keerthi',
        senderAvatar: AppAssets.avatarMeena,
        giftName: 'Rose',
        emoji: '🌹',
        giftImage: AppAssets.giftRose,
        count: 5,
      ),
      rightGift: const PkGiftEvent(
        id: 302,
        sender: 'Suresh',
        senderAvatar: AppAssets.avatarArun,
        giftName: 'Ocean Whale',
        emoji: '🐋',
        giftImage: AppAssets.giftOceanWhale,
        count: 1,
      ),
      leftGifters: const [
        PkGifter(name: 'Aravind', avatar: AppAssets.avatarKarthik, total: 490),
        PkGifter(name: 'Keerthi', avatar: AppAssets.avatarMeena, total: 310),
        PkGifter(name: 'Rajesh', avatar: AppAssets.avatarSaran, total: 180),
        PkGifter(name: 'Swathi', avatar: AppAssets.avatarNeha, total: 85),
      ],
      rightGifters: const [
        PkGifter(name: 'Suresh', avatar: AppAssets.avatarArun, total: 520),
        PkGifter(name: 'Swetha', avatar: AppAssets.avatarDiya, total: 410),
        PkGifter(name: 'Manoj', avatar: AppAssets.status2, total: 260),
        PkGifter(name: 'Harish', avatar: AppAssets.avatarVicky, total: 95),
      ],
      initialComments: [
        LiveComment(
          id: 'b3_1',
          userName: 'Aravind',
          userAssetPath: AppAssets.avatarKarthik,
          message: 'Sweety don\'t give up! 💖',
          type: LiveCommentType.chat,
          timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
        ),
        LiveComment(
          id: 'b3_2',
          userName: 'Suresh',
          userAssetPath: AppAssets.avatarArun,
          message: 'sent Ocean Whale 🐋 x 1',
          type: LiveCommentType.gift,
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
        LiveComment(
          id: 'b3_3',
          userName: 'Keerthi',
          userAssetPath: AppAssets.avatarMeena,
          message: 'Nila is leading by a bit! ⚡',
          type: LiveCommentType.chat,
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
        LiveComment(
          id: 'b3_4',
          userName: 'Swetha',
          userAssetPath: AppAssets.avatarDiya,
          message: 'Nila squad make some noise 🔥',
          type: LiveCommentType.chat,
          timestamp: DateTime.now(),
        ),
      ],
      commentPool: const [
        ('Aravind', AppAssets.avatarKarthik, 'Sweety comeback time! 🌟', false),
        ('Suresh', AppAssets.avatarArun, 'Nila army stay strong 🛡️', false),
        ('Keerthi', AppAssets.avatarMeena, 'sent Rose 🌹 x 2', true),
        ('Swetha', AppAssets.avatarDiya, 'Double tap for Nila ❤️', false),
        ('Rajesh', AppAssets.avatarSaran, 'sent Golden Horse 🐎 x 1', true),
        ('Manoj', AppAssets.status2, 'Sweety song was awesome 🎶', false),
        ('Swathi', AppAssets.avatarNeha, 'Come on guys boost the score 🚀', false),
        ('Harish', AppAssets.avatarVicky, 'sent Golden Lion 🦁 x 1', true),
      ],
    ),

    // 4. Karthik vs Vicky
    PkBattleFeedItem(
      match: PkMatch(
        id: 'pk_karthik_vicky',
        left: _host(
          name: 'Karthik',
          avatar: AppAssets.avatarKarthik,
          video: AppAssets.video1,
          viewers: '7.8K',
          likes: '142.0K',
          bio: '🔥 Energy & Comedy Host 🔥',
        ),
        right: _host(
          name: 'Vicky',
          avatar: AppAssets.avatarVicky,
          video: AppAssets.video2,
          viewers: '6.5K',
          likes: '118.5K',
          bio: '⚡ Gaming & Vlogs ⚡',
        ),
        status: PkMatchStatus.ongoing,
        viewers: '14.3K',
        cover: AppAssets.pkCoverNehaArun,
        leftScore: 24500,
        rightScore: 22890,
        secondsLeft: 195,
      ),
      leftGift: const PkGiftEvent(
        id: 401,
        sender: 'Saran',
        senderAvatar: AppAssets.avatarSaran,
        giftName: 'Golden Horse',
        emoji: '🐎',
        giftImage: AppAssets.giftGoldenHorse,
        count: 2,
      ),
      rightGift: const PkGiftEvent(
        id: 402,
        sender: 'Mohan',
        senderAvatar: AppAssets.status5,
        giftName: 'Angel Vehicle',
        emoji: '🚗',
        giftImage: AppAssets.giftAngelVehicle,
        count: 1,
      ),
      leftGifters: const [
        PkGifter(name: 'Arun', avatar: AppAssets.avatarArun, total: 720),
        PkGifter(name: 'Saran', avatar: AppAssets.avatarSaran, total: 510),
        PkGifter(name: 'Ajay', avatar: AppAssets.avatarDiya, total: 380),
        PkGifter(name: 'Preeti', avatar: AppAssets.avatarSneha, total: 150),
      ],
      rightGifters: const [
        PkGifter(name: 'Mohan', avatar: AppAssets.status5, total: 680),
        PkGifter(name: 'Dinesh', avatar: AppAssets.status3, total: 490),
        PkGifter(name: 'Sandeep', avatar: AppAssets.avatarPriya, total: 320),
        PkGifter(name: 'Varun', avatar: AppAssets.avatarMeena, total: 140),
      ],
      initialComments: [
        LiveComment(
          id: 'b4_1',
          userName: 'Arun',
          userAssetPath: AppAssets.avatarArun,
          message: 'Karthik bro is on fire today! 🔥',
          type: LiveCommentType.chat,
          timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
        ),
        LiveComment(
          id: 'b4_2',
          userName: 'Mohan',
          userAssetPath: AppAssets.status5,
          message: 'sent Angel Vehicle 🚗 x 1',
          type: LiveCommentType.gift,
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
        LiveComment(
          id: 'b4_3',
          userName: 'Saran',
          userAssetPath: AppAssets.avatarSaran,
          message: 'Vicky snipe in the last round 🎯',
          type: LiveCommentType.chat,
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
        LiveComment(
          id: 'b4_4',
          userName: 'Dinesh',
          userAssetPath: AppAssets.status3,
          message: 'Vicky squad don\'t stop tapping ⚡',
          type: LiveCommentType.chat,
          timestamp: DateTime.now(),
        ),
      ],
      commentPool: const [
        ('Arun', AppAssets.avatarArun, 'King Karthik ruling the arena 👑', false),
        ('Mohan', AppAssets.status5, 'Vicky big gifts incoming 🎁', false),
        ('Saran', AppAssets.avatarSaran, 'sent Golden Horse 🐎 x 2', true),
        ('Dinesh', AppAssets.status3, 'Boys battle is too intense ⚔️', false),
        ('Ajay', AppAssets.avatarDiya, 'Keep the gifts flowing 🌟', false),
        ('Sandeep', AppAssets.avatarPriya, 'sent Ocean Tornado 🌪️ x 1', true),
        ('Preeti', AppAssets.avatarSneha, 'Double tap 50k likes target! ❤️', false),
        ('Varun', AppAssets.avatarMeena, 'Vicky clutch win possible! 💥', false),
      ],
    ),

    // 5. Diya vs Meena
    PkBattleFeedItem(
      match: PkMatch(
        id: 'pk_diya_meena',
        left: _host(
          name: 'Diya',
          avatar: AppAssets.avatarDiya,
          video: AppAssets.video4,
          viewers: '5.6K',
          likes: '70.3K',
          bio: '🌟 Melodies & Acoustic Vibes 🌟',
        ),
        right: _host(
          name: 'Meena',
          avatar: AppAssets.avatarMeena,
          video: AppAssets.video3,
          viewers: '4.9K',
          likes: '52.7K',
          bio: '💖 Style Icon & Dancer 💖',
        ),
        status: PkMatchStatus.ongoing,
        viewers: '10.5K',
        cover: AppAssets.pkCoverDiyaPriya,
        leftScore: 15100,
        rightScore: 14800,
        secondsLeft: 140,
      ),
      leftGift: const PkGiftEvent(
        id: 501,
        sender: 'Sandhya',
        senderAvatar: AppAssets.avatarPriya,
        giftName: 'Ocean Whale',
        emoji: '🐋',
        giftImage: AppAssets.giftOceanWhale,
        count: 1,
      ),
      rightGift: const PkGiftEvent(
        id: 502,
        sender: 'Gowtham',
        senderAvatar: AppAssets.avatarKarthik,
        giftName: 'Golden Lion',
        emoji: '🦁',
        giftImage: AppAssets.giftGoldenLion,
        count: 1,
      ),
      leftGifters: const [
        PkGifter(name: 'Surya', avatar: AppAssets.avatarArun, total: 450),
        PkGifter(name: 'Rithika', avatar: AppAssets.avatarSneha, total: 340),
        PkGifter(name: 'Sandhya', avatar: AppAssets.avatarPriya, total: 210),
        PkGifter(name: 'Naveen', avatar: AppAssets.status1, total: 90),
      ],
      rightGifters: const [
        PkGifter(name: 'Gowtham', avatar: AppAssets.avatarKarthik, total: 480),
        PkGifter(name: 'Kishore', avatar: AppAssets.avatarSaran, total: 360),
        PkGifter(name: 'Bala', avatar: AppAssets.avatarVicky, total: 220),
        PkGifter(name: 'Shreya', avatar: AppAssets.avatarNeha, total: 80),
      ],
      initialComments: [
        LiveComment(
          id: 'b5_1',
          userName: 'Surya',
          userAssetPath: AppAssets.avatarArun,
          message: 'Diya sweet smile brightens the room 🌸',
          type: LiveCommentType.chat,
          timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
        ),
        LiveComment(
          id: 'b5_2',
          userName: 'Gowtham',
          userAssetPath: AppAssets.avatarKarthik,
          message: 'sent Rose 🌹 x 5',
          type: LiveCommentType.gift,
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
        LiveComment(
          id: 'b5_3',
          userName: 'Rithika',
          userAssetPath: AppAssets.avatarSneha,
          message: 'Meena looks fabulous in pink 💕',
          type: LiveCommentType.chat,
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
        LiveComment(
          id: 'b5_4',
          userName: 'Kishore',
          userAssetPath: AppAssets.avatarSaran,
          message: 'Such a close battle between friends! ✨',
          type: LiveCommentType.chat,
          timestamp: DateTime.now(),
        ),
      ],
      commentPool: const [
        ('Surya', AppAssets.avatarArun, 'Queen Diya let\'s take the lead 👑', false),
        ('Gowtham', AppAssets.avatarKarthik, 'sent Golden Lion 🦁 x 1', true),
        ('Rithika', AppAssets.avatarSneha, 'Double tap screen guys ❤️', false),
        ('Kishore', AppAssets.avatarSaran, 'Meena sing one more song 🎶', false),
        ('Sandhya', AppAssets.avatarPriya, 'sent Ocean Whale 🐋 x 1', true),
        ('Bala', AppAssets.avatarVicky, 'Both hosts are sweethearts 💖', false),
        ('Naveen', AppAssets.status1, 'Diya team send rockets 🚀', false),
        ('Shreya', AppAssets.avatarNeha, 'sent Rose 🌹 x 10', true),
      ],
    ),

    // 6. Angel vs Divya
    PkBattleFeedItem(
      match: PkMatch(
        id: 'pk_angel_divya',
        left: _host(
          name: 'Angel',
          avatar: AppAssets.status3,
          video: AppAssets.video6,
          viewers: '3.9K',
          likes: '44.9K',
          bio: '🕊️ Serene Melodies & Stories 🕊️',
        ),
        right: _host(
          name: 'Divya',
          avatar: AppAssets.status2,
          video: AppAssets.video5,
          viewers: '3.6K',
          likes: '39.2K',
          bio: '✨ Creative Host & Artist ✨',
        ),
        status: PkMatchStatus.ongoing,
        viewers: '7.5K',
        cover: AppAssets.pkCoverAngelDivya,
        leftScore: 7420,
        rightScore: 6980,
        secondsLeft: 95,
      ),
      leftGift: const PkGiftEvent(
        id: 601,
        sender: 'Nisha',
        senderAvatar: AppAssets.avatarSneha,
        giftName: 'Golden Horse',
        emoji: '🐎',
        giftImage: AppAssets.giftGoldenHorse,
        count: 1,
      ),
      rightGift: const PkGiftEvent(
        id: 602,
        sender: 'Bala',
        senderAvatar: AppAssets.avatarSaran,
        giftName: 'Ocean Tornado',
        emoji: '🌪️',
        count: 2,
      ),
      leftGifters: const [
        PkGifter(name: 'Ashok', avatar: AppAssets.avatarKarthik, total: 390),
        PkGifter(name: 'Nisha', avatar: AppAssets.avatarSneha, total: 280),
        PkGifter(name: 'Bala', avatar: AppAssets.avatarSaran, total: 170),
        PkGifter(name: 'Tanvi', avatar: AppAssets.avatarMeena, total: 60),
      ],
      rightGifters: const [
        PkGifter(name: 'Vignesh', avatar: AppAssets.avatarArun, total: 350),
        PkGifter(name: 'Shruti', avatar: AppAssets.avatarDiya, total: 270),
        PkGifter(name: 'Kiran', avatar: AppAssets.avatarVicky, total: 160),
        PkGifter(name: 'Moni', avatar: AppAssets.avatarNeha, total: 75),
      ],
      initialComments: [
        LiveComment(
          id: 'b6_1',
          userName: 'Ashok',
          userAssetPath: AppAssets.avatarKarthik,
          message: 'Angel\'s voice is truly heavenly 🕊️',
          type: LiveCommentType.chat,
          timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
        ),
        LiveComment(
          id: 'b6_2',
          userName: 'Vignesh',
          userAssetPath: AppAssets.avatarArun,
          message: 'sent Rose 🌹 x 2',
          type: LiveCommentType.gift,
          timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
        LiveComment(
          id: 'b6_3',
          userName: 'Nisha',
          userAssetPath: AppAssets.avatarSneha,
          message: 'Divya don\'t give up! 💪',
          type: LiveCommentType.chat,
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
        ),
        LiveComment(
          id: 'b6_4',
          userName: 'Shruti',
          userAssetPath: AppAssets.avatarDiya,
          message: 'Team Divya boost the score! ⚡',
          type: LiveCommentType.chat,
          timestamp: DateTime.now(),
        ),
      ],
      commentPool: const [
        ('Ashok', AppAssets.avatarKarthik, 'Angel singing like an angel 🎶', false),
        ('Vignesh', AppAssets.avatarArun, 'Divya team send stars ⭐', false),
        ('Nisha', AppAssets.avatarSneha, 'sent Golden Horse 🐎 x 1', true),
        ('Shruti', AppAssets.avatarDiya, 'Keep tapping screen friends ❤️', false),
        ('Bala', AppAssets.avatarSaran, 'sent Ocean Tornado 🌪️ x 1', true),
        ('Kiran', AppAssets.avatarVicky, 'Divya energy is amazing 🔥', false),
        ('Tanvi', AppAssets.avatarMeena, 'Tap tap tap! 💖', false),
        ('Moni', AppAssets.avatarNeha, 'sent Rose 🌹 x 4', true),
      ],
    ),
  ];
}
