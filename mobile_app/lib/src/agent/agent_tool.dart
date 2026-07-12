import 'dart:async';
import 'dart:convert';

import 'agent_models.dart';

abstract class AgentTool {
  AgentToolDefinition get definition;
  ToolRiskLevel get riskLevel;

  Future<ToolResult> execute(
    Map<String, dynamic> arguments,
    ToolExecutionContext context,
  );

  Future<ToolPreview?> preview(
    Map<String, dynamic> arguments,
    ToolExecutionContext context,
  ) async =>
      null;
}

class AgentToolRegistry {
  AgentToolRegistry(Iterable<AgentTool> tools)
      : _tools = {for (final tool in tools) tool.definition.name: tool} {
    if (_tools.length != tools.length) {
      throw ArgumentError('Agent tool names must be unique');
    }
  }

  final Map<String, AgentTool> _tools;
  final Map<String, ToolResult> _idempotentResults = {};
  final Set<String> _usedConfirmationTokens = {};

  List<AgentToolDefinition> get definitions =>
      _tools.values.map((tool) => tool.definition).toList(growable: false);

  AgentTool require(String name) {
    final tool = _tools[name];
    if (tool == null) throw StateError('Unknown agent tool: $name');
    return tool;
  }

  Future<ToolDispatchOutcome> dispatch(
    AgentToolCall call,
    ToolExecutionContext context,
  ) async {
    final tool = require(call.name);
    final invalid = _validate(tool.definition.parameters, call.arguments);
    if (invalid != null) {
      return ToolDispatchOutcome(
        result: ToolResult.failure('invalid_arguments', invalid),
      );
    }
    if (tool.riskLevel == ToolRiskLevel.update ||
        tool.riskLevel == ToolRiskLevel.delete ||
        tool.riskLevel == ToolRiskLevel.bulkWrite) {
      final preview = await tool.preview(call.arguments, context) ??
          ToolPreview(
            title: call.name,
            affectedCount: tool.riskLevel == ToolRiskLevel.bulkWrite ? 0 : 1,
          );
      final expiresAt = DateTime.now().add(const Duration(minutes: 10));
      return ToolDispatchOutcome(
        pendingConfirmation: PendingToolConfirmation(
          token: _confirmationToken(call, preview, expiresAt),
          call: call,
          preview: preview,
          expiresAt: expiresAt,
        ),
      );
    }
    return ToolDispatchOutcome(result: await execute(call, context));
  }

  Future<ToolResult> execute(
    AgentToolCall call,
    ToolExecutionContext context,
  ) async {
    final tool = require(call.name);
    final invalid = _validate(tool.definition.parameters, call.arguments);
    if (invalid != null) {
      return ToolResult.failure('invalid_arguments', invalid);
    }
    final key = context.idempotencyKey;
    if (key != null && _idempotentResults.containsKey(key)) {
      return _idempotentResults[key]!;
    }
    try {
      final result = await tool
          .execute(call.arguments, context)
          .timeout(const Duration(seconds: 10));
      if (key != null && result.isSuccess) _idempotentResults[key] = result;
      return result;
    } on TimeoutException {
      return ToolResult.failure('timeout', 'Tool execution timed out');
    } catch (error) {
      return ToolResult.failure('execution_failed', error.toString());
    }
  }

  Future<ToolResult> confirm(
    PendingToolConfirmation pending,
    String token,
    ToolExecutionContext context,
  ) async {
    if (token != pending.token) {
      return ToolResult.failure('invalid_confirmation', '确认令牌无效');
    }
    if (_usedConfirmationTokens.contains(token)) {
      return ToolResult.failure('confirmation_already_used', '确认已执行，不能重复使用');
    }
    if (!pending.expiresAt.isAfter(DateTime.now())) {
      return ToolResult.failure('confirmation_expired', '确认已过期，请重新预览');
    }
    _usedConfirmationTokens.add(token);
    final arguments = Map<String, dynamic>.from(pending.call.arguments);
    final version = pending.preview.recordVersion;
    if (version != null) arguments['expected_updated_at'] = version;
    return execute(
      AgentToolCall(
        callId: pending.call.callId,
        name: pending.call.name,
        arguments: arguments,
      ),
      context,
    );
  }

  String? _validate(
    Map<String, dynamic> schema,
    Map<String, dynamic> arguments,
  ) {
    final required = (schema['required'] as List<dynamic>? ?? const [])
        .map((value) => value.toString());
    for (final key in required) {
      if (!arguments.containsKey(key) || arguments[key] == null) {
        return 'Missing required argument: $key';
      }
    }
    final properties =
        Map<String, dynamic>.from(schema['properties'] as Map? ?? const {});
    if (schema['additionalProperties'] == false) {
      final unknown =
          arguments.keys.where((key) => !properties.containsKey(key));
      if (unknown.isNotEmpty) return 'Unknown argument: ${unknown.first}';
    }
    for (final entry in arguments.entries) {
      final spec = properties[entry.key];
      if (spec is! Map || entry.value == null) continue;
      final expected = spec['type'];
      final valid = switch (expected) {
        'string' => entry.value is String,
        'integer' => entry.value is int,
        'number' => entry.value is num,
        'boolean' => entry.value is bool,
        'array' => entry.value is List,
        'object' => entry.value is Map,
        _ => true,
      };
      if (!valid) return 'Invalid type for ${entry.key}: expected $expected';
    }
    return null;
  }

  String _confirmationToken(
    AgentToolCall call,
    ToolPreview preview,
    DateTime expiresAt,
  ) {
    final raw = jsonEncode({
      'call': call.callId,
      'name': call.name,
      'arguments': call.arguments,
      'version': preview.recordVersion,
      'expires': expiresAt.toUtc().toIso8601String(),
    });
    var hash = 0xcbf29ce484222325;
    for (final byte in utf8.encode(raw)) {
      hash ^= byte;
      hash = (hash * 0x100000001b3) & 0x7fffffffffffffff;
    }
    return hash.toRadixString(16);
  }
}
