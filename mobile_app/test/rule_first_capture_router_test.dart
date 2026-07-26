import 'package:flutter_test/flutter_test.dart';
import 'package:local_idea_capture/src/domain/capture_conversation_agent.dart';
import 'package:local_idea_capture/src/domain/capture_models.dart';

void main() {
  const request = CaptureAgentRequest(
    text: '今天中午吃午饭花了35元',
    conversation: [],
    pendingDraft: null,
    missingFields: [],
    isFollowUp: false,
  );

  test('sends an explicit ledger to Ark instead of handling it locally',
      () async {
    var cloudCalls = 0;
    final router = CloudCaptureRouter(
      cloudCapture: (_) async {
        cloudCalls++;
        return _idea('unused');
      },
      cloudCaptureStream: (_) async* {
        cloudCalls++;
        yield const CaptureAgentAssistantDelta('正在云端整理。');
        yield CaptureAgentDone(_idea('午饭支出 35 元'));
      },
    );

    final events = await router.captureStream(request).toList();

    expect(cloudCalls, 1);
    expect(events.whereType<CaptureAgentRoutingStatus>().single.message,
        '正在云端整理…');
    final done = events.whereType<CaptureAgentDone>().single;
    expect(done.capture.summary, '午饭支出 35 元');
  });

  test('streams one Ark request for any text', () async {
    var cloudCalls = 0;
    final router = CloudCaptureRouter(
      cloudCapture: (_) async => _idea('unused'),
      cloudCaptureStream: (_) async* {
        cloudCalls++;
        yield const CaptureAgentAssistantDelta('我来补充整理。');
        yield CaptureAgentDone(_idea('整理一个新的长期学习计划'));
      },
    );

    final events = await router
        .captureStream(const CaptureAgentRequest(
          text: '把刚刚说的事情重新排一下优先级',
          conversation: [],
          pendingDraft: null,
          missingFields: [],
          isFollowUp: false,
        ))
        .toList();

    expect(cloudCalls, 1);
    expect(
        events.whereType<CaptureAgentAssistantDelta>().single.text, '我来补充整理。');
    expect(events.whereType<CaptureAgentDone>().single.capture.summary,
        '整理一个新的长期学习计划');
  });

  test('does not produce a draft when cloud capture fails', () async {
    final router = CloudCaptureRouter(
      cloudCapture: (_) async => throw StateError('offline'),
      cloudCaptureStream: (_) async* {
        throw StateError('offline');
      },
    );
    final agent = CaptureConversationAgent(
      capture: router.capture,
      captureStream: router.captureStream,
    );

    final events = await agent.submitTextStream('把刚刚说的事情重新排一下优先级').toList();

    expect(events.whereType<CaptureAgentFailure>().single.message,
        contains('云端整理失败'));
    expect(events.whereType<CaptureAgentTurnDone>(), isEmpty);
  });
}

CaptureResult _idea(String summary) => CaptureResult(
      intentType: CaptureIntentType.idea,
      confidence: 0.9,
      title: summary,
      summary: summary,
      missingFields: const [],
      followUpQuestion: null,
      shouldSave: true,
      todoPayload: null,
      ideaPayload: IdeaPayload(
        summary: summary,
        sourceHint: 'Ark',
        tags: const [],
      ),
    );
