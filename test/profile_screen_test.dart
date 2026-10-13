import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivoo/features/profile/presentation/screens/profile_screen.dart';

void main() {
  testWidgets('ProfileScreen renders VIP Gold theme, identity header, stats, and 3-column video grid',
      (WidgetTester tester) async {
    // Provide phone screen size
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify Top Bar: VIP badge and back button
    expect(find.text('VIP'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(find.byIcon(Icons.qr_code_scanner_rounded), findsNothing);
    expect(find.byIcon(Icons.menu_rounded), findsOneWidget);
    expect(find.byIcon(Icons.settings_rounded), findsOneWidget);

    // 2. Verify Profile Identity Header
    expect(find.text('Rohit_Rajdhani66'), findsOneWidget);
    expect(find.byIcon(Icons.verified_rounded), findsOneWidget);
    expect(find.text('Lv 10'), findsOneWidget);
    expect(find.text('#DreamBig  #LiveMore  #Tivoo'), findsOneWidget);

    // 3. Verify Stats
    expect(find.text('4.7K'), findsOneWidget);
    expect(find.text('Followers'), findsOneWidget);
    expect(find.text('300'), findsOneWidget);
    expect(find.text('Following'), findsOneWidget);
    expect(find.text('53.1K'), findsOneWidget);
    expect(find.text('Likes'), findsOneWidget);

    // 4. Verify Artistic Calligraphy
    expect(find.text('Good\nVibes\nOnly'), findsOneWidget);

    // 5. Verify Bio Section
    expect(find.text('#Knowledge'), findsOneWidget);
    expect(find.text('Rohit Rajdhani'), findsOneWidget);
    expect(find.text('OFFICIAL HOST BANNE KE LIYE MASSAGE KARE 80848 06861 LIVE AANE KA TIME 9PM 👑'), findsOneWidget);

    // 6. Verify Action Buttons
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Find Friends'), findsOneWidget);

    // 7. Verify Badges
    expect(find.text('Tiki Star'), findsOneWidget);
    expect(find.text('Angels'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
    expect(find.text('Family'), findsOneWidget);
    expect(find.text('RS TECH'), findsOneWidget);

    // 8. Verify Video Stats Highlight Bar
    expect(find.text('Videos 411'), findsOneWidget);
    expect(find.text('Likes 39637'), findsOneWidget);

    // 9. Verify Sub-Tabs
    expect(find.text('Drafts'), findsWidgets);
    expect(find.text('Pinned'), findsWidgets);
    expect(find.text('My Posts'), findsOneWidget);

    // 10. Verify Video Grid Items
    expect(find.text('12 Videos'), findsOneWidget);
    expect(find.text('4.9K'), findsOneWidget);
    expect(find.text('6.3K'), findsOneWidget);
    expect(find.text('8.2K'), findsOneWidget);
    expect(find.text('5.7K'), findsOneWidget);
    expect(find.text('9.1K'), findsOneWidget);
  });

  testWidgets('ProfileScreen renders without overflow on compact 320px phone',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(320 * 2, 640 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rohit_Rajdhani66'), findsOneWidget);
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Videos 411'), findsOneWidget);
  });

  testWidgets('ProfileScreen renders without overflow on 800px tablet',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800 * 2, 1280 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rohit_Rajdhani66'), findsOneWidget);
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Videos 411'), findsOneWidget);
  });
}
