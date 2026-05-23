class AppConfig {
  /// Production API (Render).
  static const productionApiUrl = 'https://localservicemarket-api.onrender.com';

  /// Set `USE_MOCK_API=true` to use the offline mock store.
  static const useMockApi =
      bool.fromEnvironment('USE_MOCK_API', defaultValue: false);

  static String get apiBaseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    // Default to Render so physical Android/iOS devices work out of the box.
    // Local dev: flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
    return productionApiUrl;
  }
}
