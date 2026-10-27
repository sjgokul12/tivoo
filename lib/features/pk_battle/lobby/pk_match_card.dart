// One PK battle in the PK Home list: split profile pictures, status, viewers, Watch button and names.

import 'package:flutter/material.dart';

import '../../../core/theme/luxe_theme.dart';
import '../core/pk_models.dart';

/// ┌───────────────────────────────────────┐
/// │ [LIVE] [👤 12.4K]                     │
/// │  (left host photo)   ⚡VS⚡ (right photo)│
/// │ Priya          [ Watch ]          Anu │
/// └───────────────────────────────────────┘
class PkMatchCard extends StatelessWidget {
  final PkMatch match;
  final bool isFollowingRight;
  final VoidCallback onTap;
  final VoidCallback? onFollowTap;

  const PkMatchCard({
    super.key,
    required this.match,
    this.isFollowingRight = false,
    required this.onTap,
    this.onFollowTap,
  });

  /// Width / height of the battle card (1200 × 520).
  static const double aspectRatio = 1200 / 520;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: LayoutBuilder(
        builder: (context, c) {
          final u = c.maxWidth / 100; // 1% of the card width
          return Semantics(
            button: true,
            label: '${match.left.name} versus ${match.right.name}',
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(u * 4.5),
                  border: Border.all(color: const Color(0xFFFFD600).withValues(alpha: 0.25), width: u * 0.3),
                  boxShadow: const [
                    BoxShadow(color: Color(0x33FFC928), blurRadius: 14, offset: Offset(-2, 3)),
                    BoxShadow(color: Color(0x337B4DFF), blurRadius: 14, offset: Offset(2, 3)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(u * 4.5),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // 1. Battlers' Real Profile Pictures (Split Left / Right)
                      Row(
                        children: [
                          Expanded(
                            child: Image.asset(
                              match.left.avatarAsset,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),
                          ),
                          Expanded(
                            child: Image.asset(
                              match.right.avatarAsset,
                              fit: BoxFit.cover,
                              alignment: Alignment.topCenter,
                            ),
                          ),
                        ],
                      ),

                      // 2. Neon atmosphere tint (blue on left, pink on right)
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [const Color(0xFF1E3A8A).withValues(alpha: 0.35), Colors.transparent],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerRight,
                                  end: Alignment.centerLeft,
                                  colors: [const Color(0xFF831843).withValues(alpha: 0.35), Colors.transparent],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 3. Top & bottom dark vignette for readability
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xB3050410), Colors.transparent, Color(0xD9050410)],
                            stops: [0.0, 0.45, 1.0],
                          ),
                        ),
                      ),

                      // 4. Center vertical glowing laser divider
                      Center(
                        child: Container(
                          width: u * 0.6,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Color(0xFFFFD600), Color(0xFF00E5FF), Colors.transparent],
                            ),
                            boxShadow: const [BoxShadow(color: Color(0x88FFD600), blurRadius: 8)],
                          ),
                        ),
                      ),

                      // 5. Top Left: LIVE + viewer count
                      Positioned(
                        top: u * 3,
                        left: u * 3,
                        child: Row(
                          children: [
                            _StatusPill(match: match, u: u),
                            SizedBox(width: u * 1.5),
                            _ViewersPill(count: match.viewers, u: u),
                          ],
                        ),
                      ),

                      // 6. Center VS badge with electric bolt & 3D metallic gold gradient
                      Align(
                        alignment: const Alignment(0, -0.32),
                        child: _GoldVsBadge(u: u),
                      ),

                      // 7. Bottom Left: Left Host Name
                      Positioned(
                        left: u * 3.5,
                        bottom: u * 3,
                        child: _Name(match.left.name, u: u),
                      ),

                      // 8. Bottom Right: Right Host Name (Clean profile display without follow button)
                      Positioned(
                        right: u * 3.5,
                        bottom: u * 3,
                        child: _Name(match.right.name, u: u),
                      ),

                      // 9. Center Action Button with Yellow/Gold Tint as per existing UI
                      Align(
                        alignment: const Alignment(0, 0.78),
                        child: _ActionButton(match: match, u: u, onTap: onTap),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final PkMatch match;
  final double u;
  const _StatusPill({required this.match, required this.u});

  @override
  Widget build(BuildContext context) {
    final (label, colors) = switch (match.status) {
      PkMatchStatus.ongoing => ('LIVE', const [Color(0xFFFF3B6B), Color(0xFFE5174F)]),
      PkMatchStatus.upcoming => (match.startsAt ?? 'SOON', const [Color(0xFFFFB300), Color(0xFFFF8F00)]),
      PkMatchStatus.ended => ('ENDED', const [Color(0xFF5C6078), Color(0xFF3D4058)]),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: u * 2.4, vertical: u * 0.8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(u * 3),
        gradient: LinearGradient(colors: colors),
        boxShadow: [BoxShadow(color: colors.first.withValues(alpha: 0.45), blurRadius: 6)],
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.white, fontSize: u * 3.6, fontWeight: FontWeight.w900, letterSpacing: 0.4),
      ),
    );
  }
}

class _ViewersPill extends StatelessWidget {
  final String count;
  final double u;
  const _ViewersPill({required this.count, required this.u});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: u * 2, vertical: u * 0.8),
      decoration: BoxDecoration(
        color: const Color(0xB3000000),
        borderRadius: BorderRadius.circular(u * 3),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: u * 0.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_rounded, color: Colors.white, size: u * 4),
          SizedBox(width: u * 0.6),
          Text(
            count,
            style: TextStyle(color: Colors.white, fontSize: u * 3.6, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

/// Rich 3D metallic gold "VS" with electric lightning bolt, matching the battle arena UI.
class _GoldVsBadge extends StatelessWidget {
  final double u;
  const _GoldVsBadge({required this.u});

  @override
  Widget build(BuildContext context) {
    final width = u * 15;
    final height = width * 1.15;
    final style = TextStyle(
      fontSize: width * 0.52,
      fontWeight: FontWeight.w900,
      fontStyle: FontStyle.italic,
      letterSpacing: -1.2,
    );
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background lightning flare
          CustomPaint(size: Size(width, height), painter: _BoltPainter()),
          // Deep dark stroke for crisp outline over any photo
          Text(
            'VS',
            style: style.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = width * 0.08
                ..color = const Color(0xFF4A1A00),
              shadows: const [
                Shadow(color: Color(0xCCFF8A00), blurRadius: 16),
                Shadow(color: Color(0x99000000), blurRadius: 8, offset: Offset(0, 2)),
              ],
            ),
          ),
          // Metallic 4-stop gold gradient fill
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFFBE0), Color(0xFFFFD54A), Color(0xFFFF9800), Color(0xFFFFC107)],
              stops: [0, 0.4, 0.75, 1],
            ).createShader,
            child: Text('VS', style: style.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _BoltPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final bolt = Path()
      ..moveTo(w * 0.62, 0)
      ..lineTo(w * 0.26, h * 0.56)
      ..lineTo(w * 0.47, h * 0.56)
      ..lineTo(w * 0.34, h)
      ..lineTo(w * 0.76, h * 0.4)
      ..lineTo(w * 0.54, h * 0.4)
      ..lineTo(w * 0.74, 0)
      ..close();

    // Outer soft electric glow
    canvas.drawPath(
      bolt,
      Paint()
        ..color = const Color(0xCCFF9800)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.08),
    );

    // Inner bright gradient bolt
    canvas.drawPath(
      bolt,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF59D), Color(0xFFFFB300), Color(0xFFFF6F00)],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Name extends StatelessWidget {
  final String name;
  final double u;
  const _Name(this.name, {required this.u});

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      style: TextStyle(
        color: Colors.white,
        fontSize: u * 5,
        fontWeight: FontWeight.w800,
        shadows: const [Shadow(color: Color(0xEE000000), blurRadius: 8, offset: Offset(0, 2))],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final PkMatch match;
  final double u;
  final VoidCallback onTap;
  const _ActionButton({required this.match, required this.u, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final label = switch (match.status) {
      PkMatchStatus.ongoing => 'Watch',
      PkMatchStatus.upcoming => 'Remind',
      PkMatchStatus.ended => 'Result',
    };
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: u * 6, vertical: u * 1.8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(u * 6),
          gradient: LuxeColors.goldGradient,
          border: Border.all(color: LuxeColors.goldLight, width: u * 0.3),
          boxShadow: const [BoxShadow(color: Color(0x88FFC928), blurRadius: 14, offset: Offset(0, 3))],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: const Color(0xFF1F1400),
            fontSize: u * 4.6,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
