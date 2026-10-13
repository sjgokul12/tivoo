import 'package:flutter/material.dart';

import '../../../core/theme/luxe_theme.dart';

/// Dark ink used on gold buttons.
const Color kGoldInk = Color(0xFF241500);

enum ChatButtonStyle { gold, ghost, danger }

/// Full-width stadium button: gold (primary), ghost (neon glass) or danger (pink).
class ChatPillButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final ChatButtonStyle style;
  final double height;

  const ChatPillButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.style = ChatButtonStyle.gold,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final radius = height / 2;
    final fg = style == ChatButtonStyle.gold ? kGoldInk : Colors.white;
    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[Icon(icon, color: fg, size: height * 0.42), const SizedBox(width: 6)],
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(color: fg, fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.3),
            ),
          ),
        ),
      ],
    );

    final Widget body = switch (style) {
      ChatButtonStyle.gold => Container(
        height: height,
        decoration: LuxeDecor.goldButton(radius: radius),
        child: content,
      ),
      ChatButtonStyle.danger => Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: const LinearGradient(colors: [Color(0xFFFF2D55), LuxeColors.pink, LuxeColors.violet]),
          boxShadow: const [BoxShadow(color: Color(0x66FF2D78), blurRadius: 12, offset: Offset(0, 3))],
        ),
        child: content,
      ),
      ChatButtonStyle.ghost => LuxePanel(height: height, radius: radius, glow: 0, child: content),
    };

    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(onTap: onTap, child: body),
    );
  }
}

/// Dimmed full-screen layer with a centred gold → neon glass card (join / end room modals).
class ChatModalCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onDismiss;

  const ChatModalCard({super.key, required this.child, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black.withValues(alpha: 0.68),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: GestureDetector(
          onTap: () {}, // keep taps inside the card from dismissing
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: SingleChildScrollView(
              child: LuxePanel(
                radius: 28,
                borderColors: LuxeColors.goldToNeon,
                glow: 22,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bottom-sheet frame with a gold → neon top edge (create room, seat details, more menu).
class ChatSheetFrame extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const ChatSheetFrame({super.key, required this.child, this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 20)});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 1.4),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        gradient: LinearGradient(colors: LuxeColors.goldToNeon),
      ),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.vertical(top: Radius.circular(27)),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [LuxeColors.bgTop, LuxeColors.bg],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Avatar inside a gold sweep ring with a soft gold glow.
class GoldRingAvatar extends StatelessWidget {
  final String asset;
  final double radius;
  final double ring;

  const GoldRingAvatar({super.key, required this.asset, required this.radius, this.ring = 2.4});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(ring),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [LuxeColors.goldLight, LuxeColors.goldDeep, LuxeColors.violet, LuxeColors.gold, LuxeColors.goldLight],
        ),
        boxShadow: [BoxShadow(color: Color(0x55FFC928), blurRadius: 14)],
      ),
      child: ClipOval(
        child: Image.asset(
          asset,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            width: radius * 2,
            height: radius * 2,
            color: LuxeColors.panel,
            child: Icon(Icons.person_rounded, color: Colors.white38, size: radius),
          ),
        ),
      ),
    );
  }
}

/// Small gold pill: "👑 Dream Team".
class GoldTagPill extends StatelessWidget {
  final String text;
  final String icon;
  final double fontSize;

  const GoldTagPill({super.key, required this.text, this.icon = '👑', this.fontSize = 11.5});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: fontSize * 0.7, vertical: fontSize * 0.22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: LuxeColors.gold.withValues(alpha: 0.12),
        border: Border.all(color: LuxeColors.gold.withValues(alpha: 0.55)),
      ),
      child: Text(
        '$icon $text',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: LuxeColors.goldLight, fontSize: fontSize, fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Section label used in the create-room sheet.
class ChatFieldLabel extends StatelessWidget {
  final String text;
  const ChatFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(color: LuxeColors.textMuted, fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}

void showChatToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        backgroundColor: LuxeColors.panel,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: LuxeColors.gold.withValues(alpha: 0.6)),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
}
