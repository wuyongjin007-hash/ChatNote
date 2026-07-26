import 'capture_models.dart';

class CaptureDraftMerger {
  const CaptureDraftMerger();

  CaptureResult merge(CaptureResult previous, CaptureResult incoming) {
    if (incoming.intentType == CaptureIntentType.unclear) {
      return _preserveWithFollowUp(previous, incoming);
    }

    if (incoming.intentType == CaptureIntentType.todoQuery) {
      return incoming;
    }

    if (incoming.intentType == CaptureIntentType.todoDelete) {
      return incoming;
    }

    if (incoming.intentType == CaptureIntentType.ledger) {
      return incoming;
    }

    final isCorrection = incoming.interactionMode == InteractionMode.correction;
    final updatedFields = incoming.updatedFields.toSet();
    final isSupplement = incoming.interactionMode == InteractionMode.supplement;

    final mergedTitle = _mergeField(
      previous: previous.title,
      incoming: incoming.title,
      isCorrection: isCorrection,
      fieldUpdated: updatedFields.contains('title'),
      defaultValue: '未命名记录',
    );

    final mergedSummary = _mergeField(
      previous: previous.summary,
      incoming: incoming.summary,
      isCorrection: isCorrection,
      fieldUpdated: updatedFields.contains('summary'),
    );

    final mergedMissingFields = _resolveMissingFields(
      previous: previous.missingFields,
      incoming: incoming.missingFields,
      isSupplementOrCorrection: isSupplement || isCorrection,
      isNewRequest: incoming.interactionMode == InteractionMode.newRequest,
    );

    final mergedShouldSave = incoming.shouldSave || previous.shouldSave;

    final mergedTodo = _mergeTodoPayload(
      previous: previous.todoPayload,
      incoming: incoming.todoPayload,
      isCorrection: isCorrection,
      updatedFields: updatedFields,
    );

    final mergedTodos = _mergeTodoPayloadsList(
      previous: previous.effectiveTodoPayloads,
      incoming: incoming.effectiveTodoPayloads,
      isCorrection: isCorrection,
      updatedFields: updatedFields,
    );

    final mergedIdea = incoming.ideaPayload ?? previous.ideaPayload;

    final mergedFollowUp = _resolveFollowUp(
      previous: previous.followUpQuestion,
      incoming: incoming.followUpQuestion,
      incomingShouldSave: incoming.shouldSave,
    );

    final merged = CaptureResult(
      intentType: incoming.intentType == CaptureIntentType.unclear
          ? previous.intentType
          : incoming.intentType,
      confidence: incoming.confidence,
      title: mergedTitle ?? previous.title,
      summary: mergedSummary ?? incoming.summary,
      missingFields: mergedMissingFields,
      followUpQuestion: mergedFollowUp,
      shouldSave: mergedShouldSave,
      todoPayload: mergedTodos.isNotEmpty ? null : mergedTodo,
      todoPayloads: mergedTodos,
      ideaPayload: mergedIdea,
      todoDeletePayload: incoming.todoDeletePayload,
      todoQueryPayload: incoming.todoQueryPayload,
      interactionMode: incoming.interactionMode,
      updatedFields: incoming.updatedFields,
    );

    return _validateDraft(merged);
  }

  CaptureResult _preserveWithFollowUp(
      CaptureResult previous, CaptureResult incoming) {
    return CaptureResult(
      intentType: previous.intentType,
      confidence: incoming.confidence,
      title: previous.title,
      summary: previous.summary,
      missingFields: previous.missingFields,
      followUpQuestion: incoming.followUpQuestion ?? previous.followUpQuestion,
      shouldSave: previous.shouldSave,
      todoPayload: previous.todoPayload,
      todoPayloads: previous.todoPayloads,
      ideaPayload: previous.ideaPayload,
      todoDeletePayload: previous.todoDeletePayload,
      interactionMode: incoming.interactionMode,
      updatedFields: incoming.updatedFields,
    );
  }

  List<String> _resolveMissingFields({
    required List<String> previous,
    required List<String> incoming,
    required bool isSupplementOrCorrection,
    required bool isNewRequest,
  }) {
    if (isNewRequest) {
      return incoming;
    }

    if (isSupplementOrCorrection && incoming.isEmpty) {
      return incoming;
    }

    if (incoming.isNotEmpty) {
      return incoming;
    }

    return previous;
  }

  String? _resolveFollowUp({
    required String? previous,
    required String? incoming,
    required bool incomingShouldSave,
  }) {
    if (incomingShouldSave) {
      return null;
    }
    return incoming ?? previous;
  }

  CaptureResult _validateDraft(CaptureResult draft) {
    if (draft.intentType != CaptureIntentType.todo) {
      return draft;
    }

    final primaryTodo = draft.todoPayload ??
        (draft.todoPayloads.isNotEmpty ? draft.todoPayloads.first : null);
    if (primaryTodo == null) {
      return draft;
    }

    final hasTime = primaryTodo.startAt != null;

    if (!hasTime) {
      final missing = <String>['start_at'];
      return CaptureResult(
        intentType: draft.intentType,
        confidence: draft.confidence,
        title: draft.title,
        summary: draft.summary,
        missingFields: missing,
        followUpQuestion: '请问这件事安排在什么时间？',
        shouldSave: false,
        todoPayload: draft.todoPayload,
        todoPayloads: draft.todoPayloads,
        ideaPayload: draft.ideaPayload,
        todoDeletePayload: draft.todoDeletePayload,
        todoQueryPayload: draft.todoQueryPayload,
        interactionMode: draft.interactionMode,
        updatedFields: draft.updatedFields,
      );
    }

    return CaptureResult(
      intentType: draft.intentType,
      confidence: draft.confidence,
      title: draft.title,
      summary: draft.summary,
      missingFields: const [],
      followUpQuestion: null,
      shouldSave: true,
      todoPayload: draft.todoPayload,
      todoPayloads: draft.todoPayloads,
      ideaPayload: draft.ideaPayload,
      todoDeletePayload: draft.todoDeletePayload,
      todoQueryPayload: draft.todoQueryPayload,
      interactionMode: draft.interactionMode,
      updatedFields: draft.updatedFields,
    );
  }

  String? _mergeField({
    required String? previous,
    required String? incoming,
    required bool isCorrection,
    required bool fieldUpdated,
    String? defaultValue,
  }) {
    if (isCorrection &&
        fieldUpdated &&
        incoming != null &&
        incoming.isNotEmpty) {
      return incoming;
    }

    if (incoming != null &&
        incoming.isNotEmpty &&
        incoming != defaultValue &&
        previous != incoming) {
      return incoming;
    }

    return previous;
  }

  TodoPayload? _mergeTodoPayload({
    required TodoPayload? previous,
    required TodoPayload? incoming,
    required bool isCorrection,
    required Set<String> updatedFields,
  }) {
    if (previous == null) {
      return incoming;
    }
    if (incoming == null) {
      return previous;
    }

    final startAt = _mergeDateTimeField(
      previous: previous.startAt,
      incoming: incoming.startAt,
      isCorrection: isCorrection,
      fieldUpdated: updatedFields.contains('start_at'),
    );

    final durationMinutes = _mergeIntField(
      previous: previous.durationMinutes,
      incoming: incoming.durationMinutes,
      isCorrection: isCorrection,
      fieldUpdated: updatedFields.contains('duration_minutes'),
    );

    final endAt = _resolveEndAt(
      startAt: startAt,
      durationMinutes: durationMinutes,
      previousEndAt: previous.endAt,
      incomingEndAt: incoming.endAt,
      isCorrection: isCorrection,
      endAtUpdated: updatedFields.contains('end_at'),
    );

    final location = _mergeNullableField<String>(
      previous: previous.location,
      incoming: incoming.location,
      isCorrection: isCorrection,
      fieldUpdated: updatedFields.contains('location'),
    );

    final topic = _mergeNullableField<String>(
      previous: previous.topic,
      incoming: incoming.topic,
      isCorrection: isCorrection,
      fieldUpdated: updatedFields.contains('topic'),
    );

    final reminderAt = _mergeDateTimeField(
      previous: previous.reminderAt,
      incoming: incoming.reminderAt,
      isCorrection: isCorrection,
      fieldUpdated: updatedFields.contains('reminder_at'),
    );

    final title = _mergeField(
      previous: previous.title,
      incoming: incoming.title,
      isCorrection: isCorrection,
      fieldUpdated: updatedFields.contains('title'),
    );

    final summary = _mergeField(
      previous: previous.summary,
      incoming: incoming.summary,
      isCorrection: isCorrection,
      fieldUpdated: updatedFields.contains('summary'),
    );

    return TodoPayload(
      title: title,
      summary: summary,
      startAt: startAt,
      endAt: endAt,
      location: location,
      topic: topic,
      reminderAt: reminderAt,
      status: incoming.status.isNotEmpty ? incoming.status : previous.status,
      durationMinutes: durationMinutes,
    );
  }

  List<TodoPayload> _mergeTodoPayloadsList({
    required List<TodoPayload> previous,
    required List<TodoPayload> incoming,
    required bool isCorrection,
    required Set<String> updatedFields,
  }) {
    if (incoming.isEmpty) {
      return previous;
    }
    if (previous.isEmpty) {
      return incoming;
    }

    if (previous.length != incoming.length) {
      return incoming;
    }

    final merged = <TodoPayload>[];
    for (var index = 0; index < previous.length; index++) {
      final mergedItem = _mergeTodoPayload(
        previous: previous[index],
        incoming: incoming[index],
        isCorrection: isCorrection,
        updatedFields: updatedFields,
      );
      if (mergedItem != null) {
        merged.add(mergedItem);
      }
    }
    return merged;
  }

  DateTime? _mergeDateTimeField({
    required DateTime? previous,
    required DateTime? incoming,
    required bool isCorrection,
    required bool fieldUpdated,
  }) {
    if (isCorrection && fieldUpdated) {
      return incoming;
    }
    return incoming ?? previous;
  }

  int? _mergeIntField({
    required int? previous,
    required int? incoming,
    required bool isCorrection,
    required bool fieldUpdated,
  }) {
    if (isCorrection && fieldUpdated) {
      return incoming;
    }
    return incoming ?? previous;
  }

  T? _mergeNullableField<T>({
    required T? previous,
    required T? incoming,
    required bool isCorrection,
    required bool fieldUpdated,
  }) {
    if (isCorrection && fieldUpdated) {
      return incoming;
    }
    return incoming ?? previous;
  }

  DateTime? _resolveEndAt({
    required DateTime? startAt,
    required int? durationMinutes,
    required DateTime? previousEndAt,
    required DateTime? incomingEndAt,
    required bool isCorrection,
    required bool endAtUpdated,
  }) {
    if (startAt != null && durationMinutes != null) {
      return startAt.add(Duration(minutes: durationMinutes));
    }

    if (isCorrection && endAtUpdated) {
      return incomingEndAt;
    }

    return incomingEndAt ?? previousEndAt;
  }
}
