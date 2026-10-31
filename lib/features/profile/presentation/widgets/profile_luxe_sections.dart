// Profile screen sections in the Luxe (gold + deep navy neon) style.
//
// Sizes are designed for a 390 px wide phone and scale with the screen ([profileScale]).

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/luxe_theme.dart';
import '../../../../core/widgets/custom_avatar.dart';
import 'package:tivoo/features/explore/domain/models/video_post.dart';
import 'package:tivoo/features/explore/presentation/widgets/video_thumbnail_view.dart';

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
  static const double _iconScale = 0.5;

  const _RingButton({
    required this.icon,
    required this.label,
    required this.size,
    required this.onTap,
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
            child: Icon(icon, color: Colors.white, size: size * _iconScale),
          ),
        ),
      ),
    );
  }
}

/// [←] ................. [≡] [⚙]
class ProfileTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback? onMenu;
  final VoidCallback? onSettings;
  final bool showActions;

  const ProfileTopBar({
    super.key,
    required this.onBack,
    this.onMenu,
    this.onSettings,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final s = profileScale(context);
    final size = 40 * s;
    return Row(
      children: [
        _RingButton(icon: Icons.arrow_back_rounded, label: 'Back', size: size, onTap: onBack),
        const Spacer(),
        if (showActions && onMenu != null)
          _RingButton(icon: Icons.menu_rounded, label: 'Menu', size: size, onTap: onMenu!),
        if (showActions && onMenu != null && onSettings != null)
          SizedBox(width: 9 * s),
        if (showActions && onSettings != null)
          _RingButton(icon: Icons.settings_rounded, label: 'Settings', size: size, onTap: onSettings!),
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
  final String followersCount;
  final String followingCount;
  final String likesCount;
  final int level;
  final VoidCallback? onLevelTap;

  const ProfileIdentityHeader({
    super.key,
    required this.username,
    required this.avatarAsset,
    required this.onAvatarCamera,
    this.followersCount = '4.7K',
    this.followingCount = '300',
    this.likesCount = '53.1K',
    this.level = 18,
    this.onLevelTap,
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
                    _LevelPill(level: level, s: s, onTap: onLevelTap),
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
              _StatsCard(
                s: s,
                followers: followersCount,
                following: followingCount,
                likes: likesCount,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Photo in a thick glowing gold ring with a violet inner rim, a thin white bezel,
/// lens-flare glints and a tilted crown.
class _Avatar extends StatelessWidget {
  final double size;
  final String asset;
  final VoidCallback onCamera;
  const _Avatar({required this.size, required this.asset, required this.onCamera});

  @override
  Widget build(BuildContext context) {
    final photoInset = size * 0.115;
    final innerDiameter = size - photoInset * 2;
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
                child: GestureDetector(
                  onTap: onCamera,
                  child: ColoredBox(
                    color: Colors.white,
                    child: CustomAvatar(
                      radius: innerDiameter / 2,
                      imageUrl: asset,
                      assetPath: asset.startsWith('assets/') ? asset : null,
                    ),
                  ),
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
  final VoidCallback? onTap;
  const _LevelPill({required this.level, required this.s, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
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
            if (onTap != null) ...[
              SizedBox(width: 2 * s),
              Icon(Icons.chevron_right_rounded, color: LuxeColors.gold, size: 11 * s),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final double s;
  final String followers;
  final String following;
  final String likes;

  const _StatsCard({
    required this.s,
    this.followers = '4.7K',
    this.following = '300',
    this.likes = '53.1K',
  });

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
        children: [stat(followers, 'Followers'), divider(), stat(following, 'Following'), divider(), stat(likes, 'Likes')],
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

/// [Edit Profile] and [Messages] action buttons.
class ProfileActions extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onMessagesTap;
  final int unreadCount;

  const ProfileActions({
    super.key,
    required this.onEdit,
    required this.onMessagesTap,
    this.unreadCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final s = profileScale(context);
    final h = 46 * s;
    return Row(
      children: [
        // Edit Profile Button
        Expanded(
          child: Semantics(
            button: true,
            child: GestureDetector(
              onTap: onEdit,
              child: _GlossyGlassButton(
                height: h,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit_outlined, color: LuxeColors.gold, size: 18 * s),
                      SizedBox(width: 7 * s),
                      Text(
                        'Edit Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13.5 * s,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10 * s),
        // Messages Panel Button
        Expanded(
          child: Semantics(
            button: true,
            child: GestureDetector(
              onTap: onMessagesTap,
              child: _GlossyGoldButton(
                height: h,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded, color: _ink, size: 18 * s),
                      SizedBox(width: 7 * s),
                      Text(
                        'Messages',
                        style: TextStyle(
                          color: _ink,
                          fontSize: 13.5 * s,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        SizedBox(width: 6 * s),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6 * s, vertical: 2 * s),
                          decoration: BoxDecoration(
                            color: const Color(0xFF161200),
                            borderRadius: BorderRadius.circular(10 * s),
                          ),
                          child: Text(
                            '$unreadCount',
                            style: TextStyle(
                              color: LuxeColors.gold,
                              fontSize: 10.5 * s,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ],
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

/// Glass pill button with a subtle gold border and glossy top highlight.
class _GlossyGlassButton extends StatelessWidget {
  final double height;
  final Widget child;
  const _GlossyGlassButton({required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(height / 2);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0x331C1645),
        borderRadius: r,
        border: Border.all(color: LuxeColors.gold.withValues(alpha: 0.55), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: r,
        child: Stack(
          fit: StackFit.expand,
          children: [
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
                      colors: [
                        Colors.white.withValues(alpha: 0.16),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Center(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: child)),
          ],
        ),
      ),
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

/// One glass panel: [⭐ Tivoo Star No.500+ ›] | [Angels 👥 ›] | [Share] | [🛡 Family RS TECH ›]
class ProfileBadgesRow extends StatelessWidget {
  final VoidCallback onTikiStar;
  final VoidCallback? onTivooStar;
  final VoidCallback onAngels;
  final VoidCallback onShare;
  final VoidCallback onFamily;

  const ProfileBadgesRow({
    super.key,
    required this.onTikiStar,
    this.onTivooStar,
    required this.onAngels,
    required this.onShare,
    required this.onFamily,
  });

  @override
  Widget build(BuildContext context) {
    final s = profileScale(context);
    final h = 56 * s;
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
                  color: Colors.white.withValues(alpha: 0.05),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.16), width: 1.1),
                  boxShadow: const [
                    BoxShadow(color: Color(0x22000000), blurRadius: 6, offset: Offset(0, 2)),
                  ],
                )
              : null,
          child: Center(
            child: FittedBox(fit: BoxFit.scaleDown, child: child),
          ),
        ),
      ),
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 8 * s),
      decoration: _glass(26 * s).copyWith(
        boxShadow: const [BoxShadow(color: Color(0x3D7B4DFF), blurRadius: 16)],
        border: Border.all(color: const Color(0x667B4DFF), width: 1.2),
      ),
      child: Row(
        children: [
          cell(
            _BadgeCell(
              s: s,
              leading: _RoundIcon(icon: Icons.star_rounded, color: LuxeColors.gold, s: s),
              title: 'Tivoo Star',
              value: 'No.500+',
            ),
            onTivooStar ?? onTikiStar,
            30,
          ),
          SizedBox(width: 5 * s),
          cell(
            _BadgeCell(
              s: s,
              title: 'Angels',
              valueWidget: SizedBox(
                width: 44 * s,
                height: 22 * s,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      child: CustomAvatar(radius: 11 * s, assetPath: AppAssets.avatarPriya),
                    ),
                    Positioned(
                      left: 18 * s,
                      child: CustomAvatar(radius: 11 * s, assetPath: AppAssets.avatarNeha),
                    ),
                  ],
                ),
              ),
            ),
            onAngels,
            22,
          ),
          SizedBox(width: 5 * s),
          cell(
            Container(
              height: h - 8 * s,
              padding: EdgeInsets.symmetric(horizontal: 14 * s),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFFFE34D), LuxeColors.gold]),
                borderRadius: BorderRadius.circular(h / 2),
                boxShadow: const [BoxShadow(color: Color(0x77FFC928), blurRadius: 10)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.push_pin_rounded, color: _ink, size: 16 * s),
                  SizedBox(width: 5 * s),
                  Text(
                    'Share',
                    style: TextStyle(color: _ink, fontSize: 13.5 * s, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            onShare,
            22,
            framed: false,
          ),
          SizedBox(width: 5 * s),
          cell(
            _BadgeCell(
              s: s,
              leading: _RoundIcon(icon: Icons.shield_rounded, color: const Color(0xFFCFE2FF), s: s),
              title: 'Family',
              value: 'RS TECH',
            ),
            onFamily,
            30,
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
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leading != null) ...[leading!, SizedBox(width: 6 * s)],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(color: const Color(0xFFD9D6EE), fontSize: 12 * s, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 1 * s),
            valueWidget ??
                Text(
                  value ?? '',
                  style: TextStyle(color: Colors.white, fontSize: 13.5 * s, fontWeight: FontWeight.w700),
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
      width: 35 * s,
      height: 35 * s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(colors: [Color(0xFF2A2366), Color(0xFF0E0B2C)]),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22), width: 1.1),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 8)],
      ),
      child: Icon(
        icon,
        color: color,
        size: 21 * s,
        shadows: [Shadow(color: color.withValues(alpha: 0.6), blurRadius: 6)],
      ),
    );
  }
}

// =============================================================================
// CONTENT GRID (Instagram style)
// =============================================================================

/// One tile in the profile grid: a photo post, an uploaded video, or the Drafts folder.
class ProfileVideo {
  final String asset;

  /// Likes (photos) or views (videos), e.g. "3.5K".
  final String? views;
  final bool isDraftFolder;

  /// Set for videos the user uploaded.
  final VideoPost? post;

  const ProfileVideo(this.asset, {this.views, this.isDraftFolder = false, this.post});

  ProfileVideo.uploaded(VideoPost post) : this(AppAssets.liveCard1, views: post.formattedViews, post: post);

  bool get isVideo => post != null;
}

/// Model representing a draft video.
class DraftVideoItem {
  final String id;
  final String asset;
  final String title;
  final String duration;
  final String date;

  const DraftVideoItem({
    required this.id,
    required this.asset,
    required this.title,
    required this.duration,
    required this.date,
  });
}

/// Posts grid (3 columns on phones, 4 on tablets) with in-place Drafts viewing.
class ProfileContentPanel extends StatelessWidget {
  final bool isViewingDrafts;
  final List<ProfileVideo> videos;
  final List<DraftVideoItem> draftVideos;
  final ValueChanged<ProfileVideo> onOpen;
  final ValueChanged<ProfileVideo>? onLongPressVideo;
  final VoidCallback? onOpenDrafts;
  final VoidCallback? onCloseDrafts;
  final ValueChanged<DraftVideoItem>? onOpenDraft;

  const ProfileContentPanel({
    super.key,
    this.isViewingDrafts = false,
    required this.videos,
    this.draftVideos = const [],
    required this.onOpen,
    this.onLongPressVideo,
    this.onOpenDrafts,
    this.onCloseDrafts,
    this.onOpenDraft,
  });

  @override
  Widget build(BuildContext context) {
    final s = profileScale(context);
    final columns = MediaQuery.sizeOf(context).width >= 700 ? 4 : 3;

    Widget grid(int count, Widget Function(int) tile) => GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: 0.9, // a little taller than wide
        crossAxisSpacing: 8 * s,
        mainAxisSpacing: 8 * s,
      ),
      itemBuilder: (_, i) => tile(i),
    );

    if (!isViewingDrafts && !videos.any((v) => v.isVideo)) {
      return Column(
        children: [
          if (videos.isNotEmpty) grid(videos.length, (i) => _tileFor(videos[i])),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 28 * s),
            child: Column(
              children: [
                Icon(Icons.video_library_outlined, color: Colors.white38, size: 40 * s),
                SizedBox(height: 10 * s),
                Text(
                  'No videos yet',
                  style: TextStyle(color: Colors.white, fontSize: 15 * s, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4 * s),
                Text(
                  onLongPressVideo == null ? 'Videos will appear here.' : 'Tap + below to upload your first video.',
                  style: TextStyle(color: Colors.white54, fontSize: 12.5 * s),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (!isViewingDrafts) {
      return grid(videos.length, (i) => _tileFor(videos[i]));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 10 * s),
          child: Row(
            children: [
              IconButton(
                onPressed: onCloseDrafts,
                tooltip: 'Back to posts',
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.08)),
              ),
              SizedBox(width: 8 * s),
              Text(
                'Drafts · ${draftVideos.length}',
                style: TextStyle(color: Colors.white, fontSize: 15 * s, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Icon(Icons.lock_rounded, color: LuxeColors.gold, size: 14 * s),
              SizedBox(width: 4 * s),
              Text('Only you', style: TextStyle(color: Colors.white60, fontSize: 11.5 * s)),
            ],
          ),
        ),
        grid(draftVideos.length, (i) {
          final d = draftVideos[i];
          return _GridTile(
            onTap: () => onOpenDraft?.call(d),
            image: _asset(d.asset),
            topRight: Icons.edit_rounded,
            bottomIcon: Icons.schedule_rounded,
            bottomText: d.duration,
          );
        }),
      ],
    );
  }

  /// The Drafts folder or an uploaded video.
  Widget _tileFor(ProfileVideo v) {
    if (v.isDraftFolder) {
      return _GridTile(
        onTap: () => onOpenDrafts?.call(),
        image: _asset(v.asset),
        bottomIcon: Icons.folder_rounded,
        bottomText: 'Drafts',
      );
    }
    return _GridTile(
      onTap: () => onOpen(v),
      onLongPress: onLongPressVideo == null ? null : () => onLongPressVideo!(v),
      image: VideoThumbnailView(key: ValueKey(v.post!.id), post: v.post!),
      topRight: Icons.smart_display_rounded,
      bottomIcon: Icons.play_arrow_rounded,
      bottomText: v.views ?? '',
    );
  }

  static Widget _asset(String path) => Image.asset(path, fit: BoxFit.cover, cacheWidth: 420);
}

/// Rounded tile with a type icon at the top right and a stat at the bottom left.
class _GridTile extends StatelessWidget {
  final Widget image;
  final IconData? topRight;
  final IconData bottomIcon;
  final String bottomText;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const _GridTile({
    required this.image,
    required this.bottomIcon,
    required this.bottomText,
    required this.onTap,
    this.topRight,
    this.onLongPress,
  });

  static const _shadow = [Shadow(color: Color(0xAA000000), blurRadius: 6)];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: LayoutBuilder(
        builder: (context, c) {
          final u = (c.maxWidth / 120).clamp(0.85, 1.4);
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14 * u),
              border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
              boxShadow: const [BoxShadow(color: Color(0x44000000), blurRadius: 8, offset: Offset(0, 3))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13 * u),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  image,
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x33000000), Colors.transparent, Color(0x99000000)],
                        stops: [0, 0.45, 1],
                      ),
                    ),
                  ),
                  if (topRight != null)
                    Positioned(
                      top: 7 * u,
                      right: 7 * u,
                      child: Icon(topRight, color: Colors.white, size: 17 * u, shadows: _shadow),
                    ),
                  Positioned(
                    left: 8 * u,
                    bottom: 6 * u,
                    right: 8 * u,
                    child: Row(
                      children: [
                        Icon(bottomIcon, color: Colors.white, size: 15 * u, shadows: _shadow),
                        SizedBox(width: 4 * u),
                        Flexible(
                          child: Text(
                            bottomText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.5 * u,
                              fontWeight: FontWeight.w700,
                              shadows: _shadow,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
