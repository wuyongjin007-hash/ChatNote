part of 'app_database.dart';

class CaptureSessions extends Table {
  late final TextColumn id = text()();
  late final TextColumn rawText = text()();
  late final TextColumn status = text()();
  late final TextColumn createdAt = text()();
  late final TextColumn updatedAt = text()();
  late final TextColumn conversationJson = text().nullable()();
  late final TextColumn activeDraftJson = text().nullable()();
  late final TextColumn recoverableDraftJson = text().nullable()();
  late final TextColumn expiresAt = text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Entries extends Table {
  late final TextColumn id = text()();
  late final TextColumn entryType = text()
      .named('type')
      .customConstraint("NOT NULL CHECK (type IN ('todo', 'idea'))")();
  late final TextColumn title = text()();
  late final TextColumn rawText = text()();
  late final TextColumn normalizedText = text()();
  late final TextColumn createdAt = text()();
  late final TextColumn updatedAt = text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Todos extends Table {
  late final TextColumn entryId =
      text().references(Entries, #id, onDelete: KeyAction.cascade)();
  late final TextColumn startAt = text().nullable()();
  late final TextColumn endAt = text().nullable()();
  late final TextColumn location = text().nullable()();
  late final TextColumn topic = text().nullable()();
  late final TextColumn reminderAt = text().nullable()();
  late final TextColumn status = text().withDefault(const Constant('draft'))();

  @override
  Set<Column<Object>> get primaryKey => {entryId};
}

class Ideas extends Table {
  late final TextColumn entryId =
      text().references(Entries, #id, onDelete: KeyAction.cascade)();
  late final TextColumn summary = text()();
  late final TextColumn sourceHint = text().nullable()();
  late final BoolColumn favorite =
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {entryId};
}

class Tags extends Table {
  late final TextColumn id = text()();
  late final TextColumn name = text().unique()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class EntryTags extends Table {
  late final TextColumn entryId =
      text().references(Entries, #id, onDelete: KeyAction.cascade)();
  late final TextColumn tagId =
      text().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {entryId, tagId};
}

class LedgerTransactions extends Table {
  late final TextColumn id = text()();
  late final TextColumn direction = text().customConstraint(
      "NOT NULL CHECK (direction IN ('expense', 'income'))")();
  late final IntColumn amountCents = integer()
      .named('amount_cents')
      .customConstraint('NOT NULL CHECK (amount_cents > 0)')();
  late final TextColumn categoryCode = text().named('category_code')();
  late final TextColumn note = text().withDefault(const Constant(''))();
  late final TextColumn occurredAt = text().named('occurred_at')();
  late final TextColumn source = text()();
  late final TextColumn rawText = text().named('raw_text')();
  late final TextColumn createdAt = text().named('created_at')();
  late final TextColumn updatedAt = text().named('updated_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AgentThreads extends Table {
  late final TextColumn id = text()();
  late final TextColumn status = text()();
  late final TextColumn previousResponseId =
      text().named('previous_response_id').nullable()();
  late final TextColumn rollingSummary =
      text().named('rolling_summary').nullable()();
  late final TextColumn entityRefsJson =
      text().named('entity_refs_json').nullable()();
  late final TextColumn createdAt = text().named('created_at')();
  late final TextColumn updatedAt = text().named('updated_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AgentMessages extends Table {
  late final TextColumn id = text()();
  late final TextColumn threadId = text()
      .named('thread_id')
      .references(AgentThreads, #id, onDelete: KeyAction.cascade)();
  late final TextColumn role = text()();
  late final TextColumn content = text()();
  late final TextColumn createdAt = text().named('created_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AgentRuns extends Table {
  late final TextColumn id = text()();
  late final TextColumn threadId = text()
      .named('thread_id')
      .references(AgentThreads, #id, onDelete: KeyAction.cascade)();
  late final TextColumn status = text()();
  late final IntColumn modelRounds =
      integer().named('model_rounds').withDefault(const Constant(0))();
  late final IntColumn toolCalls =
      integer().named('tool_calls').withDefault(const Constant(0))();
  late final TextColumn error = text().nullable()();
  late final TextColumn createdAt = text().named('created_at')();
  late final TextColumn updatedAt = text().named('updated_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('AgentToolCallRow')
class AgentToolCalls extends Table {
  late final TextColumn id = text()();
  late final TextColumn runId = text()
      .named('run_id')
      .references(AgentRuns, #id, onDelete: KeyAction.cascade)();
  late final TextColumn callId = text().named('call_id').unique()();
  late final TextColumn toolName = text().named('tool_name')();
  late final TextColumn argumentsJson = text().named('arguments_json')();
  late final TextColumn riskLevel = text().named('risk_level')();
  late final TextColumn status = text()();
  late final TextColumn resultJson = text().named('result_json').nullable()();
  late final TextColumn idempotencyKey =
      text().named('idempotency_key').nullable().unique()();
  late final TextColumn error = text().nullable()();
  late final TextColumn createdAt = text().named('created_at')();
  late final TextColumn updatedAt = text().named('updated_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AgentConfirmations extends Table {
  late final TextColumn token = text()();
  late final TextColumn toolCallId = text().named('tool_call_id')();
  late final TextColumn runId = text().named('run_id')();
  late final TextColumn toolName = text().named('tool_name')();
  late final TextColumn argumentsJson = text().named('arguments_json')();
  late final TextColumn previewJson = text().named('preview_json')();
  late final TextColumn responseId = text().named('response_id')();
  late final TextColumn status = text()();
  late final TextColumn recordVersion =
      text().named('record_version').nullable()();
  late final TextColumn expiresAt = text().named('expires_at')();
  late final TextColumn createdAt = text().named('created_at')();

  @override
  Set<Column<Object>> get primaryKey => {token};
}

class MemoryItems extends Table {
  late final TextColumn id = text()();
  late final TextColumn memoryType = text().named('memory_type')();
  late final TextColumn content = text()();
  late final TextColumn sourceMessageId =
      text().named('source_message_id').nullable()();
  late final RealColumn confidence = real()();
  late final TextColumn createdAt = text().named('created_at')();
  late final TextColumn lastUsedAt = text().named('last_used_at').nullable()();
  late final TextColumn expiresAt = text().named('expires_at').nullable()();
  late final TextColumn status = text().withDefault(const Constant('active'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
