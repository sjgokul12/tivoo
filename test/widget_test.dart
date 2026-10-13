import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tivoo/features/settings/presentation/screens/settings_screen.dart';
import 'package:tivoo/features/settings/presentation/screens/help_support_screen.dart';

void main() {
  testWidgets('SettingsScreen smoke test - verify removed items are absent', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );
    await tester.pump();

    // Verify header and remaining options
    expect(find.text('Settings & Privacy'), findsOneWidget);
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Change Password'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Live & Content Settings'), findsOneWidget);
    expect(find.text('Help & Support'), findsOneWidget);
    expect(find.text('Legal & Policies'), findsOneWidget);
    expect(find.text('Log Out'), findsOneWidget);

    // Verify requested removed items are NOT present
    expect(find.text('Privacy & Security'), findsNothing);
    expect(find.text('Account Management'), findsNothing);
    expect(find.text('Language & Storage'), findsNothing);
  });

  testWidgets('HelpSupportScreen individual question dropdown test with auto-close', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HelpSupportScreen(),
        ),
      ),
    );
    await tester.pump();

    // Verify all questions are listed
    expect(find.text('How do I start a live stream broadcast?'), findsOneWidget);
    expect(find.text('How do Coins, Virtual Gifts & Diamonds work?'), findsOneWidget);
    expect(find.text('How do I withdraw my Creator Earnings?'), findsOneWidget);
    expect(find.text('How do I get the Verified Creator Badge?'), findsOneWidget);

    // Verify answers are initially collapsed / not visible
    expect(find.textContaining('Tap the glowing "+" button'), findsNothing);
    expect(find.textContaining('Viewers purchase virtual coins in their wallet'), findsNothing);

    // Tap Question 1: How do I start a live stream broadcast?
    await tester.tap(find.text('How do I start a live stream broadcast?'));
    await tester.pumpAndSettle();

    // Question 1 answer should now be visible
    expect(find.textContaining('Tap the glowing "+" button'), findsOneWidget);
    // Question 2 answer should remain hidden
    expect(find.textContaining('Viewers purchase virtual coins in their wallet'), findsNothing);

    // Tap Question 2: How do Coins, Virtual Gifts & Diamonds work?
    await tester.ensureVisible(find.text('How do Coins, Virtual Gifts & Diamonds work?'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('How do Coins, Virtual Gifts & Diamonds work?'));
    await tester.pumpAndSettle();

    // Question 2 answer should now be visible
    expect(find.textContaining('Viewers purchase virtual coins in their wallet'), findsOneWidget);
    // Question 1 answer should be AUTOMATICALLY CLOSED!
    expect(find.textContaining('Tap the glowing "+" button'), findsNothing);
  });
}

