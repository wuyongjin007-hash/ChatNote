import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../agent/agent_models.dart';
import '../../agent/agent_runtime.dart';
import '../../agent/agent_session_controller.dart';
import '../../providers.dart';
import '../../widgets/page_header.dart';
import '../../widgets/unified_input_bar.dart';

class AgentPage extends ConsumerStatefulWidget {
  const AgentPage({super.key});

  @override
  ConsumerState<AgentPage> createState() => _AgentPageState();
}

class _AgentPageState extends ConsumerState<AgentPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_VisibleMessage>[];
  AgentSessionController? _controller;
  PendingToolConfirmation? _pending;
  bool _busy = false;
  bool _recording = false;
  bool _recordingWillCancel = false;
  bool _textInputMode = false;
  String? _status;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_refreshInput);
    Future<void>.microtask(_initialize);
  }

  Future<void> _initialize() async {
    final controller = ref.read(agentSessionControllerProvider);
    await controller.initialize();
    if (!mounted) return;
    setState(() {
      _controller = controller;
      _messages
        ..clear()
        ..addAll(controller.messages.map(
          (message) => _VisibleMessage(
            isUser: message.role == 'user',
            text: message.content,
          ),
        ));
      _pending = controller.pendingConfirmation;
    });
    _scrollBottom();
  }

  @override
  void dispose() {
    _textController.removeListener(_refreshInput);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _busy || _controller == null) return;
    _textController.clear();
    setState(() {
      _busy = true;
      _status = '正在思考';
      _messages.add(_VisibleMessage(isUser: true, text: text));
      _messages.add(const _VisibleMessage(isUser: false, text: ''));
    });
    final assistantIndex = _messages.length - 1;
    _scrollBottom();
    await _consume(_controller!.send(text), assistantIndex);
  }

  Future<void> _confirm() async {
    if (_busy || _controller == null || _pending == null) return;
    setState(() {
      _busy = true;
      _status = '正在执行已确认操作';
      _messages.add(const _VisibleMessage(isUser: false, text: ''));
    });
    final assistantIndex = _messages.length - 1;
    await _consume(_controller!.confirmPending(), assistantIndex);
  }

  Future<void> _cancel() async {
    await _controller?.cancelPending();
    if (!mounted) return;
    setState(() {
      _pending = null;
      _messages.add(const _VisibleMessage(isUser: false, text: '已取消该操作。'));
    });
  }

  Future<void> _consume(
      Stream<AgentRuntimeEvent> stream, int assistantIndex) async {
    await for (final event in stream) {
      if (!mounted) return;
      setState(() {
        if (event is AgentRuntimeText) {
          final current = _messages[assistantIndex];
          _messages[assistantIndex] =
              _VisibleMessage(isUser: false, text: current.text + event.text);
        } else if (event is AgentRuntimeStatus) {
          _status = _friendlyStatus(event.label);
        } else if (event is AgentRuntimeToolActivity &&
            event.riskLevel == ToolRiskLevel.create &&
            event.result?.isSuccess == true) {
          unawaited(ref.read(interactionSoundServiceProvider).playDing());
        } else if (event is AgentRuntimeConfirmation) {
          _pending = event.confirmation;
          _status = '等待你的确认';
        } else if (event is AgentRuntimeFailure) {
          _messages[assistantIndex] =
              _VisibleMessage(isUser: false, text: event.message);
        } else if (event is AgentRuntimeCompleted) {
          _status = null;
          _pending = _controller?.pendingConfirmation;
        }
      });
      _scrollBottom();
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (_pending == null) _status = null;
      if (_messages[assistantIndex].text.isEmpty && _pending != null) {
        _messages.removeAt(assistantIndex);
      }
    });
  }

  Future<void> _startVoice() async {
    if (_busy || _recording) return;
    setState(() {
      _recording = true;
      _recordingWillCancel = false;
    });
    try {
      await ref.read(speechChannelProvider).startRecognition();
    } catch (error) {
      if (!mounted) return;
      setState(() => _recording = false);
      _showError('无法开始录音：$error');
    }
  }

  void _updateVoiceDrag(Offset offset) {
    final willCancel = offset.dy < -72;
    if (_recordingWillCancel != willCancel) {
      setState(() => _recordingWillCancel = willCancel);
    }
  }

  Future<void> _stopVoice() async {
    if (!_recording) return;
    if (_recordingWillCancel) {
      await ref.read(speechChannelProvider).cancelRecognition();
      if (!mounted) return;
      setState(() {
        _recording = false;
        _recordingWillCancel = false;
        _status = null;
      });
      return;
    }
    setState(() {
      _recording = false;
      _status = '正在识别语音';
    });
    try {
      unawaited(ref.read(interactionSoundServiceProvider).playXiu());
      final text = await ref.read(speechChannelProvider).stopRecognition();
      _textController.text = text.trim();
      await _send();
    } catch (error) {
      _showError('语音识别失败：$error');
    }
  }

  void _refreshInput() {
    if (mounted) setState(() {});
  }

  void _showError(String text) {
    if (!mounted) return;
    setState(() {
      _busy = false;
      _status = null;
      _messages.add(_VisibleMessage(isUser: false, text: text));
    });
  }

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          const PageHeader(title: '智能记录'),
          const SizedBox(height: 12),
          Expanded(
            child: _messages.isEmpty
                ? const _AgentEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) =>
                        _MessageBubble(message: _messages[index]),
                  ),
          ),
          if (_pending != null)
            _ConfirmationCard(
              pending: _pending!,
              onConfirm: _confirm,
              onCancel: _cancel,
            ),
          if (_status != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(_status!, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
          UnifiedInputBar(
            controller: _textController,
            enabled: (!_busy && _pending == null) || _recording,
            isTextMode: _textInputMode,
            hasText: _textController.text.trim().isNotEmpty,
            onSubmitText: _send,
            onToggleMode: () => setState(() {
              _textInputMode = !_textInputMode;
            }),
            onLongPressStart: _startVoice,
            onLongPressMoveUpdate: _updateVoiceDrag,
            onLongPressEnd: _stopVoice,
          ),
        ],
      ),
    );
  }
}

class _AgentEmptyState extends StatelessWidget {
  const _AgentEmptyState();
  @override
  Widget build(BuildContext context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 46, color: Color(0xff3f6fc7)),
            SizedBox(height: 12),
            Text('我可以帮你管理待办、想法和账目',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            SizedBox(height: 6),
            Text('试试“总结最近的想法”或“午饭花了25元”'),
          ],
        ),
      );
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final _VisibleMessage message;
  @override
  Widget build(BuildContext context) {
    if (message.text.isEmpty) return const SizedBox.shrink();
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: message.isUser ? const Color(0xffdce8ff) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xffe2e6ee)),
        ),
        child: Text(message.text),
      ),
    );
  }
}

class _ConfirmationCard extends StatelessWidget {
  const _ConfirmationCard({
    required this.pending,
    required this.onConfirm,
    required this.onCancel,
  });
  final PendingToolConfirmation pending;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final preview = pending.preview;
    return Card(
      color: const Color(0xfffff8e5),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(preview.title,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            if (preview.description.isNotEmpty) Text(preview.description),
            Text('将影响 ${preview.affectedCount} 条记录'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: onCancel, child: const Text('取消')),
                FilledButton(onPressed: onConfirm, child: const Text('确认执行')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _VisibleMessage {
  const _VisibleMessage({required this.isUser, required this.text});
  final bool isUser;
  final String text;
}

String _friendlyStatus(String raw) {
  if (raw.contains('idea_search')) return '正在查询想法';
  if (raw.contains('todo')) return '正在处理待办';
  if (raw.contains('ledger')) return '正在处理账目';
  return '正在处理';
}
