import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';

class SocialLoginButtons extends StatelessWidget {
  final VoidCallback onGoogleTap;
  final VoidCallback onAppleTap;
  final VoidCallback onFacebookTap;

  const SocialLoginButtons({
    super.key,
    required this.onGoogleTap,
    required this.onAppleTap,
    required this.onFacebookTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Google Button
        Expanded(
          child: _buildSocialButton(
            icon: Image.asset(
              AppAssets.logoGoogle,
              width: 19,
              height: 19,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  _buildGoogleFallback(),
            ),
            label: 'Google',
            onTap: onGoogleTap,
          ),
        ),

        const SizedBox(width: 8),

        // Apple Button
        Expanded(
          child: _buildSocialButton(
            icon: Image.asset(
              AppAssets.logoApple,
              width: 19,
              height: 19,
              fit: BoxFit.contain,
              color: Colors.white,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.apple, color: Colors.white, size: 19),
            ),
            label: 'Apple',
            onTap: onAppleTap,
          ),
        ),

        const SizedBox(width: 8),

        // Facebook Button
        Expanded(
          child: _buildSocialButton(
            icon: Image.asset(
              AppAssets.logoFacebook,
              width: 19,
              height: 19,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.facebook, color: Color(0xFF1877F2), size: 19),
            ),
            label: 'Facebook',
            onTap: onFacebookTap,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: const Color(0x9913131E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.12),
              width: 0.8,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleFallback() {
    return Container(
      width: 19,
      height: 19,
      alignment: Alignment.center,
      child: const Text(
        'G',
        style: TextStyle(
          color: Color(0xFFEA4335),
          fontWeight: FontWeight.w900,
          fontSize: 15,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }
}
