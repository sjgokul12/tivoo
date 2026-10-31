// Boxing-gloves clash shown for a few seconds when a PK battle restarts
// (streamer Rebattle, and the viewers' screens when that happens).

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../core/pk_responsive.dart';

class PkBoxerIntro extends StatefulWidget {
  /// Big caption under the gloves, e.g. "REBATTLE!".
  final String title;
  final String leftName;
  final String rightName;
  final int round;
  final Duration duration;
  final VoidCallback onFinished;

  const PkBoxerIntro({
    super.key,
    required this.title,
    required this.leftName,
    required this.rightName,
    required this.round,
    this.duration = const Duration(milliseconds: 3000),
    required this.onFinished,
  });

  @override
  State<PkBoxerIntro> createState() => _PkBoxerIntroState();
}

class _PkBoxerIntroState extends State<PkBoxerIntro> with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(vsync: this, duration: widget.duration)
    ..forward().whenComplete(() {
      if (mounted) widget.onFinished();
    });

  // 0–25%: gloves punch in, 22–40%: impact shake, 25–45%: captions slam in,
  // 85–100%: fade out.
  late final Animation<double> _punch = CurvedAnimation(
    parent: _anim,
    curve: const Interval(0, 0.25, curve: Curves.elasticOut),
  );
  late final Animation<double> _shake = CurvedAnimation(parent: _anim, curve: const Interval(0.22, 0.4));
  late final Animation<double> _title = CurvedAnimation(
    parent: _anim,
    curve: const Interval(0.25, 0.4, curve: Curves.easeOutBack),
  );
  late final Animation<double> _names = CurvedAnimation(
    parent: _anim,
    curve: const Interval(0.32, 0.48, curve: Curves.easeOutCubic),
  );
  late final Animation<double> _fadeOut = Tween<double>(begin: 1, end: 0).animate(
    CurvedAnimation(
      parent: _anim,
      curve: const Interval(0.85, 1, curve: Curves.easeIn),
    ),
  );

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = PkResponsive.of(context);
    final imageWidth = min(r.width * 0.92, r.isWide ? 480.0 : 420.0);

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final shakeX = sin(_shake.value * pi * 10) * (1 - _shake.value) * 10;
        return Opacity(
          opacity: _fadeOut.value,
          child: Stack(
            children: [
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: ColoredBox(color: Colors.black.withValues(alpha: 0.62)),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Opacity(
                        opacity: _names.value.clamp(0.0, 1.0),
                        child: _RoundRibbon(round: widget.round),
                      ),
                      SizedBox(height: r.s(4)),
                      Transform.translate(
                        offset: Offset(shakeX, 0),
                        child: Transform.scale(
                          scale: 0.35 + 0.65 * _punch.value,
                          child: Image.asset(
                            AppAssets.pkBoxer,
                            width: imageWidth,
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.medium,
                          ),
                        ),
                      ),
                      // Title slams down from slightly larger than final size.
                      Transform.scale(
                        scale: 1.6 - 0.6 * _title.value,
                        child: Opacity(
                          opacity: _title.value.clamp(0.0, 1.0),
                          child: _FireTitle(text: widget.title),
                        ),
                      ),
                      SizedBox(height: r.s(10)),
                      Transform.translate(
                        offset: Offset(0, 18 * (1 - _names.value)),
                        child: Opacity(
                          opacity: _names.value.clamp(0.0, 1.0),
                          child: _VersusNames(left: widget.leftName, right: widget.rightName),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Big italic title: dark outline, gold→orange fire gradient fill, and a
/// red (left) / blue (right) glow matching the two gloves.
class _FireTitle extends StatelessWidget {
  final String text;
  const _FireTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    final r = PkResponsive.of(context);
    final style = TextStyle(
      fontFamily: 'Poppins',
      fontSize: r.s(40),
      fontWeight: FontWeight.w700,
      fontStyle: FontStyle.italic,
      letterSpacing: r.s(3),
      height: 1.1,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        // Outline + glow
        Text(
          text,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = r.s(6)
              ..strokeJoin = StrokeJoin.round
              ..color = const Color(0xFF2A0A00),
            shadows: const [
              Shadow(color: Color(0xCCFF3B3B), blurRadius: 18, offset: Offset(-6, 0)),
              Shadow(color: Color(0xCC2E7BFF), blurRadius: 18, offset: Offset(6, 0)),
            ],
          ),
        ),
        // Fire gradient fill
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFBE0), Color(0xFFFFD54F), Color(0xFFFF8F00), Color(0xFFE53935)],
            stops: [0, 0.35, 0.7, 1],
          ).createShader,
          child: Text(text, style: style.copyWith(color: Colors.white)),
        ),
      ],
    );
  }
}

/// "ROUND 2" ribbon above the gloves.
class _RoundRibbon extends StatelessWidget {
  final int round;
  const _RoundRibbon({required this.round});

  @override
  Widget build(BuildContext context) {
    final r = PkResponsive.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.s(16), vertical: r.s(4)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r.s(20)),
        gradient: const LinearGradient(colors: [Color(0xFFE53935), Color(0xFF7B1FA2), Color(0xFF1E63E9)]),
        border: Border.all(color: const Color(0xFFFFD54F), width: 1.2),
        boxShadow: const [BoxShadow(color: Color(0x88FFD54F), blurRadius: 12)],
      ),
      child: Text(
        'ROUND $round',
        style: TextStyle(
          fontFamily: 'Poppins',
          color: Colors.white,
          fontSize: r.s(13),
          fontWeight: FontWeight.w700,
          letterSpacing: r.s(4),
        ),
      ),
    );
  }
}

/// Glass pill: "Priya  VS  Anu" with the names in the gloves' colours.
class _VersusNames extends StatelessWidget {
  final String left;
  final String right;
  const _VersusNames({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    final r = PkResponsive.of(context);
    final nameStyle = TextStyle(
      fontFamily: 'KaushanScript',
      fontSize: r.s(20),
      color: Colors.white,
      shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
    );

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: r.width - 32),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: r.s(18), vertical: r.s(6)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(r.s(30)),
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                left,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: nameStyle.copyWith(color: const Color(0xFFFF8A80)),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: r.s(12)),
              child: Text(
                'VS',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: r.s(15),
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFFFFD54F),
                  shadows: const [Shadow(color: Color(0xAAFFB300), blurRadius: 10)],
                ),
              ),
            ),
            Flexible(
              child: Text(
                right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: nameStyle.copyWith(color: const Color(0xFF82B1FF)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
