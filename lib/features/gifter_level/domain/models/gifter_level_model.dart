import 'package:flutter/material.dart';

/// Categories of milestone rewards in the Gifter Level system.
enum GifterRewardCategory {
  profileFrame,
  levelBadge,
  entranceEffect,
  chatRecognition,
  profileEffect,
  specialTitle,
  liveRoomRecognition,
  achievement,
  placeholder,
}

extension GifterRewardCategoryX on GifterRewardCategory {
  String get label {
    switch (this) {
      case GifterRewardCategory.profileFrame:
        return 'Profile Frame';
      case GifterRewardCategory.levelBadge:
        return 'Level Badge';
      case GifterRewardCategory.entranceEffect:
        return 'Entrance Effect';
      case GifterRewardCategory.chatRecognition:
        return 'Chat Perk';
      case GifterRewardCategory.profileEffect:
        return 'Profile Effect';
      case GifterRewardCategory.specialTitle:
        return 'Special Title';
      case GifterRewardCategory.liveRoomRecognition:
        return 'Room Recognition';
      case GifterRewardCategory.achievement:
        return 'Achievement';
      case GifterRewardCategory.placeholder:
        return 'Upcoming Perk';
    }
  }

  IconData get icon {
    switch (this) {
      case GifterRewardCategory.profileFrame:
        return Icons.portrait_rounded;
      case GifterRewardCategory.levelBadge:
        return Icons.military_tech_rounded;
      case GifterRewardCategory.entranceEffect:
        return Icons.auto_awesome_rounded;
      case GifterRewardCategory.chatRecognition:
        return Icons.chat_bubble_rounded;
      case GifterRewardCategory.profileEffect:
        return Icons.flare_rounded;
      case GifterRewardCategory.specialTitle:
        return Icons.workspace_premium_rounded;
      case GifterRewardCategory.liveRoomRecognition:
        return Icons.campaign_rounded;
      case GifterRewardCategory.achievement:
        return Icons.emoji_events_rounded;
      case GifterRewardCategory.placeholder:
        return Icons.more_horiz_rounded;
    }
  }
}

/// A single reward granted when unlocking a milestone level.
class GifterReward {
  final String name;
  final GifterRewardCategory category;
  final String description;
  final bool isPlaceholder;

  const GifterReward({
    required this.name,
    required this.category,
    required this.description,
    this.isPlaceholder = false,
  });
}

/// Tier brackets for visual styling (frames, badges, glows).
enum GifterTierBracket {
  basic,
  bronze,
  silver,
  gold,
  premiumGold,
  platinum,
  diamond,
  royal,
  elite,
  elitePlus,
  royalElite,
  legendary,
  legendaryPlus,
  master,
  grandMaster,
  supreme,
  royalSupreme,
  mythical,
  ultimateLegend,
}

extension GifterTierBracketX on GifterTierBracket {
  /// Primary gradient used for badges and glowing borders.
  List<Color> get gradientColors {
    switch (this) {
      case GifterTierBracket.basic:
        return const [Color(0xFF9E9E9E), Color(0xFF616161), Color(0xFF424242)];
      case GifterTierBracket.bronze:
        return const [Color(0xFFE5A65D), Color(0xFFCD7F32), Color(0xFF8C531B)];
      case GifterTierBracket.silver:
        return const [Color(0xFFFFFFFF), Color(0xFFD6DBDF), Color(0xFFA6ACAF)];
      case GifterTierBracket.gold:
        return const [Color(0xFFFFEA80), Color(0xFFFFD700), Color(0xFFFF9A00)];
      case GifterTierBracket.premiumGold:
        return const [Color(0xFFFFF2A3), Color(0xFFFFC928), Color(0xFFE58000)];
      case GifterTierBracket.platinum:
        return const [Color(0xFFE8F0FE), Color(0xFFA4C2F4), Color(0xFF7BA4F5)];
      case GifterTierBracket.diamond:
        return const [Color(0xFFE0F7FA), Color(0xFF00E5FF), Color(0xFF651FFF)];
      case GifterTierBracket.royal:
        return const [Color(0xFFFFE57F), Color(0xFFE040FB), Color(0xFF7C4DFF)];
      case GifterTierBracket.elite:
        return const [Color(0xFFFFD54F), Color(0xFFFF6D00), Color(0xFFFF3D00)];
      case GifterTierBracket.elitePlus:
        return const [Color(0xFFFFEE58), Color(0xFFFF3D00), Color(0xFFD500F9)];
      case GifterTierBracket.royalElite:
        return const [Color(0xFFFFD700), Color(0xFF9C27B0), Color(0xFF6200EA)];
      case GifterTierBracket.legendary:
        return const [Color(0xFFFF80AB), Color(0xFFFF1744), Color(0xFFFF9100)];
      case GifterTierBracket.legendaryPlus:
        return const [Color(0xFFFF4081), Color(0xFFFF0055), Color(0xFFFFD600)];
      case GifterTierBracket.master:
        return const [Color(0xFFB388FF), Color(0xFF7C4DFF), Color(0xFF00E5FF)];
      case GifterTierBracket.grandMaster:
        return const [Color(0xFFE040FB), Color(0xFF651FFF), Color(0xFF00E676)];
      case GifterTierBracket.supreme:
        return const [Color(0xFFFFD700), Color(0xFFFF007F), Color(0xFF7C4DFF)];
      case GifterTierBracket.royalSupreme:
        return const [Color(0xFFFFF176), Color(0xFFAB47BC), Color(0xFF4A148C)];
      case GifterTierBracket.mythical:
        return const [Color(0xFFFF5252), Color(0xFFFF007F), Color(0xFFFFAB00)];
      case GifterTierBracket.ultimateLegend:
        return const [
          Color(0xFFFFF59D),
          Color(0xFFFFD700),
          Color(0xFFFF007F),
          Color(0xFF7C4DFF),
          Color(0xFF00E5FF),
        ];
    }
  }

  /// Ambient glow color for this tier.
  Color get glowColor {
    switch (this) {
      case GifterTierBracket.basic:
        return const Color(0x669E9E9E);
      case GifterTierBracket.bronze:
        return const Color(0x99CD7F32);
      case GifterTierBracket.silver:
        return const Color(0x99E0E0E0);
      case GifterTierBracket.gold:
      case GifterTierBracket.premiumGold:
        return const Color(0xAAFFC928);
      case GifterTierBracket.platinum:
        return const Color(0x9988C0D0);
      case GifterTierBracket.diamond:
        return const Color(0xAA00E5FF);
      case GifterTierBracket.royal:
      case GifterTierBracket.royalElite:
        return const Color(0xAAE040FB);
      case GifterTierBracket.elite:
      case GifterTierBracket.elitePlus:
        return const Color(0xAAFF6D00);
      case GifterTierBracket.legendary:
      case GifterTierBracket.legendaryPlus:
        return const Color(0xAAFF1744);
      case GifterTierBracket.master:
      case GifterTierBracket.grandMaster:
        return const Color(0xAA7C4DFF);
      case GifterTierBracket.supreme:
      case GifterTierBracket.royalSupreme:
        return const Color(0xAAFFD700);
      case GifterTierBracket.mythical:
        return const Color(0xAAFF007F);
      case GifterTierBracket.ultimateLegend:
        return const Color(0xCCFFD700);
    }
  }

  /// Badge jewel accent color.
  Color get jewelColor {
    switch (this) {
      case GifterTierBracket.basic:
        return const Color(0xFFB0BEC5);
      case GifterTierBracket.bronze:
        return const Color(0xFFFFB74D);
      case GifterTierBracket.silver:
        return const Color(0xFFECEFF1);
      case GifterTierBracket.gold:
      case GifterTierBracket.premiumGold:
        return const Color(0xFFFFD54F);
      case GifterTierBracket.platinum:
        return const Color(0xFFB3E5FC);
      case GifterTierBracket.diamond:
        return const Color(0xFF80D8FF);
      case GifterTierBracket.royal:
      case GifterTierBracket.royalElite:
        return const Color(0xFFEA80FC);
      case GifterTierBracket.elite:
      case GifterTierBracket.elitePlus:
        return const Color(0xFFFFAB40);
      case GifterTierBracket.legendary:
      case GifterTierBracket.legendaryPlus:
        return const Color(0xFFFF80AB);
      case GifterTierBracket.master:
      case GifterTierBracket.grandMaster:
        return const Color(0xFFB388FF);
      case GifterTierBracket.supreme:
      case GifterTierBracket.royalSupreme:
        return const Color(0xFFFFD700);
      case GifterTierBracket.mythical:
        return const Color(0xFFFF4081);
      case GifterTierBracket.ultimateLegend:
        return const Color(0xFFFFFFFF);
    }
  }
}

/// A milestone level definition with client-specified rewards.
class GifterMilestone {
  final int level;
  final String tierName;
  final int starsThresholdPlaceholder;
  final List<GifterReward> rewards;
  final GifterTierBracket bracket;
  final String description;

  const GifterMilestone({
    required this.level,
    required this.tierName,
    required this.starsThresholdPlaceholder,
    required this.rewards,
    required this.bracket,
    required this.description,
  });

  bool isUnlocked(int userLevel) => userLevel >= level;
  bool isCurrent(int userLevel, List<GifterMilestone> all) {
    // Find the highest milestone <= userLevel
    final highestUnlocked = all.where((m) => m.level <= userLevel).fold<GifterMilestone?>(
          null,
          (prev, curr) => (prev == null || curr.level > prev.level) ? curr : prev,
        );
    return highestUnlocked?.level == level;
  }
}

/// Aggregated user status for Gifter Level preview.
class GifterUserStatus {
  final int currentLevel;
  final String tierName;
  final int starsSpentOnGifts;
  final int purchasedStarsTotal;
  final GifterMilestone currentMilestone;
  final GifterMilestone? nextMilestone;
  final double progressToNext;
  final int starsNeededForNext;

  const GifterUserStatus({
    required this.currentLevel,
    required this.tierName,
    required this.starsSpentOnGifts,
    required this.purchasedStarsTotal,
    required this.currentMilestone,
    this.nextMilestone,
    required this.progressToNext,
    required this.starsNeededForNext,
  });
}

