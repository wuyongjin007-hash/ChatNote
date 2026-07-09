import 'package:flutter_test/flutter_test.dart';
import 'package:local_idea_capture/src/domain/capture_conversation_agent.dart';
import 'package:local_idea_capture/src/domain/capture_models.dart';
import 'package:local_idea_capture/src/domain/local_capture_heuristics.dart';

void main() {
  test('uses the previous incomplete draft as short-term memory for follow-up answers', () async {
    final requests = <CaptureAgentRequest>[];
    final agent = CaptureConversationAgent(
      heuristics: LocalCaptureHeuristics(),
      capture: (request) async {
        requests.add(request);
        if (requests.length == 1) {
          return _todoDraft(
            title: '补充会议安排',
            missingFields: const ['start_at', 'location', 'topic'],
            shouldSave: false,
          );
        }
        return _todoDraft(
          title: '预算会议',
          missingFields: const [],
          shouldSave: true,
          startAt: DateTime(2026, 7, 10, 9),
          endAt: DateTime(2026, 7, 10, 10),
          location: '公司',
          topic: '预算',
        );
      },
    );

    final firstTurn = await agent.submitText('明天早晨要开会');
    final secondTurn = await agent.submitText('上午九点，在公司，讨论预算');

    expect(firstTurn.isFollowUp, isFalse);
    expect(secondTurn.isFollowUp, isTrue);
    expect(secondTurn.rawTranscript, '明天早晨要开会\n上午九点，在公司，讨论预算');
    expect(secondTurn.capture.shouldSave, isTrue);
    expect(requests[1].isFollowUp, isTrue);
    expect(requests[1].missingFields, ['start_at', 'location', 'topic']);
    expect(requests[1].pendingDraft?['title'], '补充会议安排');
    expect(requests[1].conversation.map((message) => message['role']), containsAllInOrder(['user', 'assistant']));
  });

  test('reset clears short-term memory before the next capture', () async {
    final requests = <CaptureAgentRequest>[];
    final agent = CaptureConversationAgent(
      heuristics: LocalCaptureHeuristics(),
      capture: (request) async {
        requests.add(request);
        return _todoDraft(
          title: '补充会议安排',
          missingFields: const ['start_at'],
          shouldSave: false,
        );
      },
    );

    await agent.submitText('明天开会');
    agent.reset();
    await agent.submitText('记录一个新想法');

    expect(requests.last.isFollowUp, isFalse);
    expect(requests.last.pendingDraft, isNull);
    expect(requests.last.conversation, isEmpty);
  });
}

CaptureResult _todoDraft({
  required String title,
  required List<String> missingFields,
  required bool shouldSave,
  DateTime? startAt,
  DateTime? endAt,
  String? location,
  String? topic,
}) {
  return CaptureResult(
    intentType: CaptureIntentType.todo,
    confidence: 0.9,
    title: title,
    summary: title,
    missingFields: missingFields,
    followUpQuestion: missingFields.isEmpty ? null : '请补充会议信息',
    shouldSave: shouldSave,
    todoPayload: TodoPayload(
      startAt: startAt,
      endAt: endAt,
      location: location,
      topic: topic,
      reminderAt: null,
      status: shouldSave ? 'draft' : 'pending',
    ),
    ideaPayload: null,
  );
}
