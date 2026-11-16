// PK battle live screen: the vertical swipe feed. Each page is either the
// viewer (user) screen or the streamer screen — see viewer/ and streamer/.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/pk_feed_data.dart';
import 'core/pk_models.dart';
import 'lobby/pk_home_screen.dart';
import 'sheets/pk_explore_sheet.dart';
import 'streamer/pk_streamer_battle_view.dart';
import 'viewer/pk_viewer_battle_view.dart';

/// Live PK battle feed with smooth vertical swipe scrolling like a live video feed.
/// Swiping up or down transitions to the next or previous mock PK battle with
/// distinct streamers, videos, avatars, scores, viewer counts, and comments.
class PkBattleLiveScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  /// The initial battle to show (defaults to Neha vs Arun).
  final PkMatch match;

  /// Whether the current user is host / creator of this battle (defaults to false for viewers).
  final bool? isCreator;

  const PkBattleLiveScreen({super.key, this.onBack, this.match = PkDemoData.featured, this.isCreator});

  @override
  ConsumerState<PkBattleLiveScreen> createState() => _PkBattleLiveScreenState();
}

class _PkBattleLiveScreenState extends ConsumerState<PkBattleLiveScreen> {
  late final List<PkBattleFeedItem> _feed;
  late final PageController _pageController;
  late int _currentPage;
  late final bool _isCreator;

  @override
  void initState() {
    super.initState();
    _isCreator = widget.isCreator ?? false;
    _feed = List.of(PkFeedData.feedBattles);
    final matchIndex = _feed.indexWhere((item) => item.match.id == widget.match.id);
    if (matchIndex != -1) {
      _currentPage = matchIndex;
    } else {
      _feed.insert(0, PkBattleFeedItem.fromMatch(widget.match));
      _currentPage = 0;
    }
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (_currentPage != index) {
      setState(() => _currentPage = index);
    }
  }

  void _openExploreSheet() {
    final currentMatch = _feed[_currentPage].match;
    PkExploreSheet.show(
      context,
      currentMatchId: currentMatch.id,
      onSelectBattle: (newBattle) {
        final foundIndex = _feed.indexWhere((f) => f.match.id == newBattle.id);
        if (foundIndex != -1) {
          _pageController.animateToPage(
            foundIndex,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOut,
          );
        } else {
          setState(() {
            _feed.add(PkBattleFeedItem.fromMatch(newBattle));
          });
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients) {
              _pageController.animateToPage(
                _feed.length - 1,
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeInOut,
              );
            }
          });
        }
      },
    );
  }

  /// Moves the viewer on to the next battle (wraps to the first one).
  void _goToNextBattle() {
    if (!mounted) return;
    if (_feed.length < 2) {
      _goBack();
      return;
    }
    _pageController.animateToPage(
      (_currentPage + 1) % _feed.length,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
    );
  }

  void _goBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const PkHomeScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131766),
      resizeToAvoidBottomInset: false,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        // A streamer stays in their own battle; viewers can swipe between battles.
        physics: _isCreator
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        itemCount: _feed.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          final key = ValueKey('feed_${_feed[index].match.id}');
          final isActive = index == _currentPage;
          return _isCreator
              ? PkStreamerBattleView(
                  key: key,
                  feedItem: _feed[index],
                  isActive: isActive,
                  onBack: _goBack,
                  onExplorePk: _openExploreSheet,
                )
              : PkViewerBattleView(
                  key: key,
                  feedItem: _feed[index],
                  isActive: isActive,
                  onBack: _goBack,
                  onExplorePk: _openExploreSheet,
                  onNextBattle: _goToNextBattle,
                );
        },
      ),
    );
  }
}
