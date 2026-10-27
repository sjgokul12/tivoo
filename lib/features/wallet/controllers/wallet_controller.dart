import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/wallet_models.dart';

class WalletController extends StateNotifier<WalletState> {
  WalletController()
      : super(
          const WalletState(
            starBalance: 5600,
            tCoinBalance: 300,
            bankAccounts: [
              BankAccount(
                id: 'bank-1',
                bankName: 'HDFC Bank',
                accountNumber: '5010048214821',
                ifscCode: 'HDFC0001234',
                accountHolder: 'User Account',
              ),
              BankAccount(
                id: 'bank-2',
                bankName: 'State Bank of India',
                accountNumber: '302008129012',
                ifscCode: 'SBIN0004567',
                accountHolder: 'User Account',
              ),
            ],
            selectedBankIndex: 0,
            transactions: [
              WalletTransaction(
                id: 'TXN-901',
                title: 'T Coin Withdrawn',
                subtitle: '3,000 T Coin',
                dateText: 'Today 10:30 AM',
                type: TransactionType.withdrawTCoin,
                tCoinDelta: -3000,
                inrAmount: 1500.0,
              ),
              WalletTransaction(
                id: 'TXN-902',
                title: 'Converted to T Coin',
                subtitle: '900 Star → 300 T Coin',
                dateText: '12 Oct 2026',
                type: TransactionType.starToTCoin,
                starDelta: -900,
                tCoinDelta: 300,
              ),
              WalletTransaction(
                id: 'TXN-903',
                title: 'Converted to Star',
                subtitle: '200 T Coin → 500 Star',
                dateText: '10 Oct 2026',
                type: TransactionType.tCoinToStar,
                tCoinDelta: -200,
                starDelta: 500,
              ),
              WalletTransaction(
                id: 'TXN-904',
                title: 'Purchase Star',
                subtitle: '1,000 Star',
                dateText: '08 Oct 2026',
                type: TransactionType.starPurchase,
                starDelta: 1000,
                inrAmount: 200.0,
              ),
            ],
          ),
        );

  static const List<StarPackage> packages = [
    StarPackage(id: 'pkg-1', starsCount: 100, priceInr: 20),
    StarPackage(id: 'pkg-2', starsCount: 300, priceInr: 60, isPopular: true),
    StarPackage(id: 'pkg-3', starsCount: 500, priceInr: 100),
    StarPackage(id: 'pkg-4', starsCount: 1000, priceInr: 200),
    StarPackage(id: 'pkg-5', starsCount: 2000, priceInr: 400),
    StarPackage(id: 'pkg-6', starsCount: 3000, priceInr: 600),
    StarPackage(id: 'pkg-7', starsCount: 4000, priceInr: 800),
    StarPackage(id: 'pkg-8', starsCount: 5000, priceInr: 1000),
  ];

  void selectBank(int index) {
    if (index >= 0 && index < state.bankAccounts.length) {
      state = state.copyWith(selectedBankIndex: index);
    }
  }

  void addBankAccount(BankAccount account) {
    final updated = List<BankAccount>.from(state.bankAccounts)..add(account);
    state = state.copyWith(
      bankAccounts: updated,
      selectedBankIndex: updated.length - 1,
    );
  }

  /// Purchase Stars Flow
  WalletTransaction buyStars({
    required StarPackage package,
    required String paymentMethod,
  }) {
    final txId = 'TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(4)}';
    final now = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    final tx = WalletTransaction(
      id: txId,
      title: 'Purchase Star',
      subtitle: '${package.formattedStars} Star',
      dateText: now,
      type: TransactionType.starPurchase,
      starDelta: package.starsCount,
      inrAmount: package.priceInr.toDouble(),
    );

    state = state.copyWith(
      starBalance: state.starBalance + package.starsCount,
      transactions: [tx, ...state.transactions],
    );

    return tx;
  }

  /// Convert Stars to T Coins (3 Stars = 1 T Coin)
  WalletTransaction? convertStarToTCoin(int starsToConvert) {
    if (starsToConvert <= 0 || state.starBalance < starsToConvert) return null;

    final tCoinsReceived = starsToConvert ~/ 3;
    final txId = 'TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(4)}';
    final now = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    final tx = WalletTransaction(
      id: txId,
      title: 'Converted to T Coin',
      subtitle: '$starsToConvert Star → $tCoinsReceived T Coin',
      dateText: now,
      type: TransactionType.starToTCoin,
      starDelta: -starsToConvert,
      tCoinDelta: tCoinsReceived,
    );

    state = state.copyWith(
      starBalance: state.starBalance - starsToConvert,
      tCoinBalance: state.tCoinBalance + tCoinsReceived,
      transactions: [tx, ...state.transactions],
    );

    return tx;
  }

  /// Convert T Coins to Stars (1 T Coin = 2 Stars)
  WalletTransaction? convertTCoinToStar(int tCoinsToConvert) {
    if (tCoinsToConvert <= 0 || state.tCoinBalance < tCoinsToConvert) return null;

    final starsReceived = tCoinsToConvert * 2;
    final txId = 'TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(4)}';
    final now = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    final tx = WalletTransaction(
      id: txId,
      title: 'Converted to Star',
      subtitle: '$tCoinsToConvert T Coin → $starsReceived Star',
      dateText: now,
      type: TransactionType.tCoinToStar,
      tCoinDelta: -tCoinsToConvert,
      starDelta: starsReceived,
    );

    state = state.copyWith(
      tCoinBalance: state.tCoinBalance - tCoinsToConvert,
      starBalance: state.starBalance + starsReceived,
      transactions: [tx, ...state.transactions],
    );

    return tx;
  }

  /// Withdraw T Coins to Bank Account (1 T Coin = ₹0.50, Fee = ₹2.00)
  WalletTransaction? withdrawTCoin({
    required int tCoinsToWithdraw,
    required BankAccount bank,
  }) {
    if (tCoinsToWithdraw <= 0 || state.tCoinBalance < tCoinsToWithdraw) return null;

    final grossAmount = tCoinsToWithdraw * 0.50;
    const fee = 2.00;
    final netPayout = grossAmount - fee;
    final reqId = 'WD${DateTime.now().millisecondsSinceEpoch.toString().substring(4)}';
    final now = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

    final tx = WalletTransaction(
      id: reqId,
      title: 'T Coin Withdrawn',
      subtitle: '$tCoinsToWithdraw T Coin',
      dateText: now,
      type: TransactionType.withdrawTCoin,
      tCoinDelta: -tCoinsToWithdraw,
      inrAmount: netPayout,
      isPending: true,
    );

    state = state.copyWith(
      tCoinBalance: state.tCoinBalance - tCoinsToWithdraw,
      transactions: [tx, ...state.transactions],
    );

    return tx;
  }
}

final walletProvider = StateNotifierProvider<WalletController, WalletState>((ref) {
  return WalletController();
});
