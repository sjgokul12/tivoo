import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/utils/snackbar.dart';
import '../../../core/widgets/tivoo_logo.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../shell/presentation/main_shell.dart';
import '../providers/auth_providers.dart';
import 'widgets/go_live_signature.dart';
import 'widgets/login_card.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(loginControllerProvider, (previous, next) {
      switch (next) {
        case AsyncError(:final error):
          context.showAppSnackBar(
            error is AuthException ? error.message : 'Something went wrong. Please try again.',
          );
        case AsyncData() when previous?.isLoading ?? false:
          Navigator.of(context).pushReplacement(MainShell.route());
        default:
          break;
      }
    });

    final size = context.screenSize;
    final dpr = MediaQuery.devicePixelRatioOf(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppAssets.loginBackground,
            fit: BoxFit.cover,
            cacheWidth: (size.width * dpr).round(),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 26),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(height: context.scaled(12)),
                          TivooLogo(fontSize: context.scaled(70)),
                          SizedBox(height: context.scaled(20)),
                          const LoginCard(),
                          SizedBox(height: context.scaled(16)),
                          const GoLiveSignature(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
