import 'package:flutter/foundation.dart';

@immutable
class Gift {
  const Gift({required this.id, required this.name, required this.emoji, required this.coins});

  final String id;
  final String name;
  final String emoji;
  final int coins;
}

/// A gift the viewer chose to send, and to whom (index into the recipients).
@immutable
class GiftSelection {
  const GiftSelection({required this.gift, required this.quantity, this.recipientIndex = 0});

  final Gift gift;
  final int quantity;
  final int recipientIndex;

  int get totalCoins => gift.coins * quantity;
}

@immutable
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderName,
    required this.avatar,
    required this.sentAt,
    this.text = '',
    this.gift,
    this.giftCount = 1,
    this.isMine = false,
  });

  final String id;
  final String senderName;
  final String avatar;
  final DateTime sentAt;
  final String text;
  final Gift? gift;
  final int giftCount;
  final bool isMine;

  bool get isGift => gift != null;
}
