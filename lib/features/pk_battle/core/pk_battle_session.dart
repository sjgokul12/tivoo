// Channel between the streamer's PK screen and the viewers' PK screens.

import 'package:flutter/foundation.dart';
import 'pk_models.dart';

/// What the streamer chose when the PK timer ran out.
enum PkHostDecision { pending, rebattle, exit }

/// Carries the streamer's end-of-battle choice to everyone watching the same
/// battle. The streamer publishes; viewers listen and only get a Rewatch
/// option once the streamer has chosen Rebattle, or see "End" if they exit.
class PkBattleSessionHub {
  PkBattleSessionHub._();
  static final PkBattleSessionHub instance = PkBattleSessionHub._();

  final ValueNotifier<List<PkMatch>> activeMatches = ValueNotifier<List<PkMatch>>([]);
  final Map<String, ValueNotifier<PkHostDecision>> _decisions = {};

  void registerMatch(PkMatch match) {
    final current = activeMatches.value.where((m) => m.id != match.id).toList();
    activeMatches.value = [match, ...current];
  }

  void endMatch(String matchId) {
    activeMatches.value = activeMatches.value.where((m) => m.id != matchId).toList();
  }

  void clearMatches() {
    activeMatches.value = [];
  }

  ValueNotifier<PkHostDecision> decisionFor(String matchId) =>
      _decisions.putIfAbsent(matchId, () => ValueNotifier(PkHostDecision.pending));

  void publish(String matchId, PkHostDecision decision) => decisionFor(matchId).value = decision;

  void reset(String matchId) => publish(matchId, PkHostDecision.pending);
}
