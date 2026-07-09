import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ai/volcengine_ark_capture_client.dart';
import 'data/app_database.dart';
import 'data/entry_repository.dart';
import 'domain/local_capture_heuristics.dart';
import 'settings/settings_store.dart';
import 'speech/volcengine_ark_files_client.dart';
import 'speech/volcengine_speech_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final entryRepositoryProvider = Provider<EntryRepository>((ref) {
  return EntryRepository(ref.watch(databaseProvider));
});

final settingsStoreProvider = Provider<SettingsStore>((ref) {
  return SettingsStore();
});

final volcengineArkCaptureClientProvider = Provider<VolcengineArkCaptureClient>((ref) {
  return VolcengineArkCaptureClient(ref.watch(settingsStoreProvider));
});

final localCaptureHeuristicsProvider = Provider<LocalCaptureHeuristics>((ref) {
  return LocalCaptureHeuristics();
});

final volcengineArkFilesClientProvider = Provider<VolcengineArkFilesClient>((ref) {
  return VolcengineArkFilesClient(ref.watch(settingsStoreProvider));
});

final speechChannelProvider = Provider<VolcengineSpeechService>((ref) {
  return VolcengineSpeechService(ref.watch(volcengineArkFilesClientProvider));
});
