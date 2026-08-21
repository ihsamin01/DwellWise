import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../config/app_colors.dart';

/// Mic button that dictates into a text field.
///
/// Recognition runs on the device rather than through Gemini: it costs no API
/// quota, needs no round trip, and the text lands in the same field typing
/// fills — so a mis-heard word can be corrected before sending.
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
  /// default when that locale is not installed.
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
      // The platform default cuts off after about three seconds of silence,
      // which ends the sentence while someone is still thinking. These give
      // room to pause mid-request without losing the recording.
      pauseFor: const Duration(seconds: 8),
      listenFor: const Duration(minutes: 1),
      listenOptions: SpeechListenOptions(
        localeId: locale,
        // Partial results fill the field as the user speaks, which is what
        // makes it feel like dictation rather than a recording.
        partialResults: true,
        cancelOnError: true,
      ),
    );

    if (mounted) setState(() => _listening = true);
  }

  /// The requested locale if the device has it, otherwise its default —
  /// asking for a missing locale fails outright on some devices.
  Future<String?> _resolveLocale() async {
    final wanted = widget.localeId;
    if (wanted == null) return null;
    final locales = await _speech.locales();
    final match = locales.any((l) => l.localeId == wanted);
    if (match) return wanted;

    // 'bn_BD' may be installed as 'bn-BD' or plain 'bn' depending on the
    // device, so fall back to any locale in the same language.
    final language = wanted.split(RegExp('[_-]')).first.toLowerCase();
    for (final locale in locales) {
      if (locale.localeId.toLowerCase().startsWith(language)) {
        return locale.localeId;
      }
    }
    return null;
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

/// Picks which language the mic listens in.
///
/// Android's recogniser is told one language up front — it cannot detect
/// Bangla and English on its own, and asking for the wrong one is what turns
/// spoken Bangla into Latin letters. So the choice is the user's, sitting next
/// to the mic where the consequence is visible.
class SpeechLanguageToggle extends StatelessWidget {
  const SpeechLanguageToggle({
    super.key,
    required this.isBangla,
    required this.onChanged,
    required this.colors,
  });

  final bool isBangla;
  final ValueChanged<bool> onChanged;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isBangla),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: colors.border),
        ),
        alignment: Alignment.center,
        child: Text(
          isBangla ? 'বাং' : 'EN',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: colors.textSecondary,
          ),
        ),
      ),
    );
  }
}
