import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/star_wallet_controller.dart';
import 'purchase_stars_sheet.dart';

class StarUpBottomSheet extends ConsumerStatefulWidget {
  final String streamerName;
  final Function(int count)? onSendStars;

  const StarUpBottomSheet({
    super.key,
    required this.streamerName,
    this.onSendStars,
  });

  static Future<void> show(
    BuildContext context, {
    required String streamerName,
    Function(int count)? onSendStars,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => StarUpBottomSheet(
        streamerName: streamerName,
        onSendStars: onSendStars,
      ),
    );
  }

  @override
  ConsumerState<StarUpBottomSheet> createState() => _StarUpBottomSheetState();
}

class _StarUpBottomSheetState extends ConsumerState<StarUpBottomSheet> {
  int _selectedMultiplier = 1;

  void _handleStarTap(int multiplier) {
    setState(() => _selectedMultiplier = multiplier);

    final wallet = ref.read(starWalletProvider);
    if (wallet.starBalance < multiplier) {
      // User has 0 or insufficient stars -> prompt and open Dollar purchase sheet!
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1F1B24),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: Row(
            children: [
              const Icon(Icons.star_half_rounded, color: Color(0xFFFFD700)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'You need $multiplier Stars to send to ${widget.streamerName}! Please purchase more stars.',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      _openPurchaseSheet();
    } else {
      // User has enough stars -> send to streamer!
      final success = ref
          .read(starWalletProvider.notifier)
          .sendStars(multiplier);

      if (success) {
        widget.onSendStars?.call(multiplier);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1E1E2E),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            content: Row(
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFFD700)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Sent $multiplier Star${multiplier > 1 ? 's' : ''} to ${widget.streamerName}! ⭐✨',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _openPurchaseSheet() {
    PurchaseStarsSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(starWalletProvider);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.65,
      ),
      padding: EdgeInsets.fromLTRB(
        22,
        12,
        22,
        bottomPadding > 0 ? bottomPadding + 14 : 22,
      ),
      decoration: BoxDecoration(
        color: const Color(0xF912121A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: const Border(
          top: BorderSide(color: Color(0x33FFD700), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.15),
            blurRadius: 36,
            spreadRadius: -8,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Drag Handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 2. StarUp Header Title
            const Text(
              'StarUp',
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 6),

            // 3. Star Balance Indicator (⭐ No. 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFFD700),
                  size: 19,
                ),
                const SizedBox(width: 5),
                Text(
                  wallet.formattedBalance,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 4. Two Golden Star Option Cards (matching screenshot: x1 & x2)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Star Card x1
                Expanded(
                  child: _buildStarCard(
                    multiplier: 1,
                    label: 'x1',
                    isSelected: _selectedMultiplier == 1,
                    onTap: () => _handleStarTap(1),
                  ),
                ),
                const SizedBox(width: 18),

                // Star Card x2
                Expanded(
                  child: _buildStarCard(
                    multiplier: 2,
                    label: 'x2',
                    isSelected: _selectedMultiplier == 2,
                    onTap: () => _handleStarTap(2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Quick bulk options pill selector: x5, x10, x100
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [5, 10, 100].map((count) {
                final isSelected = _selectedMultiplier == count;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: GestureDetector(
                    onTap: () => _handleStarTap(count),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0x33FFD700)
                            : const Color(0xFF1E1E2C),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFFFD700)
                              : Colors.white10,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'x$count',
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFFFFD700)
                              : Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 5. High-Contrast Yellow Rounded Button: "Purchase More Stars"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _openPurchaseSheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFDF00),
                  foregroundColor: const Color(0xFF121212),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 6,
                  shadowColor: const Color(0x66FFDF00),
                ),
                child: const Text(
                  'Purchase More Stars',
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarCard({
    required int multiplier,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 140,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0x22FFD700) : const Color(0xFF181824),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFD700)
                : Colors.white.withValues(alpha: 0.12),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 3D Faceted Golden Star Graphic
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                    blurRadius: 22,
                    spreadRadius: -4,
                  ),
                ],
              ),
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return const RadialGradient(
                    center: Alignment(-0.2, -0.3),
                    radius: 0.8,
                    colors: [
                      Color(0xFFFFF9C4), // Highlight
                      Color(0xFFFFD700), // Gold
                      Color(0xFFFFB300), // Amber
                      Color(0xFFF57F17), // Deep Gold Edge
                    ],
                    stops: [0.0, 0.4, 0.75, 1.0],
                  ).createShader(bounds);
                },
                child: const Icon(
                  Icons.star_rounded,
                  size: 92,
                  color: Colors.white,
                ),
              ),
            ),

            // Multiplier label centered inside star ("x1", "x2")
            Positioned(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF5D4037),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(
                      color: Color(0x66FFFFFF),
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),

            // Subtle "TAP TO SEND" hint on bottom
            Positioned(
              bottom: 8,
              child: Text(
                'SEND $label',
                style: TextStyle(
                  color: isSelected
                      ? const Color(0xFFFFD700)
                      : Colors.white.withValues(alpha: 0.45),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
