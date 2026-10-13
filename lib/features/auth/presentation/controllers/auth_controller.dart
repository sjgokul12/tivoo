import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isLoading;
  final bool isPasswordVisible;
  final String? errorMessage;
  final bool isAuthenticated;

  const AuthState({
    this.isLoading = false,
    this.isPasswordVisible = false,
    this.errorMessage,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isPasswordVisible,
    String? errorMessage,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      errorMessage: errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(const AuthState());

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  Future<bool> login(String emailOrPhone, String password) async {
    if (emailOrPhone.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your email or phone number');
      return false;
    }
    if (password.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your password');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);
    await Future.delayed(const Duration(milliseconds: 300));
    state = state.copyWith(isLoading: false, isAuthenticated: true);
    return true;
  }

  void logout() {
    state = const AuthState(isAuthenticated: false);
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController();
});
