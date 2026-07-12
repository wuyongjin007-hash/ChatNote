import 'dart:convert';

import 'package:http/http.dart' as http;

import '../agent/agent_models.dart';

typedef AgentSettingReader = Future<String> Function();

class ArkResponsesAgentClient implements AgentModelClient {
  ArkResponsesAgentClient({
    required AgentSettingReader apiKey,
    required AgentSettingReader baseUrl,
    required AgentSettingReader model,
    http.Client? httpClient,
  })  : _apiKey = apiKey,
        _baseUrl = baseUrl,
        _model = model,
        _httpClient = httpClient ?? http.Client();

  final AgentSettingReader _apiKey;
  final AgentSettingReader _baseUrl;
  final AgentSettingReader _model;
  final http.Client _httpClient;

  @override
  Stream<AgentEvent> run(AgentRequest request) async* {
    final key = (await _apiKey()).trim();
    if (key.isEmpty) {
      yield const AgentResponseFailed('请先在设置页填写火山方舟 API Key');
      return;
    }
    final base = (await _baseUrl()).replaceAll(RegExp(r'/$'), '');
    final response = await _httpClient.post(
      Uri.parse('$base/responses'),
      headers: {
        'authorization': 'Bearer $key',
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'model': await _model(),
        'instructions': '$_agentInstructions\n$_toolEvidenceInstructions',
        'input': request.input.map((item) => item.json).toList(),
        'tools': request.tools
            .map((definition) => definition.toResponsesJson())
            .toList(),
        if (request.previousResponseId != null)
          'previous_response_id': request.previousResponseId,
        'store': true,
        'thinking': {'type': 'disabled'},
      }),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      yield AgentResponseFailed(
          '火山方舟智能体请求失败：HTTP ${response.statusCode} ${response.body}');
      return;
    }
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    if (body is! Map<String, dynamic>) {
      yield const AgentResponseFailed('火山方舟返回了无法识别的响应');
      return;
    }
    final output = body['output'] as List<dynamic>? ?? const [];
    for (final raw in output) {
      if (raw is! Map<String, dynamic>) continue;
      if (raw['type'] == 'function_call') {
        final argumentText = raw['arguments'] as String? ?? '{}';
        final arguments = jsonDecode(argumentText);
        if (arguments is! Map<String, dynamic>) {
          yield AgentResponseFailed('工具 ${raw['name']} 的参数不是对象');
          return;
        }
        yield AgentToolCallRequested(AgentToolCall(
          callId: raw['call_id'] as String? ?? '',
          name: raw['name'] as String? ?? '',
          arguments: arguments,
        ));
      } else if (raw['type'] == 'message') {
        for (final content in raw['content'] as List<dynamic>? ?? const []) {
          if (content is Map<String, dynamic> &&
              content['type'] == 'output_text' &&
              content['text'] is String) {
            yield AgentTextDelta(content['text'] as String);
          }
        }
      }
    }
    final responseId = body['id'];
    if (responseId is! String || responseId.isEmpty) {
      yield const AgentResponseFailed('火山方舟响应缺少 response id');
      return;
    }
    yield AgentResponseCompleted(responseId: responseId);
  }
}

const _agentInstructions = '''
你是一个本地个人记录 App 的工具调用智能体。待办、想法、账目等可变数据必须通过工具查询，不能凭记忆编造。
读操作可直接调用；新增完成后明确回执；修改、删除和批量写入会由 App 要求用户确认。
用户说“最近”但未指定范围时，先查询最近 7 个自然日；没有结果时可扩大到 30 天，并明确说明实际范围。
工具返回多条候选而用户目标不唯一时必须追问。回答简洁、准确，不暴露函数名、JSON 或内部实现。
''';

const _toolEvidenceInstructions = '''
When a user asks to create, change, delete, search, summarize, or calculate
local todos, ideas, or ledger records, call an appropriate registered tool
before answering. Do not claim that an action succeeded, or that records were
found, until a tool result confirms it. If no tool result is available, call a
tool or ask a clarification question instead.
''';
