import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

import '../domain/capture_models.dart';
import '../domain/conflict_detector.dart';

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
}

class AppDatabase extends GeneratedDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  final _uuid = const Uuid();

  @override
  int get schemaVersion => 1;

  @override
  Iterable<TableInfo<Table, Object?>> get allTables => const [];

  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => const [];

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
        onCreate: (m) async {
          await customStatement('''
            CREATE TABLE capture_sessions (
              id TEXT PRIMARY KEY,
              raw_text TEXT NOT NULL,
              status TEXT NOT NULL,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL
            );
          ''');
          await customStatement('''
            CREATE TABLE entries (
              id TEXT PRIMARY KEY,
              type TEXT NOT NULL CHECK (type IN ('todo', 'idea')),
              title TEXT NOT NULL,
              raw_text TEXT NOT NULL,
              normalized_text TEXT NOT NULL,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL
            );
          ''');
          await customStatement('''
            CREATE TABLE todos (
              entry_id TEXT PRIMARY KEY REFERENCES entries(id) ON DELETE CASCADE,
              start_at TEXT,
              end_at TEXT,
              location TEXT,
              topic TEXT,
              reminder_at TEXT,
              status TEXT NOT NULL DEFAULT 'draft'
            );
          ''');
          await customStatement('''
            CREATE TABLE ideas (
              entry_id TEXT PRIMARY KEY REFERENCES entries(id) ON DELETE CASCADE,
              summary TEXT NOT NULL,
              source_hint TEXT,
              favorite INTEGER NOT NULL DEFAULT 0
            );
          ''');
          await customStatement('''
            CREATE TABLE tags (
              id TEXT PRIMARY KEY,
              name TEXT NOT NULL UNIQUE
            );
          ''');
          await customStatement('''
            CREATE TABLE entry_tags (
              entry_id TEXT NOT NULL REFERENCES entries(id) ON DELETE CASCADE,
              tag_id TEXT NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
              PRIMARY KEY (entry_id, tag_id)
            );
          ''');
          await customStatement('''
            CREATE VIRTUAL TABLE entry_fts USING fts5(
              entry_id UNINDEXED,
              title,
              normalized_text,
              raw_text
            );
          ''');
        },
      );

  Future<String> saveTodo({
    required CaptureResult capture,
    required String rawText,
  }) async {
    final todo = capture.todoPayload;
    if (todo == null) {
      throw ArgumentError('todo_payload is required for todo entries');
    }
    final entryId = _uuid.v4();
    final now = DateTime.now().toIso8601String();

    await transaction(() async {
      await _insertEntry(
        id: entryId,
        type: 'todo',
        title: capture.title,
        rawText: rawText,
        normalizedText: capture.summary,
        createdAt: now,
        updatedAt: now,
      );
      await customStatement(
        '''
        INSERT INTO todos(entry_id, start_at, end_at, location, topic, reminder_at, status)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        ''',
        [
          entryId,
          todo.startAt?.toIso8601String(),
          todo.endAt?.toIso8601String(),
          todo.location,
          todo.topic,
          todo.reminderAt?.toIso8601String(),
          todo.status,
        ],
      );
    });

    return entryId;
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
      await customStatement(
        '''
        INSERT INTO ideas(entry_id, summary, source_hint, favorite)
        VALUES (?, ?, ?, 0)
        ''',
        [entryId, idea.summary, idea.sourceHint],
      );
      for (final tag in idea.tags) {
        await _attachTag(entryId, tag);
      }
    });

    return entryId;
  }

  Future<List<EntryListItem>> loadTodos(DateTime from, DateTime to) async {
    final rows = await customSelect(
      '''
      SELECT e.*, t.start_at, t.end_at, t.location, t.topic
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
    ).get();

    return rows.map(_todoFromRow).toList(growable: false);
  }

  Future<List<EntryListItem>> searchIdeas(String query) async {
    final trimmed = query.trim();
    final rows = trimmed.isEmpty
        ? await customSelect(
            '''
            SELECT e.*, i.summary, i.source_hint
            FROM entries e
            JOIN ideas i ON i.entry_id = e.id
            ORDER BY e.updated_at DESC
            ''',
          ).get()
        : await customSelect(
            '''
            SELECT e.*, i.summary, i.source_hint
            FROM entry_fts f
            JOIN entries e ON e.id = f.entry_id
            JOIN ideas i ON i.entry_id = e.id
            WHERE entry_fts MATCH ?
            ORDER BY e.updated_at DESC
            ''',
            variables: [Variable.withString(_ftsQuery(trimmed))],
          ).get();

    final items = <EntryListItem>[];
    for (final row in rows) {
      items.add(_ideaFromRow(row, await _tagsForEntry(row.read<String>('id'))));
    }
    return items;
  }

  Future<List<TodoTimeBlock>> loadTodoBlocks() async {
    final rows = await customSelect(
      '''
      SELECT e.id, e.title, t.start_at, t.end_at
      FROM entries e
      JOIN todos t ON t.entry_id = e.id
      WHERE t.start_at IS NOT NULL AND t.end_at IS NOT NULL
      ''',
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

  Future<void> deleteEntry(String id) async {
    await transaction(() async {
      await customStatement('DELETE FROM entry_fts WHERE entry_id = ?', [id]);
      await customStatement('DELETE FROM entries WHERE id = ?', [id]);
    });
  }

  Future<void> clearAll() async {
    await transaction(() async {
      await customStatement('DELETE FROM entry_fts');
      await customStatement('DELETE FROM entry_tags');
      await customStatement('DELETE FROM tags');
      await customStatement('DELETE FROM todos');
      await customStatement('DELETE FROM ideas');
      await customStatement('DELETE FROM entries');
      await customStatement('DELETE FROM capture_sessions');
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
    await customStatement(
      '''
      INSERT INTO entries(id, type, title, raw_text, normalized_text, created_at, updated_at)
      VALUES (?, ?, ?, ?, ?, ?, ?)
      ''',
      [id, type, title, rawText, normalizedText, createdAt, updatedAt],
    );
    await customStatement(
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
    await customStatement(
      'INSERT OR IGNORE INTO tags(id, name) VALUES (?, ?)',
      [tagId, normalized],
    );
    await customStatement(
      'INSERT OR IGNORE INTO entry_tags(entry_id, tag_id) VALUES (?, ?)',
      [entryId, tagId],
    );
  }

  Future<List<String>> _tagsForEntry(String entryId) async {
    final rows = await customSelect(
      '''
      SELECT t.name
      FROM tags t
      JOIN entry_tags et ON et.tag_id = t.id
      WHERE et.entry_id = ?
      ORDER BY t.name ASC
      ''',
      variables: [Variable.withString(entryId)],
    ).get();

    return rows.map((row) => row.read<String>('name')).toList(growable: false);
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

QueryExecutor _openConnection() {
  return driftDatabase(name: 'local_idea_capture');
}

DateTime? _readDate(QueryRow row, String column) {
  final value = row.readNullable<String>(column);
  return value == null ? null : DateTime.tryParse(value);
}

String _ftsQuery(String value) {
  return value.replaceAll('"', ' ').split(RegExp(r'\s+')).where((part) => part.isNotEmpty).join(' ');
}
