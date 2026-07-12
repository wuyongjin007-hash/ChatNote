import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Shared voice/text input strip used by both recording experiences.
class UnifiedInputBar extends StatefulWidget {
  const UnifiedInputBar({
    super.key,
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
  State<UnifiedInputBar> createState() => _UnifiedInputBarState();
}

class _UnifiedInputBarState extends State<UnifiedInputBar> {
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
    if (event.pointer != _activeVoicePointer) return;
    final origin = _voicePointerOrigin;
    if (origin == null) return;
    widget.onLongPressMoveUpdate(event.position - origin);
  }

  void _finishVoicePointer(int pointer) {
    if (pointer != _activeVoicePointer) return;
    _activeVoicePointer = null;
    _voicePointerOrigin = null;
    widget.onLongPressEnd();
  }

  @override
  Widget build(BuildContext context) => Container(
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
              icon: const Icon(Icons.photo_camera_outlined,
                  color: AppColors.textSecondary),
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
                        onSubmitted: widget.enabled
                            ? (_) => widget.onSubmitText()
                            : null,
                        decoration: InputDecoration(
                          hintText: '发送消息或按住说话...',
                          isDense: true,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          suffixIconConstraints:
                              const BoxConstraints(minWidth: 36, minHeight: 36),
                          suffixIcon: widget.hasText
                              ? IconButton(
                                  icon: const Icon(Icons.send_rounded),
                                  tooltip: '发送',
                                  onPressed: widget.enabled
                                      ? widget.onSubmitText
                                      : null,
                                )
                              : null,
                        ),
                      )
                    : Listener(
                        key: const Key('voice-press-button'),
                        onPointerDown: _handleVoicePointerDown,
                        onPointerMove: _handleVoicePointerMove,
                        onPointerUp: (event) =>
                            _finishVoicePointer(event.pointer),
                        onPointerCancel: (event) =>
                            _finishVoicePointer(event.pointer),
                        child: Container(
                          height: 52,
                          alignment: Alignment.center,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _SideSignalIcon(color: Color(0xffc7921e)),
                              SizedBox(width: 8),
                              Text('按住说话',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary)),
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
                  : const Icon(Icons.keyboard_alt_outlined,
                      color: AppColors.textSecondary),
              tooltip: widget.isTextMode ? '切换到语音输入' : '切换到文字输入',
            ),
          ],
        ),
      );
}

class _SideSignalIcon extends StatelessWidget {
  const _SideSignalIcon({this.color});
  final Color? color;

  @override
  Widget build(BuildContext context) => CustomPaint(
        key: const Key('voice-side-signal-icon'),
        size: const Size(28, 28),
        painter: _SideSignalPainter(
          color:
              color ?? IconTheme.of(context).color ?? const Color(0xff111827),
        ),
      );
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
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -0.82,
          1.64, false, paint);
    }
    canvas.drawCircle(center, 1.8, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SideSignalPainter oldDelegate) =>
      oldDelegate.color != color;
}
