import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_database.dart';
import '../../domain/capture_conversation_agent.dart';
import '../../domain/capture_models.dart';
import '../../domain/conflict_detector.dart';
import '../../providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/page_header.dart';

class VoicePage extends ConsumerStatefulWidget {
  const VoicePage({super.key});

  @override
  ConsumerState<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends ConsumerState<VoicePage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_ChatMessage>[
    const _ChatMessage.assistant('按住麦克风说出待办或闪念。也可以先用文字输入测试。'),
  ];

  CaptureResult? _draft;
  String? _rawText;
  List<TodoTimeBlock> _conflicts = const [];
  List<EntryListItem> _deleteMatches = const [];
  _VoiceStage _voiceStage = _VoiceStage.idle;
  bool _aiBusy = false;
  bool _recordingWillCancel = false;
  bool _textInputMode = false;

  bool get _isInputLocked =>
      _aiBusy ||
      _voiceStage == _VoiceStage.recognizing ||
      _voiceStage == _VoiceStage.recording;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_refreshTextInput);
  }

  @override
  void dispose() {
    _textController.removeListener(_refreshTextInput);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _refreshTextInput() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _startRecording() async {
    setState(() {
      _voiceStage = _VoiceStage.recording;
      _recordingWillCancel = false;
    });
    try {
      await ref.read(speechChannelProvider).startRecognition();
    } catch (error) {
      setState(() => _voiceStage = _VoiceStage.idle);
      _addAssistant('语音识别未就绪：$error。你可以先用文字输入。');
    }
  }

  Future<void> _stopRecording() async {
    if (_recordingWillCancel) {
      await ref.read(speechChannelProvider).cancelRecognition();
      setState(() {
        _voiceStage = _VoiceStage.idle;
        _recordingWillCancel = false;
      });
      return;
    }

    late final int recognizingIndex;
    setState(() {
      _voiceStage = _VoiceStage.recognizing;
      _messages.add(const _ChatMessage.recognizing());
      _messages.add(const _ChatMessage.assistantTyping());
      recognizingIndex = _messages.length - 2;
    });
    _scrollToBottom();

    try {
      final text = await ref.read(speechChannelProvider).stopRecognition();
      final normalized = text.trim();
      if (normalized.isEmpty) {
        _replaceMessage(recognizingIndex, const _ChatMessage.user('未识别到语音内容'));
        _removeAssistantTyping();
        setState(() => _voiceStage = _VoiceStage.error);
        return;
      }
      _replaceMessage(recognizingIndex, _ChatMessage.user(normalized));
      _removeAssistantTyping();
      setState(() => _voiceStage = _VoiceStage.recognized);
      unawaited(ref.read(interactionSoundServiceProvider).playXiu());
      await _submitText(normalized, addUserMessage: false);
    } catch (error) {
      _replaceMessage(recognizingIndex, const _ChatMessage.user('语音识别失败'));
      _removeAssistantTyping();
      setState(() => _voiceStage = _VoiceStage.error);
      _addAssistant('结束识别失败：$error');
      setState(() => _voiceStage = _VoiceStage.idle);
    }
  }

  void _updateRecordingDrag(Offset offsetFromOrigin) {
    final shouldCancel = offsetFromOrigin.dy < -72;
    if (shouldCancel != _recordingWillCancel) {
      setState(() => _recordingWillCancel = shouldCancel);
    }
  }

  Future<void> _submitManualText() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      return;
    }
    _textController.clear();
    await _submitText(text);
  }

  void _toggleInputMode() {
    if (_isInputLocked) {
      return;
    }
    setState(() => _textInputMode = !_textInputMode);
  }

  Future<void> _submitText(String text, {bool addUserMessage = true}) async {
    late final int assistantMessageIndex;
    setState(() {
      _aiBusy = true;
      _voiceStage = _VoiceStage.organizing;
      _deleteMatches = const [];
      if (addUserMessage) {
        _messages.add(_ChatMessage.user(text));
      }
      _messages.add(const _ChatMessage.assistant(''));
      assistantMessageIndex = _messages.length - 1;
    });
    _scrollToBottom();

    await for (final event
        in ref.read(captureConversationAgentProvider).submitTextStream(text)) {
      if (event is CaptureAgentAssistantDelta) {
        _appendAssistantDelta(assistantMessageIndex, event.text);
      } else if (event is CaptureAgentTurnDone) {
        await _applyCompletedTurn(event.turn, assistantMessageIndex);
      } else if (event is CaptureAgentFallback) {
        _appendAssistantDelta(assistantMessageIndex, '火山方舟文本模型暂不可用，已使用本地兜底整理。');
        await _applyCompletedTurn(event.turn, assistantMessageIndex);
      }
    }
  }

  Future<void> _saveDraft({String? replaceConflictId}) async {
    final draft = _draft;
    final rawText = _rawText;
    if (draft == null || rawText == null) {
      return;
    }
    if (draft.missingFields.isNotEmpty || !draft.shouldSave) {
      _addAssistant(draft.followUpQuestion ?? '这条记录还缺少关键信息，请继续补充。');
      return;
    }

    final repository = ref.read(entryRepositoryProvider);
    if (_conflicts.isNotEmpty && replaceConflictId == null) {
      _addAssistant('这条待办和已有日程冲突，请先选择保留原日程、删除原日程或修改时间。');
      return;
    }

    setState(() => _aiBusy = true);
    if (replaceConflictId != null) {
      await ref.read(databaseProvider).deleteEntry(replaceConflictId);
    }
    final savedIds = await repository.saveCapture(draft, rawText);
    unawaited(ref.read(interactionSoundServiceProvider).playDing());
    ref.read(captureConversationAgentProvider).reset();
    setState(() {
      _draft = null;
      _rawText = null;
      _conflicts = const [];
      _aiBusy = false;
      _voiceStage = _VoiceStage.idle;
      _messages.add(_ChatMessage.assistant(savedIds.length > 1
          ? '已保存 ${savedIds.length} 条待办'
          : '已保存'));
    });
    _scrollToBottom();
  }

  Future<void> _confirmTodoDeletion() async {
    final matches = _deleteMatches;
    if (matches.isEmpty) {
      return;
    }
    setState(() => _aiBusy = true);
    await ref.read(entryRepositoryProvider).deleteTodos(
          matches.map((item) => item.id).toList(growable: false),
        );
    if (!mounted) {
      return;
    }
    setState(() {
      _deleteMatches = const [];
      _aiBusy = false;
      _messages.add(_ChatMessage.assistant('已删除 ${matches.length} 条待办。'));
    });
    _scrollToBottom();
  }

  void _cancelTodoDeletion() {
    setState(() {
      _deleteMatches = const [];
      _messages.add(const _ChatMessage.assistant('已取消删除。'));
    });
    _scrollToBottom();
  }

  void _discardDraft() {
    ref.read(captureConversationAgentProvider).reset();
    setState(() {
      _draft = null;
      _rawText = null;
      _conflicts = const [];
      _deleteMatches = const [];
      _voiceStage = _VoiceStage.idle;
      _messages.add(const _ChatMessage.assistant('已取消本次录入。'));
    });
    _scrollToBottom();
  }

  void _addAssistant(String text) {
    setState(() => _messages.add(_ChatMessage.assistant(text)));
    _scrollToBottom();
  }

  void _appendAssistantDelta(int index, String delta) {
    if (!mounted || index < 0 || index >= _messages.length || delta.isEmpty) {
      return;
    }
    setState(() {
      final message = _messages[index];
      _messages[index] = message.copyWith(text: message.text + delta);
    });
    _scrollToBottom();
  }

  void _replaceMessage(int index, _ChatMessage message) {
    if (!mounted || index < 0 || index >= _messages.length) {
      return;
    }
    setState(() => _messages[index] = message);
    _scrollToBottom();
  }

  void _removeAssistantTyping() {
    final index = _messages.lastIndexWhere(
        (message) => message.kind == _ChatMessageKind.assistantTyping);
    if (index == -1) {
      return;
    }
    setState(() => _messages.removeAt(index));
  }

  Future<void> _applyCompletedTurn(
      CaptureTurn turn, int assistantMessageIndex) async {
    final capture = turn.capture;
    if (capture.intentType == CaptureIntentType.todoDelete) {
      final payload = capture.todoDeletePayload;
      final matches = payload == null
          ? const <EntryListItem>[]
          : await ref
              .read(entryRepositoryProvider)
              .findTodosForDeletion(payload);
      if (!mounted) {
        return;
      }
      ref.read(captureConversationAgentProvider).reset();
      setState(() {
        _draft = null;
        _rawText = null;
        _conflicts = const [];
        _deleteMatches = matches;
        if (_messages[assistantMessageIndex].text.trim().isEmpty) {
          _messages[assistantMessageIndex] =
              _messages[assistantMessageIndex].copyWith(
            text: matches.isEmpty
                ? '没有找到符合条件的待办。'
                : '找到了 ${matches.length} 条待办，请确认是否删除。',
          );
        } else if (matches.isEmpty) {
          _messages.add(const _ChatMessage.assistant('没有找到符合条件的待办。'));
        }
        _aiBusy = false;
        _voiceStage = _VoiceStage.idle;
      });
      _scrollToBottom();
      return;
    }
    final conflicts =
        await ref.read(entryRepositoryProvider).conflictsFor(capture);
    if (!mounted) {
      return;
    }
    setState(() {
      _draft = capture;
      _rawText = turn.rawTranscript;
      _conflicts = conflicts;
      if (_messages[assistantMessageIndex].text.trim().isEmpty) {
        _messages[assistantMessageIndex] =
            _messages[assistantMessageIndex].copyWith(
          text: capture.followUpQuestion ?? '我整理好了，请确认是否保存。',
        );
      }
      _aiBusy = false;
      _voiceStage = _VoiceStage.idle;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageHeader(title: '语音记录'),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 12),
                  children: [
                    for (final message in _messages)
                      _ChatBubble(message: message),
                    if (_draft != null)
                      _DraftCard(
                        draft: _draft!,
                        conflicts: _conflicts,
                        onSave: () => _saveDraft(),
                        onDiscard: _discardDraft,
                        onReplaceConflict: (id) =>
                            _saveDraft(replaceConflictId: id),
                      ),
                    if (_deleteMatches.isNotEmpty)
                      _TodoDeleteCard(
                        matches: _deleteMatches,
                        onCancel: _cancelTodoDeletion,
                        onConfirm: _confirmTodoDeletion,
                      ),
                  ],
                ),
              ),
              if (_aiBusy) const LinearProgressIndicator(minHeight: 2),
              const SizedBox(height: 8),
              _UnifiedInputBar(
                controller: _textController,
                enabled:
                    !_isInputLocked || _voiceStage == _VoiceStage.recording,
                isTextMode: _textInputMode,
                hasText: _textController.text.trim().isNotEmpty,
                onSubmitText: _submitManualText,
                onToggleMode: _toggleInputMode,
                onLongPressStart: _startRecording,
                onLongPressMoveUpdate: _updateRecordingDrag,
                onLongPressEnd: _stopRecording,
              ),
            ],
          ),
        ),
        if (_voiceStage == _VoiceStage.recording)
          _RecordingOverlay(willCancel: _recordingWillCancel),
      ],
    );
  }
}

class _TodoDeleteCard extends StatelessWidget {
  const _TodoDeleteCard({
    required this.matches,
    required this.onCancel,
    required this.onConfirm,
  });

  final List<EntryListItem> matches;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final visible = matches.take(3);
    return Card(
      key: const Key('todo-delete-confirmation-card'),
      margin: const EdgeInsets.symmetric(vertical: 12),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '准备删除 ${matches.length} 条待办',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            for (final item in visible)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text('${_shortTime(item.startAt)} ${item.title}'),
              ),
            if (matches.length > 3) Text('还有 ${matches.length - 3} 条...'),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton(onPressed: onCancel, child: const Text('取消')),
                const SizedBox(width: 12),
                FilledButton(onPressed: onConfirm, child: const Text('确认删除')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _VoiceStage {
  idle,
  recording,
  recognizing,
  recognized,
  organizing,
  error,
}

enum _ChatMessageKind {
  text,
  recognizing,
  assistantTyping,
}

class _DraftCard extends StatelessWidget {
  const _DraftCard({
    required this.draft,
    required this.conflicts,
    required this.onSave,
    required this.onDiscard,
    required this.onReplaceConflict,
  });

  final CaptureResult draft;
  final List<TodoTimeBlock> conflicts;
  final VoidCallback onSave;
  final VoidCallback onDiscard;
  final ValueChanged<String> onReplaceConflict;

  @override
  Widget build(BuildContext context) {
    final isTodo = draft.intentType == CaptureIntentType.todo;
    final todoPayloads = draft.effectiveTodoPayloads;
    final isBatchTodo = isTodo && todoPayloads.length > 1;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(isTodo ? Icons.event_available : Icons.lightbulb_outline),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(
                        isBatchTodo
                            ? '准备保存 ${todoPayloads.length} 条待办'
                            : draft.title,
                        style: Theme.of(context).textTheme.titleMedium)),
              ],
            ),
            const SizedBox(height: 8),
            Text(draft.summary),
            if (isBatchTodo) ...[
              const SizedBox(height: 10),
              for (final todo in todoPayloads)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _shortTime(todo.startAt),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(todo.title ?? todo.topic ?? draft.title),
                      ),
                    ],
                  ),
                ),
            ],
            if (draft.missingFields.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('缺少信息：${draft.missingFields.join('、')}',
                  style: const TextStyle(color: Colors.orange)),
            ],
            if (conflicts.isNotEmpty) ...[
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.warningSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('时间冲突',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.warning)),
                      for (final conflict in conflicts)
                        Text('${conflict.title}  ${_timeRange(conflict)}'),
                      const SizedBox(height: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          OutlinedButton(
                              onPressed: onDiscard, child: const Text('保留原日程')),
                          const SizedBox(height: 8),
                          FilledButton(
                            onPressed: () =>
                                onReplaceConflict(conflicts.first.id),
                            child: const Text('删除原日程并保存本次'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (conflicts.isEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton(onPressed: onDiscard, child: const Text('取消')),
                  const SizedBox(width: 12),
                  FilledButton(onPressed: onSave, child: const Text('保存')),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: switch (message.kind) {
        _ChatMessageKind.recognizing => const _TypingDotsBubble(
            key: Key('voice-recognizing-bubble'),
            isUser: true,
          ),
        _ChatMessageKind.assistantTyping =>
          const _TypingDotsBubble(isUser: false),
        _ChatMessageKind.text => Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            constraints: const BoxConstraints(maxWidth: 310),
            decoration: BoxDecoration(
              color: message.isUser ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border:
                  message.isUser ? null : Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.035),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: message.isUser ? Colors.white : const Color(0xff1f2937),
                fontSize: 15,
                height: 1.35,
              ),
            ),
          ),
      },
    );
  }
}

class _UnifiedInputBar extends StatefulWidget {
  const _UnifiedInputBar({
    required this.controller,
    required this.enabled,
    required this.isTextMode,
    required this.hasText,
    required this.onSubmitText,
    required this.onToggleMode,
    required this.onLongPressStart,
    required this.onLongPressMoveUpdate,
    required this.onLongPressEnd,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool isTextMode;
  final bool hasText;
  final VoidCallback onSubmitText;
  final VoidCallback onToggleMode;
  final VoidCallback onLongPressStart;
  final ValueChanged<Offset> onLongPressMoveUpdate;
  final VoidCallback onLongPressEnd;

  @override
  State<_UnifiedInputBar> createState() => _UnifiedInputBarState();
}

class _UnifiedInputBarState extends State<_UnifiedInputBar> {
  int? _activeVoicePointer;
  Offset? _voicePointerOrigin;

  void _handleVoicePointerDown(PointerDownEvent event) {
    if (!widget.enabled || widget.isTextMode || _activeVoicePointer != null) {
      return;
    }
    _activeVoicePointer = event.pointer;
    _voicePointerOrigin = event.position;
    widget.onLongPressStart();
  }

  void _handleVoicePointerMove(PointerMoveEvent event) {
    if (event.pointer != _activeVoicePointer) {
      return;
    }
    final origin = _voicePointerOrigin;
    if (origin == null) {
      return;
    }
    widget.onLongPressMoveUpdate(event.position - origin);
  }

  void _handleVoicePointerUp(PointerUpEvent event) {
    if (event.pointer != _activeVoicePointer) {
      return;
    }
    _activeVoicePointer = null;
    _voicePointerOrigin = null;
    widget.onLongPressEnd();
  }

  void _handleVoicePointerCancel(PointerCancelEvent event) {
    if (event.pointer != _activeVoicePointer) {
      return;
    }
    _activeVoicePointer = null;
    _voicePointerOrigin = null;
    widget.onLongPressEnd();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      key: const Key('voice-input-strip'),
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: widget.enabled ? () {} : null,
            icon: const Icon(Icons.photo_camera_outlined),
            tooltip: '拍照',
          ),
          const SizedBox(width: 4),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 160),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: widget.isTextMode
                  ? TextField(
                      key: const Key('merged-text-input'),
                      controller: widget.controller,
                      minLines: 1,
                      maxLines: 2,
                      enabled: widget.enabled,
                      textInputAction: TextInputAction.send,
                      onSubmitted:
                          widget.enabled ? (_) => widget.onSubmitText() : null,
                      decoration: InputDecoration(
                        hintText: '发送消息或按住说话...',
                        isDense: true,
                        border: InputBorder.none,
                        suffixIconConstraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        suffixIcon: widget.hasText
                            ? IconButton(
                                icon: const Icon(Icons.send_rounded),
                                tooltip: '发送',
                                onPressed:
                                    widget.enabled ? widget.onSubmitText : null,
                              )
                            : null,
                      ),
                    )
                  : Listener(
                      key: const Key('voice-press-button'),
                      onPointerDown: _handleVoicePointerDown,
                      onPointerMove: _handleVoicePointerMove,
                      onPointerUp: _handleVoicePointerUp,
                      onPointerCancel: _handleVoicePointerCancel,
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _SideSignalIcon(),
                            SizedBox(width: 8),
                            Text(
                              '按住说话',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff111827),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            key: const Key('voice-mode-toggle-button'),
            onPressed: widget.enabled ? widget.onToggleMode : null,
            icon: widget.isTextMode
                ? const _SideSignalIcon()
                : const Icon(Icons.keyboard_alt_outlined),
            tooltip: widget.isTextMode ? '切换到语音输入' : '切换到文字输入',
          ),
        ],
      ),
    );
  }
}

class _SideSignalIcon extends StatelessWidget {
  const _SideSignalIcon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      key: const Key('voice-side-signal-icon'),
      size: const Size(28, 28),
      painter: _SideSignalPainter(
        color: IconTheme.of(context).color ?? const Color(0xff111827),
      ),
    );
  }
}

class _SideSignalPainter extends CustomPainter {
  const _SideSignalPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final center = Offset(size.width * 0.35, size.height * 0.5);
    for (final radius in [5.0, 9.0, 13.0]) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -0.82,
        1.64,
        false,
        paint,
      );
    }
    canvas.drawCircle(center, 1.8, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SideSignalPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _RecordingOverlay extends StatelessWidget {
  const _RecordingOverlay({required this.willCancel});

  final bool willCancel;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    return Positioned.fill(
      key: const Key('voice-recording-overlay'),
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 330 + bottomPadding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withValues(alpha: 0),
                  const Color(0xffdff5ff).withValues(alpha: 0.72),
                  const Color(0xff0b8cff).withValues(alpha: 0.96),
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 66, 24, 22 + bottomPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 74,
                    width: 74,
                    decoration: BoxDecoration(
                      color:
                          willCancel ? Colors.white : const Color(0xff087cff),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (willCancel ? Colors.redAccent : Colors.white)
                              .withValues(alpha: 0.42),
                          blurRadius: 28,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      willCancel ? Icons.close : Icons.mic,
                      color: willCancel ? Colors.redAccent : Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    willCancel ? '松手取消' : '松手发送，上移取消',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 22),
                  const _AnimatedWaveform(color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedWaveform extends StatefulWidget {
  const _AnimatedWaveform({required this.color});

  final Color color;

  @override
  State<_AnimatedWaveform> createState() => _AnimatedWaveformState();
}

class _AnimatedWaveformState extends State<_AnimatedWaveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(42, (index) {
            final wave =
                math.sin((_controller.value * math.pi * 2) + index * 0.42);
            final height = 8 + (wave.abs() * 22) + (index % 5 == 0 ? 8 : 0);
            return Container(
              width: 3,
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(99),
              ),
            );
          }),
        );
      },
    );
  }
}

class _TypingDotsBubble extends StatefulWidget {
  const _TypingDotsBubble({super.key, required this.isUser});

  final bool isUser;

  @override
  State<_TypingDotsBubble> createState() => _TypingDotsBubbleState();
}

class _TypingDotsBubbleState extends State<_TypingDotsBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final background = widget.isUser ? AppColors.primary : AppColors.surface;
    final dotColor = widget.isUser ? Colors.white : AppColors.textMuted;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: widget.isUser ? null : Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (index) {
              final phase = (_controller.value + index * 0.18) % 1;
              final opacity = 0.35 + (math.sin(phase * math.pi) * 0.65);
              return Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: dotColor.withValues(alpha: opacity),
                  shape: BoxShape.circle,
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage.user(this.text)
      : isUser = true,
        kind = _ChatMessageKind.text;

  const _ChatMessage.assistant(this.text)
      : isUser = false,
        kind = _ChatMessageKind.text;

  const _ChatMessage.recognizing()
      : text = '',
        isUser = true,
        kind = _ChatMessageKind.recognizing;

  const _ChatMessage.assistantTyping()
      : text = '',
        isUser = false,
        kind = _ChatMessageKind.assistantTyping;

  final String text;
  final bool isUser;
  final _ChatMessageKind kind;

  _ChatMessage copyWith({String? text}) {
    if (kind != _ChatMessageKind.text) {
      return this;
    }
    return isUser
        ? _ChatMessage.user(text ?? this.text)
        : _ChatMessage.assistant(text ?? this.text);
  }
}

String _timeRange(TodoTimeBlock block) {
  final start = block.startAt.toLocal();
  final end = block.endAt.toLocal();
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(start.hour)}:${two(start.minute)}-${two(end.hour)}:${two(end.minute)}';
}

String _shortTime(DateTime? value) {
  if (value == null) {
    return '--:--';
  }
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${two(local.hour)}:${two(local.minute)}';
}
