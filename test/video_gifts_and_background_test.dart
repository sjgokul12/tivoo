import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivoo/core/constants/app_assets.dart';
import 'package:tivoo/core/services/gift_video_pool.dart';
import 'package:tivoo/core/widgets/animated_gradient_background.dart';
import 'package:tivoo/core/widgets/luxury_atmosphere_background.dart';
import 'package:tivoo/features/gift/gift_options.dart';
import 'package:tivoo/features/pk_battle/core/pk_common_widgets.dart';
import 'package:tivoo/features/pk_battle/core/pk_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Video Gifts Registration & Metadata Tests', () {
    test('All 4 video gifts exist in GiftCatalog.allGifts', () {
      final fox = GiftCatalog.findById('gift_video_fox');
      final dragon = GiftCatalog.findById('gift_video_dragon');
      final bunny = GiftCatalog.findById('gift_video_bunny');
      final target = GiftCatalog.findById('gift_video_target');

      expect(fox, isNotNull);
      expect(fox!.name, 'Kitsune Fox');
      expect(fox.diamonds, 8000);
      expect(fox.isVideo, isTrue);
      expect(fox.videoAssetPath, AppAssets.giftVideoFox);
      expect(fox.imageAssetPath, AppAssets.giftThumbFox);
      expect(fox.animationType, GiftAnimationType.kitsuneFox);

      expect(dragon, isNotNull);
      expect(dragon!.name, 'Celestial Dragon');
      expect(dragon.diamonds, 12000);
      expect(dragon.isVideo, isTrue);
      expect(dragon.videoAssetPath, AppAssets.giftVideoDragon);
      expect(dragon.imageAssetPath, AppAssets.giftThumbDragon);
      expect(dragon.animationType, GiftAnimationType.celestialDragon);

      expect(bunny, isNotNull);
      expect(bunny!.name, 'Love Bunny');
      expect(bunny.diamonds, 1500);
      expect(bunny.isVideo, isTrue);
      expect(bunny.videoAssetPath, AppAssets.giftVideoBunny);
      expect(bunny.imageAssetPath, AppAssets.giftThumbBunny);
      expect(bunny.animationType, GiftAnimationType.loveBunny);

      expect(target, isNotNull);
      expect(target!.name, 'Cupid Target');
      expect(target.diamonds, 800);
      expect(target.isVideo, isTrue);
      expect(target.videoAssetPath, AppAssets.giftVideoTarget);
      expect(target.imageAssetPath, AppAssets.giftThumbTarget);
      expect(target.animationType, GiftAnimationType.cupidTarget);
    });

    test('Video gifts are discoverable by name lookup', () {
      expect(GiftCatalog.findByName('Kitsune Fox'), isNotNull);
      expect(GiftCatalog.findByName('celestial dragon'), isNotNull);
      expect(GiftCatalog.findByName('love bunny'), isNotNull);
      expect(GiftCatalog.findByName('CUPID TARGET'), isNotNull);
    });

    test('Video gifts are correctly placed in category filters', () {
      final popular = GiftCatalog.filterByCategory('Popular');
      expect(popular.any((g) => g.id == 'gift_video_fox'), isTrue);
      expect(popular.any((g) => g.id == 'gift_video_dragon'), isTrue);
      expect(popular.any((g) => g.id == 'gift_video_bunny'), isTrue);
      expect(popular.any((g) => g.id == 'gift_video_target'), isTrue);

      final luxury = GiftCatalog.filterByCategory('Luxury');
      expect(luxury.any((g) => g.id == 'gift_video_fox'), isTrue);
      expect(luxury.any((g) => g.id == 'gift_video_dragon'), isTrue);

      final love = GiftCatalog.filterByCategory('Love');
      expect(love.any((g) => g.id == 'gift_video_bunny'), isTrue);
      expect(love.any((g) => g.id == 'gift_video_target'), isTrue);
    });

    test('GiftAnimationMeta registry contains definitions for all 4 video gifts with 8.0s duration', () {
      final foxMeta = GiftAnimationMeta.registry[GiftAnimationType.kitsuneFox];
      final dragonMeta = GiftAnimationMeta.registry[GiftAnimationType.celestialDragon];
      final bunnyMeta = GiftAnimationMeta.registry[GiftAnimationType.loveBunny];
      final targetMeta = GiftAnimationMeta.registry[GiftAnimationType.cupidTarget];

      expect(foxMeta, isNotNull);
      expect(dragonMeta, isNotNull);
      expect(bunnyMeta, isNotNull);
      expect(targetMeta, isNotNull);

      expect(foxMeta!.duration, const Duration(milliseconds: 8000));
      expect(dragonMeta!.duration, const Duration(milliseconds: 8000));
      expect(bunnyMeta!.duration, const Duration(milliseconds: 8000));
      expect(targetMeta!.duration, const Duration(milliseconds: 8000));
    });

    test('GiftVideoPool correctly normalizes path variations to canonical paths', () {
      expect(GiftVideoPool.normalizeKey('assets/new gift/video1.mp4'), AppAssets.giftVideoFox);
      expect(GiftVideoPool.normalizeKey('assets/gifts/video1_fox.mp4'), AppAssets.giftVideoFox);
      expect(GiftVideoPool.normalizeKey('assets/new gift/video2.mp4'), AppAssets.giftVideoDragon);
      expect(GiftVideoPool.normalizeKey('assets/gifts/video2_dragon.mp4'), AppAssets.giftVideoDragon);
      expect(GiftVideoPool.normalizeKey('assets/new gift/video3.mp4'), AppAssets.giftVideoBunny);
      expect(GiftVideoPool.normalizeKey('assets/gifts/video3_bunny.mp4'), AppAssets.giftVideoBunny);
      expect(GiftVideoPool.normalizeKey('assets/new gift/video4.mp4'), AppAssets.giftVideoTarget);
      expect(GiftVideoPool.normalizeKey('assets/gifts/video4_target.mp4'), AppAssets.giftVideoTarget);
    });

    test('PKBattleGiftData and PkDemoData map video gifts with scores and thumbnails', () {
      expect(PKBattleGiftData.quickGiftNames.contains('Kitsune Fox'), isTrue);
      expect(PKBattleGiftData.quickGiftNames.contains('Celestial Dragon'), isTrue);
      expect(PKBattleGiftData.giftImages['Kitsune Fox'], AppAssets.giftThumbFox);
      expect(PKBattleGiftData.giftImages['Celestial Dragon'], AppAssets.giftThumbDragon);
      expect(PKBattleGiftData.giftImages['Love Bunny'], AppAssets.giftThumbBunny);
      expect(PKBattleGiftData.giftImages['Cupid Target'], AppAssets.giftThumbTarget);

      expect(PkDemoData.giftValues['Kitsune Fox'], 8000);
      expect(PkDemoData.giftValues['Celestial Dragon'], 12000);
      expect(PkDemoData.giftValues['Love Bunny'], 1500);
      expect(PkDemoData.giftValues['Cupid Target'], 800);
    });

    test('Video files can be loaded from rootBundle', () async {
      final foxBytes = await rootBundle.load(AppAssets.giftVideoFox);
      expect(foxBytes.lengthInBytes, greaterThan(0));

      final dragonBytes = await rootBundle.load(AppAssets.giftVideoDragon);
      expect(dragonBytes.lengthInBytes, greaterThan(0));

      final bunnyBytes = await rootBundle.load(AppAssets.giftVideoBunny);
      expect(bunnyBytes.lengthInBytes, greaterThan(0));

      final targetBytes = await rootBundle.load(AppAssets.giftVideoTarget);
      expect(targetBytes.lengthInBytes, greaterThan(0));
    });
  });

  group('APK Background Video Widget Tests', () {
    testWidgets('PkBackdrop instantiates with video background configuration', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PkBackdrop(
              showVideo: false, // avoid actual platform video controller spawn in headless test
            ),
          ),
        ),
      );

      expect(find.byType(PkBackdrop), findsOneWidget);
    });

    testWidgets('LuxuryAtmosphereBackground instantiates properly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LuxuryAtmosphereBackground(
              showBackgroundVideo: false,
            ),
          ),
        ),
      );

      expect(find.byType(LuxuryAtmosphereBackground), findsOneWidget);
    });

    test('AnimatedGradientBackground properties initialize correctly', () {
      const bg = AnimatedGradientBackground(
        showVideo: true,
        videoAssetPath: AppAssets.giftVideoFox,
        videoOpacity: 0.4,
      );
      expect(bg.showVideo, isTrue);
      expect(bg.videoAssetPath, AppAssets.giftVideoFox);
      expect(bg.videoOpacity, 0.4);
    });
  });
}

