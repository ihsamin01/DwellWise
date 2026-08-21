import 'package:flutter/material.dart';

import '../config/app_colors.dart';
import '../services/assistant_service.dart';
import '../services/chat_attachment_service.dart';

/// Mic button that dictates into a text field.
///
/// The recording is transcribed by Gemini rather than the device recogniser.
/// Android has to be told which language to expect and cannot work it out
/// itself, so the on-device route needed the user to declare Bangla or English
/// before speaking — and getting it wrong wrote Bangla in Latin letters.
/// Gemini hears which language is spoken and writes it in that script, so
/// there is nothing to set.
///
/// The transcript lands in the same field typing fills, so a mis-heard word
/// can still be corrected before sending.
class VoiceInputButton extends StatefulWidget {
  const VoiceInputButton({
    super.key,
    required this.onResult,
    required this.colors,
    this.enabled = true,
  });

  /// Called once with the finished transcript.
  final ValueChanged<String> onResult;

  final AppColors colors;
  final bool enabled;

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

enum _MicState { idle, recording, transcribing }

class _VoiceInputButtonState extends State<VoiceInputButton> {
  final ChatAttachmentService _recorder = ChatAttachmentService();
  final AssistantService _assistant = AssistantService();

  _MicState _state = _MicState.idle;

  Future<void> _toggle() async {
    switch (_state) {
      case _MicState.transcribing:
        return; // Already working; another tap would start a second request.
      case _MicState.recording:
        await _finish();
      case _MicState.idle:
        await _start();
    }
  }

  Future<void> _start() async {
    final started = await _recorder.startVoiceRecording();
    if (!mounted) return;

    if (!started) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Microphone permission is needed to speak your request.'),
        ),
      );
      return;
    }
    setState(() => _state = _MicState.recording);
  }

  Future<void> _finish() async {
    setState(() => _state = _MicState.transcribing);

    final recording = await _recorder.stopVoiceRecording();
    if (recording == null) {
      if (mounted) setState(() => _state = _MicState.idle);
      return;
    }

    final text = await _assistant.transcribe(recording.path);
    if (!mounted) return;

    setState(() => _state = _MicState.idle);

    if (text == null || text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not catch that. Please try again.')),
      );
      return;
    }
    widget.onResult(text);
  }

  @override
  void dispose() {
    _recorder.cancelVoiceRecording();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final recording = _state == _MicState.recording;
    final busy = _state == _MicState.transcribing;

    return GestureDetector(
      onTap: widget.enabled && !busy ? _toggle : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: recording ? const Color(0xffDC2626) : colors.background,
          shape: BoxShape.circle,
          border: Border.all(
            color: recording ? const Color(0xffDC2626) : colors.border,
          ),
        ),
        child: busy
            ? Padding(
                padding: const EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(colors.textSecondary),
                ),
              )
            : Icon(
                recording ? Icons.stop : Icons.mic_none,
                size: 20,
                color: recording ? Colors.white : colors.textSecondary,
              ),
      ),
    );
  }
}
