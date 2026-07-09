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
}
