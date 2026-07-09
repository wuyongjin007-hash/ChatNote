import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/capture_conversation_agent.dart';
import '../../domain/capture_models.dart';
import '../../domain/conflict_detector.dart';
import '../../providers.dart';

class VoicePage extends ConsumerStatefulWidget {
  const VoicePage({super.key});

  @override
  ConsumerState<VoicePage> createState() => _VoicePageState();
}

class _VoicePageState extends ConsumerState<VoicePage> {
  final _textController = TextEditingController();
  final _messages = <_ChatMessage>[
    const _ChatMessage.assistant('按住麦克风说出待办或闪念。也可以先用文字输入测试。'),
  ];

  CaptureResult? _draft;
  String? _rawText;
  List<TodoTimeBlock> _conflicts = const [];
  bool _isRecording = false;
  bool _isBusy = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    setState(() => _isRecording = true);
    try {
      await ref.read(speechChannelProvider).startRecognition();
    } catch (error) {
      _addAssistant('语音识别未就绪：$error。你可以先用文字输入。');
    }
  }

  Future<void> _stopRecording() async {
    setState(() => _isRecording = false);
    try {
      final text = await ref.read(speechChannelProvider).stopRecognition();
      if (text.trim().isEmpty) {
        _addAssistant('没有识别到语音内容。');
        return;
      }
      await _submitText(text);
    } catch (error) {
      _addAssistant('结束识别失败：$error');
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

  Future<void> _submitText(String text) async {
    late final int assistantMessageIndex;
    setState(() {
      _isBusy = true;
      _messages.add(_ChatMessage.user(text));
      _messages.add(const _ChatMessage.assistant(''));
      assistantMessageIndex = _messages.length - 1;
    });

    await for (final event in ref.read(captureConversationAgentProvider).submitTextStream(text)) {
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

    setState(() => _isBusy = true);
    if (replaceConflictId != null) {
      await ref.read(databaseProvider).deleteEntry(replaceConflictId);
    }
    await repository.saveCapture(draft, rawText);
    ref.read(captureConversationAgentProvider).reset();
    setState(() {
      _draft = null;
      _rawText = null;
      _conflicts = const [];
      _isBusy = false;
      _messages.add(const _ChatMessage.assistant('已保存到手机本地。'));
    });
  }

  void _discardDraft() {
    ref.read(captureConversationAgentProvider).reset();
    setState(() {
      _draft = null;
      _rawText = null;
      _conflicts = const [];
      _messages.add(const _ChatMessage.assistant('已取消本次录入。'));
    });
  }

  void _addAssistant(String text) {
    setState(() => _messages.add(_ChatMessage.assistant(text)));
  }

  void _appendAssistantDelta(int index, String delta) {
    if (!mounted || index < 0 || index >= _messages.length || delta.isEmpty) {
      return;
    }
    setState(() {
      final message = _messages[index];
      _messages[index] = message.copyWith(text: message.text + delta);
    });
  }

  Future<void> _applyCompletedTurn(CaptureTurn turn, int assistantMessageIndex) async {
    final capture = turn.capture;
    final conflicts = await ref.read(entryRepositoryProvider).conflictsFor(capture);
    if (!mounted) {
      return;
    }
    setState(() {
      _draft = capture;
      _rawText = turn.rawTranscript;
      _conflicts = conflicts;
      if (_messages[assistantMessageIndex].text.trim().isEmpty) {
        _messages[assistantMessageIndex] = _messages[assistantMessageIndex].copyWith(
          text: capture.followUpQuestion ?? '我整理好了，请确认是否保存。',
        );
      }
      _isBusy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('语音记录', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              children: [
                for (final message in _messages) _ChatBubble(message: message),
                if (_draft != null)
                  _DraftCard(
                    draft: _draft!,
                    conflicts: _conflicts,
                    onSave: () => _saveDraft(),
                    onDiscard: _discardDraft,
                    onReplaceConflict: (id) => _saveDraft(replaceConflictId: id),
                  ),
              ],
            ),
          ),
          if (_isBusy) const LinearProgressIndicator(),
          const SizedBox(height: 8),
          TextField(
            controller: _textController,
            minLines: 1,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: '先用文字模拟语音输入...',
              suffixIcon: IconButton(icon: const Icon(Icons.send), onPressed: _isBusy ? null : _submitManualText),
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onLongPressStart: (_) => _startRecording(),
            onLongPressEnd: (_) => _stopRecording(),
            child: FilledButton.icon(
              onPressed: null,
              icon: Icon(_isRecording ? Icons.mic : Icons.mic_none),
              label: Text(_isRecording ? '松开结束录音' : '按住说话'),
              style: FilledButton.styleFrom(
                disabledBackgroundColor: _isRecording ? Colors.redAccent : Theme.of(context).colorScheme.primary,
                disabledForegroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(isTodo ? Icons.event_available : Icons.lightbulb_outline),
                const SizedBox(width: 8),
                Expanded(child: Text(draft.title, style: Theme.of(context).textTheme.titleMedium)),
              ],
            ),
            const SizedBox(height: 8),
            Text(draft.summary),
            if (draft.missingFields.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('缺少信息：${draft.missingFields.join('、')}', style: const TextStyle(color: Colors.orange)),
            ],
            if (conflicts.isNotEmpty) ...[
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('时间冲突', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.deepOrange)),
                      for (final conflict in conflicts) Text('${conflict.title}  ${_timeRange(conflict)}'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [
                          OutlinedButton(onPressed: onDiscard, child: const Text('保留原日程')),
                          FilledButton(
                            onPressed: () => onReplaceConflict(conflicts.first.id),
                            child: const Text('删除原日程并保存'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton(onPressed: onDiscard, child: const Text('取消')),
                const SizedBox(width: 12),
                FilledButton(onPressed: onSave, child: const Text('保存')),
              ],
            ),
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
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 310),
        decoration: BoxDecoration(
          color: message.isUser ? Theme.of(context).colorScheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: message.isUser ? null : Border.all(color: const Color(0xffe2e8f0)),
        ),
        child: Text(
          message.text,
          style: TextStyle(color: message.isUser ? Colors.white : const Color(0xff1f2937)),
        ),
      ),
    );
  }
}

class _ChatMessage {
  const _ChatMessage.user(this.text) : isUser = true;
  const _ChatMessage.assistant(this.text) : isUser = false;

  final String text;
  final bool isUser;

  _ChatMessage copyWith({String? text}) {
    return isUser ? _ChatMessage.user(text ?? this.text) : _ChatMessage.assistant(text ?? this.text);
  }
}

String _timeRange(TodoTimeBlock block) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(block.startAt.hour)}:${two(block.startAt.minute)}-${two(block.endAt.hour)}:${two(block.endAt.minute)}';
}
