import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_idea_capture/src/agent/agent_models.dart';
import 'package:local_idea_capture/src/agent/agent_runtime.dart';
import 'package:local_idea_capture/src/agent/agent_session_controller.dart';
import 'package:local_idea_capture/src/agent/agent_tool.dart';
import 'package:local_idea_capture/src/data/app_database.dart';

void main() {
  test('persists user and assistant messages across controller instances',
      () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final runtime = AgentRuntime(
      modelClient: _AnswerClient(),
      tools: AgentToolRegistry(const []),
    );
    final controller = AgentSessionController(
      database: database,
      runtime: runtime,
      threadId: 'thread',
    );
    await controller.initialize();

    await controller.send('你好').toList();

    final restored = AgentSessionController(
      database: database,
      runtime: runtime,
      threadId: 'thread',
    );
    await restored.initialize();
    expect(restored.messages.map((message) => message.content), ['你好', '收到']);
  });

  test('stores long-term memory only when the user explicitly asks to remember',
      () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final controller = AgentSessionController(
      database: database,
      runtime: AgentRuntime(
        modelClient: _AnswerClient(),
        tools: AgentToolRegistry(const []),
      ),
      threadId: 'memory-thread',
    );
    await controller.initialize();

    await controller.send('请记住我喜欢简洁回答').toList();
    final memories = await database.searchMemories(
      '简洁',
      now: DateTime.now(),
      limit: 5,
    );

    expect(memories.single.content, '我喜欢简洁回答');
    expect(memories.single.memoryType, 'explicit_preference');
  });
}

class _AnswerClient implements AgentModelClient {
  var count = 0;

  @override
  Stream<AgentEvent> run(AgentRequest request) async* {
    count++;
    yield const AgentTextDelta('收到');
    yield AgentResponseCompleted(responseId: 'response-$count');
  }
}
