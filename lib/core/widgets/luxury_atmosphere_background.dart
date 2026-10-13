import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_assets.dart';

/// Ultra-attractive luxury atmosphere background with vibrant cyber yellow,
/// neon magenta, electric cyan aurora orbs, animated sweeping stage light beams,
/// and twinkling golden stardust particles over the golden arena stage background.
class LuxuryAtmosphereBackground extends StatefulWidget {
  final Widget? child;
  final bool showParticles;
  final bool showLightBeams;
  final Color primaryGlowColor;
  final Color secondaryGlowColor;
  final Color accentGlowColor;
  final String? backgroundImageAsset;
  final bool showBackgroundImage;
  final double backgroundImageOpacity;

  const LuxuryAtmosphereBackground({
    super.key,
    this.child,
    this.showParticles = true,
    this.showLightBeams = true,
    this.primaryGlowColor = const Color(0xFFFFD600), // Electric Cyber Yellow
    this.secondaryGlowColor = const Color(0xFFFF1744), // Neon Magenta
    this.accentGlowColor = const Color(0xFF00E5FF), // Electric Cyan
    this.backgroundImageAsset,
    this.showBackgroundImage = false,
    this.backgroundImageOpacity = 0.95,
  });

  @override
  State<LuxuryAtmosphereBackground> createState() => _LuxuryAtmosphereBackgroundState();
}

class _LuxuryAtmosphereBackgroundState extends State<LuxuryAtmosphereBackground> with TickerProviderStateMixin {
  late final AnimationController _auroraController;
  late final AnimationController _twinkleController;
  late final AnimationController _beamController;

  @override
  void initState() {
    super.initState();

    // 1. Slow rhythmic aurora motion
    _auroraController = AnimationController(vsync: this, duration: const Duration(seconds: 8))..repeat(reverse: true);

    // 2. Sparkling stardust twinkle
    _twinkleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))
      ..repeat(reverse: true);

    // 3. Sweeping concert / stadium stage light beams
    _beamController = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _auroraController.dispose();
    _twinkleController.dispose();
    _beamController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Deep Obsidian Velvet Base
        const ColoredBox(color: Color(0xFF070709)),

        // 1b. Luxury Golden Arena Stage Background Image (Crown + Stage Podium)
        if (widget.showBackgroundImage)
          Positioned.fill(
            child: Opacity(
              opacity: widget.backgroundImageOpacity.clamp(0.0, 1.0),
              child: Image.asset(
                widget.backgroundImageAsset ?? AppAssets.pkBattleBg,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
              ),
            ),
          ),

        // 2. Multi-Orb Dynamic Animated Aurora Glows (Vibrant & Rich)
        RepaintBoundary(
          child: AnimatedBuilder(
            animation: _auroraController,
            builder: (context, child) {
              final t = _auroraController.value;
              final dx1 = sin(t * pi * 2) * 35.0;
              final dy1 = cos(t * pi * 2) * 45.0;
              final dx2 = cos(t * pi * 2) * 40.0;
              final dy2 = sin(t * pi * 2) * 30.0;
              final pulseScale = 1.0 + sin(t * pi) * 0.18;
              final glowMultiplier = widget.showBackgroundImage ? 0.25 : 1.0;

              return Stack(
                fit: StackFit.expand,
                children: [
                  // Top-Left Large Cyber Yellow & Gold Plasma Orb
                  Positioned(
                    top: -60 + dy1,
                    left: -50 + dx1,
                    child: Transform.scale(
                      scale: pulseScale,
                      child: Container(
                        width: 360,
                        height: 360,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              widget.primaryGlowColor.withValues(alpha: 0.46 * glowMultiplier),
                              const Color(0xFFFF9100).withValues(alpha: 0.28 * glowMultiplier),
                              widget.primaryGlowColor.withValues(alpha: 0.10 * glowMultiplier),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.35, 0.70, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Top-Right Vibrant Neon Magenta & Fuchsia Flare
                  Positioned(
                    top: 70 + dy2,
                    right: -60 + dx2,
                    child: Transform.scale(
                      scale: 1.18 - (t * 0.16),
                      child: Container(
                        width: 360,
                        height: 360,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              widget.secondaryGlowColor.withValues(alpha: 0.40 * glowMultiplier),
                              const Color(0xFFE040FB).withValues(alpha: 0.24 * glowMultiplier),
                              widget.secondaryGlowColor.withValues(alpha: 0.08 * glowMultiplier),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.35, 0.70, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Center-Left Electric Cyan Aura Orb
                  Positioned(
                    bottom: 150 - dy1,
                    left: -50 - dx2,
                    child: Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            widget.accentGlowColor.withValues(alpha: 0.34 * glowMultiplier),
                            const Color(0xFF2979FF).withValues(alpha: 0.18 * glowMultiplier),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Bottom-Right Cyber Gold & Amber Hearth
                  Positioned(
                    bottom: -30 + dy2,
                    right: -30 + dx1,
                    child: Transform.scale(
                      scale: pulseScale,
                      child: Container(
                        width: 340,
                        height: 340,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFFFAB00).withValues(alpha: 0.38 * glowMultiplier),
                              widget.primaryGlowColor.withValues(alpha: 0.20 * glowMultiplier),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.40, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Central Stage Clashing Beam (gives intense battle energy!)
                  Positioned(
                    top: 180,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 360,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              widget.primaryGlowColor.withValues(alpha: 0.24 * glowMultiplier),
                              widget.secondaryGlowColor.withValues(alpha: 0.14 * glowMultiplier),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.50, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // 3. Sweeping Stage Light Beams (Concert / Stadium Live Aura)
        if (widget.showLightBeams)
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _beamController,
              builder: (context, child) {
                final angle = sin(_beamController.value * pi) * 0.18 - 0.09;
                return Transform.rotate(
                  angle: angle,
                  alignment: Alignment.topCenter,
                  child: CustomPaint(
                    painter: _LightBeamsPainter(beamColor: widget.primaryGlowColor.withValues(alpha: 0.11)),
                    size: Size.infinite,
                  ),
                );
              },
            ),
          ),

        // 4. Shimmering Golden Stardust & Twinkling Cyber Stars
        if (widget.showParticles)
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _twinkleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _VibrantStardustPainter(twinkleProgress: _twinkleController.value),
                  size: Size.infinite,
                );
              },
            ),
          ),

        // 5. Cinematic Radial Vignette (Enriches contrast & focus on central UI)
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.18,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.12), Colors.black.withValues(alpha: 0.50)],
              stops: const [0.0, 0.65, 1.0],
            ),
          ),
        ),

        // 6. Child Content
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

/// Painter for dynamic sweeping stage lights
class _LightBeamsPainter extends CustomPainter {
  final Color beamColor;

  _LightBeamsPainter({required this.beamColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [beamColor, beamColor.withValues(alpha: 0.02), Colors.transparent],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Left cone
    final path1 = Path()
      ..moveTo(size.width * 0.2, 0)
      ..lineTo(0, size.height * 0.85)
      ..lineTo(size.width * 0.45, size.height * 0.95)
      ..close();
    canvas.drawPath(path1, paint);

    // Right cone
    final path2 = Path()
      ..moveTo(size.width * 0.8, 0)
      ..lineTo(size.width * 0.55, size.height * 0.95)
      ..lineTo(size.width, size.height * 0.85)
      ..close();
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant _LightBeamsPainter oldDelegate) => oldDelegate.beamColor != beamColor;
}

/// Painter for twinkling golden particles and cyber stardust
class _VibrantStardustPainter extends CustomPainter {
  final double twinkleProgress;

  _VibrantStardustPainter({required this.twinkleProgress});

  static final List<_StarParticle> _stars = List.generate(64, (i) {
    final seed = (i * 137) % 1000;
    return _StarParticle(
      x: ((seed * 73) % 1000) / 1000.0,
      y: ((seed * 91) % 1000) / 1000.0,
      baseRadius: (i % 5 == 0) ? 2.4 : ((i % 2 == 0) ? 1.5 : 0.9),
      isGold: i % 3 != 0,
      phaseOffset: (seed % 100) / 100.0,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    final goldPaint = Paint()..style = PaintingStyle.fill;
    final whitePaint = Paint()..style = PaintingStyle.fill;
    final glintPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final s in _stars) {
      final pos = Offset(s.x * size.width, s.y * size.height);
      final phase = sin((twinkleProgress + s.phaseOffset) * pi * 2);
      final alpha = (0.35 + phase * 0.50).clamp(0.1, 1.0);
      final radius = s.baseRadius * (0.8 + phase * 0.40);

      if (s.isGold) {
        goldPaint.color = const Color(0xFFFFD600).withValues(alpha: alpha);
        canvas.drawCircle(pos, radius, goldPaint);

        // 4-point diamond glint on larger golden stars
        if (s.baseRadius > 2.0 && alpha > 0.55) {
          glintPaint.color = const Color(0xFFFFEA00).withValues(alpha: (alpha - 0.2).clamp(0.0, 0.9));
          glintPaint.strokeWidth = 0.9;
          final glintLen = radius * 3.2;
          canvas.drawLine(Offset(pos.dx - glintLen, pos.dy), Offset(pos.dx + glintLen, pos.dy), glintPaint);
          canvas.drawLine(Offset(pos.dx, pos.dy - glintLen), Offset(pos.dx, pos.dy + glintLen), glintPaint);
        }
      } else {
        whitePaint.color = Colors.white.withValues(alpha: alpha);
        canvas.drawCircle(pos, radius, whitePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _VibrantStardustPainter oldDelegate) => oldDelegate.twinkleProgress != twinkleProgress;
}

class _StarParticle {
  final double x;
  final double y;
  final double baseRadius;
  final bool isGold;
  final double phaseOffset;

  _StarParticle({
    required this.x,
    required this.y,
    required this.baseRadius,
    required this.isGold,
    required this.phaseOffset,
  });
}
