import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../domain/capture_models.dart';
import '../domain/conflict_detector.dart';
import 'entry_dao.dart';

export 'entry_dao.dart' show EntryListItem, IdeaPage, IdeaPageCursor;

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
  ],
  daos: [EntryDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
        onCreate: (m) async {
          await m.createAll();
          await _createEntryFtsTable();
          await _createPagingIndexes();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await _createPagingIndexes();
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

  Future<void> deleteTodos(List<String> ids) {
    return entryDao.deleteTodos(ids);
  }

  Future<void> updateTodoStatus(String id, String status) {
    return entryDao.updateTodoStatus(id, status);
  }

  Future<void> deleteEntry(String id) {
    return entryDao.deleteEntry(id);
  }

  Future<void> clearAll() {
    return entryDao.clearAll();
  }

  Future<bool> entryFtsUsesFts5() async {
    final rows = await customSelect(
      "SELECT sql FROM sqlite_master WHERE type = 'table' AND name = 'entry_fts'",
    ).get();
    final statement =
        rows.isEmpty ? '' : rows.single.readNullable<String>('sql') ?? '';
    return statement.toUpperCase().contains('VIRTUAL TABLE');
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
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'local_idea_capture');
}
