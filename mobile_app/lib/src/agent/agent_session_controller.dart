import 'dart:convert';

import 'package:uuid/uuid.dart';

import '../data/app_database.dart';
import 'agent_models.dart';
import 'agent_runtime.dart';
import 'memory_context_builder.dart';

class AgentSessionController {
  AgentSessionController({
    required AppDatabase database,
    required AgentRuntime runtime,
    required this.threadId,
    MemoryContextBuilder? memoryContextBuilder,
  })  : _database = database,
        _runtime = runtime,
        _memoryContextBuilder =
            memoryContextBuilder ?? MemoryContextBuilder(database);

  final AppDatabase _database;
  final AgentRuntime _runtime;
  final MemoryContextBuilder _memoryContextBuilder;
  final String threadId;
  final List<AgentMessage> _messages = [];
  String? _previousResponseId;
  PendingToolConfirmation? _pending;
  String? _pendingResponseId;
  String? _pendingRunId;

  List<AgentMessage> get messages => List.unmodifiable(_messages);
  PendingToolConfirmation? get pendingConfirmation => _pending;

  Future<void> initialize() async {
    final existing = await _database.loadAgentThread(threadId);
    if (existing == null) {
      await _database.upsertAgentThread(id: threadId, status: 'idle');
    } else {
      _previousResponseId = existing.previousResponseId;
    }
    _messages
      ..clear()
      ..addAll(await _database.loadRecentAgentMessages(threadId, 12));
    final stored = await _database.loadPendingAgentConfirmation();
    if (stored != null) {
      try {
        final previewJson =
            jsonDecode(stored.previewJson) as Map<String, dynamic>;
        _pending = PendingToolConfirmation(
          token: stored.token,
          call: AgentToolCall(
            callId: stored.toolCallId,
            name: stored.toolName,
            arguments: jsonDecode(stored.argumentsJson) as Map<String, dynamic>,
          ),
          preview: ToolPreview(
            title: previewJson['title'] as String? ?? stored.toolName,
            description: previewJson['description'] as String? ?? '',
            affectedCount: previewJson['affected_count'] as int? ?? 1,
            before: previewJson['before'] as Map<String, dynamic>?,
            after: previewJson['after'] as Map<String, dynamic>?,
            recordVersion: stored.recordVersion,
          ),
          expiresAt: DateTime.parse(stored.expiresAt).toLocal(),
        );
        _pendingResponseId = stored.responseId;
        _pendingRunId = stored.runId;
      } catch (_) {
        await _database.resolveAgentConfirmation(stored.token, 'invalid');
      }
    }
  }

  Stream<AgentRuntimeEvent> send(String text) async* {
    final normalized = text.trim();
    if (normalized.isEmpty) return;
    if (_pending != null) {
      yield const AgentRuntimeFailure('请先确认或取消当前待执行操作');
      return;
    }
    final context = await _memoryContextBuilder.build(
      threadId: threadId,
      memoryKeyword: _memoryKeyword(normalized),
    );
    final messageId = const Uuid().v4();
    final now = DateTime.now();
    await _database.appendAgentMessage(
      id: messageId,
      threadId: threadId,
      role: 'user',
      content: normalized,
      createdAt: now,
    );
    final explicitMemory = _explicitMemory(normalized);
    if (explicitMemory != null) {
      await _database.saveMemoryItem(
        id: const Uuid().v4(),
        memoryType: 'explicit_preference',
        content: explicitMemory,
        confidence: 1,
        createdAt: now,
        sourceMessageId: messageId,
      );
    }
    _messages.add(AgentMessage(
      id: messageId,
      threadId: threadId,
      role: 'user',
      content: normalized,
      createdAt: now.toUtc().toIso8601String(),
    ));
    final runId = const Uuid().v4();
    await _database.startAgentRun(id: runId, threadId: threadId);
    final assistant = StringBuffer();
    final history = <AgentInputItem>[
      if (context.contextNote.isNotEmpty)
        AgentInputItem.message('developer', context.contextNote),
      if (_previousResponseId == null) ...context.recentMessages,
    ];
    await for (final event in _runtime.runTurn(
      threadId: threadId,
      runId: runId,
      input: normalized,
      history: history,
      previousResponseId: _previousResponseId,
    )) {
      if (event is AgentRuntimeText) assistant.write(event.text);
      if (event is AgentRuntimeToolActivity) {
        await _auditToolActivity(runId, event);
      }
      if (event is AgentRuntimeConfirmation) {
        _pending = event.confirmation;
        _pendingResponseId = event.responseId;
        _pendingRunId = runId;
        await _persistConfirmation(event.confirmation, event.responseId, runId);
        await _database.upsertAgentThread(
          id: threadId,
          status: 'awaitingConfirmation',
          previousResponseId: event.responseId,
        );
      } else if (event is AgentRuntimeCompleted) {
        _previousResponseId = event.responseId;
        await _database.upsertAgentThread(
          id: threadId,
          status: 'completed',
          previousResponseId: event.responseId,
        );
        await _persistAssistant(assistant.toString());
        await _database.finishAgentRun(runId, status: 'completed');
      } else if (event is AgentRuntimeFailure) {
        await _database.finishAgentRun(
          runId,
          status: 'failedRecoverable',
          error: event.message,
        );
      }
      yield event;
    }
  }

  Stream<AgentRuntimeEvent> confirmPending() async* {
    final pending = _pending;
    final responseId = _pendingResponseId;
    final runId = _pendingRunId;
    if (pending == null || responseId == null || runId == null) {
      yield const AgentRuntimeFailure('没有等待确认的操作');
      return;
    }
    final assistant = StringBuffer();
    await for (final event in _runtime.resumeConfirmation(
      threadId: threadId,
      runId: runId,
      pending: pending,
      token: pending.token,
      previousResponseId: responseId,
    )) {
      if (event is AgentRuntimeText) assistant.write(event.text);
      if (event is AgentRuntimeToolActivity) {
        await _auditToolActivity(runId, event);
      }
      if (event is AgentRuntimeCompleted) {
        _previousResponseId = event.responseId;
        await _database.resolveAgentConfirmation(pending.token, 'executed');
        await _database.upsertAgentThread(
          id: threadId,
          status: 'completed',
          previousResponseId: event.responseId,
        );
        await _persistAssistant(assistant.toString());
        await _database.finishAgentRun(runId, status: 'completed');
        _clearPending();
      } else if (event is AgentRuntimeFailure) {
        await _database.finishAgentRun(
          runId,
          status: 'failedRecoverable',
          error: event.message,
        );
      }
      yield event;
    }
  }

  Future<void> cancelPending() async {
    final pending = _pending;
    if (pending != null) {
      await _database.resolveAgentConfirmation(pending.token, 'cancelled');
    }
    _clearPending();
    await _database.upsertAgentThread(
      id: threadId,
      status: 'idle',
      previousResponseId: _previousResponseId,
    );
  }

  Future<void> _persistAssistant(String text) async {
    final normalized = text.trim();
    if (normalized.isEmpty) return;
    final id = const Uuid().v4();
    final now = DateTime.now();
    await _database.appendAgentMessage(
      id: id,
      threadId: threadId,
      role: 'assistant',
      content: normalized,
      createdAt: now,
    );
    _messages.add(AgentMessage(
      id: id,
      threadId: threadId,
      role: 'assistant',
      content: normalized,
      createdAt: now.toUtc().toIso8601String(),
    ));
    await _compactWorkingMemory();
  }

  Future<void> _compactWorkingMemory() async {
    if (_messages.length <= 12) return;
    final overflow = _messages.take(_messages.length - 12).toList();
    final existing = await _database.loadAgentThread(threadId);
    final addition = overflow
        .map((message) =>
            '${message.role == 'user' ? '用户' : '助手'}：${message.content}')
        .join('\n');
    final combined = [existing?.rollingSummary, addition]
        .whereType<String>()
        .where((value) => value.trim().isNotEmpty)
        .join('\n');
    final bounded = combined.length <= 2000
        ? combined
        : combined.substring(combined.length - 2000);
    await _database.upsertAgentThread(
      id: threadId,
      status: existing?.status ?? 'completed',
      previousResponseId: _previousResponseId,
      rollingSummary: bounded,
    );
    _messages.removeRange(0, _messages.length - 12);
  }

  Future<void> _persistConfirmation(
    PendingToolConfirmation pending,
    String responseId,
    String runId,
  ) {
    final preview = pending.preview;
    return _database.saveAgentConfirmation(
      token: pending.token,
      callId: pending.call.callId,
      runId: runId,
      toolName: pending.call.name,
      arguments: pending.call.arguments,
      preview: {
        'title': preview.title,
        'description': preview.description,
        'affected_count': preview.affectedCount,
        'before': preview.before,
        'after': preview.after,
      },
      responseId: responseId,
      expiresAt: pending.expiresAt,
      recordVersion: preview.recordVersion,
    );
  }

  Future<void> _auditToolActivity(
      String runId, AgentRuntimeToolActivity event) async {
    final items = event.result?.data['items'];
    if (items is List) {
      final refs = items
          .whereType<Map>()
          .take(50)
          .map((item) => {
                'id': item['id'],
                'type': item['type'] ?? event.call.name.split('_').first,
                'title': item['title'] ?? item['summary'] ?? item['note'],
              })
          .toList(growable: false);
      if (refs.isNotEmpty) {
        await _database.updateAgentEntityRefs(threadId, refs);
      }
    }
    await _database.upsertToolAudit(
      id: '${runId}_${event.call.callId}',
      runId: runId,
      callId: event.call.callId,
      toolName: event.call.name,
      argumentsJson: jsonEncode(event.call.arguments),
      riskLevel: event.riskLevel.name,
      status: event.status,
      resultJson: event.result?.toModelOutput(),
      idempotencyKey: '${runId}_${event.call.callId}',
      error: event.result?.isSuccess == false ? event.result?.message : null,
    );
  }

  void _clearPending() {
    _pending = null;
    _pendingResponseId = null;
    _pendingRunId = null;
  }

  String _memoryKeyword(String text) {
    for (final keyword in const ['记账', '想法', '待办', '偏好', '项目']) {
      if (text.contains(keyword)) return keyword;
    }
    return '';
  }

  String? _explicitMemory(String text) {
    const sensitive = ['API Key', 'api key', '密码', '密钥', 'token'];
    if (sensitive.any(text.contains)) return null;
    for (final prefix in const ['请记住', '记住']) {
      if (text.startsWith(prefix)) {
        final content = text.substring(prefix.length).trim();
        return content.isEmpty ? null : content;
      }
    }
    return null;
  }
}
