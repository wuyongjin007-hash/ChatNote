import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../domain/capture_models.dart';
import '../domain/conflict_detector.dart';
import 'entry_dao.dart';

export 'entry_dao.dart'
    show EntryListItem, IdeaPage, IdeaPageCursor, CaptureSessionRow;

part 'tables.dart';
part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    CaptureSessions,
    Entries,
    Todos,
    Ideas,
    Tags,
    EntryTags,
    LedgerTransactions,
    AgentThreads,
    AgentMessages,
    AgentRuns,
    AgentToolCalls,
    AgentConfirmations,
    MemoryItems,
  ],
  daos: [EntryDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
        onCreate: (m) async {
          await m.createAll();
          await _createEntryFtsTable();
          await _createMemoryFtsTable();
          await _createPagingIndexes();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await _createPagingIndexes();
          }
          if (from < 3) {
            await m.addColumn(
                captureSessions, captureSessions.conversationJson);
            await m.addColumn(captureSessions, captureSessions.activeDraftJson);
            await m.addColumn(
                captureSessions, captureSessions.recoverableDraftJson);
            await m.addColumn(captureSessions, captureSessions.expiresAt);
          }
          if (from < 4) {
            await m.createTable(ledgerTransactions);
            await m.createTable(agentThreads);
            await m.createTable(agentMessages);
            await m.createTable(agentRuns);
            await m.createTable(agentToolCalls);
            await m.createTable(agentConfirmations);
            await m.createTable(memoryItems);
            await _createMemoryFtsTable();
            await _createAgentIndexes();
          }
        },
      );

  Future<String> saveTodo({
    required CaptureResult capture,
    required String rawText,
  }) {
    return entryDao.saveTodo(capture: capture, rawText: rawText);
  }

  Future<List<String>> saveTodos({
    required CaptureResult capture,
    required String rawText,
  }) {
    return entryDao.saveTodos(capture: capture, rawText: rawText);
  }

  Future<String> saveIdea({
    required CaptureResult capture,
    required String rawText,
  }) {
    return entryDao.saveIdea(capture: capture, rawText: rawText);
  }

  Future<List<EntryListItem>> loadTodos(DateTime from, DateTime to) {
    return entryDao.loadTodos(from, to);
  }

  Future<List<EntryListItem>> loadUnscheduledTodos() {
    return entryDao.loadUnscheduledTodos();
  }

  Future<List<EntryListItem>> queryTodos(TodoQueryPayload payload) {
    return entryDao.queryTodos(payload);
  }

  Future<List<EntryListItem>> searchIdeas(String query) {
    return entryDao.searchIdeas(query);
  }

  Future<IdeaPage> loadIdeaPage({
    String query = '',
    IdeaPageCursor? after,
    int limit = 40,
  }) {
    return entryDao.loadIdeaPage(
      query: query,
      after: after,
      limit: limit,
    );
  }

  Future<List<TodoTimeBlock>> loadTodoBlocks() {
    return entryDao.loadTodoBlocks();
  }

  Future<List<EntryListItem>> findTodosForDeletion(TodoDeletePayload payload) {
    return entryDao.findTodosForDeletion(payload);
  }

  Future<List<EntryListItem>> loadTodosByIds(List<String> ids) {
    return entryDao.loadTodosByIds(ids);
  }

  Future<void> deleteTodos(List<String> ids) {
    return entryDao.deleteTodos(ids);
  }

  Future<void> updateTodoStatus(String id, String status) {
    return entryDao.updateTodoStatus(id, status);
  }

  Future<void> deleteEntry(String id) {
    return entryDao.deleteEntry(id);
  }

  Future<void> clearAll() async {
    await transaction(() async {
      await delete(agentConfirmations).go();
      await delete(agentToolCalls).go();
      await delete(agentRuns).go();
      await delete(agentMessages).go();
      await delete(agentThreads).go();
      await delete(memoryItems).go();
      await customStatement('DELETE FROM agent_memory_fts');
      await delete(ledgerTransactions).go();
      await entryDao.clearAll();
    });
  }

  Future<void> createLedgerTransaction({
    required String id,
    required String direction,
    required int amountCents,
    required String categoryCode,
    required String note,
    required DateTime occurredAt,
    required String source,
    required String rawText,
  }) async {
    if (amountCents <= 0) throw ArgumentError.value(amountCents, 'amountCents');
    final now = DateTime.now().toUtc().toIso8601String();
    await into(ledgerTransactions).insert(
      LedgerTransactionsCompanion.insert(
        id: id,
        direction: direction,
        amountCents: amountCents,
        categoryCode: categoryCode,
        note: Value(note),
        occurredAt: occurredAt.toUtc().toIso8601String(),
        source: source,
        rawText: rawText,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<List<LedgerTransaction>> listLedgerTransactions(
    DateTime from,
    DateTime to, {
    int limit = 100,
  }) {
    final safeLimit = limit.clamp(1, 100);
    return (select(ledgerTransactions)
          ..where((row) =>
              row.occurredAt
                  .isBiggerOrEqualValue(from.toUtc().toIso8601String()) &
              row.occurredAt.isSmallerThanValue(to.toUtc().toIso8601String()))
          ..orderBy([(row) => OrderingTerm.desc(row.occurredAt)])
          ..limit(safeLimit))
        .get();
  }

  Future<LedgerMonthlySummary> ledgerSummary(int year, int month) async {
    final from = DateTime(year, month);
    final to = DateTime(year, month + 1);
    final rows = await customSelect(
      '''
      SELECT
        COALESCE(SUM(CASE WHEN direction = 'income' THEN amount_cents ELSE 0 END), 0) AS income_cents,
        COALESCE(SUM(CASE WHEN direction = 'expense' THEN amount_cents ELSE 0 END), 0) AS expense_cents
      FROM ledger_transactions
      WHERE occurred_at >= ? AND occurred_at < ?
      ''',
      variables: [
        Variable.withString(from.toUtc().toIso8601String()),
        Variable.withString(to.toUtc().toIso8601String()),
      ],
      readsFrom: {ledgerTransactions},
    ).get();
    return LedgerMonthlySummary(
      incomeCents: rows.single.read<int>('income_cents'),
      expenseCents: rows.single.read<int>('expense_cents'),
    );
  }

  Future<LedgerTransaction?> getLedgerTransaction(String id) {
    return (select(ledgerTransactions)..where((row) => row.id.equals(id)))
        .getSingleOrNull();
  }

  Future<bool> updateLedgerTransaction(
    String id,
    Map<String, dynamic> changes, {
    String? expectedUpdatedAt,
  }) async {
    final current = await getLedgerTransaction(id);
    if (current == null) return false;
    if (expectedUpdatedAt != null && current.updatedAt != expectedUpdatedAt) {
      throw StateError('record_version_conflict');
    }
    final amount = changes['amount_cents'] as int? ?? current.amountCents;
    if (amount <= 0) throw ArgumentError.value(amount, 'amount_cents');
    await (update(ledgerTransactions)..where((row) => row.id.equals(id))).write(
      LedgerTransactionsCompanion(
        direction: Value(changes['direction'] as String? ?? current.direction),
        amountCents: Value(amount),
        categoryCode:
            Value(changes['category_code'] as String? ?? current.categoryCode),
        note: Value(changes['note'] as String? ?? current.note),
        occurredAt:
            Value(changes['occurred_at'] as String? ?? current.occurredAt),
        updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
      ),
    );
    return true;
  }

  Future<bool> deleteLedgerTransaction(String id,
      {String? expectedUpdatedAt}) async {
    final current = await getLedgerTransaction(id);
    if (current == null) return false;
    if (expectedUpdatedAt != null && current.updatedAt != expectedUpdatedAt) {
      throw StateError('record_version_conflict');
    }
    final count = await (delete(ledgerTransactions)
          ..where((row) => row.id.equals(id)))
        .go();
    return count > 0;
  }

  Future<AgentRecord?> getAgentRecord(String id) async {
    final rows = await customSelect(
      '''
      SELECT e.id, e.type, e.title, e.raw_text, e.created_at, e.updated_at,
             i.summary, t.start_at, t.end_at, t.location, t.topic, t.status
      FROM entries e
      LEFT JOIN ideas i ON i.entry_id = e.id
      LEFT JOIN todos t ON t.entry_id = e.id
      WHERE e.id = ?
      LIMIT 1
      ''',
      variables: [Variable.withString(id)],
      readsFrom: {entries, ideas, todos},
    ).get();
    if (rows.isEmpty) return null;
    final row = rows.single;
    return AgentRecord(
      id: row.read<String>('id'),
      type: row.read<String>('type'),
      title: row.read<String>('title'),
      rawText: row.read<String>('raw_text'),
      createdAt: row.read<String>('created_at'),
      updatedAt: row.read<String>('updated_at'),
      summary: row.readNullable<String>('summary'),
      startAt: row.readNullable<String>('start_at'),
      endAt: row.readNullable<String>('end_at'),
      location: row.readNullable<String>('location'),
      topic: row.readNullable<String>('topic'),
      status: row.readNullable<String>('status'),
    );
  }

  Future<bool> updateAgentRecord(
    String id,
    Map<String, dynamic> changes, {
    String? expectedUpdatedAt,
  }) async {
    final current = await getAgentRecord(id);
    if (current == null) return false;
    if (expectedUpdatedAt != null && current.updatedAt != expectedUpdatedAt) {
      throw StateError('record_version_conflict');
    }
    final title = changes['title'] as String? ?? current.title;
    final summary = changes['summary'] as String? ?? current.summary;
    final now = DateTime.now().toUtc().toIso8601String();
    await transaction(() async {
      await (update(entries)..where((row) => row.id.equals(id))).write(
        EntriesCompanion(title: Value(title), updatedAt: Value(now)),
      );
      if (current.type == 'idea' && summary != null) {
        await (update(ideas)..where((row) => row.entryId.equals(id)))
            .write(IdeasCompanion(summary: Value(summary)));
      }
      if (current.type == 'todo') {
        await (update(todos)..where((row) => row.entryId.equals(id))).write(
          TodosCompanion(
            startAt: changes.containsKey('start_at')
                ? Value(changes['start_at'] as String?)
                : const Value.absent(),
            endAt: changes.containsKey('end_at')
                ? Value(changes['end_at'] as String?)
                : const Value.absent(),
            location: changes.containsKey('location')
                ? Value(changes['location'] as String?)
                : const Value.absent(),
            topic: changes.containsKey('topic')
                ? Value(changes['topic'] as String?)
                : const Value.absent(),
            status: changes.containsKey('status')
                ? Value(changes['status'] as String)
                : const Value.absent(),
          ),
        );
      }
      await customStatement(
        'UPDATE entry_fts SET title = ?, normalized_text = ? WHERE entry_id = ?',
        [title, (summary ?? title).toLowerCase(), id],
      );
    });
    return true;
  }

  Future<void> upsertAgentThread({
    required String id,
    required String status,
    String? previousResponseId,
    String? rollingSummary,
  }) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final existing = await loadAgentThread(id);
    await into(agentThreads).insertOnConflictUpdate(
      AgentThreadsCompanion(
        id: Value(id),
        status: Value(status),
        previousResponseId:
            Value(previousResponseId ?? existing?.previousResponseId),
        rollingSummary: Value(rollingSummary ?? existing?.rollingSummary),
        entityRefsJson: Value(existing?.entityRefsJson),
        createdAt: Value(existing?.createdAt ?? now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<AgentThread?> loadAgentThread(String id) {
    return (select(agentThreads)..where((row) => row.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> updateAgentEntityRefs(
      String threadId, List<Map<String, dynamic>> refs) {
    return (update(agentThreads)..where((row) => row.id.equals(threadId)))
        .write(AgentThreadsCompanion(
      entityRefsJson: Value(jsonEncode(refs)),
      updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
    ));
  }

  Future<void> saveAgentConfirmation({
    required String token,
    required String callId,
    required String runId,
    required String toolName,
    required Map<String, dynamic> arguments,
    required Map<String, dynamic> preview,
    required String responseId,
    required DateTime expiresAt,
    String? recordVersion,
  }) {
    return into(agentConfirmations).insertOnConflictUpdate(
      AgentConfirmationsCompanion.insert(
        token: token,
        toolCallId: callId,
        runId: runId,
        toolName: toolName,
        argumentsJson: jsonEncode(arguments),
        previewJson: jsonEncode(preview),
        responseId: responseId,
        status: 'pending',
        recordVersion: Value(recordVersion),
        expiresAt: expiresAt.toUtc().toIso8601String(),
        createdAt: DateTime.now().toUtc().toIso8601String(),
      ),
    );
  }

  Future<AgentConfirmation?> loadPendingAgentConfirmation() {
    final now = DateTime.now().toUtc().toIso8601String();
    return (select(agentConfirmations)
          ..where((row) =>
              row.status.equals('pending') &
              row.expiresAt.isBiggerThanValue(now))
          ..orderBy([(row) => OrderingTerm.desc(row.createdAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> resolveAgentConfirmation(String token, String status) {
    return (update(agentConfirmations)..where((row) => row.token.equals(token)))
        .write(AgentConfirmationsCompanion(status: Value(status)));
  }

  Future<void> startAgentRun({required String id, required String threadId}) {
    final now = DateTime.now().toUtc().toIso8601String();
    return into(agentRuns).insertOnConflictUpdate(AgentRunsCompanion(
      id: Value(id),
      threadId: Value(threadId),
      status: const Value('running'),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));
  }

  Future<void> finishAgentRun(
    String id, {
    required String status,
    int? modelRounds,
    int? toolCalls,
    String? error,
  }) {
    return (update(agentRuns)..where((row) => row.id.equals(id))).write(
      AgentRunsCompanion(
        status: Value(status),
        modelRounds:
            modelRounds == null ? const Value.absent() : Value(modelRounds),
        toolCalls: toolCalls == null ? const Value.absent() : Value(toolCalls),
        error: Value(error),
        updatedAt: Value(DateTime.now().toUtc().toIso8601String()),
      ),
    );
  }

  Future<void> upsertToolAudit({
    required String id,
    required String runId,
    required String callId,
    required String toolName,
    required String argumentsJson,
    required String riskLevel,
    required String status,
    String? resultJson,
    String? idempotencyKey,
    String? error,
  }) {
    final now = DateTime.now().toUtc().toIso8601String();
    return into(agentToolCalls).insertOnConflictUpdate(AgentToolCallsCompanion(
      id: Value(id),
      runId: Value(runId),
      callId: Value(callId),
      toolName: Value(toolName),
      argumentsJson: Value(argumentsJson),
      riskLevel: Value(riskLevel),
      status: Value(status),
      resultJson: Value(resultJson),
      idempotencyKey: Value(idempotencyKey),
      error: Value(error),
      createdAt: Value(now),
      updatedAt: Value(now),
    ));
  }

  Future<AgentToolCallRow?> findToolAuditByIdempotencyKey(String key) {
    return (select(agentToolCalls)
          ..where((row) => row.idempotencyKey.equals(key)))
        .getSingleOrNull();
  }

  Future<void> appendAgentMessage({
    required String id,
    required String threadId,
    required String role,
    required String content,
    required DateTime createdAt,
  }) {
    return into(agentMessages).insert(AgentMessagesCompanion.insert(
      id: id,
      threadId: threadId,
      role: role,
      content: content,
      createdAt: createdAt.toUtc().toIso8601String(),
    ));
  }

  Future<List<AgentMessage>> loadRecentAgentMessages(
      String threadId, int limit) async {
    final rows = await (select(agentMessages)
          ..where((row) => row.threadId.equals(threadId))
          ..orderBy([(row) => OrderingTerm.desc(row.createdAt)])
          ..limit(limit.clamp(1, 100)))
        .get();
    return rows.reversed.toList(growable: false);
  }

  Future<void> saveMemoryItem({
    required String id,
    required String memoryType,
    required String content,
    required double confidence,
    required DateTime createdAt,
    String? sourceMessageId,
    DateTime? expiresAt,
  }) async {
    await transaction(() async {
      await into(memoryItems).insertOnConflictUpdate(MemoryItemsCompanion(
        id: Value(id),
        memoryType: Value(memoryType),
        content: Value(content),
        sourceMessageId: Value(sourceMessageId),
        confidence: Value(confidence),
        createdAt: Value(createdAt.toUtc().toIso8601String()),
        expiresAt: Value(expiresAt?.toUtc().toIso8601String()),
        status: const Value('active'),
      ));
      await customStatement(
          'DELETE FROM agent_memory_fts WHERE memory_id = ?', [id]);
      await customStatement(
          'INSERT INTO agent_memory_fts(memory_id, memory_text) VALUES (?, ?)',
          [id, content]);
    });
  }

  Future<List<MemoryItem>> searchMemories(
    String query, {
    required DateTime now,
    int limit = 5,
  }) {
    final pattern = '%${query.trim()}%';
    return (select(memoryItems)
          ..where((row) =>
              row.status.equals('active') &
              row.content.like(pattern) &
              (row.expiresAt.isNull() |
                  row.expiresAt
                      .isBiggerThanValue(now.toUtc().toIso8601String())))
          ..orderBy([
            (row) => OrderingTerm.desc(row.confidence),
            (row) => OrderingTerm.desc(row.createdAt),
          ])
          ..limit(limit.clamp(1, 5)))
        .get();
  }

  Future<void> upsertSession({
    required String id,
    required String rawText,
    required String status,
    required String createdAt,
    required String updatedAt,
    String? conversationJson,
    String? activeDraftJson,
    String? recoverableDraftJson,
    String? expiresAt,
  }) {
    return entryDao.upsertSession(
      id: id,
      rawText: rawText,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      conversationJson: conversationJson,
      activeDraftJson: activeDraftJson,
      recoverableDraftJson: recoverableDraftJson,
      expiresAt: expiresAt,
    );
  }

  Future<CaptureSessionRow?> loadSession(String id) {
    return entryDao.loadSession(id);
  }

  Future<CaptureSessionRow?> loadLatestRecoverableSession() {
    return entryDao.loadLatestRecoverableSession();
  }

  Future<void> deleteSession(String id) {
    return entryDao.deleteSession(id);
  }

  Future<bool> entryFtsUsesFts5() async {
    final rows = await customSelect(
      "SELECT sql FROM sqlite_master WHERE type = 'table' AND name = 'entry_fts'",
    ).get();
    final statement =
        rows.isEmpty ? '' : rows.single.readNullable<String>('sql') ?? '';
    return statement.toUpperCase().contains('VIRTUAL TABLE');
  }

  Future<bool> memoryFtsUsesFts5() async {
    final rows = await customSelect(
      "SELECT sql FROM sqlite_master WHERE type = 'table' AND name = 'agent_memory_fts'",
    ).get();
    final statement =
        rows.isEmpty ? '' : rows.single.readNullable<String>('sql') ?? '';
    return statement.toUpperCase().contains('VIRTUAL TABLE');
  }

  Future<bool> memorySearchIndexExists() async {
    final rows = await customSelect(
      "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'agent_memory_fts'",
    ).get();
    return rows.isNotEmpty;
  }

  Future<void> _createEntryFtsTable() async {
    try {
      await customStatement('''
        CREATE VIRTUAL TABLE entry_fts USING fts5(
          entry_id UNINDEXED,
          title,
          normalized_text,
          raw_text
        );
      ''');
    } on Object {
      await customStatement('''
        CREATE TABLE entry_fts (
          entry_id TEXT NOT NULL,
          title TEXT NOT NULL,
          normalized_text TEXT NOT NULL,
          raw_text TEXT NOT NULL
        );
      ''');
    }
  }

  Future<void> _createMemoryFtsTable() async {
    try {
      await customStatement('''
        CREATE VIRTUAL TABLE agent_memory_fts USING fts5(
          memory_id UNINDEXED,
          memory_text
        );
      ''');
    } on Object {
      // Keep a plain-table fallback for Android builds without FTS5.
      await customStatement('''
        CREATE TABLE agent_memory_fts (
          memory_id TEXT NOT NULL,
          memory_text TEXT NOT NULL
        );
      ''');
    }
  }

  Future<void> _createPagingIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_todos_start_at ON todos(start_at)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_entries_type_updated_id ON entries(type, updated_at DESC, id DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_entry_tags_entry_id ON entry_tags(entry_id)',
    );
    await _createAgentIndexes();
  }

  Future<void> _createAgentIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_ledger_occurred_at ON ledger_transactions(occurred_at DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_agent_messages_thread_time ON agent_messages(thread_id, created_at DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_memory_status_time ON memory_items(status, created_at DESC)',
    );
  }
}

class LedgerMonthlySummary {
  const LedgerMonthlySummary({
    required this.incomeCents,
    required this.expenseCents,
  });

  final int incomeCents;
  final int expenseCents;
  int get balanceCents => incomeCents - expenseCents;
}

class AgentRecord {
  const AgentRecord({
    required this.id,
    required this.type,
    required this.title,
    required this.rawText,
    required this.createdAt,
    required this.updatedAt,
    this.summary,
    this.startAt,
    this.endAt,
    this.location,
    this.topic,
    this.status,
  });

  final String id;
  final String type;
  final String title;
  final String rawText;
  final String createdAt;
  final String updatedAt;
  final String? summary;
  final String? startAt;
  final String? endAt;
  final String? location;
  final String? topic;
  final String? status;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'raw_text': rawText,
        'created_at': createdAt,
        'updated_at': updatedAt,
        if (summary != null) 'summary': summary,
        if (startAt != null) 'start_at': startAt,
        if (endAt != null) 'end_at': endAt,
        if (location != null) 'location': location,
        if (topic != null) 'topic': topic,
        if (status != null) 'status': status,
      };
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'local_idea_capture');
}
