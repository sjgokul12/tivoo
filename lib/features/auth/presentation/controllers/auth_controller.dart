import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../../../core/config/api_config.dart';
import '../../../profile/domain/models/user_profile_model.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';

class AuthState {
  final bool isLoading;
  final bool isPasswordVisible;
  final String? errorMessage;
  final bool isAuthenticated;
  final UserProfileModel? currentUser;
  final String? accessToken;
  final String? refreshToken;

  const AuthState({
    this.isLoading = false,
    this.isPasswordVisible = false,
    this.errorMessage,
    this.isAuthenticated = false,
    this.currentUser,
    this.accessToken,
    this.refreshToken,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isPasswordVisible,
    String? errorMessage,
    bool? isAuthenticated,
    UserProfileModel? currentUser,
    String? accessToken,
    String? refreshToken,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
      errorMessage: errorMessage,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      currentUser: currentUser ?? this.currentUser,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}

class AuthController extends StateNotifier<AuthState> {
  final Ref _ref;

  AuthController(this._ref) : super(const AuthState());

  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  Future<bool> login(String identifier, String password) async {
    if (identifier.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your email, username, or phone number');
      return false;
    }
    if (password.isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your password');
      return false;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/auth/login');
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'identifier': identifier,
          'password': password,
          'deviceInfo': 'flutter-app',
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data is Map<String, dynamic>) {
        final userData = data['user'] as Map<String, dynamic>?;
        UserProfileModel? user;
        if (userData != null) {
          user = UserProfileModel.fromJson(userData);
          _ref.read(profileControllerProvider.notifier).setProfile(user);
        }

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          currentUser: user,
          accessToken: data['accessToken']?.toString(),
          refreshToken: data['refreshToken']?.toString(),
          errorMessage: null,
        );
        return true;
      } else {
        final errorMsg = _extractErrorMessage(res, 'Login failed');
        state = state.copyWith(isLoading: false, errorMessage: errorMsg);
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Connection failed: ${e.toString()}',
      );
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String username,
    required String email,
    String? phoneNumber,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/auth/register');
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'username': username,
          'email': email,
          if (phoneNumber != null && phoneNumber.isNotEmpty) 'phoneNumber': phoneNumber,
          'password': password,
          'deviceInfo': 'flutter-app',
        }),
      );

      Map<String, dynamic>? data;
      try {
        final decoded = jsonDecode(res.body);
        if (decoded is Map<String, dynamic>) data = decoded;
      } catch (_) {}

      if ((res.statusCode == 200 || res.statusCode == 201) && data != null) {
        final userData = data['user'] as Map<String, dynamic>?;
        UserProfileModel? user;
        if (userData != null) {
          user = UserProfileModel.fromJson(userData);
          _ref.read(profileControllerProvider.notifier).setProfile(user);
        }

        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          currentUser: user,
          accessToken: data['accessToken']?.toString(),
          refreshToken: data['refreshToken']?.toString(),
          errorMessage: null,
        );
        return true;
      } else {
        final errorMsg = _extractErrorMessage(res, 'Registration failed');
        state = state.copyWith(isLoading: false, errorMessage: errorMsg);
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Connection failed: ${e.toString()}',
      );
      return false;
    }
  }

  String _extractErrorMessage(http.Response res, String defaultMsg) {
    try {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) {
        if (decoded['error'] != null && decoded['error'].toString().isNotEmpty) {
          return decoded['error'].toString();
        }
        if (decoded['message'] != null && decoded['message'].toString().isNotEmpty) {
          return decoded['message'].toString();
        }
        final detail = decoded['detail'];
        if (detail is String && detail.isNotEmpty) {
          return detail;
        }
        if (detail is List && detail.isNotEmpty) {
          final first = detail.first;
          if (first is Map && first['msg'] != null) {
            return first['msg'].toString();
          }
          return first.toString();
        }
      }
    } catch (_) {}
    return '$defaultMsg (HTTP ${res.statusCode})';
  }

  void logout() {
    state = const AuthState(isAuthenticated: false);
  }

  Future<bool> sendEmailOtp(String email, {String purpose = 'login'}) async {
    if (email.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your email address');
      return false;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/auth/email/send-otp');
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'purpose': purpose,
        }),
      );
      state = state.copyWith(isLoading: false);
      if (res.statusCode == 200 || res.statusCode == 201) {
        return true;
      } else {
        final err = _extractErrorMessage(res, 'Failed to send OTP');
        state = state.copyWith(errorMessage: err);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Connection failed: $e');
      return false;
    }
  }

  Future<bool> verifyEmailOtp(String email, String otp, {String purpose = 'login', String? name}) async {
    if (otp.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter the verification code');
      return false;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/auth/email/verify-otp');
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim(),
          'otp': otp.trim(),
          'purpose': purpose,
          if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
          'deviceInfo': 'flutter-app',
        }),
      );

      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data is Map<String, dynamic>) {
        final userData = data['user'] as Map<String, dynamic>?;
        UserProfileModel? user;
        if (userData != null) {
          user = UserProfileModel.fromJson(userData);
          _ref.read(profileControllerProvider.notifier).setProfile(user);
        }
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          currentUser: user,
          accessToken: data['accessToken']?.toString(),
          refreshToken: data['refreshToken']?.toString(),
          errorMessage: null,
        );
        return true;
      } else {
        final err = _extractErrorMessage(res, 'Invalid verification code');
        state = state.copyWith(isLoading: false, errorMessage: err);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: 'Connection failed: $e');
      return false;
    }
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref);
});
