import 'package:flutter_riverpod/flutter_riverpod.dart';

enum StarTransactionType {
  initialGrant,
  purchase,
  convertStarsToDollar,
  sellStarsToUser,
  buyStarsFromUser,
  sendStarGift,
  withdrawCash,
}

class StarTransaction {
  final String id;
  final String title;
  final int starsDelta;
  final double dollarDelta;
  final StarTransactionType type;
  final DateTime timestamp;
  final String? counterpartyUserId;
  final String? note;

  const StarTransaction({
    required this.id,
    required this.title,
    this.starsDelta = 0,
    this.dollarDelta = 0.0,
    required this.type,
    required this.timestamp,
    this.counterpartyUserId,
    this.note,
  });

  String get formattedStarsDelta {
    if (starsDelta == 0) return '';
    return starsDelta > 0 ? '+$starsDelta ⭐' : '$starsDelta ⭐';
  }

  String get formattedDollarDelta {
    if (dollarDelta == 0.0) return '';
    return dollarDelta > 0
        ? '+\$${dollarDelta.toStringAsFixed(2)}'
        : '-\$${dollarDelta.abs().toStringAsFixed(2)}';
  }
}

class P2PStarListing {
  final String id;
  final String sellerId;
  final String sellerName;
  final int starsCount;
  final String formattedStars;
  final double priceDollar;
  final String formattedPrice;
  final double rating;
  final int totalSales;

  const P2PStarListing({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.starsCount,
    required this.formattedStars,
    required this.priceDollar,
    required this.formattedPrice,
    this.rating = 4.9,
    this.totalSales = 120,
  });
}

class StarPurchaseTier {
  final String id;
  final int starsCount;
  final String formattedStars;
  final int priceInr;
  final double priceDollar;

  const StarPurchaseTier({
    required this.id,
    required this.starsCount,
    required this.formattedStars,
    required this.priceInr,
    required this.priceDollar,
  });

  String get formattedInr =>
      '₹${priceInr.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  String get formattedDollar => '\$${priceDollar.toStringAsFixed(2)}';
}

class StarPackage {
  final String id;
  final int starsCount;
  final String formattedStars;
  final double priceDollar;
  final String formattedPrice;
  final String badge;
  final bool isPopular;

  const StarPackage({
    required this.id,
    required this.starsCount,
    required this.formattedStars,
    required this.priceDollar,
    required this.formattedPrice,
    required this.badge,
    this.isPopular = false,
  });
}

class StarWalletState {
  final String userId;
  final String userName;
  final int starBalance;
  final double dollarBalance;
  final bool isProcessingPayment;
  final String? lastPurchasedPackageId;
  final List<StarTransaction> transactions;
  final List<P2PStarListing> p2pMarketplace;

  const StarWalletState({
    this.userId = 'UID-849201',
    this.userName = 'Alex Rivers',
    this.starBalance = 1000000,
    this.dollarBalance = 25.0,
    this.isProcessingPayment = false,
    this.lastPurchasedPackageId,
    this.transactions = const [],
    this.p2pMarketplace = const [],
  });

  /// Full formatted stars balance with commas (e.g. '1,000,000')
  String get formattedFullBalance {
    return starBalance.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  /// Formatted stars balance (e.g. '1,000K', '250K', or 'No. 0' when 0)
  String get formattedBalance {
    if (starBalance == 0) return 'No. 0';
    if (starBalance >= 1000000) {
      final m = starBalance / 1000000;
      return m % 1 == 0 ? '${m.toInt()}M' : '${m.toStringAsFixed(1)}M';
    }
    if (starBalance >= 1000) {
      final k = starBalance / 1000;
      return k % 1 == 0 ? '${k.toInt()}K' : '${k.toStringAsFixed(1)}K';
    }
    return starBalance.toString();
  }

  /// Formatted dollar cash balance (e.g. '$25.00')
  String get formattedDollarBalance {
    return '\$${dollarBalance.toStringAsFixed(2)}';
  }

  StarWalletState copyWith({
    String? userId,
    String? userName,
    int? starBalance,
    double? dollarBalance,
    bool? isProcessingPayment,
    String? lastPurchasedPackageId,
    List<StarTransaction>? transactions,
    List<P2PStarListing>? p2pMarketplace,
  }) {
    return StarWalletState(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      starBalance: starBalance ?? this.starBalance,
      dollarBalance: dollarBalance ?? this.dollarBalance,
      isProcessingPayment: isProcessingPayment ?? this.isProcessingPayment,
      lastPurchasedPackageId:
          lastPurchasedPackageId ?? this.lastPurchasedPackageId,
      transactions: transactions ?? this.transactions,
      p2pMarketplace: p2pMarketplace ?? this.p2pMarketplace,
    );
  }
}

class StarWalletController extends StateNotifier<StarWalletState> {
  StarWalletController()
      : super(
          StarWalletState(
            starBalance: 1000000,
            dollarBalance: 25.0,
            transactions: [
              StarTransaction(
                id: 'tx_init_stars',
                title: 'Account Star Credit',
                starsDelta: 1000000,
                dollarDelta: 0.0,
                type: StarTransactionType.initialGrant,
                timestamp: DateTime.now().subtract(const Duration(hours: 2)),
                note: 'Star balance available in your wallet',
              ),
              StarTransaction(
                id: 'tx_init_cash',
                title: 'Initial Wallet Balance',
                starsDelta: 0,
                dollarDelta: 25.0,
                type: StarTransactionType.initialGrant,
                timestamp: DateTime.now().subtract(const Duration(hours: 2)),
                note: 'Starter USD wallet balance',
              ),
            ],
            p2pMarketplace: const [
              P2PStarListing(
                id: 'p2p_1',
                sellerId: 'UID-928410',
                sellerName: 'Elena Rostova',
                starsCount: 100000,
                formattedStars: '100K',
                priceDollar: 0.89,
                formattedPrice: '\$0.89',
                rating: 4.98,
                totalSales: 340,
              ),
              P2PStarListing(
                id: 'p2p_2',
                sellerId: 'UID-718293',
                sellerName: 'Marcus Chen',
                starsCount: 250000,
                formattedStars: '250K',
                priceDollar: 2.19,
                formattedPrice: '\$2.19',
                rating: 5.0,
                totalSales: 512,
              ),
              P2PStarListing(
                id: 'p2p_3',
                sellerId: 'UID-519284',
                sellerName: 'Sophia Vance',
                starsCount: 500000,
                formattedStars: '500K',
                priceDollar: 4.29,
                formattedPrice: '\$4.29',
                rating: 4.95,
                totalSales: 215,
              ),
              P2PStarListing(
                id: 'p2p_4',
                sellerId: 'UID-638219',
                sellerName: 'Liam Novak',
                starsCount: 1000000,
                formattedStars: '1,000K',
                priceDollar: 8.20,
                formattedPrice: '\$8.20',
                rating: 4.9,
                totalSales: 94,
              ),
            ],
          ),
        );

  static const List<StarPackage> packages = [
    StarPackage(
      id: 'pack_100k',
      starsCount: 100000,
      formattedStars: '100K',
      priceDollar: 0.99,
      formattedPrice: '\$0.99',
      badge: 'Starter Star',
    ),
    StarPackage(
      id: 'pack_500k',
      starsCount: 500000,
      formattedStars: '500K',
      priceDollar: 4.99,
      formattedPrice: '\$4.99',
      badge: '🔥 Most Popular (+15%)',
      isPopular: true,
    ),
    StarPackage(
      id: 'pack_1000k',
      starsCount: 1000000,
      formattedStars: '1,000K',
      priceDollar: 8.99,
      formattedPrice: '\$8.99',
      badge: '⭐ Best Value (+30%)',
    ),
    StarPackage(
      id: 'pack_2500k',
      starsCount: 2500000,
      formattedStars: '2,500K',
      priceDollar: 19.99,
      formattedPrice: '\$19.99',
      badge: '👑 VIP Creator (+50%)',
    ),
    StarPackage(
      id: 'pack_5000k',
      starsCount: 5000000,
      formattedStars: '5,000K',
      priceDollar: 39.99,
      formattedPrice: '\$39.99',
      badge: '💎 Galaxy Mega Pack',
    ),
  ];

  /// Standard conversion rate: 100,000 Stars = $1.00 USD
  static const int starsPerDollar = 100000;

  /// Calculate dollar amount for a given number of stars
  static double calculateDollarEquivalent(int stars) {
    return (stars / starsPerDollar);
  }

  /// Converts collected stars into dollars in the user's wallet
  Future<bool> convertStarsToDollars(int starsToConvert) async {
    if (starsToConvert <= 0 || state.starBalance < starsToConvert) {
      return false;
    }

    state = state.copyWith(isProcessingPayment: true);
    await Future.delayed(const Duration(milliseconds: 500));

    final dollarsEarned = calculateDollarEquivalent(starsToConvert);
    final newStarBalance = state.starBalance - starsToConvert;
    final newDollarBalance = state.dollarBalance + dollarsEarned;

    final tx = StarTransaction(
      id: 'tx_conv_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Converted Stars to USD',
      starsDelta: -starsToConvert,
      dollarDelta: dollarsEarned,
      type: StarTransactionType.convertStarsToDollar,
      timestamp: DateTime.now(),
      note: 'Converted $starsToConvert stars to \$${dollarsEarned.toStringAsFixed(2)} USD',
    );

    state = state.copyWith(
      starBalance: newStarBalance,
      dollarBalance: newDollarBalance,
      isProcessingPayment: false,
      transactions: [tx, ...state.transactions],
    );
    return true;
  }

  /// Sells stars directly to another user ID in exchange for dollar payment
  Future<bool> sellStarsToUser({
    required String targetUserId,
    required int starsCount,
    required double priceDollar,
  }) async {
    if (starsCount <= 0 || state.starBalance < starsCount) {
      return false;
    }

    state = state.copyWith(isProcessingPayment: true);
    await Future.delayed(const Duration(milliseconds: 500));

    final newStarBalance = state.starBalance - starsCount;
    final newDollarBalance = state.dollarBalance + priceDollar;

    final tx = StarTransaction(
      id: 'tx_sell_${DateTime.now().millisecondsSinceEpoch}',
      title: 'P2P Star Sale',
      starsDelta: -starsCount,
      dollarDelta: priceDollar,
      type: StarTransactionType.sellStarsToUser,
      timestamp: DateTime.now(),
      counterpartyUserId: targetUserId,
      note: 'Sold $starsCount stars to $targetUserId for \$${priceDollar.toStringAsFixed(2)} USD',
    );

    state = state.copyWith(
      starBalance: newStarBalance,
      dollarBalance: newDollarBalance,
      isProcessingPayment: false,
      transactions: [tx, ...state.transactions],
    );
    return true;
  }

  /// Buys stars from another user's P2P listing
  Future<bool> buyFromPeer(
    P2PStarListing listing, {
    bool payWithDollarBalance = true,
  }) async {
    state = state.copyWith(isProcessingPayment: true);
    await Future.delayed(const Duration(milliseconds: 500));

    double newDollarBalance = state.dollarBalance;
    if (payWithDollarBalance) {
      if (state.dollarBalance < listing.priceDollar) {
        state = state.copyWith(isProcessingPayment: false);
        return false;
      }
      newDollarBalance -= listing.priceDollar;
    }

    final newStarBalance = state.starBalance + listing.starsCount;

    final tx = StarTransaction(
      id: 'tx_buy_peer_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Bought Stars from ${listing.sellerName}',
      starsDelta: listing.starsCount,
      dollarDelta: payWithDollarBalance ? -listing.priceDollar : 0.0,
      type: StarTransactionType.buyStarsFromUser,
      timestamp: DateTime.now(),
      counterpartyUserId: listing.sellerId,
      note: 'Bought ${listing.formattedStars} stars for ${listing.formattedPrice} USD',
    );

    // Remove bought listing from active marketplace or mark sold
    final updatedListings =
        state.p2pMarketplace.where((item) => item.id != listing.id).toList();

    state = state.copyWith(
      starBalance: newStarBalance,
      dollarBalance: newDollarBalance,
      isProcessingPayment: false,
      transactions: [tx, ...state.transactions],
      p2pMarketplace: updatedListings,
    );
    return true;
  }

  /// Withdraws cash balance to external account (PayPal, Bank, Card)
  Future<bool> withdrawCash({
    required double amountDollar,
    required String payoutMethod,
    required String accountDetails,
  }) async {
    if (amountDollar <= 0 || state.dollarBalance < amountDollar) {
      return false;
    }

    state = state.copyWith(isProcessingPayment: true);
    await Future.delayed(const Duration(milliseconds: 600));

    final newDollarBalance = state.dollarBalance - amountDollar;

    final tx = StarTransaction(
      id: 'tx_wd_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Cash Withdrawal to $payoutMethod',
      starsDelta: 0,
      dollarDelta: -amountDollar,
      type: StarTransactionType.withdrawCash,
      timestamp: DateTime.now(),
      note: 'Withdrew \$${amountDollar.toStringAsFixed(2)} to $accountDetails',
    );

    state = state.copyWith(
      dollarBalance: newDollarBalance,
      isProcessingPayment: false,
      transactions: [tx, ...state.transactions],
    );
    return true;
  }

  /// Simulates payment with Dollar and adds stars to the wallet
  Future<bool> purchaseWithDollar(StarPackage package) async {
    state = state.copyWith(isProcessingPayment: true);
    await Future.delayed(const Duration(milliseconds: 600));

    final tx = StarTransaction(
      id: 'tx_pkg_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Purchased ${package.formattedStars} Stars',
      starsDelta: package.starsCount,
      dollarDelta: 0.0,
      type: StarTransactionType.purchase,
      timestamp: DateTime.now(),
      note: 'Recharged with ${package.formattedPrice} USD',
    );

    state = state.copyWith(
      starBalance: state.starBalance + package.starsCount,
      isProcessingPayment: false,
      lastPurchasedPackageId: package.id,
      transactions: [tx, ...state.transactions],
    );
    return true;
  }

  /// Sends stars if user has enough balance; returns true if successful
  bool sendStars(int count) {
    if (state.starBalance >= count) {
      final tx = StarTransaction(
        id: 'tx_send_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Sent $count Star Gift',
        starsDelta: -count,
        dollarDelta: 0.0,
        type: StarTransactionType.sendStarGift,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        starBalance: state.starBalance - count,
        transactions: [tx, ...state.transactions],
      );
      return true;
    }
    return false;
  }
}

final starWalletProvider =
    StateNotifierProvider<StarWalletController, StarWalletState>((ref) {
  return StarWalletController();
});

