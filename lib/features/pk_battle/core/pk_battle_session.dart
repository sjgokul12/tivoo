// Channel between the streamer's PK screen and the viewers' PK screens.

import 'package:flutter/foundation.dart';

/// What the streamer chose when the PK timer ran out.
enum PkHostDecision { pending, rebattle, exit }

/// Carries the streamer's end-of-battle choice to everyone watching the same
/// battle. The streamer publishes; viewers listen and only get a Rewatch
/// option once the streamer has chosen Rebattle, or see "End" if they exit.
///
/// The app has no backend yet, so this lives in memory. Swap [publish] and
/// [decisionFor] for a socket / API channel when one is available.
class PkBattleSessionHub {
  PkBattleSessionHub._();
  static final PkBattleSessionHub instance = PkBattleSessionHub._();

  final Map<String, ValueNotifier<PkHostDecision>> _decisions = {};

  ValueNotifier<PkHostDecision> decisionFor(String matchId) =>
      _decisions.putIfAbsent(matchId, () => ValueNotifier(PkHostDecision.pending));

  void publish(String matchId, PkHostDecision decision) => decisionFor(matchId).value = decision;

  void reset(String matchId) => publish(matchId, PkHostDecision.pending);
}
