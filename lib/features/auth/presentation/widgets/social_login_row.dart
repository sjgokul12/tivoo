import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/widgets/gradient_mask.dart';
import '../../../../data/repositories/auth_repository.dart';

class SocialLoginRow extends StatelessWidget {
  const SocialLoginRow({super.key, required this.onSelected});

  final ValueChanged<SocialProvider> onSelected;

  static const _googleGradient = SweepGradient(
    colors: [Color(0xFFEA4335), Color(0xFFFBBC05), Color(0xFF34A853), Color(0xFF4285F4), Color(0xFFEA4335)],
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _SocialButton(
          label: 'Google',
          onTap: () => onSelected(SocialProvider.google),
          child: const GradientMask(
            gradient: _googleGradient,
            child: FaIcon(FontAwesomeIcons.google, size: 20),
          ),
        ),
        _SocialButton(
          label: 'Facebook',
          onTap: () => onSelected(SocialProvider.facebook),
          child: const FaIcon(FontAwesomeIcons.facebook, color: Color(0xFF1877F2), size: 23),
        ),
        _SocialButton(
          label: 'Apple',
          onTap: () => onSelected(SocialProvider.apple),
          child: const FaIcon(FontAwesomeIcons.apple, color: Colors.white, size: 23),
        ),
        _SocialButton(
          label: 'Phone',
          highlight: true,
          onTap: () => onSelected(SocialProvider.phone),
          child: const Icon(Icons.phone_iphone_rounded, color: Color(0xFFC89BFF), size: 22),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.child,
    required this.onTap,
    this.highlight = false,
  });

  final String label;
  final Widget child;
  final VoidCallback onTap;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Continue with $label',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Ink(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0E1236).withValues(alpha: 0.6),
              border: Border.all(
                color: highlight ? const Color(0xAAB07BFF) : const Color(0x808DA2FF),
              ),
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
