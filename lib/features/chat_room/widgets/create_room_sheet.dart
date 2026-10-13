import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/luxe_theme.dart';
import '../data/chat_room_data.dart';
import 'chat_room_common.dart';

/// Host creates a room: topic, team badge and Audio / Video mode.
class CreateRoomSheet extends StatefulWidget {
  final ValueChanged<ChatRoom> onCreate;
  const CreateRoomSheet({super.key, required this.onCreate});

  static void show(BuildContext context, ValueChanged<ChatRoom> onCreate) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreateRoomSheet(onCreate: onCreate),
    );
  }

  @override
  State<CreateRoomSheet> createState() => _CreateRoomSheetState();
}

class _CreateRoomSheetState extends State<CreateRoomSheet> {
  final _title = TextEditingController(text: 'My Party Room 💕');
  String _tag = ChatRoomData.tags.first;
  bool _video = false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _create() {
    final topic = _title.text.trim();
    widget.onCreate(
      ChatRoom(
        id: 'room_${DateTime.now().millisecondsSinceEpoch}',
        hostName: 'You (Host)',
        tagline: topic.isEmpty ? "Let's party together 💕" : topic,
        tag: _tag,
        avatar: AppAssets.avatarDiya,
        members: 1,
        viewers: 1,
        isVerified: true,
        isVideo: _video,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ChatSheetFrame(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: LuxeGoldText('Create Chat Room', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const ChatFieldLabel('Room Title / Topic'),
            LuxePanel(
              radius: 14,
              glow: 0,
              child: TextField(
                controller: _title,
                cursorColor: LuxeColors.gold,
                style: const TextStyle(color: Colors.white, fontSize: 14.5),
                decoration: const InputDecoration(
                  hintText: 'Enter room topic...',
                  hintStyle: TextStyle(color: LuxeColors.textDim),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const ChatFieldLabel('Category / Team Badge'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in ChatRoomData.tags)
                  _Choice(selected: tag == _tag, onTap: () => setState(() => _tag = tag), child: Text('👑 $tag')),
              ],
            ),
            const SizedBox(height: 16),
            const ChatFieldLabel('Room Mode'),
            Row(
              children: [
                Expanded(
                  child: _Choice(
                    selected: !_video,
                    onTap: () => setState(() => _video = false),
                    child: const _ModeLabel(icon: Icons.mic_rounded, text: 'Audio (9 Seats)'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _Choice(
                    selected: _video,
                    onTap: () => setState(() => _video = true),
                    child: const _ModeLabel(icon: Icons.videocam_rounded, text: 'Video Party'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            ChatPillButton(label: 'Create Room & Go Live', icon: Icons.sensors_rounded, onTap: _create),
          ],
        ),
      ),
    );
  }
}

/// Selectable chip / tile: gold fill when selected, glass otherwise.
class _Choice extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  const _Choice({required this.selected, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: selected
              ? LuxeDecor.goldButton(radius: 14)
              : BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: LuxeColors.panel,
                  border: Border.all(color: LuxeColors.purple.withValues(alpha: 0.45)),
                ),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: selected ? kGoldInk : Colors.white,
              fontSize: 12.5,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            ),
            child: IconTheme.merge(
              data: IconThemeData(color: selected ? kGoldInk : LuxeColors.gold, size: 17),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ModeLabel({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon),
        const SizedBox(width: 6),
        Flexible(
          child: FittedBox(fit: BoxFit.scaleDown, child: Text(text)),
        ),
      ],
    );
  }
}
