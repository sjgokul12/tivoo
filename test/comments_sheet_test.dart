import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivoo/features/explore/data/mock_explore_data.dart';
import 'package:tivoo/features/explore/presentation/widgets/comments_sheet.dart';
import 'package:tivoo/features/explore/presentation/widgets/explore_reel_card.dart';

void main() {
  Future<void> openSheet(WidgetTester tester, {required bool seed}) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => CommentsSheet.show(context, itemId: 'video_1', seed: seed),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('comments sheet opens with sample comments', (tester) async {
    await openSheet(tester, seed: true);
    expect(find.textContaining('Comments'), findsOneWidget);
    expect(find.text('Reply'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping Comment on an Explore video opens the comments sheet', (tester) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: ExploreReelCard(stream: MockExploreData.exploreStreams[0])),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byIcon(Icons.mode_comment_outlined));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Reply'), findsWidgets);
  });

  testWidgets('posting a comment adds it to the top of the list', (tester) async {
    await openSheet(tester, seed: false);
    expect(find.text('No comments yet'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Nice video 🔥');
    await tester.pump();
    await tester.tap(find.byTooltip('Post'));
    await tester.pumpAndSettle();

    expect(find.text('Nice video 🔥'), findsOneWidget);
    expect(find.text('You'), findsOneWidget);
    expect(find.text('No comments yet'), findsNothing);
  });
}
