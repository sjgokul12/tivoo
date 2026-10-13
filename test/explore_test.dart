import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivoo/core/constants/app_assets.dart';
import 'package:tivoo/core/widgets/live_badge.dart';
import 'package:tivoo/features/explore/data/mock_explore_data.dart';
import 'package:tivoo/features/explore/presentation/screens/explore_screen.dart';
import 'package:tivoo/features/explore/presentation/widgets/explore_stream_card.dart';
import 'package:visibility_detector/visibility_detector.dart';

void main() {
  setUp(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  test('MockExploreData verifies all 5 live streams have unique videos without repetition', () {
    final streams = MockExploreData.exploreStreams;
    expect(streams.length, 5);

    expect(streams[0].videoAssetPath, AppAssets.video1);
    expect(streams[1].videoAssetPath, AppAssets.video2);
    expect(streams[2].videoAssetPath, AppAssets.video3);
    expect(streams[3].videoAssetPath, AppAssets.video4);
    expect(streams[4].videoAssetPath, AppAssets.video5);

    final videoPaths = streams.map((s) => s.videoAssetPath).toSet();
    expect(videoPaths.length, 5, reason: 'All 5 videos must be unique and non-repeating');
  });

  testWidgets('ExploreScreen renders Reels Feed by default and toggles to Grid', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360 * 2, 740 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ExploreScreen(),
        ),
      ),
    );
    await tester.pump();

    // Verify Explore title & reels subtitle
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('Swipe to discover reels'), findsOneWidget);

    // Verify User Account Wallet pill is present showing balance
    expect(find.text('1M'), findsOneWidget);

    // Verify category tabs are removed (All, Trending, Gaming, Art, etc.)
    expect(find.text('All'), findsNothing);
    expect(find.text('Trending'), findsNothing);
    expect(find.text('Gaming'), findsNothing);
    expect(find.text('Art'), findsNothing);

    // In Reels mode, PageView is vertical
    final pageViewFinder = find.byType(PageView);
    expect(pageViewFinder, findsOneWidget);
    final pageView = tester.widget<PageView>(pageViewFinder);
    expect(pageView.scrollDirection, Axis.vertical);

    // First stream is Lena Rivers
    expect(find.text('Lena Rivers'), findsOneWidget);
    expect(find.text('REEL'), findsOneWidget);

    // Verify prominent Follow button is present on the reel card
    expect(find.text('Follow'), findsWidgets);

    // Verify LIVE badge is removed from Explore screen reels
    expect(find.byType(LiveBadge), findsNothing);

    // Find the view mode toggle button (grid icon when in reels view)
    final gridToggleFinder = find.byIcon(Icons.grid_view_rounded);
    expect(gridToggleFinder, findsOneWidget);

    // Tap toggle button to switch to Grid view
    await tester.tap(gridToggleFinder);
    await tester.pump(const Duration(milliseconds: 300));

    // Now in Grid view
    expect(find.text('Discover amazing reels'), findsOneWidget);
    expect(find.byType(ExploreStreamCard), findsWidgets);
    expect(find.byType(PageView), findsNothing);

    // Tap toggle button to switch back to Reels view
    final reelsToggleFinder = find.byIcon(Icons.slideshow_rounded);
    expect(reelsToggleFinder, findsOneWidget);
    await tester.tap(reelsToggleFinder);
    await tester.pump(const Duration(milliseconds: 300));

    // Back in Reels view
    expect(find.byType(PageView), findsOneWidget);
  });
}
