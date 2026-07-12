import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:local_idea_capture/src/agent/agent_models.dart';
import 'package:local_idea_capture/src/ai/ark_responses_agent_client.dart';

void main() {
  test('sends function definitions and parses function calls', () async {
    late Map<String, dynamic> requestBody;
    final httpClient = MockClient((request) async {
      requestBody = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(
        jsonEncode({
          'id': 'resp-1',
          'status': 'completed',
          'output': [
            {
              'type': 'function_call',
              'call_id': 'call-1',
              'name': 'idea_search',
              'arguments': '{"keyword":"agent"}'
            }
          ]
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final client = ArkResponsesAgentClient(
      apiKey: () async => 'key',
      baseUrl: () async => 'https://example.com/api/v3',
      model: () async => 'model',
      httpClient: httpClient,
    );

    final events = await client
        .run(AgentRequest(
          input: [AgentInputItem.message('user', '总结想法')],
          tools: const [
            AgentToolDefinition(
              name: 'idea_search',
              description: 'search ideas',
              domain: 'idea',
              parameters: {
                'type': 'object',
                'properties': {
                  'keyword': {'type': 'string'},
                },
                'required': [],
                'additionalProperties': false,
              },
            )
          ],
        ))
        .toList();

    expect(requestBody['tools'], hasLength(1));
    expect(
      events.whereType<AgentToolCallRequested>().single.call.arguments,
      {'keyword': 'agent'},
    );
    expect(
      events.whereType<AgentResponseCompleted>().single.responseId,
      'resp-1',
    );
  });

  test('parses assistant output text', () async {
    final client = ArkResponsesAgentClient(
      apiKey: () async => 'key',
      baseUrl: () async => 'https://example.com/api/v3',
      model: () async => 'model',
      httpClient: MockClient((_) async => http.Response.bytes(
            utf8.encode(jsonEncode({
              'id': 'resp-2',
              'status': 'completed',
              'output': [
                {
                  'type': 'message',
                  'content': [
                    {'type': 'output_text', 'text': '已完成总结'}
                  ]
                }
              ]
            })),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          )),
    );

    final events = await client
        .run(AgentRequest(
          input: [AgentInputItem.message('user', '总结')],
          tools: const [],
        ))
        .toList();

    expect(events.whereType<AgentTextDelta>().single.text, '已完成总结');
  });
}
