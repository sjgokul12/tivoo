import 'package:flutter_test/flutter_test.dart';
import 'package:tivoo/features/wallet/controllers/wallet_controller.dart';
import 'package:tivoo/features/wallet/models/wallet_models.dart';

void main() {
  group('WalletController Tests', () {
    test('Initial balance matches reference image (5600 Stars, 300 T Coins)', () {
      final controller = WalletController();
      expect(controller.state.starBalance, 5600);
      expect(controller.state.tCoinBalance, 300);
      expect(controller.state.transactions.length, 4);
    });

    test('buyStars updates star balance and adds transaction', () {
      final controller = WalletController();
      final pkg = WalletController.packages.firstWhere((p) => p.starsCount == 1000);
      controller.buyStars(package: pkg, paymentMethod: 'UPI');

      expect(controller.state.starBalance, 6600);
      expect(controller.state.transactions.first.type, TransactionType.starPurchase);
      expect(controller.state.transactions.first.starDelta, 1000);
    });

    test('convertStarToTCoin converts 3 Stars to 1 T Coin', () {
      final controller = WalletController();
      final tx = controller.convertStarToTCoin(300);

      expect(tx, isNotNull);
      expect(controller.state.starBalance, 5300);
      expect(controller.state.tCoinBalance, 400); // 300 + 100
    });

    test('convertTCoinToStar converts 1 T Coin to 2 Stars', () {
      final controller = WalletController();
      final tx = controller.convertTCoinToStar(100);

      expect(tx, isNotNull);
      expect(controller.state.tCoinBalance, 200); // 300 - 100
      expect(controller.state.starBalance, 5800); // 5600 + 200
    });

    test('withdrawTCoin calculates payout and records pending transaction', () {
      final controller = WalletController();
      final bank = controller.state.primaryBank!;
      final tx = controller.withdrawTCoin(tCoinsToWithdraw: 100, bank: bank);

      expect(tx, isNotNull);
      expect(controller.state.tCoinBalance, 200); // 300 - 100
      expect(tx!.isPending, isTrue);
      expect(tx.inrAmount, 48.0); // 100 * 0.50 - 2.00 fee
    });
  });
}
