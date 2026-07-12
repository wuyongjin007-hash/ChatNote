import 'agent_models.dart';
import 'agent_tool.dart';

abstract class AgentRuntimeEvent {
  const AgentRuntimeEvent();
}

class AgentRuntimeText extends AgentRuntimeEvent {
  const AgentRuntimeText(this.text);
  final String text;
}

class AgentRuntimeStatus extends AgentRuntimeEvent {
  const AgentRuntimeStatus(this.label);
  final String label;
}

class AgentRuntimeConfirmation extends AgentRuntimeEvent {
  const AgentRuntimeConfirmation(this.confirmation, {required this.responseId});
  final PendingToolConfirmation confirmation;
  final String responseId;
}

class AgentRuntimeToolActivity extends AgentRuntimeEvent {
  const AgentRuntimeToolActivity({
    required this.call,
    required this.riskLevel,
    required this.status,
    this.result,
  });

  final AgentToolCall call;
  final ToolRiskLevel riskLevel;
  final String status;
  final ToolResult? result;
}

class AgentRuntimeFailure extends AgentRuntimeEvent {
  const AgentRuntimeFailure(this.message);
  final String message;
}

class AgentRuntimeCompleted extends AgentRuntimeEvent {
  const AgentRuntimeCompleted({required this.responseId});
  final String responseId;
}

class AgentRuntime {
  AgentRuntime(
      {required AgentModelClient modelClient, required AgentToolRegistry tools})
      : _modelClient = modelClient,
        _tools = tools;

  final AgentModelClient _modelClient;
  final AgentToolRegistry _tools;

  Stream<AgentRuntimeEvent> runTurn({
    required String threadId,
    required String runId,
    required String input,
    List<AgentInputItem> history = const [],
    String? previousResponseId,
    AgentRunPolicy policy = const AgentRunPolicy(),
  }) =>
      _runFrom(
        threadId: threadId,
        runId: runId,
        nextInput: [...history, AgentInputItem.message('user', input)],
        previousResponseId: previousResponseId,
        policy: policy,
        requireToolEvidence: _requestNeedsToolEvidence(input),
      );

  Stream<AgentRuntimeEvent> resumeConfirmation({
    required String threadId,
    required String runId,
    required PendingToolConfirmation pending,
    required String token,
    required String previousResponseId,
    AgentRunPolicy policy = const AgentRunPolicy(),
  }) async* {
    final result = await _tools.confirm(
      pending,
      token,
      ToolExecutionContext(
        threadId: threadId,
        runId: runId,
        idempotencyKey: '${runId}_${pending.call.callId}',
      ),
    );
    if (!result.isSuccess) {
      yield AgentRuntimeToolActivity(
        call: pending.call,
        riskLevel: _tools.require(pending.call.name).riskLevel,
        status: 'failed',
        result: result,
      );
      yield AgentRuntimeFailure(result.message ?? '确认执行失败');
      return;
    }
    yield AgentRuntimeToolActivity(
      call: pending.call,
      riskLevel: _tools.require(pending.call.name).riskLevel,
      status: 'completed',
      result: result,
    );
    yield* _runFrom(
      threadId: threadId,
      runId: runId,
      nextInput: [
        AgentInputItem.toolOutput(pending.call.callId, result.toModelOutput())
      ],
      previousResponseId: previousResponseId,
      policy: policy,
      requireToolEvidence: false,
      initialSuccessfulTool: true,
    );
  }

  Stream<AgentRuntimeEvent> _runFrom({
    required String threadId,
    required String runId,
    required List<AgentInputItem> nextInput,
    required String? previousResponseId,
    required AgentRunPolicy policy,
    required bool requireToolEvidence,
    bool initialSuccessfulTool = false,
  }) async* {
    var responseId = previousResponseId;
    var toolCallCount = 0;
    var hasSuccessfulTool = initialSuccessfulTool;
    var requestedToolRetry = false;

    for (var round = 0; round < policy.maxModelRounds; round++) {
      final calls = <AgentToolCall>[];
      final text = StringBuffer();
      String? completedResponseId;
      try {
        final request = AgentRequest(
          input: nextInput,
          tools: _tools.definitions,
          previousResponseId: responseId,
          policy: policy,
        );
        await for (final event in _modelClient.run(request)) {
          if (event is AgentTextDelta) {
            text.write(event.text);
          } else if (event is AgentReasoningStatus) {
            yield AgentRuntimeStatus(event.label);
          } else if (event is AgentToolCallRequested) {
            calls.add(event.call);
            yield AgentRuntimeStatus('正在执行${event.call.name}');
          } else if (event is AgentResponseCompleted) {
            completedResponseId = event.responseId;
          } else if (event is AgentResponseFailed) {
            yield AgentRuntimeFailure(event.message);
            return;
          }
        }
      } catch (error) {
        yield AgentRuntimeFailure(error.toString());
        return;
      }

      if (completedResponseId == null) {
        yield const AgentRuntimeFailure('模型响应未正常完成');
        return;
      }
      responseId = completedResponseId;
      if (calls.isEmpty) {
        if (requireToolEvidence && !hasSuccessfulTool) {
          if (!requestedToolRetry) {
            requestedToolRetry = true;
            nextInput = [
              AgentInputItem.message(
                'developer',
                '上一轮没有调用本地工具。当前请求涉及本地记录，必须调用一个合适的已注册工具后才能回答。不要在工具返回成功结果前声称已经新增、修改、删除或查询到记录。',
              ),
            ];
            continue;
          }
          yield const AgentRuntimeFailure('未完成本地操作：模型没有调用所需工具，请重试。');
          return;
        }
        if (text.isNotEmpty) yield AgentRuntimeText(text.toString());
        yield AgentRuntimeCompleted(responseId: responseId);
        return;
      }
      toolCallCount += calls.length;
      if (toolCallCount > policy.maxToolCalls) {
        yield const AgentRuntimeFailure('本轮工具调用次数已达到安全上限');
        return;
      }

      final outputs = <AgentInputItem>[];
      for (final call in calls) {
        final context = ToolExecutionContext(
          threadId: threadId,
          runId: runId,
          idempotencyKey: '${runId}_${call.callId}',
        );
        final outcome = await _tools.dispatch(call, context);
        final confirmation = outcome.pendingConfirmation;
        if (confirmation != null) {
          yield AgentRuntimeToolActivity(
            call: call,
            riskLevel: _tools.require(call.name).riskLevel,
            status: 'awaiting_confirmation',
          );
          yield AgentRuntimeConfirmation(
            confirmation,
            responseId: responseId,
          );
          return;
        }
        yield AgentRuntimeToolActivity(
          call: call,
          riskLevel: _tools.require(call.name).riskLevel,
          status: outcome.result!.isSuccess ? 'completed' : 'failed',
          result: outcome.result,
        );
        hasSuccessfulTool = hasSuccessfulTool || outcome.result!.isSuccess;
        outputs.add(AgentInputItem.toolOutput(
          call.callId,
          outcome.result!.toModelOutput(),
        ));
      }
      nextInput = outputs;
    }
    yield const AgentRuntimeFailure('本轮模型推理次数已达到安全上限');
  }
}

bool _requestNeedsToolEvidence(String input) {
  const markers = [
    '记账',
    '花了',
    '支出',
    '收入',
    '添加',
    '新增',
    '创建',
    '新建',
    '待办',
    '提醒',
    '想法',
    '删除',
    '清空',
    '修改',
    '改成',
    '记录',
    '总结',
    '查询',
    '查找',
  ];
  return markers.any(input.contains);
}
