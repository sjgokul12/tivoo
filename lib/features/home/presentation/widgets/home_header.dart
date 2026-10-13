import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/luxe_theme.dart';
import '../../../../core/widgets/luxe_tivoo_logo.dart';

/// Home palette — aliases of the shared Luxe theme (gold + deep indigo / purple neon).
const Color kHomeGold = LuxeColors.gold;
const LinearGradient kHomeGoldGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [Color(0xFFFFF1A8), LuxeColors.gold, LuxeColors.goldDeep],
);

const Color kNeonPink = LuxeColors.gold;
const Color kNeonPurple = LuxeColors.violet;
const Color kNeonBlue = LuxeColors.blue;
const Color kHomeNavy = LuxeColors.bg;
const Color kHomeNavyTop = LuxeColors.bgTop;
const List<Color> kNeonColors = [Color(0xFF5B3CFF), LuxeColors.violet, LuxeColors.blue, Color(0xFF5B3CFF)];
const LinearGradient kNeonGradient = LinearGradient(colors: kNeonColors);

/// Glass panel border (neon gradient + glow).
BoxDecoration neonBorder({double radius = 20, List<Color> colors = kNeonColors, double glow = 12, Color? glowColor}) =>
    LuxeDecor.border(radius: radius, colors: colors, glow: glow, glowColor: glowColor);

/// Glass panel fill.
BoxDecoration neonFill({double radius = 20}) => LuxeDecor.fill(radius: radius);

/// Top row: [Tivoo logo] [search pill] [♡] [🔔 badge].
class HomeHeader extends StatelessWidget {
  final VoidCallback? onSearchTap;
  final VoidCallback? onFavoritesTap;
  final VoidCallback? onNotificationsTap;
  final int notificationCount;

  /// Category pills shown under the hero banner (see [HomeCategoryTabs]).
  static const List<Map<String, dynamic>> categoryTabs = [
    {'label': 'Live', 'icon': Icons.sensors_rounded},
    {'label': 'PK Battle', 'icon': Icons.sports_kabaddi_rounded},
    {'label': 'Chat Room', 'icon': Icons.chat_bubble_rounded},
    {'label': 'Popular', 'icon': Icons.workspace_premium_rounded},
  ];

  const HomeHeader({
    super.key,
    this.onSearchTap,
    this.onFavoritesTap,
    this.onNotificationsTap,
    this.notificationCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Scale the row on narrow phones instead of squeezing it.
        final circle = (constraints.maxWidth * 0.11).clamp(38.0, 46.0);
        return Row(
          children: [
            // Logo scales down on narrow screens / large text instead of overflowing.
            // The wordmark gets up to 44% of the row and scales down on narrow phones.
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.4),
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: LuxeTivooLogo(size: 36),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SearchPill(onTap: onSearchTap, height: circle),
            ),
            const SizedBox(width: 8),
            _GoldCircleButton(
              size: circle,
              icon: Icons.favorite_border_rounded,
              label: 'Favorites',
              onTap: onFavoritesTap,
            ),
            const SizedBox(width: 8),
            _GoldCircleButton(
              size: circle,
              icon: Icons.notifications_none_rounded,
              label: 'Notifications',
              badge: notificationCount,
              onTap: onNotificationsTap,
            ),
          ],
        );
      },
    );
  }
}

class _SearchPill extends StatelessWidget {
  final VoidCallback? onTap;
  final double height;
  const _SearchPill({required this.onTap, required this.height});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.all(1.2),
        decoration: neonBorder(radius: height / 2, colors: LuxeColors.goldToNeon, glow: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: neonFill(radius: height / 2),
          child: const Row(
            children: [
              Icon(Icons.search_rounded, color: LuxeColors.gold, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Search',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: LuxeColors.textDim, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Neon glass circle button (heart / bell) with an optional red badge.
class _GoldCircleButton extends StatelessWidget {
  final double size;
  final IconData icon;
  final String label;
  final int badge;
  final VoidCallback? onTap;

  const _GoldCircleButton({
    required this.size,
    required this.icon,
    required this.label,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(1.4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [Color(0xFF5B3CFF), LuxeColors.violet, LuxeColors.blue, Color(0xFF5B3CFF)],
                  ),
                  boxShadow: [BoxShadow(color: Color(0x667B4DFF), blurRadius: 12)],
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [Color(0xFF241B5C), Color(0xFF0E0B2C)]),
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: Colors.white, size: size * 0.5),
                ),
              ),
              if (badge > 0)
                Positioned(
                  right: -3,
                  top: -3,
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 18),
                    height: 18,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFFF2D55), LuxeColors.pink]),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: kHomeNavy, width: 1.5),
                      boxShadow: const [BoxShadow(color: Color(0x88FF2D55), blurRadius: 6)],
                    ),
                    child: Text(
                      '$badge',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Category pills: [Live] [PK Battle] [Chat Room] [Popular], PK-style neon glass.
/// All four fit across the screen on phones (scrolls only when there is not enough room);
/// the selected pill fills with the neon gradient and glows.
class HomeCategoryTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const HomeCategoryTabs({super.key, required this.selectedIndex, required this.onSelected});

  /// Icon colour per tab so each one reads at a glance.
  static const List<List<Color>> _accents = [
    [Color(0xFFFF5C7A), Color(0xFFFF2D55)], // Live – red
    [Color(0xFFFF6FD8), Color(0xFF2E9BFF)], // PK – pink/blue
    [Color(0xFFC9A8FF), Color(0xFF8A3DFF)], // Chat – purple
    [Color(0xFFFFF1A8), Color(0xFFFFB300)], // Popular – gold
  ];

  @override
  Widget build(BuildContext context) {
    final tabs = HomeHeader.categoryTabs;
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        const side = 14.0;
        final available = constraints.maxWidth - side * 2 - gap * (tabs.length - 1);
        final height = (constraints.maxWidth * 0.115).clamp(44.0, 52.0);
        // One font size for every pill, from the room each pill gets ("Chat Room" is the
        // longest label). If that would be too small, the pills scroll at full size instead.
        final pillWidth = available / tabs.length;
        final fitFont = (pillWidth - height * 0.42 - 6 - 32) / 5.6;
        final fits = fitFont >= 12;
        final font = fits ? fitFont.clamp(12.0, 15.0) : 14.0;

        Widget pill(int i) => _CategoryPill(
          label: tabs[i]['label'] as String,
          icon: tabs[i]['icon'] as IconData,
          accent: _accents[i % _accents.length],
          selected: i == selectedIndex,
          height: height,
          fontSize: font,
          onTap: () => onSelected(i),
        );

        if (fits) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: side),
            child: Row(
              children: [
                for (var i = 0; i < tabs.length; i++) ...[
                  if (i > 0) const SizedBox(width: gap),
                  Expanded(child: pill(i)),
                ],
              ],
            ),
          );
        }
        return SizedBox(
          height: height + 8,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: side, vertical: 4),
            itemCount: tabs.length,
            separatorBuilder: (_, _) => const SizedBox(width: gap),
            itemBuilder: (_, i) => pill(i),
          ),
        );
      },
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<Color> accent;
  final bool selected;
  final double height;
  final double fontSize;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.label,
    required this.icon,
    required this.accent,
    required this.selected,
    required this.height,
    required this.fontSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = height / 2;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          height: height,
          padding: EdgeInsets.all(selected ? 1.6 : 1.1),
          decoration: neonBorder(
            radius: radius,
            colors: selected
                ? const [Color(0xFFFFF4C2), LuxeColors.gold, LuxeColors.goldDeep]
                : [LuxeColors.purple.withValues(alpha: 0.75), LuxeColors.blue.withValues(alpha: 0.55)],
            glow: selected ? 18 : 0,
            glowColor: const Color(0x99FFC928),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: selected
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(radius),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [LuxeColors.goldLight, LuxeColors.gold, LuxeColors.goldDeep],
                    ),
                  )
                : neonFill(radius: radius),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glossy highlight on the selected pill.
                if (selected)
                  Positioned(
                    top: 2,
                    left: 10,
                    right: 10,
                    height: height * 0.32,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(radius),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x55FFFFFF), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      label == 'PK Battle'
                          ? _CrossedSwordsIcon(size: height * 0.58, selected: selected)
                          : label == 'Chat Room'
                          ? _ChatRoomIcon(size: height * 0.58, selected: selected)
                          : selected
                          ? Icon(icon, size: height * 0.44, color: Colors.black)
                          : ShaderMask(
                              blendMode: BlendMode.srcIn,
                              shaderCallback: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: accent,
                              ).createShader,
                              child: Icon(icon, size: height * 0.42, color: Colors.white),
                            ),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: TextStyle(
                          color: selected ? Colors.black : Colors.white,
                          fontSize: fontSize,
                          fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                          shadows: selected ? const [Shadow(color: Color(0x33000000), blurRadius: 2)] : null,
                        ),
                      ),
                    ],
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

/// PK Battle icon: two crossed swords — a pink blade and a blue blade (the two PK sides)
/// with gold hilts and a spark where they clash.
class _CrossedSwordsIcon extends StatelessWidget {
  final double size;
  final bool selected;
  const _CrossedSwordsIcon({required this.size, required this.selected});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _SwordsPainter(selected: selected),
    );
  }
}

class _SwordsPainter extends CustomPainter {
  final bool selected;
  _SwordsPainter({required this.selected});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final c = Offset(s / 2, s / 2);
    final pink = selected ? const Color(0xFFFFD1EC) : const Color(0xFFFF4FB8);
    final blue = selected ? const Color(0xFFD3ECFF) : const Color(0xFF4FA8FF);

    // Pink blade points up-right, blue blade points up-left; they cross in the middle.
    _sword(canvas, s, angle: pi / 4, color: pink);
    _sword(canvas, s, angle: -pi / 4, color: blue);

    // Clash spark
    canvas.drawCircle(
      c.translate(0, -s * 0.06),
      s * 0.13,
      Paint()
        ..color = const Color(0xFFFFE082).withValues(alpha: 0.9)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.08),
    );
    final r = s * 0.11;
    final p = c.translate(0, -s * 0.06);
    canvas.drawPath(
      Path()
        ..moveTo(p.dx, p.dy - r)
        ..quadraticBezierTo(p.dx, p.dy, p.dx + r, p.dy)
        ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy + r)
        ..quadraticBezierTo(p.dx, p.dy, p.dx - r, p.dy)
        ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy - r)
        ..close(),
      Paint()..color = Colors.white,
    );
  }

  /// One sword drawn pointing up, rotated around the icon centre.
  void _sword(Canvas canvas, double s, {required double angle, required Color color}) {
    canvas.save();
    canvas.translate(s / 2, s / 2);
    canvas.rotate(angle);
    final len = s * 0.62;
    final w = s * 0.085;
    // Blade (tip at -len/2)
    final blade = Path()
      ..moveTo(0, -len / 2 - w)
      ..lineTo(w, -len / 2 + w * 0.6)
      ..lineTo(w * 0.8, len * 0.22)
      ..lineTo(-w * 0.8, len * 0.22)
      ..lineTo(-w, -len / 2 + w * 0.6)
      ..close();
    canvas.drawPath(
      blade,
      Paint()
        ..color = color.withValues(alpha: 0.7)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.05),
    );
    canvas.drawPath(
      blade,
      Paint()
        ..shader = LinearGradient(
          colors: [Colors.white, color],
        ).createShader(Rect.fromLTWH(-w, -len / 2 - w, w * 2, len)),
    );
    // Gold cross-guard, grip and pommel
    final gold = Paint()..color = const Color(0xFFFFC928);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(0, len * 0.25), width: w * 4.2, height: w * 0.9),
        Radius.circular(w * 0.45),
      ),
      gold,
    );
    canvas.drawRect(Rect.fromLTWH(-w * 0.45, len * 0.29, w * 0.9, len * 0.2), Paint()..color = const Color(0xFF8A5A00));
    canvas.drawCircle(Offset(0, len * 0.52), w * 0.75, gold);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SwordsPainter oldDelegate) => oldDelegate.selected != selected;
}

/// Chat Room icon: a violet → blue bubble behind a gold bubble with typing dots and a
/// sparkle. Turns dark on the selected (gold) pill.
class _ChatRoomIcon extends StatelessWidget {
  final double size;
  final bool selected;
  const _ChatRoomIcon({required this.size, required this.selected});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _ChatBubblesPainter(selected: selected),
    );
  }
}

class _ChatBubblesPainter extends CustomPainter {
  final bool selected;
  _ChatBubblesPainter({required this.selected});

  /// Rounded bubble with a small tail at the bottom left (or right when [tailRight]).
  Path _bubble(Rect r, {required bool tailRight}) {
    final radius = Radius.circular(r.height * 0.42);
    final path = Path()..addRRect(RRect.fromRectAndRadius(r, radius));
    final tx = tailRight ? r.right - r.width * 0.26 : r.left + r.width * 0.26;
    final dir = tailRight ? 1 : -1;
    path.addPath(
      Path()
        ..moveTo(tx - r.width * 0.12, r.bottom - 1)
        ..lineTo(tx + dir * r.width * 0.2, r.bottom + r.height * 0.32)
        ..lineTo(tx + r.width * 0.12, r.bottom - 1)
        ..close(),
      Offset.zero,
    );
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final back = Rect.fromLTWH(s * 0.02, s * 0.1, s * 0.62, s * 0.44);
    final front = Rect.fromLTWH(s * 0.3, s * 0.38, s * 0.68, s * 0.44);
    final backPath = _bubble(back, tailRight: false);
    final frontPath = _bubble(front, tailRight: true);

    final backColors = selected
        ? const [Color(0xFF4A2A8A), Color(0xFF2A1A5A)]
        : const [Color(0xFFD9B8FF), LuxeColors.violet, LuxeColors.blue];
    final frontColors = selected
        ? const [Color(0xFF3A2400), Color(0xFF1A1000)]
        : const [Color(0xFFFFF4C2), LuxeColors.gold, LuxeColors.goldDeep];

    if (!selected) {
      canvas.drawPath(
        backPath,
        Paint()
          ..color = LuxeColors.violet.withValues(alpha: 0.6)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.08),
      );
    }
    canvas.drawPath(
      backPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: backColors,
        ).createShader(back),
    );
    // Cut-out ring so the front bubble reads as sitting on top.
    canvas.drawPath(
      frontPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.07
        ..color = selected ? const Color(0xFFFFC928) : const Color(0xFF0E0B2C),
    );
    if (!selected) {
      canvas.drawPath(
        frontPath,
        Paint()
          ..color = LuxeColors.gold.withValues(alpha: 0.55)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.07),
      );
    }
    canvas.drawPath(
      frontPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: frontColors,
        ).createShader(front),
    );

    // Typing dots
    final dot = Paint()..color = selected ? LuxeColors.goldLight : const Color(0xFF3A2400);
    for (var i = 0; i < 3; i++) {
      canvas.drawCircle(Offset(front.left + front.width * (0.3 + i * 0.2), front.center.dy), s * 0.05, dot);
    }

    // Sparkle
    final p = Offset(s * 0.86, s * 0.16);
    final r = s * 0.12;
    canvas.drawPath(
      Path()
        ..moveTo(p.dx, p.dy - r)
        ..quadraticBezierTo(p.dx, p.dy, p.dx + r, p.dy)
        ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy + r)
        ..quadraticBezierTo(p.dx, p.dy, p.dx - r, p.dy)
        ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy - r)
        ..close(),
      Paint()..color = selected ? const Color(0xFF241500) : Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _ChatBubblesPainter oldDelegate) => oldDelegate.selected != selected;
}
