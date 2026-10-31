// Building blocks shared by the viewer and streamer end-of-battle popups:
// the blurred full-screen frame, the winner/loser result header and the buttons.

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/luxe_theme.dart';
import '../../../core/widgets/custom_avatar.dart';
import '../core/pk_models.dart';
import '../core/pk_responsive.dart';

final _starFormat = NumberFormat('#,###');
String formatPkStars(int value) => _starFormat.format(value);

/// Blurred scrim with a centred, scrollable neon card that pops in.
class PkEndFrame extends StatefulWidget {
  final Widget child;
  final Color glow;

  const PkEndFrame({super.key, required this.child, this.glow = const Color(0xFFFFC928)});

  @override
  State<PkEndFrame> createState() => _PkEndFrameState();
}

class _PkEndFrameState extends State<PkEndFrame> with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 420))
    ..forward();

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = PkResponsive.of(context);
    final fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    final scale = CurvedAnimation(parent: _anim, curve: Curves.easeOutBack);

    return Stack(
      children: [
        Positioned.fill(
          child: FadeTransition(
            opacity: fade,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: ColoredBox(color: Colors.black.withValues(alpha: 0.6)),
            ),
          ),
        ),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: r.s(16)),
              child: ScaleTransition(
                scale: scale,
                child: FadeTransition(
                  opacity: fade,
                  child: Container(
                    width: r.dialogWidth,
                    padding: EdgeInsets.fromLTRB(r.s(18), r.s(20), r.s(18), r.s(18)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(r.s(28)),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xF5221650), Color(0xF50F0B28), Color(0xF5180C30)],
                      ),
                      border: Border.all(color: widget.glow.withValues(alpha: 0.9), width: 1.5),
                      boxShadow: [
                        BoxShadow(color: widget.glow.withValues(alpha: 0.4), blurRadius: 32, spreadRadius: 2),
                        const BoxShadow(color: Colors.black87, blurRadius: 24),
                      ],
                    ),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Both hosts side by side with WINNER / DEFEATED / DRAW badges and their scores.
class PkResultHeader extends StatelessWidget {
  final PkHost left;
  final PkHost right;
  final int leftScore;
  final int rightScore;

  const PkResultHeader({
    super.key,
    required this.left,
    required this.right,
    required this.leftScore,
    required this.rightScore,
  });

  bool get isDraw => leftScore == rightScore;
  PkHost get winner => leftScore > rightScore ? left : right;

  @override
  Widget build(BuildContext context) {
    final r = PkResponsive.of(context);
    final leftOutcome = isDraw ? _Outcome.draw : (leftScore > rightScore ? _Outcome.won : _Outcome.lost);
    final rightOutcome = isDraw ? _Outcome.draw : (rightScore > leftScore ? _Outcome.won : _Outcome.lost);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isDraw ? 'PK Battle Draw! 🤝' : '${winner.name} Won! 🏆',
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: r.s(20),
            fontWeight: FontWeight.w900,
            letterSpacing: 0.3,
            shadows: const [Shadow(color: Colors.black, blurRadius: 8)],
          ),
        ),
        SizedBox(height: r.s(14)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _HostResult(host: left, score: leftScore, outcome: leftOutcome, accent: const Color(0xFFFF2DC0)),
            ),
            Text(
              'VS',
              style: TextStyle(
                color: LuxeColors.gold,
                fontSize: r.s(18),
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                shadows: const [Shadow(color: Color(0xAAFFB300), blurRadius: 10)],
              ),
            ),
            Expanded(
              child: _HostResult(
                host: right,
                score: rightScore,
                outcome: rightOutcome,
                accent: const Color(0xFF00E5FF),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

enum _Outcome { won, lost, draw }

class _HostResult extends StatelessWidget {
  final PkHost host;
  final int score;
  final _Outcome outcome;
  final Color accent;

  const _HostResult({required this.host, required this.score, required this.outcome, required this.accent});

  @override
  Widget build(BuildContext context) {
    final r = PkResponsive.of(context);
    final won = outcome == _Outcome.won;
    final ring = won ? const Color(0xFFFFC928) : accent;
    final avatarRadius = r.s(won ? 30 : 26);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: won ? LuxeColors.goldGradient : LinearGradient(colors: [accent, accent.withValues(alpha: 0.5)]),
            boxShadow: [BoxShadow(color: ring.withValues(alpha: 0.6), blurRadius: 16)],
          ),
          child: Opacity(
            opacity: outcome == _Outcome.lost ? 0.7 : 1,
            child: CustomAvatar(radius: avatarRadius, assetPath: host.avatarAsset),
          ),
        ),
        SizedBox(height: r.s(6)),
        Text(
          host.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: Colors.white, fontSize: r.s(13), fontWeight: FontWeight.w800),
        ),
        SizedBox(height: r.s(2)),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, color: const Color(0xFFFFDF00), size: r.s(14)),
              const SizedBox(width: 2),
              Text(
                formatPkStars(score),
                style: TextStyle(color: LuxeColors.gold, fontSize: r.s(12.5), fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
        SizedBox(height: r.s(6)),
        _OutcomeBadge(outcome: outcome),
      ],
    );
  }
}

class _OutcomeBadge extends StatelessWidget {
  final _Outcome outcome;
  const _OutcomeBadge({required this.outcome});

  @override
  Widget build(BuildContext context) {
    final r = PkResponsive.of(context);
    final (label, gradient, textColor) = switch (outcome) {
      _Outcome.won => (
        'WINNER',
        const LinearGradient(colors: [Color(0xFFFFEA79), Color(0xFFFFC928), Color(0xFFE59A00)]),
        const Color(0xFF1F1400),
      ),
      _Outcome.lost => (
        'DEFEATED',
        const LinearGradient(colors: [Color(0xCC2A1A40), Color(0xCC1A102A)]),
        const Color(0xFF9E98B8),
      ),
      _Outcome.draw => ('DRAW', const LinearGradient(colors: [Color(0xFF5B3CFF), Color(0xFFB04DFF)]), Colors.white),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.s(12), vertical: r.s(3.5)),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
        border: outcome == _Outcome.lost ? Border.all(color: Colors.white24, width: 0.9) : null,
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontSize: r.s(10.5), fontWeight: FontWeight.w900, letterSpacing: 1),
      ),
    );
  }
}

/// Pill button used for Exit / Rewatch / Rebattle.
class PkEndButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback onTap;

  const PkEndButton({super.key, required this.label, required this.icon, required this.onTap, this.primary = false});

  @override
  Widget build(BuildContext context) {
    final r = PkResponsive.of(context);
    final radius = BorderRadius.circular(r.s(18));
    final fg = primary ? const Color(0xFF1F1400) : Colors.white;

    return Container(
      height: r.s(46).clamp(42.0, 52.0),
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: primary ? LuxeColors.goldGradient : null,
        color: primary ? null : Colors.white.withValues(alpha: 0.06),
        border: primary ? null : Border.all(color: Colors.white.withValues(alpha: 0.28), width: 1.2),
        boxShadow: primary ? const [BoxShadow(color: Color(0x66FFC928), blurRadius: 12, offset: Offset(0, 3))] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: fg, size: r.s(18)),
                  SizedBox(width: r.s(6)),
                  Text(
                    label,
                    style: TextStyle(color: fg, fontSize: r.s(14), fontWeight: FontWeight.w900, letterSpacing: 0.3),
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
