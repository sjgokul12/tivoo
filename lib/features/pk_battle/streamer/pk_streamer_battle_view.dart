// Streamer (host) side of a PK battle.
//
// When the timer ends: winner popup with Exit / Rebattle. The choice is
// published to viewers — Rebattle unlocks their Rewatch, Exit shows them "End".

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../home/presentation/widgets/live_tools_bottom_sheet.dart';
import '../battle/pk_battle_view_base.dart';
import '../core/pk_battle_session.dart';
import '../sheets/pk_match_flow.dart';
import '../sheets/pk_sheets.dart';
import 'pk_streamer_end_overlay.dart';

class PkStreamerBattleView extends PkBattleView {
  const PkStreamerBattleView({
    super.key,
    required super.feedItem,
    required super.isActive,
    required super.onBack,
    required super.onExplorePk,
  });

  @override
  ConsumerState<PkStreamerBattleView> createState() => _PkStreamerBattleViewState();
}

class _PkStreamerBattleViewState extends PkBattleViewState<PkStreamerBattleView> {
  @override
  void onBattleEnded() => PkBattleSessionHub.instance.reset(matchId);

  void _rebattle() {
    PkBattleSessionHub.instance.publish(matchId, PkHostDecision.rebattle);
    restartBattle(title: 'REBATTLE!', seconds: settings.durationSeconds);
  }

  void _exit() {
    PkBattleSessionHub.instance.publish(matchId, PkHostDecision.exit);
    widget.onBack();
  }

  @override
  Widget buildEndOverlay(BuildContext context) {
    return PkStreamerEndOverlay(
      left: left,
      right: right,
      leftScore: leftScore,
      rightScore: rightScore,
      onRebattle: _rebattle,
      onExit: _exit,
    );
  }

  @override
  void openMoreOptions() {
    LiveToolsBottomSheet.show(
      context,
      onPkSettingsTap: _openPkSettings,
      onInviteTap: _openMatchFlow,
      onGuestsTap: _openMatchFlow,
      onRankingTap: () => PkSheets.showMoreOptions(context, onSettings: _openPkSettings, onPreviewWinner: endBattle),
      onReportTap: () => PkSheets.showRules(context),
    );
  }

  void _openPkSettings() {
    PkSheets.showSettings(
      context,
      current: settings,
      onSave: (newSettings) {
        setState(() => settings = newSettings);
        secondsRemaining.value = newSettings.durationSeconds;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⏱️ PK Duration set to ${newSettings.durationSeconds ~/ 60} min!'),
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
      host: left,
      onOpenSettings: _openPkSettings,
      onMatched: (rival) {
        restartBattle(
          title: 'FIGHT!',
          seconds: settings.durationSeconds,
          opponent: right.copyWith(
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
}
