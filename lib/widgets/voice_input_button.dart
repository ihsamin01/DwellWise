import 'dart:async';

import 'package:flutter/material.dart';

import '../config/app_colors.dart';
import '../services/assistant_service.dart';
import '../services/chat_attachment_service.dart';

/// Mic button that dictates into a text field.
///
/// Tap once and talk. It stops on its own after a few seconds of silence,
/// transcribes, and drops the text into the field — sending stays a separate,
/// deliberate tap, so a mis-heard word can be fixed first.
///
/// Transcription goes through Gemini rather than the device recogniser, which
/// has to be told which language to expect and cannot work it out: asking for
/// the wrong one is what wrote spoken Bangla in Latin letters. Gemini hears
/// the language and writes it in its own script.
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

enum _MicState { idle, listening, transcribing }

class _VoiceInputButtonState extends State<VoiceInputButton> {
  final ChatAttachmentService _recorder = ChatAttachmentService();
  final AssistantService _assistant = AssistantService();

  StreamSubscription<dynamic>? _amplitude;
  Timer? _silenceTimer;
  _MicState _state = _MicState.idle;

  /// How long a pause ends the recording. Long enough to think mid-sentence,
  /// short enough not to sit there recording nothing.
  static const Duration _silenceLimit = Duration(seconds: 5);

  /// Amplitude in dB above which the mic counts as hearing speech. Silence
  /// sits near -60 and quiet speech around -30.
  static const double _speechThreshold = -35;

  Future<void> _toggle() async {
    switch (_state) {
      case _MicState.transcribing:
        return;
      case _MicState.listening:
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
          content:
              Text('Microphone permission is needed to speak your request.'),
        ),
      );
      return;
    }

    setState(() => _state = _MicState.listening);
    _restartSilenceTimer();

    // Every burst of sound pushes the deadline back, so the recording ends a
    // few seconds after the user actually stops talking rather than after a
    // fixed length.
    _amplitude = _recorder.amplitudeStream().listen((amplitude) {
      if (amplitude.current > _speechThreshold) _restartSilenceTimer();
    });
  }

  void _restartSilenceTimer() {
    _silenceTimer?.cancel();
    _silenceTimer = Timer(_silenceLimit, () {
      if (_state == _MicState.listening) _finish();
    });
  }

  Future<void> _finish() async {
    _silenceTimer?.cancel();
    await _amplitude?.cancel();
    _amplitude = null;

    if (mounted) setState(() => _state = _MicState.transcribing);

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
        const SnackBar(
            content: Text('Could not catch that. Please try again.')),
      );
      return;
    }
    widget.onResult(text);
  }

  @override
  void dispose() {
    _silenceTimer?.cancel();
    _amplitude?.cancel();
    _recorder.cancelVoiceRecording();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;
    final listening = _state == _MicState.listening;
    final busy = _state == _MicState.transcribing;

    return GestureDetector(
      onTap: widget.enabled && !busy ? _toggle : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          // Listening is shown with the app's own accent, not an alarm colour:
          // dictating is a normal thing to be doing, not a warning.
          color: listening ? colors.primaryTint : colors.background,
          shape: BoxShape.circle,
          border: Border.all(
            color: listening ? colors.primary : colors.border,
            width: listening ? 1.5 : 1,
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
                listening ? Icons.graphic_eq : Icons.mic_none,
                size: 20,
                color: listening ? colors.primary : colors.textSecondary,
              ),
      ),
    );
  }
}
