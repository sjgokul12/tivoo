/// Backend configuration.
///
/// The app runs in two modes:
/// - **Local mode** (default, [baseUrl] empty): uploaded videos are saved on this
///   device only. They show on your profile and in Explore, but other phones can't see them.
/// - **Server mode**: build with the backend URL and every install shares the same feed:
///
///   flutter build apk --dart-define=TIVOO_API_URL=https://your-server.com
///
/// See backend/README.md for the server.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment('TIVOO_API_URL');

  static bool get hasBackend => baseUrl.isNotEmpty;

  /// Largest video accepted for upload (matches the server limit).
  static const int maxUploadBytes = 2 * 1024 * 1024 * 1024;
}
