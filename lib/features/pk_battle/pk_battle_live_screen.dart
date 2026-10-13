// PK battle live screen: state, timers and layout.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_assets.dart';
import '../../core/services/reel_video_manager.dart';
import '../home/presentation/widgets/live_tools_bottom_sheet.dart';
import '../live_stream/domain/models/gift_item.dart';
import '../live_stream/presentation/widgets/active_gift_animation_overlay.dart';
import '../live_stream/presentation/widgets/floating_hearts_overlay.dart';
import '../live_stream/presentation/widgets/live_stream_viewers_sheet.dart';
import '../live_stream/presentation/widgets/viewer_profile_screen.dart';
import '../gift/gift.dart' as store;
import 'commands/pk_chat_controller.dart';
import 'commands/pk_command_section.dart';
import 'core/pk_models.dart';
import 'core/pk_theme.dart';
import 'gifts/pk_gift_panel.dart';
import 'gifts/pk_hearts_lane.dart';
import 'overlays/pk_winner_overlay.dart';
import 'sheets/pk_match_flow.dart';
import 'sheets/pk_sheets.dart';
import 'stage/pk_header.dart';
import 'stage/pk_score_bar.dart';
import 'stage/pk_team_row.dart';
import 'stage/pk_video_arena.dart';

/// Live PK battle between two hosts: split video, clash score bar, command section
/// (live chat), gifting and rising hearts. Each UI section lives in its own folder.
class PkBattleLiveScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const PkBattleLiveScreen({super.key, this.onBack});

  @override
  State<PkBattleLiveScreen> createState() => _PkBattleLiveScreenState();
}

class _PkBattleLiveScreenState extends State<PkBattleLiveScreen> {
  final GlobalKey<ActiveGiftAnimationOverlayState> _giftOverlayKey = GlobalKey();
  final GlobalKey<FloatingHeartsOverlayState> _floatingHeartsKey = GlobalKey();
  final GlobalKey<PkHeartsLaneState> _heartsLaneKey = GlobalKey();
  final GlobalKey _headerKey = GlobalKey();
  final ValueNotifier<int> _secondsRemaining = ValueNotifier<int>(106); // 01:46

  final PkHost _left = PkDemoData.leftHost;
  PkHost _right = PkDemoData.rightHost;
  int _leftScore = 7556900;
  int _rightScore = 483400;
  PkSettings _settings = const PkSettings();
  bool _isBattleEnded = false;
  bool _isFollowingLeft = false;
  bool _isFollowingRight = false;
  PkGiftEvent _leftGift = PkDemoData.leftGift;
  PkGiftEvent _rightGift = PkDemoData.rightGift;
  int _giftSeq = 0;

  late final PkChatController _chat = PkChatController(hostName: _left.name);
  Timer? _countdownTimer;
  Timer? _commentTimer;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Free hardware decoders used by the feed so the two PK streams play smoothly.
      ReelVideoManager.instance.pauseAll();
      _startCountdown();
      _commentTimer = Timer.periodic(const Duration(seconds: 3), (_) => _simulateAudienceComment());
    });
  }

  @override
  void dispose() {
    ReelVideoManager.instance.pauseAll();
    _countdownTimer?.cancel();
    _commentTimer?.cancel();
    _chat.dispose();
    _secondsRemaining.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Battle state
  // ---------------------------------------------------------------------------

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

  void _endBattle() {
    _countdownTimer?.cancel();
    _giftOverlayKey.currentState?.clear();
    setState(() => _isBattleEnded = true);
  }

  /// Starts a fresh round, optionally against a new opponent.
  void _restartBattle({PkHost? opponent}) {
    setState(() {
      if (opponent != null) _right = opponent;
      _leftScore = 12340;
      _rightScore = 9870;
      _isBattleEnded = false;
      _secondsRemaining.value = _settings.durationSeconds;
    });
    _startCountdown();
  }

  void _addScore({required bool toLeft, required int points}) {
    setState(() => toLeft ? _leftScore += points : _rightScore += points);
  }

  void _goBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  // ---------------------------------------------------------------------------
  // Chat
  // ---------------------------------------------------------------------------

  void _simulateAudienceComment() {
    if (!mounted || _isBattleEnded) return;
    final c = _chat.addAudienceComment();
    setState(() {
      _leftScore += c.isGift ? 120 : 35;
      _rightScore += c.isGift ? 90 : 25;
      // Audience gifts show as a pill on the video (alternating hosts); full animations
      // play only when the user sends a gift.
      final pill = PkGiftEvent.fromChatMessage(id: _giftSeq, sender: c.name, avatar: c.avatar, message: c.message);
      if (pill != null) _showGiftPill(pill, toLeft: _giftSeq.isEven);
    });
  }

  void _showGiftPill(PkGiftEvent pill, {required bool toLeft}) {
    _giftSeq++;
    toLeft ? _leftGift = pill : _rightGift = pill;
  }

  void _sendComment(String text) {
    _chat.add(userName: 'You', avatar: AppAssets.status5, message: text);
    _addScore(toLeft: true, points: 25);
    _floatingHeartsKey.currentState
      ?..addHeart(toLeft: true)
      ..addHeart(toLeft: true);
  }

  // ---------------------------------------------------------------------------
  // Gifts & likes
  // ---------------------------------------------------------------------------

  void _openGiftSheet() {
    store.GiftBottomSheet.show(
      context,
      (gift) => _sendGift(_playable(gift), 1, _left.name),
      recipients: [_left.name, _right.name],
      initialRecipient: _left.name,
      onGiftWithQuantitySelected: (gift, quantity) => _sendGift(_playable(gift), quantity, _left.name),
      onGiftWithRecipientSelected: (gift, quantity, recipient) => _sendGift(_playable(gift), quantity, recipient),
    );
  }

  /// Gifts that have a dedicated 3D animation (flapping wings, rocket flight, ...).
  static const _animatedGiftIds = {
    'Royal Crown': 'p3d_royal_crown',
    'Angel Vehicle': 'p3d_angel_vehicle',
    'Golden Horse': 'p3d_golden_horse',
    'Luxury Car': 'p3d_luxury_car',
    'Love Castle': 'p3d_love_castle',
    'Galaxy Rocket': 'p3d_galaxy_rocket',
    'Diamond Wings': 'p3d_diamond_wings',
  };

  /// Gift store item → the animation overlay's gift model (store artwork, 3D animation).
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
      final points = gift.diamonds * 15 * quantity; // PKBattleGiftData.calculatePkPoints
      toLeft ? _leftScore += points : _rightScore += points;
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
    });
    _giftOverlayKey.currentState?.playGift(
      gift,
      senderName: 'You',
      count: quantity,
      toLeft: toLeft,
      recipient: recipient,
      target: _hostAvatarPosition(toLeft),
    );
    // Hearts fly on the side of the host that received the gift.
    _floatingHeartsKey.currentState?.addHeart(toLeft: toLeft);
  }

  /// Screen position of a host's profile photo in the header (where gifts fly to).
  Offset? _hostAvatarPosition(bool isLeft) {
    final box = _headerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(PkHeader.avatarCenter(isLeft: isLeft, width: box.size.width));
  }

  /// Double-tap on a stream likes that host.
  void _onArenaDoubleTap(TapDownDetails details, double width) {
    final toLeft = details.localPosition.dx < width / 2;
    _addScore(toLeft: toLeft, points: 50);
    _floatingHeartsKey.currentState?.addHeart(toLeft: toLeft);
    if (toLeft) _heartsLaneKey.currentState?.spawn(speed: 1.2);
  }

  /// Heart button / Like tile: burst of rising hearts and a small score boost.
  void _onLike() {
    _heartsLaneKey.currentState?.burst();
    _addScore(toLeft: true, points: 20);
    _floatingHeartsKey.currentState?.addHeart(toLeft: true);
  }

  // ---------------------------------------------------------------------------
  // Header actions
  // ---------------------------------------------------------------------------

  void _toggleFollow(bool isLeft) {
    setState(() => isLeft ? _isFollowingLeft = !_isFollowingLeft : _isFollowingRight = !_isFollowingRight);
    final host = isLeft ? _left : _right;
    final following = isLeft ? _isFollowingLeft : _isFollowingRight;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(following ? 'Now following ${host.name} ${isLeft ? '❤️' : '💙'}' : 'Unfollowed ${host.name}'),
        duration: const Duration(seconds: 1),
        backgroundColor: PkColors.side(isLeft),
      ),
    );
  }

  void _openHostProfile(bool isLeft) {
    final host = isLeft ? _left : _right;
    ViewerProfileScreen.open(
      context,
      userName: host.name,
      avatarAsset: host.avatarAsset,
      handle: host.handle.isEmpty ? null : host.handle,
      bio: host.bio.isEmpty ? null : host.bio,
      followersCount: host.likes,
    );
  }

  // ---------------------------------------------------------------------------
  // Sheets
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Size the video from the height left after the status / navigation bars.
    final padding = MediaQuery.paddingOf(context);
    final usableHeight = MediaQuery.sizeOf(context).height - padding.top - padding.bottom;
    final videoHeight = (usableHeight * 0.36).clamp(220.0, 400.0);
    final leftWins = _leftScore >= _rightScore;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: ActiveGiftAnimationOverlay(
        key: _giftOverlayKey,
        isSuppressed: _isBattleEnded,
        showTopBanner: false,
        child: FloatingHeartsOverlay(
          key: _floatingHeartsKey,
          alignLeft: true,
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: PkColors.background,
            body: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [PkColors.backgroundTop, PkColors.background],
                ),
              ),
              child: Stack(
                children: [
                  SafeArea(
                    bottom: false,
                    child: Column(
                      children: [
                        PkHeader(
                          key: _headerKey,
                          isFollowingLeft: _isFollowingLeft,
                          isFollowingRight: _isFollowingRight,
                          onBack: _goBack,
                          onEmblemTap: _openMatchFlow,
                          onFollowTap: _toggleFollow,
                          onHostTap: _openHostProfile,
                        ),
                        PkTeamRow(
                          left: _left,
                          right: _right,
                          secondsRemaining: _secondsRemaining,
                          showCountdown: _settings.countdownDisplay && _settings.showTimerToAudience,
                          onTeamTap: () => LiveStreamViewersSheet.show(context),
                          onTimerTap: _openPkSettings,
                        ),
                        SizedBox(
                          height: videoHeight,
                          child: LayoutBuilder(
                            builder: (context, constraints) => GestureDetector(
                              onDoubleTapDown: (d) => _onArenaDoubleTap(d, constraints.maxWidth),
                              child: PkVideoArena(
                                left: _left,
                                right: _right,
                                leftGift: _leftGift,
                                rightGift: _rightGift,
                              ),
                            ),
                          ),
                        ),
                        PkScoreBar(leftScore: _leftScore, rightScore: _rightScore),
                        // Full command section on one background down to the screen edge.
                        Expanded(
                          child: PkLowerSection(
                            commandList: ListenableBuilder(
                              listenable: _chat,
                              builder: (context, _) => PkCommandList(
                                comments: _chat.comments,
                                controller: _chat.scroll,
                                onLiveTap: _chat.scrollToLatest,
                              ),
                            ),
                            rightColumn: PkRightColumn(
                              hearts: PkHeartsLane(key: _heartsLaneKey, ambient: !_isBattleEnded),
                              onGift: _openGiftSheet,
                              onLike: _onLike,
                              onShare: () => PkSheets.showShare(context),
                            ),
                            inputBar: PkInputBar(
                              onEmojiTap: () => PkSheets.showMessageInput(context, onSend: _sendComment),
                              onMessageTap: () => PkSheets.showMessageInput(context, onSend: _sendComment),
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
                      winnerScore: leftWins ? _leftScore : _rightScore,
                      loserScore: leftWins ? _rightScore : _leftScore,
                      onPlayAgain: _restartBattle,
                      onBackToLive: _goBack,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
