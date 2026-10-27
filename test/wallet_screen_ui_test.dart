import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivoo/features/wallet/presentation/screens/wallet_screen.dart';

void main() {
  testWidgets('WalletScreen renders all reference components smoothly', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: WalletScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify header title
    expect(find.text('My Wallet'), findsOneWidget);

    // Verify Star balance card
    expect(find.text('Star'), findsOneWidget);
    expect(find.text('5,600'), findsOneWidget);

    // Verify T Coin balance card
    expect(find.text('T Coin'), findsOneWidget);
    expect(find.text('300'), findsOneWidget);

    // Verify promo banner
    expect(find.text('Purchase Star'), findsWidgets);
    expect(find.text('Get Stars instantly'), findsOneWidget);
    expect(find.text('Purchase'), findsOneWidget);

    // Verify Quick Actions
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(find.text('Convert Star\nto T Coin'), findsOneWidget);
    expect(find.text('Convert T Coin\nto Star'), findsOneWidget);
    expect(find.text('Withdraw\nT Coin'), findsOneWidget);

    // Verify Recent Activity
    expect(find.text('Recent Activity'), findsOneWidget);
    expect(find.text('T Coin Withdrawn'), findsOneWidget);
    expect(find.text('Converted to T Coin'), findsOneWidget);
    expect(find.text('Converted to Star'), findsOneWidget);
  });
}
