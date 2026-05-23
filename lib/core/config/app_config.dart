import 'package:flutter/foundation.dart';

class AppConfig {
  /// Production API (Render) — always used on release Android/iOS installs.
  static const productionApiUrl = 'https://localservicemarket-api.onrender.com';

  /// Mock is opt-in only: `--dart-define=USE_MOCK_API=true`
  static const useMockApi =
      bool.fromEnvironment('USE_MOCK_API', defaultValue: false);

  static String get apiBaseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    if (useMockApi && !kReleaseMode) {
      return productionApiUrl; // mock bypasses HTTP; URL unused
    }

    return productionApiUrl;
  }

  static bool get isUsingRenderApi =>
      !useMockApi && apiBaseUrl == productionApiUrl;
}
