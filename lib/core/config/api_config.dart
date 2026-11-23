import 'package:flutter/foundation.dart';

/// Backend configuration.
///
/// The app connects to the Tivoo backend via [baseUrl].
/// Defaults:
/// - Web / Desktop / iOS: http://localhost:8080
/// - Android emulator: http://10.0.2.2:8080
/// - Custom: `flutter run --dart-define=TIVOO_API_URL=http://<IP_OR_DOMAIN>:8080`
class ApiConfig {
  ApiConfig._();

  static const String _envUrl = String.fromEnvironment('TIVOO_API_URL');

  static String get baseUrl {
    if (_envUrl.isNotEmpty) return _envUrl;
    if (kIsWeb) return 'http://localhost:8080';
    if (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS) {
      return 'http://192.168.1.7:8080';
    }
    return 'http://192.168.1.7:8080';
  }

  static bool get hasBackend => true;

  /// Largest video accepted for upload (matches the server limit).
  static const int maxUploadBytes = 2 * 1024 * 1024 * 1024;
}
