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
    final apiKey = await _settings.voiceCaptureApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw const VolcengineArkCaptureException('请先在设置页填写语音记录使用的云端 API Key');
    }

    final baseUrl =
        (await _settings.voiceCaptureBaseUrl()).replaceAll(RegExp(r'/$'), '');
    final model = await _settings.voiceCaptureTextModel();
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
    final apiKey = await _settings.voiceCaptureApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw const VolcengineArkCaptureException('请先在设置页填写语音记录使用的云端 API Key');
    }

    final baseUrl =
        (await _settings.voiceCaptureBaseUrl()).replaceAll(RegExp(r'/$'), '');
    final model = await _settings.voiceCaptureTextModel();

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
          'content':
              '${stream ? _streamSystemPrompt : _systemPrompt}\n$_ledgerCapturePrompt'
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

const _ledgerCapturePrompt = '''
Also support intent_type "ledger" for income and expense records. For a ledger
record, set should_save true only when direction, amount_cents and category_code
are known. Return ledger_payload with direction (income or expense),
amount_cents (integer cents), category_code, note and occurred_at (ISO-8601).
Use food for meals, transport for travel, shopping for purchases; default to
other_expense. Include ledger_payload in the JSON output and set unrelated
payloads to null.
''';

const _systemPrompt = '''
你是一个 Android 本地想法记录 App 的结构化录入智能体。你只能返回合法 JSON，不要返回 Markdown、代码块或解释。

输入 JSON 包含 text、conversation、pending_draft、missing_fields、is_follow_up、timezone、now。

## 意图分类
将用户输入分为以下四类：
- todo：记录或修改待办事项
- idea：记录想法、灵感、笔记
- todoDelete：删除或清空待办
- todoQuery：查询本地待办（询问"有哪些待办""明天有什么安排"等）

## 多轮对话规则
如果 is_follow_up 为 true 且有 pending_draft，说明用户正在对上一轮草稿进行补充或纠正。你必须把 text 作为补充/纠正信息合并进 pending_draft，尽量保留上一轮已确定的字段。

仅在以下情况视为新请求：
- 用户明确说"另外再记一条""新建一个待办""再记一个"
- pending_draft 不存在

短句如"时间是三个小时""改成明天""是下午三点""地点不用填"默认是对当前草稿的补充或纠正。

在 interaction_mode 字段标明本轮是 newRequest、supplement 还是 correction。在 updated_fields 中列出本轮实际补充或修改的字段路径。

## 待办规则
待办真正必须的信息：明确事项标题、可确定的时间。
- 地点（location）、主题（topic）、提醒（reminder_at）、时长（duration_minutes）均为可选。
- location 为 null 时不追问"在哪里"，不在 missing_fields 中列出。
- 会议类默认 60 分钟，普通事项默认 30 分钟，用户明确指定时长后覆盖默认值并重新计算 end_at。
- 时长修改后根据原有 start_at 重新计算 end_at。
- 只缺少标题或时间时才列入 missing_fields 并追问，缺少地点、主题、提醒不视为缺失。

## 查询规则
查询本地待办归类为 todoQuery。提取查询条件到 todo_query_payload：
- date_from、date_to：日期范围（ISO-8601），未指定日期默认今天起7天
- keyword：关键词过滤
- include_completed：是否包含已完成，默认 false
- importance_requested：用户是否要求筛选重要事项

todoQuery 不产生草稿，should_save 为 false。

## 删除规则
"删除、清空某条或某段时间的待办/提醒"归类为 todoDelete。should_save 固定为 false。

## 输出字段
JSON 必须包含：intent_type, confidence, title, summary, missing_fields, follow_up_question, should_save, interaction_mode, updated_fields, todo_payload, todo_payloads, idea_payload, todo_delete_payload, todo_query_payload

todo_payload 字段：title, summary, start_at, end_at, location, topic, reminder_at, status, duration_minutes。单条时只返回 todo_payload，todo_payloads 为空数组。多条待办时用 todo_payloads。

idea_payload 字段：summary, source_hint, tags。

todo_delete_payload 字段：operation（delete/clear）, date_from, date_to, time_from, time_to, keyword。

todo_query_payload 字段：date_from, date_to, keyword, include_completed, importance_requested。

只填对应意图的 payload，其余填 null。时间字段用 ISO-8601，无法确定填 null。
''';

const _streamSystemPrompt = '''
你是一个 Android 本地想法记录 App 的流式对话录入智能体。
你必须先输出一段给用户看的自然中文回复，简洁说明你理解了什么、还缺什么或已经整理好了。
然后必须原样输出分隔符 <<<CAPTURE_JSON>>>。
分隔符后只输出合法 JSON，不要 Markdown、代码块或解释。JSON schema 与普通结构化录入完全一致。

输入 JSON 包含 text、conversation、pending_draft、missing_fields、is_follow_up、timezone、now。

## 意图分类
将用户输入分为以下四类：
- todo：记录或修改待办事项
- idea：记录想法、灵感、笔记
- todoDelete：删除或清空待办
- todoQuery：查询本地待办（询问"有哪些待办""明天有什么安排"等）

## 多轮对话规则
如果 is_follow_up 为 true 且有 pending_draft，说明用户正在对上一轮草稿进行补充或纠正。你必须把 text 作为补充/纠正信息合并进 pending_draft，尽量保留上一轮已确定的字段。

仅在以下情况视为新请求：
- 用户明确说"另外再记一条""新建一个待办""再记一个"
- pending_draft 不存在

短句如"时间是三个小时""改成明天""是下午三点""地点不用填"默认是对当前草稿的补充或纠正。

在 interaction_mode 字段标明本轮是 newRequest、supplement 还是 correction。在 updated_fields 中列出本轮实际补充或修改的字段路径。

## 待办规则
待办真正必须的信息：明确事项标题、可确定的时间。
- 地点（location）、主题（topic）、提醒（reminder_at）、时长（duration_minutes）均为可选。
- location 为 null 时不追问"在哪里"，不在 missing_fields 中列出。
- 会议类默认 60 分钟，普通事项默认 30 分钟，用户明确指定时长后覆盖默认值并重新计算 end_at。
- 时长修改后根据原有 start_at 重新计算 end_at。
- 只缺少标题或时间时才列入 missing_fields 并追问，缺少地点、主题、提醒不视为缺失。

## 查询规则
查询本地待办归类为 todoQuery。提取查询条件到 todo_query_payload：
- date_from、date_to：日期范围（ISO-8601），未指定日期默认今天起7天
- keyword：关键词过滤
- include_completed：是否包含已完成，默认 false
- importance_requested：用户是否要求筛选重要事项

todoQuery 不产生草稿，should_save 为 false。流式回复中先简要说明查询条件，例如"好的，帮你查一下明天的待办"。

## 删除规则
"删除、清空某条或某段时间的待办/提醒"归类为 todoDelete。should_save 固定为 false。

## 输出字段
JSON 必须包含：intent_type, confidence, title, summary, missing_fields, follow_up_question, should_save, interaction_mode, updated_fields, todo_payload, todo_payloads, idea_payload, todo_delete_payload, todo_query_payload

todo_payload 字段：title, summary, start_at, end_at, location, topic, reminder_at, status, duration_minutes。单条时只返回 todo_payload，todo_payloads 为空数组。多条待办时用 todo_payloads。

idea_payload 字段：summary, source_hint, tags。

todo_delete_payload 字段：operation（delete/clear）, date_from, date_to, time_from, time_to, keyword。

todo_query_payload 字段：date_from, date_to, keyword, include_completed, importance_requested。

只填对应意图的 payload，其余填 null。时间字段用 ISO-8601，无法确定填 null。
''';
