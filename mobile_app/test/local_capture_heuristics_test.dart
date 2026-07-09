import 'package:flutter_test/flutter_test.dart';
import 'package:local_idea_capture/src/domain/local_capture_heuristics.dart';

void main() {
  test('asks for missing meeting fields', () {
    final result = LocalCaptureHeuristics().extract('我明天早晨要开个会，帮我记录一下');

    expect(result.intentType, CaptureIntentType.todo);
    expect(result.missingFields, containsAll(['start_at', 'location', 'topic']));
    expect(result.shouldSave, isFalse);
  });

  test('classifies the Wanli example as an idea', () {
    final result = LocalCaptureHeuristics().extract('万历十五年这本书和中国通史里的历史观点有出入，我现在要记录一下，以后查询相关的一些事情');

    expect(result.intentType, CaptureIntentType.idea);
    expect(result.title, '查询《万历十五年》和《中国通史》的历史观点差异');
    expect(result.ideaPayload?.tags, contains('历史'));
  });
}
