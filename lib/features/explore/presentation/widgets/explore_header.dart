import 'package:flutter/material.dart';

import '../../../../core/theme/luxe_theme.dart';

/// Floating Explore header: provides back navigation when pushed as a screen.
/// Upload and search buttons have been removed as requested for a clean full-screen feed.
class ExploreHeader extends StatelessWidget {
  /// Hidden when null (Explore is a tab).
  final VoidCallback? onBackTap;

  const ExploreHeader({
    super.key,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    if (onBackTap == null) {
      return const SizedBox.shrink();
    }
    final size = MediaQuery.sizeOf(context).width < 360 ? 36.0 : 40.0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Row(
        children: [
          LuxeCircleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            label: 'Back',
            size: size,
            onTap: onBackTap,
          ),
        ],
      ),
    );
  }
}

