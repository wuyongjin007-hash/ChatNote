import 'dart:convert';

enum ToolRiskLevel { read, create, update, delete, bulkWrite }

class AgentToolDefinition {
  const AgentToolDefinition({
    required this.name,
    required this.description,
    required this.domain,
    required this.parameters,
    this.resultSchemaVersion = 1,
    this.supportsBatch = false,
  });

  final String name;
  final String description;
  final String domain;
  final Map<String, dynamic> parameters;
  final int resultSchemaVersion;
  final bool supportsBatch;

  Map<String, dynamic> toResponsesJson() => {
        'type': 'function',
        'name': name,
        'description': description,
        'parameters': parameters,
        'strict': true,
      };
}

class AgentToolCall {
  const AgentToolCall({
    required this.callId,
    required this.name,
    required this.arguments,
  });

  final String callId;
  final String name;
  final Map<String, dynamic> arguments;
}

class ToolExecutionContext {
  const ToolExecutionContext({
    required this.threadId,
    required this.runId,
    this.idempotencyKey,
  });

  final String threadId;
  final String runId;
  final String? idempotencyKey;
}

class ToolResult {
  const ToolResult({
    required this.isSuccess,
    required this.data,
    this.errorCode,
    this.message,
  });

  factory ToolResult.success(Map<String, dynamic> data) =>
      ToolResult(isSuccess: true, data: data);

  factory ToolResult.failure(String code, String message) => ToolResult(
        isSuccess: false,
        data: const {},
        errorCode: code,
        message: message,
      );

  final bool isSuccess;
  final Map<String, dynamic> data;
  final String? errorCode;
  final String? message;

  String toModelOutput() => jsonEncode({
        'ok': isSuccess,
        if (isSuccess) 'data': data,
        if (!isSuccess) 'error': {'code': errorCode, 'message': message},
      });
}

class ToolPreview {
  const ToolPreview({
    required this.title,
    required this.affectedCount,
    this.description = '',
    this.before,
    this.after,
    this.recordVersion,
  });

  final String title;
  final String description;
  final int affectedCount;
  final Map<String, dynamic>? before;
  final Map<String, dynamic>? after;
  final String? recordVersion;
}

class PendingToolConfirmation {
  const PendingToolConfirmation({
    required this.token,
    required this.call,
    required this.preview,
    required this.expiresAt,
  });

  final String token;
  final AgentToolCall call;
  final ToolPreview preview;
  final DateTime expiresAt;
}

class ToolDispatchOutcome {
  const ToolDispatchOutcome({this.result, this.pendingConfirmation});

  final ToolResult? result;
  final PendingToolConfirmation? pendingConfirmation;
}

abstract class AgentEvent {
  const AgentEvent();
}

class AgentTextDelta extends AgentEvent {
  const AgentTextDelta(this.text);
  final String text;
}

class AgentReasoningStatus extends AgentEvent {
  const AgentReasoningStatus(this.label);
  final String label;
}

class AgentToolCallRequested extends AgentEvent {
  const AgentToolCallRequested(this.call);
  final AgentToolCall call;
}

class AgentResponseCompleted extends AgentEvent {
  const AgentResponseCompleted({required this.responseId});
  final String responseId;
}

class AgentResponseFailed extends AgentEvent {
  const AgentResponseFailed(this.message);
  final String message;
}

class AgentInputItem {
  const AgentInputItem._(this.json);
  final Map<String, dynamic> json;

  factory AgentInputItem.message(String role, String text) => AgentInputItem._({
        'type': 'message',
        'role': role,
        'content': text,
      });

  factory AgentInputItem.toolOutput(String callId, String output) =>
      AgentInputItem._({
        'type': 'function_call_output',
        'call_id': callId,
        'output': output,
      });
}

class AgentRunPolicy {
  const AgentRunPolicy({
    this.maxModelRounds = 6,
    this.maxToolCalls = 10,
    this.toolTimeout = const Duration(seconds: 10),
  });

  final int maxModelRounds;
  final int maxToolCalls;
  final Duration toolTimeout;
}

class AgentRequest {
  const AgentRequest({
    required this.input,
    required this.tools,
    this.previousResponseId,
    this.policy = const AgentRunPolicy(),
  });

  final List<AgentInputItem> input;
  final List<AgentToolDefinition> tools;
  final String? previousResponseId;
  final AgentRunPolicy policy;
}

abstract interface class AgentModelClient {
  Stream<AgentEvent> run(AgentRequest request);
}
