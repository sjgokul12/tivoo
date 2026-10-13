import '../../../../core/constants/app_assets.dart';
import '../domain/models/gift_item.dart';
import '../domain/models/live_comment.dart';

class MockLiveComments {
  MockLiveComments._();

  static List<LiveComment> get initialComments => [
        LiveComment(
          id: 'comm_1',
          userName: 'LeoBeats',
          userAvatarUrl:
              'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150&auto=format&fit=crop&q=80',
          message: "Vocals on point! 🔥🔥 let's gooo",
          timestamp: DateTime.now().subtract(const Duration(seconds: 25)),
        ),
        LiveComment(
          id: 'comm_star_1',
          userName: 'Maya Vibes',
          userAvatarUrl:
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80',
          message: 'sent 200 Stars! 🌟',
          type: LiveCommentType.star,
          starsCount: 200,
          timestamp: DateTime.now().subtract(const Duration(seconds: 20)),
        ),
        LiveComment(
          id: 'comm_like_1',
          userName: 'DarkKnight22',
          userAvatarUrl:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
          message: 'liked the LIVE stream ❤️',
          type: LiveCommentType.like,
          timestamp: DateTime.now().subtract(const Duration(seconds: 15)),
        ),
        LiveComment(
          id: 'comm_2',
          userName: 'Maya Vibes',
          userAvatarUrl:
              'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80',
          message: 'I love your setup! So cozy ✨',
          timestamp: DateTime.now().subtract(const Duration(seconds: 10)),
        ),
        LiveComment(
          id: 'comm_3',
          userName: 'DarkKnight22',
          userAvatarUrl:
              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
          message: 'This beat is hitting hard 💥',
          timestamp: DateTime.now().subtract(const Duration(seconds: 5)),
        ),
        LiveComment(
          id: 'comm_4',
          userName: 'KoffeeKat',
          userAvatarUrl:
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
          message: 'Your voice is pure magic 💕',
          timestamp: DateTime.now(),
        ),
      ];

  static final List<LiveComment> automatedIncomingPool = [
    LiveComment(
      id: 'pool_1',
      userName: 'Sam_99',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop&q=80',
      message: 'Play my favorite track please! 🎸',
      timestamp: DateTime.now(),
    ),
    LiveComment(
      id: 'pool_2',
      userName: 'Aurora_X',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=150&auto=format&fit=crop&q=80',
      message: 'Sent a Rose 🌹✨',
      timestamp: DateTime.now(),
    ),
    LiveComment(
      id: 'pool_3',
      userName: 'Lucas_Gamer',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=150&auto=format&fit=crop&q=80',
      message: 'Subscribed for 6 months! 🏆',
      timestamp: DateTime.now(),
    ),
    LiveComment(
      id: 'pool_4',
      userName: 'Chloe_DJ',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=150&auto=format&fit=crop&q=80',
      message: 'This remix is fire 🔥🔥',
      timestamp: DateTime.now(),
    ),
    LiveComment(
      id: 'pool_5',
      userName: 'Noah_Vibes',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=150&auto=format&fit=crop&q=80',
      message: 'Greetings from Los Angeles! 🌴',
      timestamp: DateTime.now(),
    ),
    LiveComment(
      id: 'pool_6',
      userName: 'Elena_R',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&auto=format&fit=crop&q=80',
      message: 'Sent 500 Diamonds 💎💎',
      timestamp: DateTime.now(),
    ),
    LiveComment(
      id: 'pool_7',
      userName: 'Kai_Beats',
      userAvatarUrl:
          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
      message: 'Audio quality is unmatched 🎧',
      timestamp: DateTime.now(),
    ),
  ];

  static const List<GiftItem> virtualGifts = [
    GiftItem(
      id: 'gift_rose_bouquet',
      name: 'Rose Bouquet',
      icon: '💐',
      imageAssetPath: AppAssets.giftArtRoseBouquet,
      isSceneArt: true,
      diamonds: 1999,
    ),
    // 3D animated gift effects
    GiftItem(
      id: 'p3d_royal_crown',
      name: 'Royal Crown',
      icon: '👑',
      imageAssetPath: AppAssets.gift3dRoyalCrown,
      isSceneArt: true,
      diamonds: 9999,
    ),
    GiftItem(
      id: 'p3d_angel_vehicle',
      name: 'Angel Vehicle',
      icon: '👼',
      imageAssetPath: AppAssets.gift3dAngelVehicle,
      isSceneArt: true,
      diamonds: 8888,
    ),
    GiftItem(
      id: 'p3d_golden_horse',
      name: 'Golden Horse',
      icon: '🐎',
      imageAssetPath: AppAssets.gift3dGoldenHorse,
      isSceneArt: true,
      diamonds: 6666,
    ),
    GiftItem(
      id: 'p3d_luxury_car',
      name: 'Luxury Car',
      icon: '🏎️',
      imageAssetPath: AppAssets.gift3dLuxuryCar,
      isSceneArt: true,
      diamonds: 5000,
    ),
    GiftItem(
      id: 'p3d_love_castle',
      name: 'Love Castle',
      icon: '🏰',
      imageAssetPath: AppAssets.gift3dLoveCastle,
      isSceneArt: true,
      diamonds: 5200,
    ),
    GiftItem(
      id: 'p3d_galaxy_rocket',
      name: 'Galaxy Rocket',
      icon: '🚀',
      imageAssetPath: AppAssets.gift3dGalaxyRocket,
      isSceneArt: true,
      diamonds: 7777,
    ),
    GiftItem(
      id: 'p3d_diamond_wings',
      name: 'Diamond Wings',
      icon: '🪽',
      imageAssetPath: AppAssets.gift3dDiamondWings,
      isSceneArt: true,
      diamonds: 3000,
    ),
    GiftItem(
      id: 'p3d_flower_chariot',
      name: 'Flower Chariot',
      icon: '🌹',
      imageAssetPath: AppAssets.gift3dFlowerChariot,
      isSceneArt: true,
      diamonds: 4500,
    ),
    GiftItem(
      id: 'p3d_ocean_whale',
      name: 'Ocean Whale',
      icon: '🐋',
      imageAssetPath: AppAssets.gift3dOceanWhale,
      isSceneArt: true,
      diamonds: 6000,
    ),
    GiftItem(
      id: 'p3d_meteor_shower',
      name: 'Meteor Shower',
      icon: '🌠',
      imageAssetPath: AppAssets.gift3dMeteorShower,
      isSceneArt: true,
      diamonds: 2999,
    ),
    GiftItem(
      id: 'gift_cosmic_rose',
      name: 'Cosmic Fire Rose',
      icon: '🌹',
      imageAssetPath: AppAssets.giftArtCosmicFireRose,
      diamonds: 999,
    ),
    GiftItem(
      id: 'gift_flowers',
      name: 'Flowers',
      icon: '💐',
      imageAssetPath: AppAssets.giftArtFlowers,
      diamonds: 10,
    ),
    GiftItem(
      id: 'gift_love',
      name: 'Love',
      icon: '💖',
      imageAssetPath: AppAssets.giftArtLove,
      diamonds: 10,
    ),
    GiftItem(
      id: 'gift_kitty',
      name: 'Kitty',
      icon: '🐱',
      imageAssetPath: AppAssets.giftArtKitty,
      diamonds: 50,
    ),
    GiftItem(
      id: 'gift_teddy',
      name: 'Teddy',
      icon: '🧸',
      imageAssetPath: AppAssets.giftArtTeddy,
      diamonds: 50,
    ),
    GiftItem(
      id: 'gift_tiki_love',
      name: 'Tiki Love',
      icon: '💕',
      imageAssetPath: AppAssets.giftArtTikiLove,
      diamonds: 100,
    ),
    GiftItem(
      id: 'gift_cake',
      name: 'Cake',
      icon: '🎂',
      imageAssetPath: AppAssets.giftArtCake,
      diamonds: 100,
    ),
    GiftItem(
      id: 'gift_crown',
      name: 'Crown',
      icon: '👑',
      imageAssetPath: AppAssets.giftArtCrown,
      diamonds: 200,
    ),
    GiftItem(
      id: 'gift_angel_wings',
      name: 'Angel Wings',
      icon: '👼',
      imageAssetPath: AppAssets.giftArtAngelWings,
      diamonds: 500,
    ),
    GiftItem(
      id: 'gift_diamond',
      name: 'Diamond',
      icon: '💎',
      imageAssetPath: AppAssets.giftArtDiamond,
      diamonds: 500,
    ),
    GiftItem(
      id: 'gift_super_car',
      name: 'Super Car',
      icon: '🏎️',
      imageAssetPath: AppAssets.giftArtSuperCar,
      diamonds: 1000,
    ),
    GiftItem(
      id: 'gift_rocket',
      name: 'Rocket',
      icon: '🚀',
      imageAssetPath: AppAssets.giftArtRocket,
      diamonds: 1000,
    ),
    GiftItem(
      id: 'gift_yacht',
      name: 'Yacht',
      icon: '🛥️',
      imageAssetPath: AppAssets.giftArtYacht,
      diamonds: 2000,
    ),
    GiftItem(
      id: 'gift_castle',
      name: 'Castle',
      icon: '🏰',
      imageAssetPath: AppAssets.giftArtCastle,
      diamonds: 5000,
    ),
    GiftItem(
      id: 'gift_world_tour',
      name: 'World Tour',
      icon: '🌍',
      imageAssetPath: AppAssets.giftArtWorldTour,
      diamonds: 10000,
    ),
  ];
}
