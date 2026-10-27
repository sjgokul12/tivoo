enum TransactionType {
  starPurchase,
  starToTCoin,
  tCoinToStar,
  withdrawTCoin,
}

class StarPackage {
  final String id;
  final int starsCount;
  final int priceInr;
  final bool isPopular;

  const StarPackage({
    required this.id,
    required this.starsCount,
    required this.priceInr,
    this.isPopular = false,
  });

  String get formattedStars =>
      starsCount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  String get formattedPrice => '₹$priceInr';
}

class BankAccount {
  final String id;
  final String bankName;
  final String accountNumber;
  final String ifscCode;
  final String accountHolder;

  const BankAccount({
    required this.id,
    required this.bankName,
    required this.accountNumber,
    required this.ifscCode,
    required this.accountHolder,
  });

  String get maskedNumber {
    if (accountNumber.length <= 4) return '**** $accountNumber';
    return '**** ${accountNumber.substring(accountNumber.length - 4)}';
  }

  String get displayName => '$bankName $maskedNumber';
}

class WalletTransaction {
  final String id;
  final String title;
  final String subtitle;
  final String dateText;
  final TransactionType type;
  final int? starDelta;
  final int? tCoinDelta;
  final double? inrAmount;
  final bool isPending;

  const WalletTransaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.dateText,
    required this.type,
    this.starDelta,
    this.tCoinDelta,
    this.inrAmount,
    this.isPending = false,
  });
}

class WalletState {
  final int starBalance;
  final int tCoinBalance;
  final List<WalletTransaction> transactions;
  final List<BankAccount> bankAccounts;
  final int selectedBankIndex;

  const WalletState({
    required this.starBalance,
    required this.tCoinBalance,
    required this.transactions,
    required this.bankAccounts,
    this.selectedBankIndex = 0,
  });

  BankAccount? get primaryBank =>
      bankAccounts.isNotEmpty && selectedBankIndex < bankAccounts.length
          ? bankAccounts[selectedBankIndex]
          : null;

  String get formattedStarBalance =>
      starBalance.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  String get formattedTCoinBalance =>
      tCoinBalance.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  double get tCoinInrValue => tCoinBalance * 0.50;

  WalletState copyWith({
    int? starBalance,
    int? tCoinBalance,
    List<WalletTransaction>? transactions,
    List<BankAccount>? bankAccounts,
    int? selectedBankIndex,
  }) {
    return WalletState(
      starBalance: starBalance ?? this.starBalance,
      tCoinBalance: tCoinBalance ?? this.tCoinBalance,
      transactions: transactions ?? this.transactions,
      bankAccounts: bankAccounts ?? this.bankAccounts,
      selectedBankIndex: selectedBankIndex ?? this.selectedBankIndex,
    );
  }
}
