class LocalConfig {
  /// Optional build-time fallback for the Ark key.
  ///
  /// Do not put an actual key in source code. In normal use, enter provider
  /// credentials through the in-app Settings screen, where they are saved with
  /// Flutter Secure Storage. This fallback is intentionally empty by default.
  static const volcengineArkApiKey =
      String.fromEnvironment('VOLCENGINE_ARK_API_KEY');
}
