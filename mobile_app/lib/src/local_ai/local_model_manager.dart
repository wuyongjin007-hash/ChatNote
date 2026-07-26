import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

enum LocalModelKind { asr, asrTokens, vad }

enum LocalModelInstallState {
  notInstalled,
  downloading,
  verifying,
  ready,
  failed
}

class LocalModelSpec {
  const LocalModelSpec({
    required this.id,
    required this.kind,
    required this.name,
    required this.version,
    required this.source,
    required this.downloadUrl,
    required this.fileName,
    required this.bytes,
    required this.sha256,
    required this.minimumRamGb,
  });

  final String id;
  final LocalModelKind kind;
  final String name;
  final String version;
  final String source;
  final Uri downloadUrl;
  final String fileName;
  final int bytes;
  final String sha256;
  final int minimumRamGb;
}

/// Locked model catalogue. A production release should replace downloadUrl with
/// the application's CDN URL while retaining the upstream revision and digest.
class LocalModelCatalog {
  /// Remove language-model artifacts downloaded by earlier releases.
  static const retiredLanguageModelIds = [
    'qwen3-5-0-8b-q4-k-m',
    'qwen2-5-0-5b-instruct-q4-k-m',
  ];

  static final senseVoice = LocalModelSpec(
    id: 'sherpa-sensevoice-small-q8',
    kind: LocalModelKind.asr,
    name: 'Sherpa SenseVoiceSmall Q8',
    version: '1faa169e9bc83503acb1b41541b26de8aaa8fe0f',
    source: 'ModelScope / xiaowangge/sherpa-onnx-sense-voice-small',
    downloadUrl: Uri.parse(
        'https://modelscope.cn/models/xiaowangge/sherpa-onnx-sense-voice-small/resolve/1faa169e9bc83503acb1b41541b26de8aaa8fe0f/model_q8.onnx'),
    fileName: 'model_q8.onnx',
    bytes: 239234116,
    sha256: '6887cdd6fc94c3e4cb5aea8b62dead45229643708d20b8ec8a4a736dfb45f6af',
    minimumRamGb: 1,
  );

  static final fsmnVad = LocalModelSpec(
    id: 'fsmn-vad',
    kind: LocalModelKind.vad,
    name: 'FSMN-VAD',
    version: 'f04fc3013641c8d59c156e2cbf171c1ad596f74d',
    source: 'ModelScope / FunAudioLLM/fsmn-vad-GGUF',
    downloadUrl: Uri.parse(
        'https://modelscope.cn/models/FunAudioLLM/fsmn-vad-GGUF/resolve/f04fc3013641c8d59c156e2cbf171c1ad596f74d/fsmn-vad.gguf'),
    fileName: 'fsmn-vad.gguf',
    bytes: 1720512,
    sha256: '1270f2559c495f4e7b6e739541151027d360761a3fda43fc147034f5719f5479',
    minimumRamGb: 1,
  );

  static final senseVoiceTokens = LocalModelSpec(
    id: 'sherpa-sensevoice-small-tokens',
    kind: LocalModelKind.asrTokens,
    name: 'Sherpa SenseVoice 词表',
    version: '4c244d4b1a7a93539c408d61de4bbcf0966ac39f',
    source: 'ModelScope / xiaowangge/sherpa-onnx-sense-voice-small',
    downloadUrl: Uri.parse(
        'https://modelscope.cn/models/xiaowangge/sherpa-onnx-sense-voice-small/resolve/4c244d4b1a7a93539c408d61de4bbcf0966ac39f/tokens.txt'),
    fileName: 'tokens.txt',
    bytes: 315894,
    sha256: 'f449eb28dc567533d7fa59be34e2abca8784f771850c78a47fb731a31429a1dc',
    minimumRamGb: 1,
  );

  static final all = [senseVoice, senseVoiceTokens, fsmnVad];
}

class LocalModelStatus {
  const LocalModelStatus({
    required this.spec,
    this.state = LocalModelInstallState.notInstalled,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.error,
    this.path,
  });

  final LocalModelSpec spec;
  final LocalModelInstallState state;
  final int downloadedBytes;
  final int totalBytes;
  final String? error;
  final String? path;

  bool get isReady => state == LocalModelInstallState.ready && path != null;
  double get progress => totalBytes <= 0 ? 0 : downloadedBytes / totalBytes;

  LocalModelStatus copyWith({
    LocalModelInstallState? state,
    int? downloadedBytes,
    int? totalBytes,
    String? error,
    String? path,
    bool clearError = false,
  }) =>
      LocalModelStatus(
        spec: spec,
        state: state ?? this.state,
        downloadedBytes: downloadedBytes ?? this.downloadedBytes,
        totalBytes: totalBytes ?? this.totalBytes,
        error: clearError ? null : error ?? this.error,
        path: path ?? this.path,
      );
}

class LocalModelManager {
  LocalModelManager({http.Client? client}) : _client = client ?? http.Client() {
    for (final spec in LocalModelCatalog.all) {
      _statuses[spec.id] = LocalModelStatus(spec: spec, totalBytes: spec.bytes);
    }
  }

  final http.Client _client;
  final Map<String, LocalModelStatus> _statuses = {};
  final _changes = StreamController<List<LocalModelStatus>>.broadcast();
  final Map<String, StreamSubscription<List<int>>> _downloads = {};

  List<LocalModelStatus> get statuses => List.unmodifiable(_statuses.values);
  Stream<List<LocalModelStatus>> get changes => _changes.stream;
  LocalModelStatus statusFor(LocalModelKind kind) =>
      _statuses.values.firstWhere((status) => status.spec.kind == kind);

  Future<void> initialize() async {
    final root = await getApplicationSupportDirectory();
    await _removeRetiredLanguageModels(root);
    for (final status in statuses) {
      final file = await _modelFile(status.spec);
      if (await file.exists()) {
        _set(status.copyWith(
          state: LocalModelInstallState.ready,
          downloadedBytes: await file.length(),
          totalBytes: status.spec.bytes,
          path: file.path,
          clearError: true,
        ));
      }
    }
  }

  Future<void> _removeRetiredLanguageModels(Directory root) async {
    for (final id in LocalModelCatalog.retiredLanguageModelIds) {
      final directory = Directory(p.join(root.path, 'local_models', id));
      if (await directory.exists()) {
        await directory.delete(recursive: true);
      }
    }
  }

  Future<void> download(LocalModelSpec spec) async {
    if (spec.downloadUrl.host == 'example.invalid' || spec.sha256.isEmpty) {
      _set(_statuses[spec.id]!.copyWith(
        state: LocalModelInstallState.failed,
        error: '此模型尚未配置经过 SHA-256 锁定的下载源。',
      ));
      return;
    }
    await cancel(spec);
    final target = await _modelFile(spec);
    await target.parent.create(recursive: true);
    final partial = File('${target.path}.part');
    final existing = await partial.exists() ? await partial.length() : 0;
    final request = http.Request('GET', spec.downloadUrl);
    if (existing > 0) request.headers['Range'] = 'bytes=$existing-';
    _set(_statuses[spec.id]!.copyWith(
      state: LocalModelInstallState.downloading,
      downloadedBytes: existing,
      totalBytes: spec.bytes,
      clearError: true,
    ));
    try {
      final response = await _client.send(request);
      if (response.statusCode != 200 && response.statusCode != 206) {
        throw HttpException('下载失败（HTTP ${response.statusCode}）');
      }
      final append = response.statusCode == 206 && existing > 0;
      final sink =
          partial.openWrite(mode: append ? FileMode.append : FileMode.write);
      var received = append ? existing : 0;
      final subscription = response.stream.listen(
        (chunk) {
          sink.add(chunk);
          received += chunk.length;
          _set(_statuses[spec.id]!.copyWith(downloadedBytes: received));
        },
        onError: (Object error, StackTrace stackTrace) async {
          await sink.close();
          _set(_statuses[spec.id]!.copyWith(
            state: LocalModelInstallState.failed,
            error: error.toString(),
          ));
        },
        onDone: () async {
          await sink.close();
          _downloads.remove(spec.id);
          await _verifyAndInstall(spec, partial, target);
        },
        cancelOnError: true,
      );
      _downloads[spec.id] = subscription;
    } catch (error) {
      _set(_statuses[spec.id]!.copyWith(
        state: LocalModelInstallState.failed,
        error: error.toString(),
      ));
    }
  }

  Future<void> _verifyAndInstall(
      LocalModelSpec spec, File partial, File target) async {
    _set(_statuses[spec.id]!.copyWith(state: LocalModelInstallState.verifying));
    try {
      final digest = await sha256.bind(partial.openRead()).first;
      if (digest.toString().toLowerCase() != spec.sha256.toLowerCase()) {
        throw const FormatException('SHA-256 校验失败，文件未安装。');
      }
      if (await target.exists()) await target.delete();
      await partial.rename(target.path);
      _set(_statuses[spec.id]!.copyWith(
        state: LocalModelInstallState.ready,
        downloadedBytes: await target.length(),
        totalBytes: spec.bytes,
        path: target.path,
        clearError: true,
      ));
    } catch (error) {
      _set(_statuses[spec.id]!.copyWith(
        state: LocalModelInstallState.failed,
        error: error.toString(),
      ));
    }
  }

  Future<void> cancel(LocalModelSpec spec) async {
    await _downloads.remove(spec.id)?.cancel();
    final status = _statuses[spec.id]!;
    if (status.state == LocalModelInstallState.downloading) {
      _set(status.copyWith(state: LocalModelInstallState.notInstalled));
    }
  }

  Future<void> delete(LocalModelSpec spec) async {
    await cancel(spec);
    final target = await _modelFile(spec);
    final partial = File('${target.path}.part');
    if (await target.exists()) await target.delete();
    if (await partial.exists()) await partial.delete();
    _set(LocalModelStatus(spec: spec, totalBytes: spec.bytes));
  }

  Future<File> _modelFile(LocalModelSpec spec) async {
    final root = await getApplicationSupportDirectory();
    return File(p.join(
        root.path, 'local_models', spec.id, spec.version, spec.fileName));
  }

  void _set(LocalModelStatus status) {
    _statuses[status.spec.id] = status;
    _changes.add(statuses);
  }

  Future<void> dispose() async {
    for (final download in _downloads.values) {
      await download.cancel();
    }
    _downloads.clear();
    await _changes.close();
    _client.close();
  }
}
