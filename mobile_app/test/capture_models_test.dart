import 'package:flutter_test/flutter_test.dart';
import 'package:local_idea_capture/src/domain/capture_models.dart';

void main() {
  test('uses the idea summary when the model omits an idea title', () {
    final capture = CaptureResult.fromJson({
      'intent_type': 'idea',
      'confidence': 0.96,
      'title': '   ',
      'summary': '顶层摘要不应覆盖想法正文',
      'missing_fields': <String>[],
      'follow_up_question': null,
      'should_save': true,
      'todo_payload': null,
      'idea_payload': {
        'summary': '构建一个可自动归档的灵感记录应用',
        'source_hint': null,
        'tags': <String>['产品'],
      },
    });

    expect(capture.title, '构建一个可自动归档的灵感记录应用');
  });

  test('replaces a generic idea title with a concise summary fallback', () {
    final capture = CaptureResult.fromJson({
      'intent_type': 'idea',
      'confidence': 0.96,
      'title': '想法',
      'summary': '顶层摘要不应覆盖想法正文',
      'missing_fields': <String>['title'],
      'follow_up_question': '请为这个想法提炼一个标题。',
      'should_save': false,
      'todo_payload': null,
      'idea_payload': {
        'summary': '研究语音记录如何按项目与主题自动归档，并在后续查询中提供相关建议。',
        'source_hint': null,
        'tags': <String>['产品'],
      },
    });

    expect(capture.title, '研究语音记录如何按项目与主题自动归档');
    expect(capture.missingFields, isEmpty);
    expect(capture.followUpQuestion, isNull);
    expect(capture.shouldSave, isTrue);
  });

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

  test('parses multiple todo payloads from one model result', () {
    final capture = CaptureResult.fromJson({
      'intent_type': 'todo',
      'confidence': 0.98,
      'title': 'Two todos on July 11',
      'summary': 'Add a report todo and a shopping todo',
      'missing_fields': <String>[],
      'follow_up_question': null,
      'should_save': true,
      'todo_payload': null,
      'todo_payloads': [
        {
          'start_at': '2026-07-11T11:00:00+08:00',
          'end_at': '2026-07-11T11:30:00+08:00',
          'location': 'office',
          'topic': 'report',
          'reminder_at': null,
          'status': 'draft',
        },
        {
          'start_at': '2026-07-11T15:00:00+08:00',
          'end_at': '2026-07-11T15:30:00+08:00',
          'location': 'market',
          'topic': 'buy fruit',
          'reminder_at': null,
          'status': 'draft',
        },
      ],
      'idea_payload': null,
    });

    expect(capture.todoPayloads, hasLength(2));
    expect(capture.todoPayloads.first.startAt?.hour, 11);
    expect(capture.todoPayloads.last.location, 'market');
    expect(capture.effectiveTodoPayloads.map((todo) => todo.topic),
        ['report', 'buy fruit']);
  });
}
