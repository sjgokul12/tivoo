import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The viewer's coin balance used to send gifts.
final walletProvider = NotifierProvider<WalletNotifier, int>(WalletNotifier.new);

class WalletNotifier extends Notifier<int> {
  static const _startingCoins = 5000;

  @override
  int build() => _startingCoins;

  /// Deducts [coins] if affordable. Returns false (and changes nothing) otherwise.
  bool trySpend(int coins) {
    if (coins <= 0 || coins > state) return false;
    state -= coins;
    return true;
  }
}
