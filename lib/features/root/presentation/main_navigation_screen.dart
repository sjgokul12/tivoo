import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/reel_video_manager.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/luxury_atmosphere_background.dart';
import '../../activity/presentation/screens/activity_screen.dart';
import '../../broadcast/presentation/screens/go_live_broadcast_screen.dart';
import '../../explore/presentation/screens/explore_screen.dart';
import '../../home/presentation/controllers/home_controller.dart';
import '../../home/presentation/screens/home_screen.dart';
import '../../home/presentation/widgets/floating_bottom_nav_bar.dart';
import '../../profile/presentation/screens/profile_screen.dart';

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavIndexProvider);

    final pages = [
      const HomeScreen(),
      const ExploreScreen(),
      const ActivityScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Global Ultra-attractive Luxury Atmosphere Background
          const Positioned.fill(
            child: LuxuryAtmosphereBackground(),
          ),

          // Current Page
          IndexedStack(
            index: selectedIndex,
            children: pages,
          ),

          // Floating Curved Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingBottomNavBar(
              currentIndex: selectedIndex,
              activityBadgeCount: 5,
              onTap: (index) {
                if (index != 1) {
                  ReelVideoManager.instance.pauseAll();
                }
                ref.read(bottomNavIndexProvider.notifier).state = index;
              },
              onGoLiveTap: () {
                _showGoLiveModal(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showGoLiveModal(BuildContext rootContext) {
    showModalBottomSheet(
      context: rootContext,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: const Border(
            top: BorderSide(color: AppColors.borderSubtle, width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryYellow.withValues(alpha: 0.2),
              blurRadius: 40,
              spreadRadius: -10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.liveCenterButtonGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryYellow.withValues(alpha: 0.4),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: AppColors.textOnPrimary,
                size: 42,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Create & Go Live',
              style: AppTextStyles.heroHeading.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(
              'Broadcast to millions of viewers on Tivoo worldwide',
              style: AppTextStyles.heroSubtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GradientButton(
              text: 'Go Live Now',
              onPressed: () {
                Navigator.pop(context);
                Navigator.of(rootContext).push(
                  MaterialPageRoute(
                    builder: (context) => const GoLiveBroadcastScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}