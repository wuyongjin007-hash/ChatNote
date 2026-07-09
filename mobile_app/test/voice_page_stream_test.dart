import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_idea_capture/src/data/app_database.dart';
import 'package:local_idea_capture/src/domain/capture_conversation_agent.dart';
import 'package:local_idea_capture/src/domain/capture_models.dart';
import 'package:local_idea_capture/src/features/voice/voice_page.dart';
import 'package:local_idea_capture/src/providers.dart';

void main() {
  testWidgets('streams assistant text and shows a draft card after completion', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          captureConversationAgentProvider.overrideWithValue(_FakeCaptureConversationAgent()),
        ],
        child: const MaterialApp(home: Scaffold(body: VoicePage())),
      ),
    );

    await tester.enterText(find.byType(TextField), '明天上午九点开会');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('我理解这是一个待办'), findsOneWidget);

    await tester.pump();

    expect(find.text('预算会议'), findsOneWidget);
    expect(find.text('缺少信息：location'), findsOneWidget);
  });
}

class _FakeCaptureConversationAgent implements CaptureConversationAgent {
  @override
  Stream<CaptureAgentStreamEvent> submitTextStream(String text) async* {
    yield const CaptureAgentAssistantDelta('我理解这是一个待办，');
    yield const CaptureAgentAssistantDelta('还需要地点。');
    yield CaptureAgentTurnDone(
      CaptureTurn(
        capture: _todoDraft(),
        rawTranscript: text,
        isFollowUp: false,
        usedFallback: false,
      ),
    );
  }

  @override
  Future<CaptureTurn> submitText(String text) {
    throw UnimplementedError();
  }

  @override
  void reset() {}
}

CaptureResult _todoDraft() {
  return CaptureResult(
    intentType: CaptureIntentType.todo,
    confidence: 0.92,
    title: '预算会议',
    summary: '明天上午九点开预算会议',
    missingFields: const ['location'],
    followUpQuestion: '会议在哪里开？',
    shouldSave: false,
    todoPayload: TodoPayload(
      startAt: DateTime(2026, 7, 10, 9),
      endAt: DateTime(2026, 7, 10, 10),
      location: null,
      topic: '预算',
      reminderAt: null,
      status: 'pending',
    ),
    ideaPayload: null,
  );
}
