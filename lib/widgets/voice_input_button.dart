import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../config/app_colors.dart';

/// Mic button that dictates into a text field.
///
/// Speech recognition runs on the device rather than through Gemini: it costs
/// no API quota, works without a round trip, and the text lands in the same
/// field typing would fill — so voice and typing are the same path from here
/// on, and the user can correct a mis-heard word before sending.
class VoiceInputButton extends StatefulWidget {
  const VoiceInputButton({
    super.key,
    required this.onResult,
    required this.colors,
    this.localeId,
    this.enabled = true,
  });

  /// Called with the transcript as it grows, so the field fills while talking.
  final ValueChanged<String> onResult;

  final AppColors colors;

  /// Which language to listen for, e.g. 'bn_BD'. Falls back to the device
  /// default when the locale is not installed.
  final String? localeId;

  final bool enabled;

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  final SpeechToText _speech = SpeechToText();

  bool _available = false;
  bool _listening = false;
  bool _checked = false;

  Future<void> _toggle() async {
    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }

    if (!_checked) {
      _checked = true;
      _available = await _speech.initialize(
        onStatus: (status) {
          // The recogniser stops itself after a pause; reflect that on the
          // button instead of leaving it looking like it is still listening.
          if (status == 'done' || status == 'notListening') {
            if (mounted) setState(() => _listening = false);
          }
        },
        onError: (_) {
          if (mounted) setState(() => _listening = false);
        },
      );
    }

    if (!_available) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Speech recognition is not available on this device. '
            'You can type instead.',
          ),
        ),
      );
      return;
    }

    final locale = await _resolveLocale();
    await _speech.listen(
      onResult: (result) => widget.onResult(result.recognizedWords),
      listenOptions: SpeechListenOptions(
        localeId: locale,
        // Partial results make the field fill as the user speaks, which is
        // what makes it feel like dictation rather than a recording.
        partialResults: true,
        cancelOnError: true,
      ),
    );

    if (mounted) setState(() => _listening = true);
  }

  /// The requested locale if the device has it, otherwise its default — asking
  /// for a missing locale fails outright on some devices.
  Future<String?> _resolveLocale() async {
    final wanted = widget.localeId;
    if (wanted == null) return null;
    final locales = await _speech.locales();
    final match = locales.any((l) => l.localeId == wanted);
    return match ? wanted : null;
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;

    return GestureDetector(
      onTap: widget.enabled ? _toggle : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _listening ? const Color(0xffDC2626) : colors.background,
          shape: BoxShape.circle,
          border: Border.all(
            color: _listening ? const Color(0xffDC2626) : colors.border,
          ),
        ),
        child: Icon(
          _listening ? Icons.stop : Icons.mic_none,
          size: 20,
          color: _listening ? Colors.white : colors.textSecondary,
        ),
      ),
    );
  }
}
