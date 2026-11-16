import 'package:flutter/material.dart';

/// Renders dynamic visual AR overlays and atmospheric effects directly on top
/// of the video viewfinder / video player matching the selected filter.
class VideoFilterOverlay extends StatelessWidget {
  final String overlayType;
  final double intensity;

  const VideoFilterOverlay({
    super.key,
    required this.overlayType,
    this.intensity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    if (overlayType == 'none' || intensity <= 0.05) {
      return const SizedBox.shrink();
    }

    switch (overlayType) {
      case 'beauty_glow':
        return _buildBeautyGlow();
      case 'makeup_glam':
        return _buildMakeupGlam();
      case 'animal_whiskers':
        return _buildAnimalWhiskers();
      case 'accessories_3d':
        return _build3DAccessories();
      case 'cinematic_bars':
        return _buildCinematicBars();
      case 'aesthetic_haze':
        return _buildAestheticHaze();
      case 'cartoon_pop':
        return _buildCartoonPop();
      case 'portrait_bokeh':
        return _buildPortraitBokeh();
      case 'vhs_camcorder':
        return _buildVhsCamcorder();
      case 'neon_pulse':
        return _buildNeonPulse();
      case 'fantasy_sparkles':
        return _buildFantasySparkles();
      case 'bw_grain':
        return _buildBwGrain();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBeautyGlow() {
    return IgnorePointer(
      child: Opacity(
        opacity: (0.45 * intensity).clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.85,
              colors: [
                Colors.transparent,
                const Color(0xFFFFD1DC).withValues(alpha: 0.15),
                const Color(0xFFFF8AE6).withValues(alpha: 0.35),
              ],
              stops: const [0.55, 0.8, 1.0],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMakeupGlam() {
    return IgnorePointer(
      child: Opacity(
        opacity: (0.5 * intensity).clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, 0.2),
              radius: 0.9,
              colors: [
                Colors.transparent,
                const Color(0xFFFF2A85).withValues(alpha: 0.18),
                const Color(0xFF9D4EDD).withValues(alpha: 0.30),
              ],
              stops: const [0.5, 0.8, 1.0],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimalWhiskers() {
    return IgnorePointer(
      child: Opacity(
        opacity: (0.95 * intensity).clamp(0.0, 1.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cute cat / puppy ears at upper thirds
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.rotate(
                    angle: -0.25,
                    child: const Text('🐱', style: TextStyle(fontSize: 48)),
                  ),
                  const SizedBox(width: 80),
                  Transform.rotate(
                    angle: 0.25,
                    child: const Text('✨', style: TextStyle(fontSize: 36)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Whiskers and heart nose
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('彡', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 14),
                  Container(
                    width: 18,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4081),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(color: Color(0x88FF4081), blurRadius: 8),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text('ミ', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              // Cheeks blush
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0x66FF80AB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(width: 70),
                  Container(
                    width: 32,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0x66FF80AB),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _build3DAccessories() {
    return IgnorePointer(
      child: Opacity(
        opacity: (0.95 * intensity).clamp(0.0, 1.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cyberpunk Neon Sunglasses
              Container(
                width: 190,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF00E5FF), width: 2.2),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xCC00E5FF),
                      Color(0xCC9D4EDD),
                      Color(0xCCFF2A85),
                    ],
                  ),
                  boxShadow: const [
                    BoxShadow(color: Color(0x9900E5FF), blurRadius: 18, spreadRadius: 2),
                    BoxShadow(color: Color(0x66FF2A85), blurRadius: 12),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(width: 70, height: 32, decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10))),
                    Container(width: 8, height: 4, color: const Color(0xFF00E5FF)),
                    Container(width: 70, height: 32, decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10))),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              // Cyberpunk badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFFC00), width: 1),
                ),
                child: const Text(
                  'CYBER 2077 // 3D AR',
                  style: TextStyle(color: Color(0xFFFFFC00), fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCinematicBars() {
    return IgnorePointer(
      child: Column(
        children: [
          // Top Letterbox Bar
          Container(
            height: 38 * intensity,
            width: double.infinity,
            color: Colors.black,
          ),
          const Spacer(),
          // Bottom Letterbox Bar
          Container(
            height: 38 * intensity,
            width: double.infinity,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildAestheticHaze() {
    return IgnorePointer(
      child: Opacity(
        opacity: (0.45 * intensity).clamp(0.0, 1.0),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color(0x66FFE082),
                Color(0x33FFAB91),
                Colors.transparent,
                Color(0x22CE93D8),
              ],
              stops: [0.0, 0.35, 0.7, 1.0],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCartoonPop() {
    return IgnorePointer(
      child: Opacity(
        opacity: (0.35 * intensity).clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 3.0),
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.9,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.4),
              ],
              stops: const [0.7, 1.0],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPortraitBokeh() {
    return IgnorePointer(
      child: Opacity(
        opacity: (0.6 * intensity).clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.7,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.25),
                Colors.black.withValues(alpha: 0.65),
              ],
              stops: const [0.45, 0.75, 1.0],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVhsCamcorder() {
    return IgnorePointer(
      child: Opacity(
        opacity: (0.9 * intensity).clamp(0.0, 1.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Scan lines simulation
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: List.generate(
                    40,
                    (i) => i.isEven ? Colors.black.withValues(alpha: 0.08) : Colors.transparent,
                  ),
                ),
              ),
            ),
            // VHS UI elements
            Positioned(
              top: 18,
              left: 18,
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'REC',
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                  ),
                ],
              ),
            ),
            const Positioned(
              top: 18,
              right: 18,
              child: Text(
                'SP  0:00:15',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.2),
              ),
            ),
            const Positioned(
              bottom: 18,
              left: 18,
              child: Text(
                'PLAY ►',
                style: TextStyle(color: Color(0xFF00E676), fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.2),
              ),
            ),
            Positioned(
              bottom: 18,
              right: 18,
              child: Text(
                'OCT 24 1998',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNeonPulse() {
    return IgnorePointer(
      child: Opacity(
        opacity: (0.75 * intensity).clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFFF2DC0), width: 2.5),
            boxShadow: const [
              BoxShadow(color: Color(0x99FF2DC0), blurRadius: 16, spreadRadius: 2),
              BoxShadow(color: Color(0x6600E5FF), blurRadius: 10, spreadRadius: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFantasySparkles() {
    return IgnorePointer(
      child: Opacity(
        opacity: (0.9 * intensity).clamp(0.0, 1.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Ethereal ambient gradient
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    Color(0x22B388FF),
                    Colors.transparent,
                    Color(0x447C4DFF),
                  ],
                ),
              ),
            ),
            // Floating stars and sparkles
            const Positioned(top: 60, left: 30, child: Text('✨', style: TextStyle(fontSize: 26))),
            const Positioned(top: 140, right: 40, child: Text('⭐', style: TextStyle(fontSize: 20))),
            const Positioned(top: 240, left: 60, child: Text('💫', style: TextStyle(fontSize: 24))),
            const Positioned(bottom: 160, right: 30, child: Text('✨', style: TextStyle(fontSize: 30))),
            const Positioned(bottom: 90, left: 45, child: Text('✦', style: TextStyle(color: Color(0xFFFFD54F), fontSize: 22))),
            const Positioned(bottom: 220, left: 140, child: Text('🪄', style: TextStyle(fontSize: 20))),
          ],
        ),
      ),
    );
  }

  Widget _buildBwGrain() {
    return IgnorePointer(
      child: Opacity(
        opacity: (0.35 * intensity).clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.9,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
