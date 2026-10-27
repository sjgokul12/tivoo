import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../live_stream/presentation/controllers/star_wallet_controller.dart';
import '../wallet/controllers/wallet_controller.dart';
import 'realistic_3d_star.dart';

/// Data model representing a Star recharge pack matching reference Image 1.
class StarPack {
  final int stars;
  final String price;
  final String image;
  final bool isPopular;

  const StarPack({
    required this.stars,
    required this.price,
    required this.image,
    this.isPopular = false,
  });

  static const List<StarPack> standardPacks = [
    StarPack(stars: 100, price: '₹20', image: 'assets/stars/pack_100.png'),
    StarPack(stars: 300, price: '₹60', image: 'assets/stars/pack_300.png'),
    StarPack(stars: 500, price: '₹100', image: 'assets/stars/pack_500.png'),
    StarPack(stars: 1000, price: '₹200', image: 'assets/stars/pack_1000.png', isPopular: true),
    StarPack(stars: 2000, price: '₹400', image: 'assets/stars/pack_1000.png'),
    StarPack(stars: 3000, price: '₹600', image: 'assets/stars/coinpouch.png'),
    StarPack(stars: 4000, price: '₹800', image: 'assets/stars/coinpouch.png'),
    StarPack(stars: 5000, price: '₹1,000', image: 'assets/stars/chest_of_golden_stars.png'),
  ];

  static const StarPack grandPack = StarPack(
    stars: 10000,
    price: '₹2,000',
    image: 'assets/stars/treasure_chest.png',
  );
}

/// Full-screen Buy Stars page matching reference design with edge-to-edge layout,
/// fully responsive across mobile and tablet screens, with smooth tactile feedback
/// and rock-solid clickables that never get stuck.
class BuyStarsScreen extends ConsumerStatefulWidget {
  final int? currentBalance;
  final void Function(int stars, String price)? onSelectPack;

  const BuyStarsScreen({
    super.key,
    this.currentBalance,
    this.onSelectPack,
  });

  /// Opens the full-screen Buy Stars page across root navigator with zero gaps.
  static void show(
    BuildContext context, {
    int? currentBalance,
    void Function(int stars, String price)? onSelectPack,
  }) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => BuyStarsScreen(
          currentBalance: currentBalance,
          onSelectPack: onSelectPack,
        ),
      ),
    );
  }

  @override
  ConsumerState<BuyStarsScreen> createState() => _BuyStarsScreenState();
}

class _BuyStarsScreenState extends ConsumerState<BuyStarsScreen> {
  bool _isProcessing = false;

  String _format(int val) {
    return val.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  void _handlePackTap(StarPack pack) {
    if (_isProcessing) return;
    _showPaymentSheet(pack);
  }

  void _showPaymentSheet(StarPack pack) {
    if (!mounted || _isProcessing) return;
    setState(() => _isProcessing = true);

    String selectedMethod = 'Google Pay';
    bool isSubmitting = false;

    final methods = [
      {'name': 'Google Pay', 'icon': '🟢', 'desc': 'Instant UPI transfer'},
      {'name': 'PhonePe', 'icon': '🟣', 'desc': 'UPI & Wallet'},
      {'name': 'Paytm', 'icon': '🔵', 'desc': 'UPI, Wallet & Cards'},
      {'name': 'UPI', 'icon': '⚡', 'desc': 'Any UPI App'},
      {'name': 'Credit / Debit Card', 'icon': '💳', 'desc': 'Visa, Mastercard, RuPay'},
      {'name': 'Net Banking', 'icon': '🏦', 'desc': 'All Indian Banks'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: false,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            final mediaQuery = MediaQuery.of(modalContext);
            final sheetBottom = mediaQuery.viewInsets.bottom + mediaQuery.padding.bottom;
            final screenWidth = mediaQuery.size.width;
            final isSmall = screenWidth < 360;

            return Container(
              margin: EdgeInsets.only(bottom: sheetBottom),
              padding: EdgeInsets.fromLTRB(isSmall ? 14 : 18, 12, isSmall ? 14 : 18, 16),
              decoration: const BoxDecoration(
                color: Color(0xFF130E29),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(
                  top: BorderSide(color: Color(0xFFFFC928), width: 1.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x33FFC928),
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Pull Handle
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Sheet Header
                    Row(
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (Navigator.of(sheetContext).canPop()) {
                              Navigator.of(sheetContext).pop();
                            }
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Top Up Stars',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Selected Pack Highlight
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D173C),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0x44FFC928)),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 44,
                            height: 44,
                            child: Image.asset(
                              pack.image,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Realistic3DStar(size: 32),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_format(pack.stars)} Stars',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Instant recharge to your balance',
                                  style: TextStyle(color: Colors.white54, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFC928),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              pack.price,
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
                    const SizedBox(height: 14),

                    // Payment Method Options
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: mediaQuery.size.height * 0.35,
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: methods.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 6),
                        itemBuilder: (context, idx) {
                          final m = methods[idx];
                          final isSel = selectedMethod == m['name'];
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              setModalState(() => selectedMethod = m['name'] as String);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSel ? const Color(0xFF282050) : const Color(0xFF171330),
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
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          m['name'] as String,
                                          style: TextStyle(
                                            color: isSel ? Colors.white : Colors.white70,
                                            fontSize: 14,
                                            fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          m['desc'] as String,
                                          style: const TextStyle(color: Colors.white38, fontSize: 10.5),
                                        ),
                                      ],
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
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Pay Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF2D78),
                          foregroundColor: Colors.white,
                          elevation: 6,
                          shadowColor: const Color(0x99FF2D78),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                setModalState(() => isSubmitting = true);
                                await Future.delayed(const Duration(milliseconds: 400));
                                if (!modalContext.mounted) return;

                                // Credit star balance in live stream controller
                                try {
                                  ref.read(starWalletProvider.notifier).creditStars(
                                        pack.stars,
                                        reason: 'Coins Pack Purchase',
                                      );
                                } catch (_) {}

                                // Synchronize wallet provider if active
                                try {
                                  final walletNotifier = ref.read(walletProvider.notifier);
                                  final pkg = WalletController.packages.firstWhere(
                                    (p) => p.starsCount == pack.stars,
                                    orElse: () => WalletController.packages.first,
                                  );
                                  walletNotifier.buyStars(package: pkg, paymentMethod: selectedMethod);
                                } catch (_) {}

                                // Dismiss the payment sheet safely
                                if (Navigator.of(sheetContext).canPop()) {
                                  Navigator.of(sheetContext).pop();
                                }

                                if (!mounted) return;
                                // Show celebratory success dialog
                                _showSuccessDialog(pack);

                                // Notify external listener if registered
                                widget.onSelectPack?.call(pack.stars, pack.price);
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Pay ${pack.price}',
                                style: const TextStyle(
                                  fontSize: 16,
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
    ).whenComplete(() {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    });
  }

  void _showSuccessDialog(StarPack pack) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (dialogCtx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: const Color(0xFF14102B),
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
                // Glowing Checkmark
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
                  '${_format(pack.stars)} Stars\nadded to your account.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFFFD600),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),

                // Star pack icon preview
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F183C),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SizedBox(
                    width: 52,
                    height: 52,
                    child: Image.asset(
                      pack.image,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Realistic3DStar(size: 44),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                const Text(
                  'Now you can send gifts to your favorite host!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 20),

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
                      if (Navigator.of(dialogCtx).canPop()) {
                        Navigator.of(dialogCtx).pop();
                      }
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

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;
    final bottomPadding = mediaQuery.padding.bottom;
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;

    // Responsive breakpoints
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;

    final horizontalMargin = isTablet ? 32.0 : (isSmallScreen ? 10.0 : 14.0);
    final cardGap = isSmallScreen ? 8.0 : 10.0;
    final cardMinHeight = isSmallScreen ? 76.0 : 84.0;
    final starIconSize = isSmallScreen ? 40.0 : 48.0;

    // Proportional hero banner sizing based on device height
    final heroHeight = (screenHeight * (screenHeight < 600 ? 0.22 : 0.28)).clamp(160.0, 240.0);

    // Watch live star balance from riverpod, with fallback
    int liveBalance;
    try {
      final walletState = ref.watch(starWalletProvider);
      liveBalance = walletState.starBalance;
      if (liveBalance == 0 && widget.currentBalance != null && widget.currentBalance! > 0) {
        liveBalance = widget.currentBalance!;
      }
    } catch (_) {
      liveBalance = widget.currentBalance ?? 1000000;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF09051E),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF150A38),
              Color(0xFF0E0728),
              Color(0xFF09051E),
              Color(0xFF060314),
            ],
          ),
        ),
        child: Stack(
          children: [
            // 1. Ambient Background Glow Effects
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: heroHeight + 60,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.4),
                      radius: 0.9,
                      colors: [
                        const Color(0xFF7A22FF).withValues(alpha: 0.35),
                        const Color(0xFFFFB800).withValues(alpha: 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // 2. Edge-to-Edge Scrollable Content
            ListView(
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              children: [
                // Top Hero Banner with subtle bottom fade
                SizedBox(
                  height: heroHeight + topPadding,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: topPadding * 0.4),
                        child: Image.asset(
                          'assets/stars/stars_hero_banner.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: topPadding),
                                const Realistic3DStar(size: 64),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Bottom gradient merge so it blends into cards seamlessly
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 40,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                const Color(0xFF0E0728).withValues(alpha: 0.8),
                                const Color(0xFF0E0728),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Responsive Packs Grid
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: isTablet ? 640 : double.infinity,
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalMargin),
                      child: Column(
                        children: [
                          for (int i = 0; i < StarPack.standardPacks.length; i += 2) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _InteractivePackCard(
                                    pack: StarPack.standardPacks[i],
                                    isSmallScreen: isSmallScreen,
                                    minHeight: cardMinHeight,
                                    iconSize: starIconSize,
                                    onTap: () => _handlePackTap(StarPack.standardPacks[i]),
                                  ),
                                ),
                                SizedBox(width: cardGap),
                                if (i + 1 < StarPack.standardPacks.length)
                                  Expanded(
                                    child: _InteractivePackCard(
                                      pack: StarPack.standardPacks[i + 1],
                                      isSmallScreen: isSmallScreen,
                                      minHeight: cardMinHeight,
                                      iconSize: starIconSize,
                                      onTap: () => _handlePackTap(StarPack.standardPacks[i + 1]),
                                    ),
                                  )
                                else
                                  const Spacer(),
                              ],
                            ),
                            SizedBox(height: cardGap),
                          ],

                          // 10,000 Grand Pack full-width card
                          _InteractiveGrandCard(
                            pack: StarPack.grandPack,
                            isSmallScreen: isSmallScreen,
                            onTap: () => _handlePackTap(StarPack.grandPack),
                          ),
                          SizedBox(height: bottomPadding + 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 3. Floating Top App Bar: Back Button & Live Star Balance Chip
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button with accessible touch target
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.50),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),

                      // Live Star Balance Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F1836).withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFFC928), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFC928).withValues(alpha: 0.25),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Realistic3DStar(size: 16),
                            const SizedBox(width: 6),
                            Text(
                              _format(liveBalance),
                              style: const TextStyle(
                                color: Color(0xFFFFC928),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Interactive Pack Card with smooth tactile press animation and 100% surface touch sensitivity.
class _InteractivePackCard extends StatefulWidget {
  final StarPack pack;
  final bool isSmallScreen;
  final double minHeight;
  final double iconSize;
  final VoidCallback onTap;

  const _InteractivePackCard({
    required this.pack,
    required this.isSmallScreen,
    required this.minHeight,
    required this.iconSize,
    required this.onTap,
  });

  @override
  State<_InteractivePackCard> createState() => _InteractivePackCardState();
}

class _InteractivePackCardState extends State<_InteractivePackCard> {
  bool _isPressed = false;

  String _format(int val) {
    return val.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final pack = widget.pack;
    final isPopular = pack.isPopular;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Container(
          constraints: BoxConstraints(minHeight: widget.minHeight),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0B36),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPopular ? const Color(0xFFFFB800) : const Color(0xFF282585),
              width: isPopular ? 1.6 : 1.0,
            ),
            boxShadow: isPopular
                ? [
                    BoxShadow(
                      color: const Color(0xFFFFB800).withValues(alpha: 0.35),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Popular Badge pinned at top-right
              if (isPopular)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFB800),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(15),
                        bottomLeft: Radius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Popular',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),

              // Card Content
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isSmallScreen ? 6 : 8,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: widget.iconSize,
                      height: widget.iconSize,
                      child: Image.asset(
                        pack.image,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Realistic3DStar(size: widget.iconSize * 0.7),
                        ),
                      ),
                    ),
                    SizedBox(width: widget.isSmallScreen ? 5 : 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              _format(pack.stars),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: widget.isSmallScreen ? 14 : 15.5,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('⭐', style: TextStyle(fontSize: widget.isSmallScreen ? 8.5 : 9.5)),
                              const SizedBox(width: 3),
                              Text(
                                'Stars',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: widget.isSmallScreen ? 9.5 : 10.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: widget.isSmallScreen ? 8 : 11,
                              vertical: widget.isSmallScreen ? 3 : 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF282585),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF282585).withValues(alpha: 0.35),
                                  blurRadius: 4,
                                  offset: const Offset(0, 1.5),
                                ),
                              ],
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                pack.price,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: widget.isSmallScreen ? 10.5 : 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Interactive 10,000 Grand Pack Card with 100% surface touch sensitivity.
class _InteractiveGrandCard extends StatefulWidget {
  final StarPack pack;
  final bool isSmallScreen;
  final VoidCallback onTap;

  const _InteractiveGrandCard({
    required this.pack,
    required this.isSmallScreen,
    required this.onTap,
  });

  @override
  State<_InteractiveGrandCard> createState() => _InteractiveGrandCardState();
}

class _InteractiveGrandCardState extends State<_InteractiveGrandCard> {
  bool _isPressed = false;

  String _format(int val) {
    return val.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final pack = widget.pack;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: Container(
          constraints: BoxConstraints(minHeight: widget.isSmallScreen ? 72 : 78),
          padding: EdgeInsets.symmetric(
            horizontal: widget.isSmallScreen ? 10 : 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0B36),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF282585), width: 1.0),
          ),
          child: Row(
            children: [
              SizedBox(
                width: widget.isSmallScreen ? 54 : 68,
                height: widget.isSmallScreen ? 44 : 52,
                child: Image.asset(
                  pack.image,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Realistic3DStar(size: widget.isSmallScreen ? 30 : 36),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _format(pack.stars),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: widget.isSmallScreen ? 15 : 16.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('⭐', style: TextStyle(fontSize: widget.isSmallScreen ? 9 : 10)),
                      const SizedBox(width: 3),
                      Text(
                        'Stars',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: widget.isSmallScreen ? 10 : 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isSmallScreen ? 14 : 20,
                  vertical: widget.isSmallScreen ? 6 : 7.5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF282585),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF282585).withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  pack.price,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.isSmallScreen ? 12 : 13.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Backward compatibility alias so existing calls work without alteration.
typedef BuyStarsSheet = BuyStarsScreen;
