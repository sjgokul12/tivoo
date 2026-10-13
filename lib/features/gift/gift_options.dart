import '../../core/constants/app_assets.dart';

/// ============================================================================
/// UNIFIED GIFT OPTIONS & CATALOG SYSTEM
/// ============================================================================
/// Single consolidated source of truth for all gift models, catalog items,
/// category filters, combo multipliers, PK Battle options, coin recharge packs,
/// and animation metadata.
/// ============================================================================

/// Identifies the high-fidelity 3D/canvas animation profile for an active gift.
enum GiftAnimationType {
  roses,
  oceanDolphin,
  goldenHorse,
  angelVehicle,
  starThrone,
  loveCastle,
  goldenLion,
  galaxyRocket,
  luxuryCar,
  royalCrown,
  diamondWings,
  luxuryYacht,
  classicRose,
  classicHeart,
  genericSticker,
}

/// Core model representing a virtual gift across live streaming, PK battles,
/// audio party rooms, and 24/7 live feeds.
class GiftItem {
  final String id;
  final String name;
  final String icon;
  final String? imageAssetPath;
  final int diamonds;
  final String category;
  final String tagline;
  final GiftAnimationType? animationTypeOverride;

  const GiftItem({
    required this.id,
    required this.name,
    required this.icon,
    this.imageAssetPath,
    required this.diamonds,
    this.category = 'Popular',
    this.tagline = '',
    this.animationTypeOverride,
  });

  /// Formatted star / diamond label (e.g., "100,000 ⭐")
  String get formattedDiamonds {
    if (diamonds >= 1000) {
      final s = diamonds.toString();
      final lastThree = s.substring(s.length - 3);
      final rest = s.substring(0, s.length - 3);
      return '$rest,$lastThree ⭐';
    }
    return '$diamonds ⭐';
  }

  /// Resolves the animation type for this gift.
  GiftAnimationType get animationType {
    if (animationTypeOverride != null) return animationTypeOverride!;
    final idLower = id.toLowerCase();
    final nameLower = name.toLowerCase();

    if (idLower.contains('ani10') || idLower.contains('roses') || nameLower.contains('rose')) {
      if (idLower.contains('roses') || nameLower == 'roses') return GiftAnimationType.roses;
      return GiftAnimationType.classicRose;
    }
    if ((idLower.contains('ani1') && !idLower.contains('ani10')) ||
        idLower.contains('whale') ||
        nameLower.contains('whale') ||
        idLower.contains('dolphin') ||
        nameLower.contains('dolphin')) {
      return GiftAnimationType.oceanDolphin;
    }
    if (idLower.contains('ani2') || idLower.contains('horse') || nameLower.contains('horse')) {
      return GiftAnimationType.goldenHorse;
    }
    if (idLower.contains('ani3') ||
        idLower.contains('vehicle') ||
        nameLower.contains('vehicle') ||
        idLower.contains('chariot') ||
        nameLower.contains('chariot')) {
      return GiftAnimationType.angelVehicle;
    }
    if (idLower.contains('ani4') || idLower.contains('throne') || nameLower.contains('throne')) {
      return GiftAnimationType.starThrone;
    }
    if (idLower.contains('ani5') || idLower.contains('castle') || nameLower.contains('castle')) {
      return GiftAnimationType.loveCastle;
    }
    if (idLower.contains('lion') || nameLower.contains('lion')) {
      return GiftAnimationType.goldenLion;
    }
    if (idLower.contains('rocket') || nameLower.contains('rocket')) {
      return GiftAnimationType.galaxyRocket;
    }
    if (idLower.contains('ani6') || idLower.contains('car') || nameLower.contains('car')) {
      return GiftAnimationType.luxuryCar;
    }
    if (idLower.contains('ani7') || idLower.contains('crown') || nameLower.contains('crown')) {
      return GiftAnimationType.royalCrown;
    }
    if (idLower.contains('wing') || nameLower.contains('wing')) {
      return GiftAnimationType.diamondWings;
    }
    if (idLower.contains('yacht') || nameLower.contains('yacht')) {
      return GiftAnimationType.luxuryYacht;
    }
    if (idLower.contains('love') || idLower.contains('heart') || nameLower.contains('heart')) {
      return GiftAnimationType.classicHeart;
    }
    return GiftAnimationType.genericSticker;
  }

  /// Sound category key matching [GiftSoundService].
  String get soundCategory {
    switch (animationType) {
      case GiftAnimationType.royalCrown:
        return 'crown';
      case GiftAnimationType.angelVehicle:
        return 'vehicle';
      case GiftAnimationType.goldenHorse:
        return 'horse';
      case GiftAnimationType.loveCastle:
        return 'castle';
      case GiftAnimationType.galaxyRocket:
        return 'rocket';
      case GiftAnimationType.goldenLion:
        return 'lion';
      case GiftAnimationType.luxuryCar:
        return 'car';
      case GiftAnimationType.luxuryYacht:
        return 'yacht';
      case GiftAnimationType.diamondWings:
        return 'wings';
      case GiftAnimationType.starThrone:
        return 'throne';
      case GiftAnimationType.roses:
        return 'roses';
      case GiftAnimationType.oceanDolphin:
        return 'dolphin';
      case GiftAnimationType.classicRose:
        return 'roses';
      default:
        return 'magic';
    }
  }

  /// Helper boolean getters for fast condition checks
  bool get isCrown => animationType == GiftAnimationType.royalCrown;
  bool get isOceanDolphin => animationType == GiftAnimationType.oceanDolphin;
  bool get isRoses => animationType == GiftAnimationType.roses;
  bool get isStarThrone => animationType == GiftAnimationType.starThrone;
  bool get isDiamondWings => animationType == GiftAnimationType.diamondWings;
  bool get isLuxuryCar => animationType == GiftAnimationType.luxuryCar;
  bool get isLuxuryYacht => animationType == GiftAnimationType.luxuryYacht;
  bool get isGoldenLion => animationType == GiftAnimationType.goldenLion;
  bool get isLoveCastle => animationType == GiftAnimationType.loveCastle;
  bool get isAngelVehicle => animationType == GiftAnimationType.angelVehicle;
  bool get isGoldenHorse => animationType == GiftAnimationType.goldenHorse;
  bool get isGalaxyRocket => animationType == GiftAnimationType.galaxyRocket;

  /// True if this gift belongs to the Luxury Master Animation suite
  bool get isMasterAniGift => diamonds >= 500;

  GiftItem copyWith({
    String? id,
    String? name,
    String? icon,
    String? imageAssetPath,
    int? diamonds,
    String? category,
    String? tagline,
    GiftAnimationType? animationTypeOverride,
  }) {
    return GiftItem(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      imageAssetPath: imageAssetPath ?? this.imageAssetPath,
      diamonds: diamonds ?? this.diamonds,
      category: category ?? this.category,
      tagline: tagline ?? this.tagline,
      animationTypeOverride: animationTypeOverride ?? this.animationTypeOverride,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'imageAssetPath': imageAssetPath,
      'diamonds': diamonds,
      'category': category,
      'tagline': tagline,
    };
  }

  factory GiftItem.fromMap(Map<String, dynamic> map) {
    return GiftItem(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: map['icon'] as String,
      imageAssetPath: map['imageAssetPath'] as String?,
      diamonds: map['diamonds'] as int,
      category: (map['category'] as String?) ?? 'Popular',
      tagline: (map['tagline'] as String?) ?? '',
    );
  }

  @override
  String toString() => 'GiftItem($id, $name, $diamonds ⭐)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GiftItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// ============================================================================
/// GIFT CATEGORY OPTIONS
/// ============================================================================
class GiftCategoryOption {
  final String id;
  final String label;
  final String icon;

  const GiftCategoryOption({
    required this.id,
    required this.label,
    required this.icon,
  });

  static const List<GiftCategoryOption> standard = [
    GiftCategoryOption(id: 'All', label: 'All', icon: '✨'),
    GiftCategoryOption(id: 'Popular', label: 'Popular', icon: '🔥'),
    GiftCategoryOption(id: 'Love', label: 'Love', icon: '💖'),
    GiftCategoryOption(id: 'Luxury', label: 'Luxury', icon: '👑'),
    GiftCategoryOption(id: 'Romantic', label: 'Romantic', icon: '🌹'),
    GiftCategoryOption(id: 'Special', label: 'Special', icon: '⭐'),
  ];

  static const List<String> labels = ['All', 'Popular', 'Love', 'Luxury', 'Romantic', 'Special'];
}

/// ============================================================================
/// COMBO / QUANTITY OPTIONS
/// ============================================================================
class GiftComboOption {
  final int count;
  final String label;
  final String meaning;
  final int particleTier;
  final bool isFeatured;

  const GiftComboOption({
    required this.count,
    required this.label,
    required this.meaning,
    this.particleTier = 1,
    this.isFeatured = false,
  });

  static const List<GiftComboOption> presets = [
    GiftComboOption(count: 1, label: 'x1', meaning: 'Just for you', particleTier: 1),
    GiftComboOption(count: 5, label: 'x5', meaning: 'High Five', particleTier: 1),
    GiftComboOption(count: 10, label: 'x10', meaning: 'Perfect 10', particleTier: 2),
    GiftComboOption(count: 66, label: 'x66', meaning: 'Smooth Sailing', particleTier: 2),
    GiftComboOption(count: 88, label: 'x88', meaning: 'Double Luck', particleTier: 3, isFeatured: true),
    GiftComboOption(count: 99, label: 'x99', meaning: 'Stay Forever', particleTier: 3),
    GiftComboOption(count: 188, label: 'x188', meaning: 'Prosperity', particleTier: 4),
    GiftComboOption(count: 520, label: 'x520', meaning: 'I Love You', particleTier: 4, isFeatured: true),
    GiftComboOption(count: 1314, label: 'x1314', meaning: 'Lifetime Commitment', particleTier: 5, isFeatured: true),
  ];
}

/// ============================================================================
/// PK BATTLE GIFT OPTIONS & DATA
/// ============================================================================
class PKGiftEvent {
  final int id;
  final String sender;
  final String senderAvatar;
  final String giftName;
  final String emoji;
  final String? giftImage;
  final int count;

  const PKGiftEvent({
    required this.id,
    required this.sender,
    required this.senderAvatar,
    required this.giftName,
    required this.emoji,
    this.giftImage,
    this.count = 1,
  });
}

class PKBattleGiftData {
  PKBattleGiftData._();

  /// Quick gift picks specifically highlighted during PK Battles
  static const List<String> quickGiftNames = [
    'Rose',
    'Heart',
    'Luxury Car',
    'Ocean Dolphin',
    'Golden Horse',
    'Royal Crown',
  ];

  /// Sticker artwork mapped by gift name for PK simulated chat and pill banners
  static const Map<String, String> giftImages = {
    'Rose': AppAssets.giftRose,
    'Flowers': AppAssets.giftFlowers,
    'Heart': AppAssets.giftLove,
    'Golden Horse': AppAssets.giftGoldenHorse,
    'Ocean Whale': AppAssets.oceanDolphinHero,
    'Ocean Dolphin': AppAssets.oceanDolphinHero,
    'Angel Vehicle': AppAssets.giftAngelVehicle,
    'Super Car': AppAssets.giftSuperCar,
    'Luxury Car': AppAssets.ani6,
    'Royal Crown': AppAssets.ani7,
    'Love Castle': AppAssets.loveCastleActor,
    'Star Throne': AppAssets.starThroneActor,
    'Diamond Wings': AppAssets.diamondWingsHero,
    'Roses': AppAssets.rosesStreamHero,
  };

  /// Initial demo gift events for PK stream preview
  static const PKGiftEvent defaultLeftGift = PKGiftEvent(
    id: -1,
    sender: 'Riya',
    senderAvatar: AppAssets.status4,
    giftName: 'Rose',
    emoji: '🌹',
    giftImage: AppAssets.giftRose,
    count: 1,
  );

  static const PKGiftEvent defaultRightGift = PKGiftEvent(
    id: -2,
    sender: 'Karthik',
    senderAvatar: AppAssets.avatarKarthik,
    giftName: 'Galaxy',
    emoji: '🔮',
    count: 5,
  );

  /// Rotating pool of simulated audience messages: (name, avatar, message, isGift)
  static const List<(String, String, String, bool)> incomingComments = [
    ('Priya', AppAssets.status3, 'Go Neha 💛', false),
    ('Karthik', AppAssets.status5, 'Super performance ❤️', false),
    ('Manoj', AppAssets.status2, 'sent Rose 🌹 x 1', true),
    ('Divya', AppAssets.status4, 'sent Heart 💖 x 1', true),
    ('Rahul', AppAssets.status5, 'sent Luxury Car 🏎️ x 1', true),
    ('Sneha', AppAssets.status3, 'sent Royal Crown 👑 x 1', true),
    ('Kavya', AppAssets.status4, 'sent Golden Horse 🐎 x 1', true),
    ('Ananya', AppAssets.status3, 'sent Ocean Dolphin 🐬 x 1', true),
    ('Sanjay', AppAssets.status5, 'sent Angel Vehicle 🕊️ x 1', true),
    ('Vicky', AppAssets.status2, 'Both are amazing 👏', false),
    ('Diya', AppAssets.status4, 'Amazing PK 🔥', false),
  ];

  /// Standard formula for PK score gain per gift sent
  static int calculatePkPoints(GiftItem gift, int quantity) {
    return gift.diamonds * 15 * quantity;
  }
}

/// ============================================================================
/// RECIPIENT OPTIONS
/// ============================================================================
class GiftRecipientOption {
  final String id;
  final String displayName;
  final String? subtitle;
  final String? avatarUrl;

  const GiftRecipientOption({
    required this.id,
    required this.displayName,
    this.subtitle,
    this.avatarUrl,
  });

  static const GiftRecipientOption host = GiftRecipientOption(
    id: 'host',
    displayName: 'Host',
    subtitle: 'Stream Broadcaster',
  );

  static const GiftRecipientOption opponent = GiftRecipientOption(
    id: 'opponent',
    displayName: 'Opponent',
    subtitle: 'PK Battle Challenger',
  );

  static const GiftRecipientOption bothHosts = GiftRecipientOption(
    id: 'both',
    displayName: 'Both Hosts',
    subtitle: 'Split 50/50',
  );
}

/// ============================================================================
/// COIN TOP-UP & PAYMENT OPTIONS
/// ============================================================================
class CoinPackOption {
  final int coins;
  final String price;
  final bool isPopular;
  final String bonus;

  const CoinPackOption({
    required this.coins,
    required this.price,
    this.isPopular = false,
    this.bonus = '',
  });

  static const List<CoinPackOption> standardPacks = [
    CoinPackOption(coins: 70, price: '₹49'),
    CoinPackOption(coins: 350, price: '₹249', isPopular: true, bonus: '+25 Bonus'),
    CoinPackOption(coins: 700, price: '₹499', bonus: '+60 Bonus'),
    CoinPackOption(coins: 1750, price: '₹999', bonus: '+200 Bonus'),
    CoinPackOption(coins: 3500, price: '₹1,999', bonus: '+500 Bonus'),
    CoinPackOption(coins: 7000, price: '₹3,899', bonus: '+1,200 Bonus'),
    CoinPackOption(coins: 15000, price: '₹7,999', bonus: '+3,000 Bonus'),
  ];
}

class PaymentMethodOption {
  final String id;
  final String name;
  final String icon;
  final bool isDefault;

  const PaymentMethodOption({
    required this.id,
    required this.name,
    required this.icon,
    this.isDefault = false,
  });

  static const List<PaymentMethodOption> standardMethods = [
    PaymentMethodOption(id: 'gpay', name: 'Google Pay', icon: '⚡', isDefault: true),
    PaymentMethodOption(id: 'paytm', name: 'Paytm UPI', icon: '💳'),
    PaymentMethodOption(id: 'card', name: 'Credit / Debit Card', icon: '💳'),
    PaymentMethodOption(id: 'netbanking', name: 'Net Banking', icon: '🏦'),
  ];
}

/// ============================================================================
/// ANIMATION METADATA REGISTRY
/// ============================================================================
class GiftAnimationMeta {
  final GiftAnimationType type;
  final Duration duration;
  final int stagesCount;
  final String soundtrackName;

  const GiftAnimationMeta({
    required this.type,
    required this.duration,
    required this.stagesCount,
    required this.soundtrackName,
  });

  static const Map<GiftAnimationType, GiftAnimationMeta> registry = {
    GiftAnimationType.royalCrown: GiftAnimationMeta(
      type: GiftAnimationType.royalCrown,
      duration: Duration(milliseconds: 6000),
      stagesCount: 5,
      soundtrackName: 'sound_crown.wav',
    ),
    GiftAnimationType.angelVehicle: GiftAnimationMeta(
      type: GiftAnimationType.angelVehicle,
      duration: Duration(milliseconds: 7000),
      stagesCount: 6,
      soundtrackName: 'sound_angel_vehicle.wav',
    ),
    GiftAnimationType.goldenHorse: GiftAnimationMeta(
      type: GiftAnimationType.goldenHorse,
      duration: Duration(milliseconds: 6500),
      stagesCount: 5,
      soundtrackName: 'sound_horse.wav',
    ),
    GiftAnimationType.starThrone: GiftAnimationMeta(
      type: GiftAnimationType.starThrone,
      duration: Duration(milliseconds: 10000),
      stagesCount: 6,
      soundtrackName: 'sound_star_throne.wav',
    ),
    GiftAnimationType.loveCastle: GiftAnimationMeta(
      type: GiftAnimationType.loveCastle,
      duration: Duration(milliseconds: 8000),
      stagesCount: 6,
      soundtrackName: 'sound_love_castle.wav',
    ),
    GiftAnimationType.goldenLion: GiftAnimationMeta(
      type: GiftAnimationType.goldenLion,
      duration: Duration(milliseconds: 7000),
      stagesCount: 5,
      soundtrackName: 'sound_lion.wav',
    ),
    GiftAnimationType.galaxyRocket: GiftAnimationMeta(
      type: GiftAnimationType.galaxyRocket,
      duration: Duration(milliseconds: 5500),
      stagesCount: 4,
      soundtrackName: 'sound_rocket.wav',
    ),
    GiftAnimationType.luxuryCar: GiftAnimationMeta(
      type: GiftAnimationType.luxuryCar,
      duration: Duration(milliseconds: 6500),
      stagesCount: 6,
      soundtrackName: 'sound_car.wav',
    ),
    GiftAnimationType.luxuryYacht: GiftAnimationMeta(
      type: GiftAnimationType.luxuryYacht,
      duration: Duration(milliseconds: 8000),
      stagesCount: 5,
      soundtrackName: 'sound_yacht.wav',
    ),
    GiftAnimationType.diamondWings: GiftAnimationMeta(
      type: GiftAnimationType.diamondWings,
      duration: Duration(milliseconds: 8000),
      stagesCount: 6,
      soundtrackName: 'sound_diamond_wings.wav',
    ),
    GiftAnimationType.roses: GiftAnimationMeta(
      type: GiftAnimationType.roses,
      duration: Duration(milliseconds: 12000),
      stagesCount: 6,
      soundtrackName: 'sound_roses.wav',
    ),
    GiftAnimationType.oceanDolphin: GiftAnimationMeta(
      type: GiftAnimationType.oceanDolphin,
      duration: Duration(milliseconds: 10000),
      stagesCount: 6,
      soundtrackName: 'sound_ocean_dolphin.wav',
    ),
    GiftAnimationType.classicRose: GiftAnimationMeta(
      type: GiftAnimationType.classicRose,
      duration: Duration(milliseconds: 3000),
      stagesCount: 3,
      soundtrackName: 'sound_rose.wav',
    ),
    GiftAnimationType.classicHeart: GiftAnimationMeta(
      type: GiftAnimationType.classicHeart,
      duration: Duration(milliseconds: 3000),
      stagesCount: 3,
      soundtrackName: 'magic',
    ),
    GiftAnimationType.genericSticker: GiftAnimationMeta(
      type: GiftAnimationType.genericSticker,
      duration: Duration(milliseconds: 2500),
      stagesCount: 2,
      soundtrackName: 'magic',
    ),
  };
}

/// ============================================================================
/// MASTER GIFT CATALOG (CENTRAL SOURCE OF TRUTH)
/// ============================================================================
class GiftCatalog {
  GiftCatalog._();

  /// 👑 Master list of all virtual gifts
  static const List<GiftItem> allGifts = [
    // 👑 1. Royal Crown (Biggest Prize - 50,000 Stars)
    GiftItem(
      id: 'gift_ani7_crown',
      name: 'Royal Crown',
      icon: '👑',
      imageAssetPath: AppAssets.ani7,
      diamonds: 50000,
      category: 'Luxury',
      tagline: 'Grand Coronation & Sovereign Glory',
    ),

    // 🕊️ 2. Angel Vehicle (35,000 Stars)
    GiftItem(
      id: 'gift_ani3_vehicle',
      name: 'Angel Vehicle',
      icon: '🕊️',
      imageAssetPath: AppAssets.ani3,
      diamonds: 35000,
      category: 'Luxury',
      tagline: 'Celestial Chariot of Divine Blessings',
    ),

    // 🐎 3. Golden Horse (25,000 Stars)
    GiftItem(
      id: 'gift_ani2_horse',
      name: 'Golden Horse',
      icon: '🐎',
      imageAssetPath: AppAssets.ani2,
      diamonds: 25000,
      category: 'Popular',
      tagline: 'Majestic Golden Steed of Triumph',
    ),

    // 🏰 4. Love Castle (100,000 Stars)
    GiftItem(
      id: 'gift_ani5_castle',
      name: 'Love Castle',
      icon: '🏰',
      imageAssetPath: AppAssets.loveCastleActor,
      diamonds: 100000,
      category: 'Love',
      tagline: 'Fairytale Kingdom of Everlasting Love',
    ),

    // 🚀 5. Galaxy Rocket (1,000 Stars)
    GiftItem(
      id: 'gift_rocket',
      name: 'Galaxy Rocket',
      icon: '🚀',
      imageAssetPath: AppAssets.galaxyRocketHero,
      diamonds: 1000,
      category: 'Popular',
      tagline: 'Cosmic Ascent Across the Stars',
    ),

    // 🦁 6. Golden Lion (5,000 Stars)
    GiftItem(
      id: 'gift_golden_lion',
      name: 'Golden Lion',
      icon: '🦁',
      imageAssetPath: AppAssets.goldenLionHero,
      diamonds: 5000,
      category: 'Special',
      tagline: 'Courage, Power and Untamed Royalty',
    ),

    // 🏎️ 7. Luxury Car (500 Stars - User Reference)
    GiftItem(
      id: 'gift_ani6_car',
      name: 'Luxury Car',
      icon: '🏎️',
      imageAssetPath: AppAssets.ani6,
      diamonds: 500,
      category: 'Popular',
      tagline: 'High Speed Cyber Supercar Rush',
    ),

    // 💐 8. Flowers (200 Stars)
    GiftItem(
      id: 'gift_flowers',
      name: 'Flowers',
      icon: '💐',
      imageAssetPath: AppAssets.giftFlowers,
      diamonds: 200,
      category: 'Popular',
      tagline: 'Fresh Floral Bouquet of Joy',
    ),

    // 🏎️ 9. Super Car (500 Stars - Backward Compatibility)
    GiftItem(
      id: 'gift_super_car',
      name: 'Super Car',
      icon: '🏎️',
      imageAssetPath: AppAssets.giftSuperCar,
      diamonds: 500,
      category: 'Popular',
      tagline: 'Turbocharged Moving Supercar',
    ),

    // 🛥️ 10. Luxury Yacht (5,000 Stars)
    GiftItem(
      id: 'gift_yacht',
      name: 'Luxury Yacht',
      icon: '🛥️',
      imageAssetPath: AppAssets.luxuryYachtActor,
      diamonds: 5000,
      category: 'Luxury',
      tagline: 'Ocean Sunset Cruise of Extravagance',
    ),

    // 💎 11. Diamond Wings (10,000 Stars)
    GiftItem(
      id: 'gift_diamond_wings',
      name: 'Diamond Wings',
      icon: '💎',
      imageAssetPath: AppAssets.diamondWingsHero,
      diamonds: 10000,
      category: 'Love',
      tagline: 'Prismatic Luminous Wings of Glory',
    ),

    // 👑 12. Star Throne (5,000 Stars)
    GiftItem(
      id: 'gift_ani4_throne',
      name: 'Star Throne',
      icon: '👑',
      imageAssetPath: AppAssets.starThroneActor,
      diamonds: 5000,
      category: 'Special',
      tagline: 'Throne of Stars & Sovereign Rule',
    ),

    // 🌹 13. Roses (100,000 Stars)
    GiftItem(
      id: 'gift_ani10_roses',
      name: 'Roses',
      icon: '🌹',
      imageAssetPath: AppAssets.rosesStreamHero,
      diamonds: 100000,
      category: 'Romantic',
      tagline: 'Bloom, Spread, Touch Hearts',
    ),

    // 🐬 14. Ocean Dolphin (10,000 Stars)
    GiftItem(
      id: 'gift_ani1_whale',
      name: 'Ocean Dolphin',
      icon: '🐬',
      imageAssetPath: AppAssets.oceanDolphinHero,
      diamonds: 10000,
      category: 'Special',
      tagline: 'Freedom, Peace, New Beginnings',
    ),

    // 🌹 15. Classic Rose (10 Stars)
    GiftItem(
      id: 'gift_rose',
      name: 'Rose',
      icon: '🌹',
      imageAssetPath: AppAssets.giftRose,
      diamonds: 10,
      category: 'Popular',
      tagline: 'A Single Blossom of Affection',
    ),

    // 💖 16. Heart (50 Stars)
    GiftItem(
      id: 'gift_love',
      name: 'Heart',
      icon: '💖',
      imageAssetPath: AppAssets.giftLove,
      diamonds: 50,
      category: 'Love',
      tagline: 'Pure Warm Love',
    ),

    // 💎 17. Diamond (500 Stars)
    GiftItem(
      id: 'gift_diamond',
      name: 'Diamond',
      icon: '💎',
      imageAssetPath: AppAssets.giftDiamond,
      diamonds: 500,
      category: 'Luxury',
      tagline: 'Sparkling Brilliant Gem',
    ),
  ];

  /// Master list alias for compatibility with MockLiveComments
  static const List<GiftItem> virtualGifts = allGifts;

  /// Find a gift by unique ID
  static GiftItem? findById(String id) {
    try {
      return allGifts.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Find a gift by Name (case-insensitive)
  static GiftItem? findByName(String name) {
    final needle = name.toLowerCase().trim();
    try {
      return allGifts.firstWhere(
        (g) => g.name.toLowerCase().trim() == needle,
      );
    } catch (_) {
      return null;
    }
  }

  /// Filter gifts by selected category tab
  static List<GiftItem> filterByCategory(String category) {
    switch (category) {
      case 'Popular':
        return allGifts
            .where((g) =>
                g.category == 'Popular' ||
                g.id.contains('crown') ||
                g.id.contains('horse') ||
                g.id.contains('car') ||
                g.id.contains('whale') ||
                g.id.contains('rose'))
            .toList();

      case 'Love':
        return allGifts
            .where((g) =>
                g.category == 'Love' ||
                g.id.contains('castle') ||
                g.id.contains('wings') ||
                g.id.contains('vehicle') ||
                g.id.contains('roses') ||
                g.id.contains('love'))
            .toList();

      case 'Luxury':
      case 'Premium':
        return allGifts.where((g) => g.diamonds >= 1000).toList();

      case 'Romantic':
        return allGifts
            .where((g) =>
                g.category == 'Romantic' ||
                g.id.contains('roses') ||
                g.id.contains('rose') ||
                g.id.contains('flower') ||
                g.id.contains('castle'))
            .toList();

      case 'Special':
        return allGifts
            .where((g) =>
                g.category == 'Special' ||
                g.id.contains('throne') ||
                g.id.contains('lion') ||
                g.id.contains('dolphin') ||
                g.id.contains('whale'))
            .toList();

      case 'All':
      default:
        return allGifts;
    }
  }
}
