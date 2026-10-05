import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/widgets/animations.dart';
import '../../providers/shell_tab_provider.dart';

/// Floating pitch-black tab bar inside a soft frosted gradient frame.
/// Active tab: solid white icon + label; others: muted grey. "Go Live"
/// carries a gradient "LIVE" pill badge.
class GlassBottomNav extends StatelessWidget {
  const GlassBottomNav({super.key, required this.current, required this.onSelected});

  final ShellTab current;
  final ValueChanged<ShellTab> onSelected;

  static const _barHeight = 64.0;
  static const _frame = 9.0;

  static const _items = [
    (ShellTab.home, FontAwesomeIcons.solidHouse, 'Home'),
    (ShellTab.discover, FontAwesomeIcons.solidCompass, 'Discover'),
    (ShellTab.goLive, FontAwesomeIcons.towerBroadcast, 'Go Live'),
    (ShellTab.messages, FontAwesomeIcons.solidCommentDots, 'Messages'),
    (ShellTab.profile, FontAwesomeIcons.solidUser, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, bottomInset + 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: DecoratedBox(
            // Soft pastel frame around the black bar.
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(34),
              gradient: const LinearGradient(
                colors: [Color(0x66F0A8D0), Color(0x55C8B8F0), Color(0x669AA8FF)],
              ),
              border: Border.all(color: const Color(0x40FFFFFF)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(_frame),
              child: Container(
                height: _barHeight,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Row(
                  children: [
                    for (final (tab, icon, label) in _items)
                      Expanded(
                        child: _NavItem(
                          icon: icon,
                          label: label,
                          active: current == tab,
                          badge: tab == ShellTab.goLive ? 'LIVE' : null,
                          dot: tab == ShellTab.messages,
                          onTap: () => onSelected(tab),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.badge,
    this.dot = false,
  });

  static const _idle = Color(0xFF6C6C76);

  final FaIconData icon;
  final String label;
  final bool active;
  final String? badge;
  final bool dot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.white : _idle;
    return Semantics(
      button: true,
      selected: active,
      label: label,
      child: Pressable(
        onTap: onTap,
        scale: 0.85,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 26,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  AnimatedScale(
                    scale: active ? 1.12 : 1,
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutBack,
                    child: TweenAnimationBuilder<Color?>(
                      tween: ColorTween(end: color),
                      duration: const Duration(milliseconds: 220),
                      builder: (_, c, _) => FaIcon(icon, size: 21, color: c),
                    ),
                  ),
                  if (badge != null) Positioned(top: -12, child: _Badge(text: badge!)),
                  if (dot)
                    Positioned(
                      right: -5,
                      top: -2,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: Color(0xFFFF2D6F), shape: BoxShape.circle),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              style: TextStyle(
                fontFamily: 'Poppins',
                color: color,
                fontSize: 11,
                height: 1.2,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
              ),
              child: Text(label, maxLines: 1),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gradient pill badge ("LIVE") with a gentle pulse.
class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Breathing(
      scale: 0.08,
      period: const Duration(milliseconds: 1400),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: const LinearGradient(colors: [Color(0xFFE0569B), Color(0xFF6C63FF)]),
          border: Border.all(color: const Color(0x99FFFFFF)),
          boxShadow: const [BoxShadow(color: Color(0x80B44CFF), blurRadius: 8)],
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}
