import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../domain/capture_models.dart';
import '../domain/conflict_detector.dart';
import 'app_database.dart';

part 'entry_dao.g.dart';

class EntryListItem {
  const EntryListItem({
    required this.id,
    required this.type,
    required this.title,
    required this.rawText,
    required this.normalizedText,
    required this.createdAt,
    required this.updatedAt,
    this.startAt,
    this.endAt,
    this.location,
    this.topic,
    this.summary,
    this.tags = const [],
    this.status = 'pending',
    this.reminderAt,
  });

  final String id;
  final CaptureIntentType type;
  final String title;
  final String rawText;
  final String normalizedText;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? startAt;
  final DateTime? endAt;
  final String? location;
  final String? topic;
  final String? summary;
  final List<String> tags;
  final String status;
  final DateTime? reminderAt;
}

class IdeaPageCursor {
  const IdeaPageCursor({required this.updatedAt, required this.id});

  final String updatedAt;
  final String id;
}

class IdeaPage {
  const IdeaPage({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });

  final List<EntryListItem> items;
  final IdeaPageCursor? nextCursor;
  final bool hasMore;
}

class CaptureSessionRow {
  const CaptureSessionRow({
    required this.id,
    required this.rawText,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.conversationJson,
    this.activeDraftJson,
    this.recoverableDraftJson,
    this.expiresAt,
  });

  final String id;
  final String rawText;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String? conversationJson;
  final String? activeDraftJson;
  final String? recoverableDraftJson;
  final String? expiresAt;

  List<Map<String, String>> parseConversation() {
    if (conversationJson == null || conversationJson!.isEmpty) {
      return [];
    }
    try {
      final decoded = jsonDecode(conversationJson!);
      return (decoded as List<dynamic>)
          .map((item) => Map<String, String>.from(item as Map))
          .toList();
    } catch (_) {
      return [];
    }
  }

  CaptureResult? parseActiveDraft() {
    if (activeDraftJson == null || activeDraftJson!.isEmpty) {
      return null;
    }
    try {
      return CaptureResult.fromJson(
          jsonDecode(activeDraftJson!) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  CaptureResult? parseRecoverableDraft() {
    if (recoverableDraftJson == null || recoverableDraftJson!.isEmpty) {
      return null;
    }
    try {
      return CaptureResult.fromJson(
          jsonDecode(recoverableDraftJson!) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  bool get isRecoverable {
    if (expiresAt == null) {
      return false;
    }
    final expiry = DateTime.tryParse(expiresAt!);
    return expiry != null && expiry.isAfter(DateTime.now());
  }
}

@DriftAccessor(tables: [Entries, Todos, Ideas, Tags, EntryTags])
class EntryDao extends DatabaseAccessor<AppDatabase> with _$EntryDaoMixin {
  EntryDao(super.db);

  final _uuid = const Uuid();

  Future<String> saveTodo({
    required CaptureResult capture,
    required String rawText,
  }) async {
    final ids = await saveTodos(capture: capture, rawText: rawText);
    return ids.first;
  }

  Future<List<String>> saveTodos({
    required CaptureResult capture,
    required String rawText,
  }) async {
    final todos = capture.effectiveTodoPayloads;
    if (todos.isEmpty) {
      throw ArgumentError('todo_payload is required for todo entries');
    }
    final entryIds = <String>[];
    final now = DateTime.now().toIso8601String();

    await transaction(() async {
      for (final todo in todos) {
        final entryId = _uuid.v4();
        entryIds.add(entryId);
        await _insertTodoEntry(
          entryId: entryId,
          capture: capture,
          todo: todo,
          rawText: rawText,
          now: now,
        );
      }
    });

    return entryIds;
  }

  Future<void> _insertTodoEntry({
    required String entryId,
    required CaptureResult capture,
    required TodoPayload todo,
    required String rawText,
    required String now,
  }) async {
    await _insertEntry(
      id: entryId,
      type: 'todo',
      title: todo.title?.trim().isNotEmpty == true
          ? todo.title!.trim()
          : capture.title,
      rawText: rawText,
      normalizedText: todo.summary?.trim().isNotEmpty == true
          ? todo.summary!.trim()
          : capture.summary,
      createdAt: now,
      updatedAt: now,
    );
    await into(todos).insert(
      TodosCompanion(
        entryId: Value(entryId),
        startAt: Value(todo.startAt?.toIso8601String()),
        endAt: Value(todo.endAt?.toIso8601String()),
        location: Value(todo.location),
        topic: Value(todo.topic),
        reminderAt: Value(todo.reminderAt?.toIso8601String()),
        status: Value(todo.status),
      ),
    );
  }

  Future<String> saveIdea({
    required CaptureResult capture,
    required String rawText,
  }) async {
    final idea = capture.ideaPayload;
    if (idea == null) {
      throw ArgumentError('idea_payload is required for idea entries');
    }
    final entryId = _uuid.v4();
    final now = DateTime.now().toIso8601String();

    await transaction(() async {
      await _insertEntry(
        id: entryId,
        type: 'idea',
        title: capture.title,
        rawText: rawText,
        normalizedText: capture.summary,
        createdAt: now,
        updatedAt: now,
      );
      await into(ideas).insert(
        IdeasCompanion(
          entryId: Value(entryId),
          summary: Value(idea.summary),
          sourceHint: Value(idea.sourceHint),
          favorite: const Value(false),
        ),
      );
      for (final tag in idea.tags) {
        await _attachTag(entryId, tag);
      }
    });

    return entryId;
  }

  Future<List<EntryListItem>> loadTodos(DateTime from, DateTime to) async {
    final rows = await db.customSelect(
      '''
      SELECT e.*, t.start_at, t.end_at, t.location, t.topic, t.status, t.reminder_at
      FROM entries e
      JOIN todos t ON t.entry_id = e.id
      WHERE t.start_at IS NOT NULL
        AND t.start_at >= ?
        AND t.start_at < ?
      ORDER BY t.start_at ASC
      ''',
      variables: [
        Variable.withString(from.toIso8601String()),
        Variable.withString(to.toIso8601String()),
      ],
      readsFrom: {entries, todos},
    ).get();

    return rows.map(_todoFromRow).toList(growable: false);
  }

  Future<List<EntryListItem>> loadUnscheduledTodos() async {
    final rows = await db.customSelect(
      '''
      SELECT e.*, t.start_at, t.end_at, t.location, t.topic, t.status, t.reminder_at
      FROM entries e
      JOIN todos t ON t.entry_id = e.id
      WHERE t.start_at IS NULL
        AND (t.status IS NULL OR t.status != 'completed')
      ORDER BY e.created_at DESC
      ''',
      readsFrom: {entries, todos},
    ).get();
    return rows.map(_todoFromRow).toList(growable: false);
  }

  Future<List<EntryListItem>> queryTodos(TodoQueryPayload payload) async {
    final conditions = <String>['t.start_at IS NOT NULL'];
    final vars = <Variable>[];

    if (payload.dateFrom != null) {
      conditions.add('t.start_at >= ?');
      vars.add(Variable.withString(payload.dateFrom!.toIso8601String()));
    }

    if (payload.dateTo != null) {
      conditions.add('t.start_at < ?');
      vars.add(Variable.withString(payload.dateTo!.toIso8601String()));
    }

    if (!payload.includeCompleted) {
      conditions.add("(t.status IS NULL OR t.status != 'completed')");
    }

    final whereClause = conditions.join(' AND ');

    final rows = await db
        .customSelect(
          '''
      SELECT e.*, t.start_at, t.end_at, t.location, t.topic, t.status, t.reminder_at
      FROM entries e
      JOIN todos t ON t.entry_id = e.id
      WHERE $whereClause
      ORDER BY t.start_at ASC
      ''',
          variables: vars,
          readsFrom: {entries, todos},
        )
        .get();

    var results = rows.map(_todoFromRow).toList(growable: false);

    if (payload.keyword != null && payload.keyword!.trim().isNotEmpty) {
      final keyword = payload.keyword!.trim().toLowerCase();
      results = results.where((item) {
        final searchable = [
          item.title,
          item.topic ?? '',
          item.location ?? '',
          item.rawText,
          item.normalizedText,
        ].join('\n').toLowerCase();
        return searchable.contains(keyword);
      }).toList(growable: false);
    }

    return results;
  }

  Future<List<EntryListItem>> searchIdeas(String query) async {
    final rows = await _loadIdeaRows(query: query);
    return _ideasFromRows(rows);
  }

  Future<IdeaPage> loadIdeaPage({
    required String query,
    IdeaPageCursor? after,
    required int limit,
  }) async {
    final rows = await _loadIdeaRows(
      query: query,
      after: after,
      limit: limit + 1,
    );
    final hasMore = rows.length > limit;
    final pageRows = hasMore ? rows.take(limit).toList(growable: false) : rows;
    final items = await _ideasFromRows(pageRows);
    final last = items.isEmpty ? null : items.last;

    return IdeaPage(
      items: items,
      hasMore: hasMore,
      nextCursor: hasMore && last != null
          ? IdeaPageCursor(
              updatedAt: last.updatedAt.toIso8601String(),
              id: last.id,
            )
          : null,
    );
  }

  Future<List<TodoTimeBlock>> loadTodoBlocks() async {
    final rows = await db.customSelect(
      '''
      SELECT e.id, e.title, t.start_at, t.end_at
      FROM entries e
      JOIN todos t ON t.entry_id = e.id
      WHERE t.start_at IS NOT NULL AND t.end_at IS NOT NULL
      ''',
      readsFrom: {entries, todos},
    ).get();

    return rows.map((row) {
      return TodoTimeBlock(
        id: row.read<String>('id'),
        title: row.read<String>('title'),
        startAt: DateTime.parse(row.read<String>('start_at')),
        endAt: DateTime.parse(row.read<String>('end_at')),
      );
    }).toList(growable: false);
  }

  Future<List<EntryListItem>> findTodosForDeletion(
      TodoDeletePayload payload) async {
    final rows = await db.customSelect(
      '''
      SELECT e.*, t.start_at, t.end_at, t.location, t.topic, t.status, t.reminder_at
      FROM entries e
      JOIN todos t ON t.entry_id = e.id
      WHERE t.start_at IS NOT NULL AND t.end_at IS NOT NULL
      ORDER BY t.start_at ASC
      ''',
      readsFrom: {entries, todos},
    ).get();

    final keyword = payload.keyword?.trim().toLowerCase();
    return rows.map(_todoFromRow).where((item) {
      final start = item.startAt?.toLocal();
      final end = item.endAt?.toLocal();
      if (start == null || end == null) {
        return false;
      }
      final dateFrom = payload.dateFrom?.toLocal();
      final dateTo = payload.dateTo?.toLocal();
      if (dateFrom != null && start.isBefore(dateFrom)) {
        return false;
      }
      if (dateTo != null && !start.isBefore(dateTo)) {
        return false;
      }
      final timeFrom = payload.timeFrom?.toLocal();
      final timeTo = payload.timeTo?.toLocal();
      if (timeFrom != null &&
          timeTo != null &&
          !(start.isBefore(timeTo) && end.isAfter(timeFrom))) {
        return false;
      }
      if (keyword != null && keyword.isNotEmpty) {
        final searchable = [
          item.title,
          item.topic ?? '',
          item.location ?? '',
          item.rawText,
          item.normalizedText,
        ].join('\n').toLowerCase();
        if (!searchable.contains(keyword)) {
          return false;
        }
      }
      return true;
    }).toList(growable: false);
  }

  Future<List<EntryListItem>> loadTodosByIds(List<String> ids) async {
    if (ids.isEmpty) {
      return const [];
    }

    final placeholders = List.filled(ids.length, '?').join(', ');
    final rows = await db
        .customSelect(
          '''
      SELECT e.*, t.start_at, t.end_at, t.location, t.topic, t.status, t.reminder_at
      FROM entries e
      JOIN todos t ON t.entry_id = e.id
      WHERE e.id IN ($placeholders)
      ORDER BY t.start_at ASC
      ''',
          variables: ids.map(Variable.withString).toList(growable: false),
          readsFrom: {entries, todos},
        )
        .get();
    return rows.map(_todoFromRow).toList(growable: false);
  }

  Future<void> deleteTodos(List<String> ids) async {
    if (ids.isEmpty) {
      return;
    }
    await transaction(() async {
      for (final id in ids) {
        await db
            .customStatement('DELETE FROM entry_fts WHERE entry_id = ?', [id]);
        await (delete(entries)..where((table) => table.id.equals(id))).go();
      }
    });
  }

  Future<void> updateTodoStatus(String id, String status) async {
    await transaction(() async {
      await (update(todos)..where((table) => table.entryId.equals(id))).write(
        TodosCompanion(status: Value(status)),
      );
      await (update(entries)..where((table) => table.id.equals(id))).write(
        EntriesCompanion(updatedAt: Value(DateTime.now().toIso8601String())),
      );
    });
  }

  Future<void> deleteEntry(String id) async {
    await transaction(() async {
      await db
          .customStatement('DELETE FROM entry_fts WHERE entry_id = ?', [id]);
      await (delete(entries)..where((table) => table.id.equals(id))).go();
    });
  }

  Future<void> clearAll() async {
    await transaction(() async {
      await db.customStatement('DELETE FROM entry_fts');
      await delete(entryTags).go();
      await delete(tags).go();
      await delete(todos).go();
      await delete(ideas).go();
      await delete(entries).go();
      await delete(db.captureSessions).go();
    });
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
  }) async {
    await into(db.captureSessions).insertOnConflictUpdate(
      CaptureSessionsCompanion(
        id: Value(id),
        rawText: Value(rawText),
        status: Value(status),
        createdAt: Value(createdAt),
        updatedAt: Value(updatedAt),
        conversationJson: Value(conversationJson),
        activeDraftJson: Value(activeDraftJson),
        recoverableDraftJson: Value(recoverableDraftJson),
        expiresAt: Value(expiresAt),
      ),
    );
  }

  Future<CaptureSessionRow?> loadSession(String id) async {
    final rows = await (db.select(db.captureSessions)
          ..where((table) => table.id.equals(id)))
        .get();
    if (rows.isEmpty) {
      return null;
    }
    return _sessionFromRow(rows.first);
  }

  Future<CaptureSessionRow?> loadLatestRecoverableSession() async {
    final now = DateTime.now().toIso8601String();
    final rows = await db.customSelect(
      '''
      SELECT * FROM capture_sessions
      WHERE status = 'cancelledRecoverable'
        AND expires_at IS NOT NULL
        AND expires_at > ?
      ORDER BY updated_at DESC
      LIMIT 1
      ''',
      variables: [Variable.withString(now)],
      readsFrom: {db.captureSessions},
    ).get();

    if (rows.isEmpty) {
      return null;
    }
    return _sessionFromRow(rows.first);
  }

  Future<void> deleteSession(String id) async {
    await (db.delete(db.captureSessions)..where((table) => table.id.equals(id)))
        .go();
  }

  CaptureSessionRow _sessionFromRow(dynamic row) {
    return CaptureSessionRow(
      id: row is QueryRow ? row.read<String>('id') : row.id,
      rawText: row is QueryRow ? row.read<String>('raw_text') : row.rawText,
      status: row is QueryRow ? row.read<String>('status') : row.status,
      createdAt:
          row is QueryRow ? row.read<String>('created_at') : row.createdAt,
      updatedAt:
          row is QueryRow ? row.read<String>('updated_at') : row.updatedAt,
      conversationJson: row is QueryRow
          ? row.readNullable<String>('conversation_json')
          : row.conversationJson,
      activeDraftJson: row is QueryRow
          ? row.readNullable<String>('active_draft_json')
          : row.activeDraftJson,
      recoverableDraftJson: row is QueryRow
          ? row.readNullable<String>('recoverable_draft_json')
          : row.recoverableDraftJson,
      expiresAt: row is QueryRow
          ? row.readNullable<String>('expires_at')
          : row.expiresAt,
    );
  }

  Future<void> _insertEntry({
    required String id,
    required String type,
    required String title,
    required String rawText,
    required String normalizedText,
    required String createdAt,
    required String updatedAt,
  }) async {
    await into(entries).insert(
      EntriesCompanion.insert(
        id: id,
        entryType: type,
        title: title,
        rawText: rawText,
        normalizedText: normalizedText,
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
    );
    await db.customStatement(
      'INSERT INTO entry_fts(entry_id, title, normalized_text, raw_text) VALUES (?, ?, ?, ?)',
      [id, title, normalizedText, rawText],
    );
  }

  Future<void> _attachTag(String entryId, String name) async {
    final normalized = name.trim();
    if (normalized.isEmpty) {
      return;
    }
    final tagId = 'tag:$normalized';
    await into(tags).insertOnConflictUpdate(
        TagsCompanion.insert(id: tagId, name: normalized));
    await into(entryTags).insertOnConflictUpdate(
        EntryTagsCompanion.insert(entryId: entryId, tagId: tagId));
  }

  Future<List<EntryListItem>> _ideasFromRows(List<QueryRow> rows) async {
    if (rows.isEmpty) {
      return const [];
    }
    final ids =
        rows.map((row) => row.read<String>('id')).toList(growable: false);
    final tagsByEntry = await _tagsForEntries(ids);
    return rows
        .map((row) => _ideaFromRow(
              row,
              tagsByEntry[row.read<String>('id')] ?? const [],
            ))
        .toList(growable: false);
  }

  Future<Map<String, List<String>>> _tagsForEntries(
      List<String> entryIds) async {
    final placeholders = List.filled(entryIds.length, '?').join(', ');
    final rows = await db
        .customSelect(
          '''
      SELECT et.entry_id, t.name
      FROM tags t
      JOIN entry_tags et ON et.tag_id = t.id
      WHERE et.entry_id IN ($placeholders)
      ORDER BY et.entry_id ASC, t.name ASC
      ''',
          variables: entryIds.map(Variable.withString).toList(growable: false),
          readsFrom: {tags, entryTags},
        )
        .get();

    final tagsByEntry = <String, List<String>>{};
    for (final row in rows) {
      tagsByEntry
          .putIfAbsent(row.read<String>('entry_id'), () => [])
          .add(row.read<String>('name'));
    }
    return tagsByEntry;
  }

  Future<List<QueryRow>> _loadIdeaRows({
    required String query,
    IdeaPageCursor? after,
    int? limit,
  }) {
    final trimmed = query.trim();
    return trimmed.isEmpty
        ? _loadAllIdeaRows(after: after, limit: limit)
        : _searchIdeasByText(trimmed, after: after, limit: limit);
  }

  Future<List<QueryRow>> _loadAllIdeaRows({
    IdeaPageCursor? after,
    int? limit,
  }) {
    final variables = <Variable>[];
    final cursorClause = _ideaCursorClause(after, variables);
    final limitClause = _ideaLimitClause(limit, variables);
    return db
        .customSelect(
          '''
      SELECT e.*, i.summary, i.source_hint
      FROM entries e
      JOIN ideas i ON i.entry_id = e.id
      WHERE 1 = 1 $cursorClause
      ORDER BY e.updated_at DESC, e.id DESC
      $limitClause
      ''',
          variables: variables,
          readsFrom: {entries, ideas},
        )
        .get();
  }

  Future<List<QueryRow>> _searchIdeasByText(
    String trimmed, {
    IdeaPageCursor? after,
    int? limit,
  }) {
    final terms = _fuzzyTerms(trimmed);
    final whereClause = terms
        .map((_) =>
            "(f.title LIKE ? ESCAPE '\\' OR f.normalized_text LIKE ? ESCAPE '\\' OR f.raw_text LIKE ? ESCAPE '\\')")
        .join(' AND ');
    final variables = <Variable>[
      for (final term in terms) ...[
        Variable.withString(term),
        Variable.withString(term),
        Variable.withString(term),
      ],
    ];
    final cursorClause = _ideaCursorClause(after, variables);
    final limitClause = _ideaLimitClause(limit, variables);
    return db
        .customSelect(
          '''
      SELECT e.*, i.summary, i.source_hint
      FROM entry_fts f
      JOIN entries e ON e.id = f.entry_id
      JOIN ideas i ON i.entry_id = e.id
      WHERE $whereClause $cursorClause
      ORDER BY e.updated_at DESC, e.id DESC
      $limitClause
      ''',
          variables: variables,
          readsFrom: {entries, ideas},
        )
        .get();
  }

  String _ideaCursorClause(IdeaPageCursor? after, List<Variable> variables) {
    if (after == null) {
      return '';
    }
    variables
      ..add(Variable.withString(after.updatedAt))
      ..add(Variable.withString(after.updatedAt))
      ..add(Variable.withString(after.id));
    return 'AND (e.updated_at < ? OR (e.updated_at = ? AND e.id < ?))';
  }

  String _ideaLimitClause(int? limit, List<Variable> variables) {
    if (limit == null) {
      return '';
    }
    variables.add(Variable.withInt(limit));
    return 'LIMIT ?';
  }

  EntryListItem _todoFromRow(QueryRow row) {
    return EntryListItem(
      id: row.read<String>('id'),
      type: CaptureIntentType.todo,
      title: row.read<String>('title'),
      rawText: row.read<String>('raw_text'),
      normalizedText: row.read<String>('normalized_text'),
      createdAt: DateTime.parse(row.read<String>('created_at')),
      updatedAt: DateTime.parse(row.read<String>('updated_at')),
      startAt: _readDate(row, 'start_at'),
      endAt: _readDate(row, 'end_at'),
      location: row.readNullable<String>('location'),
      topic: row.readNullable<String>('topic'),
      status: row.read<String>('status'),
      reminderAt: _readDate(row, 'reminder_at'),
    );
  }

  EntryListItem _ideaFromRow(QueryRow row, List<String> tags) {
    return EntryListItem(
      id: row.read<String>('id'),
      type: CaptureIntentType.idea,
      title: row.read<String>('title'),
      rawText: row.read<String>('raw_text'),
      normalizedText: row.read<String>('normalized_text'),
      createdAt: DateTime.parse(row.read<String>('created_at')),
      updatedAt: DateTime.parse(row.read<String>('updated_at')),
      summary: row.read<String>('summary'),
      tags: tags,
    );
  }
}

DateTime? _readDate(QueryRow row, String column) {
  final value = row.readNullable<String>(column);
  return value == null ? null : DateTime.tryParse(value);
}

List<String> _fuzzyTerms(String value) {
  return value
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .map((part) =>
          '%${part.replaceAll(r'\', r'\\').replaceAll('%', r'\%').replaceAll('_', r'\_')}%')
      .toList(growable: false);
}
