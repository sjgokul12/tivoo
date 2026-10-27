import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/luxe_theme.dart';
import '../../../../core/widgets/custom_avatar.dart';
import '../../domain/models/chat_message.dart';
import '../controllers/messages_controller.dart';
import '../widgets/new_chat_sheet.dart';
import 'direct_chat_screen.dart';

enum MessageFilter { all, unread, online, vip }

class MessagesInboxScreen extends ConsumerStatefulWidget {
  const MessagesInboxScreen({super.key});

  @override
  ConsumerState<MessagesInboxScreen> createState() => _MessagesInboxScreenState();
}

class _MessagesInboxScreenState extends ConsumerState<MessagesInboxScreen> {
  final TextEditingController _searchController = TextEditingController();
  MessageFilter _activeFilter = MessageFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openChat(ChatConversation conv) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DirectChatScreen(
          peerId: conv.peerId,
          peerName: conv.peerName,
          peerAvatar: conv.peerAvatar,
          peerUsername: conv.peerUsername,
          isVerified: conv.isVerified,
          isOnline: conv.isOnline,
        ),
      ),
    );
  }

  List<ChatConversation> _applyFilter(List<ChatConversation> items) {
    switch (_activeFilter) {
      case MessageFilter.unread:
        return items.where((c) => c.unreadCount > 0).toList();
      case MessageFilter.online:
        return items.where((c) => c.isOnline).toList();
      case MessageFilter.vip:
        return items.where((c) => c.isVerified).toList();
      case MessageFilter.all:
        return items;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(messagesControllerProvider);
    final filteredConversations = _applyFilter(state.filteredConversations);

    return Scaffold(
      backgroundColor: LuxeColors.bg,
      body: Stack(
        children: [
          // 1. Luxe Deep Indigo Backdrop with Purple Glows & Gold Light Streaks
          const Positioned.fill(
            child: LuxeBackdrop(),
          ),

          // 2. Main Content
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, state.totalUnreadCount),
                _buildSearchBar(),
                _buildFilterTabs(state),
                if (state.searchQuery.isEmpty && _activeFilter == MessageFilter.all)
                  _buildActiveNowTray(state.conversations),
                Expanded(
                  child: filteredConversations.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                          physics: const BouncingScrollPhysics(),
                          itemCount: filteredConversations.length,
                          itemBuilder: (context, index) {
                            final conv = filteredConversations[index];
                            return _buildConversationCard(conv);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int totalUnread) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: LuxeColors.bgTop.withValues(alpha: 0.65),
        border: Border(
          bottom: BorderSide(
            color: LuxeColors.purple.withValues(alpha: 0.22),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          LuxeCircleButton(
            icon: Icons.arrow_back_ios_new_rounded,
            label: 'Back',
            size: 40,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                const Text(
                  'Messages',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                if (totalUnread > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      gradient: LuxeColors.goldGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x66FFC928),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '$totalUnread',
                      style: const TextStyle(
                        color: Color(0xFF161200),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          LuxeCircleButton(
            icon: Icons.edit_note_rounded,
            label: 'New message',
            size: 40,
            gold: true,
            iconColor: LuxeColors.gold,
            onTap: () => NewChatSheet.show(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: LuxeColors.panel.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: LuxeColors.purple.withValues(alpha: 0.35),
            width: 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: LuxeColors.purple.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: LuxeColors.gold, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search chats, creators or messages...',
                  hintStyle: TextStyle(color: LuxeColors.textDim, fontSize: 13.5),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (val) {
                  ref.read(messagesControllerProvider.notifier).setSearchQuery(val);
                  setState(() {});
                },
              ),
            ),
            if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  ref.read(messagesControllerProvider.notifier).setSearchQuery('');
                  setState(() {});
                },
                child: const Icon(Icons.close_rounded, color: LuxeColors.textDim, size: 18),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs(dynamic state) {
    final filters = [
      {'type': MessageFilter.all, 'label': 'All Chats'},
      {
        'type': MessageFilter.unread,
        'label': 'Unread',
        'badge': state.totalUnreadCount > 0 ? '${state.totalUnreadCount}' : null,
      },
      {'type': MessageFilter.online, 'label': 'Active Now'},
      {'type': MessageFilter.vip, 'label': 'VIP Creators'},
    ];

    return Container(
      height: 38,
      margin: const EdgeInsets.only(top: 2, bottom: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = filters[index];
          final type = item['type'] as MessageFilter;
          final isSelected = _activeFilter == type;
          final badge = item['badge'] as String?;

          return GestureDetector(
            onTap: () => setState(() => _activeFilter = type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LuxeColors.goldGradient
                    : LinearGradient(
                        colors: [
                          LuxeColors.panel.withValues(alpha: 0.6),
                          LuxeColors.panelDeep.withValues(alpha: 0.6),
                        ],
                      ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? LuxeColors.goldLight
                      : LuxeColors.purple.withValues(alpha: 0.28),
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        const BoxShadow(
                          color: Color(0x55FFC928),
                          blurRadius: 10,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item['label'] as String,
                    style: TextStyle(
                      color: isSelected ? const Color(0xFF161200) : LuxeColors.textMuted,
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF161200) : LuxeColors.pink,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          color: isSelected ? LuxeColors.gold : Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveNowTray(List<ChatConversation> all) {
    final activeUsers = all.where((c) => c.isOnline).toList();
    if (activeUsers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
          child: Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF00E676),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Color(0xFF00E676), blurRadius: 6),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'ACTIVE CREATORS',
                style: TextStyle(
                  color: LuxeColors.textDim,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Text(
                '${activeUsers.length} online',
                style: const TextStyle(
                  color: Color(0xFF00E676),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 92,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: activeUsers.length,
            itemBuilder: (context, index) {
              final user = activeUsers[index];
              return GestureDetector(
                onTap: () => _openChat(user),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2.4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: SweepGradient(
                                colors: [
                                  LuxeColors.goldLight,
                                  LuxeColors.pink,
                                  LuxeColors.violet,
                                  LuxeColors.blue,
                                  LuxeColors.goldLight,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x407B4DFF),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(1.5),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: LuxeColors.bg,
                              ),
                              child: CustomAvatar(
                                radius: 24,
                                assetPath: user.peerAvatar.startsWith('assets/') ? user.peerAvatar : null,
                                imageUrl: !user.peerAvatar.startsWith('assets/') ? user.peerAvatar : null,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 1,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E676),
                                shape: BoxShape.circle,
                                border: Border.all(color: LuxeColors.bg, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x8800E676),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        width: 60,
                        child: Text(
                          user.peerName.split(' ').first,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildConversationCard(ChatConversation conv) {
    final isUnread = conv.unreadCount > 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _openChat(conv),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isUnread
                    ? [
                        LuxeColors.panel.withValues(alpha: 0.75),
                        LuxeColors.panelDeep.withValues(alpha: 0.85),
                      ]
                    : [
                        LuxeColors.panel.withValues(alpha: 0.4),
                        LuxeColors.panelDeep.withValues(alpha: 0.5),
                      ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isUnread
                    ? LuxeColors.gold.withValues(alpha: 0.45)
                    : LuxeColors.purple.withValues(alpha: 0.22),
                width: isUnread ? 1.3 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isUnread
                      ? LuxeColors.gold.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Avatar with online status
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(1.5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isUnread
                              ? LuxeColors.gold
                              : LuxeColors.purple.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      child: CustomAvatar(
                        radius: 25,
                        assetPath: conv.peerAvatar.startsWith('assets/') ? conv.peerAvatar : null,
                        imageUrl: !conv.peerAvatar.startsWith('assets/') ? conv.peerAvatar : null,
                      ),
                    ),
                    if (conv.isOnline)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E676),
                            shape: BoxShape.circle,
                            border: Border.all(color: LuxeColors.panelDeep, width: 2),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x6600E676),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),

                // Name & preview
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              conv.peerName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: isUnread ? FontWeight.w800 : FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (conv.isVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified_rounded,
                              color: LuxeColors.gold,
                              size: 15,
                            ),
                          ],
                          const Spacer(),
                          Text(
                            _formatTime(conv.lastMessageTime),
                            style: TextStyle(
                              color: isUnread ? LuxeColors.gold : LuxeColors.textDim,
                              fontSize: 11.5,
                              fontWeight: isUnread ? FontWeight.w800 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conv.lastMessage,
                              style: TextStyle(
                                color: isUnread ? Colors.white : LuxeColors.textMuted,
                                fontSize: 13,
                                fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: LuxeColors.goldGradient,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x66FFC928),
                                    blurRadius: 8,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Text(
                                '${conv.unreadCount}',
                                style: const TextStyle(
                                  color: Color(0xFF161200),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    LuxeColors.purple.withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
                border: Border.all(
                  color: LuxeColors.purple.withValues(alpha: 0.35),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                color: LuxeColors.gold,
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No conversations yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Direct message and connect with your favorite creators!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: LuxeColors.textDim,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => NewChatSheet.show(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                decoration: LuxeDecor.goldButton(radius: 16),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.edit_note_rounded, color: Color(0xFF161200), size: 19),
                    SizedBox(width: 8),
                    Text(
                      'Start a Chat',
                      style: TextStyle(
                        color: Color(0xFF161200),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
