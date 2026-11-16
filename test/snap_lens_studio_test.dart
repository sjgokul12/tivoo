import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivoo/features/broadcast/domain/models/camera_filter_model.dart';
import 'package:tivoo/features/broadcast/presentation/widgets/filter_overlay_widget.dart';
import 'package:tivoo/features/video_creator/domain/models/video_creation_state.dart';
import 'package:tivoo/features/video_creator/presentation/widgets/snap_lens_carousel.dart';
import 'package:tivoo/features/video_creator/presentation/widgets/snap_lens_studio_sheet.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Snap Lens Studio Models & Catalog Tests', () {
    test('MockFilterData contains all Snap Lens Studio AR lenses', () {
      final filters = MockFilterData.allFilters;
      expect(filters.isNotEmpty, isTrue);

      final dogFace = filters.firstWhere((f) => f.id == 'dog');
      final animeCat = filters.firstWhere((f) => f.id == 'cat');
      final butterfly = filters.firstWhere((f) => f.id == 'butterfly');
      final bunny = filters.firstWhere((f) => f.id == 'bunny');
      final angel = filters.firstWhere((f) => f.id == 'angel');
      final cyber = filters.firstWhere((f) => f.id == 'style');
      final crown = filters.firstWhere((f) => f.id == 'crown');
      final horns = filters.firstWhere((f) => f.id == 'devil');
      final flower = filters.firstWhere((f) => f.id == 'flowers');

      expect(dogFace.isSnapLens, isTrue);
      expect(dogFace.creator, 'Snap Lens Studio');
      expect(dogFace.overlayType, FilterOverlayType.dog);

      expect(animeCat.isSnapLens, isTrue);
      expect(animeCat.overlayType, FilterOverlayType.catAnime);

      expect(butterfly.isSnapLens, isTrue);
      expect(butterfly.overlayType, FilterOverlayType.butterfly);

      expect(bunny.isSnapLens, isTrue);
      expect(bunny.overlayType, FilterOverlayType.bunny);

      expect(angel.isSnapLens, isTrue);
      expect(angel.overlayType, FilterOverlayType.angelHalo);

      expect(cyber.isSnapLens, isTrue);
      expect(cyber.overlayType, FilterOverlayType.cyberGlasses);

      expect(crown.isSnapLens, isTrue);
      expect(crown.overlayType, FilterOverlayType.goldenCrown);

      expect(horns.isSnapLens, isTrue);
      expect(horns.overlayType, FilterOverlayType.devilHorns);

      expect(flower.isSnapLens, isTrue);
      expect(flower.overlayType, FilterOverlayType.flowerCrown);
    });

    test('All FilterOverlayType values are supported by FilterOverlayWidget', () {
      for (final type in FilterOverlayType.values) {
        final filter = CameraFilterModel(
          id: 'test_${type.name}',
          name: 'Test ${type.name}',
          category: FilterCategory.fun,
          overlayType: type,
          isSnapLens: true,
          creator: 'Lens Studio',
        );

        expect(() => FilterOverlayWidget(filter: filter), returnsNormally);
      }
    });

    test('VideoCreationState correctly holds and retains activeSnapLens', () {
      final lens = MockFilterData.allFilters.firstWhere((f) => f.id == 'dog');
      final dummyFile = File('dummy.mp4');

      final state = VideoCreationState(
        videoFile: dummyFile,
        activeSnapLens: lens,
      );

      expect(state.activeSnapLens, isNotNull);
      expect(state.activeSnapLens!.id, 'dog');
      expect(state.activeSnapLens!.name, 'Dog');
      expect(state.activeSnapLens!.isSnapLens, isTrue);
    });
  });

  group('Snap Lens Studio UI Widget Tests', () {
    testWidgets('FilterOverlayWidget renders without errors for animated lens', (tester) async {
      final lens = MockFilterData.allFilters.firstWhere((f) => f.id == 'dog');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              height: 640,
              child: FilterOverlayWidget(filter: lens),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(FilterOverlayWidget), findsOneWidget);

      // Clean up ticker before test finishes
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('SnapLensCarousel renders correctly with lens items', (tester) async {
      CameraFilterModel? selectedLens;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SnapLensCarousel(
              lenses: MockFilterData.allFilters,
              selectedLens: selectedLens,
              onSelectLens: (lens) => selectedLens = lens,
              onOpenStudio: () {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byType(SnapLensCarousel), findsOneWidget);
      expect(find.text('Snap Lens Studio'), findsOneWidget);
      expect(find.text('None'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('SnapLensStudioSheet renders correctly with categories and lenses', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SnapLensStudioSheet(
              selectedLens: null,
              onSelectLens: (_) {},
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(SnapLensStudioSheet), findsOneWidget);
      expect(find.text('SNAP LENS STUDIO'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });
  });
}
