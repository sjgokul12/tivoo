// Generator for the home banner artwork in assets/banners/.
// Run: flutter test tool/generate_banners_test.dart --update-goldens
// It writes banner_*.png; the app uses JPG copies of them (banner_*.jpg, quality 90).

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _w = 1280.0;
const _h = 560.0;

const gold = Color(0xFFFFC928);
const goldLight = Color(0xFFFFE680);
const goldPale = Color(0xFFFFF4C2);
const goldDeep = Color(0xFFE59A00);
const violet = Color(0xFFB04DFF);
const purple = Color(0xFF7B4DFF);
const pink = Color(0xFFFF2D78);
const blue = Color(0xFF3D8BFF);

// --- Shared helpers ----------------------------------------------------------

List<double> _even(int n) => [for (var i = 0; i < n; i++) i / (n - 1)];
Shader lin(Offset a, Offset b, List<Color> c, [List<double>? s]) => ui.Gradient.linear(a, b, c, s ?? _even(c.length));
Shader rad(Offset o, double r, List<Color> c, [List<double>? s]) => ui.Gradient.radial(o, r, c, s ?? _even(c.length));

void glow(Canvas c, Offset p, double r, Color color) {
  c.drawCircle(
    p,
    r,
    Paint()..shader = RadialGradient(colors: [color, color.withValues(alpha: 0)]).createShader(Rect.fromCircle(center: p, radius: r)),
  );
}

void beam(Canvas c, Offset from, Offset to, double width, Color color) {
  final dir = (to - from);
  final n = Offset(-dir.dy, dir.dx) / dir.distance;
  final path = Path()
    ..moveTo(from.dx, from.dy)
    ..lineTo(to.dx + n.dx * width, to.dy + n.dy * width)
    ..lineTo(to.dx - n.dx * width, to.dy - n.dy * width)
    ..close();
  c.drawPath(
    path,
    Paint()
      ..shader = lin(from, to, [color, color.withValues(alpha: 0)])
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
  );
}

void sparkle(Canvas c, Offset p, double s, {Color color = Colors.white}) {
  glow(c, p, s * 2.4, color.withValues(alpha: 0.55));
  final path = Path()
    ..moveTo(p.dx, p.dy - s * 2)
    ..quadraticBezierTo(p.dx, p.dy, p.dx + s * 2, p.dy)
    ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy + s * 2)
    ..quadraticBezierTo(p.dx, p.dy, p.dx - s * 2, p.dy)
    ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy - s * 2)
    ..close();
  c.drawPath(path, Paint()..color = color);
}

void bokeh(Canvas c, int seed, List<Color> colors, {double minX = 0.35}) {
  final rnd = math.Random(seed);
  for (var i = 0; i < 46; i++) {
    final p = Offset(_w * (minX + rnd.nextDouble() * (1 - minX)), _h * rnd.nextDouble());
    final r = 3 + rnd.nextDouble() * 16;
    final col = colors[i % colors.length].withValues(alpha: 0.12 + rnd.nextDouble() * 0.35);
    c.drawCircle(p, r, Paint()..color = col..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.6));
  }
  for (var i = 0; i < 14; i++) {
    sparkle(c, Offset(_w * (minX + rnd.nextDouble() * (1 - minX)), _h * rnd.nextDouble()), 2 + rnd.nextDouble() * 4,
        color: i.isEven ? goldPale : Colors.white);
  }
}

void confetti(Canvas c, int seed, {double minX = 0.4}) {
  final rnd = math.Random(seed);
  const cols = [gold, goldLight, pink, violet, blue, Color(0xFF3DDC97)];
  for (var i = 0; i < 70; i++) {
    final p = Offset(_w * (minX + rnd.nextDouble() * (1 - minX)), _h * rnd.nextDouble());
    c.save();
    c.translate(p.dx, p.dy);
    c.rotate(rnd.nextDouble() * math.pi);
    final w = 6 + rnd.nextDouble() * 10;
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: w, height: w * 0.45), const Radius.circular(2)),
      Paint()..color = cols[i % cols.length].withValues(alpha: 0.75 + rnd.nextDouble() * 0.25),
    );
    c.restore();
  }
}

/// Dark left side so the headline reads well.
void textShade(Canvas c) {
  c.drawRect(
    const Rect.fromLTWH(0, 0, _w, _h),
    Paint()
      ..shader = lin(const Offset(0, 0), const Offset(_w * 0.62, 0), [
        const Color(0xE6070616),
        const Color(0x99070616),
        const Color(0x00070616),
      ], [0, 0.55, 1]),
  );
}

// --- 1. Live stage: golden microphone under spotlights --------------------------

class LivePainter extends CustomPainter {
  @override
  void paint(Canvas c, Size size) {
    c.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = lin(Offset.zero, Offset(_w, _h), [
          const Color(0xFF12052E),
          const Color(0xFF3A0B5E),
          const Color(0xFF1A0838),
        ], [0, 0.6, 1]),
    );
    const mic = Offset(_w * 0.74, _h * 0.47);
    // Stage floor glow
    c.drawOval(
      Rect.fromCenter(center: const Offset(_w * 0.74, _h * 0.98), width: 760, height: 150),
      Paint()
        ..shader = rad(const Offset(_w * 0.74, _h * 0.98), 380, [const Color(0x99B04DFF), const Color(0x00B04DFF)]),
    );
    // Spotlights
    beam(c, const Offset(_w * 0.5, -40), mic + const Offset(-40, 230), 150, const Color(0x66FFE680));
    beam(c, const Offset(_w * 0.98, -40), mic + const Offset(40, 230), 150, const Color(0x55B04DFF));
    beam(c, const Offset(_w * 0.76, -60), mic + const Offset(0, 250), 120, const Color(0x55FFC928));
    bokeh(c, 7, [gold, violet, pink]);
    glow(c, mic, 300, const Color(0x88FFC928));
    glow(c, mic, 160, const Color(0x66FFF4C2));

    // Sound waves
    for (var i = 1; i <= 3; i++) {
      for (final side in [-1.0, 1.0]) {
        final r = 120.0 + i * 46;
        c.drawArc(
          Rect.fromCircle(center: mic + const Offset(0, -40), radius: r),
          side < 0 ? math.pi * 0.78 : -math.pi * 0.22,
          math.pi * 0.44,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 5
            ..strokeCap = StrokeCap.round
            ..color = (i.isOdd ? violet : pink).withValues(alpha: 0.9 - i * 0.2)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        );
      }
    }

    _microphone(c, mic);
    confetti(c, 11);
    textShade(c);
  }

  void _microphone(Canvas c, Offset m) {
    // Stand
    final stand = Paint()
      ..shader = lin(m + const Offset(-10, 0), m + const Offset(10, 0), [goldDeep, goldPale, goldDeep]);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: m + const Offset(0, 190), width: 14, height: 200), const Radius.circular(7)), stand);
    c.drawOval(Rect.fromCenter(center: m + const Offset(0, 292), width: 170, height: 34), stand);
    // Handle (tapered)
    final handle = Path()
      ..moveTo(m.dx - 42, m.dy + 20)
      ..lineTo(m.dx + 42, m.dy + 20)
      ..lineTo(m.dx + 22, m.dy + 150)
      ..quadraticBezierTo(m.dx, m.dy + 162, m.dx - 22, m.dy + 150)
      ..close();
    c.drawPath(
      handle,
      Paint()..shader = lin(m + const Offset(-42, 0), m + const Offset(42, 0), [const Color(0xFF9A6A00), goldLight, gold, const Color(0xFF8A5A00)], [0, 0.35, 0.6, 1]),
    );
    // Head
    final head = Rect.fromCenter(center: m + const Offset(0, -70), width: 150, height: 180);
    final headRRect = RRect.fromRectAndRadius(head, const Radius.circular(75));
    c.drawRRect(
      headRRect,
      Paint()..shader = rad(head.center + const Offset(-30, -40), 140, [goldPale, gold, goldDeep, const Color(0xFF7A4A00)], [0, 0.3, 0.7, 1]),
    );
    // Grille
    c.save();
    c.clipRRect(headRRect.deflate(10));
    final grille = Paint()
      ..color = const Color(0x667A4A00)
      ..strokeWidth = 2.2;
    for (var x = head.left - head.height; x < head.right; x += 13) {
      c.drawLine(Offset(x, head.top), Offset(x + head.height, head.bottom), grille);
      c.drawLine(Offset(x + head.height, head.top), Offset(x, head.bottom), grille);
    }
    c.restore();
    // Highlight
    c.drawOval(
      Rect.fromCenter(center: head.center + const Offset(-32, -44), width: 40, height: 70),
      Paint()..color = Colors.white.withValues(alpha: 0.45)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    // Band
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: m + const Offset(0, 18), width: 120, height: 26), const Radius.circular(10)),
      Paint()..shader = lin(m + const Offset(-60, 0), m + const Offset(60, 0), [const Color(0xFF6A3FD0), violet, const Color(0xFF5B2FB0)]),
    );
    sparkle(c, head.topRight + const Offset(-20, 26), 10);
    sparkle(c, m + const Offset(-80, 90), 6, color: goldPale);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- 2. PK: crossed neon swords over a lightning clash ------------------------

class PkPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size size) {
    c.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF0A0722));
    // Pink (top-left) vs blue (bottom-right) halves
    c.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(_w * 0.86, 0)
        ..lineTo(_w * 0.62, _h)
        ..lineTo(0, _h)
        ..close(),
      Paint()..shader = rad(const Offset(_w * 0.58, _h * 0.4), 520, [const Color(0xAAFF2D9A), const Color(0x00FF2D9A)]),
    );
    c.drawPath(
      Path()
        ..moveTo(_w * 0.86, 0)
        ..lineTo(_w, 0)
        ..lineTo(_w, _h)
        ..lineTo(_w * 0.62, _h)
        ..close(),
      Paint()..shader = rad(const Offset(_w * 0.9, _h * 0.6), 520, [const Color(0xAA2E7BFF), const Color(0x002E7BFF)]),
    );
    const center = Offset(_w * 0.74, _h * 0.5);
    // Energy rings
    for (var i = 0; i < 3; i++) {
      c.drawCircle(
        center,
        150.0 + i * 50,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..shader = SweepGradient(colors: const [pink, violet, blue, violet, pink], transform: GradientRotation(i * 0.7))
              .createShader(Rect.fromCircle(center: center, radius: 250))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
    bokeh(c, 21, [pink, blue, violet]);
    // Lightning bolt behind the clash
    final bolt = Path()
      ..moveTo(_w * 0.75, -10)
      ..lineTo(_w * 0.71, _h * 0.4)
      ..lineTo(_w * 0.76, _h * 0.42)
      ..lineTo(_w * 0.7, _h * 1.05)
      ..lineTo(_w * 0.79, _h * 0.36)
      ..lineTo(_w * 0.74, _h * 0.34)
      ..close();
    c.drawPath(bolt, Paint()..color = const Color(0xCCFFE680)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26));
    c.drawPath(bolt, Paint()..shader = lin(const Offset(0, 0), const Offset(0, _h), [goldPale, gold, goldDeep]));
    glow(c, center, 170, const Color(0x99FFF4C2));

    _sword(c, center, math.pi / 4, const Color(0xFFFF4FB8));
    _sword(c, center, -math.pi / 4, const Color(0xFF4FA8FF));

    // Sparks
    final rnd = math.Random(5);
    for (var i = 0; i < 26; i++) {
      final a = rnd.nextDouble() * math.pi * 2;
      final r1 = 40 + rnd.nextDouble() * 40;
      final r2 = r1 + 40 + rnd.nextDouble() * 120;
      c.drawLine(
        center + Offset(math.cos(a), math.sin(a)) * r1,
        center + Offset(math.cos(a), math.sin(a)) * r2,
        Paint()
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..color = (i.isEven ? goldLight : Colors.white).withValues(alpha: 0.8),
      );
    }
    sparkle(c, center + const Offset(0, -10), 26);
    textShade(c);
  }

  void _sword(Canvas c, Offset center, double angle, Color color) {
    c.save();
    c.translate(center.dx, center.dy);
    c.rotate(angle);
    const len = 420.0;
    const w = 26.0;
    final blade = Path()
      ..moveTo(0, -len / 2 - 30)
      ..lineTo(w, -len / 2 + 20)
      ..lineTo(w * 0.85, len * 0.2)
      ..lineTo(-w * 0.85, len * 0.2)
      ..lineTo(-w, -len / 2 + 20)
      ..close();
    c.drawPath(blade, Paint()..color = color.withValues(alpha: 0.85)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22));
    c.drawPath(blade, Paint()..shader = lin(const Offset(-w, 0), const Offset(w, 0), [color, Colors.white, color]));
    c.drawLine(const Offset(0, -len / 2 - 10), const Offset(0, len * 0.18), Paint()..color = Colors.white.withValues(alpha: 0.8)..strokeWidth = 3);
    final goldPaint = Paint()..shader = lin(const Offset(-70, 0), const Offset(70, 0), [goldDeep, goldPale, gold, goldDeep], [0, 0.4, 0.6, 1]);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: const Offset(0, len * 0.23), width: 150, height: 24), const Radius.circular(12)), goldPaint);
    c.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(-12, len * 0.25, 24, 80), const Radius.circular(6)), Paint()..color = const Color(0xFF5A2A8A));
    c.drawCircle(const Offset(0, len * 0.25 + 92), 20, goldPaint);
    c.drawCircle(const Offset(0, len * 0.23), 9, Paint()..color = pink);
    c.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// --- 3. Gifts: glowing gift box with a light burst and coins -------------------

class GiftPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size size) {
    c.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = lin(Offset.zero, Offset(_w, _h), [
          const Color(0xFF1A0A2E),
          const Color(0xFF3A1250),
          const Color(0xFF140A30),
        ]),
    );
    const box = Offset(_w * 0.74, _h * 0.58);
    // Light burst
    for (var i = 0; i < 24; i++) {
      final a = i * math.pi * 2 / 24;
      final p1 = box + Offset(math.cos(a - 0.05), math.sin(a - 0.05)) * 700;
      final p2 = box + Offset(math.cos(a + 0.05), math.sin(a + 0.05)) * 700;
      c.drawPath(
        Path()
          ..moveTo(box.dx, box.dy)
          ..lineTo(p1.dx, p1.dy)
          ..lineTo(p2.dx, p2.dy)
          ..close(),
        Paint()..shader = rad(box, 600, [(i.isEven ? gold : violet).withValues(alpha: 0.35), Colors.transparent]),
      );
    }
    glow(c, box, 320, const Color(0x99FFC928));
    bokeh(c, 33, [gold, pink, violet]);
    _giftBox(c, box);
    // Coins
    final rnd = math.Random(9);
    for (var i = 0; i < 9; i++) {
      final p = Offset(_w * (0.5 + rnd.nextDouble() * 0.48), _h * (0.08 + rnd.nextDouble() * 0.8));
      if ((p - box).distance < 190) continue;
      _coin(c, p, 18 + rnd.nextDouble() * 20, rnd.nextDouble() * 0.8 - 0.4);
    }
    // Hearts
    for (final (x, y, s) in const [(0.55, 0.25, 30.0), (0.92, 0.2, 24.0), (0.6, 0.82, 20.0)]) {
      _heart(c, Offset(_w * x, _h * y), s);
    }
    sparkle(c, box + const Offset(-120, -150), 14);
    sparkle(c, box + const Offset(140, -90), 10, color: goldPale);
    textShade(c);
  }

  void _giftBox(Canvas c, Offset b) {
    const bw = 230.0, bh = 170.0, lidH = 54.0;
    final front = Rect.fromCenter(center: b + const Offset(0, 50), width: bw, height: bh);
    c.drawRRect(
      RRect.fromRectAndRadius(front, const Radius.circular(10)),
      Paint()..shader = lin(front.topLeft, front.bottomRight, [const Color(0xFF9B3CFF), const Color(0xFF5B1FB0), const Color(0xFF3A1080)]),
    );
    final lid = Rect.fromCenter(center: b + Offset(0, 50 - bh / 2 - lidH / 2 + 6), width: bw + 30, height: lidH);
    c.drawRRect(
      RRect.fromRectAndRadius(lid, const Radius.circular(12)),
      Paint()..shader = lin(lid.topLeft, lid.bottomRight, [const Color(0xFFB86BFF), const Color(0xFF7B2FE0)]),
    );
    final ribbon = Paint()..shader = lin(Offset(b.dx - 22, 0), Offset(b.dx + 22, 0), [goldDeep, goldPale, gold, goldDeep], [0, 0.4, 0.6, 1]);
    c.drawRect(Rect.fromCenter(center: Offset(b.dx, front.center.dy), width: 40, height: bh), ribbon);
    c.drawRect(Rect.fromCenter(center: lid.center, width: 40, height: lidH), ribbon);
    c.drawRect(Rect.fromCenter(center: front.center + const Offset(0, -10), width: bw, height: 30), ribbon);
    // Bow
    for (final side in [-1.0, 1.0]) {
      c.save();
      c.translate(b.dx, lid.top);
      c.rotate(side * 0.5);
      c.drawOval(
        Rect.fromCenter(center: Offset(side * 50, -30), width: 100, height: 60),
        Paint()..shader = rad(Offset(side * 40, -40), 70, [goldPale, gold, goldDeep]),
      );
      c.drawOval(Rect.fromCenter(center: Offset(side * 50, -30), width: 50, height: 24), Paint()..color = const Color(0x557A4A00));
      c.restore();
    }
    c.drawCircle(Offset(b.dx, lid.top - 4), 20, Paint()..shader = rad(Offset(b.dx - 5, lid.top - 9), 24, [goldPale, goldDeep]));
    // Highlight
    c.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(front.left + 14, front.top + 14, 40, bh - 40), const Radius.circular(20)),
      Paint()..color = Colors.white.withValues(alpha: 0.18)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  void _coin(Canvas c, Offset p, double r, double tilt) {
    c.save();
    c.translate(p.dx, p.dy);
    c.scale(1, 0.85 + tilt.abs() * 0.1);
    glow(c, Offset.zero, r * 1.8, const Color(0x66FFC928));
    c.drawCircle(Offset.zero, r, Paint()..shader = rad(Offset(-r * 0.3, -r * 0.3), r * 1.3, [goldPale, gold, goldDeep]));
    c.drawCircle(Offset.zero, r * 0.72, Paint()..style = PaintingStyle.stroke..strokeWidth = r * 0.1..color = const Color(0x99A06A00));
    sparkle(c, Offset.zero, r * 0.22, color: const Color(0xFFFFF8E0));
    c.restore();
  }

  void _heart(Canvas c, Offset p, double s) {
    final path = Path()
      ..moveTo(p.dx, p.dy + s * 0.9)
      ..cubicTo(p.dx - s * 1.4, p.dy, p.dx - s * 0.7, p.dy - s * 1.0, p.dx, p.dy - s * 0.35)
      ..cubicTo(p.dx + s * 0.7, p.dy - s * 1.0, p.dx + s * 1.4, p.dy, p.dx, p.dy + s * 0.9)
      ..close();
    c.drawPath(path, Paint()..color = pink.withValues(alpha: 0.8)..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.5));
    c.drawPath(path, Paint()..shader = lin(p + Offset(0, -s), p + Offset(0, s), [const Color(0xFFFF8FC0), pink]));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void main() {
  for (final (name, painter) in [
    ('banner_live', LivePainter()),
    ('banner_pk', PkPainter()),
    ('banner_gifts', GiftPainter()),
  ]) {
    testWidgets('generate $name', (tester) async {
      tester.view.physicalSize = const Size(_w, _h);
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(
        RepaintBoundary(child: CustomPaint(painter: painter, size: const Size(_w, _h))),
      );
      await expectLater(find.byType(RepaintBoundary).first, matchesGoldenFile('../assets/banners/$name.png'));
    });
  }
}
