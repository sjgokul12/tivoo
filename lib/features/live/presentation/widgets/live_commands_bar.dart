import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/snackbar.dart';
import '../../../../core/widgets/animations.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/gloss.dart';

/// Chat commands viewers can tap or type ("!like", "!gift", ...).
enum LiveCommand {
  like('!like'),
  gift('!gift'),
  follow('!follow'),
  share('!share');

  const LiveCommand(this.keyword);

  final String keyword;

  static LiveCommand? parse(String text) {
    final t = text.trim().toLowerCase();
    for (final command in values) {
      if (t == command.keyword) return command;
    }
    return null;
  }
}

/// "!share": copies the room link to the clipboard.
Future<void> copyLiveLink(BuildContext context, String roomId) async {
  await Clipboard.setData(ClipboardData(text: 'https://tivoo.app/live/$roomId'));
  if (context.mounted) context.showAppSnackBar('Live link copied — share it with your friends!');
}

class LiveCommandsBar extends StatelessWidget {
  const LiveCommandsBar({super.key, required this.onCommand});

  final ValueChanged<LiveCommand> onCommand;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final command in LiveCommand.values) ...[
          if (command != LiveCommand.like) const SizedBox(width: 8),
          Expanded(child: _CommandChip(command: command, onTap: () => onCommand(command))),
        ],
      ],
    );
  }
}

class _CommandChip extends StatelessWidget {
  const _CommandChip({required this.command, required this.onTap});

  final LiveCommand command;
  final VoidCallback onTap;

  /// (icon, light, deep) colours per command.
  (IconData, Color, Color) get _style => switch (command) {
        LiveCommand.like => (Icons.favorite_rounded, const Color(0xFFFF8AD8), const Color(0xFFE0207F)),
        LiveCommand.gift => (Icons.card_giftcard_rounded, const Color(0xFFFFE680), const Color(0xFFFF9500)),
        LiveCommand.follow => (Icons.person_add_alt_1_rounded, const Color(0xFF7DE3FF), const Color(0xFF2563EB)),
        LiveCommand.share => (Icons.shortcut_rounded, const Color(0xFFD8A8FF), const Color(0xFF7C3AED)),
      };

  @override
  Widget build(BuildContext context) {
    final (icon, light, deep) = _style;
    return Pressable(
      onTap: onTap,
      scale: 0.9,
      child: GlassContainer(
        borderRadius: 18,
        borderWidth: 1.3,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [deep.withValues(alpha: 0.28), const Color(0xCC0B0A22)],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [light, Colors.white.withValues(alpha: 0.12), deep],
        ),
        shadows: [BoxShadow(color: deep.withValues(alpha: 0.55), blurRadius: 12, blurStyle: BlurStyle.outer)],
        child: SizedBox(
          height: 44,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Row(
                children: [
                  // Glossy 3D icon bubble.
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: const Alignment(-0.3, -0.5),
                        colors: [light, deep],
                      ),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
                      boxShadow: [BoxShadow(color: deep.withValues(alpha: 0.8), blurRadius: 8)],
                    ),
                    foregroundDecoration: const BoxDecoration(shape: BoxShape.circle, gradient: Gloss.sheen),
                    child: Icon(icon, size: 15, color: Colors.white),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    command.keyword,
                    style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
