import '../domain/capture_models.dart';
import '../domain/conflict_detector.dart';
import 'app_database.dart';

class EntryRepository {
  EntryRepository(this._database);

  final AppDatabase _database;

  Future<List<TodoTimeBlock>> conflictsFor(CaptureResult capture) async {
    final todos = capture.effectiveTodoPayloads
        .where((todo) => todo.startAt != null && todo.endAt != null)
        .toList(growable: false);
    if (todos.isEmpty) {
      return const [];
    }
    final existing = await _database.loadTodoBlocks();
    final conflicts = <TodoTimeBlock>[];
    for (var index = 0; index < todos.length; index++) {
      final todo = todos[index];
      final candidate = TodoTimeBlock(
        id: 'candidate:$index',
        title: todo.title ?? capture.title,
        startAt: todo.startAt!,
        endAt: todo.endAt!,
      );
      conflicts.addAll(findTodoConflicts(candidate, existing));
    }
    return conflicts;
  }

  Future<List<String>> saveCapture(CaptureResult capture, String rawText) {
    return switch (capture.intentType) {
      CaptureIntentType.todo =>
        _database.saveTodos(capture: capture, rawText: rawText),
      CaptureIntentType.idea => _database
          .saveIdea(capture: capture, rawText: rawText)
          .then((id) => [id]),
      CaptureIntentType.todoDelete => throw StateError('删除请求不能作为新记录保存'),
      CaptureIntentType.todoQuery => throw StateError('查询请求不能作为新记录保存'),
      CaptureIntentType.unclear => throw StateError('无法保存未明确分类的记录'),
    };
  }

  Future<List<EntryListItem>> queryTodos(TodoQueryPayload payload) {
    return _database.queryTodos(payload);
  }

  Future<List<EntryListItem>> findTodosForDeletion(TodoDeletePayload payload) {
    return _database.findTodosForDeletion(payload);
  }

  Future<List<EntryListItem>> loadTodosByIds(List<String> ids) {
    return _database.loadTodosByIds(ids);
  }

  Future<void> deleteTodos(List<String> ids) {
    return _database.deleteTodos(ids);
  }

  Future<void> updateTodoStatus(String id, String status) {
    return _database.updateTodoStatus(id, status);
  }

  Future<List<EntryListItem>> loadUpcomingTodos() {
    final now = DateTime.now();
    return _database.loadTodos(
      DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1)),
      DateTime(now.year, now.month, now.day).add(const Duration(days: 60)),
    );
  }

  Future<List<EntryListItem>> loadTodoWindow(DateTime from, DateTime to) {
    return _database.loadTodos(from, to);
  }

  Future<List<EntryListItem>> loadUnscheduledTodos() {
    return _database.loadUnscheduledTodos();
  }

  Future<List<EntryListItem>> searchIdeas(String query) {
    return _database.searchIdeas(query);
  }

  Future<IdeaPage> loadIdeaPage({
    String query = '',
    IdeaPageCursor? after,
    int limit = 40,
  }) {
    return _database.loadIdeaPage(query: query, after: after, limit: limit);
  }

  Future<void> deleteIdea(String id) {
    return _database.deleteEntry(id);
  }

  Future<void> clearAll() => _database.clearAll();

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
    return _database.upsertSession(
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
    return _database.loadSession(id);
  }

  Future<CaptureSessionRow?> loadLatestRecoverableSession() {
    return _database.loadLatestRecoverableSession();
  }

  Future<void> deleteSession(String id) {
    return _database.deleteSession(id);
  }
}
