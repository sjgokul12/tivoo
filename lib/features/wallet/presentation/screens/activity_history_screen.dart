import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/wallet_controller.dart';
import '../../models/wallet_models.dart';
import '../widgets/wallet_widgets.dart';

class ActivityHistoryScreen extends ConsumerStatefulWidget {
  const ActivityHistoryScreen({super.key});

  @override
  ConsumerState<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends ConsumerState<ActivityHistoryScreen> {
  int _selectedFilter = 0; // 0: All, 1: Stars, 2: T Coins, 3: Withdrawals

  final List<String> _filters = ['All', 'Stars', 'T Coins', 'Withdrawals'];

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);

    final filteredTransactions = wallet.transactions.where((tx) {
      if (_selectedFilter == 0) return true;
      if (_selectedFilter == 1) {
        return tx.type == TransactionType.starPurchase ||
            tx.type == TransactionType.tCoinToStar ||
            tx.type == TransactionType.starToTCoin;
      }
      if (_selectedFilter == 2) {
        return tx.type == TransactionType.starToTCoin ||
            tx.type == TransactionType.tCoinToStar ||
            tx.type == TransactionType.withdrawTCoin;
      }
      if (_selectedFilter == 3) {
        return tx.type == TransactionType.withdrawTCoin;
      }
      return true;
    }).toList();

    return WalletScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Recent Activity',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter Tabs matching reference style
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: List.generate(_filters.length, (index) {
                final isSelected = index == _selectedFilter;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedFilter = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1D2866)
                              : const Color(0xFF0E1236),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF4361EE)
                                : const Color(0xFF24326A),
                            width: 1.2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _filters[index],
                            style: GoogleFonts.outfit(
                              color: isSelected ? Colors.white : WalletPalette.textSecondary,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 8),

          // Transactions List in WalletNeonCard
          Expanded(
            child: filteredTransactions.isEmpty
                ? Center(
                    child: Text(
                      'No transactions found',
                      style: GoogleFonts.outfit(
                        color: WalletPalette.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredTransactions.length,
                    separatorBuilder: (_, index) => const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Divider(color: Color(0xFF1E2856), height: 1),
                    ),
                    itemBuilder: (context, index) {
                      final tx = filteredTransactions[index];
                      return TransactionActivityTile(transaction: tx);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
