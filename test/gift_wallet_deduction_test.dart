import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivoo/features/gift/gift_options.dart';
import 'package:tivoo/features/gift/gift_sheet_screen.dart';
import 'package:tivoo/features/gift/gift_balance_details_dialog.dart';
import 'package:tivoo/features/gift/realistic_3d_coin.dart';
import 'package:tivoo/features/live_stream/domain/models/gift_item.dart' as domain;
import 'package:tivoo/features/live_stream/presentation/controllers/star_wallet_controller.dart';
import 'package:tivoo/features/live_stream/presentation/widgets/active_gift_animation_overlay.dart';
import 'package:tivoo/features/pk_battle/commands/pk_command_section.dart';
import 'package:tivoo/features/live_stream/domain/models/live_comment.dart';

void main() {
  group('StarWalletController star deduction & balance tests', () {
    test('sendStars successfully deducts stars from wallet and preserves remaining balance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialBalance = container.read(starWalletProvider).starBalance;
      expect(initialBalance, 1000000);

      // Deduct 150 stars for a gift
      final success = container.read(starWalletProvider.notifier).sendStars(
            150,
            giftName: 'Cosmic Fire Rose',
            recipient: 'Riya',
          );

      expect(success, isTrue);
      final remaining = container.read(starWalletProvider).starBalance;
      expect(remaining, initialBalance - 150);

      // Check transaction recorded
      final lastTx = container.read(starWalletProvider).transactions.first;
      expect(lastTx.starsDelta, -150);
      expect(lastTx.title, contains('Cosmic Fire Rose'));
    });

    test('sendStars rejects deduction if wallet balance is insufficient', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Attempt to deduct more stars than available
      final success = container.read(starWalletProvider.notifier).sendStars(
            99999999,
            giftName: 'Galaxy Throne',
            recipient: 'Host',
          );

      expect(success, isFalse);
      expect(container.read(starWalletProvider).starBalance, 1000000);
    });

    test('creditStars increases star wallet balance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initialBalance = container.read(starWalletProvider).starBalance;
      container.read(starWalletProvider.notifier).creditStars(500, reason: 'Top Up Pack');

      expect(container.read(starWalletProvider).starBalance, initialBalance + 500);
    });
  });

  group('GiftBottomSheet UI star wallet deduction & balance display tests', () {
    testWidgets('Displays wallet stars in gift sheet, deducts on send, and shows remaining balance',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(420 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer();
      addTearDown(container.dispose);

      GiftItem? sentGift;
      int? sentQuantity;
      String? sentRecipient;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: GiftBottomSheet(
                recipients: const ['Host Neha', 'Opponent Arun'],
                initialRecipient: 'Host Neha',
                onGiftSelected: (gift) {},
                onGiftWithRecipientSelected: (gift, quantity, recipient) {
                  sentGift = gift;
                  sentQuantity = quantity;
                  sentRecipient = recipient;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify wallet stars are displayed in the gift sheet (1,000,000)
      expect(find.text('1,000,000'), findsWidgets);

      // Tap on the first gift item to open Preview & Send view
      final firstGift = GiftCatalog.virtualGifts.first;
      await tester.tap(find.text(firstGift.name).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // In Preview & Send view: verify wallet star balance is displayed
      expect(find.textContaining('1,000,000 ⭐'), findsWidgets);

      // Tap "Send Gift"
      final costStr = firstGift.diamonds.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
      final sendButton = find.widgetWithText(ElevatedButton, 'Send Gift ($costStr ⭐)');
      expect(sendButton, findsOneWidget);
      await tester.tap(sendButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify callback triggered
      expect(sentGift?.name, firstGift.name);
      expect(sentQuantity, 1);
      expect(sentRecipient, 'Host Neha');

      // Verify stars were deducted in the wallet provider
      final expectedRemaining = 1000000 - firstGift.diamonds;
      expect(container.read(starWalletProvider).starBalance, expectedRemaining);

      final expectedStr = expectedRemaining.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );

      // Verify remaining balance stars are now shown on screen in the gift section
      expect(find.textContaining('$expectedStr ⭐'), findsWidgets);

      // Verify deduction confirmation banner is shown
      expect(find.textContaining('-$costStr ⭐ deducted'), findsWidgets);
      expect(find.textContaining('Remaining:'), findsWidgets);
    });

    testWidgets('Shows Insufficient Stars dialog when balance is lower than gift cost',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(420 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Set wallet balance to only 10 stars (first gift costs 50,000)
      container.read(starWalletProvider.notifier).sendStars(999990);
      expect(container.read(starWalletProvider).starBalance, 10);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: GiftBottomSheet(
                recipients: const ['Host'],
                onGiftSelected: (gift) {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap on first gift
      final firstGift = GiftCatalog.virtualGifts.first;
      await tester.tap(find.text(firstGift.name).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap "Recharge Stars" button
      final sendButton = find.widgetWithText(ElevatedButton, 'Recharge Stars (Need 50,000 ⭐)');
      expect(sendButton, findsOneWidget);
      await tester.tap(sendButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Insufficient stars dialog appears
      expect(find.text('Insufficient Stars'), findsOneWidget);
      expect(find.text('Top Up Stars ⭐'), findsOneWidget);
    });

    testWidgets('GiftBalanceDetailsDialog displays gift details, deducted stars, and remaining balance',
        (WidgetTester tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final gift = GiftCatalog.virtualGifts.first; // e.g. Royal Crown, 50000 diamonds
      bool sendMoreTapped = false;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: GiftBalanceDetailsDialog(
                gift: gift,
                quantity: 2,
                recipient: 'Neha',
                deductedStars: 100000,
                onSendMore: () {
                  sendMoreTapped = true;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Check header
      expect(find.text('Gift Delivered!'), findsOneWidget);

      // Check gift name & quantity
      expect(find.text('${gift.name} x2'), findsOneWidget);

      // Check recipient badge
      expect(find.text('Sent to Neha'), findsOneWidget);

      // Check deducted stars
      expect(find.text('-100,000 ⭐'), findsOneWidget);

      // Check remaining stars (1,000,000 in fresh container)
      expect(find.text('1,000,000 ⭐'), findsOneWidget);

      // Tap "Send More Gifts"
      await tester.tap(find.text('Send More Gifts'));
      await tester.pump();
      expect(sendMoreTapped, isTrue);
    });

    testWidgets('ActiveGiftAnimationOverlay executes onComplete callback on animation finish',
        (WidgetTester tester) async {
      final overlayKey = GlobalKey<ActiveGiftAnimationOverlayState>();
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActiveGiftAnimationOverlay(
              key: overlayKey,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      );
      await tester.pump();

      final gift = GiftCatalog.virtualGifts.first;
      overlayKey.currentState?.playGift(
        domain.GiftItem(
          id: gift.id,
          name: gift.name,
          icon: gift.icon,
          diamonds: gift.diamonds,
        ),
        senderName: 'You',
        count: 1,
        recipient: 'Neha',
        onComplete: () {
          completed = true;
        },
      );
      await tester.pump();

      // Fast-forward beyond animation duration (7000ms max for premium tier)
      await tester.pump(const Duration(milliseconds: 8000));

      expect(completed, isTrue);
    });

    testWidgets('PkCommandList triggers onUserTap when commenter avatar or username is tapped',
        (WidgetTester tester) async {
      LiveComment? tappedComment;
      final comment = LiveComment(
        id: 'c1',
        userName: 'Vikram',
        message: 'Let us go team! 🔥',
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 300,
              child: PkCommandList(
                comments: [comment],
                controller: ScrollController(),
                onLiveTap: () {},
                onUserTap: (c) {
                  tappedComment = c;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Tap on commenter username
      expect(find.text('Vikram'), findsOneWidget);
      await tester.tap(find.text('Vikram'));
      await tester.pump();

      expect(tappedComment?.userName, 'Vikram');
    });
  });

  group('2-Column Buy Coins/Stars Panel & Realistic3DCoin Tests', () {
    testWidgets('Realistic3DCoin renders CustomPaint and shadows gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Realistic3DCoin(size: 48),
            ),
          ),
        ),
      );
      expect(find.byType(Realistic3DCoin), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Buy Coins sheet opens with 2-column grid and Picture 2 amounts', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(420 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: GiftBottomSheet(
                recipients: const ['Host'],
                onGiftSelected: (gift) {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap the top balance indicator chip with 3D coin to open Buy Coins
      final coinIndicator = find.byType(Realistic3DCoin).first;
      expect(coinIndicator, findsOneWidget);
      await tester.tap(coinIndicator);
      await tester.pumpAndSettle();

      // Verify Buy Stars sheet header and 1 Star = ₹0.20 rate hint
      expect(find.text('Buy Stars'), findsOneWidget);
      expect(find.textContaining('1 Star = ₹0.20'), findsOneWidget);

      // Verify Picture 2 packages are shown in the 2-column grid
      expect(find.text('100 Stars'), findsOneWidget);
      expect(find.text('₹20'), findsOneWidget);

      expect(find.text('300 Stars'), findsOneWidget);
      expect(find.text('₹60'), findsOneWidget);

      expect(find.text('500 Stars'), findsOneWidget);
      expect(find.text('₹100'), findsOneWidget);

      expect(find.text('1,000 Stars'), findsOneWidget);
      expect(find.text('₹200'), findsOneWidget);
      expect(find.text('Popular'), findsWidgets);

      expect(find.text('5,000 Stars'), findsOneWidget);
      expect(find.text('₹1,000'), findsOneWidget);
      expect(find.text('Best Value'), findsOneWidget);

      // Verify Realistic3DCoin icons are present
      expect(find.byType(Realistic3DCoin), findsWidgets);

      // Tap on a package (e.g. ₹200) to open payment method sheet
      await tester.tap(find.text('₹200'));
      await tester.pumpAndSettle();

      // Verify payment methods sheet opened
      expect(find.text('Top Up Coins'), findsOneWidget);
      expect(find.text('Google Pay'), findsOneWidget);
      expect(find.text('PhonePe'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });
  });
}
