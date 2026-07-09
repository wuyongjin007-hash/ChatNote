import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../settings/settings_store.dart';

class VolcengineArkFilesClient {
  VolcengineArkFilesClient(this._settings, {http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  final SettingsStore _settings;
  final http.Client _httpClient;

  Future<String> understandAudioFile(String audioPath) async {
    final apiKey = await _settings.volcengineArkApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw const VolcengineArkException('请先在设置页填写火山方舟 API Key');
    }

    final baseUrl = (await _settings.volcengineArkBaseUrl()).replaceAll(RegExp(r'/$'), '');
    final model = await _settings.volcengineArkSpeechModel();
    final fileId = await _uploadAudioFile(
      baseUrl: baseUrl,
      apiKey: apiKey,
      audioPath: audioPath,
    );

    return _understandByFileId(
      baseUrl: baseUrl,
      apiKey: apiKey,
      model: model,
      fileId: fileId,
    );
  }

  Future<String> _uploadAudioFile({
    required String baseUrl,
    required String apiKey,
    required String audioPath,
  }) async {
    final file = File(audioPath);
    if (!await file.exists()) {
      throw VolcengineArkException('音频文件不存在：$audioPath');
    }

    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/files'))
      ..headers['authorization'] = 'Bearer $apiKey'
      ..fields['purpose'] = 'user_data'
      ..files.add(await http.MultipartFile.fromPath('file', audioPath));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VolcengineArkException('上传音频失败：HTTP ${response.statusCode} ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final fileId = body['id']?.toString();
    if (fileId == null || fileId.isEmpty) {
      throw VolcengineArkException('上传音频成功，但响应里没有 file_id：${response.body}');
    }
    return fileId;
  }

  Future<String> _understandByFileId({
    required String baseUrl,
    required String apiKey,
    required String model,
    required String fileId,
  }) async {
    final response = await _httpClient.post(
      Uri.parse('$baseUrl/responses'),
      headers: {
        'authorization': 'Bearer $apiKey',
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'model': model,
        'input': [
          {
            'role': 'user',
            'content': [
              {
                'type': 'input_audio',
                'file_id': fileId,
              },
              {
                'type': 'input_text',
                'text': '请识别音频中的内容，以文字形式返回识别结果。',
              },
            ],
          },
        ],
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VolcengineArkException('语音理解失败：HTTP ${response.statusCode} ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final text = _extractResponseText(body);
    if (text.isEmpty) {
      throw VolcengineArkException('语音理解响应中没有可用文本：${response.body}');
    }
    return text;
  }

  String _extractResponseText(Map<String, dynamic> body) {
    final outputText = body['output_text'];
    if (outputText is String && outputText.trim().isNotEmpty) {
      return outputText.trim();
    }

    final output = body['output'];
    if (output is List) {
      final buffer = StringBuffer();
      for (final item in output) {
        if (item is! Map<String, dynamic>) {
          continue;
        }
        final content = item['content'];
        if (content is List) {
          for (final part in content) {
            if (part is Map<String, dynamic>) {
              final text = part['text'];
              if (text is String) {
                buffer.write(text);
              }
            }
          }
        }
      }
      return buffer.toString().trim();
    }

    return '';
  }
}

class VolcengineArkException implements Exception {
  const VolcengineArkException(this.message);

  final String message;

  @override
  String toString() => message;
}
