import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_idea_capture/src/data/app_database.dart';
import 'package:local_idea_capture/src/domain/capture_models.dart';
import 'package:local_idea_capture/src/features/query/query_page.dart';
import 'package:local_idea_capture/src/providers.dart';

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

    final historyText = tester.widget<Text>(find.text('history'));
    expect(historyText.style?.fontSize, lessThanOrEqualTo(12));

    final pill = tester.widget<Container>(
      find.byKey(const Key('idea-tag-pill-history')),
    );
    final decoration = pill.decoration as BoxDecoration;
    expect(decoration.color, isNotNull);
    expect(decoration.color, isNot(Colors.transparent));
  });
}
