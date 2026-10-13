import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivoo/features/home/presentation/screens/home_screen.dart';
import 'package:tivoo/features/pk_battle/pk_battle_live_screen.dart';
import 'package:tivoo/features/chat_room/chat_room_party_screen.dart';
import 'package:tivoo/features/home/presentation/widgets/home_grid_stream_card.dart';
import 'package:tivoo/features/home/presentation/widgets/popular_taalmil_view.dart';
import 'package:tivoo/features/live_stream/presentation/screens/live_stream_screen.dart';
import 'package:tivoo/features/live_stream/presentation/widgets/active_gift_animation_overlay.dart';
import 'package:tivoo/features/live_stream/data/mock_live_comments.dart';
import 'package:tivoo/features/home/data/mock_live_data.dart';
import 'package:visibility_detector/visibility_detector.dart';

void main() {
  setUp(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  Future<void> advanceAnimation(WidgetTester tester) async {
    for (int i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 70));
    }
  }

  testWidgets(
      'HomeScreen renders 3 tabs (Live, PK Battle, Chat Room) and verifies PK 10m/20m & Chat Room 9-Audio/6-Video modes',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    // 1. Verify 3 Category Tabs in Header
    expect(find.text('Live'), findsWidgets);
    expect(find.text('PK Battle'), findsWidgets);
    expect(find.text('Chat Room'), findsWidgets);

    // 2. Verify Search bar, heart, clock icons
    expect(find.text('Search'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
    expect(find.byIcon(Icons.access_time_rounded), findsOneWidget);

    // 3. Live Tab: 2-column grid cards (mini broadcasters and weekly all-stars removed)
    expect(find.byType(PopularTaalmilView), findsOneWidget);
    expect(find.byType(HomeGridStreamCard), findsWidgets);
    expect(find.text('aashi'), findsNothing);
    expect(find.text('payal'), findsNothing);
    expect(find.text('WEEKLY ALL-STARS'), findsNothing);

    // 4. Switch to PK Battle Tab (Index 1)
    await tester.tap(find.text('PK Battle').first);
    await advanceAnimation(tester);
    expect(find.byType(PkBattleLiveScreen), findsOneWidget);

    // Verify PK Screen: 10m & 20m Duration buttons, Invite button, Streamers, MVPs
    expect(find.text('10m'), findsOneWidget);
    expect(find.text('20m'), findsOneWidget);
    expect(find.text('Invite'), findsOneWidget);
    expect(find.text('Daisy 🥰'), findsWidgets);
    expect(find.text('Alex Martin'), findsOneWidget);
    expect(find.text('Elena Star'), findsOneWidget);
    expect(find.text('TOP MVPs'), findsOneWidget);

    // Tap 20m Duration button
    await tester.tap(find.text('20m'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('PK 20:00'), findsOneWidget);

    // 5. Switch to Chat Room Tab (Index 2)
    await tester.tap(find.text('Chat Room').first);
    await advanceAnimation(tester);
    expect(find.byType(ChatRoomPartyScreen), findsOneWidget);

    // Verify Chat Room: Host info, 9-seat audio mode, guidelines card
    expect(find.text('rohit_rajdhanis6'), findsWidgets);
    expect(find.text('Monthly Host'), findsOneWidget);
    expect(find.text('Audio Party (9 Seats)'), findsOneWidget);
    expect(find.text('NO.3'), findsOneWidget);
    expect(find.text('NO.4'), findsOneWidget);
    expect(find.textContaining('Welcome to Tiki Live'), findsOneWidget);

    // Toggle to Video Party (6 Members)
    await tester.tap(find.text('Video Party (6 Members)'));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('Rohit (Host)'), findsOneWidget);

    // 6. Switch back to Live Tab (Index 0)
    await tester.tap(find.text('Live').first);
    await advanceAnimation(tester);
    expect(find.byType(PopularTaalmilView), findsOneWidget);
  });

  testWidgets(
      'LiveStreamScreen renders downside live comments with separate Star and Gift buttons, and triggers active Super Car moving animation',
      (WidgetTester tester) async {
    final mockStreams = MockLiveData.liveStreams;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: LiveStreamScreen(
            streams: mockStreams,
            initialIndex: 0,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    // 1. Verify separate Star button and Gift button are both present on the SAME live screen
    expect(find.text('Star'), findsOneWidget);
    expect(find.text('Gift'), findsOneWidget);

    // 2. Verify downside live comments area is rendered
    expect(find.byIcon(Icons.star_rounded), findsWidgets);
    expect(find.byIcon(Icons.send_rounded), findsOneWidget);

    // 3. Verify ActiveGiftAnimationOverlay exists in tree
    expect(find.byType(ActiveGiftAnimationOverlay), findsOneWidget);

    // 4. Find ActiveGiftAnimationOverlayState and trigger Super Car gift
    final overlayState = tester.state<ActiveGiftAnimationOverlayState>(
      find.byType(ActiveGiftAnimationOverlay),
    );
    final superCarGift = MockLiveComments.virtualGifts.firstWhere(
      (g) => g.id == 'gift_super_car',
    );
    overlayState.playGift(superCarGift);
    await tester.pump(const Duration(milliseconds: 100));

    // 5. Verify the active moving car banner is rendered on screen
    expect(find.text('You sent Super Car!'), findsOneWidget);
  });
}
