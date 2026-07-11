import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_idea_capture/src/data/app_database.dart';
import 'package:local_idea_capture/src/domain/capture_models.dart';
import 'package:local_idea_capture/src/features/query/query_page.dart';
import 'package:local_idea_capture/src/providers.dart';

void main() {
  testWidgets('shows UTC stored todo times in local time', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await database.saveTodo(
      capture: CaptureResult(
        intentType: CaptureIntentType.todo,
        confidence: 0.98,
        title: 'Morning meeting',
        summary: 'Meeting at 8',
        missingFields: const [],
        followUpQuestion: null,
        shouldSave: true,
        todoPayload: TodoPayload(
          startAt: DateTime.utc(2026, 7, 11, 0),
          endAt: DateTime.utc(2026, 7, 11, 1),
          location: 'Room 3',
          topic: 'Project',
          reminderAt: null,
          status: 'draft',
        ),
        ideaPayload: null,
      ),
      rawText: 'meeting at 8',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: Scaffold(body: TodoQueryPage())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('08:00'), findsOneWidget);
    expect(find.textContaining('00:00-01:00'), findsNothing);
  });

  testWidgets('shows today section before older todos', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 9);
    final yesterday = today.subtract(const Duration(days: 1));

    await database.saveTodo(
      capture: _todoCapture(
        title: 'Yesterday todo',
        startAt: yesterday,
        endAt: yesterday.add(const Duration(minutes: 30)),
      ),
      rawText: 'yesterday',
    );
    await database.saveTodo(
      capture: _todoCapture(
        title: 'Today todo',
        startAt: today,
        endAt: today.add(const Duration(minutes: 30)),
      ),
      rawText: 'today',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: Scaffold(body: TodoQueryPage())),
      ),
    );
    await tester.pumpAndSettle();

    final todayTop =
        tester.getTopLeft(find.byKey(const Key('todo-day-today-header'))).dy;
    final yesterdayTop = tester
        .getTopLeft(find.byKey(const Key('todo-day-yesterday-header')))
        .dy;

    expect(todayTop, lessThan(yesterdayTop));
  });

  testWidgets('renders todos as compact checklist cards', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await database.saveTodo(
      capture: _todoCapture(
        title: '去办公室做PPT',
        startAt: DateTime(2026, 7, 11, 14),
        endAt: DateTime(2026, 7, 11, 14, 30),
        location: '办公室',
        topic: '做PPT',
      ),
      rawText: '7月11日下午2点去办公室做PPT',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const MaterialApp(home: Scaffold(body: TodoQueryPage())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('todo-card')), findsOneWidget);
    expect(find.byKey(const Key('todo-check-box')), findsOneWidget);
    expect(find.byKey(const Key('todo-card-accent')), findsOneWidget);
    expect(find.byIcon(Icons.event_available), findsNothing);
    expect(find.textContaining('2026-7-11 14:00'), findsOneWidget);
    expect(find.textContaining('14:00-14:30  办公室  做PPT'), findsNothing);
  });
}

CaptureResult _todoCapture({
  required String title,
  required DateTime startAt,
  required DateTime endAt,
  String? location,
  String? topic,
}) {
  return CaptureResult(
    intentType: CaptureIntentType.todo,
    confidence: 0.98,
    title: title,
    summary: title,
    missingFields: const [],
    followUpQuestion: null,
    shouldSave: true,
    todoPayload: TodoPayload(
      startAt: startAt,
      endAt: endAt,
      location: location,
      topic: topic ?? title,
      reminderAt: null,
      status: 'draft',
    ),
    ideaPayload: null,
  );
}
