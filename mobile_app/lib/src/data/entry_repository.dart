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
      CaptureIntentType.unclear => throw StateError('无法保存未明确分类的记录'),
    };
  }

  Future<List<EntryListItem>> findTodosForDeletion(TodoDeletePayload payload) {
    return _database.findTodosForDeletion(payload);
  }

  Future<void> deleteTodos(List<String> ids) {
    return _database.deleteTodos(ids);
  }

  Future<List<EntryListItem>> loadUpcomingTodos() {
    final now = DateTime.now();
    return _database.loadTodos(
      DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1)),
      DateTime(now.year, now.month, now.day).add(const Duration(days: 60)),
    );
  }

  Future<List<EntryListItem>> searchIdeas(String query) {
    return _database.searchIdeas(query);
  }

  Future<void> clearAll() => _database.clearAll();
}
