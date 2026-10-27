import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/wallet_controller.dart';
import '../../models/wallet_models.dart';
import '../widgets/wallet_widgets.dart';
import 'purchase_success_screen.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final StarPackage package;

  const PaymentScreen({super.key, required this.package});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  int _selectedMethodIndex = 0;
  bool _isProcessing = false;

  final List<Map<String, dynamic>> _methods = [
    {
      'title': 'UPI',
      'subtitle': '(Google Pay, PhonePe, Paytm)',
      'icon': Icons.flash_on_rounded,
      'color': Color(0xFF6366F1),
    },
    {
      'title': 'Credit / Debit Card',
      'subtitle': 'Visa, Mastercard, RuPay',
      'icon': Icons.credit_card_rounded,
      'color': Color(0xFF3B82F6),
    },
    {
      'title': 'Net Banking',
      'subtitle': 'All major Indian banks supported',
      'icon': Icons.account_balance_rounded,
      'color': Color(0xFF10B981),
    },
    {
      'title': 'Wallet',
      'subtitle': 'Paytm, Amazon Pay, MobiKwik',
      'icon': Icons.account_balance_wallet_rounded,
      'color': Color(0xFFF59E0B),
    },
  ];

  Future<void> _handlePayment() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    final methodName = _methods[_selectedMethodIndex]['title'] as String;
    final tx = ref.read(walletProvider.notifier).buyStars(
          package: widget.package,
          paymentMethod: methodName,
        );

    setState(() => _isProcessing = false);
    FocusScope.of(context).unfocus();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PurchaseSuccessScreen(
          package: widget.package,
          paymentMethod: methodName,
          transaction: tx,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WalletScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Payment',
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
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selected Package Card matching reference image 6
                  WalletNeonCard(
                    padding: const EdgeInsets.all(16),
                    borderColor: const Color(0xFF24326A),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Package',
                          style: GoogleFonts.outfit(
                            color: WalletPalette.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const StarIconWidget(size: 34),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${widget.package.formattedStars} Stars',
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Text(
                              widget.package.formattedPrice,
                              style: GoogleFonts.outfit(
                                color: WalletPalette.goldAccent,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'Choose Payment Method',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Payment options list matching reference image 6
                  ...List.generate(_methods.length, (index) {
                    final method = _methods[index];
                    final isSelected = index == _selectedMethodIndex;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedMethodIndex = index);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF4C36ED)
                                  : const Color(0xFF24326A),
                              width: isSelected ? 1.6 : 1.2,
                            ),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: isSelected
                                  ? const Color(0xFF161942)
                                  : const Color(0xFF0E1130),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: (method['color'] as Color).withValues(alpha: 0.15),
                                    border: Border.all(
                                      color: (method['color'] as Color).withValues(alpha: 0.5),
                                    ),
                                  ),
                                  child: Icon(
                                    method['icon'] as IconData,
                                    color: method['color'] as Color,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        method['title'] as String,
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        method['subtitle'] as String,
                                        style: GoogleFonts.outfit(
                                          color: WalletPalette.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF4C36ED)
                                          : const Color(0xFF3B4877),
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Center(
                                          child: Container(
                                            width: 12,
                                            height: 12,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              gradient: WalletPalette.primaryButton,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Bottom Bar matching reference image 6
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: const BoxDecoration(
              color: Color(0xFF0B0E2A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                top: BorderSide(color: Color(0xFF24326A), width: 1.2),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount',
                      style: GoogleFonts.outfit(
                        color: WalletPalette.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      widget.package.formattedPrice,
                      style: GoogleFonts.outfit(
                        color: WalletPalette.goldAccent,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                WalletActionButton(
                  label: 'Pay Now',
                  isLoading: _isProcessing,
                  onPressed: _handlePayment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
