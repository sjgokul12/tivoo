import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/luxe_theme.dart';
import '../../models/wallet_models.dart';

/// Palette with vibrant neon glow gradients matching reference UI
class WalletPalette {
  WalletPalette._();

  // Cosmic Background
  static const Color bgTop = Color(0xFF090724);
  static const Color bgMid = Color(0xFF07051C);
  static const Color bgBottom = Color(0xFF040312);

  // Cards
  static const Color cardFillTop = Color(0xFF0F143A);
  static const Color cardFillBottom = Color(0xFF080B22);

  // Neon Borders
  static const List<Color> borderGoldPurple = [
    Color(0xFFFFD54F),
    Color(0xFFFF9100),
    Color(0xFFE040FB),
    Color(0xFF7C4DFF),
  ];

  static const List<Color> borderCyanBlue = [
    Color(0xFF00E5FF),
    Color(0xFF00B0FF),
    Color(0xFF2979FF),
    Color(0xFF3D5AFE),
  ];

  static const List<Color> borderGoldAmber = [
    Color(0xFFFFEA00),
    Color(0xFFFFD600),
    Color(0xFFFF9100),
    Color(0xFFFF6D00),
  ];

  static const List<Color> borderNeonCyan = [
    Color(0xFF00E5FF),
    Color(0xFF00B4D8),
    Color(0xFF0077B6),
  ];

  static const List<Color> borderPinkPurple = [
    Color(0xFFFF2E93),
    Color(0xFFFF4081),
    Color(0xFFE040FB),
    Color(0xFF7C4DFF),
  ];

  static const List<Color> borderPinkYellow = [
    Color(0xFFFF1E76),
    Color(0xFFFF4081),
    Color(0xFFFF9100),
    Color(0xFFFFD600),
  ];

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8A99B5);
  static const Color textMuted = Color(0xFF6B7A99);
  static const Color goldAccent = Color(0xFFFFD600);
  static const Color electricBlue = Color(0xFF3D7BFF);

  static const LinearGradient cosmicBg = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [bgTop, bgMid, bgBottom],
  );

  static const LinearGradient cardFill = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cardFillTop, cardFillBottom],
  );

  static const LinearGradient cyberYellowButton = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFF9C4), Color(0xFFFFEA00), Color(0xFFFFD600), Color(0xFFFF9800)],
  );

  static const LinearGradient pinkPurchaseButton = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFF2E93), Color(0xFFE02070), Color(0xFFC00060)],
  );

  static const LinearGradient primaryButton = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF4C36ED), Color(0xFF6842FF), Color(0xFF3865FF)],
  );
}

// ============================================================================
// 1. OFFICIAL TIVOO LOGO (Pacifico Wordmark with Crown & Sparkles matching reference)
// ============================================================================

/// Official Tivoo logo matching reference image:
/// Flowing script (Pacifico), "Tiv" in gold, "oo" in neon violet-blue,
/// dark outline, golden crown on 'T' with pearls and ruby, and gold sparkles over 'oo'.
/// Constructed with proper padding so it is full-fitted and never clipped.
class TivooWalletLogo extends StatelessWidget {
  final double size;
  const TivooWalletLogo({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      fontFamily: 'Pacifico',
      fontSize: size,
      height: 1.15,
      letterSpacing: 0.5,
    );

    final crownSize = size * 0.52;
    final crownTopSpace = size * 0.32;

    Widget word(String text, Gradient fill, Color glow) => Stack(
      children: [
        // Outline + glow + shadow
        Text(
          text,
          style: base.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = size * 0.13
              ..color = const Color(0xFF130830)
              ..strokeJoin = StrokeJoin.round,
            shadows: [
              Shadow(color: glow, blurRadius: size * 0.45),
              Shadow(color: const Color(0xCC000000), blurRadius: 4, offset: Offset(0, size * 0.08)),
            ],
          ),
        ),
        // Gradient text fill
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: fill.createShader,
          child: Text(text, style: base.copyWith(color: Colors.white)),
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.only(top: crownTopSpace, right: size * 0.22, left: size * 0.06),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              word(
                'Tiv',
                const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFFDE7),
                    Color(0xFFFFEE58),
                    Color(0xFFFFC107),
                    Color(0xFFFF8F00),
                  ],
                  stops: [0.0, 0.25, 0.65, 1.0],
                ),
                const Color(0x99FFC928),
              ),
              word(
                'oo',
                const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE8D5FF),
                    Color(0xFFD188FF),
                    Color(0xFF9C4DFF),
                    Color(0xFF536DFE),
                  ],
                  stops: [0.0, 0.3, 0.7, 1.0],
                ),
                const Color(0x99B04DFF),
              ),
            ],
          ),
          // Crown on the top-left loop of 'T'
          Positioned(
            left: -size * 0.02,
            top: -crownTopSpace * 0.85,
            child: Transform.rotate(
              angle: -0.28,
              child: LuxeCrown(size: crownSize),
            ),
          ),
          // Triple Sparkle Cluster over last 'o'
          Positioned(
            right: -size * 0.20,
            top: -crownTopSpace * 0.1,
            child: _SparkleCluster(size: size * 0.40),
          ),
        ],
      ),
    );
  }
}

class _SparkleCluster extends StatelessWidget {
  final double size;
  const _SparkleCluster({required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SparkleClusterPainter(),
      ),
    );
  }
}

class _SparkleClusterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    void drawStar(Offset center, double r) {
      final path = Path()
        ..moveTo(center.dx, center.dy - r)
        ..quadraticBezierTo(center.dx, center.dy, center.dx + r, center.dy)
        ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + r)
        ..quadraticBezierTo(center.dx, center.dy, center.dx - r, center.dy)
        ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - r)
        ..close();

      canvas.drawPath(
        path,
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFFFFDE7), Color(0xFFFFD54F), Color(0xFFFF8F00)],
          ).createShader(path.getBounds()),
      );
    }

    // Main 4-point sparkle
    drawStar(Offset(w * 0.4, h * 0.45), w * 0.36);
    // Top-right smaller sparkle
    drawStar(Offset(w * 0.85, h * 0.22), w * 0.18);
    // Bottom-right tiny sparkle
    drawStar(Offset(w * 0.88, h * 0.72), w * 0.13);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// 2. HERO BALANCE ICONS (Using uploaded assets: gstar.png & tcoin.png)
// ============================================================================

/// 3D Luminous Star icon using `assets/wallet/gstar.png`
class StarBalanceHeroIcon extends StatelessWidget {
  final double size;
  const StarBalanceHeroIcon({super.key, this.size = 54});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB300).withValues(alpha: 0.35),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/wallet/gstar.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

/// 3D Luminous T Coin icon using `assets/wallet/tcoin.png`
class TCoinBalanceHeroIcon extends StatelessWidget {
  final double size;
  const TCoinBalanceHeroIcon({super.key, this.size = 54});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/wallet/tcoin.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

// ============================================================================
// 3. PURCHASE PROMO TREASURE CHEST (Using uploaded asset: treasure.png)
// ============================================================================

/// 3D Purple & Gold Treasure Chest using `assets/wallet/treasure.png`
class WalletTreasureChestWidget extends StatelessWidget {
  final double width;
  final double height;

  const WalletTreasureChestWidget({
    super.key,
    this.width = 68,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD600).withValues(alpha: 0.35),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          'assets/wallet/treasure.png',
          width: width,
          height: height,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

// ============================================================================
// 4. QUICK ACTION ICONS (Using uploaded assets: startocoin, cointostar, withdraw)
// ============================================================================

/// Convert Star to T Coin icon using `assets/wallet/startocoin.png`
class GoldExchangeArrowsIcon extends StatelessWidget {
  final double size;
  final double? width;
  final double? height;

  const GoldExchangeArrowsIcon({
    super.key,
    this.size = 46,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final w = width ?? size * 1.2;
    final h = height ?? size;

    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB300).withValues(alpha: 0.35),
            blurRadius: 8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/wallet/startocoin.png',
          width: w,
          height: h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

/// Convert T Coin to Star icon using `assets/wallet/cointostar.png`
class CoinsExchangeBlueArrowIcon extends StatelessWidget {
  final double size;
  final double? width;
  final double? height;

  const CoinsExchangeBlueArrowIcon({
    super.key,
    this.size = 46,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final w = width ?? size * 1.2;
    final h = height ?? size;

    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2979FF).withValues(alpha: 0.35),
            blurRadius: 8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/wallet/cointostar.png',
          width: w,
          height: h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

/// Withdraw T Coin icon using `assets/wallet/withdraw.png`
class BankTempleCyanIcon extends StatelessWidget {
  final double size;
  final double? width;
  final double? height;

  const BankTempleCyanIcon({
    super.key,
    this.size = 46,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final w = width ?? size * 1.2;
    final h = height ?? size;

    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
            blurRadius: 8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          'assets/wallet/withdraw.png',
          width: w,
          height: h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

// ============================================================================
// 5. RECENT ACTIVITY EMBLEMS (3D Luminous Spherical Glass Emblems)
// ============================================================================

/// Realistic 3D Spherical Jewel Activity Emblem matching reference Image:
/// - Green sphere with white ↑ for Withdrawals
/// - Amber sphere with white ⇄ for Star to T Coin
/// - Blue sphere with white ⇄ for T Coin to Star
/// - Pink sphere with white 🛒 for Star Purchases
class Realistic3DActivityEmblem extends StatelessWidget {
  final TransactionType type;
  final double size;

  const Realistic3DActivityEmblem({
    super.key,
    required this.type,
    this.size = 42,
  });

  @override
  Widget build(BuildContext context) {
    List<Color> sphereColors;
    IconData iconData;
    Color glowColor;

    switch (type) {
      case TransactionType.withdrawTCoin:
        sphereColors = [
          const Color(0xFFB9F6CA),
          const Color(0xFF00E676),
          const Color(0xFF00B0FF),
          const Color(0xFF00897B),
        ];
        iconData = Icons.arrow_upward_rounded;
        glowColor = const Color(0xFF00E676);
        break;
      case TransactionType.starToTCoin:
        sphereColors = [
          const Color(0xFFFFF9C4),
          const Color(0xFFFFD600),
          const Color(0xFFFF9100),
          const Color(0xFFE65100),
        ];
        iconData = Icons.swap_horiz_rounded;
        glowColor = const Color(0xFFFFB300);
        break;
      case TransactionType.tCoinToStar:
        sphereColors = [
          const Color(0xFFE1F5FE),
          const Color(0xFF00E5FF),
          const Color(0xFF2979FF),
          const Color(0xFF1565C0),
        ];
        iconData = Icons.swap_horiz_rounded;
        glowColor = const Color(0xFF2979FF);
        break;
      case TransactionType.starPurchase:
        sphereColors = [
          const Color(0xFFFF80AB),
          const Color(0xFFFF4081),
          const Color(0xFFE040FB),
          const Color(0xFF880E4F),
        ];
        iconData = Icons.shopping_cart_rounded;
        glowColor = const Color(0xFFFF4081);
        break;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.5),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 3D Spherical Radial Base
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.35, -0.35),
                radius: 0.9,
                colors: sphereColors,
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 1.2,
              ),
            ),
          ),
          // Specular curved glass arc reflection on upper hemisphere
          Positioned(
            top: size * 0.08,
            left: size * 0.18,
            child: Container(
              width: size * 0.55,
              height: size * 0.25,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.75),
                    Colors.white.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          // Crisp White Icon
          Icon(
            iconData,
            color: Colors.white,
            size: size * 0.54,
            shadows: const [
              Shadow(
                color: Color(0x66000000),
                offset: Offset(0, 1.5),
                blurRadius: 2,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 6. ACTIVITY ROW TILE
// ============================================================================

/// Clean activity list item matching reference Image
class TransactionActivityTile extends StatelessWidget {
  final WalletTransaction transaction;
  final VoidCallback? onTap;

  const TransactionActivityTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          children: [
            Realistic3DActivityEmblem(type: transaction.type, size: 42),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    transaction.title,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transaction.subtitle,
                    style: GoogleFonts.outfit(
                      color: WalletPalette.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              transaction.dateText,
              style: GoogleFonts.outfit(
                color: WalletPalette.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF6B7A99),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 7. NEON CARD & SCAFFOLDING
// ============================================================================

/// Vibrant Glass Card with glowing neon gradient border matching reference
class WalletNeonCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double radius;
  final List<Color>? borderColors;
  final Color? borderColor;
  final Gradient? fillGradient;
  final VoidCallback? onTap;
  final double glowOpacity;
  final Color? glowColor;

  const WalletNeonCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.radius = 20,
    this.borderColors,
    this.borderColor,
    this.fillGradient,
    this.onTap,
    this.glowOpacity = 0.35,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = borderColors ??
        (borderColor != null
            ? [borderColor!, borderColor!]
            : WalletPalette.borderGoldPurple);

    final effectiveGlowColor = glowColor ?? colors[0];

    final content = Container(
      margin: margin,
      padding: const EdgeInsets.all(1.6), // Crisp visible glowing border
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: glowOpacity > 0
            ? [
                BoxShadow(
                  color: effectiveGlowColor.withValues(alpha: glowOpacity),
                  blurRadius: 16,
                  spreadRadius: -1,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius - 1.6),
          gradient: fillGradient ?? WalletPalette.cardFill,
        ),
        child: child,
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: content,
        ),
      );
    }
    return content;
  }
}

/// Cosmic Scaffolding with ambient aurora background matching reference
class WalletScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final bool? resizeToAvoidBottomInset;

  const WalletScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WalletPalette.bgBottom,
      extendBodyBehindAppBar: false,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: WalletPalette.cosmicBg,
              ),
            ),
          ),
          // Ambient Glowing Aurora Orbs
          Positioned(
            top: -40,
            left: 20,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF5B3EFF).withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 180,
            right: -50,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFF1E76).withValues(alpha: 0.16),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(child: body),
        ],
      ),
    );
  }
}

/// Primary Glowing Button matching reference image
class WalletActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Gradient? gradient;
  final Color textColor;
  final double height;
  final double radius;
  final Widget? leading;

  const WalletActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.gradient,
    this.textColor = Colors.white,
    this.height = 52,
    this.radius = 16,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: isEnabled ? (gradient ?? WalletPalette.primaryButton) : null,
        color: isEnabled ? null : const Color(0xFF15193B),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: (gradient != null ? const Color(0xFFFFD600) : const Color(0xFF4C36ED))
                      .withValues(alpha: 0.45),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: isEnabled ? onPressed : null,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (leading != null) ...[
                        leading!,
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: GoogleFonts.outfit(
                          color: isEnabled ? textColor : Colors.white30,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Help modal dialog explaining Star, T Coin, and conversion rates
class WalletHelpDialog extends StatelessWidget {
  const WalletHelpDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const WalletHelpDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 32),
      decoration: const BoxDecoration(
        color: Color(0xFF0F0C28),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: Color(0xFF7A4CFF), width: 1.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Icon(Icons.help_outline_rounded, color: WalletPalette.goldAccent, size: 24),
              const SizedBox(width: 10),
              Text(
                'Wallet & Economics Guide',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildItem(
            '⭐ Stars',
            'Stars are used to send animated gifts, support streamers, and level up your VIP rank during live streams and PK battles.',
          ),
          const SizedBox(height: 12),
          _buildItem(
            '🪙 T Coins',
            'T Coins are earned from received gifts. You can convert T Coins back to Stars or withdraw them directly to your verified bank account.',
          ),
          const SizedBox(height: 12),
          _buildItem(
            '🔄 Conversion Ratios',
            '• 3 Stars = 1 T Coin\n• 1 T Coin = 2 Stars\n• 1 T Coin = ₹0.50 INR withdrawable value (Min. 100 T Coins)',
          ),
          const SizedBox(height: 12),
          _buildItem(
            '🏦 Withdrawals',
            'Withdrawals are transferred directly via IMPS/NEFT to your linked bank account within 1-3 business days.',
          ),
          const SizedBox(height: 24),
          WalletActionButton(
            label: 'Got It',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(String title, String body) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              color: WalletPalette.goldAccent,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 8. BACKWARD COMPATIBILITY ALIASES
// ============================================================================

class StarIconWidget extends StatelessWidget {
  final double size;
  const StarIconWidget({super.key, this.size = 44});
  @override
  Widget build(BuildContext context) => StarBalanceHeroIcon(size: size);
}

class TCoinIcon extends StatelessWidget {
  final double size;
  const TCoinIcon({super.key, this.size = 44});
  @override
  Widget build(BuildContext context) => TCoinBalanceHeroIcon(size: size);
}

class Realistic3DBankBuilding extends StatelessWidget {
  final double size;
  const Realistic3DBankBuilding({super.key, this.size = 52});
  @override
  Widget build(BuildContext context) => BankTempleCyanIcon(size: size);
}

class Realistic3DYellowCart extends StatelessWidget {
  final double size;
  const Realistic3DYellowCart({super.key, this.size = 50});
  @override
  Widget build(BuildContext context) => WalletTreasureChestWidget(width: size * 1.3, height: size);
}

class CelebrationStarWidget extends StatelessWidget {
  final double size;
  const CelebrationStarWidget({super.key, this.size = 170});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.85,
            height: size * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFC107).withValues(alpha: 0.5),
                  blurRadius: size * 0.45,
                  spreadRadius: 10,
                ),
              ],
            ),
          ),
          StarBalanceHeroIcon(size: size * 0.8),
        ],
      ),
    );
  }
}
