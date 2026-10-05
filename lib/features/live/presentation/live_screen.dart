import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/state_message.dart';
import '../../../data/models/live_stream.dart';
import '../../home/providers/live_now_provider.dart';
import '../../pk/presentation/pk_battle_screen.dart';
import 'widgets/live_room_page.dart';

/// Full-screen, TikTok-style vertical feed of live rooms (Discover).
///
/// By default it pages through the shared [liveNowProvider] feed and loads
/// more as the viewer swipes; pass [stream] to open a single room instead.
class LiveScreen extends ConsumerStatefulWidget {
  const LiveScreen({super.key, this.initialIndex = 0, this.stream});

  final int initialIndex;
  final LiveStream? stream;

  static Route<void> route({int initialIndex = 0, LiveStream? stream}) => MaterialPageRoute(
        builder: (_) => LiveScreen(initialIndex: initialIndex, stream: stream),
      );

  @override
  ConsumerState<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends ConsumerState<LiveScreen> {
  late final PageController _pageController = PageController(initialPage: widget.initialIndex);
  late final ValueNotifier<int> _currentPage = ValueNotifier(widget.initialIndex);

  /// False while another route (PK) covers this one, so videos pause.
  final _routeVisible = ValueNotifier(true);

  @override
  void dispose() {
    _pageController.dispose();
    _currentPage.dispose();
    _routeVisible.dispose();
    super.dispose();
  }

  Future<void> _openPk() async {
    _routeVisible.value = false;
    await Navigator.of(context).push(PkBattleScreen.route());
    if (mounted) _routeVisible.value = true;
  }

  void _onPageChanged(int index, int total) {
    _currentPage.value = index;
    if (widget.stream == null && index >= total - 2) {
      ref.read(liveNowProvider.notifier).loadMore();
    }
  }

  Widget _feed(List<LiveStream> streams) {
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      // Keeps the neighbouring room built so its video is ready before the swipe lands.
      allowImplicitScrolling: true,
      itemCount: streams.length,
      onPageChanged: (i) => _onPageChanged(i, streams.length),
      itemBuilder: (_, index) {
        final stream = streams[index];
        return ListenableBuilder(
          listenable: Listenable.merge([_currentPage, _routeVisible]),
          builder: (_, _) => LiveRoomPage(
            key: ValueKey(stream.id),
            stream: stream,
            isActive: _currentPage.value == index && _routeVisible.value,
            onOpenPk: _openPk,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final single = widget.stream;
    final Widget body;
    if (single != null) {
      body = _feed([single]);
    } else {
      // Only rebuild when the list itself changes, not on paging flags.
      final streams = ref.watch(liveNowProvider.select((a) => a.whenData((s) => s.items)));
      body = streams.when(
        data: (items) => items.isEmpty
            ? const Center(
                child: StateMessage(icon: Icons.live_tv_rounded, title: 'Nobody is live right now'),
              )
            : _feed(items),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: StateMessage(
            icon: Icons.wifi_off_rounded,
            title: 'Could not load live streams',
            actionLabel: 'Retry',
            onAction: () => ref.invalidate(liveNowProvider),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: body,
    );
  }
}
