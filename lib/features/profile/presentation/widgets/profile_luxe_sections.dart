// Profile screen sections in the Luxe (gold + deep navy neon) style.
//
// Sizes are designed for a 390 px wide phone and scale with the screen ([profileScale]).

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/luxe_theme.dart';
import '../../../../core/widgets/custom_avatar.dart';

/// Ink used on gold surfaces.
const Color _ink = Color(0xFF1A1300);

/// Scale factor for the profile layout (1.0 on a 390 px wide phone).
double profileScale(BuildContext context) =>
    (math.min(MediaQuery.sizeOf(context).width, 680) / 390).clamp(0.86, 1.25).toDouble();

/// Subtle glass panel used for the stats card and the badges row.
BoxDecoration _glass(double radius) => BoxDecoration(
  borderRadius: BorderRadius.circular(radius),
  gradient: const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xE6151233), Color(0xE60A0920)],
  ),
  border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
);

// =============================================================================
// BACKGROUND
// =============================================================================

/// Near-black navy with violet / gold light shards down both edges and a gold arc
/// sweeping behind the header.
class ProfileBackdrop extends StatelessWidget {
  const ProfileBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0B0820), Color(0xFF070616), Color(0xFF05040F)],
            ),
          ),
        ),
        RepaintBoundary(child: CustomPaint(painter: _ProfileLightsPainter())),
      ],
    );
  }
}

class _ProfileLightsPainter extends CustomPainter {
  const _ProfileLightsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    void shard(Offset a, Offset b, double width, Color color) {
      canvas.drawLine(
        a,
        b,
        Paint()
          ..shader = LinearGradient(
            colors: [Colors.transparent, color, Colors.transparent],
          ).createShader(Rect.fromPoints(a, b))
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, width * 0.7),
      );
    }

    const violet = Color(0xCCB04DFF);
    const magenta = Color(0xAAE040FB);
    const gold = Color(0xCCFFC928);

    // Left edge
    shard(Offset(-w * 0.04, h * 0.05), Offset(w * 0.06, -h * 0.02), 18, gold);
    shard(Offset(-w * 0.05, h * 0.3), Offset(w * 0.05, h * 0.2), 14, violet);
    shard(Offset(-w * 0.04, h * 0.5), Offset(w * 0.04, h * 0.42), 12, gold);
    shard(Offset(-w * 0.05, h * 0.72), Offset(w * 0.05, h * 0.62), 16, magenta);
    shard(Offset(-w * 0.04, h * 0.95), Offset(w * 0.06, h * 0.84), 18, gold);
    // Right edge
    shard(Offset(w * 0.94, h * 0.02), Offset(w * 1.05, h * 0.1), 16, violet);
    shard(Offset(w * 0.95, h * 0.24), Offset(w * 1.04, h * 0.16), 14, gold);
    shard(Offset(w * 0.95, h * 0.46), Offset(w * 1.05, h * 0.38), 16, magenta);
    shard(Offset(w * 0.95, h * 0.68), Offset(w * 1.04, h * 0.6), 12, gold);
    shard(Offset(w * 0.94, h * 0.92), Offset(w * 1.05, h * 0.82), 18, violet);

    // Gold arc behind the header (from behind the avatar out to the top right).
    final arc = Rect.fromCircle(center: Offset(w * 0.78, h * 0.3), radius: w * 0.62);
    canvas.drawArc(
      arc,
      math.pi * 1.06,
      math.pi * 0.42,
      false,
      Paint()
        ..shader = const SweepGradient(
          colors: [Colors.transparent, Color(0x99FFC928), Color(0x33FFC928), Colors.transparent],
          stops: [0.5, 0.62, 0.75, 0.8],
        ).createShader(arc)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    // Diagonal gold beam at the top right.
    shard(Offset(w * 0.5, h * 0.06), Offset(w * 0.68, -h * 0.01), 10, const Color(0x88FFC928));

    // Bokeh
    final dot = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
    for (final (x, y, r, a) in const [
      (0.04, 0.16, 2.0, 0.7),
      (0.97, 0.33, 2.4, 0.6),
      (0.03, 0.58, 1.8, 0.5),
      (0.96, 0.75, 2.2, 0.6),
      (0.62, 0.03, 1.6, 0.5),
    ]) {
      dot.color = LuxeColors.goldLight.withValues(alpha: a);
      canvas.drawCircle(Offset(w * x, h * y), r, dot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
// TOP BAR
// =============================================================================

/// Round dark button with a fine light ring (top bar, camera buttons).
class _RingButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final double size;
  final VoidCallback onTap;
  final double iconScale;

  const _RingButton({
    required this.icon,
    required this.label,
    required this.size,
    required this.onTap,
    this.iconScale = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          padding: const EdgeInsets.all(1.5),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFE9E4FF), Color(0xFF8E7BFF), Color(0xFF4B3A9E)],
            ),
            boxShadow: [BoxShadow(color: Color(0x667B4DFF), blurRadius: 12)],
          ),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(center: Alignment(-0.3, -0.4), colors: [Color(0xFF26215A), Color(0xFF0B0920)]),
            ),
            child: Icon(icon, color: Colors.white, size: size * iconScale),
          ),
        ),
      ),
    );
  }
}

/// [←] [👑 VIP] ................. [≡] [⚙]
class ProfileTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onVip;
  final VoidCallback onMenu;
  final VoidCallback onSettings;

  const ProfileTopBar({
    super.key,
    required this.onBack,
    required this.onVip,
    required this.onMenu,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final s = profileScale(context);
    final size = 40 * s;
    return Row(
      children: [
        _RingButton(icon: Icons.arrow_back_rounded, label: 'Back', size: size, onTap: onBack),
        SizedBox(width: 10 * s),
        Semantics(
          button: true,
          label: 'VIP',
          child: GestureDetector(
            onTap: onVip,
            child: Container(
              height: 34 * s,
              padding: EdgeInsets.symmetric(horizontal: 14 * s),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF2A2210), Color(0xFF120E06)],
                ),
                border: Border.all(color: LuxeColors.gold, width: 1.6),
                boxShadow: const [
                  BoxShadow(color: Color(0x88FFC928), blurRadius: 14),
                  BoxShadow(color: Color(0x33FFC928), blurRadius: 24, spreadRadius: 2),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LuxeCrown(size: 21 * s),
                  SizedBox(width: 7 * s),
                  LuxeGoldText(
                    'VIP',
                    style: TextStyle(fontSize: 16 * s, fontWeight: FontWeight.w700, letterSpacing: 0.6),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),
        _RingButton(icon: Icons.menu_rounded, label: 'Menu', size: size, onTap: onMenu),
        SizedBox(width: 9 * s),
        _RingButton(icon: Icons.settings_rounded, label: 'Settings', size: size, onTap: onSettings),
      ],
    );
  }
}

// =============================================================================
// IDENTITY HEADER
// =============================================================================

/// Avatar with gold ring + crown, name / verified / level, hashtags, stats card and
/// the "Good Vibes Only ♡" script on the right.
class ProfileIdentityHeader extends StatelessWidget {
  final String username;
  final String avatarAsset;
  final VoidCallback onAvatarCamera;

  const ProfileIdentityHeader({
    super.key,
    required this.username,
    required this.avatarAsset,
    required this.onAvatarCamera,
  });

  @override
  Widget build(BuildContext context) {
    final s = profileScale(context);
    final avatar = 100 * s;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 6 * s),
          child: _Avatar(size: avatar, asset: avatarAsset, onCamera: onAvatarCamera),
        ),
        SizedBox(width: 12 * s),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4 * s),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Text(
                      username,
                      style: TextStyle(color: Colors.white, fontSize: 17 * s, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(width: 5 * s),
                    Icon(Icons.verified_rounded, color: const Color(0xFF2E9BFF), size: 17 * s),
                    SizedBox(width: 7 * s),
                    _LevelPill(level: 10, s: s),
                  ],
                ),
              ),
              SizedBox(height: 3 * s),
              Text(
                '#DreamBig  #LiveMore  #Tivoo',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: LuxeColors.textMuted, fontSize: 11 * s),
              ),
              SizedBox(height: 9 * s),
              _StatsCard(s: s),
            ],
          ),
        ),
        SizedBox(width: 4 * s),
        _GoodVibes(s: s),
      ],
    );
  }
}

/// Photo in a thick glowing gold ring with a violet inner rim, a thin white bezel,
/// lens-flare glints, a tilted crown and a camera button.
class _Avatar extends StatelessWidget {
  final double size;
  final String asset;
  final VoidCallback onCamera;
  const _Avatar({required this.size, required this.asset, required this.onCamera});

  @override
  Widget build(BuildContext context) {
    final photoInset = size * 0.115;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Outer glow
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: const Color(0xAAFFC928), blurRadius: size * 0.2, spreadRadius: size * 0.01),
                  BoxShadow(color: const Color(0x55FF9A00), blurRadius: size * 0.34, spreadRadius: size * 0.03),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(photoInset),
              child: ClipOval(
                child: ColoredBox(
                  color: Colors.white,
                  child: Image.asset(asset, fit: BoxFit.cover, alignment: const Alignment(0, -0.6)),
                ),
              ),
            ),
          ),
          const Positioned.fill(child: CustomPaint(painter: _AvatarRingPainter())),
          Positioned(
            top: -size * 0.24,
            left: size * 0.02,
            child: Transform.rotate(angle: -0.36, child: LuxeCrown(size: size * 0.38)),
          ),
          Positioned(
            right: -size * 0.04,
            bottom: size * 0.02,
            child: _RingButton(
              icon: Icons.camera_alt_rounded,
              label: 'Change photo',
              size: size * 0.32,
              iconScale: 0.5,
              onTap: onCamera,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarRingPainter extends CustomPainter {
  const _AvatarRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = size.center(Offset.zero);
    final stroke = s * 0.075;
    final r = s / 2 - s * 0.045;
    final ring = Rect.fromCircle(center: c, radius: r);

    // Soft halo hugging the ring.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke * 2
        ..color = const Color(0x77FFC928)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.05),
    );
    // Gold band
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..shader = const SweepGradient(
          colors: [
            Color(0xFFFFF1A6),
            LuxeColors.gold,
            Color(0xFFE08A00),
            LuxeColors.gold,
            Color(0xFFFFF6CF),
            LuxeColors.gold,
            Color(0xFFFFF1A6),
          ],
          stops: [0, 0.15, 0.32, 0.5, 0.68, 0.85, 1],
        ).createShader(ring),
    );
    // Violet / magenta inner rim on the lower left.
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r - stroke * 0.32),
      math.pi * 0.42,
      math.pi * 0.95,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke * 0.5
        ..strokeCap = StrokeCap.round
        ..shader = const SweepGradient(
          colors: [Color(0x00B04DFF), Color(0xFFB04DFF), Color(0xFFE040FB), Color(0xFF7B4DFF), Color(0x007B4DFF)],
          stops: [0.2, 0.3, 0.42, 0.6, 0.72],
        ).createShader(ring)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.008),
    );
    // Bright outer edge
    canvas.drawCircle(
      c,
      r + stroke / 2,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.008
        ..color = const Color(0xCCFFF4C2),
    );
    // White bezel around the photo
    canvas.drawCircle(
      c,
      r - stroke / 2 - s * 0.008,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.016
        ..color = Colors.white.withValues(alpha: 0.9),
    );

    // Lens-flare glints on the ring.
    void glint(double angle, double size) {
      final p = c + Offset(math.cos(angle), math.sin(angle)) * r;
      canvas.drawCircle(
        p,
        size * 1.4,
        Paint()
          ..shader = RadialGradient(
            colors: [Colors.white.withValues(alpha: 0.9), const Color(0x88FFC928), Colors.transparent],
            stops: const [0, 0.3, 1],
          ).createShader(Rect.fromCircle(center: p, radius: size * 1.4)),
      );
      final star = Path()
        ..moveTo(p.dx, p.dy - size * 1.6)
        ..quadraticBezierTo(p.dx, p.dy, p.dx + size * 1.6, p.dy)
        ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy + size * 1.6)
        ..quadraticBezierTo(p.dx, p.dy, p.dx - size * 1.6, p.dy)
        ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy - size * 1.6)
        ..close();
      canvas.drawPath(star, Paint()..color = Colors.white);
    }

    glint(math.pi * 0.78, s * 0.06);
    glint(-math.pi * 0.12, s * 0.045);
    glint(math.pi * 1.32, s * 0.03);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LevelPill extends StatelessWidget {
  final int level;
  final double s;
  const _LevelPill({required this.level, required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7 * s, vertical: 1.5 * s),
      decoration: BoxDecoration(
        color: const Color(0x1FFFC928),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: LuxeColors.gold, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, color: LuxeColors.gold, size: 12 * s),
          SizedBox(width: 3 * s),
          Text(
            'Lv $level',
            style: TextStyle(color: Colors.white, fontSize: 10.5 * s, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final double s;
  const _StatsCard({required this.s});

  @override
  Widget build(BuildContext context) {
    Widget stat(String value, String label) => Expanded(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(color: Colors.white, fontSize: 17 * s, fontWeight: FontWeight.w600, height: 1.2),
            ),
            Text(
              label,
              style: TextStyle(color: LuxeColors.textMuted, fontSize: 10.5 * s),
            ),
          ],
        ),
      ),
    );
    Widget divider() => Container(width: 1, height: 28 * s, color: Colors.white.withValues(alpha: 0.16));

    return Container(
      padding: EdgeInsets.symmetric(vertical: 9 * s, horizontal: 4 * s),
      decoration: _glass(16 * s),
      child: Row(
        children: [stat('4.7K', 'Followers'), divider(), stat('300', 'Following'), divider(), stat('53.1K', 'Likes')],
      ),
    );
  }
}

class _GoodVibes extends StatelessWidget {
  final double s;
  const _GoodVibes({required this.s});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50 * s,
      child: Column(
        children: [
          SizedBox(height: 10 * s),
          Transform.rotate(angle: 0.12, child: LuxeCrown(size: 26 * s)),
          SizedBox(height: 2 * s),
          Transform.rotate(
            angle: -0.12,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: LuxeGoldText(
                'Good\nVibes\nOnly',
                style: TextStyle(
                  fontFamily: 'KaushanScript',
                  fontSize: 17 * s,
                  height: 1.0,
                  shadows: const [Shadow(color: Color(0x99FFC928), blurRadius: 8)],
                ),
              ),
            ),
          ),
          SizedBox(height: 2 * s),
          Icon(Icons.favorite_border_rounded, color: LuxeColors.gold, size: 20 * s),
        ],
      ),
    );
  }
}

// =============================================================================
// BIO + ACTIONS
// =============================================================================

class ProfileBio extends StatelessWidget {
  final String name;
  final String bio;
  const ProfileBio({super.key, required this.name, required this.bio});

  @override
  Widget build(BuildContext context) {
    final s = profileScale(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 2 * s),
          decoration: BoxDecoration(gradient: LuxeColors.goldGradient, borderRadius: BorderRadius.circular(10)),
          child: Text(
            '#Knowledge',
            style: TextStyle(color: _ink, fontSize: 11 * s, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(height: 5 * s),
        Text(
          name,
          style: TextStyle(color: Colors.white, fontSize: 15 * s, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 2 * s),
        Text(
          bio.toUpperCase(),
          style: TextStyle(color: const Color(0xFFD9D6EE), fontSize: 11.5 * s, height: 1.4),
        ),
      ],
    );
  }
}

/// [Edit Profile (glossy gold)] [Find Friends (neon glass)] [camera]
class ProfileActions extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onFindFriends;
  final VoidCallback onCamera;

  const ProfileActions({super.key, required this.onEdit, required this.onFindFriends, required this.onCamera});

  @override
  Widget build(BuildContext context) {
    final s = profileScale(context);
    final h = 46 * s;
    Widget label(IconData icon, String text, Color color) => FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20 * s),
          SizedBox(width: 9 * s),
          Text(
            text,
            style: TextStyle(color: color, fontSize: 14 * s, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );

    return Row(
      children: [
        Expanded(
          flex: 40,
          child: Semantics(
            button: true,
            child: GestureDetector(
              onTap: onEdit,
              child: _GlossyGoldButton(height: h, child: label(Icons.person_rounded, 'Edit Profile', _ink)),
            ),
          ),
        ),
        SizedBox(width: 10 * s),
        Expanded(
          flex: 34,
          child: Semantics(
            button: true,
            child: GestureDetector(
              onTap: onFindFriends,
              child: Container(
                height: h,
                padding: const EdgeInsets.all(1.3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(h / 2),
                  gradient: const LinearGradient(colors: [Color(0xFF7B4DFF), Color(0xFF5B3CFF), LuxeColors.blue]),
                  boxShadow: const [BoxShadow(color: Color(0x557B4DFF), blurRadius: 12)],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(h / 2),
                    gradient: const LinearGradient(colors: [Color(0xFF1C1650), Color(0xFF100D33), Color(0xFF14184A)]),
                  ),
                  alignment: Alignment.center,
                  child: label(Icons.group_rounded, 'Find Friends', Colors.white),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10 * s),
        Semantics(
          button: true,
          label: 'Camera',
          child: GestureDetector(
            onTap: onCamera,
            child: Container(
              width: h * 1.08,
              height: h,
              padding: const EdgeInsets.all(1.3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(h / 2),
                gradient: const LinearGradient(colors: [Color(0xFF7B4DFF), LuxeColors.blue]),
                boxShadow: const [BoxShadow(color: Color(0x557B4DFF), blurRadius: 12)],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(h / 2),
                  gradient: const LinearGradient(colors: [Color(0xFF1C1650), Color(0xFF100D33)]),
                ),
                child: Icon(Icons.camera_alt_rounded, color: Colors.white, size: 22 * s),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Gold pill with a glossy top highlight and a diagonal light streak near its right end.
class _GlossyGoldButton extends StatelessWidget {
  final double height;
  final Widget child;
  const _GlossyGoldButton({required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(height / 2);
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: r,
        border: Border.all(color: const Color(0xFFFFE9A0), width: 1),
        boxShadow: const [BoxShadow(color: Color(0x88FFC928), blurRadius: 16, offset: Offset(0, 3))],
      ),
      child: ClipRRect(
        borderRadius: r,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFE066), LuxeColors.gold, Color(0xFFF2B200), Color(0xFFFFF0A8), Color(0xFFE59A00)],
                  stops: [0, 0.4, 0.66, 0.74, 1],
                ),
              ),
            ),
            // Top gloss
            Align(
              alignment: Alignment.topCenter,
              child: FractionallySizedBox(
                heightFactor: 0.45,
                widthFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.white.withValues(alpha: 0.45), Colors.white.withValues(alpha: 0)],
                    ),
                  ),
                ),
              ),
            ),
            Center(child: child),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// BADGES ROW
// =============================================================================

/// One glass panel: [⭐ Tiki Star No.500+ ›] | [Angels 👥 ›] | [Share] | [🛡 Family RS TECH ›]
class ProfileBadgesRow extends StatelessWidget {
  final VoidCallback onTikiStar;
  final VoidCallback onAngels;
  final VoidCallback onShare;
  final VoidCallback onFamily;

  const ProfileBadgesRow({
    super.key,
    required this.onTikiStar,
    required this.onAngels,
    required this.onShare,
    required this.onFamily,
  });

  @override
  Widget build(BuildContext context) {
    final s = profileScale(context);
    final h = 46 * s;
    Widget divider() => Container(
      width: 1,
      height: 30 * s,
      margin: EdgeInsets.symmetric(horizontal: 4 * s),
      color: Colors.white.withValues(alpha: 0.12),
    );
    Widget cell(Widget child, VoidCallback onTap, int flex, {bool framed = true}) => Expanded(
      flex: flex,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          height: h,
          padding: EdgeInsets.symmetric(horizontal: 5 * s),
          decoration: framed
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(h / 2),
                  color: Colors.white.withValues(alpha: 0.03),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                )
              : null,
          child: FittedBox(fit: BoxFit.scaleDown, child: child),
        ),
      ),
    );

    return Container(
      padding: EdgeInsets.all(6 * s),
      decoration: _glass(22 * s).copyWith(
        boxShadow: const [BoxShadow(color: Color(0x337B4DFF), blurRadius: 12)],
        border: Border.all(color: const Color(0x557B4DFF)),
      ),
      child: Row(
        children: [
          cell(
            _BadgeCell(
              s: s,
              leading: _RoundIcon(icon: Icons.star_rounded, color: LuxeColors.gold, s: s),
              title: 'Tiki Star',
              value: 'No.500+',
            ),
            onTikiStar,
            28,
          ),
          divider(),
          cell(
            _BadgeCell(
              s: s,
              title: 'Angels',
              valueWidget: SizedBox(
                width: 40 * s,
                height: 20 * s,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      child: CustomAvatar(radius: 10 * s, assetPath: AppAssets.avatarPriya),
                    ),
                    Positioned(
                      left: 17 * s,
                      child: CustomAvatar(radius: 10 * s, assetPath: AppAssets.avatarNeha),
                    ),
                  ],
                ),
              ),
            ),
            onAngels,
            20,
          ),
          divider(),
          cell(
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 7 * s),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFE34D), LuxeColors.gold]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Color(0x77FFC928), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  Icon(Icons.push_pin_rounded, color: _ink, size: 15 * s),
                  SizedBox(width: 5 * s),
                  Text(
                    'Share',
                    style: TextStyle(color: _ink, fontSize: 13 * s, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            onShare,
            22,
          ),
          divider(),
          cell(
            _BadgeCell(
              s: s,
              leading: _RoundIcon(icon: Icons.shield_rounded, color: const Color(0xFFCFE2FF), s: s),
              title: 'Family',
              value: 'RS TECH',
            ),
            onFamily,
            28,
          ),
        ],
      ),
    );
  }
}

class _BadgeCell extends StatelessWidget {
  final double s;
  final Widget? leading;
  final String title;
  final String? value;
  final Widget? valueWidget;

  const _BadgeCell({required this.s, this.leading, required this.title, this.value, this.valueWidget});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (leading != null) ...[leading!, SizedBox(width: 7 * s)],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(color: const Color(0xFFD9D6EE), fontSize: 11 * s),
            ),
            valueWidget ??
                Text(
                  value ?? '',
                  style: TextStyle(color: Colors.white, fontSize: 13 * s, fontWeight: FontWeight.w600),
                ),
          ],
        ),
        SizedBox(width: 3 * s),
        Icon(Icons.chevron_right_rounded, color: Colors.white70, size: 18 * s),
      ],
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double s;
  const _RoundIcon({required this.icon, required this.color, required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32 * s,
      height: 32 * s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(colors: [Color(0xFF2A2366), Color(0xFF0E0B2C)]),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8)],
      ),
      child: Icon(
        icon,
        color: color,
        size: 20 * s,
        shadows: [Shadow(color: color.withValues(alpha: 0.6), blurRadius: 6)],
      ),
    );
  }
}

// =============================================================================
// VIDEOS / LIKES BAR
// =============================================================================

/// Gold → blue glowing bar: [▶ Videos 411] [♥ Likes 39637], the active side underlined in gold.
class ProfileStatsBar extends StatelessWidget {
  final int videos;
  final int likes;
  final bool showVideos;
  final ValueChanged<bool> onChanged;

  const ProfileStatsBar({
    super.key,
    required this.videos,
    required this.likes,
    required this.showVideos,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final s = profileScale(context);
    final h = 50 * s;
    Widget side(bool isVideos) {
      final active = isVideos == showVideos;
      return Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onChanged(isVideos),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  children: [
                    Container(
                      width: 28 * s,
                      height: 28 * s,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0x55000000),
                        boxShadow: [
                          BoxShadow(
                            color: (isVideos ? Colors.black : LuxeColors.blue).withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        isVideos ? Icons.play_arrow_rounded : Icons.favorite_rounded,
                        color: Colors.white,
                        size: (isVideos ? 24 : 19) * s,
                      ),
                    ),
                    SizedBox(width: 9 * s),
                    Text(
                      isVideos ? 'Videos $videos' : 'Likes $likes',
                      style: TextStyle(color: Colors.white, fontSize: 15 * s, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4 * s),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: active ? 72 * s : 0,
                height: 2.6,
                decoration: BoxDecoration(
                  gradient: LuxeColors.goldGradient,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: const [BoxShadow(color: Color(0xAAFFC928), blurRadius: 6)],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: h,
      padding: const EdgeInsets.all(1.6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(h / 2),
        gradient: const LinearGradient(
          colors: [LuxeColors.goldLight, LuxeColors.gold, Color(0xFF9B3CFF), Color(0xFF3D8BFF), Color(0xFF8FC8FF)],
          stops: [0, 0.18, 0.5, 0.82, 1],
        ),
        boxShadow: const [
          BoxShadow(color: Color(0x66FFC928), blurRadius: 14, offset: Offset(-6, 0)),
          BoxShadow(color: Color(0x663D8BFF), blurRadius: 14, offset: Offset(6, 0)),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(h / 2),
          gradient: const LinearGradient(
            colors: [Color(0xFF3A2A08), Color(0xFF15102E), Color(0xFF151848), Color(0xFF1F3FB8)],
            stops: [0, 0.3, 0.62, 1],
          ),
        ),
        child: Row(children: [side(true), side(false)]),
      ),
    );
  }
}

// =============================================================================
// CONTENT: TABS + GRID
// =============================================================================

class ProfileVideo {
  final String asset;
  final String? views;
  final bool pinned;
  final bool draft;

  const ProfileVideo(this.asset, {this.views, this.pinned = false, this.draft = false});
}

/// Glass panel with [Drafts 7] [Pinned] [My Posts] tabs and a 3-column grid.
class ProfileContentPanel extends StatelessWidget {
  final int tab;
  final ValueChanged<int> onTab;
  final List<ProfileVideo> videos;
  final ValueChanged<ProfileVideo> onOpen;

  const ProfileContentPanel({
    super.key,
    required this.tab,
    required this.onTab,
    required this.videos,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final s = profileScale(context);
    final width = MediaQuery.sizeOf(context).width;
    return Container(
      padding: EdgeInsets.fromLTRB(6 * s, 10 * s, 6 * s, 6 * s),
      decoration: _glass(22 * s).copyWith(border: Border.all(color: const Color(0x447B4DFF))),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8 * s),
            child: Row(
              children: [
                Expanded(
                  child: _ContentTab(
                    s: s,
                    icon: Icons.inventory_2_outlined,
                    label: 'Drafts',
                    count: 7,
                    selected: tab == 0,
                    onTap: () => onTab(0),
                  ),
                ),
                SizedBox(width: 14 * s),
                Expanded(
                  child: _ContentTab(
                    s: s,
                    icon: Icons.push_pin_rounded,
                    label: 'Pinned',
                    selected: tab == 1,
                    onTap: () => onTab(1),
                  ),
                ),
                SizedBox(width: 14 * s),
                Expanded(
                  child: _ContentTab(
                    s: s,
                    icon: Icons.grid_view_rounded,
                    label: 'My Posts',
                    selected: tab == 2,
                    onTap: () => onTab(2),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10 * s),
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: videos.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: width >= 700 ? 4 : 3,
              childAspectRatio: width >= 700 ? 1.0 : 0.86,
              crossAxisSpacing: 6 * s,
              mainAxisSpacing: 6 * s,
            ),
            itemBuilder: (_, i) => _VideoTile(video: videos[i], onTap: () => onOpen(videos[i])),
          ),
        ],
      ),
    );
  }
}

class _ContentTab extends StatelessWidget {
  final double s;
  final IconData icon;
  final String label;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  const _ContentTab({
    required this.s,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final h = 36 * s;
    final fg = selected ? _ink : Colors.white;
    final content = FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        children: [
          Icon(icon, color: fg, size: 17 * s),
          SizedBox(width: 7 * s),
          Text(
            label,
            style: TextStyle(color: fg, fontSize: 13.5 * s, fontWeight: FontWeight.w500),
          ),
          if (count != null) ...[
            SizedBox(width: 7 * s),
            Container(
              width: 19 * s,
              height: 19 * s,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (selected ? _ink : Colors.white).withValues(alpha: 0.16),
              ),
              child: Text(
                '$count',
                style: TextStyle(color: fg, fontSize: 11 * s, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: h,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 8 * s),
          decoration: selected
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(h / 2),
                  gradient: const LinearGradient(colors: [Color(0xFFFFE34D), LuxeColors.gold, Color(0xFFF2B200)]),
                  boxShadow: const [BoxShadow(color: Color(0x77FFC928), blurRadius: 12)],
                )
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(h / 2),
                  color: const Color(0xFF110E2E),
                  border: Border.all(color: const Color(0xAA7B4DFF)),
                  boxShadow: const [BoxShadow(color: Color(0x337B4DFF), blurRadius: 8)],
                ),
          child: content,
        ),
      ),
    );
  }
}

class _VideoTile extends StatelessWidget {
  final ProfileVideo video;
  final VoidCallback onTap;
  const _VideoTile({required this.video, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(9),
          child: LayoutBuilder(
            builder: (context, c) {
              final u = (c.maxWidth / 110).clamp(0.85, 1.4);
              final label = TextStyle(color: Colors.white, fontSize: 10.5 * u, fontWeight: FontWeight.w500);
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(video.asset, fit: BoxFit.cover, cacheWidth: 360),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x33000000), Colors.transparent, Color(0x99000000)],
                        stops: [0, 0.5, 1],
                      ),
                    ),
                  ),
                  if (video.draft || video.pinned)
                    Positioned(
                      left: 5 * u,
                      top: 5 * u,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 7 * u, vertical: 2.5 * u),
                            decoration: BoxDecoration(
                              color: const Color(0x8C0B0A1E),
                              borderRadius: BorderRadius.circular(8 * u),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (video.draft) ...[
                                  Icon(Icons.folder_rounded, color: Colors.white, size: 12 * u),
                                  SizedBox(width: 4 * u),
                                ],
                                Text(video.draft ? 'Drafts' : 'Pinned', style: label),
                              ],
                            ),
                          ),
                          if (video.draft)
                            Padding(
                              padding: EdgeInsets.only(left: 5 * u, top: 2 * u),
                              child: Text('12 Videos', style: label),
                            ),
                        ],
                      ),
                    ),
                  if (video.draft)
                    Positioned(
                      left: 6 * u,
                      bottom: 6 * u,
                      child: Container(
                        width: 18 * u,
                        height: 18 * u,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD600),
                          borderRadius: BorderRadius.circular(4 * u),
                        ),
                        child: Text(
                          'T',
                          style: TextStyle(color: _ink, fontSize: 11 * u, fontWeight: FontWeight.w800),
                        ),
                      ),
                    )
                  else ...[
                    Positioned(
                      left: 6 * u,
                      bottom: 5 * u,
                      child: Row(
                        children: [
                          Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16 * u),
                          SizedBox(width: 2 * u),
                          Text(video.views ?? '', style: label.copyWith(fontSize: 11 * u)),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 6 * u,
                      bottom: 6 * u,
                      child: LuxeCrown(size: 15 * u),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
