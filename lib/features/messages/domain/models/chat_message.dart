import 'package:flutter/foundation.dart';

/// Message delivery status for 1-on-1 direct messaging.
enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
}

/// Message payload type.
enum MessageType {
  text,
  image,
  heart,
}

/// A single direct message in a conversation.
@immutable
class ChatMessage {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String senderAvatar;
  final String text;
  final DateTime timestamp;
  final bool isMe;
  final MessageStatus status;
  final MessageType type;
  final String? mediaPath;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderAvatar,
    required this.text,
    required this.timestamp,
    required this.isMe,
    this.status = MessageStatus.delivered,
    this.type = MessageType.text,
    this.mediaPath,
  });

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    String? text,
    DateTime? timestamp,
    bool? isMe,
    MessageStatus? status,
    MessageType? type,
    String? mediaPath,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
      isMe: isMe ?? this.isMe,
      status: status ?? this.status,
      type: type ?? this.type,
      mediaPath: mediaPath ?? this.mediaPath,
    );
  }
}

/// Conversation summary item displayed in the Messages Inbox.
@immutable
class ChatConversation {
  final String id;
  final String peerId;
  final String peerName;
  final String peerUsername;
  final String peerAvatar;
  final bool isVerified;
  final bool isOnline;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool requiresFollow;

  const ChatConversation({
    required this.id,
    required this.peerId,
    required this.peerName,
    required this.peerUsername,
    required this.peerAvatar,
    this.isVerified = false,
    this.isOnline = false,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.requiresFollow = false,
  });

  ChatConversation copyWith({
    String? id,
    String? peerId,
    String? peerName,
    String? peerUsername,
    String? peerAvatar,
    bool? isVerified,
    bool? isOnline,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    bool? requiresFollow,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      peerId: peerId ?? this.peerId,
      peerName: peerName ?? this.peerName,
      peerUsername: peerUsername ?? this.peerUsername,
      peerAvatar: peerAvatar ?? this.peerAvatar,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      requiresFollow: requiresFollow ?? this.requiresFollow,
    );
  }
}
