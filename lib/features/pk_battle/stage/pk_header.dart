// Top banner (PKtop.png) with back arrow and tappable hosts.

import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../core/pk_theme.dart';

/// Full-width "Neha · PK BATTLE · Arun" banner (assets/PKtop.png) with the back
/// arrow in the top-left corner. Avatars, Follow buttons and the PK emblem in
/// the artwork stay tappable through invisible hit areas.
class PkHeader extends StatelessWidget {
  final bool isFollowingLeft;
  final bool isFollowingRight;
  final VoidCallback onBack;
  final VoidCallback onEmblemTap;
  final ValueChanged<bool> onFollowTap; // true = left host
  final ValueChanged<bool> onHostTap; // true = left host

  const PkHeader({
    super.key,
    required this.isFollowingLeft,
    required this.isFollowingRight,
    required this.onBack,
    required this.onEmblemTap,
    required this.onFollowTap,
    required this.onHostTap,
  });

  // Artwork is 1536×1024. We show the band y = 170…700 (crown + cards + BATTLE)
  // at 90% of the screen width, centred.
  static const double _imgW = 1536;
  static const double _imgH = 1024;
  static const double _cropTop = 170;
  static const double _cropHeight = 530;
  static const double _widthFactor = 0.8;
  static const double _alignY = 2 * _cropTop / (_imgH - _cropHeight) - 1;

  // Hit areas in artwork pixels.
  static const _leftAvatar = Rect.fromLTRB(46, 371, 270, 595);
  static const _rightAvatar = Rect.fromLTRB(1266, 380, 1490, 604);
  static const _leftFollow = Rect.fromLTRB(258, 553, 526, 640);
  static const _rightFollow = Rect.fromLTRB(1002, 560, 1278, 648);
  static const _emblem = Rect.fromLTRB(560, 200, 975, 660);

  /// Centre of a host's profile photo inside the header, for a header [width] wide.
  static Offset avatarCenter({required bool isLeft, required double width}) {
    final bannerWidth = width * _widthFactor;
    final scale = bannerWidth / _imgW;
    final r = isLeft ? _leftAvatar : _rightAvatar;
    return Offset((width - bannerWidth) / 2 + r.center.dx * scale, (r.center.dy - _cropTop) * scale);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final bannerWidth = width * _widthFactor;
        final left = (width - bannerWidth) / 2;
        final scale = bannerWidth / _imgW;

        Widget hitArea(Rect r, VoidCallback onTap, String label, {Widget? child}) {
          return Positioned(
            left: left + r.left * scale,
            top: (r.top - _cropTop) * scale,
            width: r.width * scale,
            height: r.height * scale,
            child: Semantics(
              button: true,
              label: label,
              child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: child),
            ),
          );
        }

        return SizedBox(
          width: width,
          height: _cropHeight * scale,
          child: Stack(
            children: [
              Positioned(
                left: left,
                width: bannerWidth,
                top: 0,
                bottom: 0,
                child: ShaderMask(
                  // Soft fade at the bottom so the banner melts into the background.
                  blendMode: BlendMode.dstIn,
                  shaderCallback: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.white, Colors.white, Colors.transparent],
                    stops: [0, 0.92, 1],
                  ).createShader,
                  child: Image.asset(
                    AppAssets.pkTopBanner,
                    fit: BoxFit.cover,
                    alignment: const Alignment(0, _alignY),
                    filterQuality: FilterQuality.medium,
                  ),
                ),
              ),
              hitArea(_emblem, onEmblemTap, 'Start PK battle'),
              hitArea(_leftAvatar, () => onHostTap(true), 'Open left host profile'),
              hitArea(_rightAvatar, () => onHostTap(false), 'Open right host profile'),
              hitArea(
                _leftFollow,
                () => onFollowTap(true),
                'Follow left host',
                child: isFollowingLeft ? const _FollowingChip(isLeft: true) : null,
              ),
              hitArea(
                _rightFollow,
                () => onFollowTap(false),
                'Follow right host',
                child: isFollowingRight ? const _FollowingChip(isLeft: false) : null,
              ),
              Positioned(left: 8, top: 2, child: _BackButton(onTap: onBack)),
            ],
          ),
        );
      },
    );
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0x66070A18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 15),
        ),
      ),
    );
  }
}

/// Drawn over the artwork's Follow button once the user follows that host.
class _FollowingChip extends StatelessWidget {
  final bool isLeft;
  const _FollowingChip({required this.isLeft});

  @override
  Widget build(BuildContext context) {
    final accent = PkColors.side(isLeft);
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF141A33),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: accent, width: 1.2),
        boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.45), blurRadius: 8)],
      ),
      child: const FittedBox(
        child: Text(
          'Following',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
