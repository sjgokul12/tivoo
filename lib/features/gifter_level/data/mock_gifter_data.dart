import '../domain/models/gifter_level_model.dart';

/// Temporary local demo data for the Gifter Level System UI.
///
/// NOTE:
/// - Stars thresholds are placeholder configuration values for UI preview only.
/// - Buying Stars alone does NOT increase the Gifter Level; only eligible Stars
///   spent on sending gifts count towards milestone progress.
/// - This prototype does not connect to live wallet transactions or backend APIs.
class MockGifterData {
  MockGifterData._();

  /// Default demo user state: Level 18 Gifter.
  /// (Unlocked milestones: 1, 5, 10, 15; currently working towards Level 20).
  static const int demoInitialLevel = 18;
  static const int demoInitialStarsSpent = 24500;
  static const int demoPurchasedStars = 150000; // Demonstrates separation of purchased vs spent

  /// The 19 client-specified milestone levels with exact reward names.
  static const List<GifterMilestone> milestones = [
    // -------------------------------------------------------------------------
    // Level 1: Basic
    // -------------------------------------------------------------------------
    GifterMilestone(
      level: 1,
      tierName: 'Basic Gifter',
      starsThresholdPlaceholder: 100,
      bracket: GifterTierBracket.basic,
      description: 'Your gifting journey begins with basic status and profile framing.',
      rewards: [
        GifterReward(
          name: 'Basic Profile Frame',
          category: GifterRewardCategory.profileFrame,
          description: 'Standard glowing ring frame applied to your avatar in profile and live chats.',
        ),
        GifterReward(
          name: 'Additional Perks (Placeholder)',
          category: GifterRewardCategory.placeholder,
          description: 'To be announced by client upon confirmation.',
          isPlaceholder: true,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // Level 5: Bronze
    // -------------------------------------------------------------------------
    GifterMilestone(
      level: 5,
      tierName: 'Bronze Gifter',
      starsThresholdPlaceholder: 1500,
      bracket: GifterTierBracket.bronze,
      description: 'Step up with polished bronze framing and community recognition.',
      rewards: [
        GifterReward(
          name: 'Bronze Profile Frame',
          category: GifterRewardCategory.profileFrame,
          description: 'Burnished bronze avatar bezel with amber glints in live streams.',
        ),
        GifterReward(
          name: 'Additional Perks (Placeholder)',
          category: GifterRewardCategory.placeholder,
          description: 'To be announced by client upon confirmation.',
          isPlaceholder: true,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // Level 10: Silver
    // -------------------------------------------------------------------------
    GifterMilestone(
      level: 10,
      tierName: 'Silver Gifter',
      starsThresholdPlaceholder: 6000,
      bracket: GifterTierBracket.silver,
      description: 'Radiant silver framing showcasing generous stream support.',
      rewards: [
        GifterReward(
          name: 'Silver Profile Frame',
          category: GifterRewardCategory.profileFrame,
          description: 'Polished chrome-silver avatar frame with silver starlight radiance.',
        ),
        GifterReward(
          name: 'Additional Perks (Placeholder)',
          category: GifterRewardCategory.placeholder,
          description: 'To be announced by client upon confirmation.',
          isPlaceholder: true,
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // Level 15: Gold
    // -------------------------------------------------------------------------
    GifterMilestone(
      level: 15,
      tierName: 'Gold Gifter',
      starsThresholdPlaceholder: 15000,
      bracket: GifterTierBracket.gold,
      description: 'Official Gold status with badges and luminous profile effects.',
      rewards: [
        GifterReward(
          name: 'Gold Profile Frame',
          category: GifterRewardCategory.profileFrame,
          description: 'Lustrous 24K gold border with crown accents around your avatar.',
        ),
        GifterReward(
          name: 'Gold Level Badge',
          category: GifterRewardCategory.levelBadge,
          description: 'Vibrant gold milestone insignia displayed beside your username.',
        ),
        GifterReward(
          name: 'Special Profile Effect',
          category: GifterRewardCategory.profileEffect,
          description: 'Subtle golden sparkle aura on your profile header.',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // Level 20: Premium Gold
    // -------------------------------------------------------------------------
    GifterMilestone(
      level: 20,
      tierName: 'Premium Gold Gifter',
      starsThresholdPlaceholder: 30000,
      bracket: GifterTierBracket.premiumGold,
      description: 'Elevated prestige with animated badges and exclusive entrance flare.',
      rewards: [
        GifterReward(
          name: 'Premium Gold Profile Frame',
          category: GifterRewardCategory.profileFrame,
          description: 'Multi-layer gold filigree frame with pulsing corner jewels.',
        ),
        GifterReward(
          name: 'Animated Level Badge',
          category: GifterRewardCategory.levelBadge,
          description: 'Shimmering animated level indicator in chats and rankings.',
        ),
        GifterReward(
          name: 'Exclusive Gifter Entrance Effect',
          category: GifterRewardCategory.entranceEffect,
          description: 'Gold streak animation announcing your entry into live rooms.',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // Level 25: Platinum
    // -------------------------------------------------------------------------
    GifterMilestone(
      level: 25,
      tierName: 'Platinum Gifter',
      starsThresholdPlaceholder: 60000,
      bracket: GifterTierBracket.platinum,
      description: 'Cool crystalline platinum frame with chat room recognition.',
      rewards: [
        GifterReward(
          name: 'Platinum Profile Frame',
          category: GifterRewardCategory.profileFrame,
          description: 'Ice-platinum metallic frame with subtle prismatic refraction.',
        ),
        GifterReward(
          name: 'Platinum Level Badge',
          category: GifterRewardCategory.levelBadge,
          description: 'Crystalline blue-violet platinum badge for your profile & chats.',
        ),
        GifterReward(
          name: 'Premium Chat Recognition',
          category: GifterRewardCategory.chatRecognition,
          description: 'Highlighted chat bubble border and priority color in live comments.',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // Level 30: Diamond
    // -------------------------------------------------------------------------
    GifterMilestone(
      level: 30,
      tierName: 'Diamond Gifter',
      starsThresholdPlaceholder: 120000,
      bracket: GifterTierBracket.diamond,
      description: 'Brilliant diamond luster with animated badge and room entrance.',
      rewards: [
        GifterReward(
          name: 'Diamond Profile Frame',
          category: GifterRewardCategory.profileFrame,
          description: 'Faceted cyan diamond bezel with perpetual crystalline glitter.',
        ),
        GifterReward(
          name: 'Animated Diamond Badge',
          category: GifterRewardCategory.levelBadge,
          description: 'Pulsing cyan-violet diamond badge with light beam flares.',
        ),
        GifterReward(
          name: 'Special Live Room Entrance Effect',
          category: GifterRewardCategory.entranceEffect,
          description: 'Diamond glitter cascade when you enter any live broadcast.',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // Level 35: Royal
    // -------------------------------------------------------------------------
    GifterMilestone(
      level: 35,
      tierName: 'Royal Gifter',
      starsThresholdPlaceholder: 250000,
      bracket: GifterTierBracket.royal,
      description: 'Regal distinction with royal profile animation and live room honors.',
      rewards: [
        GifterReward(
          name: 'Royal Profile Frame',
          category: GifterRewardCategory.profileFrame,
          description: 'Imperial amethyst & gold filigree frame topped with a royal crown.',
        ),
        GifterReward(
          name: 'Royal Level Badge',
          category: GifterRewardCategory.levelBadge,
          description: 'Purple and gold royal crest badge with jewel ornaments.',
        ),
        GifterReward(
          name: 'Exclusive Profile Animation',
          category: GifterRewardCategory.profileEffect,
          description: 'Floating royal crowns and starlight on your user profile.',
        ),
        GifterReward(
          name: 'Special Gifter Recognition in Live Rooms',
          category: GifterRewardCategory.liveRoomRecognition,
          description: 'VIP banner announcement and top-tier viewer list placement.',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // Level 40: Elite
    // -------------------------------------------------------------------------
    GifterMilestone(
      level: 40,
      tierName: 'Elite Gifter',
      starsThresholdPlaceholder: 500000,
      bracket: GifterTierBracket.elite,
      description: 'Elite status marked by exclusive entrance and official title.',
      rewards: [
        GifterReward(
          name: 'Elite Profile Frame',
          category: GifterRewardCategory.profileFrame,
          description: 'Fiery amber-gold neon frame with dual wings.',
        ),
        GifterReward(
          name: 'Elite Animated Badge',
          category: GifterRewardCategory.levelBadge,
          description: 'Glowing flame-edge badge with rotating inner core.',
        ),
        GifterReward(
          name: 'Exclusive Live Room Entrance Effect',
          category: GifterRewardCategory.entranceEffect,
          description: 'Full-screen amber shockwave entrance in live streams.',
        ),
        GifterReward(
          name: 'Special Gifter Title',
          category: GifterRewardCategory.specialTitle,
          description: 'Official "Elite Gifter" moniker on your profile & room list.',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // Level 41: Elite Plus
    // -------------------------------------------------------------------------
    GifterMilestone(
      level: 41,
      tierName: 'Elite Plus Gifter',
      starsThresholdPlaceholder: 700000,
      bracket: GifterTierBracket.elitePlus,
      description: 'Upgraded elite radiance with enhanced profile effects.',
      rewards: [
        GifterReward(
          name: 'Elite Plus Profile Frame',
          category: GifterRewardCategory.profileFrame,
          description: 'Enhanced neon ruby-amber border with pulsing energy spikes.',
        ),
        GifterReward(
          name: 'Special Animated Badge',
          category: GifterRewardCategory.levelBadge,
          description: 'Dynamic animated badge with neon pulse waves.',
        ),
        GifterReward(
          name: 'Premium Profile Effect',
          category: GifterRewardCategory.profileEffect,
          description: 'Continuous atmospheric flame particles across your profile.',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // Level 42: Royal Elite
    // -------------------------------------------------------------------------
    GifterMilestone(
      level: 42,
      tierName: 'Royal Elite Gifter',
      starsThresholdPlaceholder: 950000,
      bracket: GifterTierBracket.royalElite,
      description: 'Fusion of royalty and elite prowess with special entrance.',
      rewards: [
        GifterReward(
          name: 'Royal Elite Profile Frame',
          category: GifterRewardCategory.profileFrame,
          description: 'Majestic purple velvet & gold frame with royal crest inlays.',
        ),
        GifterReward(
          name: 'Exclusive Royal Badge',
          category: GifterRewardCategory.levelBadge,
          description: 'Regal golden badge with deep violet amethyst jewel.',
        ),
        GifterReward(
          name: 'Special Entrance Animation',
          category: GifterRewardCategory.entranceEffect,
          description: 'Royal purple carpet and golden spark entry banner.',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // Level 43: Legendary
    // -------------------------------------------------------------------------
    GifterMilestone(
      level: 43,
      tierName: 'Legendary Gifter',
      starsThresholdPlaceholder: 1300000,
      bracket: GifterTierBracket.legendary,
      description: 'Legendary standing that commands attention across all rooms.',
      rewards: [
        GifterReward(
          name: 'Legendary Profile Frame',
          category: GifterRewardCategory.profileFrame,
          description: 'Crimson-gold cosmic halo frame with celestial star bursts.',
        ),
        GifterReward(
          name: 'Legendary Animated Badge',
          category: GifterRewardCategory.levelBadge,
          description: 'Animated blazing star badge with continuous light flares.',
        ),
        GifterReward(
          name: 'Exclusive Live Room Entrance Effect',
          category: GifterRewardCategory.entranceEffect,
          description: 'Meteor strike entrance with screen-wide fanfare.',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // Level 44: Legendary Plus
    // -------------------------------------------------------------------------
    GifterMilestone(
      level: 44,
      tierName: 'Legendary Plus Gifter',
      starsThresholdPlaceholder: 1800000,
      bracket: GifterTierBracket.legendaryPlus,
      description: 'Transcendent legendary status with exclusive profile decoration.',
      rewards: [
        GifterReward(
          name: 'Legendary Plus Profile Frame',
          category: GifterRewardCategory.profileFrame,
          description: 'Double-tier crimson and gold frame with radiant solar flares.',
        ),
        GifterReward(
          name: 'Premium Animated Badge',
          category: GifterRewardCategory.levelBadge,
          description: 'Pulsing stellar core badge with revolving energy rings.',
        ),
        GifterReward(
          name: 'Exclusive Profile Decoration',
          category: GifterRewardCategory.profileEffect,
          description: 'Custom legendary banner theme and sparkling avatar backdrop.',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // Level 45: Master
    // -------------------------------------------------------------------------
    GifterMilestone(
      level: 45,
      tierName: 'Master Gifter',
      starsThresholdPlaceholder: 2500000,
      bracket: GifterTierBracket.master,
      description: 'Master echelon ranking with celebrated room recognition.',
      rewards: [
        GifterReward(
          name: 'Master Profile Frame',
          category: GifterRewardCategory.profileFrame,
          description: 'Cosmic violet-cyan vortex frame with rotating astral diamonds.',
        ),
        GifterReward(
          name: 'Master Gifter Badge',
          category: GifterRewardCategory.levelBadge,
          description: 'Master crest badge with cyan glow and animated level numerals.',
        ),
        GifterReward(
          name: 'Special Live Room Recognition',
          category: GifterRewardCategory.liveRoomRecognition,
          description: 'Master viewer spotlight badge and pinned chat introduction.',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // Level 46: Grand Master
    // -------------------------------------------------------------------------
    GifterMilestone(
      level: 46,
      tierName: 'Grand Master Gifter',
      starsThresholdPlaceholder: 3500000,
      bracket: GifterTierBracket.grandMaster,
      description: 'Grand Master authority with high-impact entrance and framing.',
      rewards: [
        GifterReward(
          name: 'Grand Master Profile Frame',
          category: GifterRewardCategory.profileFrame,
          description: 'Deep violet aura frame surrounded by emerald-neon stardust.',
        ),
        GifterReward(
          name: 'Exclusive Animated Badge',
          category: GifterRewardCategory.levelBadge,
          description: 'Vortex animated badge with rotating energy ribbons.',
        ),
        GifterReward(
          name: 'Premium Entrance Effect',
          category: GifterRewardCategory.entranceEffect,
          description: 'Hyperdrive entrance animation lighting up the stream stage.',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // Level 47: Supreme
    // -------------------------------------------------------------------------
    GifterMilestone(
      level: 47,
      tierName: 'Supreme Gifter',
      starsThresholdPlaceholder: 5000000,
      bracket: GifterTierBracket.supreme,
      description: 'Supreme dominance featuring full profile animation suite.',
      rewards: [
        GifterReward(
          name: 'Supreme Profile Frame',
          category: GifterRewardCategory.profileFrame,
          description: 'Imperial gold & magenta crown frame with floating runes.',
        ),
        GifterReward(
          name: 'Supreme Gifter Badge',
          category: GifterRewardCategory.levelBadge,
          description: 'Supreme diamond-shaped badge with multi-color neon aura.',
        ),
        GifterReward(
          name: 'Exclusive Profile Animation',
          category: GifterRewardCategory.profileEffect,
          description: 'Aura of supremacy radiating across your complete profile screen.',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // Level 48: Royal Supreme
    // -------------------------------------------------------------------------
    GifterMilestone(
      level: 48,
      tierName: 'Royal Supreme Gifter',
      starsThresholdPlaceholder: 7000000,
      bracket: GifterTierBracket.royalSupreme,
      description: 'Apex nobility with royal entrance sequence and badge.',
      rewards: [
        GifterReward(
          name: 'Royal Supreme Profile Frame',
          category: GifterRewardCategory.profileFrame,
          description: 'Dual-gold imperial throne frame adorned with royal diamonds.',
        ),
        GifterReward(
          name: 'Special Royal Animated Badge',
          category: GifterRewardCategory.levelBadge,
          description: 'Regal animated crown badge that shines with prismatic light.',
        ),
        GifterReward(
          name: 'Exclusive Live Room Entrance Effect',
          category: GifterRewardCategory.entranceEffect,
          description: 'Chariot of stars entrance animation seen by all viewers.',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // Level 49: Mythical
    // -------------------------------------------------------------------------
    GifterMilestone(
      level: 49,
      tierName: 'Mythical Gifter',
      starsThresholdPlaceholder: 10000000,
      bracket: GifterTierBracket.mythical,
      description: 'Mythical status on the verge of the ultimate pinnacle.',
      rewards: [
        GifterReward(
          name: 'Mythical Profile Frame',
          category: GifterRewardCategory.profileFrame,
          description: 'Phoenix flame and dragon-scale gold frame with radiant halo.',
        ),
        GifterReward(
          name: 'Mythical Animated Badge',
          category: GifterRewardCategory.levelBadge,
          description: 'Blazing mythical emblem with continuous phoenix wings animation.',
        ),
        GifterReward(
          name: 'Premium Entrance Animation',
          category: GifterRewardCategory.entranceEffect,
          description: 'Phoenix descent animation announcing your live room arrival.',
        ),
      ],
    ),

    // -------------------------------------------------------------------------
    // Level 50: Ultimate Legend
    // -------------------------------------------------------------------------
    GifterMilestone(
      level: 50,
      tierName: 'Ultimate Legend',
      starsThresholdPlaceholder: 15000000,
      bracket: GifterTierBracket.ultimateLegend,
      description: 'The supreme pinnacle of Tivoo gifters. Total transcendence and universal prestige.',
      rewards: [
        GifterReward(
          name: 'Ultimate Legend Profile Frame',
          category: GifterRewardCategory.profileFrame,
          description: 'Pinnacle prismatic gold frame with multi-layered celestial crown.',
        ),
        GifterReward(
          name: 'Exclusive Level 50 Animated Badge',
          category: GifterRewardCategory.levelBadge,
          description: 'The legendary Level 50 badge radiating multi-spectral aurora.',
        ),
        GifterReward(
          name: 'Special Full Entrance Animation',
          category: GifterRewardCategory.entranceEffect,
          description: 'Cinematic full-screen entrance that pauses stage action with trumpets and fireworks.',
        ),
        GifterReward(
          name: 'Exclusive Profile Effects',
          category: GifterRewardCategory.profileEffect,
          description: 'Full-bleed mythic aurora and golden constellation backdrops.',
        ),
        GifterReward(
          name: 'Top-Level Gifter Recognition',
          category: GifterRewardCategory.liveRoomRecognition,
          description: 'Permanent top seat #1 honor badge across all platform live streams.',
        ),
        GifterReward(
          name: 'Special Level 50 Achievement Reward',
          category: GifterRewardCategory.achievement,
          description: 'The immortal "Ultimate Legend" trophy on profile and Hall of Fame.',
        ),
      ],
    ),
  ];

  /// Calculates a simulated user status given a specific level.
  static GifterUserStatus computeStatusForLevel({
    required int level,
    int? customStarsSpent,
  }) {
    // Find the highest milestone unlocked
    final currentMilestone = milestones
        .where((m) => m.level <= level)
        .fold<GifterMilestone>(
          milestones.first,
          (prev, curr) => curr.level > prev.level ? curr : prev,
        );

    // Find the next milestone
    final nextMilestone = milestones.cast<GifterMilestone?>().firstWhere(
          (m) => m!.level > level,
          orElse: () => null,
        );

    final currentThreshold = currentMilestone.starsThresholdPlaceholder;
    final nextThreshold = nextMilestone?.starsThresholdPlaceholder ?? currentThreshold;

    int spent;
    if (customStarsSpent != null) {
      spent = customStarsSpent;
    } else if (nextMilestone != null) {
      // Interpolate realistic progress for demo
      final span = nextThreshold - currentThreshold;
      spent = currentThreshold + (span * 0.65).round();
    } else {
      spent = currentThreshold + 1000000;
    }

    final int starsNeeded;
    final double progress;

    if (nextMilestone == null) {
      starsNeeded = 0;
      progress = 1.0;
    } else {
      final range = nextThreshold - currentThreshold;
      final currentInTier = (spent - currentThreshold).clamp(0, range);
      progress = (currentInTier / range).clamp(0.0, 1.0);
      starsNeeded = (nextThreshold - spent).clamp(0, nextThreshold);
    }

    return GifterUserStatus(
      currentLevel: level,
      tierName: currentMilestone.tierName,
      starsSpentOnGifts: spent,
      purchasedStarsTotal: demoPurchasedStars,
      currentMilestone: currentMilestone,
      nextMilestone: nextMilestone,
      progressToNext: progress,
      starsNeededForNext: starsNeeded,
    );
  }
}

