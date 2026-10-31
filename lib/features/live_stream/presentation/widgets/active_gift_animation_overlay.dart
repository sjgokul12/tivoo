import 'dart:math';
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/services/gift_sound_service.dart';
import '../../domain/models/gift_item.dart';

/// 3D gift animation engine.
///
/// Every gift is staged in a small 3D scene seen through a perspective camera:
///   0.00–0.24  arrival   – camera dolly-in while the gift flies in from depth or a side
///   0.22–0.34  impact    – flash + shockwave ripples across a glossy floor
///   0.30–0.72  showcase  – camera orbit, 3D particle vortex in front of / behind the gift,
///                          volumetric light rays, bloom, reflection, shine sweep
///   0.56–0.74  finale    – 3D particle burst, lens flare (and fireworks for some gifts)
///   0.72–0.92  exit      – the gift flies to the receiving host with a sparkle trail
///   0.90–1.00  arrival burst on the host's side
///
/// Artwork comes from [GiftItem.imageAssetPath] (emoji fallback). Sending the same gift
/// again while it is on screen raises the combo counter instead of restarting.
class ActiveGiftAnimationOverlay extends StatefulWidget {
  final Widget child;
  final bool isSuppressed;
  final bool showTopBanner;

  const ActiveGiftAnimationOverlay({
    super.key,
    required this.child,
    this.isSuppressed = false,
    this.showTopBanner = true,
  });

  static ActiveGiftAnimationOverlayState? of(BuildContext context) {
    return context.findAncestorStateOfType<ActiveGiftAnimationOverlayState>();
  }

  @override
  State<ActiveGiftAnimationOverlay> createState() => ActiveGiftAnimationOverlayState();
}

class ActiveGiftAnimationOverlayState extends State<ActiveGiftAnimationOverlay> with TickerProviderStateMixin {
  // Created in initState (not lazily) so dispose never builds a controller while unmounting.
  late final AnimationController _timeline;
  late final AnimationController _combo;

  GiftItem? _gift;
  _Look _look = _Look.generic;
  String _sender = 'You';
  String _recipient = '';
  int _count = 1;
  bool _toLeft = true;
  List<_Mote> _motes = const [];
  int _seed = 0;

  /// Global screen position the gift flies to on exit (e.g. the host's profile photo).
  Offset? _target;
  VoidCallback? _onComplete;

  @override
  void initState() {
    super.initState();
    _timeline = AnimationController(vsync: this)..addStatusListener(_onTimelineStatus);
    _combo = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  }

  @override
  void dispose() {
    _timeline.dispose();
    _combo.dispose();
    super.dispose();
  }

  void _onTimelineStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      GiftSoundService.instance.stop();
      final cb = _onComplete;
      _onComplete = null;
      setState(() => _gift = null);
      cb?.call();
    }
  }

  /// Immediately stops the running animation and hides everything.
  void clear() {
    _timeline.stop();
    _timeline.reset();
    _combo.reset();
    _onComplete = null;
    GiftSoundService.instance.stop();
    if (mounted) {
      setState(() {
        _gift = null;
        _count = 0;
        _sender = '';
      });
    }
  }

  /// Plays the 3D animation for [gift]. If the same sender sends the same gift while
  /// it is still on screen, the combo counter increases instead.
  ///
  /// [target] is the global position the gift flies to at the end (for example the
  /// receiving host's profile photo); without it the gift flies to that host's side.
  void playGift(
    GiftItem gift, {
    String senderName = 'You',
    int count = 1,
    bool toLeft = true,
    String recipient = '',
    Offset? target,
    VoidCallback? onComplete,
  }) {
    final isCombo =
        _gift != null &&
        _gift!.id == gift.id &&
        _sender == senderName &&
        _timeline.isAnimating &&
        _timeline.value < 0.72;
    if (isCombo) {
      if (onComplete != null) _onComplete = onComplete;
      setState(() => _count += count);
      _combo.forward(from: 0);
      _timeline.forward(from: 0.36); // stay in the showcase
      return;
    }

    _onComplete = onComplete;

    // Decode the artwork at full resolution up front so it is sharp from the first frame.
    final art = gift.imageAssetPath;
    if (art != null && art.isNotEmpty) precacheImage(AssetImage(art), context, onError: (_, _) {});

    final look = _Look.of(gift);
    _seed++;
    setState(() {
      _gift = gift;
      _look = look;
      _sender = senderName;
      _recipient = recipient;
      _count = count;
      _toLeft = toLeft;
      _target = target;
      _motes = _Mote.generate(look, Random(_seed));
    });
    _timeline.duration = look.tier.duration;
    _timeline.forward(from: 0);
    _combo.forward(from: 0);
    GiftSoundService.instance.stop();
    GiftSoundService.instance.playGiftSound(look.sound);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSuppressed) return widget.child;
    final gift = _gift;
    final box = context.findRenderObject() as RenderBox?;
    final target = _target == null || box == null || !box.hasSize ? null : box.globalToLocal(_target!);
    return Stack(
      children: [
        widget.child,
        if (gift != null)
          Positioned.fill(
            child: IgnorePointer(
              // Transparent Material gives captions a proper text style even when the
              // overlay sits above a Scaffold (as on the PK screen).
              child: Material(
                type: MaterialType.transparency,
                child: LayoutBuilder(
                  builder: (context, constraints) => _GiftStage(
                    timeline: _timeline,
                    combo: _combo,
                    gift: gift,
                    look: _look,
                    motes: _motes,
                    sender: _sender,
                    recipient: _recipient,
                    count: _count,
                    toLeft: _toLeft,
                    target: target,
                    size: constraints.biggest,
                    topPadding: MediaQuery.paddingOf(context).top,
                    showBanner: widget.showTopBanner,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// =============================================================================
// GIFT LOOKS
// =============================================================================

enum _Tier {
  small(Duration(milliseconds: 4000), 0.62, 0.45),
  medium(Duration(milliseconds: 5200), 0.74, 0.58),
  premium(Duration(milliseconds: 7000), 0.86, 0.72);

  const _Tier(this.duration, this.heroFactor, this.dim);

  final Duration duration;

  /// Gift width as a fraction of the screen's shortest side.
  final double heroFactor;

  /// How much the backdrop darkens the live video.
  final double dim;
}

/// Where the gift enters the 3D scene from.
enum _Arrival { depth, left, right, below, above, spin }

/// Particle shapes that fill the 3D scene.
enum _MoteKind { sparkle, petal, heart, bubble, feather, ember, star, confetti, shard }

class _Look {
  final String sound;
  final _Tier tier;
  final _Arrival arrival;
  final List<_MoteKind> motes;

  /// [main light, secondary light, highlight]
  final List<Color> palette;

  /// Extra 3D fireworks during the finale.
  final bool fireworks;

  /// Separately cut wings that flap (the gift is drawn as a flying pair of wings).
  final _WingRig? wings;

  /// Cut-out rocket with an animated flame that orbits the stage.
  final _RocketRig? rocket;

  const _Look(
    this.sound,
    this.tier,
    this.arrival,
    this.motes,
    this.palette, {
    this.fireworks = false,
    this.wings,
    this.rocket,
  });

  static const _gold = [Color(0xFFFFC400), Color(0xFFFF8F00), Color(0xFFFFF8E1)];
  static const _pink = [Color(0xFFFF4FA3), Color(0xFFFF80AB), Color(0xFFFFD54F)];
  static const _blue = [Color(0xFF2979FF), Color(0xFF00E5FF), Color(0xFFB388FF)];
  static const _cosmic = [Color(0xFF7C4DFF), Color(0xFF00E5FF), Color(0xFFFF9100)];
  static const _ice = [Color(0xFF80D8FF), Color(0xFFB388FF), Colors.white];
  static const _heaven = [Color(0xFFFFF59D), Color(0xFF80D8FF), Colors.white];
  static const _rose = [Color(0xFFFF1744), Color(0xFFFF80AB), Color(0xFFFFD54F)];
  static const _neon = [Color(0xFFFFB300), Color(0xFFD500F9), Color(0xFF00E5FF)];

  static const generic = _Look(
    'generic',
    _Tier.small,
    _Arrival.depth,
    [_MoteKind.sparkle],
    [Color(0xFFFF2D9A), Color(0xFF7C4DFF), Color(0xFFFFD54F)],
  );

  /// Hand-tuned looks for the featured gifts.
  static const Map<String, _Look> _featured = {
    // Legacy & 3D key names
    'gift_rose_bouquet': _Look('rose', _Tier.premium, _Arrival.depth, [_MoteKind.petal, _MoteKind.ember], _rose),
    'p3d_royal_crown': _Look('crown', _Tier.premium, _Arrival.below, [_MoteKind.sparkle, _MoteKind.ember], _gold),
    'p3d_angel_vehicle': _Look('angel_vehicle', _Tier.premium, _Arrival.left, [
      _MoteKind.feather,
      _MoteKind.sparkle,
    ], _heaven),
    'p3d_golden_horse': _Look('horse', _Tier.premium, _Arrival.left, [_MoteKind.ember, _MoteKind.sparkle], _gold),
    'p3d_luxury_car': _Look(
      'car',
      _Tier.premium,
      _Arrival.right,
      [_MoteKind.ember, _MoteKind.sparkle],
      _neon,
      fireworks: true,
    ),
    'p3d_love_castle': _Look(
      'castle',
      _Tier.premium,
      _Arrival.below,
      [_MoteKind.heart, _MoteKind.sparkle],
      _pink,
      fireworks: true,
    ),
    'p3d_galaxy_rocket': _Look(
      'rocket',
      _Tier.premium,
      _Arrival.below,
      [_MoteKind.star, _MoteKind.sparkle],
      _cosmic,
      rocket: _RocketRig.galaxy,
    ),
    'p3d_diamond_wings': _Look(
      'wings',
      _Tier.premium,
      _Arrival.depth,
      [_MoteKind.shard, _MoteKind.sparkle],
      _ice,
      wings: _WingRig.diamond,
    ),
    'p3d_flower_chariot': _Look('flowers', _Tier.premium, _Arrival.left, [_MoteKind.petal, _MoteKind.sparkle], _pink),
    'p3d_ocean_whale': _Look('whale', _Tier.premium, _Arrival.right, [_MoteKind.bubble, _MoteKind.sparkle], _blue),
    'p3d_meteor_shower': _Look(
      'diamond',
      _Tier.premium,
      _Arrival.above,
      [_MoteKind.star, _MoteKind.sparkle],
      _gold,
      fireworks: true,
    ),

    // Unified Gift Catalog IDs (PK Battle & all screens)
    'gift_ani7_crown': _Look('crown', _Tier.premium, _Arrival.below, [_MoteKind.sparkle, _MoteKind.ember], _gold),
    'gift_ani3_vehicle': _Look('angel_vehicle', _Tier.premium, _Arrival.left, [
      _MoteKind.feather,
      _MoteKind.sparkle,
    ], _heaven),
    'gift_ani2_horse': _Look('horse', _Tier.premium, _Arrival.left, [_MoteKind.ember, _MoteKind.sparkle], _gold),
    'gift_ani5_castle': _Look(
      'castle',
      _Tier.premium,
      _Arrival.below,
      [_MoteKind.heart, _MoteKind.sparkle],
      _pink,
      fireworks: true,
    ),
    'gift_rocket': _Look(
      'rocket',
      _Tier.premium,
      _Arrival.below,
      [_MoteKind.star, _MoteKind.sparkle],
      _cosmic,
      rocket: _RocketRig.galaxy,
    ),
    'gift_golden_lion': _Look(
      'lion',
      _Tier.premium,
      _Arrival.left,
      [_MoteKind.ember, _MoteKind.sparkle],
      _gold,
      fireworks: true,
    ),
    'gift_ani6_car': _Look(
      'car',
      _Tier.premium,
      _Arrival.right,
      [_MoteKind.ember, _MoteKind.sparkle],
      _neon,
      fireworks: true,
    ),
    'gift_super_car': _Look(
      'car',
      _Tier.premium,
      _Arrival.right,
      [_MoteKind.ember, _MoteKind.sparkle],
      _neon,
      fireworks: true,
    ),
    'gift_flowers': _Look('flowers', _Tier.premium, _Arrival.left, [_MoteKind.petal, _MoteKind.sparkle], _pink),
    'gift_yacht': _Look('yacht', _Tier.premium, _Arrival.right, [_MoteKind.bubble, _MoteKind.sparkle], _blue),
    'gift_diamond_wings': _Look(
      'wings',
      _Tier.premium,
      _Arrival.depth,
      [_MoteKind.shard, _MoteKind.sparkle],
      _ice,
      wings: _WingRig.diamond,
    ),
    'gift_ani4_throne': _Look('throne', _Tier.premium, _Arrival.above, [_MoteKind.star, _MoteKind.sparkle], _gold),
    'gift_ani10_roses': _Look('roses', _Tier.premium, _Arrival.depth, [_MoteKind.petal, _MoteKind.sparkle], _rose),
    'gift_ani1_whale': _Look('whale', _Tier.premium, _Arrival.right, [_MoteKind.bubble, _MoteKind.sparkle], _blue),
    'gift_rose': _Look('rose', _Tier.medium, _Arrival.depth, [_MoteKind.petal], _rose),
    'gift_love': _Look('love', _Tier.medium, _Arrival.depth, [_MoteKind.heart, _MoteKind.sparkle], _rose),
    'gift_diamond': _Look('diamond', _Tier.medium, _Arrival.spin, [_MoteKind.sparkle], _ice),
  };

  static _Look of(GiftItem gift) {
    final featured = _featured[gift.id];
    if (featured != null) return featured;

    final key = '${gift.id} ${gift.name}'.toLowerCase();
    bool has(String s) => key.contains(s);
    if (has('lion')) {
      return const _Look(
        'lion',
        _Tier.premium,
        _Arrival.left,
        [_MoteKind.ember, _MoteKind.sparkle],
        _gold,
        fireworks: true,
      );
    }
    if (has('throne')) {
      return const _Look('throne', _Tier.premium, _Arrival.above, [_MoteKind.star, _MoteKind.sparkle], _gold);
    }
    if (has('dolphin')) {
      return const _Look('dolphin', _Tier.premium, _Arrival.right, [_MoteKind.bubble, _MoteKind.sparkle], _blue);
    }
    if (has('roses')) {
      return const _Look('roses', _Tier.premium, _Arrival.depth, [_MoteKind.petal, _MoteKind.sparkle], _rose);
    }
    if (has('rocket')) {
      return const _Look(
        'rocket',
        _Tier.premium,
        _Arrival.below,
        [_MoteKind.star, _MoteKind.sparkle],
        _cosmic,
        rocket: _RocketRig.galaxy,
      );
    }
    if (has('car')) {
      return const _Look('car', _Tier.premium, _Arrival.right, [_MoteKind.ember], _neon, fireworks: true);
    }
    if (has('yacht') || has('whale')) {
      return const _Look('yacht', _Tier.premium, _Arrival.right, [_MoteKind.bubble, _MoteKind.sparkle], _blue);
    }
    if (has('castle')) {
      return const _Look('castle', _Tier.premium, _Arrival.below, [_MoteKind.heart], _pink, fireworks: true);
    }
    if (has('world') || has('tour')) {
      return const _Look('world_tour', _Tier.premium, _Arrival.spin, [_MoteKind.star, _MoteKind.sparkle], _cosmic);
    }
    if (has('horse')) return const _Look('horse', _Tier.premium, _Arrival.left, [_MoteKind.ember], _gold);
    if (has('wing')) {
      return const _Look(
        'wings',
        _Tier.premium,
        _Arrival.depth,
        [_MoteKind.shard, _MoteKind.sparkle],
        _ice,
        wings: _WingRig.diamond,
      );
    }
    if (has('diamond')) return const _Look('diamond', _Tier.medium, _Arrival.spin, [_MoteKind.sparkle], _ice);
    if (has('crown')) return const _Look('crown', _Tier.medium, _Arrival.below, [_MoteKind.sparkle], _gold);
    if (has('rose')) return const _Look('rose', _Tier.medium, _Arrival.depth, [_MoteKind.petal], _rose);
    if (has('flower')) return const _Look('flowers', _Tier.small, _Arrival.depth, [_MoteKind.petal], _pink);
    if (has('cake')) return const _Look('cake', _Tier.small, _Arrival.depth, [_MoteKind.confetti], _pink);
    if (has('teddy') || has('panda')) {
      return const _Look('teddy', _Tier.small, _Arrival.depth, [_MoteKind.heart], _pink);
    }
    if (has('kitty') || has('cat')) return const _Look('kitty', _Tier.small, _Arrival.depth, [_MoteKind.heart], _pink);
    if (has('tiki') || has('love') || has('heart')) {
      return const _Look('love', _Tier.small, _Arrival.depth, [_MoteKind.heart, _MoteKind.sparkle], _rose);
    }
    return generic;
  }
}

// =============================================================================
// 3D MATH
// =============================================================================

double _interval(double t, double begin, double end) => ((t - begin) / (end - begin)).clamp(0.0, 1.0);

/// Scene intensity: fade in, hold, fade out.
double _envelope(double t) {
  if (t < 0.08) return Curves.easeOut.transform(t / 0.08);
  if (t > 0.86) return 1 - Curves.easeIn.transform(_interval(t, 0.86, 1.0));
  return 1;
}

/// Screen-space exit curve from the stage to the receiving host.
Offset _exitPoint(double x, Offset from, Offset to, Size size) {
  final control = Offset((from.dx + to.dx) / 2, min(from.dy, to.dy) - size.height * 0.12);
  final u = 1 - x;
  return from * (u * u) + control * (2 * u * x) + to * (x * x);
}

class _Projected {
  final Offset point;

  /// Pixels per world unit at this depth.
  final double scale;

  /// Depth relative to the gift: negative = in front of it (closer to the camera).
  final double depth;

  const _Projected(this.point, this.scale, this.depth);
}

/// Perspective camera looking at the gift (world origin). One world unit = gift width.
class _Camera {
  final Offset center;
  final double focal;
  final double distance;
  final double yaw;

  const _Camera({required this.center, required this.focal, required this.distance, required this.yaw});

  static const double restDistance = 1.6;

  /// Camera for time [t]: dolly-in during arrival, slow orbit + push-in during the showcase.
  factory _Camera.at(double t, double seconds, Offset center, double heroWidth) {
    final dolly = Curves.easeOutCubic.transform(_interval(t, 0.0, 0.26));
    final push = Curves.easeInOut.transform(_interval(t, 0.3, 0.72));
    final orbit = sin(t * pi); // 0 → 1 → 0 over the whole timeline
    return _Camera(
      center: center,
      focal: heroWidth * restDistance,
      distance: restDistance + (1 - dolly) * 0.9 - push * 0.12,
      yaw: sin(seconds * 0.75) * 0.3 * orbit,
    );
  }

  _Projected? project(double x, double y, double z) {
    final cx = x * cos(yaw) - z * sin(yaw);
    final cz = x * sin(yaw) + z * cos(yaw);
    final depth = cz + distance;
    if (depth < 0.12) return null;
    final s = focal / depth;
    return _Projected(center + Offset(cx * s, y * s), s, cz);
  }
}

/// Where the gift is in world space during the arrival.
({double x, double y, double z, double spin}) _giftWorld(double t, _Arrival arrival) {
  final e = Curves.easeOutCubic.transform(_interval(t, 0.0, 0.24));
  final back = Curves.easeOutBack.transform(_interval(t, 0.0, 0.24));
  final u = 1 - e;
  switch (arrival) {
    case _Arrival.depth:
      return (x: 0, y: -0.15 * u, z: 5.0 * u, spin: 0);
    case _Arrival.left:
      return (x: -2.4 * (1 - back), y: -0.1 * u, z: 1.2 * u, spin: 0);
    case _Arrival.right:
      return (x: 2.4 * (1 - back), y: -0.1 * u, z: 1.2 * u, spin: 0);
    case _Arrival.below:
      return (x: 0, y: 2.2 * (1 - back), z: 0.8 * u, spin: 0);
    case _Arrival.above:
      return (x: 0.6 * u, y: -2.2 * (1 - back), z: 0.8 * u, spin: 0);
    case _Arrival.spin:
      return (x: 0, y: 0, z: 2.5 * u, spin: u * 2 * pi);
  }
}

typedef _Flight = ({double dx, double dy, double scale, double bank, double turn, double spin, double roll});

const _Flight _noFlight = (dx: 0, dy: 0, scale: 1, bank: 0, turn: 0, spin: 0, roll: 0);

/// Free flight for winged gifts during the showcase: a figure-8 swoop left and right,
/// banking and turning into each curve, moving closer / farther, with one full 3D spin.
_Flight _wingFlight(double t, double seconds, Size size, double heroH, [double heroW = 0]) {
  final on =
      Curves.easeInOut.transform(_interval(t, 0.26, 0.36)) * (1 - Curves.easeInOut.transform(_interval(t, 0.64, 0.72)));
  final phase = seconds * 2 * pi * 0.42;
  return (
    // Sideways travel limited so the wings stay on screen (they shrink a little while flying).
    dx: sin(phase) * max(size.width * 0.06, (size.width - heroW * 0.82) / 2) * on,
    dy: sin(2 * phase) * heroH * 0.16 * on,
    scale: 1 - 0.18 * on + 0.1 * cos(phase) * on,
    bank: cos(phase) * 0.32 * on,
    turn: cos(phase) * 0.6 * on,
    spin: Curves.easeInOut.transform(_interval(t, 0.46, 0.58)) * 2 * pi,
    roll: 0,
  );
}

/// Rocket showcase: a 3D elliptical orbit swinging left and right around the stage
/// (bigger when passing in front, smaller behind) with one full barrel roll.
/// [vel] is the screen direction of travel, used to point the nose.
({_Flight flight, Offset vel, double on}) _rocketFlight(
  double t,
  double seconds,
  double duration,
  Size size,
  double heroW,
  double heroH,
) {
  final on =
      Curves.easeInOut.transform(_interval(t, 0.26, 0.36)) * (1 - Curves.easeInOut.transform(_interval(t, 0.64, 0.72)));
  final phi = pi / 2 + (seconds - 0.26 * duration) * 2 * pi * 0.42;
  final rx = max(size.width * 0.08, (size.width - heroW * 0.7) / 2);
  final ry = heroH * 0.3;
  return (
    flight: (
      dx: cos(phi) * rx * on,
      dy: sin(phi) * ry * on,
      scale: 1 - 0.12 * on + 0.18 * sin(phi) * on,
      bank: 0,
      turn: cos(phi) * 0.45 * on,
      spin: 0,
      roll: Curves.easeInOut.transform(_interval(t, 0.44, 0.56)) * 2 * pi,
    ),
    vel: Offset(-sin(phi) * rx, cos(phi) * ry),
    on: on,
  );
}

// =============================================================================
// MOTES (3D PARTICLES)
// =============================================================================

class _Mote {
  final _MoteKind kind;
  final double angle;
  final double radius;
  final double height;
  final double speed;
  final double size;
  final double phase;
  final double spin;
  final int color;

  const _Mote(
    this.kind,
    this.angle,
    this.radius,
    this.height,
    this.speed,
    this.size,
    this.phase,
    this.spin,
    this.color,
  );

  static List<_Mote> generate(_Look look, Random r) {
    final count = switch (look.tier) {
      _Tier.small => 70,
      _Tier.medium => 100,
      _Tier.premium => 140,
    };
    return List.generate(count, (i) {
      // Mostly the gift's own particle; a few generic sparkles for richness.
      final kind = i % 5 == 4 ? _MoteKind.sparkle : look.motes[i % look.motes.length];
      return _Mote(
        kind,
        r.nextDouble() * 2 * pi,
        0.55 + r.nextDouble() * 1.1,
        r.nextDouble() * 2.4 - 1.2,
        0.5 + r.nextDouble(),
        r.nextDouble(),
        r.nextDouble(),
        (r.nextDouble() * 2 - 1) * 3,
        r.nextInt(3),
      );
    });
  }

  bool get _falls =>
      kind == _MoteKind.petal || kind == _MoteKind.feather || kind == _MoteKind.confetti || kind == _MoteKind.shard;
  bool get _rises => kind == _MoteKind.bubble || kind == _MoteKind.heart || kind == _MoteKind.ember;

  /// World position: converges from far away, swirls around the gift, then bursts outward.
  ({double x, double y, double z, double fade}) position(double t, double seconds) {
    final converge = Curves.easeOutCubic.transform(_interval(t, 0.0, 0.32));
    final burst = Curves.easeOutCubic.transform(_interval(t, 0.56, 0.8));
    final ang = angle + seconds * speed * 0.6 * (phase > 0.5 ? 1 : -1);
    final r = radius * (2.8 - 1.8 * converge) + burst * (1.4 + size * 1.6);

    var y = height;
    var fade = 1.0;
    if (_falls || _rises) {
      final travel = (seconds * speed * 0.22 + phase) % 1.0; // loops through the column
      y = _falls ? -1.3 + travel * 2.6 : 1.3 - travel * 2.6;
      fade = travel < 0.1 ? travel / 0.1 : (travel > 0.85 ? (1 - travel) / 0.15 : 1.0);
    } else {
      y += sin(seconds * speed * 1.4 + phase * 6) * 0.08;
    }
    y += burst * burst * 0.5 * (height + 0.4); // gravity on the burst
    return (x: r * cos(ang), y: y, z: r * sin(ang), fade: fade);
  }
}

// =============================================================================
// STAGE WIDGET
// =============================================================================

class _GiftStage extends StatelessWidget {
  final AnimationController timeline;
  final AnimationController combo;
  final GiftItem gift;
  final _Look look;
  final List<_Mote> motes;
  final String sender;
  final String recipient;
  final int count;
  final bool toLeft;
  final Offset? target;
  final Size size;
  final double topPadding;
  final bool showBanner;

  const _GiftStage({
    required this.timeline,
    required this.combo,
    required this.gift,
    required this.look,
    required this.motes,
    required this.sender,
    required this.recipient,
    required this.count,
    required this.toLeft,
    required this.target,
    required this.size,
    required this.topPadding,
    required this.showBanner,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([timeline, combo]),
      builder: (context, _) {
        final t = timeline.value;
        final seconds = t * look.tier.duration.inMilliseconds / 1000;
        final env = _envelope(t);

        final base = (size.shortestSide * look.tier.heroFactor).clamp(180.0, 560.0);
        final wings = look.wings;
        final rocket = look.rocket;
        final duration = look.tier.duration.inMilliseconds / 1000;
        final heroW = rocket != null
            ? min(size.width * 0.62, base * 1.2)
            : wings != null
            ? min(size.width * 0.98, base * 1.75)
            : (gift.isSceneArt ? min(size.width * 0.92, base * 1.55) : base);
        final heroH = rocket != null
            ? heroW / rocket.aspectRatio
            : wings != null
            ? heroW / wings.aspectRatio
            : (gift.isSceneArt ? heroW / 1.45 : base);
        final stage = Offset(size.width / 2, size.height * 0.42);
        final dest = target ?? Offset(size.width * (toLeft ? 0.25 : 0.75), size.height * 0.22);
        final camera = _Camera.at(t, seconds, stage, heroW);

        // Gift placement: 3D arrival, then screen-space exit to the host.
        final world = _giftWorld(t, look.arrival);
        final projected = camera.project(world.x, world.y, world.z);
        final exit = Curves.easeInCubic.transform(_interval(t, 0.72, 0.92));
        final restScale = projected == null ? 0.0 : projected.scale / camera.focal * _Camera.restDistance;
        _Flight flightAt(double tt) {
          final sec = tt * duration;
          if (rocket != null) return _rocketFlight(tt, sec, duration, size, heroW, heroH).flight;
          if (wings != null) return _wingFlight(tt, sec, size, heroH, heroW);
          return _noFlight;
        }

        /// Screen position of the gift at any time (used for the exhaust trail too).
        Offset centerAt(double tt) {
          final cam = tt == t ? camera : _Camera.at(tt, tt * duration, stage, heroW);
          final w = tt == t ? world : _giftWorld(tt, look.arrival);
          final pr = tt == t ? projected : cam.project(w.x, w.y, w.z);
          final ex = Curves.easeInCubic.transform(_interval(tt, 0.72, 0.92));
          final f = flightAt(tt);
          final base = pr?.point ?? stage;
          return (ex > 0 ? _exitPoint(ex, base, dest, size) : base) + Offset(f.dx, f.dy);
        }

        final flight = flightAt(t);
        final heroCenter = centerAt(t);
        final heroScale = restScale * (1 - 0.88 * exit) * flight.scale;

        // Rocket: point the nose along its path (up while launching, around the orbit,
        // then straight at the receiving host).
        var rocketTilt = 0.0;
        var rocketHeading = const Offset(0, -1);
        if (rocket != null) {
          final orbit = _rocketFlight(t, seconds, duration, size, heroW, heroH);
          final toward = Curves.easeInOut.transform(_interval(t, 0.66, 0.74));
          Offset unit(Offset v) => v.distance < 1e-6 ? Offset.zero : v / v.distance;
          final v =
              const Offset(0, -1) * ((1 - orbit.on) * (1 - toward)) +
              unit(orbit.vel) * (orbit.on * (1 - toward)) +
              unit(dest - stage) * toward;
          rocketHeading = v.distance < 1e-3 ? const Offset(0, -1) : unit(v);
          rocketTilt = atan2(rocketHeading.dy, rocketHeading.dx) - rocket.noseAngle;
        }
        final rocketTrail = rocket == null
            ? const <Offset>[]
            : [
                for (var k = 1; k <= 18; k++)
                  centerAt((t - k * 0.005).clamp(0.0, 1.0)) - rocketHeading * (heroW * heroScale * 0.42),
              ];
        // Glowing trail behind flying wings (recent flight positions).
        final trail = wings == null || flight.scale == 1 && flight.dx == 0
            ? const <Offset>[]
            : [
                for (var k = 1; k <= 14; k++)
                  () {
                    final tt = (t - k * 0.006).clamp(0.0, 1.0);
                    final f = _wingFlight(tt, tt * look.tier.duration.inMilliseconds / 1000, size, heroH, heroW);
                    return stage + Offset(f.dx, f.dy);
                  }(),
              ];
        final heroOpacity = (min(1.0, _interval(t, 0.0, 0.06) * 1.5) * (exit > 0.96 ? 1 - _interval(exit, 0.96, 1.0) : 1))
            .clamp(0.0, 1.0);
        final floorY = stage.dy + heroH * 0.5 * restScale + 10;
        final caption = t < 0.30 ? 0.0 : min(_interval(t, 0.30, 0.38), 1 - _interval(t, 0.68, 0.74));

        final _StageArgs painterArgs = (
          t: t,
          seconds: seconds,
          env: env,
          camera: camera,
          heroCenter: heroCenter,
          heroW: heroW * heroScale,
          floorY: floorY,
          floorX: wings != null ? heroCenter.dx : stage.dx,
          stage: stage,
          dest: dest,
          trail: rocket != null ? rocketTrail : trail,
          trailKind: rocket != null ? 2 : (wings != null ? 1 : 0),
          floor: rocket == null,
        );

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. Atmosphere: darkens / tints the live screen behind the scene.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.16),
                    radius: 1.15,
                    colors: [
                      look.palette[0].withValues(alpha: 0.28 * env),
                      const Color(0xFF05060F).withValues(alpha: look.tier.dim * 0.6 * env),
                      Colors.black.withValues(alpha: look.tier.dim * env),
                    ],
                    stops: const [0, 0.55, 1],
                  ),
                ),
              ),
            ),
            // 2. Back layer: nebula, light rays, floor, particles behind the gift.
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _StagePainter(args: painterArgs, look: look, motes: motes, front: false),
                ),
              ),
            ),
            // 3. Floor reflection of the gift.
            if (exit == 0 && heroScale > 0 && rocket == null)
              Positioned(
                left: heroCenter.dx - heroW * heroScale / 2,
                top: floorY,
                width: heroW * heroScale,
                height: heroH * heroScale * 0.55,
                child: _Reflection(
                  opacity: 0.28 * env * heroOpacity,
                  aspectRatio: heroW / heroH,
                  child: wings != null
                      ? _FlappingWings(rig: wings, t: t, seconds: seconds, width: heroW, height: heroH)
                      : _artFor(gift),
                ),
              ),
            // 4. The gift.
            if (t < 0.93 && heroScale > 0)
              Positioned(
                left: heroCenter.dx - heroW / 2,
                top: heroCenter.dy - heroH / 2,
                width: heroW,
                height: heroH,
                child: Opacity(
                  opacity: heroOpacity,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0014)
                      ..rotateY(-camera.yaw * (rocket != null ? 0.5 : 0.9) + world.spin + flight.turn + flight.spin)
                      ..rotateX(sin(seconds * 1.2) * 0.05)
                      ..rotateZ(rocket != null ? rocketTilt : exit * 0.5 + flight.bank)
                      ..scaleByDouble(heroScale, heroScale, 1, 1),
                    child: _Hero3D(
                      look: look,
                      t: t,
                      seconds: seconds,
                      width: heroW,
                      height: heroH,
                      sheen: rocket == null,
                      art: rocket != null
                          ? _RocketArt(
                              rig: rocket,
                              t: t,
                              seconds: seconds,
                              roll: flight.roll,
                              width: heroW,
                              height: heroH,
                            )
                          : wings != null
                          ? _FlappingWings(rig: wings, t: t, seconds: seconds, width: heroW, height: heroH)
                          : _artFor(gift),
                    ),
                  ),
                ),
              ),
            // 5. Front layer: particles in front of the gift, flash, lens flare, trails.
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _StagePainter(args: painterArgs, look: look, motes: motes, front: true),
                ),
              ),
            ),
            // 6. Combo counter + caption.
            if (caption > 0)
              Positioned(
                left: min(stage.dx + heroW * 0.26, size.width - 96),
                top: stage.dy - heroH * 0.5 - 34,
                child: Opacity(
                  opacity: caption,
                  child: _ComboCounter(count: count, entry: _interval(t, 0.30, 0.40), punch: combo.value),
                ),
              ),
            if (caption > 0)
              Positioned(
                left: 16,
                right: 16,
                top: min(floorY + heroH * 0.18, size.height - 120),
                child: Opacity(
                  opacity: caption,
                  child: Transform.translate(
                    offset: Offset(0, (1 - caption) * 12),
                    child: Center(
                      child: _Caption(sender: sender, recipient: recipient, gift: gift, look: look),
                    ),
                  ),
                ),
              ),
            // 7. Optional top banner.
            if (showBanner)
              Positioned(
                left: 12,
                right: 12,
                top: topPadding + 12,
                child: _TopBanner(t: t, gift: gift, look: look, sender: sender, recipient: recipient, count: count),
              ),
          ],
        );
      },
    );
  }
}

/// The gift with bloom glow, rim light and a shine sweep (soft edges for picture art).
double? _sheenAt(double t) => t >= 0.34 && t <= 0.58 ? -0.3 + 1.6 * _interval(t, 0.34, 0.58) : null;

/// Gift artwork: soft-edged picture art or a plain cut-out.
Widget _artFor(GiftItem gift) => gift.isSceneArt ? _SoftEdges(child: _GiftArt(gift: gift)) : _GiftArt(gift: gift);

class _Hero3D extends StatelessWidget {
  final _Look look;
  final double t;
  final double seconds;
  final double width;
  final double height;
  final Widget art;

  /// Shine sweep over the whole art (off when the art draws its own, e.g. the rocket).
  final bool sheen;

  const _Hero3D({
    required this.look,
    required this.t,
    required this.seconds,
    required this.width,
    required this.height,
    required this.art,
    this.sheen = true,
  });

  @override
  Widget build(BuildContext context) {
    final pulse = 0.85 + 0.15 * sin(seconds * 2 * pi * 1.1);
    final sheen = this.sheen ? _sheenAt(t) : null;

    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Rim light / aura
        Container(
          width: width * 1.35,
          height: height * 1.35,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                look.palette[0].withValues(alpha: 0.5 * pulse),
                look.palette[1].withValues(alpha: 0.15 * pulse),
                Colors.transparent,
              ],
              stops: const [0, 0.5, 1],
            ),
          ),
        ),
        // Bloom: blurred copy behind the artwork
        Opacity(
          opacity: 0.6 * pulse,
          child: Transform.scale(
            scale: 1.07,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: SizedBox(width: width, height: height, child: art),
            ),
          ),
        ),
        SizedBox(
          width: width,
          height: height,
          child: _Sheen(position: sheen, child: art),
        ),
      ],
    );
  }
}

/// Mirrored, fading copy of the gift on the glossy floor.
class _Reflection extends StatelessWidget {
  final Widget child;
  final double aspectRatio;
  final double opacity;
  const _Reflection({required this.child, required this.aspectRatio, required this.opacity});

  @override
  Widget build(BuildContext context) {
    if (opacity <= 0) return const SizedBox.shrink();
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Colors.transparent],
        ).createShader,
        child: Transform(
          alignment: Alignment.topCenter,
          transform: Matrix4.diagonal3Values(1, -1, 1),
          child: OverflowBox(
            alignment: Alignment.topCenter,
            maxHeight: double.infinity,
            child: AspectRatio(aspectRatio: aspectRatio, child: child),
          ),
        ),
      ),
    );
  }
}

/// A cut-out rocket image, where its engine nozzle is and which way its nose points.
class _RocketRig {
  final String asset;
  final double aspectRatio;

  /// Engine nozzle position inside the image (fractions of width / height).
  final Offset nozzle;

  /// Screen angle the nose points to in the image (radians, y down).
  final double noseAngle;

  const _RocketRig({required this.asset, required this.aspectRatio, required this.nozzle, required this.noseAngle});

  /// Cut from assets/Rocket.png: 745×700, nozzle at (185, 508), nose at (733, 11).
  static const galaxy = _RocketRig(
    asset: AppAssets.gift3dRocketBody,
    aspectRatio: 745 / 700,
    nozzle: Offset(185 / 745, 508 / 700),
    noseAngle: -0.7366,
  );
}

/// The rocket with a live flame behind it, a barrel roll around its long axis and a
/// shine sweep across the hull.
class _RocketArt extends StatelessWidget {
  final _RocketRig rig;
  final double t;
  final double seconds;
  final double roll;
  final double width;
  final double height;

  const _RocketArt({
    required this.rig,
    required this.t,
    required this.seconds,
    required this.roll,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    // Full power while launching and while flying to the host, cruising in orbit.
    final thrust = 1 - 0.35 * _interval(t, 0.24, 0.32) * (1 - _interval(t, 0.66, 0.72));
    // Barrel roll: squash across the long axis as the rocket turns over.
    final across = max(0.12, cos(roll).abs());
    final rolling = Matrix4.rotationZ(rig.noseAngle)
      ..scaleByDouble(1, across, 1, 1)
      ..rotateZ(-rig.noseAngle);

    return SizedBox(
      width: width,
      height: height,
      child: Transform(
        alignment: Alignment.center,
        transform: rolling,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _FlamePainter(nozzle: rig.nozzle, angle: rig.noseAngle + pi, seconds: seconds, thrust: thrust),
              ),
            ),
            Positioned.fill(
              child: _Sheen(
                position: _sheenAt(t),
                child: Image.asset(rig.asset, fit: BoxFit.fill, filterQuality: FilterQuality.high),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Layered, flickering rocket exhaust: violet outer glow, orange body, yellow inner
/// flame, white-hot core, plus sparks streaming out of the nozzle.
class _FlamePainter extends CustomPainter {
  final Offset nozzle;
  final double angle;
  final double seconds;
  final double thrust;

  _FlamePainter({required this.nozzle, required this.angle, required this.seconds, required this.thrust});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final flicker = 1 + 0.07 * sin(seconds * 47) + 0.05 * sin(seconds * 83 + 1.3);
    final length = w * (0.38 + 0.32 * thrust) * flicker;
    final radius = w * 0.055;

    canvas.save();
    canvas.translate(nozzle.dx * w, nozzle.dy * size.height);
    canvas.rotate(angle);

    Path plume(double len, double r) => Path()
      ..moveTo(-r * 0.2, -r)
      ..quadraticBezierTo(len * 0.3, -r * 1.55, len, 0)
      ..quadraticBezierTo(len * 0.3, r * 1.55, -r * 0.2, r)
      ..close();

    void layer(double len, double r, List<Color> colors, double blur) {
      final rect = Rect.fromLTWH(0, -r * 1.6, len, r * 3.2);
      canvas.drawPath(
        plume(len, r),
        Paint()
          ..shader = LinearGradient(colors: colors).createShader(rect)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
      );
    }

    layer(length * 1.15, radius * 1.9, const [Color(0xCC7C4DFF), Color(0x662979FF), Color(0x002979FF)], radius * 0.9);
    layer(length, radius * 1.35, const [Color(0xFFFF9100), Color(0xCCFF3D00), Color(0x00FF3D00)], radius * 0.45);
    layer(length * 0.72, radius * 0.95, const [Color(0xFFFFF59D), Color(0xEEFFC400), Color(0x00FF9100)], radius * 0.25);
    layer(length * 0.4, radius * 0.5, const [Colors.white, Color(0xEEFFFDE7), Color(0x00FFFFFF)], radius * 0.12);
    // Nozzle glow
    canvas.drawCircle(
      Offset.zero,
      radius * 1.2,
      Paint()
        ..color = const Color(0xFFFFE082).withValues(alpha: 0.9)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.8),
    );
    // Sparks
    for (var i = 0; i < 14; i++) {
      final p = (seconds * (1.6 + (i % 5) * 0.25) + i * 0.137) % 1.0;
      final c = Offset(p * length * 1.1, sin(i * 2.7 + seconds * 9) * radius * (0.4 + p));
      canvas.drawCircle(
        c,
        radius * 0.14 * (1 - p) + 0.6,
        Paint()
          ..color = (i.isEven ? const Color(0xFFFFE082) : const Color(0xFFFF9100)).withValues(alpha: 1 - p)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.1),
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FlamePainter oldDelegate) => true;
}

/// Two wing images and where their shoulder joints are, in source pixels.
class _WingRig {
  final String left;
  final String right;
  final Rect leftRect;
  final Rect rightRect;
  final Size frame;
  final Alignment leftPivot;
  final Alignment rightPivot;

  const _WingRig({
    required this.left,
    required this.right,
    required this.leftRect,
    required this.rightRect,
    required this.frame,
    required this.leftPivot,
    required this.rightPivot,
  });

  double get aspectRatio => frame.width / frame.height;

  /// Cut from assets/Diamondwings.png (1322×1190); shoulders sit at the gold joints.
  static const diamond = _WingRig(
    left: AppAssets.gift3dDiamondWingsLeft,
    right: AppAssets.gift3dDiamondWingsRight,
    leftRect: Rect.fromLTWH(0, 21, 619, 792),
    rightRect: Rect.fromLTWH(619, 0, 621, 813),
    frame: Size(1240, 813),
    leftPivot: Alignment(0.95, 0.19),
    rightPivot: Alignment(-0.95, 0.21),
  );
}

/// A pair of wings flapping around their shoulders in 3D. Beats are bigger while the
/// gift is flying in / out and gentler while it hovers; the body bobs with each beat.
class _FlappingWings extends StatelessWidget {
  final _WingRig rig;
  final double t;
  final double seconds;
  final double width;
  final double height;

  const _FlappingWings({
    required this.rig,
    required this.t,
    required this.seconds,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final k = width / rig.frame.width;
    // 1 while flying (arrival / exit), 0 while hovering.
    final flying = 1 - _interval(t, 0.18, 0.32) * (1 - _interval(t, 0.66, 0.76));
    final amplitude = 0.55 + 0.4 * flying;
    final phase = seconds * 2 * pi * 1.9;
    // Fast downstroke, slower upstroke. 0 = fully open, 1 = folded back.
    final stroke = 0.5 + 0.5 * sin(phase + 0.35 * sin(phase));
    final angle = 0.08 + amplitude * stroke;
    final bob = (stroke - 0.5) * height * 0.07;

    Widget wing(String asset, Rect r, Alignment pivot, double side) {
      return Positioned(
        left: r.left * k,
        top: r.top * k,
        width: r.width * k,
        height: r.height * k,
        child: Transform(
          alignment: pivot,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0016)
            ..rotateY(side * angle)
            ..rotateZ(side * angle * 0.16),
          child: Image.asset(asset, fit: BoxFit.fill, filterQuality: FilterQuality.high),
        ),
      );
    }

    return Transform.translate(
      offset: Offset(0, bob),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            wing(rig.left, rig.leftRect, rig.leftPivot, 1),
            wing(rig.right, rig.rightRect, rig.rightPivot, -1),
          ],
        ),
      ),
    );
  }
}

/// Image from assets, or the gift's emoji when the image is missing.
class _GiftArt extends StatelessWidget {
  final GiftItem gift;
  const _GiftArt({required this.gift});

  @override
  Widget build(BuildContext context) {
    final emoji = FittedBox(
      child: Text(
        gift.icon,
        style: const TextStyle(
          fontSize: 220,
          height: 1.0,
          shadows: [Shadow(color: Color(0x88000000), blurRadius: 18, offset: Offset(0, 8))],
        ),
      ),
    );
    final path = gift.imageAssetPath;
    if (path == null || path.isEmpty) return emoji;
    return Image.asset(
      path,
      fit: gift.isSceneArt ? BoxFit.cover : BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, _, _) => emoji,
    );
  }
}

/// Fades the edges of picture-style art so it blends into the scene.
class _SoftEdges extends StatelessWidget {
  final Widget child;
  const _SoftEdges({required this.child});

  static const _fade = [Colors.transparent, Colors.white, Colors.white, Colors.transparent];

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: const LinearGradient(colors: _fade, stops: [0, 0.16, 0.84, 1]).createShader,
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _fade,
          stops: [0, 0.14, 0.86, 1],
        ).createShader,
        child: child,
      ),
    );
  }
}

/// Diagonal white shine that sweeps across the artwork once.
class _Sheen extends StatelessWidget {
  final double? position;
  final Widget child;

  const _Sheen({required this.position, required this.child});

  @override
  Widget build(BuildContext context) {
    final p = position;
    if (p == null) return child;
    return ShaderMask(
      blendMode: BlendMode.srcATop,
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: const [Colors.transparent, Color(0x99FFFFFF), Colors.transparent],
        stops: [(p - 0.12).clamp(0.0, 1.0), p.clamp(0.0, 1.0), (p + 0.12).clamp(0.0, 1.0)],
      ).createShader(bounds),
      child: child,
    );
  }
}

class _ComboCounter extends StatelessWidget {
  final int count;
  final double entry;
  final double punch;

  const _ComboCounter({required this.count, required this.entry, required this.punch});

  @override
  Widget build(BuildContext context) {
    final scale = Curves.elasticOut.transform(entry) * (1 + 0.4 * sin(punch * pi));
    return Transform.scale(
      scale: scale,
      alignment: Alignment.bottomLeft,
      child: Transform.rotate(
        angle: -0.12,
        child: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFDE7), Color(0xFFFFD600), Color(0xFFFF8F00)],
          ).createShader,
          child: Text(
            'x$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 44,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              height: 1.0,
              shadows: [Shadow(color: Color(0xCC000000), blurRadius: 10, offset: Offset(0, 3))],
            ),
          ),
        ),
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  final String sender;
  final String recipient;
  final GiftItem gift;
  final _Look look;

  const _Caption({
    required this.sender,
    this.recipient = '',
    required this.gift,
    required this.look,
  });

  @override
  Widget build(BuildContext context) {
    final highlight = look.palette[2] == Colors.white ? const Color(0xFFFFD54F) : look.palette[2];
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 7, 16, 7),
      decoration: BoxDecoration(
        color: const Color(0xCC0B0E26),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: look.palette[0].withValues(alpha: 0.9), width: 1.3),
        boxShadow: [BoxShadow(color: look.palette[0].withValues(alpha: 0.5), blurRadius: 16)],
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: sender,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
            ),
            const TextSpan(
              text: '  sent  ',
              style: TextStyle(color: Color(0xFFC5CCE0)),
            ),
            TextSpan(
              text: gift.name,
              style: TextStyle(color: highlight, fontWeight: FontWeight.w800),
            ),
            if (recipient.isNotEmpty) ...[
              const TextSpan(
                text: '  to  ',
                style: TextStyle(color: Color(0xFFC5CCE0)),
              ),
              TextSpan(
                text: recipient,
                style: const TextStyle(color: Color(0xFFFFD54F), fontWeight: FontWeight.w800),
              ),
            ],
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}

class _TopBanner extends StatelessWidget {
  final double t;
  final GiftItem gift;
  final _Look look;
  final String sender;
  final String recipient;
  final int count;

  const _TopBanner({
    required this.t,
    required this.gift,
    required this.look,
    required this.sender,
    required this.recipient,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final inP = Curves.easeOutBack.transform(_interval(t, 0.03, 0.12));
    final outP = Curves.easeIn.transform(_interval(t, 0.86, 0.95));
    final dx = (-1 + inP) * 320 - outP * 320;

    return Opacity(
      opacity: (inP * (1 - outP)).clamp(0.0, 1.0),
      child: Transform.translate(
        offset: Offset(dx, 0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.fromLTRB(5, 5, 14, 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [look.palette[0].withValues(alpha: 0.85), const Color(0xE61A1033)]),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: look.palette[2].withValues(alpha: 0.8), width: 1.2),
              boxShadow: [BoxShadow(color: look.palette[0].withValues(alpha: 0.45), blurRadius: 14)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0x33FFFFFF)),
                  child: ClipOval(child: _GiftArt(gift: gift)),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$sender sent ${gift.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        recipient.isEmpty
                            ? '💎 ${gift.diamonds * count}'
                            : 'to $recipient  ·  💎 ${gift.diamonds * count}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Color(0xFFFFE082), fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'x$count',
                  style: const TextStyle(
                    color: Color(0xFFFFD600),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// STAGE PAINTER
// =============================================================================

typedef _StageArgs = ({
  double t,
  double seconds,
  double env,
  _Camera camera,
  Offset heroCenter,
  double heroW,
  double floorY,
  double floorX,
  Offset stage,
  Offset dest,
  List<Offset> trail,

  /// 0 = none, 1 = wing-tip sparkles, 2 = rocket exhaust.
  int trailKind,
  bool floor,
});

/// Draws the 3D scene. The back pass paints everything behind the gift (nebula, light
/// rays, floor, far particles); the front pass paints near particles, flash, lens flare
/// and trails — so particles really pass in front of and behind the gift.
class _StagePainter extends CustomPainter {
  final _StageArgs args;
  final _Look look;
  final List<_Mote> motes;
  final bool front;

  _StagePainter({required this.args, required this.look, required this.motes, required this.front});

  static const _confetti = [
    Color(0xFFFF4081),
    Color(0xFFFFD54F),
    Color(0xFF40C4FF),
    Color(0xFF69F0AE),
    Color(0xFFB388FF),
    Color(0xFFFF9100),
  ];

  double get t => args.t;
  double get env => args.env;

  Paint _glow(Color color, double blur) => Paint()
    ..color = color
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

  @override
  void paint(Canvas canvas, Size size) {
    if (env <= 0) return;
    if (!front) {
      _nebula(canvas, size);
      _lightRays(canvas, size);
      if (args.floor) _floor(canvas);
      if (args.trailKind == 2) _exhaustTrail(canvas);
    }
    _drawMotes(canvas);
    if (look.fireworks) _fireworks(canvas);
    if (front) {
      _impactFlash(canvas);
      _lensFlare(canvas, size);
      _arrivalStreak(canvas);
      if (args.trailKind == 1) _flightTrail(canvas);
      _exitTrail(canvas, size);
      _hostBurst(canvas);
    }
  }

  // ------------------------------------------------------------- background

  void _nebula(Canvas canvas, Size size) {
    // Two big drifting colour clouds give the scene depth.
    final s = args.seconds;
    final c = args.stage;
    canvas.drawCircle(
      c + Offset(sin(s * 0.4) * size.width * 0.18, -size.height * 0.08),
      size.shortestSide * 0.55,
      _glow(look.palette[0].withValues(alpha: 0.22 * env), size.shortestSide * 0.25),
    );
    canvas.drawCircle(
      c + Offset(-cos(s * 0.35) * size.width * 0.2, size.height * 0.1),
      size.shortestSide * 0.5,
      _glow(look.palette[1].withValues(alpha: 0.18 * env), size.shortestSide * 0.25),
    );
  }

  void _lightRays(Canvas canvas, Size size) {
    final reveal = _interval(t, 0.18, 0.4);
    if (reveal <= 0) return;
    const rays = 16;
    final c = args.heroCenter;
    final maxR = size.longestSide * 0.75;
    final rotation = args.seconds * 0.18 + args.camera.yaw;
    for (var i = 0; i < rays; i++) {
      final ang = rotation + i / rays * 2 * pi;
      final half = pi / rays * (0.25 + 0.15 * sin(args.seconds * 2 + i));
      final color = i.isEven ? look.palette[0] : look.palette[2];
      canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy)
          ..lineTo(c.dx + cos(ang - half) * maxR, c.dy + sin(ang - half) * maxR)
          ..lineTo(c.dx + cos(ang + half) * maxR, c.dy + sin(ang + half) * maxR)
          ..close(),
        Paint()
          ..shader = RadialGradient(
            colors: [
              color.withValues(alpha: 0.28 * reveal * env),
              color.withValues(alpha: 0),
            ],
          ).createShader(Rect.fromCircle(center: c, radius: maxR))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }
  }

  void _floor(Canvas canvas) {
    // Glossy glowing floor ellipse under the gift, seen in perspective.
    final y = args.floorY;
    final w = args.heroW * 1.25;
    final floor = Rect.fromCenter(center: Offset(args.floorX, y), width: w, height: w * 0.22);
    canvas.drawOval(
      floor,
      Paint()
        ..shader = RadialGradient(
          colors: [
            look.palette[0].withValues(alpha: 0.55 * env),
            look.palette[1].withValues(alpha: 0.15 * env),
            Colors.transparent,
          ],
          stops: const [0, 0.55, 1],
        ).createShader(floor),
    );
    canvas.drawOval(
      floor.deflate(w * 0.08),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = look.palette[2].withValues(alpha: 0.55 * env)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    // Shockwave ripples across the floor at impact.
    for (var k = 0; k < 3; k++) {
      final p = _interval(t, 0.22 + k * 0.05, 0.5 + k * 0.05);
      if (p <= 0 || p >= 1) continue;
      final rw = w * (0.4 + Curves.easeOut.transform(p) * 1.9);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(args.floorX, y), width: rw, height: rw * 0.22),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5 * (1 - p) + 0.5
          ..color = (k.isEven ? look.palette[0] : look.palette[2]).withValues(alpha: (1 - p) * 0.9)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }
  }

  // ------------------------------------------------------------- particles

  void _drawMotes(Canvas canvas) {
    final cam = args.camera;
    final visible = <(_Mote, _Projected, double)>[];
    for (final m in motes) {
      final p = m.position(t, args.seconds);
      final pr = cam.project(p.x, p.y, p.z);
      if (pr == null) continue;
      if ((pr.depth < 0) != front) continue;
      // Depth fog: far particles fade out; particles about to touch the lens fade too.
      final fog = (1.2 - pr.depth.clamp(0.0, 2.0) * 0.35).clamp(0.25, 1.0);
      final nearFade = ((pr.depth + 1.3) / 0.5).clamp(0.0, 1.0);
      visible.add((m, pr, p.fade * fog * nearFade * env));
    }
    visible.sort((a, b) => b.$2.depth.compareTo(a.$2.depth)); // far first
    final unit = (args.heroW / 220).clamp(0.7, 1.6);
    for (final (m, pr, alpha) in visible) {
      if (alpha <= 0.01) continue;
      // 1.0 at the gift's depth; capped so near particles never balloon.
      final perspective = min(pr.scale / cam.focal * _Camera.restDistance, 2.2);
      final sizePx = (4 + m.size * 9) * perspective * unit;
      // Depth of field: particles close to the camera are blurred.
      final dof = pr.depth < -0.5 ? (-pr.depth - 0.5) * 6 : 0.0;
      _drawMote(canvas, m, pr.point, sizePx, alpha, dof);
    }
  }

  void _drawMote(Canvas canvas, _Mote m, Offset c, double s, double a, double blur) {
    final color = look.palette[m.color];
    final spin = args.seconds * m.spin + m.phase * 6;
    final soft = blur > 0 ? MaskFilter.blur(BlurStyle.normal, blur) : null;
    switch (m.kind) {
      case _MoteKind.sparkle:
      case _MoteKind.star:
        final tw = 0.55 + 0.45 * sin(args.seconds * 5 + m.phase * 12);
        final r = s * (m.kind == _MoteKind.star ? 1.3 : 0.9) * tw;
        canvas.drawCircle(c, r * 0.9, _glow(color.withValues(alpha: 0.6 * a), r + blur));
        final path = Path()
          ..moveTo(c.dx, c.dy - r)
          ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
          ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
          ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
          ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
          ..close();
        canvas.drawPath(path, Paint()..color = Colors.white.withValues(alpha: a));
      case _MoteKind.ember:
        canvas.drawCircle(c, s * 0.9, _glow(color.withValues(alpha: 0.8 * a), s + blur));
        canvas.drawCircle(c, s * 0.3, Paint()..color = Colors.white.withValues(alpha: a));
      case _MoteKind.bubble:
        canvas.drawCircle(
          c,
          s,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = max(1, s * 0.12)
            ..color = color.withValues(alpha: 0.85 * a)
            ..maskFilter = soft,
        );
        canvas.drawCircle(
          c.translate(-s * 0.35, -s * 0.35),
          s * 0.22,
          Paint()..color = Colors.white.withValues(alpha: a),
        );
      case _MoteKind.heart:
        final path = Path()
          ..moveTo(c.dx, c.dy + s * 0.35)
          ..cubicTo(c.dx - s * 1.1, c.dy - s * 0.35, c.dx - s * 0.45, c.dy - s, c.dx, c.dy - s * 0.45)
          ..cubicTo(c.dx + s * 0.45, c.dy - s, c.dx + s * 1.1, c.dy - s * 0.35, c.dx, c.dy + s * 0.35)
          ..close();
        canvas.drawPath(path, _glow(color.withValues(alpha: 0.55 * a), s * 0.6 + blur));
        canvas.drawPath(
          path,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.lerp(color, Colors.white, 0.45)!.withValues(alpha: a),
                color.withValues(alpha: a),
              ],
            ).createShader(Rect.fromCircle(center: c, radius: s))
            ..maskFilter = soft,
        );
      case _MoteKind.shard:
        // Faceted crystal shard turning in 3D.
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.rotate(spin);
        canvas.scale(0.35 + 0.65 * cos(spin * 1.1).abs(), 1);
        final shard = Path()
          ..moveTo(0, -s * 1.4)
          ..lineTo(s * 0.55, 0)
          ..lineTo(0, s * 1.4)
          ..lineTo(-s * 0.55, 0)
          ..close();
        canvas.drawPath(shard, _glow(color.withValues(alpha: 0.5 * a), s * 0.8 + blur));
        canvas.drawPath(
          shard,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: a),
                color.withValues(alpha: 0.85 * a),
                Colors.white.withValues(alpha: 0.6 * a),
              ],
            ).createShader(Rect.fromCenter(center: Offset.zero, width: s * 1.1, height: s * 2.8))
            ..maskFilter = soft,
        );
        canvas.drawLine(
          Offset(0, -s * 1.3),
          Offset(0, s * 1.3),
          Paint()
            ..color = Colors.white.withValues(alpha: 0.8 * a)
            ..strokeWidth = max(0.8, s * 0.08),
        );
        canvas.restore();
      case _MoteKind.petal:
      case _MoteKind.feather:
      case _MoteKind.confetti:
        canvas.save();
        canvas.translate(c.dx, c.dy);
        canvas.rotate(spin);
        // 3D flutter: squash one axis as the piece turns over.
        canvas.scale(1, 0.35 + 0.65 * cos(spin * 1.3).abs());
        final rect = switch (m.kind) {
          _MoteKind.feather => Rect.fromCenter(center: Offset.zero, width: s * 0.6, height: s * 1.8),
          _MoteKind.confetti => Rect.fromCenter(center: Offset.zero, width: s * 1.1, height: s * 0.55),
          _ => Rect.fromCenter(center: Offset.zero, width: s * 1.6, height: s),
        };
        final fill = switch (m.kind) {
          _MoteKind.feather => Colors.white,
          _MoteKind.confetti => _confetti[(m.phase * 6).floor() % 6],
          _ => color,
        };
        final paint = Paint()
          ..shader = LinearGradient(
            colors: [
              Color.lerp(fill, Colors.white, 0.35)!.withValues(alpha: a),
              fill.withValues(alpha: a),
            ],
          ).createShader(rect)
          ..maskFilter = soft;
        if (m.kind == _MoteKind.confetti) {
          canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(s * 0.15)), paint);
        } else {
          canvas.drawOval(rect, paint);
        }
        canvas.restore();
    }
  }

  void _fireworks(Canvas canvas) {
    // Three 3D bursts at different depths (some behind the gift, some in front).
    const origins = [(-0.9, -0.55, 0.6), (0.95, -0.7, -0.5), (0.1, -1.05, 0.9)];
    for (var k = 0; k < origins.length; k++) {
      final local = _interval(t, 0.5 + k * 0.06, 0.74 + k * 0.06);
      if (local <= 0 || local >= 1) continue;
      final (ox, oy, oz) = origins[k];
      if ((oz < 0) != front) continue;
      final e = Curves.easeOutCubic.transform(local);
      final color = _confetti[(k * 2 + 1) % _confetti.length];
      for (var j = 0; j < 26; j++) {
        final theta = j / 26 * 2 * pi;
        final r = e * 0.55;
        final head = args.camera.project(ox + cos(theta) * r, oy + sin(theta) * r + local * local * 0.15, oz);
        final tail = args.camera.project(ox + cos(theta) * max(0.0, r - 0.1), oy + sin(theta) * max(0.0, r - 0.1), oz);
        if (head == null || tail == null) continue;
        canvas.drawLine(
          tail.point,
          head.point,
          Paint()
            ..color = (j.isEven ? color : look.palette[2]).withValues(alpha: (1 - local) * env)
            ..strokeWidth = 2.2
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  // ------------------------------------------------------------- front effects

  void _impactFlash(Canvas canvas) {
    final p = _interval(t, 0.22, 0.32);
    if (p <= 0 || p >= 1) return;
    canvas.drawCircle(args.heroCenter, args.heroW * 0.75, _glow(Colors.white.withValues(alpha: 0.5 * (1 - p)), 40));
  }

  void _lensFlare(Canvas canvas, Size size) {
    // Anamorphic streak + ghosts during the finale.
    final p = _interval(t, 0.55, 0.75);
    if (p <= 0 || p >= 1) return;
    final a = sin(p * pi) * env;
    final light = args.heroCenter.translate(args.heroW * 0.18, -args.heroW * 0.22);
    final streak = Rect.fromCenter(center: light, width: size.width * 1.2, height: 6);
    canvas.drawRect(
      streak,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.transparent,
            look.palette[2].withValues(alpha: 0.85 * a),
            Colors.transparent,
          ],
        ).createShader(streak)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(light, 14, _glow(Colors.white.withValues(alpha: a), 10));
    final screenCenter = size.center(Offset.zero);
    for (var k = 1; k <= 3; k++) {
      final ghost = Offset.lerp(light, screenCenter * 2 - light, k * 0.28)!;
      canvas.drawCircle(ghost, 10.0 + k * 9, _glow(look.palette[k % 3].withValues(alpha: 0.22 * a), 6));
    }
  }

  void _arrivalStreak(Canvas canvas) {
    final p = _interval(t, 0.0, 0.24);
    if (p <= 0 || p >= 1) return;
    for (var k = 1; k <= 10; k++) {
      final back = (t - k * 0.012).clamp(0.0, 1.0);
      final w = _giftWorld(back, look.arrival);
      final pr = args.camera.project(w.x, w.y, w.z);
      if (pr == null) continue;
      final fade = (1 - k / 10) * (1 - p);
      canvas.drawCircle(pr.point, 14 * fade + 2, _glow(look.palette[k % 3].withValues(alpha: 0.6 * fade), 10));
    }
  }

  void _exhaustTrail(Canvas canvas) {
    // Smoke puffs that grow and fade, with glowing embers close to the nozzle.
    final unit = (args.heroW / 260).clamp(0.6, 1.6);
    final n = args.trail.length;
    for (var k = n - 1; k >= 0; k--) {
      final c = args.trail[k];
      final fade = (1 - k / n) * env;
      final smoke = Color.lerp(look.palette[1], const Color(0xFFB0BEC5), k / n)!;
      canvas.drawCircle(c, (6 + k * 2.4) * unit, _glow(smoke.withValues(alpha: 0.22 * fade), 10 * unit));
      if (k < n * 0.6) {
        final ember = k < 4 ? const Color(0xFFFFE082) : const Color(0xFFFF9100);
        canvas.drawCircle(
          c,
          (6 - k * 0.45).clamp(1.0, 6.0) * unit,
          _glow(ember.withValues(alpha: 0.75 * fade), 6 * unit),
        );
      }
    }
  }

  void _flightTrail(Canvas canvas) {
    // Sparkle streams from both wing tips while the wings swoop around.
    final tip = args.heroW * 0.42;
    for (var k = 0; k < args.trail.length; k++) {
      final fade = (1 - k / args.trail.length) * env;
      for (final side in [-1.0, 1.0]) {
        final c = args.trail[k] + Offset(side * tip, -args.heroW * 0.08);
        canvas.drawCircle(c, 7 * fade + 1, _glow(look.palette[k % 3].withValues(alpha: 0.65 * fade), 7));
        canvas.drawCircle(c, 1.8 * fade, Paint()..color = Colors.white.withValues(alpha: fade));
      }
    }
  }

  void _exitTrail(Canvas canvas, Size size) {
    final x = _interval(t, 0.72, 0.92);
    if (x <= 0 || x >= 1) return;
    final eased = Curves.easeInCubic.transform(x);
    for (var k = 0; k < 16; k++) {
      final back = (eased - k * 0.035).clamp(0.0, 1.0);
      final c = _exitPoint(back, args.stage, args.dest, size);
      final fade = 1 - k / 16;
      canvas.drawCircle(c, (9 - k * 0.45) * fade + 1, _glow(look.palette[k % 3].withValues(alpha: 0.7 * fade), 8));
      canvas.drawCircle(c, 2.2 * fade, Paint()..color = Colors.white.withValues(alpha: fade));
    }
  }

  void _hostBurst(Canvas canvas) {
    final p = _interval(t, 0.90, 1.0);
    if (p <= 0 || p >= 1) return;
    final e = Curves.easeOut.transform(p);
    final dest = args.dest;
    canvas.drawCircle(dest, 30 + e * 30, _glow(look.palette[0].withValues(alpha: 0.6 * (1 - p)), 20));
    for (var j = 0; j < 16; j++) {
      final dir = Offset(cos(j / 16 * 2 * pi), sin(j / 16 * 2 * pi));
      final r1 = 10 + e * 70;
      canvas.drawLine(
        dest + dir * max(0.0, r1 - 22),
        dest + dir * r1,
        Paint()
          ..color = look.palette[j % 3].withValues(alpha: 1 - p)
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StagePainter oldDelegate) => true;
}
