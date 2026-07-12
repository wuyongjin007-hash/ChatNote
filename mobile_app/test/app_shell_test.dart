import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_idea_capture/src/app.dart';
import 'package:local_idea_capture/src/data/app_database.dart';
import 'package:local_idea_capture/src/features/query/query_page.dart';
import 'package:local_idea_capture/src/features/voice/voice_page.dart';
import 'package:local_idea_capture/src/providers.dart';
import 'package:local_idea_capture/src/theme/app_colors.dart';

void main() {
  testWidgets('shows record todo and idea as top-level drawer destinations',
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

    final contentFinder = find.byKey(const Key('app-pushed-content'));
    final initialLeft = tester.getTopLeft(contentFinder).dx;
    await tester.tap(find.byKey(const Key('app-drawer-menu-button')));
    await tester.pumpAndSettle();

    expect(initialLeft, 0);
    expect(tester.getTopLeft(contentFinder).dx, greaterThanOrEqualTo(300));
    final overlay = tester.widget<Opacity>(
      find.byKey(const Key('app-content-fade-overlay')),
    );
    expect(overlay.opacity, greaterThan(0));
    final drawerFinder = find.byKey(const Key('app-side-drawer'));
    expect(drawerFinder, findsOneWidget);
    expect(
      find.descendant(of: drawerFinder, matching: find.byType(TextField)),
      findsNothing,
    );
    final identityAvatar = find.descendant(
      of: drawerFinder,
      matching: find.byType(CircleAvatar),
    );
    expect(tester.getSize(identityAvatar).height, lessThanOrEqualTo(36));
    final identity = tester.widget<Container>(
      find.byKey(const Key('drawer-identity-panel')),
    );
    final identityDecoration = identity.decoration as BoxDecoration;
    expect(identityDecoration.color, AppColors.surface);
    expect(identityDecoration.border, isNotNull);

    final selectedDestination = tester.widget<Container>(
      find.byKey(const Key('drawer-destination-voice-selected')),
    );
    final selectedDecoration = selectedDestination.decoration as BoxDecoration;
    expect(selectedDecoration.color, AppColors.accentSoft);
    expect(selectedDecoration.border, isNotNull);
    expect(find.text('记录'), findsOneWidget);
    expect(find.text('待办'), findsOneWidget);
    expect(find.text('想法'), findsOneWidget);
    expect(find.text('查询'), findsNothing);
    expect(find.byKey(const Key('drawer-destination-settings')), findsNothing);
    expect(find.byKey(const Key('drawer-destination-ledger')), findsOneWidget);
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

    expect(find.text('想法'), findsOneWidget);

    await tester.tap(find.byKey(const Key('app-drawer-menu-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('drawer-destination-ideas-selected')),
        findsOneWidget);

    await tester.tap(find.byKey(const Key('drawer-destination-ideas')));
    await tester.pumpAndSettle();
  });

  testWidgets('keeps warm background at the app shell level', (tester) async {
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

    final shellScaffold = tester.widget<Scaffold>(
      find
          .descendant(
            of: find.byType(IdeaCaptureApp),
            matching: find.byType(Scaffold),
          )
          .first,
    );
    expect(shellScaffold.backgroundColor, AppColors.background);
    expect(find.byKey(const Key('app-background-fill')), findsOneWidget);
  });

  testWidgets('closes drawer before navigating to selected page',
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

    await tester.tap(find.byKey(const Key('app-drawer-menu-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('drawer-destination-voice')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('app-drawer-menu-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('drawer-destination-todos')));
    await tester.pump(const Duration(milliseconds: 80));

    expect(find.byType(VoicePage), findsOneWidget);
    expect(find.byType(TodoQueryPage), findsNothing);

    await tester.pumpAndSettle();

    expect(find.byType(VoicePage), findsNothing);
    expect(find.byType(TodoQueryPage), findsOneWidget);
    expect(find.byKey(const Key('app-side-drawer')), findsNothing);
  });
}
