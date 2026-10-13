import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/luxe_theme.dart';
import '../../../../core/widgets/glow_icon_button.dart';
import '../../../live_stream/presentation/controllers/star_wallet_controller.dart';
import '../../../live_stream/presentation/widgets/purchase_stars_sheet.dart';

class ExploreHeader extends ConsumerWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onFilterTap;
  final VoidCallback? onViewModeToggle;
  final VoidCallback? onWalletTap;

  /// Top-left back arrow (hidden when null).
  final VoidCallback? onBackTap;
  final bool isReelsView;

  const ExploreHeader({
    super.key,
    this.onSearchTap,
    this.onFilterTap,
    this.onViewModeToggle,
    this.onWalletTap,
    this.onBackTap,
    this.isReelsView = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final wallet = ref.watch(starWalletProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (onBackTap != null) ...[
            LuxeCircleButton(icon: Icons.arrow_back_ios_new_rounded, label: 'Back to Home', size: 38, onTap: onBackTap),
            const SizedBox(width: 10),
          ],
          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Explore',
                  style: AppTextStyles.heroHeading.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF161622),
                    letterSpacing: -0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  isReelsView ? 'Swipe to discover reels' : 'Discover amazing reels',
                  style: AppTextStyles.heroSubtitle.copyWith(
                    fontSize: 11.5,
                    color: isDark ? AppColors.textSecondary : const Color(0xFF6B6B78),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // User Account Wallet Button (Stars Balance + User ID Account Tooltip)
          Tooltip(
            message: 'Star Wallet (${wallet.userId})',
            child: GestureDetector(
              onTap: () {
                if (onWalletTap != null) {
                  onWalletTap!();
                } else {
                  PurchaseStarsSheet.show(context);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0x33FFD700), Color(0x18FFD700)]),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0x77FFD700), width: 1.1),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      wallet.formattedBalance,
                      style: const TextStyle(color: Color(0xFFFFD700), fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Action Buttons: Mode Toggle, Search
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onViewModeToggle != null) ...[
                GlowIconButton(
                  icon: isReelsView ? Icons.grid_view_rounded : Icons.slideshow_rounded,
                  iconColor: isReelsView ? AppColors.primaryYellow : AppColors.primaryPink,
                  glow: true,
                  glowColor: isReelsView
                      ? AppColors.primaryYellow.withValues(alpha: 0.3)
                      : AppColors.glowPink.withValues(alpha: 0.3),
                  onTap: onViewModeToggle,
                ),
                const SizedBox(width: 6),
              ],
              GlowIconButton(icon: Icons.search_rounded, onTap: onSearchTap),
              if (onFilterTap != null) ...[
                const SizedBox(width: 6),
                GlowIconButton(icon: Icons.tune_rounded, onTap: onFilterTap),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
