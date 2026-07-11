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

class CaptureConversationAgent {
  CaptureConversationAgent({
    required CaptureAgentCall capture,
    CaptureAgentStreamCall? captureStream,
    required LocalCaptureHeuristics heuristics,
  })  : _capture = capture,
        _captureStream = captureStream,
        _heuristics = heuristics;

  final CaptureAgentCall _capture;
  final CaptureAgentStreamCall? _captureStream;
  final LocalCaptureHeuristics _heuristics;
  final List<Map<String, String>> _memory = [];
  final List<String> _rawInputs = [];

  CaptureResult? _draft;

  Future<CaptureTurn> submitText(String text) async {
    final normalized = text.trim();
    final isFollowUp = _hasPendingDraft;

    if (!isFollowUp && _draft != null) {
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

    _draft = capture;
    _rawInputs.add(normalized);
    _memory
      ..add({'role': 'user', 'content': normalized})
      ..add({
        'role': 'assistant',
        'content': capture.followUpQuestion ?? capture.summary,
      });

    return CaptureTurn(
      capture: capture,
      rawTranscript: _rawInputs.join('\n'),
      isFollowUp: isFollowUp,
      usedFallback: usedFallback,
    );
  }

  Stream<CaptureAgentStreamEvent> submitTextStream(String text) async* {
    final normalized = text.trim();
    final isFollowUp = _hasPendingDraft;

    if (!isFollowUp && _draft != null) {
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

      final turn = _finishTurn(
        normalized: normalized,
        capture: capture,
        isFollowUp: isFollowUp,
        usedFallback: false,
        assistantText: assistantBuffer.toString(),
      );
      yield CaptureAgentTurnDone(turn);
    } catch (_) {
      final capture = _heuristics.extract(normalized);
      final turn = _finishTurn(
        normalized: normalized,
        capture: capture,
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
  }

  bool get _hasPendingDraft {
    final draft = _draft;
    if (draft == null) {
      return false;
    }
    if (draft.intentType == CaptureIntentType.todoDelete) {
      return false;
    }
    return draft.missingFields.isNotEmpty || !draft.shouldSave;
  }

  CaptureTurn _finishTurn({
    required String normalized,
    required CaptureResult capture,
    required bool isFollowUp,
    required bool usedFallback,
    required String assistantText,
  }) {
    _draft = capture;
    _rawInputs.add(normalized);
    _memory
      ..add({'role': 'user', 'content': normalized})
      ..add({
        'role': 'assistant',
        'content': assistantText.trim().isEmpty
            ? capture.followUpQuestion ?? capture.summary
            : assistantText,
      });

    return CaptureTurn(
      capture: capture,
      rawTranscript: _rawInputs.join('\n'),
      isFollowUp: isFollowUp,
      usedFallback: usedFallback,
    );
  }
}
