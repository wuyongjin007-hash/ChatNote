import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_idea_capture/src/agent/agent_models.dart';
import 'package:local_idea_capture/src/agent/agent_tool.dart';
import 'package:local_idea_capture/src/agent/local_agent_tools.dart';
import 'package:local_idea_capture/src/data/app_database.dart';

void main() {
  late AppDatabase database;
  late AgentToolRegistry registry;
  const context = ToolExecutionContext(threadId: 'thread', runId: 'run');

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    registry = AgentToolRegistry(buildLocalAgentTools(database));
  });
  tearDown(() => database.close());

  test('publishes CRUD tools for todos ideas and ledger', () {
    expect(
      registry.definitions.map((definition) => definition.name),
      containsAll([
        'todo_list',
        'todo_get',
        'todo_create',
        'todo_update',
        'todo_delete',
        'idea_search',
        'idea_get',
        'idea_create',
        'idea_update',
        'idea_delete',
        'ledger_list',
        'ledger_get',
        'ledger_create',
        'ledger_update',
        'ledger_delete',
        'ledger_summary',
      ]),
    );
  });

  test('creates and summarizes ledger transactions through tools', () async {
    final create = await registry.execute(
      const AgentToolCall(
        callId: 'create',
        name: 'ledger_create',
        arguments: {
          'direction': 'expense',
          'amount_cents': 2500,
          'category_code': 'food',
          'note': '午饭',
          'occurred_at': '2026-07-12T12:00:00+08:00',
        },
      ),
      context,
    );
    final summary = await registry.execute(
      const AgentToolCall(
        callId: 'summary',
        name: 'ledger_summary',
        arguments: {'year': 2026, 'month': 7},
      ),
      context,
    );

    expect(create.isSuccess, isTrue);
    expect(summary.data['expense_cents'], 2500);
    expect(summary.data['balance_cents'], -2500);
  });

  test('creates and searches ideas through tools', () async {
    await registry.execute(
      const AgentToolCall(
        callId: 'create-idea',
        name: 'idea_create',
        arguments: {'summary': '做一个可扩展的智能体'},
      ),
      context,
    );

    final result = await registry.execute(
      const AgentToolCall(
        callId: 'search-idea',
        name: 'idea_search',
        arguments: {'keyword': '智能体', 'limit': 50},
      ),
      context,
    );

    expect(result.isSuccess, isTrue);
    expect(result.data['items'], hasLength(1));
  });
}
