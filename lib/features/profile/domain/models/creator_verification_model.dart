/// Tiki Creator Verification Tiers:
/// - White Tiki (⚪): Beginner Creator tier awarded after profile & authentic video conditions.
/// - Gray Tiki (🔘): Advanced Creator tier awarded after reaching 500+ views in 1 month.
/// - Only Gray Tiki verified creators can create a Family Team as Leader.
enum TikiBadgeTier { none, whiteTiki, grayTiki }

class CreatorVerificationModel {
  final TikiBadgeTier badgeTier;
  final int currentViews;
  final int targetViews;
  final int daysRemaining;
  final int qualityVideosCount;
  final bool hasWhiteTiki;
  final bool hasGrayTiki;
  final String? familyId;
  final String? familyName;
  final bool isFamilyLeader;

  const CreatorVerificationModel({
    this.badgeTier = TikiBadgeTier.whiteTiki,
    this.currentViews = 500,
    this.targetViews = 500,
    this.daysRemaining = 24,
    this.qualityVideosCount = 5,
    this.hasWhiteTiki = true,
    this.hasGrayTiki = true,
    this.familyId = 'family_rs_tech',
    this.familyName = 'RS TECH',
    this.isFamilyLeader = true,
  });

  bool get isTargetAchieved => currentViews >= targetViews;
  bool get canCreateFamily => hasGrayTiki;

  double get progressRatio => (currentViews / targetViews).clamp(0.0, 1.0);

  CreatorVerificationModel copyWith({
    TikiBadgeTier? badgeTier,
    int? currentViews,
    int? targetViews,
    int? daysRemaining,
    int? qualityVideosCount,
    bool? hasWhiteTiki,
    bool? hasGrayTiki,
    String? familyId,
    String? familyName,
    bool? isFamilyLeader,
  }) {
    return CreatorVerificationModel(
      badgeTier: badgeTier ?? this.badgeTier,
      currentViews: currentViews ?? this.currentViews,
      targetViews: targetViews ?? this.targetViews,
      daysRemaining: daysRemaining ?? this.daysRemaining,
      qualityVideosCount: qualityVideosCount ?? this.qualityVideosCount,
      hasWhiteTiki: hasWhiteTiki ?? this.hasWhiteTiki,
      hasGrayTiki: hasGrayTiki ?? this.hasGrayTiki,
      familyId: familyId ?? this.familyId,
      familyName: familyName ?? this.familyName,
      isFamilyLeader: isFamilyLeader ?? this.isFamilyLeader,
    );
  }
}
