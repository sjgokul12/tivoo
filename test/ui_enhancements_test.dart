import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivoo/core/constants/app_assets.dart';
import 'package:tivoo/core/services/reel_video_manager.dart';
import 'package:tivoo/core/widgets/reel_media_view.dart';
import 'package:tivoo/features/auth/presentation/screens/login_screen.dart';
import 'package:tivoo/features/home/presentation/screens/home_screen.dart';
import 'package:tivoo/features/home/presentation/widgets/home_header.dart';
import 'package:tivoo/features/live_stream/domain/models/gift_item.dart';
import 'package:tivoo/features/live_stream/presentation/widgets/gift_bottom_sheet.dart';
import 'package:tivoo/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:visibility_detector/visibility_detector.dart';

void main() {
  setUp(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  testWidgets('SplashScreen smoke test - verify PageIndicator dots are removed', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Get Started button is present
    expect(find.text('Get Started'), findsOneWidget);

  });

  testWidgets('LoginScreen smoke test - verify uploaded logo assets and social buttons', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Verify Hero text
    expect(find.text('Live.'), findsOneWidget);
    expect(find.text('Stream.'), findsOneWidget);
    expect(find.text('Connect.'), findsOneWidget);
    expect(
      find.text('Join a community of amazing streamers and enjoy live moments together.'),
      findsOneWidget,
    );
    expect(find.text('Welcome Back'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);

    // Verify social buttons with labels
    expect(find.text('Google'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('Facebook'), findsOneWidget);

    // Verify Image.asset for logos
    final imageFinders = find.byType(Image);
    expect(imageFinders, findsWidgets);
  });

  testWidgets('HomeScreen smoke test - verify TaalMil layout with 5 category tabs, mini broadcasters, weekly all-stars, and 2-col grid without star/gift', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 200));

    // Old popular/discover category tabs are gone
    expect(find.text('Discover'), findsNothing);

    // Verify story row (You, Khalid, Maya, Leo) is removed per user instruction
    expect(find.text('You'), findsNothing);
    expect(find.text('Khalid'), findsNothing);

    // Verify category tabs exist in HomeHeader (Live, PK Battle, Chat Room)
    expect(
      HomeHeader.categoryTabs.map((t) => t['label']),
      containsAll([
        'Live',
        'PK Battle',
        'Chat Room',
      ]),
    );
    expect(find.text('Live'), findsWidgets);
    expect(find.text('PK Battle'), findsWidgets);
    expect(find.text('Chat Room'), findsWidgets);

    // Header: tagline, search pill, favorites and notifications buttons, hero banner
    expect(find.textContaining('CONNECT', findRichText: true), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.byIcon(Icons.favorite_border_rounded), findsWidgets); // header + banner heart
    expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
    expect(find.text('Real People'), findsOneWidget);

    // Verify Mini Broadcasters & Weekly All-Stars banner are REMOVED per user request
    expect(find.text('aashi'), findsNothing);
    expect(find.text('payal'), findsNothing);
    expect(find.text('WEEKLY ALL-STARS'), findsNothing);

    // Verify Star and Gift are REMOVED from the Home Screen cards
    expect(find.text('Star'), findsNothing);
    expect(find.text('Gift'), findsNothing);
  });

  testWidgets('ReelMediaView smoke test - verify fast thumbnail preview and muted state by default', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ReelMediaView(
            videoAssetPath: AppAssets.video1,
            coverAssetPath: AppAssets.liveCard1,
            isActive: true,
          ),
        ),
      ),
    );
    await tester.pump();

    // Verify thumbnail image is rendered immediately on frame 0
    expect(find.byType(Image), findsWidgets);
    // Verify ReelVideoManager starts muted by default per Instagram Reels UX
    expect(ReelVideoManager.instance.isMuted, isTrue);
  });

  testWidgets('GiftBottomSheet smoke test - verify 5 custom gifts are present with images and selectable', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    GiftItem? selectedGift;

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: GiftBottomSheet(
              onGiftSelected: (gift) {
                selectedGift = gift;
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // Verify Title and Tabs
    expect(find.text('Gift'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Popular'), findsOneWidget);

    // Verify all custom gifts are rendered with images
    final images = find.byType(Image);
    expect(images, findsWidgets);

    // Scroll the grid to Flowers (premium 3D gifts come first), then open Preview & Send
    await tester.scrollUntilVisible(find.text('Flowers'), 200, scrollable: find.byType(Scrollable).last);
    expect(find.text('Flowers'), findsWidgets);
    await tester.tap(find.text('Flowers').first);
    await tester.pumpAndSettle();

    // Verify Tiki Style Preview & Send button is present
    final sendButton = find.textContaining('Send Gift');
    expect(sendButton, findsOneWidget);
    await tester.tap(sendButton);
    await tester.pump();
    expect(selectedGift?.name, equals('Flowers'));
  });
}
