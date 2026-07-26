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
import '../../widgets/unified_input_bar.dart';

class VoicePage extends ConsumerStatefulWidget {
  const VoicePage({super.key});

  @override
  ConsumerState<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends ConsumerState<VoicePage> {
  static const _cloudWorkingText = '正在云端整理…';
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_ChatMessage>[];

  CaptureResult? _draft;
  String? _rawText;
  List<TodoTimeBlock> _conflicts = const [];
  List<EntryListItem> _deleteMatches = const [];
  List<EntryListItem> _lastQueryMatches = const [];
  _VoiceStage _voiceStage = _VoiceStage.idle;
  bool _aiBusy = false;
  bool _recordingWillCancel = false;
  bool _textInputMode = false;
  bool _conversationStarted = false;

  bool get _isInputLocked =>
      _aiBusy ||
      _voiceStage == _VoiceStage.recognizing ||
      _voiceStage == _VoiceStage.recording;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_refreshTextInput);
    _restoreDisplayFromAgent();
    Future<void>.microtask(_tryRestoreSession);
    Future<void>.microtask(() async {
      try {
        await ref.read(speechChannelProvider).prepare();
      } catch (_) {
        // startRecognition will surface permission and model-download errors.
      }
    });
  }

  void _restoreDisplayFromAgent() {
    final snapshot = ref.read(captureConversationAgentProvider).displaySnapshot;
    if (snapshot.messages.isEmpty) {
      return;
    }
    _draft = snapshot.activeDraft;
    final agent = ref.read(captureConversationAgentProvider);
    _rawText = agent.memory
        .where((m) => m['role'] == 'user')
        .map((m) => m['content'] as String)
        .join('\n');
    setState(() {
      _conversationStarted = true;
      for (final msg in snapshot.messages) {
        _messages.add(
          msg.isUser
              ? _ChatMessage.user(msg.text)
              : _ChatMessage.assistant(msg.text),
        );
      }
    });
    _scrollToBottom();
  }

  Future<void> _tryRestoreSession() async {
    final restored =
        await ref.read(captureConversationAgentProvider).restoreSession();
    if (!mounted || !restored) {
      return;
    }
    final agent = ref.read(captureConversationAgentProvider);
    final draft = agent.draft;
    if (draft == null) {
      return;
    }
    setState(() {
      _conversationStarted = true;
      _draft = draft;
      _addAssistant('已恢复上次取消的录入，你可以继续补充或修改。');
    });
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
      _conversationStarted = true;
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

    unawaited(ref.read(interactionSoundServiceProvider).playXiu());

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
        ref.read(captureConversationAgentProvider).appendDisplayMessage(
              const ConversationMessage(isUser: true, text: '未识别到语音内容'),
            );
        _removeAssistantTyping();
        setState(() => _voiceStage = _VoiceStage.error);
        return;
      }
      _replaceMessage(recognizingIndex, _ChatMessage.user(normalized));
      ref.read(captureConversationAgentProvider).appendDisplayMessage(
            ConversationMessage(isUser: true, text: normalized),
          );
      _removeAssistantTyping();
      setState(() => _voiceStage = _VoiceStage.recognized);
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
      _conversationStarted = true;
      _aiBusy = true;
      _voiceStage = _VoiceStage.organizing;
      _deleteMatches = const [];
      if (addUserMessage) {
        _messages.add(_ChatMessage.user(text));
        ref.read(captureConversationAgentProvider).appendDisplayMessage(
              ConversationMessage(isUser: true, text: text),
            );
      }
      _messages.add(const _ChatMessage.assistant(_cloudWorkingText));
      assistantMessageIndex = _messages.length - 1;
    });
    _scrollToBottom();

    await for (final event
        in ref.read(captureConversationAgentProvider).submitTextStream(text)) {
      if (event is CaptureAgentAssistantDelta) {
        _appendAssistantDelta(assistantMessageIndex, event.text);
      } else if (event is CaptureAgentRoutingStatus) {
        _replaceMessage(
            assistantMessageIndex, _ChatMessage.assistant(event.message));
      } else if (event is CaptureAgentTurnDone) {
        await _applyCompletedTurn(event.turn, assistantMessageIndex);
      } else if (event is CaptureAgentFailure) {
        _replaceMessage(
            assistantMessageIndex, _ChatMessage.assistant(event.message));
        setState(() {
          _aiBusy = false;
          _voiceStage = _VoiceStage.idle;
        });
      }
    }
  }

  Future<void> _saveDraft({String? replaceConflictId}) async {
    final draft = _draft;
    final rawText = _rawText;
    if (draft == null || rawText == null) {
      return;
    }
    if (draft.missingFields
            .where((field) =>
                field != 'location' &&
                field != 'topic' &&
                field != 'reminder_at')
            .isNotEmpty ||
        !draft.shouldSave) {
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
    await ref.read(captureConversationAgentProvider).completeDraft();
    setState(() {
      _draft = null;
      _rawText = null;
      _conflicts = const [];
      _aiBusy = false;
      _voiceStage = _VoiceStage.idle;
      _messages.add(_ChatMessage.assistant(
          savedIds.length > 1 ? '已保存 ${savedIds.length} 条待办' : '已保存'));
      ref.read(captureConversationAgentProvider).appendDisplayMessage(
            ConversationMessage(
                isUser: false,
                text:
                    savedIds.length > 1 ? '已保存 ${savedIds.length} 条待办' : '已保存'),
          );
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
      ref.read(captureConversationAgentProvider).appendDisplayMessage(
            ConversationMessage(
                isUser: false, text: '已删除 ${matches.length} 条待办。'),
          );
    });
    _scrollToBottom();
  }

  void _cancelTodoDeletion() {
    setState(() {
      _deleteMatches = const [];
      _messages.add(const _ChatMessage.assistant('已取消删除。'));
      ref.read(captureConversationAgentProvider).appendDisplayMessage(
            const ConversationMessage(isUser: false, text: '已取消删除。'),
          );
    });
    _scrollToBottom();
  }

  void _discardDraft() async {
    await ref.read(captureConversationAgentProvider).cancelDraft();
    setState(() {
      _draft = null;
      _rawText = null;
      _conflicts = const [];
      _deleteMatches = const [];
      _voiceStage = _VoiceStage.idle;
      _messages.add(const _ChatMessage.assistant('已取消本次录入，30分钟内可以继续修改刚才的内容。'));
      ref.read(captureConversationAgentProvider).appendDisplayMessage(
            const ConversationMessage(
                isUser: false, text: '已取消本次录入，30分钟内可以继续修改刚才的内容。'),
          );
    });
    _scrollToBottom();
  }

  void _addAssistant(String text) {
    setState(() => _messages.add(_ChatMessage.assistant(text)));
    ref.read(captureConversationAgentProvider).appendDisplayMessage(
          ConversationMessage(isUser: false, text: text),
        );
    _scrollToBottom();
  }

  void _appendAssistantDelta(int index, String delta) {
    if (!mounted || index < 0 || index >= _messages.length || delta.isEmpty) {
      return;
    }
    setState(() {
      final message = _messages[index];
      _messages[index] = message.copyWith(
        text: message.text == _cloudWorkingText ? delta : message.text + delta,
      );
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

    if (capture.intentType == CaptureIntentType.todoQuery) {
      final payload = capture.todoQueryPayload;
      if (payload == null) {
        _replaceMessage(assistantMessageIndex,
            const _ChatMessage.assistant('未能解析查询条件，请换个说法试试。'));
        setState(() {
          _aiBusy = false;
          _voiceStage = _VoiceStage.idle;
        });
        return;
      }

      final results =
          await ref.read(entryRepositoryProvider).queryTodos(payload);
      if (!mounted) {
        return;
      }

      final queryReply = _buildQueryReply(payload, results, capture);
      _replaceMessage(
          assistantMessageIndex, _ChatMessage.assistant(queryReply));
      ref.read(captureConversationAgentProvider).appendDisplayMessage(
            ConversationMessage(isUser: false, text: queryReply),
          );
      ref
          .read(captureConversationAgentProvider)
          .rememberLastQueryTodoIds(results.map((item) => item.id));
      setState(() {
        _lastQueryMatches = results;
        _aiBusy = false;
        _voiceStage = _VoiceStage.idle;
      });
      _scrollToBottom();
      return;
    }

    if (capture.intentType == CaptureIntentType.todoDelete) {
      final payload = capture.todoDeletePayload;
      final agent = ref.read(captureConversationAgentProvider);
      final queryIds = agent.lastQueryTodoIds.isNotEmpty
          ? agent.lastQueryTodoIds
          : _lastQueryMatches.map((item) => item.id).toList(growable: false);
      final refersToLastQuery =
          _refersToLastQuery(turn.rawTranscript, queryIds);
      final matches = refersToLastQuery
          ? _lastQueryMatches.isNotEmpty
              ? _lastQueryMatches
              : await ref.read(entryRepositoryProvider).loadTodosByIds(queryIds)
          : payload == null
              ? const <EntryListItem>[]
              : await ref
                  .read(entryRepositoryProvider)
                  .findTodosForDeletion(payload);
      if (!mounted) {
        return;
      }
      setState(() {
        _draft = null;
        _rawText = null;
        _conflicts = const [];
        _deleteMatches = matches;
        _lastQueryMatches = const [];
        agent.clearLastQueryTodoIds();
        if (_messages[assistantMessageIndex].text.trim().isEmpty ||
            _messages[assistantMessageIndex].text == _cloudWorkingText) {
          final deleteText = matches.isEmpty
              ? '没有找到符合条件的待办。'
              : '找到了 ${matches.length} 条待办，请确认是否删除。';
          _messages[assistantMessageIndex] =
              _messages[assistantMessageIndex].copyWith(
            text: deleteText,
          );
        } else if (matches.isEmpty) {
          _messages.add(const _ChatMessage.assistant('没有找到符合条件的待办。'));
          ref.read(captureConversationAgentProvider).appendDisplayMessage(
                const ConversationMessage(isUser: false, text: '没有找到符合条件的待办。'),
              );
        }
        final deleteDisplayText = _messages[assistantMessageIndex].text.trim();
        if (deleteDisplayText.isNotEmpty) {
          ref.read(captureConversationAgentProvider).appendDisplayMessage(
                ConversationMessage(isUser: false, text: deleteDisplayText),
              );
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
      _lastQueryMatches = const [];
      ref.read(captureConversationAgentProvider).clearLastQueryTodoIds();
      _draft = capture;
      _rawText = turn.rawTranscript;
      _conflicts = conflicts;
      if (_messages[assistantMessageIndex].text.trim().isEmpty ||
          _messages[assistantMessageIndex].text == _cloudWorkingText) {
        _messages[assistantMessageIndex] =
            _messages[assistantMessageIndex].copyWith(
          text: capture.followUpQuestion ?? '我整理好了，请确认是否保存。',
        );
      }
      final assistantDisplayText = _messages[assistantMessageIndex].text.trim();
      if (assistantDisplayText.isNotEmpty) {
        ref.read(captureConversationAgentProvider).appendDisplayMessage(
              ConversationMessage(isUser: false, text: assistantDisplayText),
            );
      }
      _aiBusy = false;
      _voiceStage = _VoiceStage.idle;
    });
    _scrollToBottom();
  }

  bool _refersToLastQuery(String text, List<String> lastQueryTodoIds) {
    if (lastQueryTodoIds.isEmpty) {
      return false;
    }

    final normalized = text.replaceAll(RegExp(r'\s+'), '');
    return RegExp(
      r'(这些|这几|刚才|上面|上述|它们)|((全部|全都|都).{0,6}(删除|删掉|清空))|((删除|删掉|清空).{0,6}(全部|全都|都))',
    ).hasMatch(normalized);
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

  String _buildQueryReply(TodoQueryPayload payload, List<EntryListItem> results,
      CaptureResult capture) {
    final buffer = StringBuffer();
    final dateLabel = _queryDateLabel(payload);
    buffer.writeln(dateLabel);

    if (results.isEmpty) {
      buffer.write('暂时没有');
      buffer.write(payload.includeCompleted ? '' : '未完成的');
      buffer.write('待办。');
      return buffer.toString();
    }

    buffer.writeln('共 ${results.length} 条待办：');
    for (final todo in results) {
      final time = todo.startAt != null ? _shortTime(todo.startAt!) : '--:--';
      buffer.writeln('$time ${todo.title}');
    }

    buffer.writeln();

    final suggestions = _generateSuggestions(results, payload);
    if (suggestions.isNotEmpty) {
      buffer.write(suggestions);
    }

    return buffer.toString().trim();
  }

  String _queryDateLabel(TodoQueryPayload payload) {
    if (payload.dateFrom != null && payload.dateTo != null) {
      final diff = payload.dateTo!.difference(payload.dateFrom!).inDays;
      if (diff == 1) {
        final month = payload.dateFrom!.month;
        final day = payload.dateFrom!.day;
        return '$month月$day日的待办：';
      }
      if (diff <= 7) {
        final fromMonth = payload.dateFrom!.month;
        final fromDay = payload.dateFrom!.day;
        final toMonth = payload.dateTo!.month;
        final toDay = payload.dateTo!.day;
        return '$fromMonth月$fromDay日 至 $toMonth月$toDay日的待办：';
      }
    }
    return '查询结果：';
  }

  String _generateSuggestions(
      List<EntryListItem> todos, TodoQueryPayload payload) {
    final suggestions = <String>[];
    final sortedTodos = todos.where((todo) => todo.startAt != null).toList()
      ..sort((a, b) => a.startAt!.compareTo(b.startAt!));

    for (var index = 0; index < sortedTodos.length - 1; index++) {
      final current = sortedTodos[index];
      final next = sortedTodos[index + 1];
      if (current.endAt != null && next.startAt != null) {
        final gap = next.startAt!.difference(current.endAt!).inMinutes;
        if (gap < 30 && gap >= 0) {
          suggestions.add(
              '「${current.title}」和「${next.title}」间隔较短（$gap分钟），建议提前安排出行时间。');
        } else if (gap < 0) {
          suggestions.add('「${current.title}」与「${next.title}」时间重叠，请注意调整。');
        }
      }
    }

    for (final todo in sortedTodos) {
      if (todo.reminderAt == null && todo.startAt != null) {
        final untilStart = todo.startAt!.difference(DateTime.now()).inMinutes;
        if (untilStart > 0 && untilStart < 120) {
          suggestions.add('「${todo.title}」即将开始，还没有设置提醒。');
        }
      }
      if (todo.endAt != null && todo.startAt != null) {
        final duration = todo.endAt!.difference(todo.startAt!).inMinutes;
        if (duration > 120) {
          suggestions.add('「${todo.title}」持续时间较长（$duration分钟）。');
        }
      }
    }

    final todayStart = DateTime.now();
    final todayEnd =
        DateTime(todayStart.year, todayStart.month, todayStart.day + 1);
    final todayCount = sortedTodos
        .where((todo) =>
            todo.startAt != null &&
            !todo.startAt!.isBefore(todayStart) &&
            todo.startAt!.isBefore(todayEnd))
        .length;
    if (todayCount > 5) {
      suggestions.add('今天安排较密（$todayCount 项），建议合理分配精力。');
    }

    if (suggestions.isEmpty) {
      return '';
    }

    return '\n建议：\n${suggestions.map((s) => '• $s').join('\n')}';
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
                child: !_conversationStarted && _messages.isEmpty
                    ? const _VoiceAssistantPrompt()
                    : ListView(
                        key: const Key('voice-conversation-list'),
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
              UnifiedInputBar(
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

class _VoiceAssistantPrompt extends StatelessWidget {
  const _VoiceAssistantPrompt();

  static const _prompts = [
    '记录一个突发的灵感',
    '整理今天想做的几件事',
    '记录一个问题或需要解决的困扰',
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      key: const Key('voice-assistant-prompt'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.055),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.smart_toy_outlined,
                      color: Color(0xffc7921e),
                      size: 32,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'AI 助手提示',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  '说出你的想法，我会帮你整理和保存。',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                for (var index = 0; index < _prompts.length; index++) ...[
                  Container(
                    key: Key('voice-assistant-prompt-row-$index'),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      _prompts[index],
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (index < _prompts.length - 1) const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      ),
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
    return Container(
      key: const Key('todo-delete-confirmation-card'),
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accentBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0f3d3528),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '准备删除 ${matches.length} 条待办',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (final item in visible)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _shortTime(item.startAt),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(item.title)),
                  ],
                ),
              ),
            if (matches.length > 3)
              Text(
                '还有 ${matches.length - 3} 条...',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.textMuted),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: onCancel,
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: onConfirm,
                    child: const Text('确认删除'),
                  ),
                ),
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
    final isLedger = draft.intentType == CaptureIntentType.ledger;
    final todoPayloads = draft.effectiveTodoPayloads;
    final isBatchTodo = isTodo && todoPayloads.length > 1;
    return Container(
      key: const Key('voice-draft-card'),
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accentBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0f3d3528),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  key: const Key('voice-draft-icon'),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.accentSoft,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isTodo
                        ? Icons.event_available
                        : isLedger
                            ? Icons.receipt_long_outlined
                            : Icons.lightbulb_outline,
                    size: 20,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(
                        isBatchTodo
                            ? '准备保存 ${todoPayloads.length} 条待办'
                            : draft.title,
                        style: Theme.of(context).textTheme.titleMedium)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              draft.summary,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
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
            if (draft.missingFields
                .where((f) => _fieldLabel(f) != null)
                .isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                  '缺少信息：${draft.missingFields.where((f) => _fieldLabel(f) != null).map((f) => _fieldLabel(f)!).join('、')}',
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
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.textPrimary,
                                side: const BorderSide(
                                    color: AppColors.textMuted),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: onDiscard,
                              child: const Text('保留原日程'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () =>
                                  onReplaceConflict(conflicts.first.id),
                              child: const Text('删除原日程'),
                            ),
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
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.textMuted),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: onDiscard,
                      child: const Text('取消'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: onSave,
                      child: const Text('保存'),
                    ),
                  ),
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
            key: message.isUser ? const Key('voice-user-message-bubble') : null,
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            constraints: const BoxConstraints(maxWidth: 310),
            decoration: BoxDecoration(
              color:
                  message.isUser ? AppColors.chatUserSoft : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: message.isUser ? AppColors.chatBorder : AppColors.border,
              ),
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
              style: const TextStyle(
                color: Color(0xff1f2937),
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
    return Container(
      key: const Key('voice-input-strip'),
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: widget.enabled ? () {} : null,
            icon: const Icon(
              Icons.photo_camera_outlined,
              color: AppColors.textSecondary,
            ),
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
                      textAlignVertical: TextAlignVertical.center,
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
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
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
                        height: 52,
                        alignment: Alignment.center,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _SideSignalIcon(color: Color(0xffc7921e)),
                            SizedBox(width: 8),
                            Text(
                              '按住说话',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
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
                : const Icon(
                    Icons.keyboard_alt_outlined,
                    color: AppColors.textSecondary,
                  ),
            tooltip: widget.isTextMode ? '切换到语音输入' : '切换到文字输入',
          ),
        ],
      ),
    );
  }
}

class _SideSignalIcon extends StatelessWidget {
  const _SideSignalIcon({this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      key: const Key('voice-side-signal-icon'),
      size: const Size(28, 28),
      painter: _SideSignalPainter(
        color: color ?? IconTheme.of(context).color ?? const Color(0xff111827),
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
    final background =
        widget.isUser ? AppColors.chatUserSoft : AppColors.surface;
    final dotColor =
        widget.isUser ? AppColors.primaryDark : AppColors.textMuted;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isUser ? AppColors.chatBorder : AppColors.border,
        ),
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

String? _fieldLabel(String field) {
  const map = {
    'start_at': '时间',
    'end_at': '结束时间',
    'title': '事项',
    'location': '地点',
    'topic': '主题',
    'reminder_at': '提醒',
  };
  return map[field];
}

String _shortTime(DateTime? value) {
  if (value == null) {
    return '--:--';
  }
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${two(local.hour)}:${two(local.minute)}';
}
