import 'package:flutter_test/flutter_test.dart';
import 'package:tivoo/features/gifter_level/data/mock_gifter_data.dart';
import 'package:tivoo/features/gifter_level/presentation/controllers/gifter_level_controller.dart';

void main() {
  group('Gifter Level System - Domain & Mock Data', () {
    test('contains exactly the 19 client-specified milestone levels', () {
      final expectedMilestones = [
        1, 5, 10, 15, 20, 25, 30, 35, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50,
      ];
      final actualLevels = MockGifterData.milestones.map((m) => m.level).toList();

      expect(actualLevels, equals(expectedMilestones));
      expect(MockGifterData.milestones.length, equals(19));
    });

    test('verifies exact client-specified reward names for milestones', () {
      final m1 = MockGifterData.milestones.firstWhere((m) => m.level == 1);
      expect(m1.rewards.any((r) => r.name == 'Basic Profile Frame'), isTrue);

      final m5 = MockGifterData.milestones.firstWhere((m) => m.level == 5);
      expect(m5.rewards.any((r) => r.name == 'Bronze Profile Frame'), isTrue);

      final m10 = MockGifterData.milestones.firstWhere((m) => m.level == 10);
      expect(m10.rewards.any((r) => r.name == 'Silver Profile Frame'), isTrue);

      final m15 = MockGifterData.milestones.firstWhere((m) => m.level == 15);
      expect(m15.rewards.any((r) => r.name == 'Gold Profile Frame'), isTrue);
      expect(m15.rewards.any((r) => r.name == 'Gold Level Badge'), isTrue);
      expect(m15.rewards.any((r) => r.name == 'Special Profile Effect'), isTrue);

      final m20 = MockGifterData.milestones.firstWhere((m) => m.level == 20);
      expect(m20.rewards.any((r) => r.name == 'Premium Gold Profile Frame'), isTrue);
      expect(m20.rewards.any((r) => r.name == 'Animated Level Badge'), isTrue);
      expect(m20.rewards.any((r) => r.name == 'Exclusive Gifter Entrance Effect'), isTrue);

      final m25 = MockGifterData.milestones.firstWhere((m) => m.level == 25);
      expect(m25.rewards.any((r) => r.name == 'Platinum Profile Frame'), isTrue);
      expect(m25.rewards.any((r) => r.name == 'Platinum Level Badge'), isTrue);
      expect(m25.rewards.any((r) => r.name == 'Premium Chat Recognition'), isTrue);

      final m30 = MockGifterData.milestones.firstWhere((m) => m.level == 30);
      expect(m30.rewards.any((r) => r.name == 'Diamond Profile Frame'), isTrue);
      expect(m30.rewards.any((r) => r.name == 'Animated Diamond Badge'), isTrue);
      expect(m30.rewards.any((r) => r.name == 'Special Live Room Entrance Effect'), isTrue);

      final m35 = MockGifterData.milestones.firstWhere((m) => m.level == 35);
      expect(m35.rewards.any((r) => r.name == 'Royal Profile Frame'), isTrue);
      expect(m35.rewards.any((r) => r.name == 'Royal Level Badge'), isTrue);
      expect(m35.rewards.any((r) => r.name == 'Exclusive Profile Animation'), isTrue);
      expect(m35.rewards.any((r) => r.name == 'Special Gifter Recognition in Live Rooms'), isTrue);

      final m40 = MockGifterData.milestones.firstWhere((m) => m.level == 40);
      expect(m40.rewards.any((r) => r.name == 'Elite Profile Frame'), isTrue);
      expect(m40.rewards.any((r) => r.name == 'Elite Animated Badge'), isTrue);
      expect(m40.rewards.any((r) => r.name == 'Exclusive Live Room Entrance Effect'), isTrue);
      expect(m40.rewards.any((r) => r.name == 'Special Gifter Title'), isTrue);

      final m41 = MockGifterData.milestones.firstWhere((m) => m.level == 41);
      expect(m41.rewards.any((r) => r.name == 'Elite Plus Profile Frame'), isTrue);
      expect(m41.rewards.any((r) => r.name == 'Special Animated Badge'), isTrue);
      expect(m41.rewards.any((r) => r.name == 'Premium Profile Effect'), isTrue);

      final m42 = MockGifterData.milestones.firstWhere((m) => m.level == 42);
      expect(m42.rewards.any((r) => r.name == 'Royal Elite Profile Frame'), isTrue);
      expect(m42.rewards.any((r) => r.name == 'Exclusive Royal Badge'), isTrue);
      expect(m42.rewards.any((r) => r.name == 'Special Entrance Animation'), isTrue);

      final m43 = MockGifterData.milestones.firstWhere((m) => m.level == 43);
      expect(m43.rewards.any((r) => r.name == 'Legendary Profile Frame'), isTrue);
      expect(m43.rewards.any((r) => r.name == 'Legendary Animated Badge'), isTrue);
      expect(m43.rewards.any((r) => r.name == 'Exclusive Live Room Entrance Effect'), isTrue);

      final m44 = MockGifterData.milestones.firstWhere((m) => m.level == 44);
      expect(m44.rewards.any((r) => r.name == 'Legendary Plus Profile Frame'), isTrue);
      expect(m44.rewards.any((r) => r.name == 'Premium Animated Badge'), isTrue);
      expect(m44.rewards.any((r) => r.name == 'Exclusive Profile Decoration'), isTrue);

      final m45 = MockGifterData.milestones.firstWhere((m) => m.level == 45);
      expect(m45.rewards.any((r) => r.name == 'Master Profile Frame'), isTrue);
      expect(m45.rewards.any((r) => r.name == 'Master Gifter Badge'), isTrue);
      expect(m45.rewards.any((r) => r.name == 'Special Live Room Recognition'), isTrue);

      final m46 = MockGifterData.milestones.firstWhere((m) => m.level == 46);
      expect(m46.rewards.any((r) => r.name == 'Grand Master Profile Frame'), isTrue);
      expect(m46.rewards.any((r) => r.name == 'Exclusive Animated Badge'), isTrue);
      expect(m46.rewards.any((r) => r.name == 'Premium Entrance Effect'), isTrue);

      final m47 = MockGifterData.milestones.firstWhere((m) => m.level == 47);
      expect(m47.rewards.any((r) => r.name == 'Supreme Profile Frame'), isTrue);
      expect(m47.rewards.any((r) => r.name == 'Supreme Gifter Badge'), isTrue);
      expect(m47.rewards.any((r) => r.name == 'Exclusive Profile Animation'), isTrue);

      final m48 = MockGifterData.milestones.firstWhere((m) => m.level == 48);
      expect(m48.rewards.any((r) => r.name == 'Royal Supreme Profile Frame'), isTrue);
      expect(m48.rewards.any((r) => r.name == 'Special Royal Animated Badge'), isTrue);
      expect(m48.rewards.any((r) => r.name == 'Exclusive Live Room Entrance Effect'), isTrue);

      final m49 = MockGifterData.milestones.firstWhere((m) => m.level == 49);
      expect(m49.rewards.any((r) => r.name == 'Mythical Profile Frame'), isTrue);
      expect(m49.rewards.any((r) => r.name == 'Mythical Animated Badge'), isTrue);
      expect(m49.rewards.any((r) => r.name == 'Premium Entrance Animation'), isTrue);

      final m50 = MockGifterData.milestones.firstWhere((m) => m.level == 50);
      expect(m50.rewards.any((r) => r.name == 'Ultimate Legend Profile Frame'), isTrue);
      expect(m50.rewards.any((r) => r.name == 'Exclusive Level 50 Animated Badge'), isTrue);
      expect(m50.rewards.any((r) => r.name == 'Special Full Entrance Animation'), isTrue);
      expect(m50.rewards.any((r) => r.name == 'Exclusive Profile Effects'), isTrue);
      expect(m50.rewards.any((r) => r.name == 'Top-Level Gifter Recognition'), isTrue);
      expect(m50.rewards.any((r) => r.name == 'Special Level 50 Achievement Reward'), isTrue);
    });

    test('keeps purchased stars and eligible spent stars conceptually separate', () {
      final status = MockGifterData.computeStatusForLevel(level: 18);
      expect(status.purchasedStarsTotal, isNot(equals(status.starsSpentOnGifts)));
      expect(status.currentMilestone.level, equals(15));
      expect(status.nextMilestone?.level, equals(20));
      expect(status.progressToNext, greaterThan(0.0));
      expect(status.progressToNext, lessThanOrEqualTo(1.0));
    });

    test('reaches max level at level 50 with null next milestone', () {
      final status = MockGifterData.computeStatusForLevel(level: 50);
      expect(status.currentMilestone.level, equals(50));
      expect(status.nextMilestone, isNull);
      expect(status.progressToNext, equals(1.0));
      expect(status.starsNeededForNext, equals(0));
    });
  });

  group('Gifter Level System - Controller & State', () {
    test('filters milestones correctly', () {
      final controller = GifterLevelController();
      controller.setDemoLevel(18);

      expect(controller.state.filteredMilestones.length, equals(19));
      expect(controller.state.unlockedCount, equals(4)); // Lv 1, 5, 10, 15
      expect(controller.state.lockedCount, equals(15));

      controller.setFilter(MilestoneFilter.unlocked);
      expect(controller.state.filteredMilestones.length, equals(4));

      controller.setFilter(MilestoneFilter.locked);
      expect(controller.state.filteredMilestones.length, equals(15));

      controller.setFilter(MilestoneFilter.all);
      expect(controller.state.filteredMilestones.length, equals(19));
    });

    test('switches demo levels and updates status', () {
      final controller = GifterLevelController();
      controller.setDemoLevel(30);

      expect(controller.state.userStatus.currentLevel, equals(30));
      expect(controller.state.userStatus.currentMilestone.level, equals(30));
      expect(controller.state.userStatus.nextMilestone?.level, equals(35));
      expect(controller.state.unlockedCount, equals(7)); // 1, 5, 10, 15, 20, 25, 30
    });
  });
}
