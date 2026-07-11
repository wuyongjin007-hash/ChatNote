import 'package:flutter_test/flutter_test.dart';
import 'package:local_idea_capture/src/domain/capture_models.dart';

void main() {
  test('parses model todo times with timezone as local business time', () {
    final capture = CaptureResult.fromJson({
      'intent_type': 'todo',
      'confidence': 0.98,
      'title': 'Morning meeting',
      'summary': 'Meeting at 8',
      'missing_fields': <String>[],
      'follow_up_question': null,
      'should_save': true,
      'todo_payload': {
        'start_at': '2026-07-11T08:00:00+08:00',
        'end_at': '2026-07-11T08:30:00+08:00',
        'location': 'Room 3',
        'topic': 'Project',
        'reminder_at': null,
        'status': 'draft',
      },
      'idea_payload': null,
    });

    final todo = capture.todoPayload!;

    expect(todo.startAt!.hour, 8);
    expect(todo.startAt!.minute, 0);
    expect(todo.endAt!.hour, 8);
    expect(todo.endAt!.minute, 30);
    expect(todo.startAt!.isUtc, isFalse);
  });

  test('parses todo delete payload from model JSON', () {
    final capture = CaptureResult.fromJson({
      'intent_type': 'todoDelete',
      'confidence': 0.98,
      'title': '清空明天的待办',
      'summary': '删除明天的全部待办',
      'missing_fields': <String>[],
      'follow_up_question': null,
      'should_save': false,
      'todo_payload': null,
      'idea_payload': null,
      'todo_delete_payload': {
        'operation': 'clear',
        'date_from': '2026-07-12T00:00:00+08:00',
        'date_to': '2026-07-13T00:00:00+08:00',
        'time_from': null,
        'time_to': null,
        'keyword': null,
      },
    });

    expect(capture.intentType, CaptureIntentType.todoDelete);
    expect(capture.todoDeletePayload?.operation, TodoDeleteOperation.clear);
    expect(capture.todoDeletePayload?.dateFrom?.hour, 0);
    expect(capture.todoDeletePayload?.dateTo?.day, 13);
  });
}
