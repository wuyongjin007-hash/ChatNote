import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/capture_models.dart';
import '../settings/settings_store.dart';

class VolcengineArkCaptureClient {
  VolcengineArkCaptureClient(this._settings, {http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  final SettingsStore _settings;
  final http.Client _httpClient;

  Stream<ArkCaptureStreamEvent> captureTextStream({
    required String text,
    List<Map<String, String>> conversation = const [],
    Map<String, dynamic>? pendingDraft,
    List<String> missingFields = const [],
    bool isFollowUp = false,
  }) async* {
    final apiKey = await _settings.volcengineArkApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw const VolcengineArkCaptureException('请先在设置页填写火山方舟 API Key');
    }

    final baseUrl =
        (await _settings.volcengineArkBaseUrl()).replaceAll(RegExp(r'/$'), '');
    final model = await _settings.volcengineArkTextModel();
    final request = http.Request('POST', Uri.parse('$baseUrl/chat/completions'))
      ..headers.addAll({
        'authorization': 'Bearer $apiKey',
        'content-type': 'application/json',
      })
      ..body = jsonEncode(_requestBody(
        model: model,
        text: text,
        conversation: conversation,
        pendingDraft: pendingDraft,
        missingFields: missingFields,
        isFollowUp: isFollowUp,
        stream: true,
      ));

    final response = await _httpClient.send(request);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = await response.stream.bytesToString();
      throw VolcengineArkCaptureException(
          '火山方舟文本流式整理失败：HTTP ${response.statusCode} $body');
    }

    final parser = _ArkStreamParser();
    await for (final line in response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())) {
      if (!line.startsWith('data:')) {
        continue;
      }
      final data = line.substring(5).trim();
      if (data.isEmpty) {
        continue;
      }
      if (data == '[DONE]') {
        break;
      }

      final decoded = jsonDecode(data);
      if (decoded is! Map<String, dynamic>) {
        continue;
      }
      final content = decoded['choices']?[0]?['delta']?['content'];
      if (content is! String || content.isEmpty) {
        continue;
      }
      for (final event in parser.add(content)) {
        yield event;
      }
    }

    yield ArkCaptureDone(parser.finish());
  }

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

    final baseUrl =
        (await _settings.volcengineArkBaseUrl()).replaceAll(RegExp(r'/$'), '');
    final model = await _settings.volcengineArkTextModel();

    final response = await _httpClient.post(
      Uri.parse('$baseUrl/chat/completions'),
      headers: {
        'authorization': 'Bearer $apiKey',
        'content-type': 'application/json',
      },
      body: jsonEncode(_requestBody(
        model: model,
        text: text,
        conversation: conversation,
        pendingDraft: pendingDraft,
        missingFields: missingFields,
        isFollowUp: isFollowUp,
        stream: false,
      )),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VolcengineArkCaptureException(
          '火山方舟文本整理失败：HTTP ${response.statusCode} ${response.body}');
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
    return _stripCodeFenceStatic(text);
  }

  Map<String, dynamic> _requestBody({
    required String model,
    required String text,
    required List<Map<String, String>> conversation,
    required Map<String, dynamic>? pendingDraft,
    required List<String> missingFields,
    required bool isFollowUp,
    required bool stream,
  }) {
    return {
      'model': model,
      'messages': [
        {
          'role': 'system',
          'content': stream ? _streamSystemPrompt : _systemPrompt
        },
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
      if (stream) 'stream': true,
    };
  }
}

abstract class ArkCaptureStreamEvent {
  const ArkCaptureStreamEvent();
}

class ArkAssistantDelta extends ArkCaptureStreamEvent {
  const ArkAssistantDelta(this.text);

  final String text;
}

class ArkCaptureDone extends ArkCaptureStreamEvent {
  const ArkCaptureDone(this.capture);

  final CaptureResult capture;
}

class VolcengineArkCaptureException implements Exception {
  const VolcengineArkCaptureException(this.message);

  final String message;

  @override
  String toString() => message;
}

class _ArkStreamParser {
  var _pendingVisible = '';
  var _jsonText = '';
  var _readingJson = false;

  Iterable<ArkCaptureStreamEvent> add(String content) sync* {
    if (_readingJson) {
      _jsonText += content;
      return;
    }

    _pendingVisible += content;
    final separatorIndex = _pendingVisible.indexOf(_captureJsonSeparator);
    if (separatorIndex >= 0) {
      final visible = _pendingVisible.substring(0, separatorIndex);
      if (visible.isNotEmpty) {
        yield ArkAssistantDelta(visible);
      }
      _jsonText += _pendingVisible
          .substring(separatorIndex + _captureJsonSeparator.length);
      _pendingVisible = '';
      _readingJson = true;
      return;
    }

    final safeLength =
        _pendingVisible.length - (_captureJsonSeparator.length - 1);
    if (safeLength > 0) {
      final visible = _pendingVisible.substring(0, safeLength);
      _pendingVisible = _pendingVisible.substring(safeLength);
      yield ArkAssistantDelta(visible);
    }
  }

  CaptureResult finish() {
    if (!_readingJson || _jsonText.trim().isEmpty) {
      throw const VolcengineArkCaptureException('火山方舟流式响应缺少结构化 JSON');
    }
    final decoded = jsonDecode(_stripCodeFenceStatic(_jsonText.trim()));
    if (decoded is! Map<String, dynamic>) {
      throw VolcengineArkCaptureException('火山方舟流式响应的 JSON 不是对象：$_jsonText');
    }
    return CaptureResult.fromJson(decoded);
  }
}

String _stripCodeFenceStatic(String text) {
  if (!text.startsWith('```')) {
    return text;
  }
  return text
      .replaceFirst(RegExp(r'^```(?:json)?\s*', caseSensitive: false), '')
      .replaceFirst(RegExp(r'\s*```$'), '')
      .trim();
}

const _captureJsonSeparator = '<<<CAPTURE_JSON>>>';

const _systemPrompt = '''
你是一个 Android 本地想法记录 App 的结构化录入智能体。你只能返回合法 JSON，不要返回 Markdown、代码块或解释。
输入 JSON 会包含 text、conversation、pending_draft、missing_fields、is_follow_up、timezone、now。
如果 is_follow_up 为 true，说明用户正在回答上一轮追问。请把 text 作为补充信息合并进 pending_draft，尽量保留上一轮已确定字段，只更新缺失或被用户明确修正的字段，不要把补充回答当成全新记录。
把用户输入分为 todo、idea、todoDelete 或 unclear。“删除、清空、取消某条或某段时间的待办/提醒”必须归类为 todoDelete，而不是新增 todo。todoDelete 不直接执行删除，should_save 固定为 false，并提取本地匹配条件。todo 缺少时间、地点、主题时不要保存，missing_fields 写缺失字段，并提出一个自然中文追问。idea 不强制要求时间地点，应整理成简洁标题、摘要和标签。时间字段使用 ISO-8601 字符串；无法确定时填 null。会议默认 60 分钟，普通事项默认 30 分钟。
输出字段必须是 intent_type, confidence, title, summary, missing_fields, follow_up_question, should_save, todo_payload, idea_payload, todo_delete_payload。todo_payload 必须包含 start_at, end_at, location, topic, reminder_at, status。idea_payload 必须包含 summary, source_hint, tags。todo_delete_payload 必须包含 operation, date_from, date_to, time_from, time_to, keyword；operation 只能是 delete 或 clear，日期范围使用左闭右开，时间范围用于重叠匹配。“删除提醒”表示删除整条待办。todo、idea、todoDelete 三种 payload 只保留对应的一种，其余填 null。''';

const _streamSystemPrompt = '''
你是一个 Android 本地想法记录 App 的流式对话录入智能体。
你必须先输出一段给用户看的自然中文回复，像聊天助手一样简洁说明你理解了什么、还缺什么或已经整理好了。
然后必须原样输出分隔符 <<<CAPTURE_JSON>>>。
分隔符后只输出合法 JSON，不要 Markdown、不要代码块、不要解释。JSON schema 与普通结构化录入完全一致。

输入 JSON 会包含 text、conversation、pending_draft、missing_fields、is_follow_up、timezone、now。
如果 is_follow_up 为 true，说明用户正在回答上一轮追问。请把 text 作为补充信息合并进 pending_draft，尽量保留上一轮已确定字段，只更新缺失或被用户明确修正的字段，不要把补充回答当成全新记录。
把用户输入分为 todo、idea、todoDelete 或 unclear。“删除、清空、取消某条或某段时间的待办/提醒”必须归类为 todoDelete，而不是新增 todo。todoDelete 不直接执行删除，should_save 固定为 false，并提取本地匹配条件。todo 缺少时间、地点、主题时不要保存，missing_fields 写缺失字段，并提出一个自然中文追问。idea 不强制要求时间地点，应整理成简洁标题、摘要和标签。时间字段使用 ISO-8601 字符串；无法确定时填 null。会议默认 60 分钟，普通事项默认 30 分钟。
JSON 字段必须是 intent_type, confidence, title, summary, missing_fields, follow_up_question, should_save, todo_payload, idea_payload, todo_delete_payload。todo_payload 必须包含 start_at, end_at, location, topic, reminder_at, status。idea_payload 必须包含 summary, source_hint, tags。todo_delete_payload 必须包含 operation, date_from, date_to, time_from, time_to, keyword；operation 只能是 delete 或 clear，日期范围使用左闭右开，时间范围用于重叠匹配。“删除提醒”表示删除整条待办。todo、idea、todoDelete 三种 payload 只保留对应的一种，其余填 null。''';
