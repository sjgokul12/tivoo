import 'dart:math';

import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import '../../data/mock_live_comments.dart';
import '../../domain/models/gift_item.dart';

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

  final List<String> _categories = ['All', 'Popular', 'Love', 'Premium'];

  static const List<GiftItem> starGifts = [
    GiftItem(id: 'star_1', name: 'Star x1', icon: '⭐', diamonds: 1),
    GiftItem(id: 'star_10', name: 'Star Pack x10', icon: '🌟', diamonds: 10),
    GiftItem(id: 'star_50', name: 'Super Star x50', icon: '✨', diamonds: 50),
    GiftItem(id: 'star_100', name: 'Galaxy Star x100', icon: '💫', diamonds: 100),
    GiftItem(id: 'star_500', name: 'Mega Star x500', icon: '🌠', diamonds: 500),
    GiftItem(id: 'star_1000', name: 'Star Lord x1000', icon: '🌌', diamonds: 1000),
  ];

  @override
  void initState() {
    super.initState();
    _selectedGift = MockLiveComments.virtualGifts.first;
    _selectedRecipient =
        widget.initialRecipient ??
        (widget.recipients != null && widget.recipients!.isNotEmpty ? widget.recipients!.first : 'Host');
  }

  List<GiftItem> _getFilteredGifts() {
    final all = [...MockLiveComments.virtualGifts, ...starGifts];
    switch (_selectedCategory) {
      case 'Popular':
        return all.where((g) {
          final id = g.id.toLowerCase();
          return id.contains('rose') ||
              id.contains('love') ||
              id.contains('heart') ||
              id.contains('teddy') ||
              id.contains('chocolate') ||
              id.contains('crown') ||
              id.contains('star');
        }).toList();
      case 'Love':
        return all.where((g) {
          final id = g.id.toLowerCase();
          return id.contains('rose') ||
              id.contains('love') ||
              id.contains('heart') ||
              id.contains('teddy') ||
              id.contains('chocolate') ||
              id.contains('castle');
        }).toList();
      case 'Premium':
        return all.where((g) {
          final id = g.id.toLowerCase();
          return id.contains('car') ||
              id.contains('lion') ||
              id.contains('yacht') ||
              id.contains('rocket') ||
              id.contains('castle') ||
              id.contains('whale') ||
              id.contains('firework') ||
              id.contains('dragon') ||
              id.contains('vehicle') ||
              id.contains('horse') ||
              id.contains('wings') ||
              g.diamonds >= 500;
        }).toList();
      default:
        return all;
    }
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
    final packs = [
      {'coins': 70, 'price': '₹49', 'isPopular': false},
      {'coins': 350, 'price': '₹249', 'isPopular': true},
      {'coins': 700, 'price': '₹499', 'isPopular': false},
      {'coins': 1750, 'price': '₹999', 'isPopular': false},
      {'coins': 3500, 'price': '₹1,999', 'isPopular': false},
    ];

    showModalBottomSheet(
      context: parentContext,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(ctx).height * 0.76),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: const BoxDecoration(
            color: Color(0xFF101018),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: Color(0x55FFD600), width: 1.5)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
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
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
                          color: const Color(0xFF181822),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isPop ? const Color(0xFFFFD600) : Colors.white12,
                            width: isPop ? 1.8 : 1.0,
                          ),
                          boxShadow: isPop ? const [BoxShadow(color: Color(0x33FFD600), blurRadius: 10)] : null,
                        ),
                        child: Row(
                          children: [
                            // 3D Coin Graphic
                            Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(colors: [Color(0xFFFFEA00), Color(0xFFFF9100)]),
                              ),
                              child: const Center(child: Text('🪙', style: TextStyle(fontSize: 20))),
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
                                backgroundColor: isPop ? const Color(0xFFFFD600) : Colors.white12,
                                foregroundColor: isPop ? Colors.black : Colors.white,
                                elevation: isPop ? 4 : 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                    gradient: const LinearGradient(colors: [Color(0xFF2E124D), Color(0xFF1E0E33)]),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x66BA43F6)),
                  ),
                  child: const Center(
                    child: Text(
                      'More Coins   More Gifts   More Fun ♡',
                      style: TextStyle(
                        color: Color(0xFFFFD600),
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
                color: Color(0xFF12121A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(top: BorderSide(color: Color(0x55FFD600), width: 1.5)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
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
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 3D Gold Coins stack illustration
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C1A28),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0x33FFD600)),
                      ),
                      child: Column(
                        children: [
                          const Text('🪙 🪙 🪙', style: TextStyle(fontSize: 36)),
                          const SizedBox(height: 4),
                          Text(
                            '${pack['coins']} Coins for ${pack['price']}',
                            style: const TextStyle(color: Color(0xFFFFD600), fontSize: 16, fontWeight: FontWeight.w900),
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
                            color: isSel ? const Color(0xFF221F33) : const Color(0xFF171720),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSel ? const Color(0xFFFFD600) : Colors.white12,
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
                                color: isSel ? const Color(0xFFFFD600) : Colors.white38,
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showPaymentSuccessDialog(parentContext, pack['coins'] as int);
                        },
                        child: const Text(
                          'Continue',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.5),
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
              color: const Color(0xFF14141E),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFF00E676), width: 1.8),
              boxShadow: const [BoxShadow(color: Color(0x5500E676), blurRadius: 24, spreadRadius: 2)],
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
                    boxShadow: [BoxShadow(color: Color(0x6600E676), blurRadius: 18, spreadRadius: 2)],
                  ),
                  child: const Center(child: Icon(Icons.check_rounded, color: Colors.black, size: 44)),
                ),
                const SizedBox(height: 18),

                const Text(
                  'Payment Successful!',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),

                Text(
                  '$coinsAdded Coins\nadded to your account.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFD600),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 18),

                // 3D gold coins stack illustration
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(color: const Color(0xFF1F1C2D), borderRadius: BorderRadius.circular(16)),
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
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 20),

                // Yellow "OK" button matching Screen 7
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD600),
                      foregroundColor: Colors.black,
                      elevation: 6,
                      shadowColor: const Color(0xAAFFD600),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                          backgroundColor: const Color(0xFFFFD600),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text(
                      'OK',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1.0),
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
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.80),
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding > 0 ? bottomPadding + 8 : 16),
      decoration: const BoxDecoration(
        color: Color(0xF0101018),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: Color(0x55FFD600), width: 1.5)),
        boxShadow: [BoxShadow(color: Color(0x33FFD600), blurRadius: 36, spreadRadius: -6)],
      ),
      child: SafeArea(
        top: false,
        child: _showPreviewAndSend
            ? _buildPreviewAndSendView(context, totalCost, hasEnoughCoins)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                  ),
                  const SizedBox(height: 12),

                  // Top Header: "Gift" title + Coin Balance pill (🪙 350 +)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Gift',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),

                      // Coin balance pill with '+' recharge button matching Screen 4 & 8
                      GestureDetector(
                        onTap: () => _showBuyCoinsSheet(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1A10),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFFFD600), width: 1.2),
                            boxShadow: const [BoxShadow(color: Color(0x33FFD600), blurRadius: 8)],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🪙', style: TextStyle(fontSize: 13)),
                              const SizedBox(width: 5),
                              Text(
                                '$_coinBalance',
                                style: const TextStyle(
                                  color: Color(0xFFFFD600),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(color: Color(0xFFFFD600), shape: BoxShape.circle),
                                child: const Icon(Icons.add, color: Colors.black, size: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Category Tabs: All | Popular | Luxury | Love
                  SizedBox(
                    height: 32,
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
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                              color: isCatSel ? const Color(0xFFFFD600) : const Color(0xFF181822),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: isCatSel ? const Color(0xFFFFD600) : Colors.white12, width: 1),
                            ),
                            child: Text(
                              cat,
                              style: TextStyle(
                                color: isCatSel ? Colors.black : Colors.white70,
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

                  // Grid of Gifts (Transparent, pure isolated stickers with neon pill badge matching user reference)
                  Flexible(
                    child: GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      itemCount: filteredGifts.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: context.isTablet ? 4 : 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.88,
                      ),
                      itemBuilder: (context, index) {
                        final gift = filteredGifts[index];
                        final isSelected = _selectedGift.id == gift.id;

                        return GestureDetector(
                          onTap: () => _handleGiftTap(gift),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0x33FFD600) : const Color(0xFF13111C),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isSelected ? const Color(0xFFFFD600) : Colors.white.withValues(alpha: 0.08),
                                width: isSelected ? 2.0 : 0.8,
                              ),
                              boxShadow: isSelected
                                  ? const [BoxShadow(color: Color(0x44FFD600), blurRadius: 12, spreadRadius: 1)]
                                  : null,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // 3D Sticker Graphic + Neon Pill Badge matching User Screenshots
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: gift.isSceneArt
                                              ? _SceneGiftThumbnail(gift: gift)
                                              : Center(
                                                  child: gift.imageAssetPath != null
                                                      ? Image.asset(
                                                          gift.imageAssetPath!,
                                                          width: 58,
                                                          height: 58,
                                                          fit: BoxFit.contain,
                                                          errorBuilder: (context, error, stackTrace) =>
                                                              Text(gift.icon, style: const TextStyle(fontSize: 34)),
                                                        )
                                                      : Text(gift.icon, style: const TextStyle(fontSize: 34)),
                                                ),
                                        ),
                                        const SizedBox(height: 4),

                                        // Neon Capsule Pill Badge (Matches User Reference Image 1, 2, 3)
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF0C0A14),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: isSelected
                                                  ? const Color(0xFFFFD600)
                                                  : const Color(0xFFBA43F6).withValues(alpha: 0.7),
                                              width: 1.0,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: (isSelected ? const Color(0xFFFFD600) : const Color(0xFFBA43F6))
                                                    .withValues(alpha: 0.25),
                                                blurRadius: 5,
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  gift.name,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 3),
                                              const Text('🪙', style: TextStyle(fontSize: 8)),
                                              const SizedBox(width: 2),
                                              Text(
                                                _formatCost(gift.diamonds),
                                                style: const TextStyle(
                                                  color: Color(0xFFFFD600),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Selected Checkmark
                                  if (isSelected)
                                    Positioned(
                                      top: 6,
                                      right: 6,
                                      child: Container(
                                        width: 18,
                                        height: 18,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFFFD600),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.check_rounded, color: Colors.black, size: 13),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Bottom Action Bar matching Screen 8: Stepper `[- 1 +]` + Pink "Send" CTA Button
                  Row(
                    children: [
                      // Quantity Stepper: `[- 1 +]`
                      Container(
                        height: 44,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B1B26),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white24, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (_quantity > 1) {
                                  setState(() => _quantity--);
                                }
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
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                '$_quantity',
                                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (_quantity < 99) {
                                  setState(() => _quantity++);
                                }
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
                      const SizedBox(width: 10),

                      // Send Button (or Recharge button if balance < totalCost)
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: hasEnoughCoins
                              ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF2D78),
                                    foregroundColor: Colors.white,
                                    elevation: 6,
                                    shadowColor: const Color(0xAAFF2D78),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  onPressed: _sendSelectedGift,
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Send ${_selectedGift.name}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.28),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text('🪙 ', style: TextStyle(fontSize: 10)),
                                              Text(
                                                '$totalCost',
                                                style: const TextStyle(
                                                  color: Color(0xFFFFD21F),
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFD600),
                                    foregroundColor: Colors.black,
                                    elevation: 6,
                                    shadowColor: const Color(0xAAFFD600),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                  ),
                                  onPressed: () => _showBuyCoinsSheet(context),
                                  child: const FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '🪙 Recharge',
                                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPreviewAndSendView(BuildContext context, int totalCost, bool hasEnoughCoins) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Handle bar
        Container(
          width: 38,
          height: 4,
          decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
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
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.1)),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
              ),
            ),
            Text(
              _selectedGift.name,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.1)),
                child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Video gifts play their animation right away; other gifts show the 3D preview.
        if (_selectedGift.isSceneArt)
          _AnimatedArtPreview(key: ValueKey(_selectedGift.id), gift: _selectedGift)
        else
          // Center 3D Animation Preview of the gift
          Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF161424),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0x55FF2D78), width: 1.2),
              boxShadow: const [BoxShadow(color: Color(0x33FF2D78), blurRadius: 24, spreadRadius: -2)],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Radial glow behind the gift
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [const Color(0xFFFF2D78).withValues(alpha: 0.35), Colors.transparent],
                    ),
                  ),
                ),
                // 3D Gift preview graphic
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 900),
                  tween: Tween(begin: 0.90, end: 1.05),
                  curve: Curves.easeInOut,
                  builder: (context, scale, child) {
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: _selectedGift.imageAssetPath != null
                      ? Image.asset(
                          _selectedGift.imageAssetPath!,
                          width: 90,
                          height: 90,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => Text(_selectedGift.icon, style: const TextStyle(fontSize: 64)),
                        )
                      : Text(_selectedGift.icon, style: const TextStyle(fontSize: 64)),
                ),
                // Subtle "3D Live Preview" badge
                Positioned(
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFD600), width: 0.8),
                    ),
                    child: const Text(
                      '✨ 3D Live Preview',
                      style: TextStyle(color: Color(0xFFFFD600), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),

        // Gift Name & Star Value
        Text(
          _selectedGift.name,
          style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 3),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⭐', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              '${_selectedGift.diamonds}',
              style: const TextStyle(color: Color(0xFFFFD600), fontSize: 15, fontWeight: FontWeight.w900),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // "Send this gift to [Recipient]?"
        Text(
          'Send this gift to ${_selectedRecipient.split(' ').first}?',
          style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),

        // Stepper: [- 1 +]
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1B26),
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
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), shape: BoxShape.circle),
                  child: const Icon(Icons.remove, color: Colors.white, size: 16),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  '$_quantity',
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (_quantity < 99) setState(() => _quantity++);
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), shape: BoxShape.circle),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(vertical: 13),
            ),
            onPressed: _sendSelectedGift,
            child: Text(
              'Send Gift ($totalCost ⭐)',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.5),
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
              style: const TextStyle(color: Color(0xFFFFD600), fontSize: 13, fontWeight: FontWeight.w900),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => _showBuyCoinsSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFF2979FF), borderRadius: BorderRadius.circular(12)),
                child: const Text(
                  'Top Up',
                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Grid card artwork for picture-style gifts: the image fills the card with a "3D" badge.
class _SceneGiftThumbnail extends StatelessWidget {
  final GiftItem gift;
  const _SceneGiftThumbnail({required this.gift});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            gift.imageAssetPath!,
            fit: BoxFit.cover,
            alignment: const Alignment(0, -0.3),
            errorBuilder: (_, _, _) => Center(child: Text(gift.icon, style: const TextStyle(fontSize: 34))),
          ),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: Container(
            constraints: const BoxConstraints(minWidth: 22),
            height: 22,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              color: Colors.black.withValues(alpha: 0.55),
              border: Border.all(color: const Color(0xFFFFD600), width: 1),
            ),
            child: const Text(
                    '3D',
                    style: TextStyle(color: Color(0xFFFFD600), fontSize: 10, fontWeight: FontWeight.w900),
                  ),
          ),
        ),
      ],
    );
  }
}

/// Preview for 3D picture gifts: the artwork comes alive with a slow zoom, parallax
/// drift, a shine sweep and rising sparkles as soon as the card is tapped.
class _AnimatedArtPreview extends StatefulWidget {
  final GiftItem gift;
  const _AnimatedArtPreview({super.key, required this.gift});

  @override
  State<_AnimatedArtPreview> createState() => _AnimatedArtPreviewState();
}

class _AnimatedArtPreviewState extends State<_AnimatedArtPreview> with SingleTickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(vsync: this, duration: const Duration(seconds: 6))
    ..repeat();

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      widget.gift.imageAssetPath ?? '',
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, _, _) => Center(child: Text(widget.gift.icon, style: const TextStyle(fontSize: 64))),
    );

    return Container(
      height: 230,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x88FFD600), width: 1.2),
        boxShadow: const [BoxShadow(color: Color(0x44FF2D78), blurRadius: 24, spreadRadius: -2)],
      ),
      clipBehavior: Clip.antiAlias,
      child: AnimatedBuilder(
        animation: _loop,
        builder: (context, child) {
          final v = _loop.value;
          final wave = sin(v * 2 * pi);
          final zoom = 1.08 + 0.06 * wave;
          final sheen = (v * 1.6 - 0.3).clamp(-0.3, 1.3);
          return Stack(
            fit: StackFit.expand,
            children: [
              Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..translateByDouble(cos(v * 2 * pi) * 10, wave * 6, 0, 1)
                  ..scaleByDouble(zoom, zoom, 1, 1),
                child: ShaderMask(
                  blendMode: BlendMode.srcATop,
                  shaderCallback: (bounds) => LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: const [Colors.transparent, Color(0x66FFFFFF), Colors.transparent],
                    stops: [(sheen - 0.1).clamp(0.0, 1.0), sheen.clamp(0.0, 1.0), (sheen + 0.1).clamp(0.0, 1.0)],
                  ).createShader(bounds),
                  child: child,
                ),
              ),
              CustomPaint(painter: _RisingSparklesPainter(progress: v)),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.transparent, Color(0xCC000000)],
                    stops: [0, 0.6, 1],
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFD600), width: 0.8),
                    ),
                    child: const Text(
                      '✨ 3D Animated Gift',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        child: image,
      ),
    );
  }
}

/// Small golden sparkles drifting upwards over the preview.
class _RisingSparklesPainter extends CustomPainter {
  final double progress;
  _RisingSparklesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 26; i++) {
      final seed = (i * 0.6180339) % 1.0;
      final p = (progress * (0.8 + seed) + seed) % 1.0;
      final x = size.width * ((i * 0.37) % 1.0) + sin(p * 2 * pi + i) * 8;
      final y = size.height * (1.05 - p * 1.1);
      final a = (p < 0.15 ? p / 0.15 : (1 - p)).clamp(0.0, 1.0);
      canvas.drawCircle(
        Offset(x, y),
        1.5 + seed * 2.5,
        Paint()
          ..color = const Color(0xFFFFE082).withValues(alpha: a)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RisingSparklesPainter oldDelegate) => oldDelegate.progress != progress;
}
