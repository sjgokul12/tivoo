import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/responsive.dart';
import 'gift_options.dart';

/// Tiki Live Gift Bottom Sheet with complete Coin Top-Up Flow matching Image 2:
/// - Screen 4 & 8: Gift Store with Coin balance (`🪙 350 +`), tabs (`All`, `Popular`, `Luxury`, `Love`),
///   quantity counter (`[- 1 +]`), and Send / Recharge buttons.
/// - Screen 6: "Buy Coins" Pack selector sheet (`70 Coins ₹49`, `350 Coins ₹249 Popular`, etc.).
/// - Screen 5: "Top Up Coins" Payment Method sheet (Google Pay, PhonePe, Paytm, UPI, Cards, Net Banking).
/// - Screen 7: "Payment Successful!" popup dialog with 3D coin stack illustration.
class GiftBottomSheet extends StatefulWidget {
  final Function(GiftItem gift) onGiftSelected;
  final Function(GiftItem gift, int quantity)? onGiftWithQuantitySelected;
  final List<String>? recipients;
  final String? initialRecipient;
  final Function(GiftItem gift, int quantity, String recipient)? onGiftWithRecipientSelected;

  const GiftBottomSheet({
    super.key,
    required this.onGiftSelected,
    this.onGiftWithQuantitySelected,
    this.recipients,
    this.initialRecipient,
    this.onGiftWithRecipientSelected,
  });

  static void show(
    BuildContext context,
    Function(GiftItem gift) onGiftSelected, {
    Function(GiftItem gift, int quantity)? onGiftWithQuantitySelected,
    List<String>? recipients,
    String? initialRecipient,
    Function(GiftItem gift, int quantity, String recipient)? onGiftWithRecipientSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => GiftBottomSheet(
        onGiftSelected: onGiftSelected,
        onGiftWithQuantitySelected: onGiftWithQuantitySelected,
        recipients: recipients,
        initialRecipient: initialRecipient,
        onGiftWithRecipientSelected: onGiftWithRecipientSelected,
      ),
    );
  }

  @override
  State<GiftBottomSheet> createState() => _GiftBottomSheetState();
}

class _GiftBottomSheetState extends State<GiftBottomSheet> {
  late GiftItem _selectedGift;
  late String _selectedRecipient;
  int _coinBalance = 99999; // Generous balance so user can test all 3D stickers freely!
  int _quantity = 1;
  String _selectedCategory = 'All';
  bool _showPreviewAndSend = false;

  final List<String> _categories = GiftCategoryOption.labels;

  @override
  void initState() {
    super.initState();
    _selectedGift = GiftCatalog.virtualGifts.first;
    _selectedRecipient = widget.initialRecipient ??
        (widget.recipients != null && widget.recipients!.isNotEmpty
            ? widget.recipients!.first
            : 'Host');
  }

  List<GiftItem> _getFilteredGifts() {
    return GiftCatalog.filterByCategory(_selectedCategory);
  }

  void _handleGiftTap(GiftItem gift) {
    setState(() {
      _selectedGift = gift;
      _showPreviewAndSend = true;
    });
  }

  void _sendSelectedGift() {
    final totalCost = _selectedGift.diamonds * _quantity;
    // Allow user to freely send and test any 3D sticker as requested
    if (_coinBalance < totalCost) {
      _coinBalance = 99999;
    }

    setState(() {
      _coinBalance -= totalCost;
    });

    Navigator.pop(context);
    if (widget.onGiftWithRecipientSelected != null) {
      widget.onGiftWithRecipientSelected!(_selectedGift, _quantity, _selectedRecipient);
    } else if (widget.onGiftWithQuantitySelected != null) {
      widget.onGiftWithQuantitySelected!(_selectedGift, _quantity);
    } else {
      widget.onGiftSelected(_selectedGift);
    }
  }

  // ===========================================================================
  // SCREEN 6: Buy Coins Sheet (Coin Packs)
  // ===========================================================================
  void _showBuyCoinsSheet(BuildContext parentContext) {
    final packs = CoinPackOption.standardPacks.map((p) => {
      'coins': p.coins,
      'price': p.price,
      'isPopular': p.isPopular,
    }).toList();

    showModalBottomSheet(
      context: parentContext,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.76,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: const BoxDecoration(
            color: Color(0xFF0E0B2C),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: Color(0x55FFC928), width: 1.5)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 14),

                // Top bar: < Buy Coins
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'Buy Coins',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // List of Coin Packs matching Image 2 Screen 6
                Expanded(
                  child: ListView.builder(
                    itemCount: packs.length,
                    itemBuilder: (c, idx) {
                      final p = packs[idx];
                      final isPop = p['isPopular'] as bool;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1548),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isPop ? const Color(0xFFFFC928) : Colors.white12,
                            width: isPop ? 1.8 : 1.0,
                          ),
                          boxShadow: isPop
                              ? const [
                                  BoxShadow(
                                    color: Color(0x33FFC928),
                                    blurRadius: 10,
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          children: [
                            // 3D Coin Graphic
                            Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [Color(0xFFFFE680), Color(0xFFE59A00)],
                                ),
                              ),
                              child: const Center(
                                child: Text('🪙', style: TextStyle(fontSize: 20)),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Coins amount + Popular badge
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    '${p['coins']} Coins',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (isPop) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFF2D78),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Text(
                                        'Popular',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // Price Button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isPop ? const Color(0xFFFFC928) : Colors.white12,
                                foregroundColor: isPop ? Colors.black : Colors.white,
                                elevation: isPop ? 4 : 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);
                                _showPaymentMethodSheet(parentContext, p);
                              },
                              child: Text(
                                p['price'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: isPop ? Colors.black : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom banner: More Coins More Gifts More Fun ♡
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2E124D), Color(0xFF1E0E33)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x66BA43F6)),
                  ),
                  child: const Center(
                    child: Text(
                      'More Coins   More Gifts   More Fun ♡',
                      style: TextStyle(
                        color: Color(0xFFFFC928),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // SCREEN 5: Choose Payment Method Sheet ("Top Up Coins")
  // ===========================================================================
  void _showPaymentMethodSheet(BuildContext parentContext, Map<String, dynamic> pack) {
    String selectedMethod = 'Google Pay';

    final methods = [
      {'name': 'Google Pay', 'icon': '🟢'},
      {'name': 'PhonePe', 'icon': '🟣'},
      {'name': 'Paytm', 'icon': '🔵'},
      {'name': 'UPI', 'icon': '⚡'},
      {'name': 'Credit / Debit Card', 'icon': '💳'},
      {'name': 'Net Banking', 'icon': '🏦'},
    ];

    showModalBottomSheet(
      context: parentContext,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF0E0B2C),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(top: BorderSide(color: Color(0x55FFC928), width: 1.5)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Top Up Coins header with Stack of Coins
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(ctx),
                          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'Top Up Coins',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 3D Gold Coins stack illustration
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1548),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0x33FFC928)),
                      ),
                      child: Column(
                        children: [
                          const Text('🪙 🪙 🪙', style: TextStyle(fontSize: 36)),
                          const SizedBox(height: 4),
                          Text(
                            '${pack['coins']} Coins for ${pack['price']}',
                            style: const TextStyle(
                              color: Color(0xFFFFC928),
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Payment Method Options
                    ...methods.map((m) {
                      final isSel = selectedMethod == m['name'];
                      return GestureDetector(
                        onTap: () => setModalState(() => selectedMethod = m['name'] as String),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFF241B5C) : const Color(0xFF171340),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSel ? const Color(0xFFFFC928) : Colors.white12,
                              width: isSel ? 1.5 : 0.8,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(m['icon'] as String, style: const TextStyle(fontSize: 18)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  m['name'] as String,
                                  style: TextStyle(
                                    color: isSel ? Colors.white : Colors.white70,
                                    fontSize: 14,
                                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                              ),
                              Icon(
                                isSel ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: isSel ? const Color(0xFFFFC928) : Colors.white38,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 14),

                    // Pink / Cyber Yellow "Continue" Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF2D78),
                          foregroundColor: Colors.white,
                          elevation: 6,
                          shadowColor: const Color(0x99FF2D78),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showPaymentSuccessDialog(parentContext, pack['coins'] as int);
                        },
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ===========================================================================
  // SCREEN 7: Payment Successful Dialog
  // ===========================================================================
  void _showPaymentSuccessDialog(BuildContext parentContext, int coinsAdded) {
    showDialog(
      context: parentContext,
      barrierColor: Colors.black87,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF100D33),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFF00E676), width: 1.8),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x5500E676),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Green checkmark icon circle
                Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00E676),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x6600E676),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.check_rounded, color: Colors.black, size: 44),
                  ),
                ),
                const SizedBox(height: 18),

                const Text(
                  'Payment Successful!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),

                Text(
                  '$coinsAdded Coins\nadded to your account.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFC928),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 18),

                // 3D gold coins stack illustration
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1852),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🪙 🪙 🪙', style: TextStyle(fontSize: 26)),
                      SizedBox(width: 8),
                      Text('✨ ✨', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                const Text(
                  'Now you can send gifts to your favorite host!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),

                // Yellow "OK" button matching Screen 7
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC928),
                      foregroundColor: Colors.black,
                      elevation: 6,
                      shadowColor: const Color(0xAAFFD600),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.pop(dialogCtx);
                      setState(() {
                        _coinBalance += coinsAdded;
                      });
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(
                          content: Text('🎉 $coinsAdded Coins credited to your wallet!'),
                          backgroundColor: const Color(0xFFFFC928),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatCost(int cost) {
    if (cost >= 1000) {
      final s = cost.toString();
      final lastThree = s.substring(s.length - 3);
      final rest = s.substring(0, s.length - 3);
      return '$rest,$lastThree';
    }
    return '$cost';
  }

  @override
  Widget build(BuildContext context) {
    final filteredGifts = _getFilteredGifts();
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final totalCost = _selectedGift.diamonds * _quantity;
    final bool hasEnoughCoins = _coinBalance >= totalCost;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.86,
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        bottomPadding > 0 ? bottomPadding + 8 : 16,
      ),
      decoration: const BoxDecoration(
        color: Color(0xF00E0B2C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0x55FFC928), width: 1.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x33FFC928),
            blurRadius: 36,
            spreadRadius: -6,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: _showPreviewAndSend
              ? _buildPreviewAndSendView(context, totalCost, hasEnoughCoins)
              : _buildChooseAGiftView(context, filteredGifts, totalCost, hasEnoughCoins),
        ),
      ),
    );
  }

  Widget _buildChooseAGiftView(
    BuildContext context,
    List<GiftItem> filteredGifts,
    int totalCost,
    bool hasEnoughCoins,
  ) {
    return Column(
      key: const ValueKey('choose_gift_view'),
      mainAxisSize: MainAxisSize.min,
      children: [
            // Handle bar
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),

            // Header: `< Send Gift` + Recipient pill & Star balance matching Image 2 Panel 2
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Gift',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.recipients != null && widget.recipients!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF2D78), Color(0xFFBA43F6)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'To: ${_selectedRecipient.split(' ').first}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // Top balance indicator
                GestureDetector(
                  onTap: () => _showBuyCoinsSheet(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2008),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFC928), width: 1.2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33FFC928),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 5),
                        Text(
                          _formatCost(_coinBalance),
                          style: const TextStyle(
                            color: Color(0xFFFFC928),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.add_circle, color: Color(0xFFFFC928), size: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Category Tabs: All | Popular | Love | Premium matching Image 2 Panel 2
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isCatSel = _selectedCategory == cat;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: isCatSel
                            ? const LinearGradient(
                                colors: [Color(0xFFFF2D78), Color(0xFFBA43F6)],
                              )
                            : null,
                        color: isCatSel ? null : const Color(0xFF1A1548),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCatSel ? Colors.transparent : Colors.white12,
                          width: 1,
                        ),
                        boxShadow: isCatSel
                            ? const [
                                BoxShadow(
                                  color: Color(0x55FF2D78),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          color: isCatSel ? Colors.white : Colors.white70,
                          fontSize: 12.5,
                          fontWeight: isCatSel ? FontWeight.w900 : FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Grid of Gifts (Fills screen with exactly 9 enlarged cards at start; scroll for row 4+)
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = context.isTablet ? 4 : 3;
                const crossSpacing = 10.0;
                const mainSpacing = 10.0;
                const childAspectRatio = 0.81;

                // Calculate card dimensions from the available width
                final totalWidth = constraints.maxWidth - 4; // grid padding horizontal: 2
                final cardWidth = (totalWidth - (crossAxisCount - 1) * crossSpacing) / crossAxisCount;
                final cardHeight = cardWidth / childAspectRatio;

                // Exactly 3 rows (9 items on mobile) visible at screen start; scroll down for more
                final totalRows = (filteredGifts.length / crossAxisCount).ceil();
                final visibleRows = totalRows.clamp(1, 3);
                final targetGridHeight = (visibleRows * cardHeight) + ((visibleRows - 1) * mainSpacing);

                return SizedBox(
                  height: targetGridHeight,
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    itemCount: filteredGifts.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: mainSpacing,
                      crossAxisSpacing: crossSpacing,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemBuilder: (context, index) {
                      final gift = filteredGifts[index];
                      final isSelected = _selectedGift.id == gift.id;

                      return _InteractiveGiftGridCard(
                        gift: gift,
                        isSelected: isSelected,
                        onTap: () => _handleGiftTap(gift),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 12),

            // Bottom Footer matching Image 2 Panel 2:
            // Left: `⭐ 2,500`  |  Right: `Top Up` (Purple pill button)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Balance Star pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1548),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          _formatCost(_coinBalance),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // "Top Up" purple gradient pill CTA matching Image 2 Panel 2
                  GestureDetector(
                    onTap: () => _showBuyCoinsSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF8E24AA), Color(0xFF5E35B1)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x668E24AA),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Top Up',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
  }

  Widget _buildPreviewAndSendView(
    BuildContext context,
    int totalCost,
    bool hasEnoughCoins,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle bar
        Container(
          width: 38,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 12),

        // Header: <  _selectedGift.name  ✕
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => setState(() => _showPreviewAndSend = false),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            Text(
              _selectedGift.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // PK Recipient Selector (Allows switching between Neha & Arun)
        if (widget.recipients != null && widget.recipients!.length > 1) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.recipients!.map((r) {
                final isSel = _selectedRecipient == r;
                final isLeft = widget.recipients!.indexOf(r) == 0;
                return GestureDetector(
                  onTap: () => setState(() => _selectedRecipient = r),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: isSel
                          ? LinearGradient(
                              colors: isLeft
                                  ? [const Color(0xFFFF2D78), const Color(0xFFFF5252)]
                                  : [const Color(0xFF2979FF), const Color(0xFF00E5FF)],
                            )
                          : null,
                      color: isSel ? null : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSel ? Colors.white : Colors.white24,
                        width: 1.2,
                      ),
                      boxShadow: isSel
                          ? [
                              BoxShadow(
                                color: (isLeft ? const Color(0xFFFF2D78) : const Color(0xFF2979FF))
                                    .withValues(alpha: 0.45),
                                blurRadius: 10,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('👑 ', style: TextStyle(fontSize: 12)),
                        Text(
                          r,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: isSel ? FontWeight.w900 : FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],

        // Center 3D Animation Preview with interactive touch-to-pop animation
        _GiftInteractivePreviewPop(gift: _selectedGift),
        const SizedBox(height: 10),

        // Gift Name & Star Value
        Text(
          _selectedGift.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⭐', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              '${_selectedGift.diamonds}',
              style: const TextStyle(
                color: Color(0xFFFFC928),
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // "Send this gift to [Recipient]?"
        Text(
          'Send this gift to ${_selectedRecipient.split(' ').first}?',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),

        // Stepper: [- 1 +]
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1548),
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  if (_quantity > 1) setState(() => _quantity--);
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.remove, color: Colors.white, size: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  '$_quantity',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (_quantity < 99) setState(() => _quantity++);
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Big Send Gift CTA button matching Screenshot 2 Panel 3
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF2D78),
              foregroundColor: Colors.white,
              elevation: 8,
              shadowColor: const Color(0xAAFF2D78),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
            onPressed: _sendSelectedGift,
            child: Text(
              'Send Gift ($totalCost ⭐)',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Balance & Top Up footer
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⭐', style: TextStyle(fontSize: 13)),
            const SizedBox(width: 5),
            Text(
              '$_coinBalance',
              style: const TextStyle(
                color: Color(0xFFFFC928),
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _showBuyCoinsSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF2979FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Top Up',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Interactive 3D Gift Grid Card with tap bounce micro-animation
class _InteractiveGiftGridCard extends StatefulWidget {
  final GiftItem gift;
  final bool isSelected;
  final VoidCallback onTap;

  const _InteractiveGiftGridCard({
    required this.gift,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_InteractiveGiftGridCard> createState() => _InteractiveGiftGridCardState();
}

class _InteractiveGiftGridCardState extends State<_InteractiveGiftGridCard> {
  bool _isDown = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isDown = true),
      onTapUp: (_) {
        setState(() => _isDown = false);
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isDown = false),
      child: AnimatedScale(
        scale: _isDown ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? const Color(0x33FF2D78)
                : const Color(0xFF100D33),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.isSelected
                  ? const Color(0xFFFF2D78)
                  : Colors.white.withValues(alpha: 0.08),
              width: widget.isSelected ? 2.0 : 0.8,
            ),
            boxShadow: widget.isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x44FF2D78),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Center(
                          child: widget.gift.imageAssetPath != null
                              ? Image.asset(
                                  widget.gift.imageAssetPath!,
                                  width: 76,
                                  height: 76,
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.medium,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Text(widget.gift.icon, style: const TextStyle(fontSize: 40)),
                                )
                              : Text(widget.gift.icon, style: const TextStyle(fontSize: 40)),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.gift.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('⭐', style: TextStyle(fontSize: 11)),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              _formatCost(widget.gift.diamonds),
                              style: const TextStyle(
                                color: Color(0xFFFFC928),
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (widget.isSelected)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF2D78),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatCost(int cost) {
    if (cost >= 1000) {
      final s = cost.toString();
      final lastThree = s.substring(s.length - 3);
      final rest = s.substring(0, s.length - 3);
      return '$rest,$lastThree';
    }
    return '$cost';
  }
}

/// Interactive 3D Gift Preview widget:
/// - Springs in on entry
/// - Ambient hover float and radiant glow
/// - **Pop animation when touched by the user** (scales up, wobbles, bursts particles, haptic feedback)
class _GiftInteractivePreviewPop extends StatefulWidget {
  final GiftItem gift;
  const _GiftInteractivePreviewPop({required this.gift});

  @override
  State<_GiftInteractivePreviewPop> createState() => _GiftInteractivePreviewPopState();
}

class _GiftInteractivePreviewPopState extends State<_GiftInteractivePreviewPop>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _entryScale;

  late AnimationController _popController;
  late Animation<double> _popScale;
  late Animation<double> _popRotation;

  late AnimationController _floatController;
  late Animation<double> _floatOffset;

  late AnimationController _burstController;
  late Animation<double> _burstProgress;

  int _popCount = 0;

  @override
  void initState() {
    super.initState();
    // Entrance elastic pop
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _entryScale = CurvedAnimation(
      parent: _entryController,
      curve: Curves.elasticOut,
    );
    _entryController.forward();

    // Tap to pop animation
    _popController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _popScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.36).chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.36, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 70,
      ),
    ]).animate(_popController);

    _popRotation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -0.12).chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.12, end: 0.12).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.12, end: 0.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_popController);

    // Particle burst on pop
    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _burstProgress = CurvedAnimation(
      parent: _burstController,
      curve: Curves.easeOutQuad,
    );

    // Ambient floating
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _floatOffset = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void didUpdateWidget(covariant _GiftInteractivePreviewPop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gift.id != widget.gift.id) {
      _entryController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _popController.dispose();
    _floatController.dispose();
    _burstController.dispose();
    super.dispose();
  }

  void _triggerPop() {
    HapticFeedback.mediumImpact();
    setState(() => _popCount++);
    _popController.forward(from: 0.0);
    _burstController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _triggerPop,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF100D33),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0x66FF2D78),
            width: 1.4,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33FF2D78),
              blurRadius: 28,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Radial glow background
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFF2D78).withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Particle Burst Canvas
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _burstProgress,
                builder: (context, _) => CustomPaint(
                  painter: _GiftBurstPainter(
                    progress: _burstProgress.value,
                    color: const Color(0xFFFFC928),
                  ),
                ),
              ),
            ),

            // Animated Gift Image with Entrance, Tap-Pop, and Hover Float
            AnimatedBuilder(
              animation: Listenable.merge([_entryScale, _popScale, _popRotation, _floatOffset]),
              builder: (context, child) {
                final scale = _entryScale.value * _popScale.value;
                final rot = _popRotation.value;
                final offsetY = _floatOffset.value;

                return Transform.translate(
                  offset: Offset(0, offsetY),
                  child: Transform.rotate(
                    angle: rot,
                    child: Transform.scale(
                      scale: scale,
                      child: child,
                    ),
                  ),
                );
              },
              child: widget.gift.imageAssetPath != null
                  ? Image.asset(
                      widget.gift.imageAssetPath!,
                      width: 105,
                      height: 105,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Text(
                        widget.gift.icon,
                        style: const TextStyle(fontSize: 72),
                      ),
                    )
                  : Text(
                      widget.gift.icon,
                      style: const TextStyle(fontSize: 72),
                    ),
            ),

            // Bottom pill indicator: "✨ Tap to Pop Animation"
            Positioned(
              bottom: 8,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _popController.isAnimating
                        ? const Color(0xFFFF2D78)
                        : const Color(0xFFFFC928),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_popController.isAnimating
                              ? const Color(0xFFFF2D78)
                              : const Color(0xFFFFC928))
                          .withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _popController.isAnimating ? '🎉 POP!' : '✨ Tap to Pop Animation',
                      style: TextStyle(
                        color: _popController.isAnimating
                            ? const Color(0xFFFF2D78)
                            : const Color(0xFFFFC928),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    if (_popCount > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        'x$_popCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the sparkling stars burst when touching the 3D gift
class _GiftBurstPainter extends CustomPainter {
  final double progress;
  final Color color;

  _GiftBurstPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.48;
    final currentRadius = maxRadius * progress;
    final alpha = (1.0 - progress).clamp(0.0, 1.0);

    final paint = Paint()
      ..color = color.withValues(alpha: alpha)
      ..style = PaintingStyle.fill;

    // Draw 8 sparkle stars expanding outwards
    const count = 8;
    for (int i = 0; i < count; i++) {
      final angle = (i * 2 * math.pi / count) + (progress * 0.5);
      final x = center.dx + currentRadius * math.cos(angle);
      final y = center.dy + currentRadius * math.sin(angle);
      final starSize = (6.0 * (1.0 - progress * 0.5)).clamp(2.0, 6.0);

      canvas.drawCircle(Offset(x, y), starSize * 0.6, paint);
      // Sparkle cross
      final linePaint = Paint()
        ..color = Colors.white.withValues(alpha: alpha)
        ..strokeWidth = 1.5;
      canvas.drawLine(Offset(x - starSize, y), Offset(x + starSize, y), linePaint);
      canvas.drawLine(Offset(x, y - starSize), Offset(x, y + starSize), linePaint);
    }

    // Outer expanding shockwave ring
    final ringPaint = Paint()
      ..color = color.withValues(alpha: alpha * 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * (1.0 - progress);
    canvas.drawCircle(center, currentRadius * 0.9, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _GiftBurstPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
