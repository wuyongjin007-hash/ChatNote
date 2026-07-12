import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_idea_capture/src/data/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = AppDatabase(NativeDatabase.memory()));
  tearDown(() => database.close());

  test('stores ledger amounts in cents and calculates a monthly summary',
      () async {
    await database.createLedgerTransaction(
      id: 'expense',
      direction: 'expense',
      amountCents: 2501,
      categoryCode: 'food',
      note: '午饭',
      occurredAt: DateTime(2026, 7, 12, 12),
      source: 'typedText',
      rawText: '午饭花了25.01',
    );
    await database.createLedgerTransaction(
      id: 'income',
      direction: 'income',
      amountCents: 800000,
      categoryCode: 'salary',
      note: '工资',
      occurredAt: DateTime(2026, 7, 10),
      source: 'voiceTranscript',
      rawText: '工资到账8000',
    );

    final summary = await database.ledgerSummary(2026, 7);
    final rows = await database.listLedgerTransactions(
      DateTime(2026, 7),
      DateTime(2026, 8),
    );

    expect(summary.expenseCents, 2501);
    expect(summary.incomeCents, 800000);
    expect(summary.balanceCents, 797499);
    expect(rows.map((row) => row.id), ['expense', 'income']);
  });

  test('monthly ledger summary is not truncated by list pagination', () async {
    for (var index = 0; index < 101; index++) {
      await database.createLedgerTransaction(
        id: 'expense-$index',
        direction: 'expense',
        amountCents: 100,
        categoryCode: 'food',
        note: 'item',
        occurredAt: DateTime(2026, 7, 12, 12, index % 60),
        source: 'typedText',
        rawText: 'item',
      );
    }

    final summary = await database.ledgerSummary(2026, 7);

    expect(summary.expenseCents, 10100);
  });

  test('loads only the latest twelve working-memory messages', () async {
    await database.upsertAgentThread(id: 'thread', status: 'idle');
    for (var index = 0; index < 15; index++) {
      await database.appendAgentMessage(
        id: 'message-$index',
        threadId: 'thread',
        role: index.isEven ? 'user' : 'assistant',
        content: 'content-$index',
        createdAt: DateTime(2026, 7, 12, 10, index),
      );
    }

    final messages = await database.loadRecentAgentMessages('thread', 12);

    expect(messages.length, 12);
    expect(messages.first.content, 'content-3');
    expect(messages.last.content, 'content-14');
  });

  test('searches active long-term memories without returning expired ones',
      () async {
    await database.saveMemoryItem(
      id: 'active',
      memoryType: 'preference',
      content: '用户喜欢简洁的记账摘要',
      confidence: 1,
      createdAt: DateTime(2026, 7, 1),
    );
    await database.saveMemoryItem(
      id: 'expired',
      memoryType: 'preference',
      content: '用户喜欢复杂的记账摘要',
      confidence: 1,
      createdAt: DateTime(2026, 6, 1),
      expiresAt: DateTime(2026, 7, 2),
    );

    final memories = await database.searchMemories(
      '记账',
      now: DateTime(2026, 7, 12),
      limit: 5,
    );

    expect(memories.map((memory) => memory.id), ['active']);
  });

  test('audits tool calls and resolves idempotency keys', () async {
    await database.upsertAgentThread(id: 'thread', status: 'idle');
    await database.startAgentRun(id: 'run', threadId: 'thread');
    await database.upsertToolAudit(
      id: 'audit',
      runId: 'run',
      callId: 'call',
      toolName: 'idea_create',
      argumentsJson: '{"summary":"one"}',
      riskLevel: 'create',
      status: 'completed',
      idempotencyKey: 'idem',
      resultJson: '{"ok":true}',
    );

    final audit = await database.findToolAuditByIdempotencyKey('idem');

    expect(audit?.toolName, 'idea_create');
    expect(audit?.status, 'completed');
  });

  test('creates a searchable index for long-term memories', () async {
    expect(await database.memorySearchIndexExists(), isTrue);
  });
}
