import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/wallet_controller.dart';
import '../../models/wallet_models.dart';
import '../widgets/wallet_widgets.dart';
import 'payment_screen.dart';

class BuyStarsScreen extends ConsumerStatefulWidget {
  const BuyStarsScreen({super.key});

  @override
  ConsumerState<BuyStarsScreen> createState() => _BuyStarsScreenState();
}

class _BuyStarsScreenState extends ConsumerState<BuyStarsScreen> {
  late StarPackage _selectedPackage;

  final Map<int, String> _packImages = {
    100: 'assets/stars/pack_100.png',
    300: 'assets/stars/pack_300.png',
    500: 'assets/stars/pack_500.png',
    1000: 'assets/stars/pack_1000.png',
    2000: 'assets/stars/pack_2000.png',
    3000: 'assets/stars/pack_3000.png',
    4000: 'assets/stars/pack_4000.png',
    5000: 'assets/stars/pack_5000.png',
  };

  @override
  void initState() {
    super.initState();
    // Default selected package matching reference image (1,000 Stars / ₹200)
    _selectedPackage = WalletController.packages[3];
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);

    return WalletScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Buy Stars',
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
                  // Balance Card matching reference image 2
                  WalletNeonCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    borderColor: const Color(0xFF24326A),
                    child: Row(
                      children: [
                        const StarIconWidget(size: 46),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Star Balance',
                              style: GoogleFonts.outfit(
                                color: WalletPalette.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  wallet.formattedStarBalance,
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Stars',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white70,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),
                  Text(
                    'Select a Package',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Packages Grid (2 columns, 4 rows) matching reference image 2
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: WalletController.packages.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.15,
                    ),
                    itemBuilder: (context, index) {
                      final package = WalletController.packages[index];
                      final isSelected = package.id == _selectedPackage.id;
                      final imagePath = _packImages[package.starsCount];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPackage = package;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF4C36ED)
                                  : const Color(0xFF24326A),
                              width: isSelected ? 1.8 : 1.2,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF4C36ED).withValues(alpha: 0.45),
                                      blurRadius: 16,
                                      spreadRadius: -1,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.5),
                              gradient: isSelected
                                  ? const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF191D4E),
                                        Color(0xFF0F1235),
                                      ],
                                    )
                                  : WalletPalette.cardFill,
                            ),
                            child: Stack(
                              children: [
                                // Popular badge
                                if (package.isPopular)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFFFF1E76), Color(0xFFFF4081)],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Popular',
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),

                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (imagePath != null)
                                        SizedBox(
                                          height: 38,
                                          child: Image.asset(
                                            imagePath,
                                            fit: BoxFit.contain,
                                            errorBuilder: (ctx, err, stack) => const StarIconWidget(size: 32),
                                          ),
                                        )
                                      else
                                        const StarIconWidget(size: 32),
                                      const SizedBox(height: 6),
                                      Text(
                                        package.formattedStars,
                                        style: GoogleFonts.outfit(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        'Stars',
                                        style: GoogleFonts.outfit(
                                          color: WalletPalette.textSecondary,
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      // Blue Pill Price matching reference image 2
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFF263388)
                                              : const Color(0xFF131A44),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(
                                            color: isSelected
                                                ? const Color(0xFF4C62D8)
                                                : const Color(0xFF243675),
                                          ),
                                        ),
                                        child: Text(
                                          package.formattedPrice,
                                          style: GoogleFonts.outfit(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                          ),
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
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom Bar matching reference image 2
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
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Package',
                          style: GoogleFonts.outfit(
                            color: WalletPalette.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_selectedPackage.formattedStars} Stars',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      _selectedPackage.formattedPrice,
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
                  label: 'Continue to Payment',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PaymentScreen(package: _selectedPackage),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Stars are credited after payment verification.',
                  style: GoogleFonts.outfit(
                    color: WalletPalette.textMuted,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
