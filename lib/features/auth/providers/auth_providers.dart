import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/auth_repository.dart';

/// The signed-in user for this app session (null = signed out).
final sessionProvider = NotifierProvider<SessionNotifier, AuthUser?>(SessionNotifier.new);

class SessionNotifier extends Notifier<AuthUser?> {
  @override
  AuthUser? build() => null;

  void signIn(AuthUser user) => state = user;

  void signOut() => state = null;
}

/// Login request state: idle (data) / loading / error.
final loginControllerProvider = AsyncNotifierProvider.autoDispose<LoginController, void>(LoginController.new);

class LoginController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> login({required String identifier, required String password}) {
    return _authenticate(
      () => ref.read(authRepositoryProvider).login(identifier: identifier.trim(), password: password),
    );
  }

  Future<void> loginWith(SocialProvider provider) {
    return _authenticate(() => ref.read(authRepositoryProvider).loginWith(provider));
  }

  Future<void> _authenticate(Future<AuthUser> Function() request) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    final result = await AsyncValue.guard(request);
    if (!ref.mounted) return;
    if (result case AsyncData(:final value)) {
      ref.read(sessionProvider.notifier).signIn(value);
    }
    state = result.whenData((_) {});
  }
}
