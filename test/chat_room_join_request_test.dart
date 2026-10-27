import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivoo/features/chat_room/chat_room_party_screen.dart';

void main() {
  testWidgets('Chat room join flow: sends request first, receives on-screen approval from host, and participates',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ChatRoomPartyScreen(initialStage: 3),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify initially spectator with Join button
    expect(find.text('Join'), findsOneWidget);
    expect(find.text('Diya_Official'), findsOneWidget);

    // Click Join
    await tester.tap(find.text('Join'));
    await tester.pump();

    // Verify it transitioned to Requested state
    expect(find.text('Requested'), findsOneWidget);
    expect(find.text('Join'), findsNothing);

    // Fast forward timer to when host approval arrives
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pumpAndSettle();

    // On-screen approval message should now be visible
    expect(find.text('Request Approved! 🎉'), findsOneWidget);
    expect(find.textContaining('approved your request to join'), findsWidgets);
    expect(find.text('Participate in Chatroom'), findsOneWidget);

    // User taps Participate in Chatroom
    await tester.tap(find.text('Participate in Chatroom'));
    await tester.pumpAndSettle();

    // Now user should be joined: dock switches from Join/Requested to Chat
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Join'), findsNothing);
    expect(find.text('Requested'), findsNothing);

    // Chat feed should include approval message
    expect(find.textContaining('approved your request to join'), findsWidgets);
  });
}
