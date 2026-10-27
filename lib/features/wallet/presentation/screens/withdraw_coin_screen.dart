import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/wallet_controller.dart';
import '../../models/wallet_models.dart';
import '../widgets/wallet_widgets.dart';
import 'withdrawal_status_screen.dart';

class WithdrawCoinScreen extends ConsumerStatefulWidget {
  const WithdrawCoinScreen({super.key});

  @override
  ConsumerState<WithdrawCoinScreen> createState() => _WithdrawCoinScreenState();
}

class _WithdrawCoinScreenState extends ConsumerState<WithdrawCoinScreen> {
  late final TextEditingController _amountController;
  int _currentAmount = 100; // default matching reference image 5
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
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

  void _setMax(int maxVal) {
    setState(() {
      _currentAmount = maxVal;
      _amountController.text = '$maxVal';
    });
  }

  void _showAddBankDialog(BuildContext context) {
    final bankNameController = TextEditingController();
    final accNumberController = TextEditingController();
    final ifscController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            color: Color(0xFF101438),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: Color(0xFF4C36ED), width: 1.5)),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Bank Account',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                _buildInput('Bank Name (e.g. HDFC Bank, ICICI)', bankNameController),
                const SizedBox(height: 12),
                _buildInput('Account Number', accNumberController, isNumber: true),
                const SizedBox(height: 12),
                _buildInput('IFSC Code', ifscController),
                const SizedBox(height: 20),
                WalletActionButton(
                  label: 'Save & Select Bank',
                  onPressed: () {
                    if (bankNameController.text.trim().isNotEmpty &&
                        accNumberController.text.trim().isNotEmpty) {
                      final newBank = BankAccount(
                        id: 'bank-${DateTime.now().millisecondsSinceEpoch}',
                        bankName: bankNameController.text.trim(),
                        accountNumber: accNumberController.text.trim(),
                        ifscCode: ifscController.text.trim().isEmpty ? 'N/A' : ifscController.text.trim(),
                        accountHolder: 'User Account',
                      );
                      ref.read(walletProvider.notifier).addBankAccount(newBank);
                      Navigator.of(ctx).pop();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(String hint, TextEditingController ctrl, {bool isNumber = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF070921),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E2856)),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: GoogleFonts.outfit(color: WalletPalette.textMuted, fontSize: 13),
        ),
      ),
    );
  }

  Future<void> _handleWithdraw(BankAccount bank) async {
    FocusScope.of(context).unfocus();
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    final gross = _currentAmount * 0.50;
    const fee = 2.00;
    final payout = (gross - fee).clamp(0.0, double.infinity);

    final tx = ref.read(walletProvider.notifier).withdrawTCoin(
          tCoinsToWithdraw: _currentAmount,
          bank: bank,
        );

    setState(() => _isProcessing = false);

    if (tx != null) {
      FocusScope.of(context).unfocus();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => WithdrawalStatusScreen(
            transaction: tx,
            bankAccount: bank,
            tCoinsAmount: _currentAmount,
            payoutAmount: payout,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);
    final bank = wallet.primaryBank;

    final grossAmount = _currentAmount * 0.50;
    const fee = 2.00;
    final estimatedPayout = (grossAmount - fee).clamp(0.0, double.infinity);

    final isValid = _currentAmount >= 100 &&
        _currentAmount <= wallet.tCoinBalance &&
        bank != null;

    return WalletScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Withdraw T Coin',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 20,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance Card matching reference image 5
                  WalletNeonCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    borderColor: const Color(0xFF24326A),
                    child: Row(
                      children: [
                        const TCoinIcon(size: 46),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Withdrawable T Coins',
                                style: GoogleFonts.outfit(
                                  color: WalletPalette.textSecondary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                wallet.formattedTCoinBalance,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '≈ ₹${wallet.tCoinInrValue.toStringAsFixed(2)}',
                                style: GoogleFonts.outfit(
                                  color: WalletPalette.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Conversion Rate Info text
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      '1 T Coin = ₹0.50\nMin. withdrawal: 100 T Coins',
                      style: GoogleFonts.outfit(
                        color: WalletPalette.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Enter Amount Card matching reference image 5
                  WalletNeonCard(
                    padding: const EdgeInsets.all(16),
                    borderColor: const Color(0xFF24326A),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enter Amount',
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
                                onTap: () => _setMax(wallet.tCoinBalance),
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
                        const SizedBox(height: 8),
                        Text(
                          '≈ ₹${grossAmount.toStringAsFixed(2)}',
                          style: GoogleFonts.outfit(
                            color: WalletPalette.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Select Bank Account Card matching reference image 5
                  Text(
                    'Select Bank Account',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (bank != null)
                    WalletNeonCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      borderColor: const Color(0xFF24326A),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF4C36ED).withValues(alpha: 0.2),
                              border: Border.all(color: const Color(0xFF4C36ED)),
                            ),
                            child: const Icon(
                              Icons.account_balance_rounded,
                              color: Color(0xFF7A6BFF),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  bank.bankName,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  bank.maskedNumber,
                                  style: GoogleFonts.outfit(
                                    color: WalletPalette.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: WalletPalette.textSecondary,
                            size: 16,
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _showAddBankDialog(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.add_rounded, color: WalletPalette.electricBlue, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            '+ Add Bank Account',
                            style: GoogleFonts.outfit(
                              color: WalletPalette.electricBlue,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Withdrawal Summary Card matching reference image 5
                  WalletNeonCard(
                    padding: const EdgeInsets.all(16),
                    borderColor: const Color(0xFF24326A),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Withdrawal Summary',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildSummaryLine('T Coins Requested', '$_currentAmount'),
                        const SizedBox(height: 6),
                        _buildSummaryLine('Gross Amount (₹0.50)', '₹${grossAmount.toStringAsFixed(2)}'),
                        const SizedBox(height: 6),
                        _buildSummaryLine('Fee (₹2.00)', '- ₹${fee.toStringAsFixed(2)}'),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Divider(color: Color(0xFF1E2856), height: 1),
                        ),
                        _buildSummaryLine(
                          'Estimated Payout',
                          '₹${estimatedPayout.toStringAsFixed(2)}',
                          isHighlight: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Review Withdrawal Button
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
            child: WalletActionButton(
              label: 'Review Withdrawal',
              isLoading: _isProcessing,
              onPressed: isValid
                  ? () => _handleWithdraw(bank)
                  : null,
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildSummaryLine(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            color: WalletPalette.textSecondary,
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: isHighlight ? WalletPalette.goldAccent : Colors.white,
            fontSize: isHighlight ? 16 : 13,
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
