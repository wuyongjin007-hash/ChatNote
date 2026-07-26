import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_idea_capture/src/data/app_database.dart';
import 'package:local_idea_capture/src/data/entry_repository.dart';
import 'package:local_idea_capture/src/domain/capture_models.dart';

void main() {
  test('saves a voice ledger capture into the ledger transaction table',
      () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final occurredAt = DateTime(2026, 7, 13, 12);
    final capture = CaptureResult(
      intentType: CaptureIntentType.ledger,
      confidence: 1,
      title: '记录支出',
      summary: '午饭 35 元',
      missingFields: const [],
      followUpQuestion: null,
      shouldSave: true,
      todoPayload: null,
      ideaPayload: null,
      ledgerPayload: LedgerPayload(
        direction: 'expense',
        amountCents: 3500,
        categoryCode: 'food',
        note: '午饭',
        occurredAt: occurredAt,
      ),
    );

    await EntryRepository(database).saveCapture(capture, '午饭花了35元');
    final rows = await database.listLedgerTransactions(
      DateTime(2026, 7, 1),
      DateTime(2026, 8, 1),
    );

    expect(rows, hasLength(1));
    expect(rows.single.amountCents, 3500);
    expect(rows.single.categoryCode, 'food');
    expect(rows.single.note, '午饭');
  });
}
