import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_idea_capture/src/data/app_database.dart';
import 'package:local_idea_capture/src/data/entry_repository.dart';
import 'package:local_idea_capture/src/domain/capture_models.dart';
import 'package:local_idea_capture/src/features/query/query_page.dart';
import 'package:local_idea_capture/src/providers.dart';
import 'package:local_idea_capture/src/theme/app_colors.dart';

void main() {
  testWidgets('renders idea tags as compact colorful pills', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await database.saveIdea(
      capture: const CaptureResult(
        intentType: CaptureIntentType.idea,
        confidence: 0.96,
        title: 'History reading idea',
        summary: 'Compare two history books',
        missingFields: [],
        followUpQuestion: null,
        shouldSave: true,
        todoPayload: null,
        ideaPayload: IdeaPayload(
          summary: 'Compare two history books',
          sourceHint: null,
          tags: ['history', 'reading'],
        ),
      ),
      rawText: 'compare history books',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
        ],
        child: const MaterialApp(home: Scaffold(body: IdeaQueryPage())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('idea-tag-pill-history')), findsOneWidget);
    expect(find.byKey(const Key('idea-tag-pill-reading')), findsOneWidget);
    expect(find.byType(Chip), findsNothing);
    expect(find.byIcon(Icons.lightbulb_outline), findsNothing);

    final historyText = tester.widget<Text>(find.text('history'));
    expect(historyText.style?.fontSize, lessThanOrEqualTo(12));

    final pill = tester.widget<Container>(
      find.byKey(const Key('idea-tag-pill-history')),
    );
    final decoration = pill.decoration as BoxDecoration;
    expect(decoration.color, isNotNull);
    expect(decoration.color, isNot(Colors.transparent));
  });

  testWidgets('uses warm clean idea page surfaces', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await database.saveIdea(
      capture: const CaptureResult(
        intentType: CaptureIntentType.idea,
        confidence: 0.96,
        title: 'Reading idea',
        summary: 'Compare two books',
        missingFields: [],
        followUpQuestion: null,
        shouldSave: true,
        todoPayload: null,
        ideaPayload: IdeaPayload(
          summary: 'Compare two books',
          sourceHint: null,
          tags: ['reading'],
        ),
      ),
      rawText: 'compare books',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
        ],
        child: const MaterialApp(home: Scaffold(body: IdeaQueryPage())),
      ),
    );
    await tester.pumpAndSettle();

    final searchField = tester.widget<TextField>(find.byType(TextField));
    final searchDecoration = searchField.decoration!;
    expect(searchDecoration.filled, isTrue);
    expect(searchDecoration.fillColor, AppColors.surfaceSoft);

    final ideaCard =
        tester.widget<Container>(find.byKey(const Key('idea-card')));
    final decoration = ideaCard.decoration as BoxDecoration;
    expect(decoration.color, AppColors.surface);
    expect(decoration.border, isNotNull);
  });

  testWidgets('reveals a delete action and removes only the selected idea',
      (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    final repository = _ControlledRefreshEntryRepository(database);
    addTearDown(database.close);

    final deleteId = await database.saveIdea(
      capture: const CaptureResult(
        intentType: CaptureIntentType.idea,
        confidence: 0.96,
        title: 'Delete this idea',
        summary: 'This idea should disappear',
        missingFields: [],
        followUpQuestion: null,
        shouldSave: true,
        todoPayload: null,
        ideaPayload: IdeaPayload(
          summary: 'This idea should disappear',
          sourceHint: null,
          tags: [],
        ),
      ),
      rawText: 'delete this idea',
    );
    await database.saveIdea(
      capture: const CaptureResult(
        intentType: CaptureIntentType.idea,
        confidence: 0.96,
        title: 'Keep this idea',
        summary: 'This idea should remain',
        missingFields: [],
        followUpQuestion: null,
        shouldSave: true,
        todoPayload: null,
        ideaPayload: IdeaPayload(
          summary: 'This idea should remain',
          sourceHint: null,
          tags: [],
        ),
      ),
      rawText: 'keep this idea',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          entryRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: Scaffold(body: IdeaQueryPage())),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(Key('idea-card-$deleteId')),
      const Offset(-260, 0),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(Key('idea-delete-action-$deleteId')), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline), findsOneWidget);

    await tester.tap(find.byKey(Key('idea-delete-action-$deleteId')));
    await tester.pump();

    expect(find.byKey(Key('idea-delete-animation-$deleteId')), findsOneWidget);
    final sizeTransition = tester.widget<SizeTransition>(
      find.descendant(
        of: find.byKey(Key('idea-delete-animation-$deleteId')),
        matching: find.byType(SizeTransition),
      ),
    );
    expect(sizeTransition.alignment, Alignment.topCenter);
    expect(find.text('Delete this idea'), findsOneWidget);
    expect(await database.searchIdeas('Delete this idea'), hasLength(1));

    await tester.pump(const Duration(milliseconds: 420));
    for (var attempt = 0;
        attempt < 10 && repository.refreshCompleter == null;
        attempt++) {
      await tester.pump(const Duration(milliseconds: 10));
    }

    expect(repository.refreshCompleter, isNull);
    expect(
      find.byKey(Key('idea-card-$deleteId')).hitTestable(),
      findsNothing,
    );

    await tester.pumpAndSettle();

    expect(find.text('Delete this idea'), findsNothing);
    expect(find.text('Keep this idea'), findsOneWidget);
    expect(await database.searchIdeas('Delete this idea'), isEmpty);
    expect(await database.searchIdeas('Keep this idea'), hasLength(1));
    expect(find.byType(SnackBar), findsNothing);
  });
}

class _ControlledRefreshEntryRepository extends EntryRepository {
  _ControlledRefreshEntryRepository(super.database);

  var _searchCount = 0;
  Completer<List<EntryListItem>>? refreshCompleter;

  @override
  Future<List<EntryListItem>> searchIdeas(String query) {
    _searchCount++;
    if (_searchCount == 1) {
      return super.searchIdeas(query);
    }
    refreshCompleter = Completer<List<EntryListItem>>();
    return refreshCompleter!.future;
  }
}
