import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ai/volcengine_ark_capture_client.dart';
import 'data/app_database.dart';
import 'data/entry_repository.dart';
import 'domain/capture_conversation_agent.dart';
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

final volcengineArkCaptureClientProvider =
    Provider<VolcengineArkCaptureClient>((ref) {
  return VolcengineArkCaptureClient(ref.watch(settingsStoreProvider));
});

final localCaptureHeuristicsProvider = Provider<LocalCaptureHeuristics>((ref) {
  return LocalCaptureHeuristics();
});

final captureConversationAgentProvider =
    Provider<CaptureConversationAgent>((ref) {
  final arkClient = ref.watch(volcengineArkCaptureClientProvider);
  return CaptureConversationAgent(
    heuristics: ref.watch(localCaptureHeuristicsProvider),
    capture: (request) {
      return arkClient.captureText(
        text: request.text,
        conversation: request.conversation,
        pendingDraft: request.pendingDraft,
        missingFields: request.missingFields,
        isFollowUp: request.isFollowUp,
      );
    },
    captureStream: (request) {
      return arkClient
          .captureTextStream(
        text: request.text,
        conversation: request.conversation,
        pendingDraft: request.pendingDraft,
        missingFields: request.missingFields,
        isFollowUp: request.isFollowUp,
      )
          .map((event) {
        if (event is ArkAssistantDelta) {
          return CaptureAgentAssistantDelta(event.text);
        }
        if (event is ArkCaptureDone) {
          return CaptureAgentDone(event.capture);
        }
        throw StateError('Unsupported Ark stream event: $event');
      });
    },
  );
});

final volcengineArkFilesClientProvider =
    Provider<VolcengineArkFilesClient>((ref) {
  return VolcengineArkFilesClient(ref.watch(settingsStoreProvider));
});

final speechChannelProvider = Provider<VolcengineSpeechService>((ref) {
  return VolcengineSpeechService(ref.watch(volcengineArkFilesClientProvider));
});
