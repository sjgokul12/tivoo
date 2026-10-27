import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/reel_video_manager.dart';
import '../../../../core/widgets/luxury_atmosphere_background.dart';
import '../../activity/presentation/screens/activity_screen.dart';
import '../../explore/presentation/screens/explore_screen.dart';
import '../../home/presentation/controllers/home_controller.dart';
import '../../home/presentation/screens/home_screen.dart';
import '../../home/presentation/widgets/floating_bottom_nav_bar.dart';
import 'package:tivoo/features/explore/presentation/widgets/upload_video_sheet.dart';
import '../../profile/presentation/screens/profile_screen.dart';

class MainNavigationScreen extends ConsumerWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavIndexProvider);

    final pages = [
      const ExploreScreen(),
      const HomeScreen(),
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
                if (index != 0) {
                  ReelVideoManager.instance.pauseAll();
                }
                ref.read(bottomNavIndexProvider.notifier).state = index;
              },
              onGoLiveTap: () {
                ReelVideoManager.instance.pauseAll();
                UploadVideoSheet.show(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
