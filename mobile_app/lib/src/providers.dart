import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'ai/volcengine_ark_capture_client.dart';
import 'ai/ark_responses_agent_client.dart';
import 'agent/agent_runtime.dart';
import 'agent/agent_session_controller.dart';
import 'agent/agent_tool.dart';
import 'agent/local_agent_tools.dart';
import 'audio/interaction_sound_service.dart';
import 'data/app_database.dart';
import 'data/entry_repository.dart';
import 'domain/capture_conversation_agent.dart';
import 'local_ai/local_model_manager.dart';
import 'local_ai/local_voice_runtime.dart';
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

final localModelManagerProvider = Provider<LocalModelManager>((ref) {
  final manager = LocalModelManager();
  unawaited(manager.initialize());
  ref.onDispose(() => manager.dispose());
  return manager;
});

final speechChannelProvider = Provider<LocalVoiceSpeechService>((ref) {
  final service = LocalVoiceSpeechService(ref.watch(localModelManagerProvider));
  ref.onDispose(service.dispose);
  return service;
});

final captureConversationAgentProvider =
    Provider<CaptureConversationAgent>((ref) {
  final arkClient = ref.watch(volcengineArkCaptureClientProvider);
  final router = CloudCaptureRouter(
    cloudCapture: (request) => arkClient.captureText(
      text: request.text,
      conversation: request.conversation,
      pendingDraft: request.pendingDraft,
      missingFields: request.missingFields,
      isFollowUp: request.isFollowUp,
    ),
    cloudCaptureStream: (request) => arkClient
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
    }),
  );
  return CaptureConversationAgent(
    repository: ref.watch(entryRepositoryProvider),
    capture: router.capture,
    captureStream: router.captureStream,
  );
});

final volcengineArkFilesClientProvider =
    Provider<VolcengineArkFilesClient>((ref) {
  return VolcengineArkFilesClient(ref.watch(settingsStoreProvider));
});

final cloudSpeechChannelProvider = Provider<VolcengineSpeechService>((ref) {
  return VolcengineSpeechService(ref.watch(volcengineArkFilesClientProvider));
});

final interactionSoundServiceProvider =
    Provider<InteractionSoundService>((ref) {
  final service = LocalInteractionSoundService();
  ref.onDispose(service.dispose);
  return service;
});

final agentToolRegistryProvider = Provider<AgentToolRegistry>((ref) {
  return AgentToolRegistry(buildLocalAgentTools(ref.watch(databaseProvider)));
});

final agentModelClientProvider = Provider<ArkResponsesAgentClient>((ref) {
  final settings = ref.watch(settingsStoreProvider);
  return ArkResponsesAgentClient(
    apiKey: () async => await settings.volcengineArkApiKey() ?? '',
    baseUrl: settings.volcengineArkBaseUrl,
    model: settings.volcengineArkTextModel,
  );
});

final agentRuntimeProvider = Provider<AgentRuntime>((ref) {
  return AgentRuntime(
    modelClient: ref.watch(agentModelClientProvider),
    tools: ref.watch(agentToolRegistryProvider),
  );
});

final agentSessionControllerProvider = Provider<AgentSessionController>((ref) {
  return AgentSessionController(
    database: ref.watch(databaseProvider),
    runtime: ref.watch(agentRuntimeProvider),
    threadId: 'default-agent-thread',
  );
});
