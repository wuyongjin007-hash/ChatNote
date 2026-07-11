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
      SELECT e.*, t.start_at, t.end_at, t.location, t.topic, t.status
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

  Future<List<EntryListItem>> searchIdeas(String query) async {
    final trimmed = query.trim();
    final rows = trimmed.isEmpty
        ? await db.customSelect(
            '''
            SELECT e.*, i.summary, i.source_hint
            FROM entries e
            JOIN ideas i ON i.entry_id = e.id
            ORDER BY e.updated_at DESC
            ''',
            readsFrom: {entries, ideas},
          ).get()
        : await _searchIdeasByText(trimmed);

    final items = <EntryListItem>[];
    for (final row in rows) {
      items.add(_ideaFromRow(row, await _tagsForEntry(row.read<String>('id'))));
    }
    return items;
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
      SELECT e.*, t.start_at, t.end_at, t.location, t.topic, t.status
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

  Future<List<String>> _tagsForEntry(String entryId) async {
    final rows = await db.customSelect(
      '''
      SELECT t.name
      FROM tags t
      JOIN entry_tags et ON et.tag_id = t.id
      WHERE et.entry_id = ?
      ORDER BY t.name ASC
      ''',
      variables: [Variable.withString(entryId)],
      readsFrom: {tags, entryTags},
    ).get();

    return rows.map((row) => row.read<String>('name')).toList(growable: false);
  }

  Future<List<QueryRow>> _searchIdeasByText(String trimmed) async {
    final terms = _fuzzyTerms(trimmed);
    final whereClause = terms
        .map((_) =>
            "(f.title LIKE ? ESCAPE '\\' OR f.normalized_text LIKE ? ESCAPE '\\' OR f.raw_text LIKE ? ESCAPE '\\')")
        .join(' AND ');
    final variables = [
      for (final term in terms) ...[
        Variable.withString(term),
        Variable.withString(term),
        Variable.withString(term),
      ],
    ];
    return db
        .customSelect(
          '''
      SELECT e.*, i.summary, i.source_hint
      FROM entry_fts f
      JOIN entries e ON e.id = f.entry_id
      JOIN ideas i ON i.entry_id = e.id
      WHERE $whereClause
      ORDER BY e.updated_at DESC
      ''',
          variables: variables,
          readsFrom: {entries, ideas},
        )
        .get();
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
