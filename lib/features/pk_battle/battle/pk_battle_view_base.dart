// Shared PK battle page: state, timers, gifts, chat and the responsive layout.
// The viewer (viewer/) and streamer (streamer/) screens extend this and only
// add what differs: the end-of-battle flow and the "More" menu.

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/services/reel_video_manager.dart';
import '../../../core/widgets/comment_action_sheet.dart';
import '../../gift/gift.dart' as store;
import '../../home/domain/models/live_stream_card_model.dart';
import '../../home/presentation/widgets/streamer_id_profile_sheet.dart';
import '../../live_stream/domain/models/gift_item.dart';
import '../../live_stream/domain/models/live_comment.dart';
import '../../live_stream/presentation/widgets/active_gift_animation_overlay.dart';
import '../../live_stream/presentation/widgets/floating_hearts_overlay.dart';
import '../../live_stream/presentation/widgets/live_stream_viewers_sheet.dart';
import '../../live_stream/presentation/widgets/user_profile_bottom_sheet.dart';
import '../../profile/presentation/controllers/follow_controller.dart';
import '../../profile/presentation/widgets/instagram_follow_actions_sheet.dart';
import '../commands/pk_chat_controller.dart';
import '../commands/pk_command_section.dart';
import '../core/pk_common_widgets.dart';
import '../core/pk_feed_data.dart';
import '../core/pk_models.dart';
import '../core/pk_responsive.dart';
import '../gifts/pk_gift_panel.dart';
import '../overlays/pk_boxer_intro.dart';
import '../sheets/pk_sheets.dart';
import '../stage/pk_score_bar.dart';
import '../stage/pk_stage.dart';
import '../stage/pk_top_gifters.dart';
import '../stage/pk_video_arena.dart';

/// One PK battle page inside the vertical feed.
abstract class PkBattleView extends ConsumerStatefulWidget {
  final PkBattleFeedItem feedItem;
  final bool isActive;
  final VoidCallback onBack;
  final VoidCallback onExplorePk;

  /// Scrolls the feed on to the next battle.
  final VoidCallback? onNextBattle;

  const PkBattleView({
    super.key,
    required this.feedItem,
    required this.isActive,
    required this.onBack,
    required this.onExplorePk,
    this.onNextBattle,
  });
}

abstract class PkBattleViewState<T extends PkBattleView> extends ConsumerState<T> {
  final GlobalKey<ActiveGiftAnimationOverlayState> _giftOverlayKey = GlobalKey();
  final GlobalKey<FloatingHeartsOverlayState> _floatingHeartsKey = GlobalKey();
  final GlobalKey _arenaKey = GlobalKey();

  // Owned here (not by the input bar) so typing survives layout changes
  // when the keyboard opens.
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocus = FocusNode();

  late final ValueNotifier<int> secondsRemaining;
  late PkHost left;
  late PkHost right;
  late int leftScore;
  late int rightScore;
  late PkGiftEvent leftGift;
  late PkGiftEvent rightGift;
  late final Map<String, PkGifter> leftGifters;
  late final Map<String, PkGifter> rightGifters;
  late final PkChatController chat;

  late final int initialLeftScore;
  late final int initialRightScore;

  PkSettings settings = const PkSettings();
  bool isBattleEnded = false;

  /// Boxer intro shown before a restarted battle (Rewatch / Rebattle).
  String? introTitle;
  bool get isShowingIntro => introTitle != null;

  /// Battle round on this page; every rebattle adds one (no limit).
  int round = 1;

  /// Gifts the viewer sent and stars they spent in the current battle.
  int sessionGiftsCount = 0;
  int sessionStarsSpent = 0;

  int _giftSeq = 0;
  bool _showVs = true;

  Timer? _countdownTimer;
  Timer? _commentTimer;
  Timer? _scorePulseTimer;
  Timer? _vsTimer;
  final _random = Random();

  static const _vsDuration = Duration(seconds: 4);

  String get matchId => widget.feedItem.match.id;

  // ---------------------------------------------------------------------------
  // Role-specific hooks
  // ---------------------------------------------------------------------------

  /// Popup shown over the stage once the timer runs out.
  Widget buildEndOverlay(BuildContext context);

  /// The "More" (…) button next to the comment box.
  void openMoreOptions();

  /// Tap on the opponent's (right) video.
  void onRightVideoTap() {}

  /// Called once when the countdown reaches zero.
  void onBattleEnded() {}

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    final match = widget.feedItem.match;
    left = match.left;
    right = match.right;

    // Distinct starting scores for each battle so no battles look static
    final itemIndex = match.secondsLeft % 7;
    initialLeftScore = match.leftScore > 0 ? match.leftScore : (2450 + (itemIndex * 680));
    initialRightScore = match.rightScore > 0 ? match.rightScore : (1980 + (itemIndex * 820));
    leftScore = initialLeftScore;
    rightScore = initialRightScore;

    leftGift = widget.feedItem.leftGift;
    rightGift = widget.feedItem.rightGift;
    secondsRemaining = ValueNotifier<int>(match.secondsLeft);
    leftGifters = {for (final g in widget.feedItem.leftGifters) g.name: g};
    rightGifters = {for (final g in widget.feedItem.rightGifters) g.name: g};
    chat = PkChatController(
      hostName: left.name,
      initialComments: widget.feedItem.initialComments,
      commentPool: widget.feedItem.commentPool,
    );

    if (widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ReelVideoManager.instance.pauseAll();
        _startBattleTimers();
      });
    }
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive == oldWidget.isActive) return;
    if (widget.isActive) {
      ReelVideoManager.instance.pauseAll();
      if (!isShowingIntro) _startBattleTimers();
    } else {
      _stopBattleTimers();
      _inputFocus.unfocus();
    }
  }

  @override
  void dispose() {
    _stopBattleTimers();
    chat.dispose();
    secondsRemaining.dispose();
    _inputController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Battle flow
  // ---------------------------------------------------------------------------

  void _startBattleTimers() {
    _startCountdown();
    _startScoreSimulation();
    _startCommentTimer();
    _flashVs();
  }

  void _stopBattleTimers() {
    _countdownTimer?.cancel();
    _scorePulseTimer?.cancel();
    _commentTimer?.cancel();
    _vsTimer?.cancel();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isBattleEnded) return;
      if (secondsRemaining.value > 0) secondsRemaining.value--;
      if (secondsRemaining.value == 0) endBattle();
    });
  }

  /// Actively simulates dynamic battle star fluctuations (increases & counter-surges)
  /// so stars count bar is alive and clashing in every battle on the UI.
  void _startScoreSimulation() {
    _scorePulseTimer?.cancel();
    _scorePulseTimer = Timer.periodic(const Duration(milliseconds: 2200), (_) {
      if (!mounted || isBattleEnded || !widget.isActive) return;
      setState(() {
        final randVal = _random.nextInt(100);
        final starAmounts = [20, 35, 60, 110, 180, 320, 550];
        final stars = starAmounts[_random.nextInt(starAmounts.length)];

        if (randVal < 48) {
          leftScore += stars;
          final supporters = ['Rohit Sharma', 'Pooja Hegde', 'Vijay Sethupathi', 'Ananya Panday'];
          final name = supporters[_random.nextInt(supporters.length)];
          _recordGift(name, AppAssets.status1, stars, toLeft: true);
        } else if (randVal < 92) {
          rightScore += stars;
          final supporters = ['Suresh Raina', 'Kiara Advani', 'Dulquer Salmaan', 'Samantha Ruth'];
          final name = supporters[_random.nextInt(supporters.length)];
          _recordGift(name, AppAssets.status2, stars, toLeft: false);
        } else {
          // Surge clash: both sides gain points with tension
          leftScore += (stars * 0.85).round();
          rightScore += stars;
        }
      });
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

  void endBattle() {
    if (isBattleEnded) return;
    _countdownTimer?.cancel();
    _scorePulseTimer?.cancel();
    _giftOverlayKey.currentState?.clear();
    _inputFocus.unfocus();
    setState(() => isBattleEnded = true);
    onBattleEnded();
  }

  /// Resets the battle and plays the boxer intro; the countdown starts when
  /// the intro finishes.
  void restartBattle({
    required String title,
    required int seconds,
    PkHost? opponent,
    int leftStartScore = 0,
    int rightStartScore = 0,
  }) {
    _stopBattleTimers();
    _giftOverlayKey.currentState?.clear();
    setState(() {
      if (opponent != null) right = opponent;
      leftScore = leftStartScore;
      rightScore = rightStartScore;
      isBattleEnded = false;
      introTitle = title;
      round++;
      secondsRemaining.value = seconds;
      sessionGiftsCount = 0;
      sessionStarsSpent = 0;
    });
  }

  void _onIntroFinished() {
    if (!mounted) return;
    setState(() => introTitle = null);
    if (widget.isActive) _startBattleTimers();
  }

  // ---------------------------------------------------------------------------
  // Chat & gifts
  // ---------------------------------------------------------------------------

  void _simulateAudienceComment() {
    if (!mounted || isBattleEnded || !widget.isActive) return;
    final c = chat.addAudienceComment();
    if (c == null) return;
    setState(() {
      final pill = PkGiftEvent.fromChatMessage(id: _giftSeq, sender: c.name, avatar: c.avatar, message: c.message);
      if (pill != null) {
        final toLeft = _giftSeq.isEven;
        final stars = (PkDemoData.giftValues[pill.giftName] ?? 10) * pill.count;
        if (toLeft) {
          leftScore += stars;
        } else {
          rightScore += stars;
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
      onPause: () => chat.pause(),
      onResume: () => chat.resume(),
      onReported: () => chat.reportComment(comment.id),
      onBlocked: () => chat.blockUser(comment.userName),
    );
  }

  void _recordGift(String name, String avatar, int stars, {required bool toLeft}) {
    final gifters = toLeft ? leftGifters : rightGifters;
    gifters[name] = (gifters[name] ?? PkGifter(name: name, avatar: avatar, total: 0)).add(stars);
  }

  void _showGiftPill(PkGiftEvent pill, {required bool toLeft}) {
    _giftSeq++;
    toLeft ? leftGift = pill : rightGift = pill;
  }

  void _sendComment(String text) {
    chat.add(userName: 'You', avatar: AppAssets.status5, message: text);
    _floatingHeartsKey.currentState
      ?..addHeart(toLeft: true)
      ..addHeart(toLeft: true);
  }

  void openGiftSheet() {
    store.GiftBottomSheet.show(
      context,
      (gift) => _sendGift(_playable(gift), 1, left.name),
      recipients: [left.name, right.name],
      initialRecipient: left.name,
      onGiftWithQuantitySelected: (gift, quantity) => _sendGift(_playable(gift), quantity, left.name),
      onGiftWithRecipientSelected: (gift, quantity, recipient) => _sendGift(_playable(gift), quantity, recipient),
    );
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
    if (isBattleEnded) return;
    final toLeft = recipient == left.name;
    chat.add(
      userName: 'You',
      avatar: AppAssets.status5,
      message: 'sent ${gift.name} ${gift.icon} x $quantity to $recipient',
      isGift: true,
    );
    setState(() {
      toLeft ? leftScore += gift.diamonds * 15 * quantity : rightScore += gift.diamonds * 15 * quantity;
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

    sessionGiftsCount += quantity;
    sessionStarsSpent += gift.diamonds * quantity;

    _giftOverlayKey.currentState?.playGift(
      gift,
      senderName: 'You',
      count: quantity,
      toLeft: toLeft,
      recipient: recipient,
      target: _hostVideoPosition(toLeft),
    );
    _floatingHeartsKey.currentState?.addHeart(toLeft: toLeft);
  }

  Offset? _hostVideoPosition(bool isLeft) {
    final box = _arenaKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset(box.size.width * (isLeft ? 0.25 : 0.75), box.size.height * 0.5));
  }

  // ---------------------------------------------------------------------------
  // Profiles & follow
  // ---------------------------------------------------------------------------

  String hostIdFor(PkHost host) => 'host_${host.name.toLowerCase().replaceAll(' ', '_')}';

  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF192233),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleFollowHost(bool isLeft) {
    final host = isLeft ? left : right;
    final hostId = hostIdFor(host);
    final followers = ref.read(followControllerProvider.notifier);
    final rel =
        ref.read(followControllerProvider)[hostId] ??
        followers.getRelationship(
          hostId,
          defaultName: host.name,
          defaultAvatar: host.avatarAsset,
          initialFollowers: isLeft ? 120400 : 98700,
        );

    if (rel.isNotFollowing) {
      followers.sendFollowRequest(
        hostId,
        targetName: host.name,
        targetAvatar: host.avatarAsset,
        initialFollowers: isLeft ? 120400 : 98700,
        onStatusNotify: showSnack,
      );
    } else if (rel.isRequested) {
      InstagramFollowActionsSheet.showRequestedSheet(
        context,
        relationship: rel,
        streamerId: hostId,
        onCancelRequest: () => followers.cancelFollowRequest(hostId, onStatusNotify: showSnack),
      );
    } else if (rel.isFollowingOrMutual) {
      InstagramFollowActionsSheet.show(context, relationship: rel, streamerId: hostId);
    } else if (rel.isBlocked) {
      followers.unblockUser(hostId, onStatusNotify: showSnack);
    }
  }

  void _openHostProfile(bool isLeft) {
    final host = isLeft ? left : right;
    final hostId = hostIdFor(host);
    final rel =
        ref.read(followControllerProvider)[hostId] ??
        ref
            .read(followControllerProvider.notifier)
            .getRelationship(
              hostId,
              defaultName: host.name,
              defaultAvatar: host.avatarAsset,
              initialFollowers: isLeft ? 120400 : 98700,
            );

    StreamerIdProfileSheet.show(
      context,
      stream: LiveStreamCardModel(
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
      ),
    );
  }

  void _openUserProfile(String name, String? avatar) {
    UserProfileBottomSheet.show(
      context,
      userName: name,
      avatarAsset: avatar ?? AppAssets.status4,
      userId: 'user_${name.toLowerCase().replaceAll(' ', '_')}',
      onSendGiftTap: openGiftSheet,
    );
  }

  // ---------------------------------------------------------------------------
  // Layout
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // On tablets / desktop web keep the phone layout centred instead of
    // stretching it; children see the narrowed width through MediaQuery.
    final mq = MediaQuery.of(context);
    final contentWidth = min(mq.size.width, PkResponsive.maxContentWidth);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ColoredBox(
        color: const Color(0xFF0A0A3E),
        child: Center(
          child: SizedBox(
            width: contentWidth,
            child: MediaQuery(
              data: mq.copyWith(size: Size(contentWidth, mq.size.height)),
              child: Builder(builder: _buildBattle),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBattle(BuildContext context) {
    final r = PkResponsive.of(context);
    final usableHeight = r.height - r.padding.top - r.padding.bottom;

    // Responsive stage height: full cinematic height when the keyboard is closed.
    final double maxStageRatio = r.height < 680 ? 0.46 : (r.height < 760 ? 0.52 : 0.56);
    final double minStageRatio = r.height < 680 ? 0.42 : 0.46;
    final double normalStageHeight = (r.width * 1.15).clamp(usableHeight * minStageRatio, usableHeight * maxStageRatio);

    // While typing, shrink the stage so the score bar and input stay above the keyboard.
    final double scoreBarH = (r.width * 0.08).clamp(30.0, 36.0);
    final double bottomControlsHeight = scoreBarH + 58.0;
    final double availableAboveKeyboard = usableHeight - r.keyboardInset;
    final double stageHeight = r.isKeyboardOpen
        ? (availableAboveKeyboard - bottomControlsHeight).clamp(160.0, normalStageHeight)
        : normalStageHeight;

    final followMap = ref.watch(followControllerProvider);
    final followers = ref.read(followControllerProvider.notifier);
    final leftId = hostIdFor(left);
    final rightId = hostIdFor(right);
    final leftRel =
        followMap[leftId] ??
        followers.getRelationship(
          leftId,
          defaultName: left.name,
          defaultAvatar: left.avatarAsset,
          initialFollowers: 120400,
        );
    final rightRel =
        followMap[rightId] ??
        followers.getRelationship(
          rightId,
          defaultName: right.name,
          defaultAvatar: right.avatarAsset,
          initialFollowers: 98700,
        );

    return ActiveGiftAnimationOverlay(
      key: _giftOverlayKey,
      isSuppressed: isBattleEnded || isShowingIntro,
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
                      showHeader: !r.isKeyboardOpen,
                      onBack: widget.onBack,
                      onEmblemTap: () => PkSheets.showRules(context),
                      onExplorePk: widget.onExplorePk,
                      left: left,
                      right: right,
                      isFollowingLeft: leftRel.isFollowingOrMutual,
                      isFollowingRight: rightRel.isFollowingOrMutual,
                      isRequestedLeft: leftRel.isRequested,
                      isRequestedRight: rightRel.isRequested,
                      leftScore: leftScore,
                      rightScore: rightScore,
                      onFollowTap: _handleFollowHost,
                      onHostTap: _openHostProfile,
                      arena: PkVideoArena(
                        key: _arenaKey,
                        left: left,
                        right: right,
                        leftGift: leftGift,
                        rightGift: rightGift,
                        showVs: _showVs,
                        isPlaying: widget.isActive,
                        onViewersTap: () => LiveStreamViewersSheet.show(context),
                        onRightVideoTap: onRightVideoTap,
                        timer: _CountdownChip(seconds: secondsRemaining),
                      ),
                    ),
                  ),
                  PkScoreBar(leftScore: leftScore, rightScore: rightScore),
                  if (!r.isKeyboardOpen) const SizedBox(height: 2),
                  if (!r.isKeyboardOpen)
                    PkTopGiftersRow(
                      left: leftGifters.values.toList(),
                      right: rightGifters.values.toList(),
                      onGifterTap: (g) => _openUserProfile(g.name, g.avatar),
                    ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: PkLowerSection(
                      commandList: ListenableBuilder(
                        listenable: chat,
                        builder: (context, _) => PkCommandList(
                          comments: chat.comments,
                          controller: chat.scroll,
                          onUserTap: (comment) => _openUserProfile(comment.userName, comment.userAssetPath),
                          onUserLongPress: _handleHoldComment,
                        ),
                      ),
                      rightColumn: PkRightColumn(onGift: openGiftSheet),
                      inputBar: PkInputBar(
                        controller: _inputController,
                        focusNode: _inputFocus,
                        onSend: _sendComment,
                        onEmojiTap: () => PkSheets.showMessageInput(context, onSend: _sendComment),
                        onShareTap: () => PkSheets.showShare(context, hostName: left.name, rivalName: right.name),
                        onMoreTap: openMoreOptions,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isBattleEnded) Positioned.fill(child: buildEndOverlay(context)),
            if (isShowingIntro)
              Positioned.fill(
                child: PkBoxerIntro(
                  key: ValueKey('intro_$round'),
                  title: introTitle!,
                  leftName: left.name,
                  rightName: right.name,
                  round: round,
                  onFinished: _onIntroFinished,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// mm:ss chip in the middle of the arena.
class _CountdownChip extends StatelessWidget {
  final ValueListenable<int> seconds;
  const _CountdownChip({required this.seconds});

  @override
  Widget build(BuildContext context) {
    final r = PkResponsive.of(context);
    return ValueListenableBuilder<int>(
      valueListenable: seconds,
      builder: (context, value, _) {
        final m = (value ~/ 60).toString().padLeft(2, '0');
        final s = (value % 60).toString().padLeft(2, '0');
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
                boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: Text(
                '$m:$s',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: r.s(11).clamp(10.0, 13.0),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
