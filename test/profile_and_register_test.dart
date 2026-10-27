import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tivoo/features/auth/presentation/screens/login_screen.dart';
import 'package:tivoo/features/auth/presentation/screens/register_screen.dart';
import 'package:tivoo/features/onboarding/presentation/screens/splash_screen.dart';
import 'package:tivoo/features/profile/presentation/widgets/profile_luxe_sections.dart';
import 'package:tivoo/features/profile/presentation/widgets/tiki_verification_sheet.dart';

void main() {
  group('Profile Tiki to Tivoo Renaming Tests', () {
    testWidgets('ProfileBadgesRow displays "Tivoo Star" instead of "Tiki Star"', (tester) async {
      bool starTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileBadgesRow(
              onTikiStar: () => starTapped = true,
              onAngels: () {},
              onShare: () {},
              onFamily: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tivoo Star'), findsOneWidget);
      expect(find.text('Tiki Star'), findsNothing);

      await tester.tap(find.text('Tivoo Star'));
      await tester.pump();
      expect(starTapped, isTrue);
    });

    testWidgets('TivooVerificationSheet shows Tivoo branding and tiers', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: TivooVerificationSheet(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tivoo Creator Verification'), findsOneWidget);
      expect(find.text('Step-by-step roadmap to White Tivoo & Gray Tivoo'), findsOneWidget);
      expect(find.text('White Tivoo (Beginning Tier)'), findsOneWidget);
      expect(find.text('Gray Tivoo (Target Tier)'), findsOneWidget);
      expect(find.textContaining('Tiki'), findsNothing);
    });
  });

  group('RegisterScreen Integration Tests', () {
    testWidgets('RegisterScreen renders form fields and Create Account button', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RegisterScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text('Create Account'), findsNWidgets(2)); // Heading & Button
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.textContaining('Log In'), findsOneWidget);
    });

    testWidgets('LoginScreen Sign Up navigates to RegisterScreen', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Sign Up'), findsOneWidget);
      await tester.tap(find.text('Sign Up'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.byType(RegisterScreen), findsOneWidget);
      expect(find.text('Create Account'), findsWidgets);
    });

    testWidgets('SplashScreen Get Started navigates to RegisterScreen', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SplashScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Get Started'), findsOneWidget);
      await tester.tap(find.text('Get Started'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.byType(RegisterScreen), findsOneWidget);
    });
  });
}
