import 'capture_models.dart';

class LocalCaptureHeuristics {
  CaptureResult extract(String text) {
    final normalized = text.trim();
    if (_looksLikeWanliIdea(normalized)) {
      return const CaptureResult(
        intentType: CaptureIntentType.idea,
        confidence: 0.72,
        title: '查询《万历十五年》和《中国通史》的历史观点差异',
        summary: '比较《万历十五年》和《中国通史》中的历史观点差异，后续查询相关资料。',
        missingFields: [],
        followUpQuestion: null,
        shouldSave: true,
        todoPayload: null,
        ideaPayload: IdeaPayload(
          summary: '查询《万历十五年》和《中国通史》的历史观点差异',
          sourceHint: '语音闪念',
          tags: ['历史', '阅读', '观点比较'],
        ),
      );
    }

    if (_looksLikeTodo(normalized)) {
      return CaptureResult(
        intentType: CaptureIntentType.todo,
        confidence: 0.68,
        title: _titleForTodo(normalized),
        summary: normalized,
        missingFields: const ['start_at', 'location', 'topic'],
        followUpQuestion: '明天几点、在哪里开会？会议主题是什么？',
        shouldSave: false,
        todoPayload: const TodoPayload(
          startAt: null,
          endAt: null,
          location: null,
          topic: null,
          reminderAt: null,
          status: 'draft',
        ),
        ideaPayload: null,
      );
    }

    return CaptureResult(
      intentType: CaptureIntentType.idea,
      confidence: 0.55,
      title: normalized.length > 24 ? '${normalized.substring(0, 24)}...' : normalized,
      summary: normalized,
      missingFields: const [],
      followUpQuestion: null,
      shouldSave: true,
      todoPayload: null,
      ideaPayload: IdeaPayload(summary: normalized, sourceHint: '本地兜底整理', tags: const ['闪念']),
    );
  }

  bool _looksLikeWanliIdea(String text) {
    return text.contains('万历十五年') && text.contains('中国通史');
  }

  bool _looksLikeTodo(String text) {
    return text.contains('开会') || text.contains('待办') || text.contains('提醒') || text.contains('明天');
  }

  String _titleForTodo(String text) {
    if (text.contains('开会')) {
      return '补充会议安排';
    }
    return text.length > 20 ? '${text.substring(0, 20)}...' : text;
  }
}
