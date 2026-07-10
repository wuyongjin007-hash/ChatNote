import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'volcengine_ark_files_client.dart';

class VolcengineSpeechService {
  VolcengineSpeechService(this._arkClient, {AudioRecorder? recorder})
      : _recorder = recorder ?? AudioRecorder();

  final VolcengineArkFilesClient _arkClient;
  final AudioRecorder _recorder;
  String? _currentPath;

  Future<void> startRecognition() async {
    if (!await _recorder.hasPermission()) {
      throw const VolcengineArkException('没有麦克风权限');
    }

    final dir = await getTemporaryDirectory();
    final path = p.join(
        dir.path, 'idea-capture-${DateTime.now().millisecondsSinceEpoch}.wav');
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
    if (path == null || !File(path).existsSync()) {
      throw const VolcengineArkException('没有生成可上传的录音文件');
    }
    final file = File(path);
    final length = await file.length();
    if (length <= 44) {
      throw const VolcengineArkException('录音文件为空或时间太短，请按住按钮说完后再松开');
    }
    return _arkClient.understandAudioFile(path);
  }

  Future<void> cancelRecognition() async {
    final path = await _recorder.stop() ?? _currentPath;
    _currentPath = null;
    if (path != null) {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    }
  }
}
