import 'package:flutter_test/flutter_test.dart';
import 'package:tivoo/features/messages/domain/models/chat_message.dart';
import 'package:tivoo/features/messages/domain/models/message_privacy_settings.dart';
import 'package:tivoo/features/messages/presentation/controllers/messages_controller.dart';

void main() {
  group('MessagePrivacySettings Tests', () {
    test('Default mode is everyone with trendy labels', () {
      const settings = MessagePrivacySettings();
      expect(settings.isEveryoneAllowed, isTrue);
      expect(settings.isFollowersOnly, isFalse);
      expect(settings.badgeLabel, 'Open DMs');
      expect(settings.title, 'Everyone');
    });

    test('Followers only mode has correct protected labels', () {
      const settings = MessagePrivacySettings(mode: MessagePrivacyMode.followersOnly);
      expect(settings.isEveryoneAllowed, isFalse);
      expect(settings.isFollowersOnly, isTrue);
      expect(settings.badgeLabel, 'Followers Only');
      expect(settings.title, 'Followers Only');
    });
  });

  group('MessagesController Tests', () {
    late MessagesController controller;

    setUp(() {
      controller = MessagesController();
    });

    test('Initializes with default conversations and unread badges', () {
      final state = controller.state;
      expect(state.conversations, isNotEmpty);
      expect(state.totalUnreadCount, greaterThan(0));
    });

    test('Searching filters conversations correctly', () {
      controller.setSearchQuery('Divya');
      expect(controller.state.filteredConversations.length, 1);
      expect(controller.state.filteredConversations.first.peerName, 'Divya Sharma');

      controller.setSearchQuery('');
      expect(controller.state.filteredConversations.length, controller.state.conversations.length);
    });

    test('Sending a text message updates thread and preview', () {
      controller.sendMessage(
        peerId: 'streamer_1',
        text: 'Hello from test!',
      );

      final thread = controller.state.threadMessages['streamer_1']!;
      expect(thread.last.text, 'Hello from test!');
      expect(thread.last.isMe, isTrue);
      expect(thread.last.type, MessageType.text);

      final conv = controller.state.conversations.firstWhere((c) => c.peerId == 'streamer_1');
      expect(conv.lastMessage, 'Hello from test!');
    });

    test('Sending a heart message sends heart emoji', () {
      controller.sendMessage(
        peerId: 'streamer_1',
        text: '',
        type: MessageType.heart,
      );

      final thread = controller.state.threadMessages['streamer_1']!;
      expect(thread.last.text, '❤️');
      expect(thread.last.type, MessageType.heart);
    });

    test('Marking as read clears unread badge for conversation', () {
      controller.markAsRead('streamer_1');
      final conv = controller.state.conversations.firstWhere((c) => c.peerId == 'streamer_1');
      expect(conv.unreadCount, 0);
    });

    test('Setting privacy mode updates state reactively', () {
      controller.setPrivacyMode(MessagePrivacyMode.followersOnly);
      expect(controller.state.privacySettings.isFollowersOnly, isTrue);

      controller.setPrivacyMode(MessagePrivacyMode.everyone);
      expect(controller.state.privacySettings.isEveryoneAllowed, isTrue);
    });

    test('Privacy checks allow messaging when following', () {
      final allowed = controller.canMessageUser('streamer_1', isFollowing: true);
      expect(allowed, isTrue);
    });
  });
}
