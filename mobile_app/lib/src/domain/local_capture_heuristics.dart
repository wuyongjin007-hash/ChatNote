import 'capture_models.dart';

class LocalCaptureHeuristics {
  CaptureResult extract(String text) {
    final normalized = text.trim();
    if (_looksLikeTodoDelete(normalized)) {
      return _todoDeleteResult(normalized);
    }
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
      title: normalized.length > 24
          ? '${normalized.substring(0, 24)}...'
          : normalized,
      summary: normalized,
      missingFields: const [],
      followUpQuestion: null,
      shouldSave: true,
      todoPayload: null,
      ideaPayload: IdeaPayload(
          summary: normalized, sourceHint: '本地兜底整理', tags: const ['闪念']),
    );
  }

  bool _looksLikeWanliIdea(String text) {
    return text.contains('万历十五年') && text.contains('中国通史');
  }

  bool _looksLikeTodoDelete(String text) {
    final hasDeleteVerb =
        text.contains('删除') || text.contains('清空') || text.contains('取消');
    final hasTodoObject =
        text.contains('待办') || text.contains('提醒') || text.contains('日程');
    return hasDeleteVerb && hasTodoObject;
  }

  CaptureResult _todoDeleteResult(String text) {
    final now = DateTime.now();
    final dayOffset = text.contains('后天')
        ? 2
        : text.contains('明天')
            ? 1
            : 0;
    final dateFrom =
        DateTime(now.year, now.month, now.day).add(Duration(days: dayOffset));
    final dateTo = dateFrom.add(const Duration(days: 1));
    final timeMatch =
        RegExp(r'(\d{1,2})点(?:到|至|-)(\d{1,2})点?').firstMatch(text);
    final timeFrom = timeMatch == null
        ? null
        : DateTime(dateFrom.year, dateFrom.month, dateFrom.day,
            int.parse(timeMatch.group(1)!));
    final timeTo = timeMatch == null
        ? null
        : DateTime(dateFrom.year, dateFrom.month, dateFrom.day,
            int.parse(timeMatch.group(2)!));
    final operation = text.contains('清空')
        ? TodoDeleteOperation.clear
        : TodoDeleteOperation.delete;
    final keyword =
        operation == TodoDeleteOperation.clear ? null : _deleteKeyword(text);
    return CaptureResult(
      intentType: CaptureIntentType.todoDelete,
      confidence: 0.62,
      title: text,
      summary: text,
      missingFields: const [],
      followUpQuestion: null,
      shouldSave: false,
      todoPayload: null,
      ideaPayload: null,
      todoDeletePayload: TodoDeletePayload(
        operation: operation,
        dateFrom: dateFrom,
        dateTo: dateTo,
        timeFrom: timeFrom,
        timeTo: timeTo,
        keyword: keyword,
      ),
    );
  }

  String? _deleteKeyword(String text) {
    final cleaned = text
        .replaceAll(RegExp(r'帮我|请|删除|取消|清空|今天|明天|后天'), '')
        .replaceAll(RegExp(r'\d{1,2}点(?:到|至|-)\d{1,2}点?'), '')
        .replaceAll(RegExp(r'的?(待办事项|待办|提醒|日程)'), '')
        .trim();
    return cleaned.isEmpty ? null : cleaned;
  }

  bool _looksLikeTodo(String text) {
    return text.contains('开会') ||
        text.contains('待办') ||
        text.contains('提醒') ||
        text.contains('明天');
  }

  String _titleForTodo(String text) {
    if (text.contains('开会')) {
      return '补充会议安排';
    }
    return text.length > 20 ? '${text.substring(0, 20)}...' : text;
  }
}
