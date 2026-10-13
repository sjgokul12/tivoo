import 'package:flutter/material.dart';

import '../../../live_stream/presentation/screens/live_stream_screen.dart';
import '../../../pk_battle/pk_battle_live_screen.dart';
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
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Center(
            child: Text('No live broadcasts right now', style: TextStyle(color: Colors.white54)),
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
        delegate: SliverChildBuilderDelegate(childCount: streams.length, (context, index) {
          final stream = streams[index];
          return HomeGridStreamCard(
            stream: stream,
            index: index,
            onFollowTap: onFollowTap == null ? null : () => onFollowTap!(stream),
            onTap: () => _open(context, index),
          );
        }),
      ),
    );
  }

  void _open(BuildContext context, int index) {
    final stream = streams[index];
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => stream.isPk
            ? PkBattleLiveScreen(onBack: () => Navigator.of(context).pop())
            : LiveStreamScreen(streams: streams, initialIndex: index),
      ),
    );
  }
}
