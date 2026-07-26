import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../local_config.dart';

enum VoiceCaptureProvider { volcengineArk, deepSeek }

class SettingsStore {
  SettingsStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _volcengineArkApiKeyKey = 'volcengine_ark_api_key';
  static const _volcengineArkBaseUrlKey = 'volcengine_ark_base_url';
  static const _volcengineArkSpeechModelKey = 'volcengine_ark_speech_model';
  static const _volcengineArkTextModelKey = 'volcengine_ark_text_model';
  static const _voiceCaptureProviderKey = 'voice_capture_provider';
  static const _deepSeekApiKeyKey = 'deepseek_api_key';
  static const _deepSeekBaseUrlKey = 'deepseek_base_url';
  static const _deepSeekTextModelKey = 'deepseek_text_model';
  static const _databaseEncryptionEnabledKey = 'database_encryption_enabled';

  final FlutterSecureStorage _storage;

  Future<String?> volcengineArkApiKey() async {
    final stored = await _storage.read(key: _volcengineArkApiKeyKey);
    if (stored != null && stored.trim().isNotEmpty) {
      return stored;
    }
    return LocalConfig.volcengineArkApiKey;
  }

  Future<void> setVolcengineArkApiKey(String value) {
    return _storage.write(key: _volcengineArkApiKeyKey, value: value.trim());
  }

  Future<String> volcengineArkBaseUrl() async {
    return await _storage.read(key: _volcengineArkBaseUrlKey) ??
        'https://ark.cn-beijing.volces.com/api/v3';
  }

  Future<void> setVolcengineArkBaseUrl(String value) {
    return _storage.write(
      key: _volcengineArkBaseUrlKey,
      value: value.trim().isEmpty
          ? 'https://ark.cn-beijing.volces.com/api/v3'
          : value.trim(),
    );
  }

  Future<String> volcengineArkSpeechModel() async {
    return await _storage.read(key: _volcengineArkSpeechModelKey) ??
        'doubao-seed-2-0-lite-260428';
  }

  Future<void> setVolcengineArkSpeechModel(String value) {
    return _storage.write(
        key: _volcengineArkSpeechModelKey, value: value.trim());
  }

  Future<String> volcengineArkTextModel() async {
    return await _storage.read(key: _volcengineArkTextModelKey) ??
        'doubao-seed-2-1-pro-260628';
  }

  Future<void> setVolcengineArkTextModel(String value) {
    return _storage.write(key: _volcengineArkTextModelKey, value: value.trim());
  }

  Future<VoiceCaptureProvider> voiceCaptureProvider() async {
    return (await _storage.read(key: _voiceCaptureProviderKey)) == 'deepseek'
        ? VoiceCaptureProvider.deepSeek
        : VoiceCaptureProvider.volcengineArk;
  }

  Future<void> setVoiceCaptureProvider(VoiceCaptureProvider value) {
    return _storage.write(
      key: _voiceCaptureProviderKey,
      value: value == VoiceCaptureProvider.deepSeek ? 'deepseek' : 'ark',
    );
  }

  Future<String?> deepSeekApiKey() async {
    final stored = await _storage.read(key: _deepSeekApiKeyKey);
    return stored?.trim().isEmpty ?? true ? null : stored!.trim();
  }

  Future<void> setDeepSeekApiKey(String value) {
    return _storage.write(key: _deepSeekApiKeyKey, value: value.trim());
  }

  Future<String> deepSeekBaseUrl() async {
    return await _storage.read(key: _deepSeekBaseUrlKey) ??
        'https://api.deepseek.com';
  }

  Future<void> setDeepSeekBaseUrl(String value) {
    return _storage.write(
      key: _deepSeekBaseUrlKey,
      value: value.trim().isEmpty ? 'https://api.deepseek.com' : value.trim(),
    );
  }

  Future<String> deepSeekTextModel() async {
    return await _storage.read(key: _deepSeekTextModelKey) ??
        'deepseek-v4-flash';
  }

  Future<void> setDeepSeekTextModel(String value) {
    return _storage.write(key: _deepSeekTextModelKey, value: value.trim());
  }

  Future<String?> voiceCaptureApiKey() async {
    return switch (await voiceCaptureProvider()) {
      VoiceCaptureProvider.volcengineArk => await volcengineArkApiKey(),
      VoiceCaptureProvider.deepSeek => await deepSeekApiKey(),
    };
  }

  Future<String> voiceCaptureBaseUrl() async {
    return switch (await voiceCaptureProvider()) {
      VoiceCaptureProvider.volcengineArk => await volcengineArkBaseUrl(),
      VoiceCaptureProvider.deepSeek => await deepSeekBaseUrl(),
    };
  }

  Future<String> voiceCaptureTextModel() async {
    return switch (await voiceCaptureProvider()) {
      VoiceCaptureProvider.volcengineArk => await volcengineArkTextModel(),
      VoiceCaptureProvider.deepSeek => await deepSeekTextModel(),
    };
  }

  Future<bool> databaseEncryptionEnabled() async {
    return (await _storage.read(key: _databaseEncryptionEnabledKey)) == 'true';
  }

  Future<void> setDatabaseEncryptionEnabled(bool value) {
    return _storage.write(
        key: _databaseEncryptionEnabledKey, value: value.toString());
  }
}
