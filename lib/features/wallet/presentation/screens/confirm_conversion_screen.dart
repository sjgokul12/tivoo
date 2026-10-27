import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/wallet_controller.dart';
import '../widgets/wallet_widgets.dart';
import 'conversion_success_screen.dart';

class ConfirmConversionScreen extends ConsumerStatefulWidget {
  final bool isStarToTCoin;
  final int sourceAmount;
  final int targetAmount;
  final int remainingSourceBalance;

  const ConfirmConversionScreen({
    super.key,
    required this.isStarToTCoin,
    required this.sourceAmount,
    required this.targetAmount,
    required this.remainingSourceBalance,
  });

  @override
  ConsumerState<ConfirmConversionScreen> createState() => _ConfirmConversionScreenState();
}

class _ConfirmConversionScreenState extends ConsumerState<ConfirmConversionScreen> {
  bool _isProcessing = false;

  Future<void> _handleConfirm() async {
    FocusScope.of(context).unfocus();
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    final controller = ref.read(walletProvider.notifier);
    final tx = widget.isStarToTCoin
        ? controller.convertStarToTCoin(widget.sourceAmount)
        : controller.convertTCoinToStar(widget.sourceAmount);

    setState(() => _isProcessing = false);

    if (tx != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ConversionSuccessScreen(
            isStarToTCoin: widget.isStarToTCoin,
            sourceAmount: widget.sourceAmount,
            targetAmount: widget.targetAmount,
            remainingSourceBalance: widget.remainingSourceBalance,
            transaction: tx,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final rateText = widget.isStarToTCoin ? '3 Stars = 1 T Coin' : '1 T Coin = 2 Stars';

    return WalletScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Confirm Conversion',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 24,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 12),

                    // Visual Emblem Conversion matching reference image 8
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (widget.isStarToTCoin) ...[
                            const StarIconWidget(size: 56),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF152258),
                                border: Border.all(color: const Color(0xFF2D55B8)),
                              ),
                              child: const Icon(
                                Icons.swap_horiz_rounded,
                                color: Color(0xFF3D7BFF),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const TCoinIcon(size: 56),
                          ] else ...[
                            const TCoinIcon(size: 56),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF152258),
                                border: Border.all(color: const Color(0xFF2D55B8)),
                              ),
                              child: const Icon(
                                Icons.swap_horiz_rounded,
                                color: Color(0xFF3D7BFF),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const StarIconWidget(size: 56),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Details Summary Card matching reference image 8
                    WalletNeonCard(
                      padding: const EdgeInsets.all(18),
                      borderColor: const Color(0xFF24326A),
                      child: Column(
                        children: [
                          _buildSummaryRow(
                            icon: widget.isStarToTCoin
                                ? const StarIconWidget(size: 22)
                                : const TCoinIcon(size: 22),
                            label: widget.isStarToTCoin ? 'Stars to Convert' : 'T Coins to Convert',
                            value: '${widget.sourceAmount}',
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(color: Color(0xFF1E2856), height: 1),
                          ),
                          _buildSummaryRow(
                            icon: widget.isStarToTCoin
                                ? const TCoinIcon(size: 22)
                                : const StarIconWidget(size: 22),
                            label: widget.isStarToTCoin ? 'T Coins to Receive' : 'Stars to Receive',
                            value: '${widget.targetAmount}',
                            isHighlight: true,
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Divider(color: Color(0xFF1E2856), height: 1),
                          ),
                          _buildSummaryRow(
                            icon: widget.isStarToTCoin
                                ? const StarIconWidget(size: 22)
                                : const TCoinIcon(size: 22),
                            label: widget.isStarToTCoin ? 'Remaining Stars' : 'Remaining T Coins',
                            value: '${widget.remainingSourceBalance}',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Rate Info Card matching reference image 8
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: const Color(0xFF0E1236),
                        border: Border.all(color: const Color(0xFF24326A), width: 1.2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Conversion Rate',
                            style: GoogleFonts.outfit(
                              color: WalletPalette.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            rateText,
                            style: GoogleFonts.outfit(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),
                    const SizedBox(height: 16),

                    WalletActionButton(
                      label: 'Confirm',
                      isLoading: _isProcessing,
                      onPressed: _handleConfirm,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow({
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
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: isHighlight ? WalletPalette.goldAccent : Colors.white,
            fontSize: 16,
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
