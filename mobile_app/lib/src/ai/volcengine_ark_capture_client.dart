import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/capture_models.dart';
import '../settings/settings_store.dart';

class VolcengineArkCaptureClient {
  VolcengineArkCaptureClient(this._settings, {http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  final SettingsStore _settings;
  final http.Client _httpClient;

  Future<CaptureResult> captureText({
    required String text,
    List<Map<String, String>> conversation = const [],
    Map<String, dynamic>? pendingDraft,
    List<String> missingFields = const [],
    bool isFollowUp = false,
  }) async {
    final apiKey = await _settings.volcengineArkApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw const VolcengineArkCaptureException('请先在设置页填写火山方舟 API Key');
    }

    final baseUrl = (await _settings.volcengineArkBaseUrl()).replaceAll(RegExp(r'/$'), '');
    final model = await _settings.volcengineArkTextModel();

    final response = await _httpClient.post(
      Uri.parse('$baseUrl/chat/completions'),
      headers: {
        'authorization': 'Bearer $apiKey',
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'model': model,
        'messages': [
          {'role': 'system', 'content': _systemPrompt},
          {
            'role': 'user',
            'content': jsonEncode({
              'text': text,
              'timezone': 'Asia/Shanghai',
              'now': DateTime.now().toIso8601String(),
              'conversation': conversation,
              'pending_draft': pendingDraft,
              'missing_fields': missingFields,
              'is_follow_up': isFollowUp,
            }),
          },
        ],
        'thinking': {'type': 'disabled'},
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VolcengineArkCaptureException('火山方舟文本整理失败：HTTP ${response.statusCode} ${response.body}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final content = body['choices']?[0]?['message']?['content'];
    if (content is! String || content.trim().isEmpty) {
      throw VolcengineArkCaptureException('火山方舟没有返回结构化内容：${response.body}');
    }

    return CaptureResult.fromJson(_decodeModelJson(content));
  }

  Map<String, dynamic> _decodeModelJson(String content) {
    final trimmed = content.trim();
    final jsonText = _stripCodeFence(trimmed);
    final decoded = jsonDecode(jsonText);
    if (decoded is! Map<String, dynamic>) {
      throw VolcengineArkCaptureException('火山方舟返回的不是 JSON 对象：$content');
    }
    return decoded;
  }

  String _stripCodeFence(String text) {
    if (!text.startsWith('```')) {
      return text;
    }
    return text
        .replaceFirst(RegExp(r'^```(?:json)?\s*', caseSensitive: false), '')
        .replaceFirst(RegExp(r'\s*```$'), '')
        .trim();
  }
}

class VolcengineArkCaptureException implements Exception {
  const VolcengineArkCaptureException(this.message);

  final String message;

  @override
  String toString() => message;
}

const _systemPrompt = '''
你是一个 Android 本地想法记录 App 的结构化录入智能体。你只能返回合法 JSON，不要返回 Markdown、代码块或解释。

输入 JSON 会包含 text、conversation、pending_draft、missing_fields、is_follow_up、timezone、now。

如果 is_follow_up 为 true，说明用户正在回答上一轮追问。请把 text 作为补充信息合并进 pending_draft，尽量保留上一轮已经确定的字段，只更新缺失或被用户明确修正的字段。不要把补充回答当成一条全新的记录。

把用户输入分为 todo、idea 或 unclear。todo 缺少时间、地点、主题时，不要保存，missing_fields 写缺失字段，并提出一个自然的中文追问。idea 不强制要求时间地点，应该整理成简洁标题、摘要和标签。时间字段使用 ISO-8601 字符串；无法确定时填 null。会议默认 60 分钟，普通事项默认 30 分钟。

输出字段必须是 intent_type, confidence, title, summary, missing_fields, follow_up_question, should_save, todo_payload, idea_payload。
todo_payload 必须包含 start_at, end_at, location, topic, reminder_at, status。
idea_payload 必须包含 summary, source_hint, tags。
todo_payload 和 idea_payload 二选一，另一个填 null。
''';
