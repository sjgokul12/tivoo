import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivoo/features/gift/buy_stars_sheet.dart';

void main() {
  Widget createTestWidget({Size? surfaceSize}) {
    return ProviderScope(
      child: MaterialApp(
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              size: surfaceSize ?? const Size(390, 844),
            ),
            child: const BuyStarsScreen(currentBalance: 1000000),
          ),
        ),
      ),
    );
  }

  group('BuyStarsScreen Responsiveness and Clickability Tests', () {
    testWidgets('Renders all packs without overflow on small 320x568 screen', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget(surfaceSize: const Size(320, 568)));
      await tester.pumpAndSettle();

      expect(find.text('100'), findsOneWidget);
      expect(find.text('1,000'), findsOneWidget);
      expect(find.text('Popular'), findsOneWidget);
      expect(find.text('10,000'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Renders without overflow on tablet 800x1200 screen', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget(surfaceSize: const Size(800, 1200)));
      await tester.pumpAndSettle();

      expect(find.text('100'), findsOneWidget);
      expect(find.text('1,000,000'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Clicking star card opens Top Up Stars sheet without getting stuck', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap the Popular 1,000 Stars card
      await tester.tap(find.text('1,000'));
      await tester.pumpAndSettle();

      // Verify Top Up Stars bottom sheet opened
      expect(find.text('Top Up Stars'), findsOneWidget);
      expect(find.text('1,000 Stars'), findsOneWidget);
      expect(find.text('Pay ₹200'), findsOneWidget);

      // Verify payment methods exist
      expect(find.text('Google Pay'), findsOneWidget);
      expect(find.text('PhonePe'), findsOneWidget);

      // Tap Pay ₹200
      await tester.tap(find.text('Pay ₹200'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify Payment Successful dialog is shown
      expect(find.text('Payment Successful!'), findsOneWidget);
      expect(find.textContaining('1,000 Stars'), findsWidgets);

      // Dismiss dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Verify no exception occurred and screen is interactive
      expect(tester.takeException(), isNull);
    });

    testWidgets('Clicking 10,000 Grand Pack card works smoothly', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Scroll down to see 10,000 pack if needed
      await tester.scrollUntilVisible(find.text('10,000'), 100);
      await tester.pumpAndSettle();

      // Tap the 10,000 pack
      await tester.tap(find.text('10,000'));
      await tester.pumpAndSettle();

      expect(find.text('Top Up Stars'), findsOneWidget);
      expect(find.text('Pay ₹2,000'), findsOneWidget);

      // Dismiss by tapping back
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded).last);
      await tester.pumpAndSettle();

      expect(find.text('Top Up Stars'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
