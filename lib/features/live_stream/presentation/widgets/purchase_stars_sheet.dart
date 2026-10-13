import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/star_wallet_controller.dart';

class PurchaseStarsSheet extends ConsumerStatefulWidget {
  const PurchaseStarsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const PurchaseStarsSheet(),
    );
  }

  @override
  ConsumerState<PurchaseStarsSheet> createState() => _PurchaseStarsSheetState();
}

class _PurchaseStarsSheetState extends ConsumerState<PurchaseStarsSheet> {
  // 4 Main Tabs: 0: Convert, 1: P2P Sales, 2: Buy Stars, 3: Withdraw
  int _activeTab = 0;

  // Tab 0 (Convert) State
  int _convertStarsAmount = 100000; // default 100K = $1.00 USD

  // Tab 1 (P2P Sales) State
  int _p2pSubTab = 0; // 0: Sell Stars to Person, 1: Peer Offers (4)
  String _targetUserId = 'UID-928410';
  int _p2pSellStarsAmount = 100000;

  // Tab 2 (Buy Stars) State
  late StarPackage _selectedPackage;

  // Tab 3 (Withdraw) State
  double _withdrawAmount = 10.0;
  String _payoutDestination = 'PayPal';
  final TextEditingController _accountTextController =
      TextEditingController(text: 'alex.rivers@email.com');

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _selectedPackage = StarWalletController.packages[1]; // 500K HOT default
  }

  @override
  void dispose() {
    _accountTextController.dispose();
    super.dispose();
  }

  // --- Handlers ---
  Future<void> _handleConvertStars() async {
    final wallet = ref.read(starWalletProvider);
    if (wallet.starBalance < _convertStarsAmount) {
      _showToast('Insufficient stars balance to convert!');
      return;
    }

    setState(() => _isProcessing = true);
    final success = await ref
        .read(starWalletProvider.notifier)
        .convertStarsToDollars(_convertStarsAmount);
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success) {
      final earned = StarWalletController.calculateDollarEquivalent(_convertStarsAmount);
      _showToast('Converted $_convertStarsAmount Stars into +\$${earned.toStringAsFixed(2)} USD! 💰');
    }
  }

  Future<void> _handleP2PSell() async {
    final wallet = ref.read(starWalletProvider);
    if (wallet.starBalance < _p2pSellStarsAmount) {
      _showToast('Insufficient stars balance for P2P sale!');
      return;
    }

    setState(() => _isProcessing = true);
    final dollarReceive =
        StarWalletController.calculateDollarEquivalent(_p2pSellStarsAmount);
    final success = await ref
        .read(starWalletProvider.notifier)
        .sellStarsToUser(
          targetUserId: _targetUserId,
          starsCount: _p2pSellStarsAmount,
          priceDollar: dollarReceive,
        );
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success) {
      _showToast(
        'Successfully sold ${_p2pSellStarsAmount >= 1000 ? "${(_p2pSellStarsAmount / 1000).toInt()}K" : "$_p2pSellStarsAmount"} Stars to $_targetUserId for +\$${dollarReceive.toStringAsFixed(2)} USD! 🤝',
      );
    }
  }

  Future<void> _handleBuyStars() async {
    setState(() => _isProcessing = true);
    final success = await ref
        .read(starWalletProvider.notifier)
        .purchaseWithDollar(_selectedPackage);
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success) {
      _showToast(
        'Purchased ${_selectedPackage.formattedStars} Stars (${_selectedPackage.formattedPrice} USD)! ⭐',
      );
    }
  }

  Future<void> _handleWithdraw() async {
    final wallet = ref.read(starWalletProvider);
    if (wallet.dollarBalance < _withdrawAmount) {
      _showToast('Insufficient cash balance to withdraw!');
      return;
    }

    setState(() => _isProcessing = true);
    final success = await ref.read(starWalletProvider.notifier).withdrawCash(
          amountDollar: _withdrawAmount,
          payoutMethod: _payoutDestination,
          accountDetails: _accountTextController.text.trim(),
        );
    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (success) {
      _showToast(
        'Withdrawal of \$${_withdrawAmount.toStringAsFixed(2)} to $_payoutDestination submitted! 🏛️',
      );
    }
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF161A28),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showHistorySheet(StarWalletState wallet) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0C101C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Transaction History',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: wallet.transactions.isEmpty
                    ? const Center(
                        child: Text(
                          'No transactions yet.',
                          style: TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: wallet.transactions.length,
                        itemBuilder: (_, i) {
                          final tx = wallet.transactions[i];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF14192B),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      tx.title,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                                    ),
                                    if (tx.note != null)
                                      Text(
                                        tx.note!,
                                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                                      ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (tx.formattedStarsDelta.isNotEmpty)
                                      Text(
                                        tx.formattedStarsDelta,
                                        style: const TextStyle(
                                          color: Color(0xFFFFDF00),
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    if (tx.formattedDollarDelta.isNotEmpty)
                                      Text(
                                        tx.formattedDollarDelta,
                                        style: const TextStyle(
                                          color: Color(0xFF00E676),
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(starWalletProvider);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.95,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0A0D18),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0x33FFD700), width: 1.2),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top Drag Handle
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Top Bar: [Wallet Icon] Tivoo Star Wallet + [History]
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFDF00),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Tivoo Star Wallet',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showHistorySheet(wallet),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF172036),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.history_rounded, color: Colors.white70, size: 15),
                          SizedBox(width: 4),
                          Text(
                            'History',
                            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Scrollable Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding > 0 ? bottomPadding + 14 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Balance Card
                    _buildBalanceCard(wallet),
                    const SizedBox(height: 14),

                    // 4 Pill Tabs Row: [Convert] [P2P Sales] [Buy Stars] [Withdraw]
                    _buildPillTabsRow(),
                    const SizedBox(height: 16),

                    // Active Tab Content
                    if (_activeTab == 0) _buildConvertTab(wallet),
                    if (_activeTab == 1) _buildP2PSalesTab(wallet),
                    if (_activeTab == 2) _buildBuyStarsTab(),
                    if (_activeTab == 3) _buildWithdrawTab(wallet),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Balance Card (Exact match with Screenshots)
  // ---------------------------------------------------------------------------
  Widget _buildBalanceCard(StarWalletState wallet) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10162A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x33FFDF00), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Left: Star Balance
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFDF00),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star_rounded, color: Colors.black, size: 24),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Star Balance',
                            style: TextStyle(color: Color(0xFF8E9BB5), fontSize: 11, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            wallet.formattedBalance,
                            style: const TextStyle(
                              color: Color(0xFFFFDF00),
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Vertical Divider
              Container(width: 1, height: 38, color: Colors.white12),

              // Right: Cash Balance
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFF00E676),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.attach_money_rounded, color: Colors.black, size: 22),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cash Balance',
                              style: TextStyle(color: Color(0xFF8E9BB5), fontSize: 11, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              wallet.formattedDollarBalance,
                              style: const TextStyle(
                                color: Color(0xFF00E676),
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Bottom Strip: [Shield] Account: UID-8492... | Rate: 100K ⭐ = $1.00 USD
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF090D1A),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.verified_user_rounded, color: Color(0xFFFFDF00), size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Account: ${wallet.userId}',
                          style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Rate: 100K ⭐ = \$1.00 USD',
                  style: TextStyle(
                    color: Color(0xFFFFDF00),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 4 Pill Tabs Row: [Convert] [P2P Sales] [Buy Stars] [Withdraw]
  // ---------------------------------------------------------------------------
  Widget _buildPillTabsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildPillTabItem(index: 0, label: 'Convert', icon: Icons.swap_horiz_rounded),
          const SizedBox(width: 8),
          _buildPillTabItem(index: 1, label: 'P2P Sales', icon: Icons.handshake_outlined),
          const SizedBox(width: 8),
          _buildPillTabItem(index: 2, label: 'Buy Stars', icon: Icons.shopping_cart_outlined),
          const SizedBox(width: 8),
          _buildPillTabItem(index: 3, label: 'Withdraw', icon: Icons.payments_outlined),
        ],
      ),
    );
  }

  Widget _buildPillTabItem({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFDF00) : const Color(0xFF14192B),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFDF00) : Colors.white10,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.black : Colors.white70,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 0: Convert (Matches Screenshot 1)
  // ===========================================================================
  Widget _buildConvertTab(StarWalletState wallet) {
    final receiveDollars =
        StarWalletController.calculateDollarEquivalent(_convertStarsAmount);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1528),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E2742)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          const Row(
            children: [
              Icon(Icons.monetization_on_rounded, color: Color(0xFFFFDF00), size: 22),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Convert Collected Stars into USD',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Convert your stars to real dollars that you can withdraw or use for P2P purchases.',
            style: TextStyle(color: Color(0xFF8E9BB5), fontSize: 12, height: 1.3),
          ),
          const SizedBox(height: 16),

          // Select Stars to Convert:
          const Text(
            'Select Stars to Convert:',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),

          // 3 chips: 50K, 100K, 200K
          Row(
            children: [
              Expanded(child: _buildConvertChoiceChip('50K Stars', 50000)),
              const SizedBox(width: 8),
              Expanded(child: _buildConvertChoiceChip('100K Stars', 100000)),
              const SizedBox(width: 8),
              Expanded(child: _buildConvertChoiceChip('200K Stars', 200000)),
            ],
          ),
          const SizedBox(height: 8),
          // Full width: All (wallet balance) Stars
          GestureDetector(
            onTap: () => setState(() => _convertStarsAmount = wallet.starBalance),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _convertStarsAmount == wallet.starBalance
                    ? const Color(0x33FFDF00)
                    : const Color(0xFF14192B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _convertStarsAmount == wallet.starBalance
                      ? const Color(0xFFFFDF00)
                      : Colors.white12,
                ),
              ),
              child: Center(
                child: Text(
                  'All (${wallet.formattedBalance}) Stars',
                  style: TextStyle(
                    color: _convertStarsAmount == wallet.starBalance
                        ? const Color(0xFFFFDF00)
                        : Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Result Box (Green themed with Instant Payout)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF091416),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0x5500E676)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'You will receive (USD):',
                        style: TextStyle(color: Color(0xFF8E9BB5), fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+\$${receiveDollars.toStringAsFixed(2)} USD',
                        style: const TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0x2200E676),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0x6600E676)),
                  ),
                  child: const Text(
                    'Instant Payout',
                    style: TextStyle(color: Color(0xFF00E676), fontSize: 11, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Big Yellow Button: Convert Stars to $X.XX USD Now
          ElevatedButton(
            onPressed: _isProcessing ? null : _handleConvertStars,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFDF00),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              elevation: 4,
            ),
            child: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                  )
                : Text(
                    'Convert Stars to \$${receiveDollars.toStringAsFixed(2)} USD Now',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildConvertChoiceChip(String label, int amount) {
    final isSelected = _convertStarsAmount == amount;
    return GestureDetector(
      onTap: () => setState(() => _convertStarsAmount = amount),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x33FFDF00) : const Color(0xFF14192B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFDF00) : Colors.white12,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFFFDF00) : Colors.white,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 1: P2P Sales (Matches Screenshot 2)
  // ===========================================================================
  Widget _buildP2PSalesTab(StarWalletState wallet) {
    final receiveDollars =
        StarWalletController.calculateDollarEquivalent(_p2pSellStarsAmount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-tabs: [Sell Stars to Person] [Peer Offers (4)]
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _p2pSubTab = 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _p2pSubTab == 0 ? Colors.transparent : const Color(0xFF14192B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _p2pSubTab == 0 ? const Color(0xFFFFDF00) : Colors.white12,
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Sell Stars to Person',
                      style: TextStyle(
                        color: _p2pSubTab == 0 ? const Color(0xFFFFDF00) : Colors.white70,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _p2pSubTab = 1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _p2pSubTab == 1 ? Colors.transparent : const Color(0xFF14192B),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _p2pSubTab == 1 ? const Color(0xFFFFDF00) : Colors.white12,
                      width: 1.2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Peer Offers (${wallet.p2pMarketplace.length})',
                      style: TextStyle(
                        color: _p2pSubTab == 1 ? const Color(0xFFFFDF00) : Colors.white70,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        if (_p2pSubTab == 0) ...[
          // Direct P2P Star Sale Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1528),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF1E2742)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    Icon(Icons.group_rounded, color: Color(0xFFFFDF00), size: 22),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Direct P2P Star Sale',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'If another person needs stars, transfer them directly and get paid in USD.',
                  style: TextStyle(color: Color(0xFF8E9BB5), fontSize: 12, height: 1.3),
                ),
                const SizedBox(height: 14),

                // Buyer / Counterparty User ID:
                const Text(
                  'Buyer / Counterparty User ID:',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161E34),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.badge_outlined, color: Color(0xFFFFDF00), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _targetUserId,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Quick Pick Chips: UID-928410 (Elena), UID-718293 (Marcus), etc.
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildUserQuickChip('UID-928410', 'Elena'),
                      _buildUserQuickChip('UID-718293', 'Marcus'),
                      _buildUserQuickChip('UID-519284', 'Sophia'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Stars to Sell:
                const Text(
                  'Stars to Sell:',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildP2PSellChip('50K Stars', 50000)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildP2PSellChip('100K Stars', 100000)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildP2PSellChip('250K Stars', 250000)),
                  ],
                ),
                const SizedBox(height: 16),

                // Buyer Pays (You Receive):
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141C30),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Buyer Pays (You Receive):',
                          style: TextStyle(color: Color(0xFF8E9BB5), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        '+\$${receiveDollars.toStringAsFixed(2)} USD',
                        style: const TextStyle(
                          color: Color(0xFF00E676),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Button: Sell 100K Stars for $1.00 USD
                ElevatedButton(
                  onPressed: _isProcessing ? null : _handleP2PSell,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFDF00),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                    elevation: 4,
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : Text(
                          'Sell ${_p2pSellStarsAmount >= 1000 ? "${(_p2pSellStarsAmount / 1000).toInt()}K" : "$_p2pSellStarsAmount"} Stars for \$${receiveDollars.toStringAsFixed(2)} USD',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                        ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Peer Offers (Marketplace)
          ...wallet.p2pMarketplace.map((offer) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0F1528),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF1E2742)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      color: Color(0x33FFDF00),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star_rounded, color: Color(0xFFFFDF00), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${offer.formattedStars} Stars (${offer.sellerName})',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Rating: ${offer.rating} ⭐ • ${offer.totalSales} sales',
                          style: const TextStyle(color: Color(0xFF8E9BB5), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final success = await ref
                          .read(starWalletProvider.notifier)
                          .buyFromPeer(offer);
                      if (success) {
                        _showToast('Purchased ${offer.formattedStars} Stars from ${offer.sellerName}! 🎉');
                      } else {
                        _showToast('Insufficient USD balance to buy this peer offer!');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFDF00),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      offer.formattedPrice,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }

  Widget _buildUserQuickChip(String uid, String name) {
    final isSelected = _targetUserId == uid;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _targetUserId = uid),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0x33FFDF00) : const Color(0xFF14192B),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? const Color(0xFFFFDF00) : Colors.white12,
            ),
          ),
          child: Text(
            '$uid ($name)',
            style: TextStyle(
              color: isSelected ? const Color(0xFFFFDF00) : Colors.white70,
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildP2PSellChip(String label, int amount) {
    final isSelected = _p2pSellStarsAmount == amount;
    return GestureDetector(
      onTap: () => setState(() => _p2pSellStarsAmount = amount),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x33FFDF00) : const Color(0xFF14192B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFDF00) : Colors.white12,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFFFFDF00) : Colors.white,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 2: Buy Stars (Matches Screenshot 3)
  // ===========================================================================
  Widget _buildBuyStarsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 5 Package Cards (Vertical list matching Screenshot 3)
        ...StarWalletController.packages.map((pkg) {
          final isSelected = _selectedPackage.id == pkg.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedPackage = pkg),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF161E34) : const Color(0xFF0F1528),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFFFDF00) : const Color(0xFF1E2842),
                    width: isSelected ? 1.8 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Color(0x33FFDF00),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    // Star Icon in Yellow Circle
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFDF00),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.star_rounded, color: Colors.black, size: 28),
                    ),
                    const SizedBox(width: 14),

                    // Title & Subtitle + HOT badge
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '${pkg.formattedStars} Stars',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (pkg.isPopular) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF2D55),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'HOT',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            pkg.badge,
                            style: const TextStyle(
                              color: Color(0xFF8E9BB5),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Price Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFDF00),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        pkg.formattedPrice,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 12),

        // Big Yellow Button: Pay $X.XX USD for XXX Stars
        ElevatedButton(
          onPressed: _isProcessing ? null : _handleBuyStars,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFDF00),
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
            elevation: 4,
          ),
          child: _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                )
              : Text(
                  'Pay ${_selectedPackage.formattedPrice} USD for ${_selectedPackage.formattedStars} Stars',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
        ),
      ],
    );
  }

  // ===========================================================================
  // TAB 3: Withdraw (Matches Screenshot 4)
  // ===========================================================================
  Widget _buildWithdrawTab(StarWalletState wallet) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1528),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E2742)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: [Bank] Cash Out USD Balance
          const Row(
            children: [
              Icon(Icons.account_balance_rounded, color: Color(0xFF00E676), size: 22),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Cash Out USD Balance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Available: ${wallet.formattedDollarBalance} USD',
            style: const TextStyle(color: Color(0xFF00E676), fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),

          // Select Withdrawal Amount:
          const Text(
            'Select Withdrawal Amount:',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildWithdrawChoiceChip('\$5', 5.0),
                const SizedBox(width: 8),
                _buildWithdrawChoiceChip('\$10', 10.0),
                const SizedBox(width: 8),
                _buildWithdrawChoiceChip('\$20', 20.0),
                const SizedBox(width: 8),
                _buildWithdrawChoiceChip('All (${wallet.formattedDollarBalance})', wallet.dollarBalance),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Payout Destination:
          const Text(
            'Payout Destination:',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _buildPayoutDestinationCard('PayPal', Icons.credit_card_rounded)),
              const SizedBox(width: 8),
              Expanded(child: _buildPayoutDestinationCard('Bank', Icons.account_balance_rounded)),
              const SizedBox(width: 8),
              Expanded(child: _buildPayoutDestinationCard('Card', Icons.payment_rounded)),
            ],
          ),
          const SizedBox(height: 16),

          // Account / Email / IBAN:
          const Text(
            'Account / Email / IBAN:',
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF161E34),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(Icons.mail_outline_rounded, color: Color(0xFF00E676), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _accountTextController,
                    style: const TextStyle(color: Colors.white, fontSize: 13.5),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter payment account details',
                      hintStyle: TextStyle(color: Colors.white38),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Big Green Button: Withdraw $10.00 USD Now
          ElevatedButton(
            onPressed: _isProcessing ? null : _handleWithdraw,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              elevation: 4,
            ),
            child: _isProcessing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                  )
                : Text(
                    'Withdraw \$${_withdrawAmount.toStringAsFixed(2)} USD Now',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawChoiceChip(String label, double amount) {
    final isSelected = (_withdrawAmount - amount).abs() < 0.01;
    return GestureDetector(
      onTap: () => setState(() => _withdrawAmount = amount),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x3300E676) : const Color(0xFF14192B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF00E676) : Colors.white12,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF00E676) : Colors.white,
              fontSize: 11.5,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  Widget _buildPayoutDestinationCard(String name, IconData icon) {
    final isSelected = _payoutDestination == name;
    return GestureDetector(
      onTap: () => setState(() => _payoutDestination = name),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x2200E676) : const Color(0xFF14192B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF00E676) : Colors.white12,
            width: isSelected ? 1.4 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? const Color(0xFF00E676) : Colors.white70, size: 22),
            const SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(
                color: isSelected ? const Color(0xFF00E676) : Colors.white,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
