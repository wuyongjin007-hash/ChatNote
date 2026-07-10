import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_idea_capture/src/app.dart';
import 'package:local_idea_capture/src/data/app_database.dart';
import 'package:local_idea_capture/src/providers.dart';

void main() {
  testWidgets(
      'shows record todo and idea as top-level drawer destinations',
      (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
        ],
        child: const IdeaCaptureApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byKey(const Key('app-drawer-menu-button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('app-drawer-menu-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('app-side-drawer')), findsOneWidget);
    expect(find.text('记录'), findsOneWidget);
    expect(find.text('待办'), findsOneWidget);
    expect(find.text('创意'), findsOneWidget);
    expect(find.text('查询'), findsNothing);
    expect(find.byKey(const Key('drawer-destination-settings')), findsNothing);
    expect(find.byKey(const Key('drawer-destination-voice-selected')),
        findsOneWidget);

    await tester.tap(find.byKey(const Key('drawer-destination-todos')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('app-side-drawer')), findsNothing);
    expect(find.text('待办'), findsOneWidget);

    await tester.tap(find.byKey(const Key('app-drawer-menu-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('drawer-destination-todos-selected')),
        findsOneWidget);

    await tester.tap(find.byKey(const Key('drawer-destination-ideas')));
    await tester.pumpAndSettle();

    expect(find.text('创意'), findsOneWidget);

    await tester.tap(find.byKey(const Key('app-drawer-menu-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('drawer-destination-ideas-selected')),
        findsOneWidget);
  });
}
