import 'package:flutter_test/flutter_test.dart';
import 'package:tivoo/features/profile/domain/models/follow_relationship.dart';
import 'package:tivoo/features/profile/presentation/controllers/follow_controller.dart';

void main() {
  group('FollowController Frontend-Only State Tests', () {
    test('Initializes with default notFollowing relationship without mutating state in build', () {
      final controller = FollowController();
      final rel = controller.getRelationship('user_123', defaultName: 'Test Creator');

      expect(rel.userId, 'user_123');
      expect(rel.userName, 'Test Creator');
      expect(rel.status, FollowStatus.notFollowing);
      expect(rel.isNotFollowing, isTrue);
      expect(rel.isFollowingOrMutual, isFalse);
      // State map must not be modified during pure read query
      expect(controller.state.containsKey('user_123'), isFalse);
    });

    test('sendFollowRequest transitions state: Follow -> Requested', () {
      final controller = FollowController();
      String? notifiedMessage;

      controller.sendFollowRequest(
        'user_456',
        targetName: 'Streamer Alex',
        onStatusNotify: (msg) => notifiedMessage = msg,
      );

      final rel = controller.state['user_456'];
      expect(rel, isNotNull);
      expect(rel!.status, FollowStatus.requested);
      expect(rel.isRequested, isTrue);
      expect(notifiedMessage, contains('Follow request sent to Streamer Alex'));
    });

    test('cancelFollowRequest transitions state: Requested -> Follow', () {
      final controller = FollowController();
      String? cancelMsg;

      controller.sendFollowRequest('user_456', targetName: 'Streamer Alex');
      expect(controller.state['user_456']!.status, FollowStatus.requested);

      controller.cancelFollowRequest(
        'user_456',
        onStatusNotify: (msg) => cancelMsg = msg,
      );

      final rel = controller.state['user_456'];
      expect(rel, isNotNull);
      expect(rel!.status, FollowStatus.notFollowing);
      expect(rel.isNotFollowing, isTrue);
      expect(cancelMsg, contains('Cancelled follow request'));
    });

    test('unfollow transitions state: Following -> Follow', () {
      final controller = FollowController();
      // Emulate user already in following state
      controller.sendFollowRequest('user_101', targetName: 'Creator Sam');
      controller.acceptRequest('user_101');
      expect(controller.state['user_101']!.isFollowingOrMutual, isTrue);

      controller.unfollow('user_101');
      final rel = controller.state['user_101'];
      expect(rel, isNotNull);
      expect(rel!.status, FollowStatus.notFollowing);
      expect(rel.isNotFollowing, isTrue);
    });

    test('maintains independent states for multiple users', () {
      final controller = FollowController();

      // User A -> Requested
      controller.sendFollowRequest('user_a', targetName: 'User A');
      // User B -> Following
      controller.sendFollowRequest('user_b', targetName: 'User B');
      controller.acceptRequest('user_b');
      // User C -> notFollowing
      final relC = controller.getRelationship('user_c', defaultName: 'User C');

      expect(controller.state['user_a']!.status, FollowStatus.requested);
      expect(controller.state['user_b']!.status, FollowStatus.mutual);
      expect(relC.status, FollowStatus.notFollowing);

      // Cancelling User A should not affect User B
      controller.cancelFollowRequest('user_a');
      expect(controller.state['user_a']!.status, FollowStatus.notFollowing);
      expect(controller.state['user_b']!.status, FollowStatus.mutual);
    });
  });
}
