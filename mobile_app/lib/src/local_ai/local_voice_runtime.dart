import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

import 'local_model_manager.dart';

class LocalVoiceRuntimeException implements Exception {
  const LocalVoiceRuntimeException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Builds the Sherpa runtime configuration for the downloaded ONNX artifact.
sherpa.OfflineRecognizerConfig buildSenseVoiceRecognizerConfig({
  required String modelPath,
  required String tokensPath,
}) {
  return sherpa.OfflineRecognizerConfig(
    model: sherpa.OfflineModelConfig(
      senseVoice: sherpa.OfflineSenseVoiceModelConfig(
        model: modelPath,
        language: 'zh',
        useInverseTextNormalization: true,
      ),
      tokens: tokensPath,
      numThreads: 4,
      debug: false,
      provider: 'cpu',
    ),
  );
}

/// Local-only recording and SenseVoice transcription. No text model is loaded
/// here; transcript interpretation is handled by the rule-first capture agent.
class LocalVoiceSpeechService {
  LocalVoiceSpeechService(
    this._models, {
    AudioRecorder? recorder,
  }) : _recorder = recorder ?? AudioRecorder();

  final LocalModelManager _models;
  final AudioRecorder _recorder;
  String? _currentPath;
  sherpa.OfflineRecognizer? _recognizer;
  String? _recognizerModelPath;

  Future<void> prepare() async {
    await _models.initialize();
    final senseVoice = _requireReady(LocalModelKind.asr);
    final tokens = _requireReady(LocalModelKind.asrTokens);
    _ensureRecognizer(senseVoice.path!, tokens.path!);
  }

  Future<void> warmUp() => prepare();

  Future<void> startRecognition() async {
    await prepare();
    if (!await _recorder.hasPermission()) {
      throw const LocalVoiceRuntimeException('没有麦克风权限');
    }
    final directory = await getTemporaryDirectory();
    final path = p.join(
      directory.path,
      'idea-capture-${DateTime.now().millisecondsSinceEpoch}.wav',
    );
    _currentPath = path;
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: path,
    );
  }

  Future<String> stopRecognition() async {
    final path = await _recorder.stop() ?? _currentPath;
    _currentPath = null;
    if (path == null) {
      throw const LocalVoiceRuntimeException('没有生成录音文件');
    }
    final audio = File(path);
    try {
      if (!await audio.exists() || await audio.length() <= 44) {
        throw const LocalVoiceRuntimeException('录音为空或时间太短，请按住按钮说完后再松开');
      }
      await prepare();
      final wave = sherpa.readWave(path);
      if (wave.samples.isEmpty || wave.sampleRate <= 0) {
        throw const LocalVoiceRuntimeException('无法读取本地 WAV 录音');
      }
      final recognizer = _recognizer;
      if (recognizer == null) {
        throw const LocalVoiceRuntimeException('SenseVoice 尚未就绪');
      }
      final stream = recognizer.createStream();
      try {
        stream.acceptWaveform(
          samples: wave.samples,
          sampleRate: wave.sampleRate,
        );
        recognizer.decode(stream);
        final text = recognizer.getResult(stream).text.trim();
        if (text.isEmpty) {
          throw const LocalVoiceRuntimeException('未识别到清晰语音内容');
        }
        return text;
      } finally {
        stream.free();
      }
    } finally {
      if (await audio.exists()) await audio.delete();
    }
  }

  Future<void> cancelRecognition() async {
    final path = await _recorder.stop() ?? _currentPath;
    _currentPath = null;
    if (path != null) {
      final audio = File(path);
      if (await audio.exists()) await audio.delete();
    }
  }

  LocalModelStatus _requireReady(LocalModelKind kind) {
    final status = _models.statusFor(kind);
    if (!status.isReady) {
      throw LocalVoiceRuntimeException('${status.spec.name} 尚未下载或校验完成');
    }
    return status;
  }

  void _ensureRecognizer(String modelPath, String tokensPath) {
    if (_recognizerModelPath == modelPath && _recognizer != null) return;
    _recognizer?.free();
    sherpa.initBindings();
    _recognizer = sherpa.OfflineRecognizer(
      buildSenseVoiceRecognizerConfig(
        modelPath: modelPath,
        tokensPath: tokensPath,
      ),
    );
    _recognizerModelPath = modelPath;
  }

  Future<void> dispose() async {
    _recognizer?.free();
    _recognizer = null;
    _recognizerModelPath = null;
    await _recorder.dispose();
  }
}
