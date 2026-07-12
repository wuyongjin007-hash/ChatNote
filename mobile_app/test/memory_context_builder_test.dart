import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_idea_capture/src/agent/memory_context_builder.dart';
import 'package:local_idea_capture/src/data/app_database.dart';

void main() {
  test('builds bounded context from summary recent messages and memories',
      () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await database.upsertAgentThread(
      id: 'thread',
      status: 'idle',
      rollingSummary: '用户正在规划智能体功能',
    );
    for (var index = 0; index < 14; index++) {
      await database.appendAgentMessage(
        id: 'm-$index',
        threadId: 'thread',
        role: index.isEven ? 'user' : 'assistant',
        content: 'message-$index',
        createdAt: DateTime(2026, 7, 12, 10, index),
      );
    }
    await database.saveMemoryItem(
      id: 'memory',
      memoryType: 'preference',
      content: '用户希望记账回答保持简洁',
      confidence: 1,
      createdAt: DateTime(2026, 7, 1),
    );

    final context = await MemoryContextBuilder(database).build(
      threadId: 'thread',
      memoryKeyword: '记账',
      now: DateTime(2026, 7, 12),
    );

    expect(context.recentMessages, hasLength(12));
    expect(context.recentMessages.first.json['content'], 'message-2');
    expect(context.contextNote, contains('用户正在规划智能体功能'));
    expect(context.contextNote, contains('历史记忆'));
    expect(context.contextNote, contains('用户希望记账回答保持简洁'));
  });
}
