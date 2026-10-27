import 'package:flutter/material.dart';

import '../../../core/theme/luxe_theme.dart';
import '../../../core/widgets/luxe_tivoo_logo.dart';
import '../data/chat_room_data.dart';
import 'chat_room_common.dart';

/// Step 1: top bar (back, logo, Chat Room badge, search), searchable room list and
/// the "Create Chat Room" button.
class RoomListView extends StatefulWidget {
  final List<ChatRoom> rooms;
  final VoidCallback onBack;
  final ValueChanged<ChatRoom> onJoin;
  final VoidCallback onCreate;

  const RoomListView({
    super.key,
    required this.rooms,
    required this.onBack,
    required this.onJoin,
    required this.onCreate,
  });

  @override
  State<RoomListView> createState() => _RoomListViewState();
}

class _RoomListViewState extends State<RoomListView> {
  final _search = TextEditingController();
  bool _searchOpen = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searchOpen = !_searchOpen;
      if (!_searchOpen) _search.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = _search.text.trim().toLowerCase();
    final rooms = q.isEmpty
        ? widget.rooms
        : widget.rooms
              .where(
                (r) =>
                    r.hostName.toLowerCase().contains(q) ||
                    r.tag.toLowerCase().contains(q) ||
                    r.tagline.toLowerCase().contains(q),
              )
              .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
          child: Row(
            children: [
              LuxeCircleButton(icon: Icons.arrow_back_ios_new_rounded, label: 'Back', size: 38, onTap: widget.onBack),
              const SizedBox(width: 8),
              const Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: LuxeTivooLogo(size: 26, showTagline: false),
                ),
              ),
              const SizedBox(width: 6),
              const _ChatRoomBadge(),
              const Spacer(),
              LuxeCircleButton(
                icon: _searchOpen ? Icons.close_rounded : Icons.search_rounded,
                label: 'Search rooms',
                size: 38,
                onTap: _toggleSearch,
              ),
            ],
          ),
        ),
        if (_searchOpen)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
            child: LuxePanel(
              height: 44,
              radius: 22,
              glow: 8,
              child: TextField(
                controller: _search,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                cursorColor: LuxeColors.gold,
                decoration: const InputDecoration(
                  hintText: 'Search room by host or topic...',
                  hintStyle: TextStyle(color: LuxeColors.textDim, fontSize: 13),
                  prefixIcon: Icon(Icons.search_rounded, color: LuxeColors.gold, size: 19),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        Expanded(
          child: rooms.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off_rounded, color: LuxeColors.textDim, size: 48),
                      SizedBox(height: 10),
                      Text('No chat rooms found', style: TextStyle(color: LuxeColors.textMuted, fontSize: 15)),
                    ],
                  ),
                )
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
                  itemCount: rooms.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _RoomRow(room: rooms[i], onJoin: () => widget.onJoin(rooms[i])),
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
          child: ChatPillButton(label: 'Create Chat Room', icon: Icons.add_rounded, height: 52, onTap: widget.onCreate),
        ),
      ],
    );
  }
}

class _ChatRoomBadge extends StatelessWidget {
  const _ChatRoomBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: LuxeColors.purple.withValues(alpha: 0.22),
        border: Border.all(color: LuxeColors.violet.withValues(alpha: 0.7)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.mic_rounded, color: LuxeColors.goldLight, size: 13),
          SizedBox(width: 4),
          Text(
            'Chat Room',
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _RoomRow extends StatelessWidget {
  final ChatRoom room;
  final VoidCallback onJoin;

  const _RoomRow({required this.room, required this.onJoin});

  @override
  Widget build(BuildContext context) {
    const meta = TextStyle(color: LuxeColors.textMuted, fontSize: 11.5, fontWeight: FontWeight.w600);
    return GestureDetector(
      onTap: onJoin,
      child: LuxePanel(
        radius: 20,
        glow: 6,
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset(
                room.avatar,
                width: 68,
                height: 68,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 68,
                  height: 68,
                  color: LuxeColors.panel,
                  child: const Icon(Icons.person_rounded, color: Colors.white30, size: 34),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          room.hostName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (room.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded, color: LuxeColors.gold, size: 15),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    room.tagline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: LuxeColors.textMuted, fontSize: 12.5),
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        GoldTagPill(text: room.tag, icon: room.tagIcon, fontSize: 11),
                        const SizedBox(width: 8),
                        const Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF8A3D), size: 14),
                        Text(' ${room.viewers}', style: meta.copyWith(color: LuxeColors.goldLight)),
                        const SizedBox(width: 8),
                        const Icon(Icons.person_rounded, color: LuxeColors.textDim, size: 14),
                        Text(' ${room.capacity}', style: meta),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: LuxeDecor.goldButton(radius: 18),
              child: const Text(
                'Watch',
                style: TextStyle(color: kGoldInk, fontSize: 13, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
