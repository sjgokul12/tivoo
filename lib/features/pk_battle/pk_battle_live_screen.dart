// PK battle live screen: vertical swipe scrolling feed, state, timers and layout.

import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_assets.dart';
import '../../core/services/reel_video_manager.dart';
import '../../core/utils/responsive.dart';
import '../../core/widgets/comment_action_sheet.dart';
import '../gift/gift.dart' as store;
import '../home/domain/models/live_stream_card_model.dart';
import '../home/presentation/widgets/live_tools_bottom_sheet.dart';
import '../home/presentation/widgets/streamer_id_profile_sheet.dart';
import '../live_stream/domain/models/gift_item.dart';
import '../live_stream/domain/models/live_comment.dart';
import '../live_stream/presentation/widgets/active_gift_animation_overlay.dart';
import '../live_stream/presentation/widgets/floating_hearts_overlay.dart';
import '../live_stream/presentation/widgets/live_stream_viewers_sheet.dart';
import '../live_stream/presentation/widgets/user_profile_bottom_sheet.dart';
import '../profile/presentation/controllers/follow_controller.dart';
import '../profile/presentation/widgets/instagram_follow_actions_sheet.dart';
import 'commands/pk_chat_controller.dart';
import 'commands/pk_command_section.dart';
import 'core/pk_common_widgets.dart';
import 'core/pk_feed_data.dart';
import 'core/pk_models.dart';
import 'core/pk_support.dart';
import 'gifts/pk_gift_panel.dart';
import 'lobby/pk_home_screen.dart';
import 'overlays/pk_winner_overlay.dart';
import 'sheets/pk_explore_sheet.dart';
import 'sheets/pk_match_flow.dart';
import 'sheets/pk_sheets.dart';
import 'stage/pk_score_bar.dart';
import 'stage/pk_stage.dart';
import 'stage/pk_top_gifters.dart';
import 'stage/pk_video_arena.dart';

/// Live PK battle feed with smooth vertical swipe scrolling like a live video feed.
/// Swiping up or down transitions to the next or previous mock PK battle with
/// distinct streamers, videos, avatars, scores, viewer counts, and comments.
class PkBattleLiveScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  /// The initial battle to show (defaults to Neha vs Arun).
  final PkMatch match;

  /// Whether the current user is host / creator of this battle.
  final bool isCreator;

  const PkBattleLiveScreen({super.key, this.onBack, this.match = PkDemoData.featured, this.isCreator = false});

  @override
  ConsumerState<PkBattleLiveScreen> createState() => _PkBattleLiveScreenState();
}

class _PkBattleLiveScreenState extends ConsumerState<PkBattleLiveScreen> {
  late final List<PkBattleFeedItem> _feed;
  late final PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
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
          _pageController.animateToPage(
            _feed.length - 1,
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeInOut,
          );
        }
      },
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
        physics: const _SmoothPagePhysics(),
        // Build the neighbouring battle ahead of time so it slides in without a hitch.
        allowImplicitScrolling: true,
        itemCount: _feed.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          return RepaintBoundary(
            child: _PkBattlePageView(
              key: ValueKey('feed_${_feed[index].match.id}'),
              feedItem: _feed[index],
              isActive: index == _currentPage,
              isCreator: widget.isCreator,
              onBack: _goBack,
              onExplorePk: _openExploreSheet,
            ),
          );
        },
      ),
    );
  }
}

/// Page snapping with a softer, nearly critically damped spring: pages glide into place
/// instead of snapping, and there's no overscroll bounce at the ends.
class _SmoothPagePhysics extends PageScrollPhysics {
  const _SmoothPagePhysics({super.parent = const ClampingScrollPhysics()});

  @override
  _SmoothPagePhysics applyTo(ScrollPhysics? ancestor) => _SmoothPagePhysics(parent: buildParent(ancestor));

  @override
  SpringDescription get spring => const SpringDescription(mass: 0.8, stiffness: 110, damping: 19);
}

/// Single interactive PK battle page inside the vertical feed.
class _PkBattlePageView extends ConsumerStatefulWidget {
  final PkBattleFeedItem feedItem;
  final bool isActive;
  final bool isCreator;
  final VoidCallback onBack;
  final VoidCallback onExplorePk;

  const _PkBattlePageView({
    super.key,
    required this.feedItem,
    required this.isActive,
    required this.isCreator,
    required this.onBack,
    required this.onExplorePk,
  });

  @override
  ConsumerState<_PkBattlePageView> createState() => _PkBattlePageViewState();
}

class _PkBattlePageViewState extends ConsumerState<_PkBattlePageView> {
  final GlobalKey<ActiveGiftAnimationOverlayState> _giftOverlayKey = GlobalKey();
  final GlobalKey<FloatingHeartsOverlayState> _floatingHeartsKey = GlobalKey();
  final GlobalKey _arenaKey = GlobalKey();

  late final ValueNotifier<int> _secondsRemaining;
  late PkHost _left;
  late PkHost _right;
  late int _leftScore;
  late int _rightScore;
  late PkGiftEvent _leftGift;
  late PkGiftEvent _rightGift;
  late final Map<String, PkGifter> _leftGifters;
  late final Map<String, PkGifter> _rightGifters;
  late final PkChatController _chat;

  PkSettings _settings = const PkSettings();

  /// The host this viewer supports: their comments are tinted and gifts go straight to them.
  bool _supportLeft = true;
  PkHost get _supported => _supportLeft ? _left : _right;
  bool _isBattleEnded = false;
  int _giftSeq = 0;
  bool _showVs = true;

  Timer? _countdownTimer;
  Timer? _commentTimer;
  Timer? _vsTimer;

  static const _vsDuration = Duration(seconds: 4);

  @override
  void initState() {
    super.initState();
    _left = widget.feedItem.match.left;
    _right = widget.feedItem.match.right;
    _leftScore = widget.feedItem.match.leftScore;
    _rightScore = widget.feedItem.match.rightScore;
    _leftGift = widget.feedItem.leftGift;
    _rightGift = widget.feedItem.rightGift;
    _secondsRemaining = ValueNotifier<int>(widget.feedItem.match.secondsLeft);
    _leftGifters = {for (final g in widget.feedItem.leftGifters) g.name: g};
    _rightGifters = {for (final g in widget.feedItem.rightGifters) g.name: g};
    _chat = PkChatController(
      hostName: _left.name,
      initialComments: widget.feedItem.initialComments,
      commentPool: widget.feedItem.commentPool,
    );

    if (widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ReelVideoManager.instance.pauseAll();
        _startCountdown();
        _flashVs();
        _startCommentTimer();
      });
    }
  }

  @override
  void didUpdateWidget(covariant _PkBattlePageView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        ReelVideoManager.instance.pauseAll();
        _startCountdown();
        _startCommentTimer();
        _flashVs();
      } else {
        _countdownTimer?.cancel();
        _commentTimer?.cancel();
        _vsTimer?.cancel();
      }
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _commentTimer?.cancel();
    _vsTimer?.cancel();
    _chat.dispose();
    _secondsRemaining.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secondsRemaining.value > 0) {
        _secondsRemaining.value--;
      } else if (!_isBattleEnded && _settings.autoEnd) {
        _endBattle();
      }
    });
  }

  void _startCommentTimer() {
    _commentTimer?.cancel();
    _commentTimer = Timer.periodic(const Duration(seconds: 3), (_) => _simulateAudienceComment());
  }

  void _flashVs() {
    _vsTimer?.cancel();
    if (!_showVs) setState(() => _showVs = true);
    _vsTimer = Timer(_vsDuration, () {
      if (mounted) setState(() => _showVs = false);
    });
  }

  void _endBattle() {
    _countdownTimer?.cancel();
    _giftOverlayKey.currentState?.clear();
    setState(() => _isBattleEnded = true);
  }

  void _restartBattle({PkHost? opponent}) {
    setState(() {
      if (opponent != null) _right = opponent;
      _leftScore = 0;
      _rightScore = 0;
      _isBattleEnded = false;
      _secondsRemaining.value = _settings.durationSeconds;
    });
    _startCountdown();
    _flashVs();
  }

  void _simulateAudienceComment() {
    if (!mounted || _isBattleEnded || !widget.isActive) return;
    final c = _chat.addAudienceComment();
    if (c == null) return;
    setState(() {
      final pill = PkGiftEvent.fromChatMessage(id: _giftSeq, sender: c.name, avatar: c.avatar, message: c.message);
      if (pill != null) {
        final toLeft = _giftSeq.isEven;
        final stars = (PkDemoData.giftValues[pill.giftName] ?? 10) * pill.count;
        if (toLeft) {
          _leftScore += stars;
        } else {
          _rightScore += stars;
        }
        _showGiftPill(pill, toLeft: toLeft);
        _recordGift(c.name, c.avatar, stars, toLeft: toLeft);
      }
    });
  }

  void _handleHoldComment(LiveComment comment) {
    CommentActionSheet.show(
      context,
      comment: comment,
      onPause: () => _chat.pause(),
      onResume: () => _chat.resume(),
      onReported: () => _chat.reportComment(comment.id),
      onBlocked: () => _chat.blockUser(comment.userName),
    );
  }

  void _recordGift(String name, String avatar, int stars, {required bool toLeft}) {
    final gifters = toLeft ? _leftGifters : _rightGifters;
    gifters[name] = (gifters[name] ?? PkGifter(name: name, avatar: avatar, total: 0)).add(stars);
  }

  void _showGiftPill(PkGiftEvent pill, {required bool toLeft}) {
    _giftSeq++;
    toLeft ? _leftGift = pill : _rightGift = pill;
  }

  void _sendComment(String text) {
    _chat.add(userName: 'You', avatar: AppAssets.status5, message: text);
    _floatingHeartsKey.currentState
      ?..addHeart(toLeft: _supportLeft)
      ..addHeart(toLeft: _supportLeft);
  }

  /// Gifts always go to the supported host (no recipient picker).
  void _openGiftSheet() {
    final to = _supported.name;
    store.GiftBottomSheet.show(
      context,
      (gift) => _sendGift(_playable(gift), 1, to),
      recipients: [to],
      initialRecipient: to,
      onGiftWithRecipientSelected: (gift, quantity, _) => _sendGift(_playable(gift), quantity, to),
    );
  }

  void _support(bool isLeft) {
    if (_supportLeft == isLeft) return;
    HapticFeedback.selectionClick();
    setState(() => _supportLeft = isLeft);
  }

  /// Tapping the other host's video asks to switch support to them.
  Future<void> _onHostCardTap(bool isLeft) async {
    if (isLeft == _supportLeft) return;
    final host = isLeft ? _left : _right;
    final ok = await PkSwitchSupportDialog.show(context, host: host, color: pkSideColor(isLeft));
    if (ok == true && mounted) _support(isLeft);
  }

  static const _animatedGiftIds = {
    'Royal Crown': 'p3d_royal_crown',
    'Angel Vehicle': 'p3d_angel_vehicle',
    'Golden Horse': 'p3d_golden_horse',
    'Luxury Car': 'p3d_luxury_car',
    'Love Castle': 'p3d_love_castle',
    'Galaxy Rocket': 'p3d_galaxy_rocket',
    'Diamond Wings': 'p3d_diamond_wings',
  };

  GiftItem _playable(store.GiftItem gift) => GiftItem(
    id: _animatedGiftIds[gift.name] ?? gift.id,
    name: gift.name,
    icon: gift.icon,
    imageAssetPath: gift.imageAssetPath,
    diamonds: gift.diamonds,
  );

  void _sendGift(GiftItem gift, int quantity, String recipient) {
    final toLeft = recipient == _left.name;
    _chat.add(
      userName: 'You',
      avatar: AppAssets.status5,
      message: 'sent ${gift.name} ${gift.icon} x $quantity to $recipient',
      isGift: true,
    );
    setState(() {
      toLeft ? _leftScore += gift.diamonds * 15 * quantity : _rightScore += gift.diamonds * 15 * quantity;
      _showGiftPill(
        PkGiftEvent(
          id: _giftSeq,
          sender: 'You',
          senderAvatar: AppAssets.status5,
          giftName: gift.name,
          emoji: gift.icon,
          giftImage: gift.imageAssetPath,
          count: quantity,
        ),
        toLeft: toLeft,
      );
      _recordGift('You', AppAssets.status5, gift.diamonds * quantity, toLeft: toLeft);
    });

    final totalCost = gift.diamonds * quantity;
    void showDetails() {
      if (!mounted) return;
      store.GiftBalanceDetailsDialog.show(
        context: context,
        gift: gift,
        quantity: quantity,
        recipient: recipient,
        deductedStars: totalCost,
        onSendMore: _openGiftSheet,
      );
    }

    if (_giftOverlayKey.currentState != null) {
      _giftOverlayKey.currentState?.playGift(
        gift,
        senderName: 'You',
        count: quantity,
        toLeft: toLeft,
        recipient: recipient,
        target: _hostVideoPosition(toLeft),
        onComplete: showDetails,
      );
    } else {
      Future.delayed(const Duration(milliseconds: 1500), showDetails);
    }
    _floatingHeartsKey.currentState?.addHeart(toLeft: toLeft);
  }

  Offset? _hostVideoPosition(bool isLeft) {
    final box = _arenaKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset(box.size.width * (isLeft ? 0.25 : 0.75), box.size.height * 0.5));
  }

  void _handleFollowHost(bool isLeft) {
    final host = isLeft ? _left : _right;
    final hostId = 'host_${host.name.toLowerCase().replaceAll(' ', '_')}';
    final followMap = ref.read(followControllerProvider);
    final rel =
        followMap[hostId] ??
        ref
            .read(followControllerProvider.notifier)
            .getRelationship(
              hostId,
              defaultName: host.name,
              defaultAvatar: host.avatarAsset,
              initialFollowers: isLeft ? 120400 : 98700,
            );

    if (rel.isNotFollowing) {
      _support(isLeft); // following a host makes them the one you support
      ref
          .read(followControllerProvider.notifier)
          .sendFollowRequest(
            hostId,
            targetName: host.name,
            targetAvatar: host.avatarAsset,
            initialFollowers: isLeft ? 120400 : 98700,
            onStatusNotify: (msg) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(msg),
                  backgroundColor: const Color(0xFF192233),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          );
    } else if (rel.isRequested) {
      InstagramFollowActionsSheet.showRequestedSheet(
        context,
        relationship: rel,
        streamerId: hostId,
        onCancelRequest: () {
          ref
              .read(followControllerProvider.notifier)
              .cancelFollowRequest(
                hostId,
                onStatusNotify: (msg) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(msg),
                      backgroundColor: const Color(0xFF192233),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              );
        },
      );
    } else if (rel.isFollowingOrMutual) {
      InstagramFollowActionsSheet.show(context, relationship: rel, streamerId: hostId);
    } else if (rel.isBlocked) {
      ref
          .read(followControllerProvider.notifier)
          .unblockUser(
            hostId,
            onStatusNotify: (msg) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(msg),
                  backgroundColor: const Color(0xFF192233),
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          );
    }
  }

  void _openHostProfile(bool isLeft) {
    final host = isLeft ? _left : _right;
    final hostId = 'host_${host.name.toLowerCase().replaceAll(' ', '_')}';
    final followMap = ref.read(followControllerProvider);
    final rel =
        followMap[hostId] ??
        ref
            .read(followControllerProvider.notifier)
            .getRelationship(
              hostId,
              defaultName: host.name,
              defaultAvatar: host.avatarAsset,
              initialFollowers: isLeft ? 120400 : 98700,
            );

    final streamModel = LiveStreamCardModel(
      id: hostId,
      userId: host.name.toLowerCase().replaceAll(' ', '_'),
      streamerName: host.name,
      streamerBio: host.bio.isNotEmpty ? host.bio : '✨ Live Stream Host | PK Champion ✨',
      streamerAssetPath: host.avatarAsset,
      viewersCount: host.viewers,
      diamondsCount: '124.8K',
      category: 'PK Battle',
      isFollowing: rel.isFollowingOrMutual,
      videoAssetPath: host.videoAsset,
      isPk: true,
    );
    StreamerIdProfileSheet.show(context, stream: streamModel);
  }

  void _openUserProfile(String name, String? avatar) {
    final userId = 'user_${name.toLowerCase().replaceAll(' ', '_')}';
    UserProfileBottomSheet.show(
      context,
      userName: name,
      avatarAsset: avatar ?? AppAssets.status4,
      userId: userId,
      onSendGiftTap: _openGiftSheet,
    );
  }

  void _openPkSettings() {
    PkSheets.showSettings(
      context,
      current: _settings,
      onSave: (settings) {
        setState(() => _settings = settings);
        _secondsRemaining.value = settings.durationSeconds;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⏱️ PK Duration set to ${settings.durationSeconds ~/ 60} min!'),
            backgroundColor: const Color(0xFFFFD600),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  void _openMatchFlow() {
    PkMatchFlow(
      context: context,
      host: _left,
      onOpenSettings: _openPkSettings,
      onMatched: (rival) {
        _restartBattle(
          opponent: _right.copyWith(
            name: rival.name,
            avatarAsset: rival.avatarAsset,
            videoAsset: rival.videoAsset,
            likes: rival.viewers,
            viewers: rival.viewers,
          ),
        );
        PkSheets.showBanner(
          context,
          title: '⚔️ PK Live Started!',
          message: 'Compete, send gifts & enjoy the battle!',
          icon: Icons.flash_on_rounded,
          color: const Color(0xFFFFD600),
        );
      },
    ).start();
  }

  void _openLiveTools() {
    LiveToolsBottomSheet.show(
      context,
      onPkSettingsTap: _openPkSettings,
      onInviteTap: _openMatchFlow,
      onGuestsTap: _openMatchFlow,
      onRankingTap: () => PkSheets.showMoreOptions(context, onSettings: _openPkSettings, onPreviewWinner: _endBattle),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = context.viewInsets.bottom > 50;
    final usableHeight = context.screenHeight - context.padding.top - context.padding.bottom;
    final availableHeight = isKeyboardOpen ? (usableHeight - context.viewInsets.bottom) : usableHeight;
    final stageHeight = isKeyboardOpen
        ? (availableHeight * 0.28).clamp(90.0, 260.0)
        : (context.screenWidth * 1.05).clamp(availableHeight * 0.44, availableHeight * 0.53);
    final leftWins = _leftScore >= _rightScore;

    final leftId = 'host_${_left.name.toLowerCase().replaceAll(' ', '_')}';
    final rightId = 'host_${_right.name.toLowerCase().replaceAll(' ', '_')}';
    final followMap = ref.watch(followControllerProvider);
    final leftRel =
        followMap[leftId] ??
        ref
            .read(followControllerProvider.notifier)
            .getRelationship(
              leftId,
              defaultName: _left.name,
              defaultAvatar: _left.avatarAsset,
              initialFollowers: 120400,
            );
    final rightRel =
        followMap[rightId] ??
        ref
            .read(followControllerProvider.notifier)
            .getRelationship(
              rightId,
              defaultName: _right.name,
              defaultAvatar: _right.avatarAsset,
              initialFollowers: 98700,
            );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ActiveGiftAnimationOverlay(
        key: _giftOverlayKey,
        isSuppressed: _isBattleEnded,
        showTopBanner: false,
        child: FloatingHeartsOverlay(
          key: _floatingHeartsKey,
          alignLeft: true,
          child: Stack(
            children: [
              const Positioned.fill(child: PkBackdrop()),
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    const SizedBox(height: 2),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutQuad,
                      height: stageHeight,
                      child: PkStage(
                        showHeader: !isKeyboardOpen,
                        onBack: widget.onBack,
                        onEmblemTap: () => PkSheets.showRules(context),
                        onExplorePk: widget.onExplorePk,
                        left: _left,
                        right: _right,
                        isFollowingLeft: leftRel.isFollowingOrMutual,
                        isFollowingRight: rightRel.isFollowingOrMutual,
                        isRequestedLeft: leftRel.isRequested,
                        isRequestedRight: rightRel.isRequested,
                        leftScore: _leftScore,
                        rightScore: _rightScore,
                        onFollowTap: _handleFollowHost,
                        onHostTap: _openHostProfile,
                        arena: LayoutBuilder(
                          builder: (context, constraints) => PkVideoArena(
                            key: _arenaKey,
                            left: _left,
                            right: _right,
                            leftGift: _leftGift,
                            rightGift: _rightGift,
                            showVs: _showVs,
                            isPlaying: widget.isActive,
                            supportLeft: _supportLeft,
                            onCardTap: _onHostCardTap,
                            onViewersTap: () => LiveStreamViewersSheet.show(context),
                            timer: ValueListenableBuilder<int>(
                              valueListenable: _secondsRemaining,
                              builder: (context, seconds, _) {
                                final m = (seconds ~/ 60).toString().padLeft(2, '0');
                                final s = (seconds % 60).toString().padLeft(2, '0');
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                      decoration: BoxDecoration(
                                        color: const Color(0x990A0D28),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 0.9),
                                        boxShadow: const [
                                          BoxShadow(color: Color(0x66000000), blurRadius: 8, offset: Offset(0, 2)),
                                        ],
                                      ),
                                      child: Text(
                                        '$m:$s',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    PkScoreBar(leftScore: _leftScore, rightScore: _rightScore),
                    if (!isKeyboardOpen) const SizedBox(height: 2),
                    if (!isKeyboardOpen)
                      PkTopGiftersRow(
                        left: _leftGifters.values.toList(),
                        right: _rightGifters.values.toList(),
                        onGifterTap: (g) => _openUserProfile(g.name, g.avatar),
                      ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: PkLowerSection(
                        commandList: ListenableBuilder(
                          listenable: _chat,
                          builder: (context, _) => PkCommandList(
                            comments: _chat.comments,
                            controller: _chat.scroll,
                            onUserTap: (comment) => _openUserProfile(comment.userName, comment.userAssetPath),
                            onUserLongPress: _handleHoldComment,
                          ),
                        ),
                        rightColumn: PkRightColumn(onGift: _openGiftSheet),
                        inputBar: PkInputBar(
                          accent: pkSideColor(_supportLeft),
                          hint: 'Cheer for ${pkShortName(_supported.name)}…',
                          onSend: _sendComment,
                          onEmojiTap: () => PkSheets.showMessageInput(context, onSend: _sendComment),
                          onShareTap: () => PkSheets.showShare(context),
                          onMoreTap: _openLiveTools,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isBattleEnded)
                PkWinnerOverlay(
                  winner: leftWins ? _left : _right,
                  loser: leftWins ? _right : _left,
                  isLeftWinner: leftWins,
                  winnerScore: leftWins ? _leftScore : _rightScore,
                  loserScore: leftWins ? _rightScore : _leftScore,
                  onPlayAgain: _restartBattle,
                  onSkip: widget.onBack,
                  onBackToLive: widget.onBack,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
