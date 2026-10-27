import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/luxe_theme.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../controllers/messages_controller.dart';
import '../screens/direct_chat_screen.dart';

class NewChatSheet extends ConsumerStatefulWidget {
  const NewChatSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const NewChatSheet(),
    );
  }

  @override
  ConsumerState<NewChatSheet> createState() => _NewChatSheetState();
}

class _NewChatSheetState extends ConsumerState<NewChatSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _filter = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suggestedCreators = [
      {
        'id': 'streamer_1',
        'name': 'Divya Sharma',
        'username': '@divyasharma',
        'avatar': AppAssets.avatarDiya,
        'bio': 'Music & Acoustic Live',
        'verified': true,
      },
      {
        'id': 'streamer_2',
        'name': 'Neha Kapoor',
        'username': '@nehakapoor',
        'avatar': AppAssets.avatarNeha,
        'bio': 'PK Battle Champion',
        'verified': true,
      },
      {
        'id': 'streamer_3',
        'name': 'Priya Patel',
        'username': '@priyapatel',
        'avatar': AppAssets.avatarPriya,
        'bio': 'Dance & Lifestyle',
        'verified': false,
      },
      {
        'id': 'streamer_4',
        'name': 'Arun Verma',
        'username': '@arunlive',
        'avatar': AppAssets.avatarArun,
        'bio': 'Gaming & Tech streamer',
        'verified': true,
      },
      {
        'id': 'streamer_5',
        'name': 'Sneha Rao',
        'username': '@sneharao',
        'avatar': AppAssets.avatarSneha,
        'bio': 'Vocals & Acoustic Beats',
        'verified': true,
      },
      {
        'id': 'streamer_6',
        'name': 'Diya Sen',
        'username': '@diyasen',
        'avatar': AppAssets.avatarDiya,
        'bio': 'Storytelling & Q&A',
        'verified': false,
      },
    ];

    final filtered = suggestedCreators.where((c) {
      final q = _filter.trim().toLowerCase();
      if (q.isEmpty) return true;
      final name = (c['name'] as String).toLowerCase();
      final username = (c['username'] as String).toLowerCase();
      final bio = (c['bio'] as String).toLowerCase();
      return name.contains(q) || username.contains(q) || bio.contains(q);
    }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: LuxeColors.bgTop,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(
          color: LuxeColors.purple.withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66100A2A),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  gradient: LuxeColors.goldGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LuxeColors.goldGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.chat_rounded,
                      color: Color(0xFF161200),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'New Direct Message',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // In-sheet search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: LuxeColors.panel.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: LuxeColors.purple.withValues(alpha: 0.28),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: LuxeColors.gold, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        style: const TextStyle(color: Colors.white, fontSize: 13.5),
                        cursorColor: LuxeColors.gold,
                        decoration: const InputDecoration(
                          hintText: 'Search creators...',
                          hintStyle: TextStyle(color: LuxeColors.textDim, fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onChanged: (val) => setState(() => _filter = val),
                      ),
                    ),
                    if (_filter.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchCtrl.clear();
                          setState(() => _filter = '');
                        },
                        child: const Icon(Icons.clear, color: LuxeColors.textDim, size: 16),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: const [
                  Text(
                    'SUGGESTED CREATORS',
                    style: TextStyle(
                      color: LuxeColors.textDim,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final creator = filtered[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          LuxeColors.panel.withValues(alpha: 0.45),
                          LuxeColors.panelDeep.withValues(alpha: 0.65),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: LuxeColors.purple.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(1.8),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              LuxeColors.goldLight,
                              LuxeColors.pink,
                              LuxeColors.violet,
                              LuxeColors.goldLight,
                            ],
                          ),
                        ),
                        child: CustomAvatar(
                          radius: 22,
                          assetPath: creator['avatar'] as String,
                        ),
                      ),
                      title: Row(
                        children: [
                          Flexible(
                            child: Text(
                              creator['name'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (creator['verified'] == true) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.verified_rounded, color: LuxeColors.gold, size: 14),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        '${creator['username']} • ${creator['bio']}',
                        style: const TextStyle(color: LuxeColors.textDim, fontSize: 11.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          final conv = ref.read(messagesControllerProvider.notifier).getOrCreateConversation(
                                peerId: creator['id'] as String,
                                peerName: creator['name'] as String,
                                peerAvatar: creator['avatar'] as String,
                                peerUsername: creator['username'] as String,
                                isVerified: creator['verified'] as bool,
                              );
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DirectChatScreen(
                                peerId: conv.peerId,
                                peerName: conv.peerName,
                                peerAvatar: conv.peerAvatar,
                                peerUsername: conv.peerUsername,
                                isVerified: conv.isVerified,
                                isOnline: true,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: LuxeDecor.goldButton(radius: 12),
                          child: const Text(
                            'Chat',
                            style: TextStyle(
                              color: Color(0xFF161200),
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
