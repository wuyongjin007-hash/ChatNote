import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_idea_capture/src/data/app_database.dart';
import 'package:local_idea_capture/src/features/ledger/ledger_page.dart';
import 'package:local_idea_capture/src/providers.dart';

void main() {
  testWidgets('shows monthly and daily ledger totals', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final now = DateTime.now();
    await database.createLedgerTransaction(
      id: 'expense',
      direction: 'expense',
      amountCents: 2500,
      categoryCode: 'food',
      note: '午饭',
      occurredAt: DateTime(now.year, now.month, 12, 12),
      source: 'typedText',
      rawText: '午饭25元',
    );
    await database.createLedgerTransaction(
      id: 'income',
      direction: 'income',
      amountCents: 800000,
      categoryCode: 'salary',
      note: '工资',
      occurredAt: DateTime(now.year, now.month, 10, 9),
      source: 'typedText',
      rawText: '工资8000',
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(database)],
      child: const MaterialApp(home: Scaffold(body: LedgerPage())),
    ));
    await tester.pumpAndSettle();

    expect(find.text('本月支出'), findsOneWidget);
    expect(find.text('¥25.00'), findsWidgets);
    expect(find.text('收入 ¥8000.00'), findsOneWidget);
    expect(find.text('结余 ¥7975.00'), findsOneWidget);
    expect(find.text('午饭'), findsOneWidget);
    expect(find.text('-¥25.00'), findsOneWidget);
    expect(find.text('+¥8000.00'), findsOneWidget);

    await tester.tap(find.text('午饭'));
    await tester.pumpAndSettle();
    expect(find.text('编辑账目'), findsOneWidget);
    expect(find.byKey(const Key('ledger-edit-save')), findsOneWidget);
    expect(find.byKey(const Key('ledger-edit-delete')), findsOneWidget);
  });
}
