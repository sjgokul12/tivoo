import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivoo/features/live_stream/presentation/controllers/star_wallet_controller.dart';
import 'package:tivoo/features/live_stream/presentation/widgets/purchase_stars_sheet.dart';
import 'package:tivoo/features/live_stream/presentation/widgets/star_up_bottom_sheet.dart';

void main() {
  group('StarWalletController tests', () {
    test('Initial balance is 1,000,000 stars (1M) and formats to "1,000,000"', () {
      final controller = StarWalletController();
      expect(controller.state.starBalance, 1000000);
      expect(controller.state.formattedFullBalance, '1,000,000');
      expect(controller.state.formattedBalance, '1M');
      expect(controller.state.dollarBalance, 25.0);
    });

    test('StarWalletState has user ID account scoping and transactions', () {
      final controller = StarWalletController();
      expect(controller.state.userId, 'UID-849201');
      expect(controller.state.userName, 'Alex Rivers');
      expect(controller.state.transactions.isNotEmpty, isTrue);
    });

    test('Purchase packages with dollar adds stars to balance', () async {
      final controller = StarWalletController();
      final initialStars = controller.state.starBalance;

      final pkg100k = StarWalletController.packages.firstWhere((p) => p.id == 'pack_100k');
      await controller.purchaseWithDollar(pkg100k);
      expect(controller.state.starBalance, initialStars + 100000);
    });

    test('sendStars succeeds when balance is sufficient, fails when insufficient', () {
      final controller = StarWalletController();
      final initialStars = controller.state.starBalance;

      expect(controller.sendStars(2), isTrue);
      expect(controller.state.starBalance, initialStars - 2);

      // Fails when exceeding balance
      expect(controller.sendStars(controller.state.starBalance + 1000), isFalse);
    });
  });

  group('StarUpBottomSheet widget tests', () {
    testWidgets('Renders StarUp, star balance, and star options', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: StarUpBottomSheet(
                streamerName: 'Lena Rivers',
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Verify title "StarUp"
      expect(find.text('StarUp'), findsOneWidget);

      // Verify initial balance indicator "1M"
      expect(find.text('1M'), findsOneWidget);

      // Verify golden star cards x1 and x2
      expect(find.text('x1'), findsOneWidget);
      expect(find.text('x2'), findsOneWidget);
      expect(find.text('SEND x1'), findsOneWidget);
      expect(find.text('SEND x2'), findsOneWidget);

      // Verify yellow "Purchase More Stars" button
      expect(find.text('Purchase More Stars'), findsOneWidget);
    });
  });

  group('PurchaseStarsSheet widget tests', () {
    testWidgets('Renders 4-tab Tivoo Star Wallet matching screenshots: Convert, P2P, Buy Stars, Withdraw', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: PurchaseStarsSheet(),
            ),
          ),
        ),
      );
      await tester.pump();

      // 1. Verify Top Bar: Tivoo Star Wallet & History
      expect(find.text('Tivoo Star Wallet'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);

      // 2. Verify Balance Card: Star Balance, Cash Balance, and Rate
      expect(find.text('Star Balance'), findsOneWidget);
      expect(find.text('Cash Balance'), findsOneWidget);
      expect(find.text('Rate: 100K ⭐ = \$1.00 USD'), findsOneWidget);

      // 3. Verify 4 Pill Tabs
      expect(find.text('Convert'), findsOneWidget);
      expect(find.text('P2P Sales'), findsOneWidget);
      expect(find.text('Buy Stars'), findsOneWidget);
      expect(find.text('Withdraw'), findsOneWidget);

      // 4. Tab 0: Convert (Default)
      expect(find.text('Convert Collected Stars into USD'), findsOneWidget);
      expect(find.text('Select Stars to Convert:'), findsOneWidget);
      expect(find.text('50K Stars'), findsOneWidget);
      expect(find.text('100K Stars'), findsOneWidget);
      expect(find.text('200K Stars'), findsOneWidget);
      expect(find.text('Instant Payout'), findsOneWidget);
      expect(find.text('Convert Stars to \$1.00 USD Now'), findsOneWidget);

      // 5. Tab 1: P2P Sales
      await tester.tap(find.text('P2P Sales'));
      await tester.pumpAndSettle();
      expect(find.text('Direct P2P Star Sale'), findsOneWidget);
      expect(find.text('Buyer / Counterparty User ID:'), findsOneWidget);
      expect(find.text('UID-928410'), findsWidgets);
      expect(find.text('Sell 100K Stars for \$1.00 USD'), findsOneWidget);

      // 6. Tab 2: Buy Stars
      await tester.ensureVisible(find.text('Buy Stars'));
      await tester.tap(find.text('Buy Stars'));
      await tester.pumpAndSettle();
      expect(find.text('100K Stars'), findsOneWidget);
      expect(find.text('500K Stars'), findsOneWidget);
      expect(find.text('HOT'), findsOneWidget);
      expect(find.text('1,000K Stars'), findsOneWidget);
      expect(find.text('2,500K Stars'), findsOneWidget);
      expect(find.text('5,000K Stars'), findsOneWidget);
      expect(find.text('Pay \$4.99 USD for 500K Stars'), findsOneWidget);

      // 7. Tab 3: Withdraw
      await tester.ensureVisible(find.text('Withdraw'));
      await tester.tap(find.text('Withdraw'));
      await tester.pumpAndSettle();
      expect(find.text('Cash Out USD Balance'), findsOneWidget);
      expect(find.text('Select Withdrawal Amount:'), findsOneWidget);
      expect(find.text('PayPal'), findsOneWidget);
      expect(find.text('Bank'), findsOneWidget);
      expect(find.text('Card'), findsOneWidget);
      expect(find.text('Withdraw \$10.00 USD Now'), findsOneWidget);
    });
  });
}
