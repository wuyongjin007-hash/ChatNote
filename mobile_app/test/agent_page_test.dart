import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_idea_capture/src/agent/agent_models.dart';
import 'package:local_idea_capture/src/agent/agent_runtime.dart';
import 'package:local_idea_capture/src/agent/agent_session_controller.dart';
import 'package:local_idea_capture/src/agent/agent_tool.dart';
import 'package:local_idea_capture/src/data/app_database.dart';
import 'package:local_idea_capture/src/features/agent/agent_page.dart';
import 'package:local_idea_capture/src/providers.dart';

void main() {
  testWidgets('sends text through the tool agent and renders its answer',
      (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final controller = AgentSessionController(
      database: database,
      runtime: AgentRuntime(
        modelClient: _AnswerClient(),
        tools: AgentToolRegistry(const []),
      ),
      threadId: 'page-thread',
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        agentSessionControllerProvider.overrideWithValue(controller),
      ],
      child: const MaterialApp(home: Scaffold(body: AgentPage())),
    ));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('voice-input-strip')), findsOneWidget);
    expect(find.byKey(const Key('voice-press-button')), findsOneWidget);
    expect(find.byKey(const Key('agent-send-button')), findsNothing);
    await tester.tap(find.byKey(const Key('voice-mode-toggle-button')));
    await tester.pump();
    await tester.enterText(find.byKey(const Key('merged-text-input')), 'hello');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    expect(find.text('hello'), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
  });
}

class _AnswerClient implements AgentModelClient {
  @override
  Stream<AgentEvent> run(AgentRequest request) async* {
    yield const AgentTextDelta('Hello');
    yield const AgentResponseCompleted(responseId: 'response');
  }
}
