import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivoo/features/gift/buy_stars_sheet.dart';

void main() {
  testWidgets('Test full screen opening of BuyStarsScreen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).push(
                    MaterialPageRoute(
                      builder: (_) => BuyStarsScreen(
                        currentBalance: 1000000,
                        onSelectPack: (pack, payment) {},
                      ),
                    ),
                  );
                },
                child: const Text('Open Buy Stars'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Buy Stars'));
    await tester.pumpAndSettle();

    // Verify all packs are rendered
    expect(find.text('100'), findsOneWidget);
    expect(find.text('300'), findsOneWidget);
    expect(find.text('500'), findsOneWidget);
    expect(find.text('1,000'), findsOneWidget);
    expect(find.text('2,000'), findsOneWidget);
    expect(find.text('3,000'), findsOneWidget);
    expect(find.text('4,000'), findsOneWidget);
    expect(find.text('5,000'), findsOneWidget);
    expect(find.text('10,000'), findsOneWidget);
  });
}
