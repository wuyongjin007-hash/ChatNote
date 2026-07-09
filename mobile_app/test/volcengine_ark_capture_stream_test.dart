import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:local_idea_capture/src/ai/volcengine_ark_capture_client.dart';
import 'package:local_idea_capture/src/domain/capture_models.dart';
import 'package:local_idea_capture/src/settings/settings_store.dart';

void main() {
  test('streams visible assistant text and parses hidden capture json', () async {
    late Map<String, dynamic> requestBody;
    final client = VolcengineArkCaptureClient(
      _FakeSettingsStore(),
      httpClient: MockClient.streaming((request, bodyStream) async {
        requestBody = jsonDecode(await utf8.decodeStream(bodyStream)) as Map<String, dynamic>;
        return http.StreamedResponse(
          Stream.fromIterable([
            _sseChunk('我理解这是一个待办，'),
            _sseChunk('还需要补充地点。<<<CAP'),
            _sseChunk('TURE_JSON>>>'),
            _sseChunk(jsonEncode(_captureJson())),
            utf8.encode('data: [DONE]\n\n'),
          ]),
          200,
          headers: {'content-type': 'text/event-stream'},
        );
      }),
    );

    final events = await client
        .captureTextStream(
          text: '明天上午九点开会',
          conversation: const [],
          pendingDraft: null,
          missingFields: const [],
          isFollowUp: false,
        )
        .toList();

    expect(requestBody['stream'], isTrue);
    expect(events.whereType<ArkAssistantDelta>().map((event) => event.text).join(), '我理解这是一个待办，还需要补充地点。');
    final done = events.whereType<ArkCaptureDone>().single;
    expect(done.capture.intentType, CaptureIntentType.todo);
    expect(done.capture.title, '预算会议');
    expect(done.capture.missingFields, ['location']);
  });

  test('throws when a streaming response ends without hidden capture json', () async {
    final client = VolcengineArkCaptureClient(
      _FakeSettingsStore(),
      httpClient: MockClient.streaming((request, bodyStream) async {
        return http.StreamedResponse(
          Stream.fromIterable([
            _sseChunk('我理解这是一个待办。'),
            utf8.encode('data: [DONE]\n\n'),
          ]),
          200,
          headers: {'content-type': 'text/event-stream'},
        );
      }),
    );

    expect(
      client.captureTextStream(text: '明天开会').toList(),
      throwsA(isA<VolcengineArkCaptureException>()),
    );
  });
}

List<int> _sseChunk(String content) {
  return utf8.encode('data: ${jsonEncode({
        'choices': [
          {
            'delta': {'content': content},
          }
        ],
      })}\n\n');
}

Map<String, dynamic> _captureJson() {
  return {
    'intent_type': 'todo',
    'confidence': 0.92,
    'title': '预算会议',
    'summary': '明天上午九点开预算会议',
    'missing_fields': ['location'],
    'follow_up_question': '会议在哪里开？',
    'should_save': false,
    'todo_payload': {
      'start_at': '2026-07-10T09:00:00+08:00',
      'end_at': '2026-07-10T10:00:00+08:00',
      'location': null,
      'topic': '预算',
      'reminder_at': null,
      'status': 'pending',
    },
    'idea_payload': null,
  };
}

class _FakeSettingsStore extends SettingsStore {
  @override
  Future<String?> volcengineArkApiKey() async => 'test-key';

  @override
  Future<String> volcengineArkBaseUrl() async => 'https://ark.test/api/v3';

  @override
  Future<String> volcengineArkTextModel() async => 'doubao-test';
}
