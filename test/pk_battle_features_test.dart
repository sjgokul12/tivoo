import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivoo/features/pk_battle/core/pk_models.dart';
import 'package:tivoo/features/pk_battle/overlays/pk_boxer_intro.dart';
import 'package:tivoo/features/pk_battle/pk_battle_live_screen.dart';
import 'package:tivoo/features/pk_battle/streamer/pk_streamer_battle_view.dart';
import 'package:tivoo/features/pk_battle/streamer/pk_streamer_end_overlay.dart';
import 'package:tivoo/features/pk_battle/viewer/pk_viewer_battle_view.dart';
import 'package:tivoo/features/pk_battle/viewer/pk_viewer_end_overlay.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('PK Battle Features', () {
    testWidgets('Streamer End Overlay displays Rebattle and Exit buttons', (tester) async {
      bool rebattleTapped = false;
      bool exitTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PkStreamerEndOverlay(
              left: PkDemoData.featured.left,
              right: PkDemoData.featured.right,
              leftScore: 12500,
              rightScore: 9800,
              onRebattle: () => rebattleTapped = true,
              onExit: () => exitTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Rebattle'), findsOneWidget);
      expect(find.text('Exit'), findsOneWidget);
      expect(find.text('WINNER'), findsWidgets);

      await tester.tap(find.text('Rebattle'));
      expect(rebattleTapped, isTrue);

      await tester.tap(find.text('Exit'));
      expect(exitTapped, isTrue);
    });

    testWidgets('Viewer Result Popup displays stars used and auto-dismiss timer', (tester) async {
      bool closed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PkViewerResultPopup(
              left: PkDemoData.featured.left,
              right: PkDemoData.featured.right,
              leftScore: 12500,
              rightScore: 9800,
              giftsSent: 3,
              starsUsed: 450,
              visibleFor: const Duration(milliseconds: 500),
              onClosed: () => closed = true,
            ),
          ),
        ),
      );

      expect(find.text('Stars you used'), findsOneWidget);
      expect(find.text('3 gifts sent'), findsOneWidget);
      expect(find.textContaining('450'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 350));
      expect(closed, isTrue);
    });

    testWidgets('Boxer Intro animation displays round and title and triggers onFinished', (tester) async {
      bool finished = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PkBoxerIntro(
              title: 'REBATTLE!',
              leftName: 'Neha',
              rightName: 'Arun',
              round: 2,
              duration: const Duration(milliseconds: 400),
              onFinished: () => finished = true,
            ),
          ),
        ),
      );

      expect(find.text('ROUND 2'), findsOneWidget);
      expect(find.text('REBATTLE!'), findsWidgets);
      expect(find.text('Neha'), findsOneWidget);
      expect(find.text('Arun'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 450));
      expect(finished, isTrue);
    });

    testWidgets('PkBattleLiveScreen differentiates between streamer and viewer', (tester) async {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);

      // Streamer view
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PkBattleLiveScreen(isCreator: true),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(PkStreamerBattleView), findsOneWidget);
      expect(find.byType(PkViewerBattleView), findsNothing);

      // Viewer view (explicit)
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PkBattleLiveScreen(isCreator: false),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(PkViewerBattleView), findsOneWidget);

      // Viewer view (default when isCreator is omitted)
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: PkBattleLiveScreen(),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(PkViewerBattleView), findsOneWidget);
    });
  });
}
