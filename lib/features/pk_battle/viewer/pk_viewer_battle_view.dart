// Viewer (user) side of a PK battle.
//
// When the timer ends a popup shows the winner and the stars this viewer
// used, then closes after 3 seconds. If the streamer clicks Rebattle the
// battle restarts here too; otherwise the feed scrolls to the next battle.

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../profile/presentation/controllers/follow_controller.dart';
import '../battle/pk_battle_view_base.dart';
import '../core/pk_battle_session.dart';
import '../sheets/pk_more_options_sheet.dart';
import '../sheets/pk_sheets.dart';
import 'pk_viewer_end_overlay.dart';

class PkViewerBattleView extends PkBattleView {
  const PkViewerBattleView({
    super.key,
    required super.feedItem,
    required super.isActive,
    required super.onBack,
    required super.onExplorePk,
    super.onNextBattle,
  });

  @override
  ConsumerState<PkViewerBattleView> createState() => _PkViewerBattleViewState();
}

class _PkViewerBattleViewState extends PkBattleViewState<PkViewerBattleView> {
  /// How long to wait for the streamer to click Rebattle after the popup closes.
  static const _hostDecisionTimeout = Duration(seconds: 4);

  bool _showResultPopup = false;
  Timer? _hostDecisionTimer;

  ValueNotifier<PkHostDecision> get _hostDecision => PkBattleSessionHub.instance.decisionFor(matchId);

  @override
  void dispose() {
    _stopWaitingForHost();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PkViewerBattleView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Scrolled away: stop waiting so this page can't restart or scroll the feed.
    if (!widget.isActive) _stopWaitingForHost();
  }

  @override
  void onBattleEnded() {
    // Fresh round: forget whatever the streamer chose last time.
    PkBattleSessionHub.instance.reset(matchId);
    setState(() => _showResultPopup = true);
  }

  void _onResultPopupClosed() {
    setState(() => _showResultPopup = false);
    if (!widget.isActive) return;

    _hostDecision.addListener(_onHostDecision);
    _onHostDecision();

    // Testing only (no backend yet): no real streamer can click on this
    // device, so pretend one did — Rebattle or not, 50/50 — when time is up.
    _hostDecisionTimer = Timer(_hostDecisionTimeout, () {
      if (_hostDecision.value != PkHostDecision.pending) return;
      final simulated = Random().nextBool() ? PkHostDecision.rebattle : PkHostDecision.exit;
      PkBattleSessionHub.instance.publish(matchId, simulated);
    });
  }

  void _onHostDecision() {
    final decision = _hostDecision.value;
    if (decision == PkHostDecision.pending || !mounted) return;
    _stopWaitingForHost();

    if (decision == PkHostDecision.rebattle) {
      restartBattle(title: 'REBATTLE!', seconds: widget.feedItem.match.secondsLeft);
    } else {
      // Streamer didn't rebattle: move on to the next PK battle.
      (widget.onNextBattle ?? widget.onBack)();
    }
  }

  void _stopWaitingForHost() {
    _hostDecisionTimer?.cancel();
    _hostDecisionTimer = null;
    _hostDecision.removeListener(_onHostDecision);
  }

  @override
  Widget buildEndOverlay(BuildContext context) {
    if (!_showResultPopup) return PkWaitingForHostPill(hostName: left.name);
    return PkViewerResultPopup(
      left: left,
      right: right,
      leftScore: leftScore,
      rightScore: rightScore,
      giftsSent: sessionGiftsCount,
      starsUsed: sessionStarsSpent,
      onClosed: _onResultPopupClosed,
    );
  }

  @override
  void openMoreOptions() {
    PkMoreOptionsSheet.show(
      context,
      leftHost: left,
      rightHost: right,
      onSwitchHost: confirmSwitchActiveProfile,
      onBlock: () => ref.read(followControllerProvider.notifier).blockUser(hostIdFor(right), onStatusNotify: showSnack),
      onHelp: () => PkSheets.showRules(context),
    );
  }
}
