import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_idea_capture/src/data/app_database.dart';
import 'package:local_idea_capture/src/domain/capture_models.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test('exposes Drift table metadata for the local schema', () {
    final tableNames = database.allTables.map((table) => table.actualTableName);

    expect(
      tableNames,
      containsAll([
        'capture_sessions',
        'entries',
        'todos',
        'ideas',
        'tags',
        'entry_tags',
      ]),
    );
  });

  test('saves an idea with tags and finds it through text search', () async {
    await database.saveIdea(
      capture: const CaptureResult(
        intentType: CaptureIntentType.idea,
        confidence: 0.95,
        title: 'Compare Wanli and Chinese history views',
        summary: 'Compare the historical views in two books',
        missingFields: [],
        followUpQuestion: null,
        shouldSave: true,
        todoPayload: null,
        ideaPayload: IdeaPayload(
          summary: 'Compare the historical views in two books',
          sourceHint: null,
          tags: ['history', 'reading'],
        ),
      ),
      rawText: 'wanli has a different historical view from chinese history',
    );

    final results = await database.searchIdeas('wanli');

    expect(results, hasLength(1));
    expect(results.single.tags, containsAll(['history', 'reading']));
  });

  test('matches todo deletion by date, overlapping time, and keyword',
      () async {
    await database.saveTodo(
      capture: _todo(
          '上午项目会议', DateTime(2026, 7, 12, 9), DateTime(2026, 7, 12, 10),
          topic: '项目会'),
      rawText: '明天上午九点开项目会议',
    );
    await database.saveTodo(
      capture: _todo(
          '中午买菜', DateTime(2026, 7, 12, 12), DateTime(2026, 7, 12, 12, 30)),
      rawText: '明天中午买菜',
    );
    await database.saveIdea(
      capture: const CaptureResult(
        intentType: CaptureIntentType.idea,
        confidence: 1,
        title: '项目会议灵感',
        summary: '不能被待办删除影响',
        missingFields: [],
        followUpQuestion: null,
        shouldSave: true,
        todoPayload: null,
        ideaPayload: IdeaPayload(summary: '不能删除', sourceHint: null, tags: []),
      ),
      rawText: '项目会议灵感',
    );

    final matches = await database.findTodosForDeletion(
      TodoDeletePayload(
        operation: TodoDeleteOperation.delete,
        dateFrom: DateTime(2026, 7, 12),
        dateTo: DateTime(2026, 7, 13),
        timeFrom: DateTime(2026, 7, 12, 9, 30),
        timeTo: DateTime(2026, 7, 12, 10, 30),
        keyword: '项目',
      ),
    );

    expect(matches.map((item) => item.title), ['上午项目会议']);
    await database.deleteTodos(matches.map((item) => item.id).toList());
    expect(
        await database.loadTodos(DateTime(2026, 7, 12), DateTime(2026, 7, 13)),
        hasLength(1));
    expect(await database.searchIdeas('项目会议'), hasLength(1));
  });
}

CaptureResult _todo(String title, DateTime start, DateTime end,
    {String? topic}) {
  return CaptureResult(
    intentType: CaptureIntentType.todo,
    confidence: 1,
    title: title,
    summary: title,
    missingFields: const [],
    followUpQuestion: null,
    shouldSave: true,
    todoPayload: TodoPayload(
      startAt: start,
      endAt: end,
      location: null,
      topic: topic,
      reminderAt: null,
      status: 'pending',
    ),
    ideaPayload: null,
  );
}
