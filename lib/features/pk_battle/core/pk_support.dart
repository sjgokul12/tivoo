// Which host the viewer supports in a PK battle: side colours, short names, and the
// "Switch to …" popup shown when tapping the other host's video.

import 'package:flutter/material.dart';

import '../../../core/widgets/custom_avatar.dart';
import 'pk_models.dart';

const _pink = Color(0xFFFF2DC0);
const _blue = Color(0xFF2E9BFF);

/// Pink for the left host, blue for the right one.
Color pkSideColor(bool isLeft) => isLeft ? _pink : _blue;

/// First name, at most 7 characters ("Priyanka Sharma" → "Priyan…").
String pkShortName(String name) {
  final first = name.trim().split(RegExp(r'\s+')).first;
  return first.length <= 7 ? first : '${first.substring(0, 6)}…';
}

/// Small centered card: host photo, "Switch to Priya?" and a coloured confirm button.
class PkSwitchSupportDialog extends StatelessWidget {
  final PkHost host;
  final Color color;

  const PkSwitchSupportDialog({super.key, required this.host, required this.color});

  /// Resolves to true when the viewer confirms.
  static Future<bool?> show(BuildContext context, {required PkHost host, required Color color}) {
    return showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (_, _, _) => PkSwitchSupportDialog(host: host, color: color),
      transitionBuilder: (_, anim, _, child) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween(begin: 0.88, end: 1.0).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack)),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = pkShortName(host.name);
    return Center(
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          width: 250,
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
          decoration: BoxDecoration(
            color: const Color(0xF2121436),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withValues(alpha: 0.8), width: 1.4),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 24)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
                child: CustomAvatar(radius: 30, assetPath: host.avatarAsset),
              ),
              const SizedBox(height: 12),
              Text(
                'Switch to $name?',
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Your comments and gifts will go to $name.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 12.5),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: color,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Switch to $name', style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
