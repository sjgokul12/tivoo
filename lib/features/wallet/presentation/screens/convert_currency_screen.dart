import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/wallet_controller.dart';
import '../widgets/wallet_widgets.dart';
import 'confirm_conversion_screen.dart';

class ConvertCurrencyScreen extends ConsumerStatefulWidget {
  final bool isStarToTCoin;

  const ConvertCurrencyScreen({super.key, required this.isStarToTCoin});

  @override
  ConsumerState<ConvertCurrencyScreen> createState() => _ConvertCurrencyScreenState();
}

class _ConvertCurrencyScreenState extends ConsumerState<ConvertCurrencyScreen> {
  late final TextEditingController _amountController;
  int _currentAmount = 0;

  @override
  void initState() {
    super.initState();
    // Default initial amount matching reference images:
    // Star to T Coin = 300 (Image 3)
    // T Coin to Star = 100 (Image 4)
    _currentAmount = widget.isStarToTCoin ? 300 : 100;
    _amountController = TextEditingController(text: '$_currentAmount');
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String val) {
    setState(() {
      _currentAmount = int.tryParse(val.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    });
  }

  void _setAmount(int val) {
    setState(() {
      _currentAmount = val;
      _amountController.text = '$val';
    });
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);

    final title = widget.isStarToTCoin ? 'Convert Star to T Coin' : 'Convert T Coin to Star';
    final availableBalance = widget.isStarToTCoin ? wallet.starBalance : wallet.tCoinBalance;
    final chips = widget.isStarToTCoin ? [30, 150, 300, 600, 1500] : [10, 25, 50, 100, 200];

    // Conversion Calculations
    final targetReceived = widget.isStarToTCoin ? _currentAmount ~/ 3 : _currentAmount * 2;
    final remainingBalance = (availableBalance - _currentAmount).clamp(0, availableBalance);
    final isValid = _currentAmount > 0 &&
        _currentAmount <= availableBalance &&
        (!widget.isStarToTCoin || _currentAmount >= 3);

    return WalletScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2E3D75), width: 1.2),
                color: const Color(0xFF0F143A),
              ),
              child: const Center(
                child: Text(
                  '?',
                  style: TextStyle(
                    color: WalletPalette.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            onPressed: () => WalletHelpDialog.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Column(
          children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Column(
                children: [
                  // Available Balance Card matching reference images 3 & 4
                  WalletNeonCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    borderColor: const Color(0xFF24326A),
                    child: Row(
                      children: [
                        if (widget.isStarToTCoin)
                          const StarIconWidget(size: 46)
                        else
                          const TCoinIcon(size: 46),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.isStarToTCoin ? 'Available Stars' : 'Available T Coins',
                              style: GoogleFonts.outfit(
                                color: WalletPalette.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              availableBalance.toString().replaceAllMapped(
                                    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                    (m) => '${m[1]},',
                                  ),
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Exchange Rate Banner Pill matching reference image
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10153D),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF28387A), width: 1.2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.isStarToTCoin) ...[
                          const StarIconWidget(size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '3 Stars = 1 T Coin',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, color: Color(0xFF3D7BFF), size: 16),
                          const SizedBox(width: 8),
                          const TCoinIcon(size: 20),
                        ] else ...[
                          const TCoinIcon(size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '1 T Coin = 2 Stars',
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, color: Color(0xFF3D7BFF), size: 16),
                          const SizedBox(width: 8),
                          const StarIconWidget(size: 20),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Enter Amount Card matching reference image
                  WalletNeonCard(
                    padding: const EdgeInsets.all(16),
                    borderColor: const Color(0xFF24326A),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isStarToTCoin ? 'Enter Star Amount' : 'Enter T Coin Amount',
                          style: GoogleFonts.outfit(
                            color: WalletPalette.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF070921),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFF1E2856), width: 1.2),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _amountController,
                                  keyboardType: TextInputType.number,
                                  onChanged: _onAmountChanged,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '0',
                                    hintStyle: TextStyle(color: Colors.white24),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _setAmount(availableBalance),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF152258),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFF2D55B8)),
                                  ),
                                  child: Text(
                                    'Max',
                                    style: GoogleFonts.outfit(
                                      color: const Color(0xFF3D7BFF),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Quick Select amount',
                          style: GoogleFonts.outfit(
                            color: WalletPalette.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Quick select chips matching reference image
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: chips.map((val) {
                              final isSelected = val == _currentAmount;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () => _setAmount(val),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF1D2866)
                                          : const Color(0xFF0D102E),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFF4361EE)
                                            : const Color(0xFF1C2454),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Text(
                                      val.toString().replaceAllMapped(
                                            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                            (m) => '${m[1]},',
                                          ),
                                      style: GoogleFonts.outfit(
                                        color: isSelected ? Colors.white : WalletPalette.textSecondary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Conversion Preview Card matching reference image
                  WalletNeonCard(
                    padding: const EdgeInsets.all(16),
                    borderColor: const Color(0xFF24326A),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Conversion Preview',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildPreviewItem(
                          icon: widget.isStarToTCoin
                              ? const StarIconWidget(size: 22)
                              : const TCoinIcon(size: 22),
                          label: widget.isStarToTCoin ? 'Stars to Convert' : 'T Coins to Convert',
                          value: '$_currentAmount',
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(color: Color(0xFF1E2856), height: 1),
                        ),
                        _buildPreviewItem(
                          icon: widget.isStarToTCoin
                              ? const TCoinIcon(size: 22)
                              : const StarIconWidget(size: 22),
                          label: widget.isStarToTCoin ? 'T Coins to Receive' : 'Stars to Receive',
                          value: '$targetReceived',
                          isHighlight: true,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(color: Color(0xFF1E2856), height: 1),
                        ),
                        _buildPreviewItem(
                          icon: widget.isStarToTCoin
                              ? const StarIconWidget(size: 22)
                              : const TCoinIcon(size: 22),
                          label: widget.isStarToTCoin ? 'Remaining Stars' : 'Remaining T Coins',
                          value: remainingBalance.toString().replaceAllMapped(
                                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                (m) => '${m[1]},',
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Review Conversion Button
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
            child: WalletActionButton(
              label: 'Review Conversion',
              onPressed: isValid
                  ? () {
                      FocusScope.of(context).unfocus();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ConfirmConversionScreen(
                            isStarToTCoin: widget.isStarToTCoin,
                            sourceAmount: _currentAmount,
                            targetAmount: targetReceived,
                            remainingSourceBalance: remainingBalance,
                          ),
                        ),
                      );
                    }
                  : null,
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildPreviewItem({
    required Widget icon,
    required String label,
    required String value,
    bool isHighlight = false,
  }) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.outfit(
              color: WalletPalette.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: isHighlight ? WalletPalette.goldAccent : Colors.white,
            fontSize: 15,
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
