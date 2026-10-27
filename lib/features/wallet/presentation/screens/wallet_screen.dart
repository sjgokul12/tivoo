import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/wallet_controller.dart';
import '../widgets/wallet_widgets.dart';
import 'activity_history_screen.dart';
import 'buy_stars_screen.dart';
import 'convert_currency_screen.dart';
import 'withdraw_coin_screen.dart';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  static Future<void> push(BuildContext context) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WalletScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);

    return WalletScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 74,
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF131844),
              border: Border.all(color: const Color(0xFF3843FF).withValues(alpha: 0.5)),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glitch-free, full fitted Tivoo logo with golden star perched on 'i'
            const TivooWalletLogo(size: 26),
            const SizedBox(height: 2),
            Text(
              'My Wallet',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // Help & FAQ Action
          IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF131844),
                border: Border.all(color: const Color(0xFF3843FF).withValues(alpha: 0.5)),
              ),
              child: const Center(
                child: Text(
                  '?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            onPressed: () => WalletHelpDialog.show(context),
          ),
          // Settings Action matching reference
          IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF131844),
                border: Border.all(color: const Color(0xFF3843FF).withValues(alpha: 0.5)),
              ),
              child: const Icon(
                Icons.settings_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
            onPressed: () => WalletHelpDialog.show(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------------------------------------------------------------
            // Top Balance Cards (3D Star & 3D T-Coin)
            // -------------------------------------------------------------
            Row(
              children: [
                // Star Balance Card
                Expanded(
                  child: WalletNeonCard(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    borderColors: WalletPalette.borderGoldAmber,
                    glowColor: const Color(0xFFFFB300),
                    glowOpacity: 0.4,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const BuyStarsScreen()),
                      );
                    },
                    child: Row(
                      children: [
                        const StarBalanceHeroIcon(size: 52),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFD600)),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Star',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                wallet.formattedStarBalance,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // T Coin Balance Card
                Expanded(
                  child: WalletNeonCard(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    borderColors: WalletPalette.borderCyanBlue,
                    glowColor: const Color(0xFF00E5FF),
                    glowOpacity: 0.4,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const WithdrawCoinScreen()),
                      );
                    },
                    child: Row(
                      children: [
                        const TCoinBalanceHeroIcon(size: 52),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 14,
                                    height: 14,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFF2979FF),
                                    ),
                                    child: const Icon(Icons.workspace_premium_rounded, size: 10, color: Colors.white),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'T Coin',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                wallet.formattedTCoinBalance,
                                style: GoogleFonts.outfit(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
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

            const SizedBox(height: 14),

            // -------------------------------------------------------------
            // Purchase Star Promo Banner with Treasure Chest & Pink Button
            // -------------------------------------------------------------
            WalletNeonCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              borderColors: WalletPalette.borderPinkPurple,
              glowColor: const Color(0xFFE040FB),
              glowOpacity: 0.45,
              fillGradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF241235),
                  Color(0xFF170C24),
                  Color(0xFF0E071A),
                ],
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BuyStarsScreen()),
                );
              },
              child: Row(
                children: [
                  // 3D Treasure Chest overflowing with stars
                  const WalletTreasureChestWidget(width: 66, height: 46),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Purchase Star',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Get Stars instantly',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFD4B3E2),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Yellow Purchase Button matching user request
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: WalletPalette.cyberYellowButton,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD600).withValues(alpha: 0.5),
                          blurRadius: 14,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Purchase',
                          style: GoogleFonts.outfit(
                            color: const Color(0xFF160E00),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: Color(0xFF160E00),
                          size: 11,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // -------------------------------------------------------------
            // Quick Actions Header with glowing pill & View All
            // -------------------------------------------------------------
            Row(
              children: [
                Text(
                  'Quick Actions',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 20,
                  height: 3.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C4DFF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ActivityHistoryScreen()),
                    );
                  },
                  child: Text(
                    'View All >',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF90A0D0),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // -------------------------------------------------------------
            // Quick Actions (3 Cards side-by-side matching reference, mobile-responsive)
            // -------------------------------------------------------------
            LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: [
                    // 1. Convert Star to T Coin (Gold/Amber)
                    Expanded(
                      child: _buildQuickActionCard(
                        context: context,
                        borderColors: WalletPalette.borderGoldAmber,
                        glowColor: const Color(0xFFFFB300),
                        icon: const GoldExchangeArrowsIcon(width: 48, height: 38),
                        title: 'Convert Star\nto T Coin',
                        subtitle: 'Star → T Coin',
                        accentColor: const Color(0xFFFFD600),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ConvertCurrencyScreen(isStarToTCoin: true),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 6),

                    // 2. Convert T Coin to Star (Electric Blue)
                    Expanded(
                      child: _buildQuickActionCard(
                        context: context,
                        borderColors: WalletPalette.borderCyanBlue,
                        glowColor: const Color(0xFF2979FF),
                        icon: const CoinsExchangeBlueArrowIcon(width: 48, height: 38),
                        title: 'Convert T Coin\nto Star',
                        subtitle: 'T Coin → Star',
                        accentColor: const Color(0xFF2979FF),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ConvertCurrencyScreen(isStarToTCoin: false),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 6),

                    // 3. Withdraw T Coin (Mint/Cyan Bank)
                    Expanded(
                      child: _buildQuickActionCard(
                        context: context,
                        borderColors: WalletPalette.borderNeonCyan,
                        glowColor: const Color(0xFF00E5FF),
                        icon: const BankTempleCyanIcon(width: 48, height: 38),
                        title: 'Withdraw\nT Coin',
                        subtitle: 'T Coin to Bank',
                        accentColor: const Color(0xFF00E5FF),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const WithdrawCoinScreen()),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),

            // -------------------------------------------------------------
            // Recent Activity Header with glowing pill & View All
            // -------------------------------------------------------------
            Row(
              children: [
                Text(
                  'Recent Activity',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 20,
                  height: 3.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C4DFF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ActivityHistoryScreen()),
                    );
                  },
                  child: Text(
                    'View All >',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF90A0D0),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Recent Activity Container Card matching reference Image
            WalletNeonCard(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              borderColors: const [Color(0xFF202A56), Color(0xFF161E42)],
              glowOpacity: 0.15,
              child: Column(
                children: List.generate(
                  wallet.transactions.take(4).length,
                  (index) {
                    final tx = wallet.transactions[index];
                    final isLast = index == wallet.transactions.take(4).length - 1;
                    return Column(
                      children: [
                        TransactionActivityTile(
                          transaction: tx,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const ActivityHistoryScreen()),
                            );
                          },
                        ),
                        if (!isLast)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Divider(color: Color(0xFF161E42), height: 1),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required BuildContext context,
    required List<Color> borderColors,
    required Color glowColor,
    required Widget icon,
    required String title,
    required String subtitle,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return WalletNeonCard(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
      borderColors: borderColors,
      glowColor: glowColor,
      glowOpacity: 0.35,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: icon),
          const SizedBox(height: 8),
          SizedBox(
            height: 32,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                  maxLines: 2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      color: WalletPalette.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.2),
                  border: Border.all(color: accentColor.withValues(alpha: 0.6), width: 1),
                ),
                child: Icon(Icons.arrow_forward_rounded, size: 11, color: accentColor),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
