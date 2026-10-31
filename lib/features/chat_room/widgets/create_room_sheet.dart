import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/luxe_theme.dart';
import '../data/chat_room_data.dart';
import 'chat_room_common.dart';

/// Host creates an audio chat room with 9 speaker seats: topic and audio setup.
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
        tag: 'Audio Party',
        avatar: AppAssets.avatarDiya,
        members: 1,
        viewers: 1,
        isVerified: true,
        isVideo: false,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.sizeOf(context);
    final viewInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInset),
      child: ChatSheetFrame(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: media.height * 0.82),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
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
                const SizedBox(height: 12),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1544),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: LuxeColors.violet.withValues(alpha: 0.45)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LuxeColors.goldGradient,
                        ),
                        child: const Icon(Icons.mic_rounded, color: kGoldInk, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Audio Room (9 Seats)',
                              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Anyone can join the conversation with 9 active speaker seats',
                              style: TextStyle(color: LuxeColors.textDim, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                ChatPillButton(label: 'Create Room & Go Live', icon: Icons.sensors_rounded, onTap: _create),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
