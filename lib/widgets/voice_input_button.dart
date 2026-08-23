import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../config/app_colors.dart';

/// Mic button that dictates straight into a text field.
class VoiceInputButton extends StatefulWidget {
  const VoiceInputButton({
    super.key,
    required this.onResult,
    required this.colors,
    this.enabled = true,
  });

  /// Called repeatedly as the transcript grows, then once when it settles.
  final ValueChanged<String> onResult;

  final AppColors colors;
  final bool enabled;

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  final SpeechToText _speech = SpeechToText();

  bool _available = false;
  bool _initialised = false;
  bool _listening = false;

  /// Bangla first.
  static const List<String> _preferredLocales = ['bn_BD', 'bn-BD', 'bn'];

  Future<void> _toggle() async {
    if (_listening) {
      await _speech.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }

    if (!_initialised) {
      _initialised = true;
      _available = await _speech.initialize(
        onStatus: (status) {
          // The recogniser ends the session itself once the speaker stops.
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

    await _speech.listen(
      onResult: (result) => widget.onResult(result.recognizedWords),
      // Ends a few seconds after the speaker does.
      pauseFor: const Duration(seconds: 5),
      listenFor: const Duration(minutes: 1),
      listenOptions: SpeechListenOptions(
        localeId: await _resolveLocale(),
        // Puts the words in the field while they are being spoken.
        partialResults: true,
        // Keeps listening through a stumble instead of throwing the whole
        // recording away.
        cancelOnError: false,
        // The network recogniser handles Bangla markedly better than the
        // on-device one.
        onDevice: false,
      ),
    );

    if (mounted) setState(() => _listening = true);
  }

  /// The first preferred locale the device actually has, or its default.
  Future<String?> _resolveLocale() async {
    final installed = await _speech.locales();
    final ids = installed.map((l) => l.localeId).toList();

    for (final wanted in _preferredLocales) {
      for (final id in ids) {
        if (id.toLowerCase() == wanted.toLowerCase()) return id;
      }
    }
    for (final id in ids) {
      if (id.toLowerCase().startsWith('bn')) return id;
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
          // The app's own accent while listening.
          color: _listening ? colors.primaryTint : colors.background,
          shape: BoxShape.circle,
          border: Border.all(
            color: _listening ? colors.primary : colors.border,
            width: _listening ? 1.5 : 1,
          ),
        ),
        child: Icon(
          _listening ? Icons.graphic_eq : Icons.mic_none,
          size: 20,
          color: _listening ? colors.primary : colors.textSecondary,
        ),
      ),
    );
  }
}
