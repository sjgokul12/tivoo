import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../mock/mock_data.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());

@immutable
class AuthUser {
  const AuthUser({required this.id, required this.name, required this.avatar});

  final String id;
  final String name;
  final String avatar;
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

enum SocialProvider { google, facebook, apple, phone }

/// Authentication API. Mocked: accepts any well-formed credentials.
/// Credentials are only ever sent to the API — never logged or persisted.
class AuthRepository {
  Future<AuthUser> login({required String identifier, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (identifier.isEmpty || password.length < 6) {
      throw const AuthException('Invalid mobile number/email or password.');
    }
    return AuthUser(id: 'me', name: _nameFrom(identifier), avatar: MockData.currentUserAvatar);
  }

  Future<AuthUser> loginWith(SocialProvider provider) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return AuthUser(id: 'me', name: 'Tivoo User', avatar: MockData.currentUserAvatar);
  }

  String _nameFrom(String identifier) {
    if (!identifier.contains('@')) return 'Tivoo User';
    final local = identifier.split('@').first;
    return local.isEmpty ? 'Tivoo User' : local[0].toUpperCase() + local.substring(1);
  }
}
