import 'package:flutter/material.dart';

import '../../../broadcast/presentation/screens/go_live_broadcast_screen.dart';
import '../../../live_stream/presentation/screens/live_stream_screen.dart';
import '../../domain/models/live_stream_card_model.dart';
import 'home_grid_stream_card.dart';

/// Responsive grid of live cards (2 / 3 / 4 columns), as a sliver for the home screen's scroll view.
class PopularTaalmilView extends StatelessWidget {
  final List<LiveStreamCardModel> streams;
  final ValueChanged<LiveStreamCardModel>? onFollowTap;

  const PopularTaalmilView({super.key, required this.streams, this.onFollowTap});

  @override
  Widget build(BuildContext context) {
    if (streams.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: const Color(0xFF101426),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: const Color(0xFFFFD600).withValues(alpha: 0.22),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD600), Color(0xFFFF8A00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFB300).withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.sensors_rounded, color: Colors.black, size: 36),
                ),
                const SizedBox(height: 18),
                const Text(
                  'No Live Streams Right Now',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Be the first to broadcast live to your community!\nChoose your cover image and start streaming now.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 13,
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 22),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const GoLiveBroadcastScreen()),
                    );
                  },
                  icon: const Icon(Icons.videocam_rounded, color: Colors.black, size: 20),
                  label: const Text(
                    'Go Live Now',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD600),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    // 2 columns on phones, 3 on small tablets / landscape, 4 on large screens.
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1000 ? 4 : (width >= 600 ? 3 : 2);
    final gap = width < 360 ? 10.0 : 12.0;
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(14, 4, 14, 120 + MediaQuery.paddingOf(context).bottom),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          // Portrait cards suit the photos; a little squarer on wide layouts.
          childAspectRatio: columns == 2 ? 0.8 : 0.86,
          crossAxisSpacing: gap,
          mainAxisSpacing: gap,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final stream = streams[index];
            return HomeGridStreamCard(
              key: ValueKey(stream.id),
              stream: stream,
              index: index,
              onFollowTap: onFollowTap == null ? null : () => onFollowTap!(stream),
              onTap: () => _open(context, index),
            );
          },
          childCount: streams.length,
          addAutomaticKeepAlives: true,
          addRepaintBoundaries: true,
        ),
      ),
    );
  }

  void _open(BuildContext context, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LiveStreamScreen(streams: streams, initialIndex: index),
      ),
    );
  }
}
