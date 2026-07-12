import 'package:flutter_test/flutter_test.dart';
import 'package:local_idea_capture/src/agent/agent_models.dart';
import 'package:local_idea_capture/src/agent/agent_runtime.dart';
import 'package:local_idea_capture/src/agent/agent_tool.dart';

void main() {
  test('executes a model tool call and feeds its output into the next round',
      () async {
    final client = _TwoRoundClient();
    final tool = _LookupTool();
    final runtime = AgentRuntime(
      modelClient: client,
      tools: AgentToolRegistry([tool]),
    );

    final events = await runtime
        .runTurn(
          threadId: 'thread',
          runId: 'run',
          input: '总结最近的想法',
        )
        .toList();

    expect(tool.executions, 1);
    expect(
      events.whereType<AgentRuntimeToolActivity>().single.status,
      'completed',
    );
    expect(client.requests, hasLength(2));
    expect(client.requests.last.previousResponseId, 'response-1');
    expect(
      client.requests.last.input.single.json['type'],
      'function_call_output',
    );
    expect(
      events.whereType<AgentRuntimeText>().map((event) => event.text).join(),
      '最近有一条想法。',
    );
  });

  test('stops before executing a tool that requires confirmation', () async {
    final client = _UpdateClient();
    final tool = _UpdateTool();
    final runtime = AgentRuntime(
      modelClient: client,
      tools: AgentToolRegistry([tool]),
    );

    final events = await runtime
        .runTurn(threadId: 'thread', runId: 'run', input: '修改它')
        .toList();

    expect(events.whereType<AgentRuntimeConfirmation>(), hasLength(1));
    expect(tool.executions, 0);
    expect(client.requests, hasLength(1));
  });

  test('continues the model response after a confirmed update', () async {
    final client = _UpdateClient();
    final tool = _UpdateTool();
    final registry = AgentToolRegistry([tool]);
    final runtime = AgentRuntime(modelClient: client, tools: registry);
    final first = await runtime
        .runTurn(threadId: 'thread', runId: 'run', input: '修改它')
        .toList();
    final confirmation = first.whereType<AgentRuntimeConfirmation>().single;

    final resumed = await runtime
        .resumeConfirmation(
          threadId: 'thread',
          runId: 'run',
          pending: confirmation.confirmation,
          token: confirmation.confirmation.token,
          previousResponseId: confirmation.responseId,
        )
        .toList();

    expect(tool.executions, 1);
    expect(resumed.whereType<AgentRuntimeText>().single.text, '修改完成');
  });

  test('retries a tool-less write claim and only surfaces the final reply',
      () async {
    final client = _ToollessWriteThenToolClient();
    final tool = _CreateTool();
    final runtime = AgentRuntime(
      modelClient: client,
      tools: AgentToolRegistry([tool]),
    );

    final events = await runtime
        .runTurn(
          threadId: 'thread',
          runId: 'run',
          input: '今天中午吃午饭花了35',
        )
        .toList();

    expect(client.requests, hasLength(3));
    expect(tool.executions, 1);
    expect(
      events.whereType<AgentRuntimeText>().map((event) => event.text).join(),
      '已记账：午饭 -¥35.00',
    );
    expect(
      events.whereType<AgentRuntimeText>().map((event) => event.text).join(),
      isNot(contains('已为你记录一笔午饭支出：35元。')),
    );
  });

  test('never surfaces a write claim when the model refuses to call a tool',
      () async {
    final client = _AlwaysToollessWriteClient();
    final events = await AgentRuntime(
      modelClient: client,
      tools: AgentToolRegistry(const []),
    ).runTurn(threadId: 'thread', runId: 'run', input: '今天花了35元').toList();

    expect(client.requests, hasLength(2));
    expect(events.whereType<AgentRuntimeText>(), isEmpty);
    expect(
      events.whereType<AgentRuntimeFailure>().single.message,
      contains('未完成本地操作'),
    );
  });
}

class _TwoRoundClient implements AgentModelClient {
  final requests = <AgentRequest>[];

  @override
  Stream<AgentEvent> run(AgentRequest request) async* {
    requests.add(request);
    if (requests.length == 1) {
      yield const AgentToolCallRequested(AgentToolCall(
        callId: 'call-1',
        name: 'idea_search',
        arguments: {'keyword': '最近'},
      ));
      yield const AgentResponseCompleted(responseId: 'response-1');
    } else {
      yield const AgentTextDelta('最近有一条想法。');
      yield const AgentResponseCompleted(responseId: 'response-2');
    }
  }
}

class _UpdateClient implements AgentModelClient {
  final requests = <AgentRequest>[];

  @override
  Stream<AgentEvent> run(AgentRequest request) async* {
    requests.add(request);
    if (requests.length == 1) {
      yield const AgentToolCallRequested(AgentToolCall(
        callId: 'call-update',
        name: 'idea_update',
        arguments: {'id': 'idea-1', 'summary': 'new'},
      ));
      yield const AgentResponseCompleted(responseId: 'response-update');
    } else {
      yield const AgentTextDelta('修改完成');
      yield const AgentResponseCompleted(responseId: 'response-finished');
    }
  }
}

class _LookupTool extends AgentTool {
  int executions = 0;

  @override
  AgentToolDefinition get definition => const AgentToolDefinition(
        name: 'idea_search',
        description: 'search ideas',
        domain: 'idea',
        parameters: {
          'type': 'object',
          'properties': {
            'keyword': {'type': 'string'},
          },
          'required': [],
          'additionalProperties': false,
        },
      );

  @override
  ToolRiskLevel get riskLevel => ToolRiskLevel.read;

  @override
  Future<ToolResult> execute(
    Map<String, dynamic> arguments,
    ToolExecutionContext context,
  ) async {
    executions++;
    return ToolResult.success({
      'items': [
        {'id': 'idea-1', 'summary': 'agent idea'}
      ]
    });
  }
}

class _UpdateTool extends AgentTool {
  int executions = 0;

  @override
  AgentToolDefinition get definition => const AgentToolDefinition(
        name: 'idea_update',
        description: 'update idea',
        domain: 'idea',
        parameters: {
          'type': 'object',
          'properties': {
            'id': {'type': 'string'},
            'summary': {'type': 'string'},
            'expected_updated_at': {'type': 'string'},
          },
          'required': ['id', 'summary'],
          'additionalProperties': false,
        },
      );

  @override
  ToolRiskLevel get riskLevel => ToolRiskLevel.update;

  @override
  Future<ToolPreview?> preview(
    Map<String, dynamic> arguments,
    ToolExecutionContext context,
  ) async =>
      const ToolPreview(
        title: '修改想法',
        affectedCount: 1,
        recordVersion: 'version-1',
      );

  @override
  Future<ToolResult> execute(
    Map<String, dynamic> arguments,
    ToolExecutionContext context,
  ) async {
    executions++;
    return ToolResult.success(arguments);
  }
}

class _CreateTool extends AgentTool {
  int executions = 0;

  @override
  AgentToolDefinition get definition => const AgentToolDefinition(
        name: 'ledger_create',
        description: 'create ledger transaction',
        domain: 'ledger',
        parameters: {
          'type': 'object',
          'properties': {
            'amount_cents': {'type': 'integer'},
          },
          'required': ['amount_cents'],
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
    return ToolResult.success({'note': '午饭', 'amount_cents': 3500});
  }
}

class _ToollessWriteThenToolClient implements AgentModelClient {
  final requests = <AgentRequest>[];

  @override
  Stream<AgentEvent> run(AgentRequest request) async* {
    requests.add(request);
    if (requests.length == 1) {
      yield const AgentTextDelta('已为你记录一笔午饭支出：35元。');
      yield const AgentResponseCompleted(responseId: 'response-1');
    } else if (requests.length == 2) {
      yield const AgentToolCallRequested(AgentToolCall(
        callId: 'create-ledger',
        name: 'ledger_create',
        arguments: {'amount_cents': 3500},
      ));
      yield const AgentResponseCompleted(responseId: 'response-2');
    } else {
      yield const AgentTextDelta('已记账：午饭 -¥35.00');
      yield const AgentResponseCompleted(responseId: 'response-3');
    }
  }
}

class _AlwaysToollessWriteClient implements AgentModelClient {
  final requests = <AgentRequest>[];

  @override
  Stream<AgentEvent> run(AgentRequest request) async* {
    requests.add(request);
    yield const AgentTextDelta('已为你记账。');
    yield AgentResponseCompleted(responseId: 'response-${requests.length}');
  }
}
