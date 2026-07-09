import 'capture_models.dart';
import 'local_capture_heuristics.dart';

typedef CaptureAgentCall = Future<CaptureResult> Function(CaptureAgentRequest request);

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

class CaptureConversationAgent {
  CaptureConversationAgent({
    required CaptureAgentCall capture,
    required LocalCaptureHeuristics heuristics,
  })  : _capture = capture,
        _heuristics = heuristics;

  final CaptureAgentCall _capture;
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
      missingFields: isFollowUp ? List.unmodifiable(_draft!.missingFields) : const [],
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
    return draft.missingFields.isNotEmpty || !draft.shouldSave;
  }
}
