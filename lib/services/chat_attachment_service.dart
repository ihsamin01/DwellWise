import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// A file the user picked to attach (image, PDF or other document).
class PickedAttachment {
  const PickedAttachment({
    required this.path,
    required this.name,
  });

  final String path;
  final String name;
}

/// A finished voice recording.
class VoiceRecording {
  const VoiceRecording({
    required this.path,
    required this.durationMs,
  });

  final String path;
  final int durationMs;
}

/// Wraps all device-side attachment sources used by the chat composer:
/// camera, gallery, documents, voice recording and location. Keeps the UI
/// free of plugin details and permission handling.
class ChatAttachmentService {
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _recorder = AudioRecorder();

  DateTime? _recordingStartedAt;

  // ── Images ────────────────────────────────────────────────────────────
  Future<PickedAttachment?> pickCameraPhoto() async {
    final XFile? file = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1920,
    );
    return file == null ? null : PickedAttachment(path: file.path, name: file.name);
  }

  Future<PickedAttachment?> pickGalleryImage() async {
    final XFile? file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1920,
    );
    return file == null ? null : PickedAttachment(path: file.path, name: file.name);
  }

  // ── Documents (PDF and other files from device storage) ───────────────
  Future<PickedAttachment?> pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx'],
    );
    final picked = result?.files.single;
    if (picked == null || picked.path == null) {
      return null;
    }
    return PickedAttachment(path: picked.path!, name: picked.name);
  }

  // ── Location ──────────────────────────────────────────────────────────
  /// Returns the user's current position, or throws a [LocationException]
  /// with a human-readable reason (service off / permission denied).
  Future<Position> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException('Location services are turned off.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationException('Location permission was denied.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
          'Location permission is permanently denied. Enable it in Settings.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  // ── Voice recording ───────────────────────────────────────────────────
  Future<bool> hasMicPermission() => _recorder.hasPermission();

  bool get isRecording => _recordingStartedAt != null;

  /// Live microphone amplitude for the waveform animation.
  Stream<Amplitude> amplitudeStream() =>
      _recorder.onAmplitudeChanged(const Duration(milliseconds: 200));

  Future<bool> startVoiceRecording() async {
    if (!await _recorder.hasPermission()) {
      return false;
    }
    final dir = await getApplicationDocumentsDirectory();
    final path =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(), path: path);
    _recordingStartedAt = DateTime.now();
    return true;
  }

  /// Stops and returns the recording, or null if it was too short / failed.
  Future<VoiceRecording?> stopVoiceRecording() async {
    if (_recordingStartedAt == null) {
      return null;
    }
    final startedAt = _recordingStartedAt!;
    _recordingStartedAt = null;

    final path = await _recorder.stop();
    if (path == null) {
      return null;
    }
    final durationMs = DateTime.now().difference(startedAt).inMilliseconds;
    if (durationMs < 500) {
      // Too short to be a real message — discard the file.
      _safeDelete(path);
      return null;
    }
    return VoiceRecording(path: path, durationMs: durationMs);
  }

  Future<void> cancelVoiceRecording() async {
    if (_recordingStartedAt == null) {
      return;
    }
    _recordingStartedAt = null;
    final path = await _recorder.stop();
    if (path != null) {
      _safeDelete(path);
    }
  }

  void _safeDelete(String path) {
    try {
      final file = File(path);
      if (file.existsSync()) {
        file.deleteSync();
      }
    } catch (_) {
      // best-effort cleanup
    }
  }

  Future<void> dispose() async {
    await _recorder.dispose();
  }
}

/// Thrown when the current location cannot be obtained.
class LocationException implements Exception {
  const LocationException(this.message);
  final String message;

  @override
  String toString() => message;
}
