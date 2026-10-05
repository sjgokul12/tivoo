import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_background.dart';
import '../../../core/widgets/state_message.dart';
import '../../home/presentation/home_screen.dart';
import '../../live/presentation/live_screen.dart';
import '../providers/shell_tab_provider.dart';
import 'widgets/glass_bottom_nav.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  static Route<void> route() => PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 450),
        pageBuilder: (_, _, _) => const MainShell(),
        transitionsBuilder: (_, animation, _, child) => FadeTransition(opacity: animation, child: child),
      );

  static const _pages = <ShellTab, Widget>{
    ShellTab.home: HomeScreen(),
    ShellTab.goLive: Center(
      child: StateMessage(
        icon: Icons.sensors_rounded,
        title: 'Go Live is coming soon',
        message: 'Broadcast yourself to the Tivoo world.',
      ),
    ),
    ShellTab.messages: Center(
      child: StateMessage(
        icon: Icons.chat_bubble_outline_rounded,
        title: 'No messages yet',
        message: 'Chats with your friends and creators will appear here.',
      ),
    ),
    ShellTab.profile: Center(
      child: StateMessage(
        icon: Icons.person_outline_rounded,
        title: 'Profile',
        message: 'Your profile is coming soon.',
      ),
    ),
  };

  void _onSelected(BuildContext context, WidgetRef ref, ShellTab tab) {
    if (tab == ShellTab.discover) {
      Navigator.of(context).push(LiveScreen.route());
      return;
    }
    ref.read(shellTabProvider.notifier).select(tab);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(shellTabProvider);
    final keys = _pages.keys.toList(growable: false);
    return Scaffold(
      extendBody: true,
      body: AppBackground(
        child: IndexedStack(
          index: keys.indexOf(current),
          children: _pages.values.toList(growable: false),
        ),
      ),
      bottomNavigationBar: GlassBottomNav(
        current: current,
        onSelected: (tab) => _onSelected(context, ref, tab),
      ),
    );
  }
}
