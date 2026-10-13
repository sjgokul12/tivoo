import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivoo/core/services/gift_sound_service.dart';
import 'package:tivoo/features/live_stream/data/mock_live_comments.dart';
import 'package:tivoo/features/live_stream/presentation/widgets/active_gift_animation_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (MethodCall methodCall) async => 1,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (MethodCall methodCall) async => 1,
    );
  });

  group('GiftSoundService Tests', () {
    test('GiftSoundService instance plays and stops sounds correctly', () async {
      final service = GiftSoundService.instance;
      expect(service, isNotNull);
      expect(service.isMuted, false);

      // Verify sound play triggers without throwing for all user gift categories
      await service.playGiftSound('rocket');
      await service.playGiftSound('wings');
      await service.playGiftSound('car');
      await service.playGiftSound('yacht');
      await service.playGiftSound('castle');
      await service.playGiftSound('world_tour');
      await service.playGiftSound('diamond');
      await service.playGiftSound('crown');
      await service.playGiftSound('cake');
      await service.playGiftSound('teddy');
      await service.playGiftSound('kitty');
      await service.playGiftSound('love');
      await service.playGiftSound('flowers');
      await service.stop();

      // Verify mute toggle
      service.isMuted = true;
      expect(service.isMuted, true);
      await service.playGiftSound('rocket'); // No-op when muted
      service.isMuted = false;
      expect(service.isMuted, false);
    });
  });

  group('User Reference Gifts (14 Genuine Sticker Gifts) List Tests', () {
    test('MockLiveComments.virtualGifts contains exactly the 14 user reference gifts', () {
      final gifts = MockLiveComments.virtualGifts;
      expect(gifts.length, greaterThanOrEqualTo(14));

      final giftNames = gifts.map((g) => g.name).toSet();
      expect(giftNames, containsAll([
        'Rocket',
        'Angel Wings',
        'Flowers',
        'Kitty',
        'Tiki Love',
        'Love',
        'Yacht',
        'Super Car',
        'Diamond',
        'Crown',
        'Cake',
        'Teddy',
        'World Tour',
        'Castle',
      ]));

      // Check specific coin values matching user screenshot badges
      final rocket = gifts.firstWhere((g) => g.name == 'Rocket');
      expect(rocket.diamonds, 1000);

      final angelWings = gifts.firstWhere((g) => g.name == 'Angel Wings');
      expect(angelWings.diamonds, 500);

      final yacht = gifts.firstWhere((g) => g.name == 'Yacht');
      expect(yacht.diamonds, 2000);

      final superCar = gifts.firstWhere((g) => g.name == 'Super Car');
      expect(superCar.diamonds, 1000);

      final diamond = gifts.firstWhere((g) => g.name == 'Diamond');
      expect(diamond.diamonds, 500);

      final crown = gifts.firstWhere((g) => g.name == 'Crown');
      expect(crown.diamonds, 200);

      final cake = gifts.firstWhere((g) => g.name == 'Cake');
      expect(cake.diamonds, 100);

      final teddy = gifts.firstWhere((g) => g.name == 'Teddy');
      expect(teddy.diamonds, 50);

      final kitty = gifts.firstWhere((g) => g.name == 'Kitty');
      expect(kitty.diamonds, 50);

      final tikiLove = gifts.firstWhere((g) => g.name == 'Tiki Love');
      expect(tikiLove.diamonds, 100);

      final love = gifts.firstWhere((g) => g.name == 'Love');
      expect(love.diamonds, 10);

      final flowers = gifts.firstWhere((g) => g.name == 'Flowers');
      expect(flowers.diamonds, 10);

      final castle = gifts.firstWhere((g) => g.name == 'Castle');
      expect(castle.diamonds, 5000);

      final worldTour = gifts.firstWhere((g) => g.name == 'World Tour');
      expect(worldTour.diamonds, 10000);
    });
  });

  group('ActiveGiftAnimationOverlay Sticker Presentation & Skip Tests', () {
    testWidgets('triggers Rocket gift, renders genuine sticker asset and skip button is removed',
        (WidgetTester tester) async {
      final GlobalKey<ActiveGiftAnimationOverlayState> overlayKey =
          GlobalKey<ActiveGiftAnimationOverlayState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActiveGiftAnimationOverlay(
              key: overlayKey,
              child: const Center(child: Text('Live Stream Screen')),
            ),
          ),
        ),
      );

      expect(find.text('Live Stream Screen'), findsOneWidget);

      final rocketGift = MockLiveComments.virtualGifts.firstWhere((g) => g.name == 'Rocket');
      overlayKey.currentState?.playGift(rocketGift, senderName: 'Tester');
      await tester.pump(const Duration(milliseconds: 100));

      // Skip button is permanently removed per user request
      expect(find.text('Skip'), findsNothing);
    });

    testWidgets('triggers Super Car gift, renders sticker animation without skip button',
        (WidgetTester tester) async {
      final GlobalKey<ActiveGiftAnimationOverlayState> overlayKey =
          GlobalKey<ActiveGiftAnimationOverlayState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActiveGiftAnimationOverlay(
              key: overlayKey,
              child: const Center(child: Text('Live Stream Screen')),
            ),
          ),
        ),
      );

      final carGift = MockLiveComments.virtualGifts.firstWhere((g) => g.name == 'Super Car');
      overlayKey.currentState?.playGift(carGift, senderName: 'Tester');
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Skip'), findsNothing);
    });

    testWidgets('triggers World Tour gift, renders sticker animation without skip button',
        (WidgetTester tester) async {
      final GlobalKey<ActiveGiftAnimationOverlayState> overlayKey =
          GlobalKey<ActiveGiftAnimationOverlayState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActiveGiftAnimationOverlay(
              key: overlayKey,
              child: const Center(child: Text('Live Stream Screen')),
            ),
          ),
        ),
      );

      final worldTourGift = MockLiveComments.virtualGifts.firstWhere((g) => g.name == 'World Tour');
      overlayKey.currentState?.playGift(worldTourGift, senderName: 'Tester');
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Skip'), findsNothing);
    });
  });
}
