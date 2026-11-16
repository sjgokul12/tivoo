import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/reel_video_manager.dart';
import '../../../../core/widgets/luxury_atmosphere_background.dart';
import '../../activity/presentation/screens/activity_screen.dart';
import '../../explore/presentation/screens/explore_screen.dart';
import '../../video_creator/presentation/screens/video_camera_screen.dart';
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
              onGoLiveTap: () => _showCreationChoiceSheet(context),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreationChoiceSheet(BuildContext context) {
    ReelVideoManager.instance.pauseAll();
    final mq = MediaQuery.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF131522),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: const Color(0x3300E5FF), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black87,
              blurRadius: 32,
              offset: Offset(0, -6),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(20, 14, 20, 20 + mq.padding.bottom),
        child: SafeArea(
          top: false,
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
              const SizedBox(height: 18),
              const Text(
                'Create & Upload',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Record, edit, apply filters & publish reels to Explore',
                style: TextStyle(color: Colors.white54, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              // Upload New Video
              _ChoiceTile(
                icon: Icons.video_library_rounded,
                gradient: const [Color(0xFF00E5FF), Color(0xFF7000FF)],
                glowColor: const Color(0x5500E5FF),
                title: 'Upload New Video',
                subtitle: 'Record, edit, apply filters & publish reels to Explore',
                badge: 'CREATOR',
                onTap: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const VideoCameraScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  final IconData icon;
  final List<Color> gradient;
  final Color glowColor;
  final String title;
  final String subtitle;
  final String badge;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.icon,
    required this.gradient,
    required this.glowColor,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1E30),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12, width: 1.0),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: gradient),
                boxShadow: [
                  BoxShadow(color: glowColor, blurRadius: 14, offset: const Offset(0, 3)),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: gradient),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 14),
          ],
        ),
      ),
    );
  }
}