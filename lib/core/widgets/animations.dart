import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Shrinks slightly while pressed, then springs back — the "3D button" feel.
class Pressable extends StatefulWidget {
  const Pressable({super.key, required this.child, required this.onTap, this.scale = 0.95});

  final Widget child;
  final VoidCallback onTap;
  final double scale;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _pressed = false;

  void _set(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _set(true),
      onTapCancel: () => _set(false),
      onTapUp: (_) => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1,
        duration: Duration(milliseconds: _pressed ? 90 : 260),
        curve: _pressed ? Curves.easeOut : Curves.elasticOut,
        child: widget.child,
      ),
    );
  }
}

/// Fades and slides its child in once, after [delay] (for staggered entrances).
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = const Offset(0, 0.12),
  });

  final Widget child;
  final Duration delay;
  final Offset offset;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  late final Animation<double> _curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _timer = Timer(widget.delay, _controller.forward);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: Tween(begin: widget.offset, end: Offset.zero).animate(_curve),
        child: widget.child,
      ),
    );
  }
}

/// A band of light that sweeps across the child's opaque pixels on a loop.
class ShimmerSweep extends StatefulWidget {
  const ShimmerSweep({
    super.key,
    required this.child,
    this.period = const Duration(milliseconds: 2600),
    this.color = const Color(0xB3FFFFFF),
  });

  final Widget child;
  final Duration period;
  final Color color;

  @override
  State<ShimmerSweep> createState() => _ShimmerSweepState();
}

class _ShimmerSweepState extends State<ShimmerSweep> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: widget.period)
    ..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clear = widget.color.withValues(alpha: 0);
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) {
          // The band crosses during the first 40% of each period, then rests.
          final t = (_controller.value / 0.4).clamp(0.0, 1.0);
          return ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (rect) => LinearGradient(
              begin: const Alignment(-1, -0.4),
              end: const Alignment(1, 0.4),
              colors: [clear, widget.color, clear],
              stops: const [0.35, 0.5, 0.65],
              transform: _SlideGradient(-1.6 + t * 3.2),
            ).createShader(rect),
            child: child,
          );
        },
      ),
    );
  }
}

class _SlideGradient extends GradientTransform {
  const _SlideGradient(this.fraction);

  final double fraction;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * fraction, 0, 0);
}

/// Gentle looping scale/float — for emblems, gift boxes and glowing orbs.
class Breathing extends StatefulWidget {
  const Breathing({
    super.key,
    required this.child,
    this.scale = 0.05,
    this.float = 0,
    this.period = const Duration(milliseconds: 1800),
  });

  final Widget child;

  /// Extra scale at the peak (0.05 = 105%).
  final double scale;

  /// Vertical float distance in logical pixels.
  final double float;
  final Duration period;

  @override
  State<Breathing> createState() => _BreathingState();
}

class _BreathingState extends State<Breathing> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: widget.period)
    ..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        child: widget.child,
        builder: (context, child) {
          final wave = (math.sin(_controller.value * 2 * math.pi) + 1) / 2;
          return Transform.translate(
            offset: Offset(0, -widget.float * wave),
            child: Transform.scale(scale: 1 + widget.scale * wave, child: child),
          );
        },
      ),
    );
  }
}

/// Continuously rotates its child (spinning gradient rings).
class Spin extends StatefulWidget {
  const Spin({super.key, required this.child, this.period = const Duration(seconds: 4)});

  final Widget child;
  final Duration period;

  @override
  State<Spin> createState() => _SpinState();
}

class _SpinState extends State<Spin> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: widget.period)
    ..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: RotationTransition(turns: _controller, child: widget.child));
  }
}

/// Slow cinematic zoom-and-pan over a still frame (keeps a poster "alive").
class KenBurns extends StatefulWidget {
  const KenBurns({super.key, required this.child, this.period = const Duration(seconds: 14), this.reverse = false});

  final Widget child;
  final Duration period;

  /// Pans the opposite way (so two side-by-side panels don't move in sync).
  final bool reverse;

  @override
  State<KenBurns> createState() => _KenBurnsState();
}

class _KenBurnsState extends State<KenBurns> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: widget.period)
    ..repeat(reverse: true);
  late final Animation<double> _curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final direction = widget.reverse ? -1.0 : 1.0;
    return ClipRect(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _curve,
          child: widget.child,
          builder: (context, child) {
            final t = _curve.value;
            return Transform.scale(
              scale: 1.04 + 0.1 * t,
              alignment: Alignment(direction * (-0.6 + 1.2 * t), -0.2),
              child: child,
            );
          },
        ),
      ),
    );
  }
}
