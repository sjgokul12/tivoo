// Bottom sheets and dialogs: message input, settings, rules, share, more.

import 'package:flutter/material.dart';

import '../core/pk_models.dart';
import '../core/pk_theme.dart';
import '../../../core/widgets/tivoo_share_sheet.dart';

const Color _gold = Color(0xFFFFD600);

/// Common bottom-sheet shell: dark rounded top, accent top border, drag handle.
class PkSheet extends StatelessWidget {
  final Widget child;
  final Color accent;
  final EdgeInsetsGeometry padding;
  final double? maxHeight;

  const PkSheet({
    super.key,
    required this.child,
    this.accent = const Color(0x66FFD600),
    this.padding = const EdgeInsets.fromLTRB(18, 12, 18, 16),
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final resolved = padding.resolve(Directionality.maybeOf(context));
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Container(
      constraints: maxHeight != null ? BoxConstraints(maxHeight: maxHeight!) : null,
      padding: EdgeInsets.fromLTRB(
        resolved.left,
        resolved.top,
        resolved.right,
        resolved.bottom + (bottomInset > 0 ? bottomInset : 0),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF101018),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: accent, width: 1.5)),
        boxShadow: const [BoxShadow(color: Color(0x33FFD600), blurRadius: 24, spreadRadius: -2)],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: maxHeight != null ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 14),
            // Transparent Material so ListTiles inside the sheet can show ink.
            if (maxHeight != null)
              Expanded(
                child: Material(type: MaterialType.transparency, child: child),
              )
            else
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Material(type: MaterialType.transparency, child: child),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Sheet header row with a back chevron: "< Title".
class PkSheetTitle extends StatelessWidget {
  final String title;
  const PkSheetTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

/// Full-width gold primary button used across PK dialogs.
class PkPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const PkPrimaryButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _gold,
          foregroundColor: Colors.black,
          elevation: 6,
          shadowColor: const Color(0xAAFFD600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          padding: const EdgeInsets.symmetric(vertical: 13),
        ),
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
      ),
    );
  }
}

/// Full-width outlined button (Cancel, Back to Live...).
class PkSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const PkSecondaryButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white30, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          padding: const EdgeInsets.symmetric(vertical: 13),
        ),
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

class PkSheets {
  PkSheets._();

  // ---------------------------------------------------------------------------
  // Message input
  // ---------------------------------------------------------------------------
  static void showMessageInput(BuildContext context, {required ValueChanged<String> onSend}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MessageInputSheet(onSend: onSend),
    );
  }

  // ---------------------------------------------------------------------------
  // PK settings
  // ---------------------------------------------------------------------------
  static void showSettings(
    BuildContext context, {
    required PkSettings current,
    required ValueChanged<PkSettings> onSave,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _SettingsSheet(initial: current, onSave: onSave),
    );
  }

  // ---------------------------------------------------------------------------
  // PK rules
  // ---------------------------------------------------------------------------
  static void showRules(BuildContext context) {
    const rule = TextStyle(color: Colors.white70);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF14141E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: _gold, width: 1.5),
        ),
        title: const Text(
          '📜 Official PK Rules',
          style: TextStyle(color: _gold, fontWeight: FontWeight.bold),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. PK Battle duration is configurable (3, 5, 10, or 15 min).', style: rule),
            SizedBox(height: 8),
            Text("2. Every gift sent boosts the host's clash score bar.", style: rule),
            SizedBox(height: 8),
            Text('3. When the timer reaches 00:00, the host with the higher score wins!', style: rule),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Got it',
              style: TextStyle(color: _gold, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Share
  // ---------------------------------------------------------------------------
  static void showShare(BuildContext context) {
    const shareUrl = 'https://tivoo.app/pk/battle_live';
    const shareText = 'Watch this intense PK Battle live on Tivoo! https://tivoo.app/pk/battle_live';

    TivooShareSheet.show(
      context,
      title: 'Share PK Battle',
      subtitle: 'Clash of Stars • Priya vs Anu',
      shareUrl: shareUrl,
      shareText: shareText,
    );
  }

  // ---------------------------------------------------------------------------
  // More options (opened from Live Tools → Ranking)
  // ---------------------------------------------------------------------------
  static void showMoreOptions(
    BuildContext context, {
    required VoidCallback onSettings,
    required VoidCallback onPreviewWinner,
  }) {
    Widget tile(BuildContext ctx, IconData icon, String title, String subtitle, VoidCallback onTap) {
      return ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Color(0x33FFD600), shape: BoxShape.circle),
          child: Icon(icon, color: _gold),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        onTap: () {
          Navigator.pop(ctx);
          onTap();
        },
      );
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PkSheet(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            tile(ctx, Icons.settings_rounded, 'PK Battle Settings', 'Timer, auto-end & host acceptance', onSettings),
            tile(
              ctx,
              Icons.emoji_events_rounded,
              'Winner Celebration Screen',
              'Preview celebration ribbon & trophies',
              onPreviewWinner,
            ),
            tile(
              ctx,
              Icons.shield_outlined,
              'PK Rules',
              'View battle rules and scoring criteria',
              () => showRules(context),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Top toast banner for PK events (started / declined ...)
  // ---------------------------------------------------------------------------
  static void showBanner(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(bottom: MediaQuery.sizeOf(context).height * 0.78, left: 14, right: 14),
        duration: const Duration(seconds: 3),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF141220),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color, width: 1.5),
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 16, spreadRadius: 1)],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.bold),
                    ),
                    Text(message, style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
                  ],
                ),
              ),
              const Text('Now', style: TextStyle(color: Colors.white38, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageInputSheet extends StatefulWidget {
  final ValueChanged<String> onSend;
  const _MessageInputSheet({required this.onSend});

  @override
  State<_MessageInputSheet> createState() => _MessageInputSheetState();
}

class _MessageInputSheetState extends State<_MessageInputSheet> {
  static const _quickEmojis = ['🌹', '❤️', '🔥', '👏', '⭐', '🐳', '🏎️', '👑', '🎉', '💯'];
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _insertEmoji(String emoji) {
    _controller.text += emoji;
    _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    Navigator.pop(context);
    widget.onSend(text);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xF5090C1A),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          border: Border.all(color: const Color(0x992979FF), width: 1.2),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final emoji in _quickEmojis)
                      GestureDetector(
                        onTap: () => _insertEmoji(emoji),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                          margin: const EdgeInsets.only(right: 6, bottom: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(emoji, style: const TextStyle(fontSize: 18)),
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xCC2979FF), width: 1.2),
                      ),
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        cursorColor: _gold,
                        cursorWidth: 2.2,
                        textInputAction: TextInputAction.send,
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: Color(0xFF9E9EAF), fontSize: 14),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onSubmitted: (_) => _send(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [PkColors.pink, Color(0xFF2979FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [BoxShadow(color: Color(0x66FF2D78), blurRadius: 10)],
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsSheet extends StatefulWidget {
  final PkSettings initial;
  final ValueChanged<PkSettings> onSave;

  const _SettingsSheet({required this.initial, required this.onSave});

  @override
  State<_SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<_SettingsSheet> {
  late int _duration = widget.initial.durationSeconds;
  late bool _countdown = widget.initial.countdownDisplay;
  late bool _showToAudience = widget.initial.showTimerToAudience;
  late bool _autoEnd = widget.initial.autoEnd;

  @override
  Widget build(BuildContext context) {
    return PkSheet(
      accent: const Color(0x55FFD600),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PkSheetTitle('PK Settings'),
          const SizedBox(height: 20),
          const Row(
            children: [
              Icon(Icons.timer_rounded, color: _gold, size: 18),
              SizedBox(width: 8),
              Text(
                'Battle Duration',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final (label, secs) in const [('3 min', 180), ('5 min', 300), ('10 min', 600), ('15 min', 900)]) ...[
                if (secs != 180) const SizedBox(width: 8),
                _durationPill(label, secs),
              ],
            ],
          ),
          const SizedBox(height: 24),
          _switchRow(Icons.alarm_on_rounded, 'Countdown Display', _countdown, (v) => setState(() => _countdown = v)),
          const SizedBox(height: 12),
          _switchRow(
            Icons.visibility_rounded,
            'Show Timer to Audience',
            _showToAudience,
            (v) => setState(() => _showToAudience = v),
          ),
          const SizedBox(height: 12),
          _switchRow(Icons.group_work_rounded, 'Auto End PK', _autoEnd, (v) => setState(() => _autoEnd = v)),
          const SizedBox(height: 24),
          PkPrimaryButton(
            label: 'Save',
            onPressed: () {
              Navigator.pop(context);
              widget.onSave(
                PkSettings(
                  durationSeconds: _duration,
                  countdownDisplay: _countdown,
                  showTimerToAudience: _showToAudience,
                  autoEnd: _autoEnd,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _durationPill(String label, int seconds) {
    final selected = seconds == _duration;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _duration = seconds),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? _gold : const Color(0xFF1B1B26),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? _gold : Colors.white12, width: selected ? 1.8 : 1),
            boxShadow: selected ? const [BoxShadow(color: Color(0x66FFD600), blurRadius: 10, spreadRadius: 1)] : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.black : Colors.white,
              fontSize: 14,
              fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _switchRow(IconData icon, String title, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: _gold,
          activeTrackColor: const Color(0x66FFD600),
          inactiveThumbColor: Colors.white38,
          inactiveTrackColor: Colors.white12,
        ),
      ],
    );
  }
}
