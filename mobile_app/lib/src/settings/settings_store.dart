import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../local_config.dart';

class SettingsStore {
  SettingsStore({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  static const _volcengineArkApiKeyKey = 'volcengine_ark_api_key';
  static const _volcengineArkBaseUrlKey = 'volcengine_ark_base_url';
  static const _volcengineArkSpeechModelKey = 'volcengine_ark_speech_model';
  static const _volcengineArkTextModelKey = 'volcengine_ark_text_model';
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
    return await _storage.read(key: _volcengineArkBaseUrlKey) ?? 'https://ark.cn-beijing.volces.com/api/v3';
  }

  Future<void> setVolcengineArkBaseUrl(String value) {
    return _storage.write(
      key: _volcengineArkBaseUrlKey,
      value: value.trim().isEmpty ? 'https://ark.cn-beijing.volces.com/api/v3' : value.trim(),
    );
  }

  Future<String> volcengineArkSpeechModel() async {
    return await _storage.read(key: _volcengineArkSpeechModelKey) ?? 'doubao-seed-2-0-lite-260428';
  }

  Future<void> setVolcengineArkSpeechModel(String value) {
    return _storage.write(key: _volcengineArkSpeechModelKey, value: value.trim());
  }

  Future<String> volcengineArkTextModel() async {
    return await _storage.read(key: _volcengineArkTextModelKey) ?? 'doubao-seed-2-1-pro-260628';
  }

  Future<void> setVolcengineArkTextModel(String value) {
    return _storage.write(key: _volcengineArkTextModelKey, value: value.trim());
  }

  Future<bool> databaseEncryptionEnabled() async {
    return (await _storage.read(key: _databaseEncryptionEnabledKey)) == 'true';
  }

  Future<void> setDatabaseEncryptionEnabled(bool value) {
    return _storage.write(key: _databaseEncryptionEnabledKey, value: value.toString());
  }
}
