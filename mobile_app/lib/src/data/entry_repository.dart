import '../domain/capture_models.dart';
import '../domain/conflict_detector.dart';
import 'app_database.dart';

class EntryRepository {
  EntryRepository(this._database);

  final AppDatabase _database;

  Future<List<TodoTimeBlock>> conflictsFor(CaptureResult capture) async {
    final todo = capture.todoPayload;
    if (todo?.startAt == null || todo?.endAt == null) {
      return const [];
    }
    final candidate = TodoTimeBlock(
      id: 'candidate',
      title: capture.title,
      startAt: todo!.startAt!,
      endAt: todo.endAt!,
    );
    final existing = await _database.loadTodoBlocks();
    return findTodoConflicts(candidate, existing);
  }

  Future<String> saveCapture(CaptureResult capture, String rawText) {
    return switch (capture.intentType) {
      CaptureIntentType.todo =>
        _database.saveTodo(capture: capture, rawText: rawText),
      CaptureIntentType.idea =>
        _database.saveIdea(capture: capture, rawText: rawText),
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
