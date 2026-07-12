import 'dart:convert';

import '../data/entry_repository.dart';
import 'capture_draft_merger.dart';
import 'capture_models.dart';
import 'local_capture_heuristics.dart';

typedef CaptureAgentCall = Future<CaptureResult> Function(
    CaptureAgentRequest request);
typedef CaptureAgentStreamCall = Stream<CaptureAgentStreamEvent> Function(
    CaptureAgentRequest request);

class CaptureAgentRequest {
  const CaptureAgentRequest({
    required this.text,
    required this.conversation,
    required this.pendingDraft,
    required this.missingFields,
    required this.isFollowUp,
  });

  final String text;
  final List<Map<String, String>> conversation;
  final Map<String, dynamic>? pendingDraft;
  final List<String> missingFields;
  final bool isFollowUp;
}

class CaptureTurn {
  const CaptureTurn({
    required this.capture,
    required this.rawTranscript,
    required this.isFollowUp,
    required this.usedFallback,
  });

  final CaptureResult capture;
  final String rawTranscript;
  final bool isFollowUp;
  final bool usedFallback;
}

abstract class CaptureAgentStreamEvent {
  const CaptureAgentStreamEvent();
}

class CaptureAgentAssistantDelta extends CaptureAgentStreamEvent {
  const CaptureAgentAssistantDelta(this.text);

  final String text;
}

class CaptureAgentDone extends CaptureAgentStreamEvent {
  const CaptureAgentDone(this.capture);

  final CaptureResult capture;
}

class CaptureAgentTurnDone extends CaptureAgentStreamEvent {
  const CaptureAgentTurnDone(this.turn);

  final CaptureTurn turn;
}

class CaptureAgentFallback extends CaptureAgentStreamEvent {
  const CaptureAgentFallback(this.turn);

  final CaptureTurn turn;
}

class ConversationMessage {
  const ConversationMessage({
    required this.isUser,
    required this.text,
  });

  final bool isUser;
  final String text;

  Map<String, dynamic> toJson() => {
        'is_user': isUser,
        'text': text,
      };

  factory ConversationMessage.fromJson(Map<String, dynamic> json) {
    return ConversationMessage(
      isUser: json['is_user'] as bool? ?? false,
      text: json['text'] as String? ?? '',
    );
  }
}

class ConversationSnapshot {
  const ConversationSnapshot({
    required this.messages,
    required this.activeDraft,
    required this.state,
  });

  final List<ConversationMessage> messages;
  final CaptureResult? activeDraft;
  final CaptureSessionState state;
}

enum CaptureSessionState {
  idle,
  collecting,
  ready,
  cancelledRecoverable,
  completed
}

class CaptureConversationAgent {
  CaptureConversationAgent({
    required CaptureAgentCall capture,
    CaptureAgentStreamCall? captureStream,
    required LocalCaptureHeuristics heuristics,
    EntryRepository? repository,
  })  : _capture = capture,
        _captureStream = captureStream,
        _heuristics = heuristics,
        _repository = repository,
        _sessionId = _newSessionId();

  final CaptureAgentCall _capture;
  final CaptureAgentStreamCall? _captureStream;
  final LocalCaptureHeuristics _heuristics;
  final EntryRepository? _repository;
  final CaptureDraftMerger _merger = const CaptureDraftMerger();

  String _sessionId;
  final List<Map<String, String>> _memory = [];
  final List<String> _rawInputs = [];
  final List<ConversationMessage> _displayTranscript = [];
  final List<String> _lastQueryTodoIds = [];

  CaptureResult? _draft;
  CaptureSessionState _state = CaptureSessionState.idle;

  static const _maxMemoryRounds = 6;

  static String _newSessionId() {
    final now = DateTime.now().microsecondsSinceEpoch;
    return 'session_$now';
  }

  CaptureSessionState get state => _state;
  CaptureResult? get draft => _draft;
  String get sessionId => _sessionId;
  List<Map<String, String>> get memory => List.unmodifiable(_memory);
  List<String> get lastQueryTodoIds => List.unmodifiable(_lastQueryTodoIds);

  ConversationSnapshot get displaySnapshot => ConversationSnapshot(
        messages: List.unmodifiable(_displayTranscript),
        activeDraft: _draft,
        state: _state,
      );

  void appendDisplayMessage(ConversationMessage message) {
    _displayTranscript.add(message);
  }

  void updateLastDisplayMessage(String text) {
    if (_displayTranscript.isNotEmpty) {
      final last = _displayTranscript.last;
      _displayTranscript[_displayTranscript.length - 1] =
          ConversationMessage(isUser: last.isUser, text: text);
    }
  }

  void rememberLastQueryTodoIds(Iterable<String> ids) {
    _lastQueryTodoIds
      ..clear()
      ..addAll(ids);
  }

  void clearLastQueryTodoIds() {
    _lastQueryTodoIds.clear();
  }

  bool get _hasPendingDraft {
    return _state == CaptureSessionState.collecting ||
        _state == CaptureSessionState.ready;
  }

  Future<CaptureTurn> submitText(String text) async {
    final normalized = text.trim();
    final isFollowUp = _hasPendingDraft;

    if (_isNewTopicRequest(normalized)) {
      reset();
    }

    final request = CaptureAgentRequest(
      text: normalized,
      conversation: List.unmodifiable(_memory),
      pendingDraft: isFollowUp ? _draft?.toJson() : null,
      missingFields:
          isFollowUp ? List.unmodifiable(_draft!.missingFields) : const [],
      isFollowUp: isFollowUp,
    );

    CaptureResult capture;
    var usedFallback = false;
    try {
      capture = await _capture(request);
    } catch (_) {
      capture = _heuristics.extract(normalized);
      usedFallback = true;
    }

    if (capture.intentType == CaptureIntentType.todoQuery) {
      _storeMemory(normalized, capture.followUpQuestion ?? capture.summary);
      return CaptureTurn(
        capture: capture,
        rawTranscript: normalized,
        isFollowUp: false,
        usedFallback: usedFallback,
      );
    }

    final merged = _resolveCapture(capture, isFollowUp);
    final turn = _finishTurn(
      normalized: normalized,
      capture: merged,
      isFollowUp: isFollowUp,
      usedFallback: usedFallback,
      assistantText: merged.followUpQuestion ?? merged.summary,
    );
    await _persistSession('active');
    return turn;
  }

  Stream<CaptureAgentStreamEvent> submitTextStream(String text) async* {
    final normalized = text.trim();
    final isFollowUp = _hasPendingDraft;

    if (_isNewTopicRequest(normalized)) {
      reset();
    }

    final request = CaptureAgentRequest(
      text: normalized,
      conversation: List.unmodifiable(_memory),
      pendingDraft: isFollowUp ? _draft?.toJson() : null,
      missingFields:
          isFollowUp ? List.unmodifiable(_draft!.missingFields) : const [],
      isFollowUp: isFollowUp,
    );

    final assistantBuffer = StringBuffer();
    try {
      final stream = _captureStream;
      CaptureResult capture;
      if (stream == null) {
        capture = await _capture(request);
      } else {
        CaptureResult? streamedCapture;
        await for (final event in stream(request)) {
          if (event is CaptureAgentAssistantDelta) {
            assistantBuffer.write(event.text);
            yield event;
          } else if (event is CaptureAgentDone) {
            streamedCapture = event.capture;
          }
        }
        if (streamedCapture == null) {
          throw StateError('stream ended without capture result');
        }
        capture = streamedCapture;
      }

      if (capture.intentType == CaptureIntentType.todoQuery) {
        _storeMemory(
            normalized,
            assistantBuffer.toString().isNotEmpty
                ? assistantBuffer.toString()
                : capture.followUpQuestion ?? capture.summary);
        yield CaptureAgentTurnDone(CaptureTurn(
          capture: capture,
          rawTranscript: normalized,
          isFollowUp: false,
          usedFallback: false,
        ));
        return;
      }

      final merged = _resolveCapture(capture, isFollowUp);
      final turn = _finishTurn(
        normalized: normalized,
        capture: merged,
        isFollowUp: isFollowUp,
        usedFallback: false,
        assistantText: assistantBuffer.toString(),
      );
      yield CaptureAgentTurnDone(turn);
    } catch (_) {
      final capture = _heuristics.extract(normalized);

      if (capture.intentType == CaptureIntentType.todoQuery) {
        _storeMemory(normalized, capture.followUpQuestion ?? capture.summary);
        yield CaptureAgentFallback(CaptureTurn(
          capture: capture,
          rawTranscript: normalized,
          isFollowUp: false,
          usedFallback: true,
        ));
        return;
      }

      final merged = _resolveCapture(capture, isFollowUp);
      final turn = _finishTurn(
        normalized: normalized,
        capture: merged,
        isFollowUp: isFollowUp,
        usedFallback: true,
        assistantText: capture.followUpQuestion ?? capture.summary,
      );
      yield CaptureAgentFallback(turn);
    }
  }

  void reset() {
    _draft = null;
    _memory.clear();
    _rawInputs.clear();
    _displayTranscript.clear();
    _lastQueryTodoIds.clear();
    _state = CaptureSessionState.idle;
    _sessionId = _newSessionId();
  }

  Future<void> cancelDraft() async {
    if (_state != CaptureSessionState.collecting &&
        _state != CaptureSessionState.ready) {
      return;
    }

    final now = DateTime.now();
    final draft = _draft;
    if (draft == null) {
      return;
    }

    _state = CaptureSessionState.cancelledRecoverable;

    await _persistSession(
      'cancelledRecoverable',
      recoverableDraftJson: jsonEncode(draft.toJson()),
      expiresAt: now.add(const Duration(minutes: 30)).toIso8601String(),
    );

    _draft = null;
    _memory.clear();
    _rawInputs.clear();
  }

  Future<bool> restoreSession() async {
    if (_repository == null) {
      return false;
    }

    final row = await _repository.loadLatestRecoverableSession();
    if (row == null || !row.isRecoverable) {
      return false;
    }

    final draft = row.parseRecoverableDraft();
    final conversation = row.parseConversation();

    if (draft == null) {
      return false;
    }

    _sessionId = row.id;
    _draft = draft;
    _memory
      ..clear()
      ..addAll(conversation);
    _rawInputs
      ..clear()
      ..add(row.rawText);
    _state = CaptureSessionState.collecting;

    await _repository.deleteSession(row.id);
    return true;
  }

  Future<void> completeDraft() async {
    _draft = null;
    _memory.clear();
    _rawInputs.clear();
    _lastQueryTodoIds.clear();
    _state = CaptureSessionState.completed;
    await _persistSession('completed');
  }

  Future<void> clearMemory() async {
    _draft = null;
    _memory.clear();
    _rawInputs.clear();
    _displayTranscript.clear();
    _lastQueryTodoIds.clear();
    _state = CaptureSessionState.idle;
    if (_repository != null) {
      await _repository.deleteSession(_sessionId);
    }
    _sessionId = _newSessionId();
  }

  CaptureResult _resolveCapture(CaptureResult capture, bool isFollowUp) {
    if (!isFollowUp || _draft == null) {
      _draft = capture;
      _state = capture.shouldSave
          ? CaptureSessionState.ready
          : CaptureSessionState.collecting;
      return capture;
    }

    final merged = _merger.merge(_draft!, capture);
    _draft = merged;
    _state = merged.shouldSave
        ? CaptureSessionState.ready
        : CaptureSessionState.collecting;
    return merged;
  }

  CaptureTurn _finishTurn({
    required String normalized,
    required CaptureResult capture,
    required bool isFollowUp,
    required bool usedFallback,
    required String assistantText,
  }) {
    _storeMemory(normalized, assistantText);

    return CaptureTurn(
      capture: capture,
      rawTranscript: _rawInputs.join('\n'),
      isFollowUp: isFollowUp,
      usedFallback: usedFallback,
    );
  }

  void _storeMemory(String userText, String assistantText) {
    _rawInputs.add(userText);
    _memory.add({'role': 'user', 'content': userText});
    _memory.add({
      'role': 'assistant',
      'content': assistantText.trim().isEmpty ? '...' : assistantText,
    });

    while (_memory.length > _maxMemoryRounds * 2) {
      _memory.removeAt(0);
      _memory.removeAt(0);
    }
  }

  bool _isNewTopicRequest(String text) {
    final lower = text.trim().toLowerCase();
    final newTopicPhrases = [
      '另外再记',
      '新建一个待办',
      '新待办',
      '新的待办',
      '再记一个',
      '再记录一个',
      '新建待办',
      '重新记录',
      '记一个新的',
    ];
    return newTopicPhrases.any((phrase) => lower.contains(phrase));
  }

  Future<void> _persistSession(
    String status, {
    String? recoverableDraftJson,
    String? expiresAt,
  }) async {
    if (_repository == null) {
      return;
    }
    final now = DateTime.now().toIso8601String();
    try {
      await _repository.upsertSession(
        id: _sessionId,
        rawText: _rawInputs.join('\n'),
        status: status,
        createdAt: now,
        updatedAt: now,
        conversationJson: jsonEncode(_memory),
        activeDraftJson: _draft != null ? jsonEncode(_draft!.toJson()) : null,
        recoverableDraftJson: recoverableDraftJson,
        expiresAt: expiresAt,
      );
    } catch (_) {
      // persistence is best-effort; don't crash the agent
    }
  }
}
