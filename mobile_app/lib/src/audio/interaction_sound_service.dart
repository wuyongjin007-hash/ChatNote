import 'dart:math' as math;
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';

abstract interface class InteractionSoundService {
  Future<void> playDing();

  Future<void> playXiu();

  Future<void> dispose();
}

class LocalInteractionSoundService implements InteractionSoundService {
  LocalInteractionSoundService({AudioPlayer? player})
      : _player = player ?? AudioPlayer();

  final AudioPlayer _player;

  // Android SoundPool cannot play BytesSource, so in-memory WAV data must use
  // the standard MediaPlayer backend.
  static const playbackMode = PlayerMode.mediaPlayer;

  static final Uint8List _dingBytes = _createTone(
    duration: const Duration(milliseconds: 340),
    sample: (time, progress) {
      final envelope = math.pow(1 - progress, 2.5).toDouble();
      return envelope *
          (0.72 * math.sin(2 * math.pi * 1046.5 * time) +
              0.28 * math.sin(2 * math.pi * 1568 * time));
    },
  );

  static final Uint8List _xiuBytes = _createTone(
    duration: const Duration(milliseconds: 260),
    sample: (time, progress) {
      final frequency = 520 + (1500 * progress);
      final envelope = math.sin(math.pi * progress) * (1 - 0.35 * progress);
      return envelope * math.sin(2 * math.pi * frequency * time);
    },
  );

  @override
  Future<void> playDing() => _play(_dingBytes, volume: 0.58);

  @override
  Future<void> playXiu() => _play(_xiuBytes, volume: 0.46);

  Future<void> _play(Uint8List bytes, {required double volume}) async {
    try {
      await _player.play(
        BytesSource(bytes),
        volume: volume,
        mode: playbackMode,
      );
    } catch (_) {
      // Interaction sounds are optional and must not interrupt core actions.
    }
  }

  @override
  Future<void> dispose() => _player.dispose();

  static Uint8List _createTone({
    required Duration duration,
    required double Function(double time, double progress) sample,
  }) {
    const sampleRate = 44100;
    const bytesPerSample = 2;
    final sampleCount =
        (sampleRate * duration.inMicroseconds / 1000000).round();
    final dataLength = sampleCount * bytesPerSample;
    final bytes = ByteData(44 + dataLength);

    void writeAscii(int offset, String value) {
      for (var index = 0; index < value.length; index++) {
        bytes.setUint8(offset + index, value.codeUnitAt(index));
      }
    }

    writeAscii(0, 'RIFF');
    bytes.setUint32(4, 36 + dataLength, Endian.little);
    writeAscii(8, 'WAVE');
    writeAscii(12, 'fmt ');
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little);
    bytes.setUint16(22, 1, Endian.little);
    bytes.setUint32(24, sampleRate, Endian.little);
    bytes.setUint32(28, sampleRate * bytesPerSample, Endian.little);
    bytes.setUint16(32, bytesPerSample, Endian.little);
    bytes.setUint16(34, 16, Endian.little);
    writeAscii(36, 'data');
    bytes.setUint32(40, dataLength, Endian.little);

    for (var index = 0; index < sampleCount; index++) {
      final time = index / sampleRate;
      final progress = index / sampleCount;
      final value = sample(time, progress).clamp(-1.0, 1.0);
      bytes.setInt16(
          44 + index * bytesPerSample, (value * 32767).round(), Endian.little);
    }
    return bytes.buffer.asUint8List();
  }
}
