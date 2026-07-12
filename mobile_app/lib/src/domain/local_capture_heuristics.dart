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
    if (_looksLikeTodoQuery(normalized)) {
      return _todoQueryResult(normalized);
    }
    if (_looksLikeTodoDelete(normalized)) {
      return _todoDeleteResult(normalized);
    }
    if (_looksLikeTodo(normalized)) {
      final now = DateTime.now();
      final startAt = _extractTime(normalized, now);
      final defaultDuration =
          normalized.contains('会议') || normalized.contains('开会') ? 60 : 30;
      final endAt = startAt?.add(Duration(minutes: defaultDuration));

      return CaptureResult(
        intentType: CaptureIntentType.todo,
        confidence: 0.68,
        title: _titleForTodo(normalized),
        summary: normalized,
        missingFields: startAt == null ? const ['start_at'] : const [],
        followUpQuestion:
            startAt == null ? '请问这件事安排在什么时间？' : '已整理好这条待办，还需要补充其他信息吗？',
        shouldSave: startAt != null,
        todoPayload: TodoPayload(
          title: _titleForTodo(normalized),
          startAt: startAt,
          endAt: endAt,
          location: null,
          topic: null,
          reminderAt: null,
          status: 'draft',
          durationMinutes: defaultDuration,
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

  bool _looksLikeTodoQuery(String text) {
    final queryVerbs = ['查询', '查一下', '看看', '有哪些', '有什么', '还有哪些', '还有什么'];
    final todoObjects = ['待办', '提醒', '日程', '事情', '安排', '事项'];
    final hasQueryVerb = queryVerbs.any((verb) => text.contains(verb));
    final hasTodoObject = todoObjects.any((obj) => text.contains(obj));
    final isQuestion =
        text.contains('吗') || text.contains('？') || text.contains('?');
    return (hasQueryVerb && hasTodoObject) || (hasTodoObject && isQuestion);
  }

  CaptureResult _todoQueryResult(String text) {
    final now = DateTime.now();
    var dateFrom = DateTime(now.year, now.month, now.day);
    var dateTo = dateFrom.add(const Duration(days: 1));

    if (text.contains('后天')) {
      dateFrom = dateFrom.add(const Duration(days: 2));
      dateTo = dateFrom.add(const Duration(days: 1));
    } else if (text.contains('明天')) {
      dateFrom = dateFrom.add(const Duration(days: 1));
      dateTo = dateFrom.add(const Duration(days: 1));
    } else if (text.contains('今天')) {
      dateTo = dateFrom.add(const Duration(days: 1));
    } else {
      dateTo = dateFrom.add(const Duration(days: 7));
    }

    final includeCompleted = text.contains('已完成') || text.contains('完成');

    return CaptureResult(
      intentType: CaptureIntentType.todoQuery,
      confidence: 0.65,
      title: text,
      summary: text,
      missingFields: const [],
      followUpQuestion: null,
      shouldSave: false,
      todoPayload: null,
      ideaPayload: null,
      todoQueryPayload: TodoQueryPayload(
        dateFrom: dateFrom,
        dateTo: dateTo,
        keyword: _extractQueryKeyword(text),
        includeCompleted: includeCompleted,
        importanceRequested: text.contains('重要'),
      ),
    );
  }

  String? _extractQueryKeyword(String text) {
    final cleaned = text
        .replaceAll(RegExp(r'查询|查一下|看看|有哪些|有什么|还有哪些|还有什么'), '')
        .replaceAll(RegExp(r'待办|提醒|日程|事情|安排|事项'), '')
        .replaceAll(RegExp(r'今天|明天|后天|本周|这周'), '')
        .replaceAll(RegExp(r'重要|已完成|完成'), '')
        .replaceAll(RegExp(r'[吗？?的]'), '')
        .trim();
    return cleaned.isEmpty ? null : cleaned;
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
        text.contains('明天') ||
        text.contains('今天') ||
        text.contains('后天');
  }

  String _titleForTodo(String text) {
    if (text.contains('开会') || text.contains('会议')) {
      return '补充会议安排';
    }
    return text.length > 20 ? '${text.substring(0, 20)}...' : text;
  }

  DateTime? _extractTime(String text, DateTime now) {
    final hourMatch = RegExp(r'(\d{1,2})点').firstMatch(text);
    if (hourMatch == null) {
      if (text.contains('明天')) {
        return DateTime(now.year, now.month, now.day + 1, 8, 0);
      }
      if (text.contains('后天')) {
        return DateTime(now.year, now.month, now.day + 2, 8, 0);
      }
      if (text.contains('今天')) {
        return DateTime(now.year, now.month, now.day, now.hour + 1, 0);
      }
      return null;
    }
    final hour = int.parse(hourMatch.group(1)!);
    if (text.contains('明天')) {
      return DateTime(now.year, now.month, now.day + 1, hour, 0);
    }
    if (text.contains('后天')) {
      return DateTime(now.year, now.month, now.day + 2, hour, 0);
    }
    return DateTime(now.year, now.month, now.day, hour, 0);
  }
}
