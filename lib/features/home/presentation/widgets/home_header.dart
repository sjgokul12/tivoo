import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/snackbar.dart';
import '../../../../core/widgets/animations.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/tivoo_logo.dart';
import '../../../pk/presentation/pk_battle_screen.dart';
import '../../../search/presentation/search_screen.dart';
import '../../../shell/providers/shell_tab_provider.dart';

/// 3D Tivoo wordmark + glass action buttons: search, PK, chats, notifications.
class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = context.scaled(42).clamp(36.0, 50.0);
    final gap = SizedBox(width: size * 0.22);

    return Row(
      children: [
        const Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: TivooLogo(fontSize: 44),
          ),
        ),
        const SizedBox(width: 10),
        _GlassAction(
          size: size,
          tooltip: 'Search',
          icon: Icon(Icons.search_rounded, size: size * 0.52),
          onTap: () => Navigator.of(context).push(SearchScreen.route()),
        ),
        gap,
        _GlassAction(
          size: size,
          tooltip: 'PK Battle',
          glow: AppColors.gold,
          icon: FaIcon(FontAwesomeIcons.crown, size: size * 0.4),
          onTap: () => Navigator.of(context).push(PkBattleScreen.route()),
        ),
        gap,
        _GlassAction(
          size: size,
          tooltip: 'Chats',
          badge: true,
          icon: FaIcon(FontAwesomeIcons.commentDots, size: size * 0.42),
          onTap: () => ref.read(shellTabProvider.notifier).select(ShellTab.messages),
        ),
        gap,
        _GlassAction(
          size: size,
          tooltip: 'Notifications',
          badge: true,
          icon: Icon(Icons.notifications_none_rounded, size: size * 0.56),
          onTap: () => context.showAppSnackBar('You are all caught up ✨'),
        ),
      ],
    );
  }
}

/// Dark glass circle with a thin light rim, soft neon halo and a white icon.
class _GlassAction extends StatelessWidget {
  const _GlassAction({
    required this.size,
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.glow = AppColors.purple,
    this.badge = false,
  });

  final double size;
  final Widget icon;
  final VoidCallback onTap;
  final String tooltip;
  final Color glow;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Pressable(
        onTap: onTap,
        scale: 0.86,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
              foregroundPainter: GradientBorderPainter(
                radius: size / 2,
                width: 1.3,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color(0xB3FFFFFF), const Color(0x1AFFFFFF), glow.withValues(alpha: 0.8)],
                ),
              ),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    center: Alignment(-0.35, -0.55),
                    radius: 1.05,
                    colors: [Color(0xFF242050), Color(0xFF07061A)],
                  ),
                  boxShadow: [
                    BoxShadow(color: glow.withValues(alpha: 0.45), blurRadius: 14, blurStyle: BlurStyle.outer),
                    const BoxShadow(color: Color(0x99000000), blurRadius: 8, offset: Offset(0, 4)),
                  ],
                ),
                alignment: Alignment.center,
                child: IconTheme(
                  data: const IconThemeData(
                    color: Colors.white,
                    shadows: [Shadow(color: Color(0x99FFFFFF), blurRadius: 8)],
                  ),
                  child: icon,
                ),
              ),
            ),
            if (badge)
              Positioned(
                right: size * 0.1,
                top: size * 0.08,
                child: Breathing(
                  scale: 0.3,
                  period: const Duration(milliseconds: 1200),
                  child: Container(
                    width: size * 0.2,
                    height: size * 0.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.liveGradient,
                      border: Border.all(color: AppColors.background, width: 1.2),
                      boxShadow: const [BoxShadow(color: Color(0xCCFF2D6F), blurRadius: 8)],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
