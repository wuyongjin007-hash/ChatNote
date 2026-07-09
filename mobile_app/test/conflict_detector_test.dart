import 'package:flutter_test/flutter_test.dart';
import 'package:local_idea_capture/src/domain/conflict_detector.dart';

void main() {
  test('detects overlapping todos', () {
    final existing = TodoTimeBlock(
      id: 'existing',
      title: '已有会议',
      startAt: DateTime.parse('2026-07-10T09:00:00+08:00'),
      endAt: DateTime.parse('2026-07-10T10:00:00+08:00'),
    );

    final candidate = TodoTimeBlock(
      id: 'candidate',
      title: '新会议',
      startAt: DateTime.parse('2026-07-10T09:30:00+08:00'),
      endAt: DateTime.parse('2026-07-10T10:30:00+08:00'),
    );

    expect(findTodoConflicts(candidate, [existing]), hasLength(1));
  });

  test('does not flag adjacent todos as conflicts', () {
    final existing = TodoTimeBlock(
      id: 'existing',
      title: '已有会议',
      startAt: DateTime.parse('2026-07-10T09:00:00+08:00'),
      endAt: DateTime.parse('2026-07-10T10:00:00+08:00'),
    );

    final candidate = TodoTimeBlock(
      id: 'candidate',
      title: '新会议',
      startAt: DateTime.parse('2026-07-10T10:00:00+08:00'),
      endAt: DateTime.parse('2026-07-10T11:00:00+08:00'),
    );

    expect(findTodoConflicts(candidate, [existing]), isEmpty);
  });
}
