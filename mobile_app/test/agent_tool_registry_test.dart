import 'package:flutter_test/flutter_test.dart';
import 'package:local_idea_capture/src/agent/agent_models.dart';
import 'package:local_idea_capture/src/agent/agent_tool.dart';

void main() {
  test('registry rejects unknown tools and invalid required arguments',
      () async {
    final registry = AgentToolRegistry([_EchoTool()]);

    expect(() => registry.require('missing'), throwsStateError);
    final result = await registry.execute(
      const AgentToolCall(callId: 'c1', name: 'echo', arguments: {}),
      const ToolExecutionContext(threadId: 't1', runId: 'r1'),
    );

    expect(result.isSuccess, isFalse);
    expect(result.errorCode, 'invalid_arguments');
  });

  test('update tools return a confirmation instead of executing', () async {
    final tool = _UpdateTool();
    final registry = AgentToolRegistry([tool]);

    final outcome = await registry.dispatch(
      const AgentToolCall(
        callId: 'c2',
        name: 'record_update',
        arguments: {'id': 'one', 'title': 'new'},
      ),
      const ToolExecutionContext(threadId: 't1', runId: 'r1'),
    );

    expect(outcome.pendingConfirmation, isNotNull);
    expect(outcome.result, isNull);
    expect(tool.executions, 0);
  });

  test('duplicate idempotency keys execute a create tool once', () async {
    final tool = _CreateTool();
    final registry = AgentToolRegistry([tool]);
    const call = AgentToolCall(
      callId: 'c3',
      name: 'record_create',
      arguments: {'title': 'one'},
    );
    const context = ToolExecutionContext(
      threadId: 't1',
      runId: 'r1',
      idempotencyKey: 'same-key',
    );

    final first = await registry.execute(call, context);
    final second = await registry.execute(call, context);

    expect(first.data, second.data);
    expect(tool.executions, 1);
  });

  test('confirmation token executes exactly once and preserves record version',
      () async {
    final tool = _UpdateTool();
    final registry = AgentToolRegistry([tool]);
    const context = ToolExecutionContext(threadId: 't1', runId: 'r1');
    final dispatched = await registry.dispatch(
      const AgentToolCall(
        callId: 'confirm-call',
        name: 'record_update',
        arguments: {'id': 'one', 'title': 'new'},
      ),
      context,
    );
    final pending = dispatched.pendingConfirmation!;

    final confirmed = await registry.confirm(pending, pending.token, context);
    final replay = await registry.confirm(pending, pending.token, context);

    expect(confirmed.isSuccess, isTrue);
    expect(replay.errorCode, 'confirmation_already_used');
    expect(tool.lastArguments?['expected_updated_at'], 'version-1');
    expect(tool.executions, 1);
  });
}

class _EchoTool extends AgentTool {
  @override
  AgentToolDefinition get definition => const AgentToolDefinition(
        name: 'echo',
        description: 'echo text',
        domain: 'test',
        parameters: {
          'type': 'object',
          'properties': {
            'text': {'type': 'string'},
          },
          'required': ['text'],
          'additionalProperties': false,
        },
      );

  @override
  ToolRiskLevel get riskLevel => ToolRiskLevel.read;

  @override
  Future<ToolResult> execute(
    Map<String, dynamic> arguments,
    ToolExecutionContext context,
  ) async =>
      ToolResult.success(arguments);
}

class _UpdateTool extends AgentTool {
  int executions = 0;
  Map<String, dynamic>? lastArguments;

  @override
  AgentToolDefinition get definition => const AgentToolDefinition(
        name: 'record_update',
        description: 'update record',
        domain: 'test',
        parameters: {
          'type': 'object',
          'properties': {
            'id': {'type': 'string'},
            'title': {'type': 'string'},
            'expected_updated_at': {'type': 'string'},
          },
          'required': ['id'],
          'additionalProperties': false,
        },
      );

  @override
  ToolRiskLevel get riskLevel => ToolRiskLevel.update;

  @override
  Future<ToolResult> execute(
    Map<String, dynamic> arguments,
    ToolExecutionContext context,
  ) async {
    executions++;
    lastArguments = arguments;
    return ToolResult.success(arguments);
  }

  @override
  Future<ToolPreview?> preview(
    Map<String, dynamic> arguments,
    ToolExecutionContext context,
  ) async =>
      const ToolPreview(
        title: 'Update record',
        affectedCount: 1,
        recordVersion: 'version-1',
      );
}

class _CreateTool extends AgentTool {
  int executions = 0;

  @override
  AgentToolDefinition get definition => const AgentToolDefinition(
        name: 'record_create',
        description: 'create record',
        domain: 'test',
        parameters: {
          'type': 'object',
          'properties': {
            'title': {'type': 'string'},
          },
          'required': ['title'],
          'additionalProperties': false,
        },
      );

  @override
  ToolRiskLevel get riskLevel => ToolRiskLevel.create;

  @override
  Future<ToolResult> execute(
    Map<String, dynamic> arguments,
    ToolExecutionContext context,
  ) async {
    executions++;
    return ToolResult.success({'id': 'created'});
  }
}
