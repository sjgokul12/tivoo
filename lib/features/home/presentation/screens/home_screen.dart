import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/luxe_theme.dart';
import '../../../pk_battle/lobby/pk_home_screen.dart';
import '../controllers/home_controller.dart';
import '../widgets/home_header.dart';
import '../widgets/home_hero_banner.dart';
import '../widgets/popular_taalmil_view.dart';
import '../../../broadcast/presentation/screens/go_live_broadcast_screen.dart';
import '../../../chat_room/chat_room_party_screen.dart';
import '../../../wallet/presentation/screens/wallet_screen.dart';

/// Home: header, hero banner, category pills (Live / PK Battle / Chat Room / Popular)
/// and the 2-column grid of live cards. PK Battle and Chat Room open full screen.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const _live = 0, _pk = 1, _chat = 2, _popular = 3;
  int _tab = _live;

  void _onTab(int index) {
    if (index == _pk) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => const PkHomeScreen()));
      return;
    }
    if (index == _chat) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ChatRoomPartyScreen(initialStage: 1, onBack: () => Navigator.of(context).pop()),
        ),
      );
      return;
    }
    setState(() => _tab = index);
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 1)));
  }

  void _openGoLive() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GoLiveBroadcastScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final streams = ref.watch(homeControllerProvider).allStreams;
    final shown = _tab == _popular
        ? ([...streams]..sort((a, b) => (b.heatScore ?? 0).compareTo(a.heatScore ?? 0)))
        : streams;

    return Scaffold(
      backgroundColor: kHomeNavy,
      body: Stack(
        children: [
          const Positioned.fill(child: LuxeBackdrop()),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverSafeArea(
                bottom: false,
                sliver: SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 18, 14, 14),
                    child: HomeHeader(
                      notificationCount: 5,
                      onSearchTap: () => _toast('Search people, live streams & tags'),
                      onWalletTap: () => WalletScreen.push(context),
                      onNotificationsTap: () => _toast('Notifications'),
                      onGoLiveTap: _openGoLive,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(padding: EdgeInsets.symmetric(horizontal: 14), child: HomeHeroBanner()),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: HomeCategoryTabs(selectedIndex: _tab, onSelected: _onTab),
                ),
              ),
              PopularTaalmilView(
                streams: shown,
                onFollowTap: (s) => ref.read(homeControllerProvider.notifier).toggleFollow(s.id),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
