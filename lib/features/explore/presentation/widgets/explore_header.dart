import 'package:flutter/material.dart';

import '../../../../core/theme/luxe_theme.dart';
import '../../../../core/widgets/glow_icon_button.dart';

/// Floating Explore header: back (when pushed) on the left, search on the right.
class ExploreHeader extends StatelessWidget {
  final VoidCallback onSearchTap;
  final VoidCallback? onUploadTap;

  /// Hidden when null (Explore is a tab).
  final VoidCallback? onBackTap;

  const ExploreHeader({
    super.key,
    required this.onSearchTap,
    this.onBackTap,
    this.onUploadTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context).width < 360 ? 36.0 : 40.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          if (onBackTap != null)
            LuxeCircleButton(icon: Icons.arrow_back_ios_new_rounded, label: 'Back', size: size, onTap: onBackTap),
          const Spacer(),
          if (onUploadTap != null) ...[
            GlowIconButton(
              icon: Icons.cloud_upload_outlined,
              size: size,
              iconSize: size * 0.52,
              backgroundColor: Colors.black.withValues(alpha: 0.35),
              onTap: onUploadTap,
            ),
            const SizedBox(width: 8),
          ],
          GlowIconButton(
            icon: Icons.search_rounded,
            size: size,
            iconSize: size * 0.5,
            backgroundColor: Colors.black.withValues(alpha: 0.35),
            onTap: onSearchTap,
          ),
        ],
      ),
    );
  }
}
