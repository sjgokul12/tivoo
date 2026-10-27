import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../live_stream/presentation/controllers/star_wallet_controller.dart';

/// Modal dialog that appears after a gift 3D animation ends, showing:
/// - Gift sent details (artwork, name, quantity, recipient)
/// - Deducted stars (-X ⭐)
/// - Updated remaining wallet balance (Y ⭐)
/// - Option to "Send More Gifts" or close.
class GiftBalanceDetailsDialog extends ConsumerWidget {
  final dynamic gift;
  final int quantity;
  final String recipient;
  final int deductedStars;
  final VoidCallback? onSendMore;

  const GiftBalanceDetailsDialog({
    super.key,
    required this.gift,
    required this.quantity,
    required this.recipient,
    required this.deductedStars,
    this.onSendMore,
  });

  static Future<void> show({
    required BuildContext context,
    required dynamic gift,
    required int quantity,
    required String recipient,
    required int deductedStars,
    VoidCallback? onSendMore,
  }) {
    HapticFeedback.mediumImpact();
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'GiftBalanceDetails',
      barrierColor: Colors.black.withValues(alpha: 0.72),
      transitionDuration: const Duration(milliseconds: 360),
      pageBuilder: (ctx, anim1, anim2) => Center(
        child: GiftBalanceDetailsDialog(
          gift: gift,
          quantity: quantity,
          recipient: recipient,
          deductedStars: deductedStars,
          onSendMore: onSendMore,
        ),
      ),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curved = CurvedAnimation(parent: anim1, curve: Curves.easeOutBack);
        return ScaleTransition(
          scale: curved,
          child: FadeTransition(
            opacity: anim1,
            child: child,
          ),
        );
      },
    );
  }

  String _formatCost(int cost) {
    return cost.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(starWalletProvider);
    final String giftName = gift.name ?? 'Gift';
    final String giftIcon = gift.icon ?? '🎁';
    final String? giftAsset = gift.imageAssetPath;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final dialogWidth = (screenWidth * 0.90).clamp(280.0, 360.0);
    final dialogMaxHeight = screenHeight * 0.88;

    return Material(
      type: MaterialType.transparency,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: dialogWidth,
          maxHeight: dialogMaxHeight,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E1442), Color(0xFF0F0A28)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFFFFC928).withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFC928).withValues(alpha: 0.25),
              blurRadius: 28,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: const Color(0xFFFF2D78).withValues(alpha: 0.2),
              blurRadius: 36,
              spreadRadius: 4,
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Header with celebration title & close icon
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC928).withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Text('🎉', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(width: 8),
                      const Flexible(
                        child: Text(
                          'Gift Delivered!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white70, size: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Hero Gift Presentation Card with aura
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF281C5C).withValues(alpha: 0.8),
                    const Color(0xFF160E36).withValues(alpha: 0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Gift Artwork or Icon
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFC928).withValues(alpha: 0.3),
                              blurRadius: 24,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      if (giftAsset != null && giftAsset.isNotEmpty)
                        Image.asset(
                          giftAsset,
                          width: 74,
                          height: 74,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => Text(
                            giftIcon,
                            style: const TextStyle(fontSize: 48),
                          ),
                        )
                      else
                        Text(
                          giftIcon,
                          style: const TextStyle(fontSize: 48),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '$giftName x$quantity',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF2D78), Color(0xFF9C27B0)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Sent to $recipient',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Star Balance & Deduction Info Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF130E2E),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFFFC928).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Deducted Stars Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: Text(
                          'Stars Deducted:',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '-${_formatCost(deductedStars)} ⭐',
                        style: const TextStyle(
                          color: Color(0xFFFF5252),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(color: Colors.white12, height: 1),
                  ),
                  // Remaining Wallet Stars Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.account_balance_wallet_outlined, color: Color(0xFFFFC928), size: 16),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Remaining Stars:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_formatCost(wallet.starBalance)} ⭐',
                        style: const TextStyle(
                          color: Color(0xFFFFC928),
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Action Buttons: Send More Gifts & Done
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Done',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF2D78),
                      foregroundColor: Colors.white,
                      elevation: 6,
                      shadowColor: const Color(0x99FF2D78),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onSendMore?.call();
                    },
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('🎁', style: TextStyle(fontSize: 13)),
                          SizedBox(width: 6),
                          Text(
                            'Send More Gifts',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}
