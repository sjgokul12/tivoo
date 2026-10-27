import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_assets.dart';
import '../../domain/models/chat_message.dart';
import '../../domain/models/message_privacy_settings.dart';

/// State of the Messages feature.
class MessagesState {
  final List<ChatConversation> conversations;
  final Map<String, List<ChatMessage>> threadMessages;
  final MessagePrivacySettings privacySettings;
  final String searchQuery;

  const MessagesState({
    required this.conversations,
    required this.threadMessages,
    required this.privacySettings,
    this.searchQuery = '',
  });

  int get totalUnreadCount =>
      conversations.fold<int>(0, (sum, conv) => sum + conv.unreadCount);

  List<ChatConversation> get filteredConversations {
    if (searchQuery.trim().isEmpty) return conversations;
    final query = searchQuery.trim().toLowerCase();
    return conversations.where((c) {
      return c.peerName.toLowerCase().contains(query) ||
          c.peerUsername.toLowerCase().contains(query) ||
          c.lastMessage.toLowerCase().contains(query);
    }).toList();
  }

  MessagesState copyWith({
    List<ChatConversation>? conversations,
    Map<String, List<ChatMessage>>? threadMessages,
    MessagePrivacySettings? privacySettings,
    String? searchQuery,
  }) {
    return MessagesState(
      conversations: conversations ?? this.conversations,
      threadMessages: threadMessages ?? this.threadMessages,
      privacySettings: privacySettings ?? this.privacySettings,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

/// Controller managing direct messaging, conversations, and privacy settings.
class MessagesController extends StateNotifier<MessagesState> {
  MessagesController() : super(_initialState());

  static MessagesState _initialState() {
    final now = DateTime.now();

    final initialConversations = [
      ChatConversation(
        id: 'conv_1',
        peerId: 'streamer_1',
        peerName: 'Divya Sharma',
        peerUsername: '@divyasharma',
        peerAvatar: AppAssets.avatarDiya,
        isVerified: true,
        isOnline: true,
        lastMessage: 'Hey! Loved your support in today\'s live stream! ✨',
        lastMessageTime: now.subtract(const Duration(minutes: 5)),
        unreadCount: 1,
      ),
      ChatConversation(
        id: 'conv_2',
        peerId: 'streamer_2',
        peerName: 'Neha Kapoor',
        peerUsername: '@nehakapoor',
        peerAvatar: AppAssets.avatarNeha,
        isVerified: true,
        isOnline: true,
        lastMessage: 'Are we doing the PK battle collaboration tonight? 🔥',
        lastMessageTime: now.subtract(const Duration(hours: 1)),
        unreadCount: 2,
      ),
      ChatConversation(
        id: 'conv_3',
        peerId: 'streamer_3',
        peerName: 'Priya Patel',
        peerUsername: '@priyapatel',
        peerAvatar: AppAssets.avatarPriya,
        isVerified: false,
        isOnline: false,
        lastMessage: 'Thanks for the follow! See you in the next broadcast! 💛',
        lastMessageTime: now.subtract(const Duration(hours: 4)),
        unreadCount: 0,
      ),
      ChatConversation(
        id: 'conv_4',
        peerId: 'streamer_4',
        peerName: 'Arun Verma',
        peerUsername: '@arunlive',
        peerAvatar: AppAssets.avatarArun,
        isVerified: true,
        isOnline: false,
        lastMessage: 'Check out the new acoustic clip I just posted!',
        lastMessageTime: now.subtract(const Duration(days: 1)),
        unreadCount: 0,
      ),
    ];

    final initialThreads = <String, List<ChatMessage>>{
      'streamer_1': [
        ChatMessage(
          id: 'm1_1',
          conversationId: 'conv_1',
          senderId: 'streamer_1',
          senderName: 'Divya Sharma',
          senderAvatar: AppAssets.avatarDiya,
          text: 'Hi there! Welcome to my Tivoo community! 🌟',
          timestamp: now.subtract(const Duration(minutes: 25)),
          isMe: false,
          status: MessageStatus.read,
        ),
        ChatMessage(
          id: 'm1_2',
          conversationId: 'conv_1',
          senderId: 'me',
          senderName: 'You',
          senderAvatar: AppAssets.status5,
          text: 'Your voice is incredible! Keep rocking! 💖',
          timestamp: now.subtract(const Duration(minutes: 15)),
          isMe: true,
          status: MessageStatus.read,
        ),
        ChatMessage(
          id: 'm1_3',
          conversationId: 'conv_1',
          senderId: 'streamer_1',
          senderName: 'Divya Sharma',
          senderAvatar: AppAssets.avatarDiya,
          text: 'Hey! Loved your support in today\'s live stream! ✨',
          timestamp: now.subtract(const Duration(minutes: 5)),
          isMe: false,
          status: MessageStatus.delivered,
        ),
      ],
      'streamer_2': [
        ChatMessage(
          id: 'm2_1',
          conversationId: 'conv_2',
          senderId: 'streamer_2',
          senderName: 'Neha Kapoor',
          senderAvatar: AppAssets.avatarNeha,
          text: 'Are we doing the PK battle collaboration tonight? 🔥',
          timestamp: now.subtract(const Duration(hours: 1)),
          isMe: false,
          status: MessageStatus.delivered,
        ),
      ],
    };

    return MessagesState(
      conversations: initialConversations,
      threadMessages: initialThreads,
      privacySettings: const MessagePrivacySettings(
        mode: MessagePrivacyMode.everyone,
      ),
    );
  }

  /// Sets search filter in inbox.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Updates private messaging privacy mode (Everyone vs Followers Only).
  void setPrivacyMode(MessagePrivacyMode mode) {
    state = state.copyWith(
      privacySettings: state.privacySettings.copyWith(mode: mode),
    );
  }

  /// Checks if current user is allowed to send a message to [targetUserId].
  /// If the target user only allows followers and [isFollowing] is false, returns false.
  bool canMessageUser(String targetUserId, {required bool isFollowing}) {
    // If the target is our own account or we are already following, always allow.
    if (isFollowing) return true;

    // Check target's privacy (simulated: default open unless marked followersOnly)
    final existingConv = state.conversations.firstWhere(
      (c) => c.peerId == targetUserId,
      orElse: () => ChatConversation(
        id: '',
        peerId: '',
        peerName: '',
        peerUsername: '',
        peerAvatar: '',
        lastMessage: '',
        lastMessageTime: DateTime.now(),
      ),
    );

    if (existingConv.requiresFollow && !isFollowing) {
      return false;
    }
    return true;
  }

  /// Retrieves or initializes a conversation with [peerId].
  ChatConversation getOrCreateConversation({
    required String peerId,
    required String peerName,
    required String peerAvatar,
    String peerUsername = '',
    bool isVerified = false,
  }) {
    final existingIndex =
        state.conversations.indexWhere((c) => c.peerId == peerId);
    if (existingIndex != -1) {
      return state.conversations[existingIndex];
    }

    final newConv = ChatConversation(
      id: 'conv_${DateTime.now().millisecondsSinceEpoch}',
      peerId: peerId,
      peerName: peerName,
      peerUsername: peerUsername.isNotEmpty
          ? peerUsername
          : '@${peerName.toLowerCase().replaceAll(' ', '')}',
      peerAvatar: peerAvatar,
      isVerified: isVerified,
      isOnline: true,
      lastMessage: 'Started a new conversation',
      lastMessageTime: DateTime.now(),
      unreadCount: 0,
    );

    state = state.copyWith(
      conversations: [newConv, ...state.conversations],
      threadMessages: {
        ...state.threadMessages,
        peerId: state.threadMessages[peerId] ?? [],
      },
    );
    return newConv;
  }

  /// Marks a conversation as read.
  void markAsRead(String peerId) {
    final updatedList = state.conversations.map((c) {
      if (c.peerId == peerId && c.unreadCount > 0) {
        return c.copyWith(unreadCount: 0);
      }
      return c;
    }).toList();

    state = state.copyWith(conversations: updatedList);
  }

  /// Sends a message and triggers a realistic auto-response.
  void sendMessage({
    required String peerId,
    required String text,
    MessageType type = MessageType.text,
    String? mediaPath,
  }) {
    if (text.trim().isEmpty && mediaPath == null && type != MessageType.heart) {
      return;
    }

    final now = DateTime.now();
    final messageId = 'msg_${now.millisecondsSinceEpoch}';
    final userMessage = ChatMessage(
      id: messageId,
      conversationId: peerId,
      senderId: 'me',
      senderName: 'You',
      senderAvatar: AppAssets.status5,
      text: type == MessageType.heart ? '❤️' : text.trim(),
      timestamp: now,
      isMe: true,
      status: MessageStatus.sent,
      type: type,
      mediaPath: mediaPath,
    );

    final currentThread = List<ChatMessage>.from(state.threadMessages[peerId] ?? []);
    currentThread.add(userMessage);

    // Update conversation preview
    final previewText = type == MessageType.heart
        ? '❤️ Heart'
        : mediaPath != null
            ? '📷 Photo'
            : text.trim();

    final updatedConversations = state.conversations.map((c) {
      if (c.peerId == peerId) {
        return c.copyWith(
          lastMessage: previewText,
          lastMessageTime: now,
        );
      }
      return c;
    }).toList();

    state = state.copyWith(
      threadMessages: {
        ...state.threadMessages,
        peerId: currentThread,
      },
      conversations: updatedConversations,
    );

    // Mark as delivered
    Timer(const Duration(milliseconds: 600), () {
      _updateMessageStatus(peerId, messageId, MessageStatus.delivered);
    });

    // Simulate smart auto-reply from creator
    Timer(const Duration(milliseconds: 1400), () {
      _simulatePeerReply(peerId);
    });
  }

  void _updateMessageStatus(
      String peerId, String messageId, MessageStatus status) {
    final thread = state.threadMessages[peerId];
    if (thread == null) return;

    final updatedThread = thread.map((m) {
      if (m.id == messageId) {
        return m.copyWith(status: status);
      }
      return m;
    }).toList();

    state = state.copyWith(
      threadMessages: {
        ...state.threadMessages,
        peerId: updatedThread,
      },
    );
  }

  void _simulatePeerReply(String peerId) {
    final conv = state.conversations.firstWhere(
      (c) => c.peerId == peerId,
      orElse: () => ChatConversation(
        id: '',
        peerId: peerId,
        peerName: 'Creator',
        peerUsername: '',
        peerAvatar: '',
        lastMessage: '',
        lastMessageTime: DateTime.now(),
      ),
    );

    final replies = [
      'Thanks for reaching out! So glad to have you in my stream! ✨',
      'Got your message! See you live soon! 💛',
      'Appreciate the love! Drop by my next broadcast! 🎙️',
      'Awesome! Let\'s stay connected here on Tivoo! 🙌',
    ];
    final replyText = replies[DateTime.now().second % replies.length];

    final now = DateTime.now();
    final replyMessage = ChatMessage(
      id: 'reply_${now.millisecondsSinceEpoch}',
      conversationId: peerId,
      senderId: peerId,
      senderName: conv.peerName,
      senderAvatar: conv.peerAvatar,
      text: replyText,
      timestamp: now,
      isMe: false,
      status: MessageStatus.delivered,
    );

    final thread = List<ChatMessage>.from(state.threadMessages[peerId] ?? []);
    thread.add(replyMessage);

    final updatedConversations = state.conversations.map((c) {
      if (c.peerId == peerId) {
        return c.copyWith(
          lastMessage: replyText,
          lastMessageTime: now,
        );
      }
      return c;
    }).toList();

    state = state.copyWith(
      threadMessages: {
        ...state.threadMessages,
        peerId: thread,
      },
      conversations: updatedConversations,
    );
  }
}

/// Provider for messages state & controller.
final messagesControllerProvider =
    StateNotifierProvider<MessagesController, MessagesState>((ref) {
  return MessagesController();
});
