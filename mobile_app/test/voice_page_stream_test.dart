import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_idea_capture/src/audio/interaction_sound_service.dart';
import 'package:local_idea_capture/src/data/app_database.dart';
import 'package:local_idea_capture/src/domain/capture_conversation_agent.dart';
import 'package:local_idea_capture/src/domain/capture_models.dart';
import 'package:local_idea_capture/src/features/voice/voice_page.dart';
import 'package:local_idea_capture/src/local_ai/local_voice_runtime.dart';
import 'package:local_idea_capture/src/providers.dart';
import 'package:local_idea_capture/src/theme/app_colors.dart';

void main() {
  testWidgets('shows the approved voice assistant empty state', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          captureConversationAgentProvider
              .overrideWithValue(_FakeCaptureConversationAgent()),
        ],
        child: const MaterialApp(home: Scaffold(body: VoicePage())),
      ),
    );

    expect(find.byKey(const Key('voice-assistant-prompt')), findsOneWidget);
    expect(find.byIcon(Icons.smart_toy_outlined), findsOneWidget);
    expect(find.text('AI 助手提示'), findsOneWidget);
    expect(find.text('说出你的想法，我会帮你整理和保存。'), findsOneWidget);
    expect(find.text('记录一个突发的灵感'), findsOneWidget);
    expect(find.text('整理今天想做的几件事'), findsOneWidget);
    expect(find.text('记录一个问题或需要解决的困扰'), findsOneWidget);

    final inputBar = tester.widget<Container>(
      find.byKey(const Key('voice-input-strip')),
    );
    expect(inputBar.constraints?.maxHeight, 60);
  });

  testWidgets('uses one input bar to switch between text and voice modes',
      (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          captureConversationAgentProvider
              .overrideWithValue(_FakeCaptureConversationAgent()),
        ],
        child: const MaterialApp(home: Scaffold(body: VoicePage())),
      ),
    );

    expect(find.text('按住说话'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(find.byIcon(Icons.keyboard_alt_outlined), findsOneWidget);
    expect(find.text('先用文字模拟语音输入...'), findsNothing);
    expect(find.byIcon(Icons.add), findsNothing);

    await tester.tap(find.byKey(const Key('voice-mode-toggle-button')));
    await tester.pumpAndSettle();

    expect(find.text('发送消息或按住说话...'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);

    await tester.tap(find.byKey(const Key('voice-mode-toggle-button')));
    await tester.pumpAndSettle();

    expect(find.text('按住说话'), findsOneWidget);
  });

  testWidgets('renders voice input as a compact rectangular strip',
      (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          captureConversationAgentProvider
              .overrideWithValue(_FakeCaptureConversationAgent()),
        ],
        child: const MaterialApp(home: Scaffold(body: VoicePage())),
      ),
    );

    expect(find.byKey(const Key('voice-input-strip')), findsOneWidget);
    expect(find.byKey(const Key('voice-side-signal-icon')), findsOneWidget);

    final strip =
        tester.widget<Container>(find.byKey(const Key('voice-input-strip')));
    final decoration = strip.decoration as BoxDecoration;
    expect(decoration.color, AppColors.surface);
    expect(decoration.borderRadius, BorderRadius.circular(18));
  });

  testWidgets('streams assistant text and shows a draft card after completion',
      (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          captureConversationAgentProvider
              .overrideWithValue(_FakeCaptureConversationAgent()),
        ],
        child: const MaterialApp(home: Scaffold(body: VoicePage())),
      ),
    );

    await tester.tap(find.byKey(const Key('voice-mode-toggle-button')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'manual meeting');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('AI todo'), findsOneWidget);

    await tester.pump();

    expect(find.text('Budget meeting'), findsOneWidget);
    expect(find.text('缺少信息：地点'), findsOneWidget);

    final draftCard = tester.widget<Container>(
      find.byKey(const Key('voice-draft-card')),
    );
    final draftDecoration = draftCard.decoration as BoxDecoration;
    expect(draftDecoration.color, AppColors.surface);
    expect(draftDecoration.border, isNotNull);
    expect(find.byKey(const Key('voice-draft-icon')), findsOneWidget);
  });

  testWidgets('renders the voice user message with the smart-record light blue',
      (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          captureConversationAgentProvider
              .overrideWithValue(_FakeCaptureConversationAgent()),
        ],
        child: const MaterialApp(home: Scaffold(body: VoicePage())),
      ),
    );

    await tester.tap(find.byKey(const Key('voice-mode-toggle-button')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'light blue bubble');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();

    final bubble = tester.widget<Container>(
      find.byKey(const Key('voice-user-message-bubble')),
    );
    final decoration = bubble.decoration as BoxDecoration;
    expect(decoration.color, const Color(0xffdce8ff));
  });

  testWidgets(
      'shows recording overlay, recognition bubble, then recognized voice text',
      (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          speechChannelProvider.overrideWithValue(_FakeSpeechService(
            'voice meeting',
            delay: const Duration(seconds: 1),
          )),
          captureConversationAgentProvider
              .overrideWithValue(_FakeCaptureConversationAgent()),
        ],
        child: const MaterialApp(home: Scaffold(body: VoicePage())),
      ),
    );

    final center =
        tester.getCenter(find.byKey(const Key('voice-press-button')));
    final gesture = await tester.startGesture(center);
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byKey(const Key('voice-recording-overlay')), findsOneWidget);

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 20));

    expect(find.byKey(const Key('voice-recognizing-bubble')), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(find.byKey(const Key('voice-recognizing-bubble')), findsNothing);
    expect(find.text('voice meeting'), findsOneWidget);
    expect(find.textContaining('AI todo'), findsOneWidget);
  });

  testWidgets('plays xiu after successful voice transcription', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    final sounds = _FakeInteractionSoundService();
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          interactionSoundServiceProvider.overrideWithValue(sounds),
          speechChannelProvider.overrideWithValue(
            _FakeSpeechService('voice meeting', delay: Duration.zero),
          ),
          captureConversationAgentProvider
              .overrideWithValue(_FakeCaptureConversationAgent()),
        ],
        child: const MaterialApp(home: Scaffold(body: VoicePage())),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('voice-press-button'))),
    );
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(sounds.xiuCount, 1);
    expect(sounds.dingCount, 0);
  });

  testWidgets('starts voice recording on pointer down without long-press delay',
      (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          speechChannelProvider.overrideWithValue(_FakeSpeechService(
            'quick voice',
            delay: Duration.zero,
          )),
          captureConversationAgentProvider
              .overrideWithValue(_FakeCaptureConversationAgent()),
        ],
        child: const MaterialApp(home: Scaffold(body: VoicePage())),
      ),
    );

    final center =
        tester.getCenter(find.byKey(const Key('voice-press-button')));
    expect(find.byKey(const Key('voice-assistant-prompt')), findsOneWidget);
    final gesture = await tester.startGesture(center);
    await tester.pump(const Duration(milliseconds: 20));

    expect(find.byKey(const Key('voice-recording-overlay')), findsOneWidget);
    expect(find.byKey(const Key('voice-assistant-prompt')), findsNothing);

    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('conflict draft only shows conflict resolution actions',
      (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await database.saveTodo(capture: _existingTodoDraft(), rawText: 'existing');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          captureConversationAgentProvider.overrideWithValue(
            _FakeCaptureConversationAgent(capture: _savableTodoDraft()),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: VoicePage())),
      ),
    );

    await tester.tap(find.byKey(const Key('voice-mode-toggle-button')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'overlapping todo');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.textContaining('08:00-09:00'), findsOneWidget);
    expect(find.textContaining('00:00-01:00'), findsNothing);

    expect(find.text('时间冲突'), findsOneWidget);
    expect(find.text('保留原日程'), findsOneWidget);
    expect(find.text('删除原日程'), findsOneWidget);
    expect(find.text('取消'), findsNothing);
    expect(find.text('保存'), findsNothing);
  });

  testWidgets('shows compact todo deletion confirmation and deletes matches',
      (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await database.saveTodo(
      capture: _existingTodoDraft(),
      rawText: '明天开会',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          captureConversationAgentProvider.overrideWithValue(
            _FakeCaptureConversationAgent(capture: _deleteDraft()),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: VoicePage())),
      ),
    );

    await tester.tap(find.byKey(const Key('voice-mode-toggle-button')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '删除明天开会的提醒');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.text('准备删除 1 条待办'), findsOneWidget);
    expect(find.text('08:00'), findsOneWidget);
    expect(find.text('Existing todo'), findsOneWidget);
    expect(find.text('取消'), findsOneWidget);
    expect(find.text('确认删除'), findsOneWidget);

    await tester.tap(find.text('确认删除'));
    await tester.pumpAndSettle();

    expect(find.text('已删除 1 条待办。'), findsOneWidget);
    expect(await database.loadTodoBlocks(), isEmpty);
  });

  testWidgets(
      'deletes only the immediately preceding query results when user refers to them',
      (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await database.saveTodo(
      capture: _todoAt('Query result one', DateTime(2026, 7, 12, 9)),
      rawText: 'query result one',
    );
    await database.saveTodo(
      capture: _todoAt('Query result two', DateTime(2026, 7, 12, 10)),
      rawText: 'query result two',
    );
    await database.saveTodo(
      capture: _todoAt('Query result three', DateTime(2026, 7, 12, 11)),
      rawText: 'query result three',
    );
    await database.saveTodo(
      capture: _todoAt('Must remain', DateTime(2026, 7, 13, 9)),
      rawText: 'must remain',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          captureConversationAgentProvider.overrideWithValue(
            _QueryThenDeleteCaptureConversationAgent(),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: VoicePage())),
      ),
    );

    await tester.tap(find.byKey(const Key('voice-mode-toggle-button')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '查询明天的待办');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '把这些待办全部删除');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();

    expect(find.text('准备删除 3 条待办'), findsOneWidget);
    await tester.tap(find.text('确认删除'));
    await tester.pumpAndSettle();

    final remaining = await database.loadTodos(
      DateTime(2026, 7, 12),
      DateTime(2026, 7, 14),
    );
    expect(remaining.map((todo) => todo.title), ['Must remain']);
  });

  testWidgets('shows and saves multiple todo drafts from one message',
      (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          captureConversationAgentProvider.overrideWithValue(
            _FakeCaptureConversationAgent(capture: _batchTodoDraft()),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: VoicePage())),
      ),
    );

    await tester.tap(find.byKey(const Key('voice-mode-toggle-button')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'add two todos');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump();
    await tester.pump();
    await tester.pump();

    expect(find.text('准备保存 2 条待办'), findsOneWidget);
    expect(find.text('Office report'), findsOneWidget);
    expect(find.text('Buy fruit'), findsOneWidget);

    await tester.tap(find.byType(FilledButton).last);
    await tester.pumpAndSettle();

    final todos =
        await database.loadTodos(DateTime(2026, 7, 11), DateTime(2026, 7, 12));
    expect(todos.map((todo) => todo.title), ['Office report', 'Buy fruit']);
    expect(find.text('已保存 2 条待办'), findsOneWidget);
    expect(find.text('Saved 2 todos locally.'), findsNothing);
  });

  testWidgets('plays ding after a draft is saved successfully', (tester) async {
    final database = AppDatabase(NativeDatabase.memory());
    final sounds = _FakeInteractionSoundService();
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          interactionSoundServiceProvider.overrideWithValue(sounds),
          captureConversationAgentProvider.overrideWithValue(
            _FakeCaptureConversationAgent(capture: _batchTodoDraft()),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: VoicePage())),
      ),
    );

    await tester.tap(find.byKey(const Key('voice-mode-toggle-button')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'add two todos');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton).last);
    await tester.pumpAndSettle();

    expect(sounds.dingCount, 1);
    expect(sounds.xiuCount, 0);
  });
}

class _FakeInteractionSoundService implements InteractionSoundService {
  int dingCount = 0;
  int xiuCount = 0;

  @override
  Future<void> playDing() async {
    dingCount++;
  }

  @override
  Future<void> playXiu() async {
    xiuCount++;
  }

  @override
  Future<void> dispose() async {}
}

class _FakeCaptureConversationAgent implements CaptureConversationAgent {
  _FakeCaptureConversationAgent({CaptureResult? capture})
      : _capture = capture ?? _todoDraft();

  final CaptureResult _capture;

  @override
  Stream<CaptureAgentStreamEvent> submitTextStream(String text) async* {
    yield const CaptureAgentAssistantDelta('AI todo, ');
    yield const CaptureAgentAssistantDelta('need location.');
    yield CaptureAgentTurnDone(
      CaptureTurn(
        capture: _capture,
        rawTranscript: text,
        isFollowUp: false,
        usedFallback: false,
      ),
    );
  }

  @override
  Future<CaptureTurn> submitText(String text) {
    throw UnimplementedError();
  }

  @override
  void reset() {}

  @override
  Future<void> cancelDraft() async {}

  @override
  Future<void> completeDraft() async {}

  @override
  Future<void> clearMemory() async {}

  @override
  Future<bool> restoreSession() async => false;

  @override
  CaptureSessionState get state => CaptureSessionState.idle;

  @override
  CaptureResult? get draft => null;

  @override
  String get sessionId => 'test';

  @override
  List<Map<String, String>> get memory => [];

  @override
  List<String> get lastQueryTodoIds => const [];

  @override
  ConversationSnapshot get displaySnapshot => const ConversationSnapshot(
      messages: [], activeDraft: null, state: CaptureSessionState.idle);

  @override
  void appendDisplayMessage(ConversationMessage message) {}

  @override
  void updateLastDisplayMessage(String text) {}

  @override
  void rememberLastQueryTodoIds(Iterable<String> ids) {}

  @override
  void clearLastQueryTodoIds() {}
}

class _QueryThenDeleteCaptureConversationAgent
    extends _FakeCaptureConversationAgent {
  @override
  Stream<CaptureAgentStreamEvent> submitTextStream(String text) async* {
    if (text.contains('查询')) {
      yield CaptureAgentTurnDone(
        CaptureTurn(
          capture: CaptureResult(
            intentType: CaptureIntentType.todoQuery,
            confidence: 0.98,
            title: '明天待办',
            summary: '查询明天待办',
            missingFields: const [],
            followUpQuestion: null,
            shouldSave: false,
            todoPayload: null,
            ideaPayload: null,
            todoQueryPayload: TodoQueryPayload(
              dateFrom: DateTime(2026, 7, 12),
              dateTo: DateTime(2026, 7, 13),
              keyword: null,
              includeCompleted: false,
              importanceRequested: false,
            ),
          ),
          rawTranscript: text,
          isFollowUp: false,
          usedFallback: false,
        ),
      );
      return;
    }

    yield CaptureAgentTurnDone(
      CaptureTurn(
        capture: const CaptureResult(
          intentType: CaptureIntentType.todoDelete,
          confidence: 0.98,
          title: '删除这些待办',
          summary: '删除查询结果',
          missingFields: [],
          followUpQuestion: null,
          shouldSave: false,
          todoPayload: null,
          ideaPayload: null,
          todoDeletePayload: TodoDeletePayload(
            operation: TodoDeleteOperation.clear,
            dateFrom: null,
            dateTo: null,
            timeFrom: null,
            timeTo: null,
            keyword: null,
          ),
        ),
        rawTranscript: text,
        isFollowUp: false,
        usedFallback: false,
      ),
    );
  }
}

class _FakeSpeechService implements LocalVoiceSpeechService {
  _FakeSpeechService(this.result,
      {this.delay = const Duration(milliseconds: 10)});

  final String result;
  final Duration delay;
  bool cancelled = false;

  @override
  Future<void> startRecognition() async {}

  @override
  Future<String> stopRecognition() async {
    await Future<void>.delayed(delay);
    return result;
  }

  @override
  Future<void> cancelRecognition() async {
    cancelled = true;
  }

  @override
  Future<void> dispose() async {}

  @override
  Future<void> warmUp() async {}

  @override
  Future<void> prepare() async {}
}

CaptureResult _todoDraft() {
  return CaptureResult(
    intentType: CaptureIntentType.todo,
    confidence: 0.92,
    title: 'Budget meeting',
    summary: 'Tomorrow morning budget meeting',
    missingFields: const ['location'],
    followUpQuestion: 'Where is the meeting?',
    shouldSave: false,
    todoPayload: TodoPayload(
      startAt: DateTime(2026, 7, 10, 9),
      endAt: DateTime(2026, 7, 10, 10),
      location: null,
      topic: 'budget',
      reminderAt: null,
      status: 'pending',
    ),
    ideaPayload: null,
  );
}

CaptureResult _savableTodoDraft() {
  return CaptureResult(
    intentType: CaptureIntentType.todo,
    confidence: 0.95,
    title: 'New overlapping todo',
    summary: 'New todo at the same time',
    missingFields: const [],
    followUpQuestion: null,
    shouldSave: true,
    todoPayload: TodoPayload(
      startAt: DateTime.utc(2026, 7, 10, 0),
      endAt: DateTime.utc(2026, 7, 10, 1),
      location: 'market',
      topic: 'buy fruit',
      reminderAt: null,
      status: 'pending',
    ),
    ideaPayload: null,
  );
}

CaptureResult _existingTodoDraft() {
  return CaptureResult(
    intentType: CaptureIntentType.todo,
    confidence: 0.95,
    title: 'Existing todo',
    summary: 'Existing todo at the same time',
    missingFields: const [],
    followUpQuestion: null,
    shouldSave: true,
    todoPayload: TodoPayload(
      startAt: DateTime.utc(2026, 7, 10, 0),
      endAt: DateTime.utc(2026, 7, 10, 1),
      location: 'market',
      topic: 'existing',
      reminderAt: null,
      status: 'pending',
    ),
    ideaPayload: null,
  );
}

CaptureResult _deleteDraft() {
  return CaptureResult(
    intentType: CaptureIntentType.todoDelete,
    confidence: 0.98,
    title: '删除明天开会的提醒',
    summary: '删除明天开会的待办',
    missingFields: const [],
    followUpQuestion: null,
    shouldSave: false,
    todoPayload: null,
    ideaPayload: null,
    todoDeletePayload: TodoDeletePayload(
      operation: TodoDeleteOperation.delete,
      dateFrom: DateTime.utc(2026, 7, 10),
      dateTo: DateTime.utc(2026, 7, 11),
      timeFrom: null,
      timeTo: null,
      keyword: 'Existing',
    ),
  );
}

CaptureResult _todoAt(String title, DateTime startAt) {
  return CaptureResult(
    intentType: CaptureIntentType.todo,
    confidence: 0.98,
    title: title,
    summary: title,
    missingFields: const [],
    followUpQuestion: null,
    shouldSave: true,
    todoPayload: TodoPayload(
      startAt: startAt,
      endAt: startAt.add(const Duration(minutes: 30)),
      location: null,
      topic: null,
      reminderAt: null,
      status: 'pending',
    ),
    ideaPayload: null,
  );
}

CaptureResult _batchTodoDraft() {
  return CaptureResult(
    intentType: CaptureIntentType.todo,
    confidence: 0.98,
    title: 'Two todos',
    summary: 'Add two todos on the same day',
    missingFields: const [],
    followUpQuestion: null,
    shouldSave: true,
    todoPayload: null,
    todoPayloads: [
      TodoPayload(
        title: 'Office report',
        summary: 'Go to the office to prepare a report',
        startAt: DateTime(2026, 7, 11, 11),
        endAt: DateTime(2026, 7, 11, 11, 30),
        location: 'office',
        topic: 'report',
        reminderAt: null,
        status: 'pending',
      ),
      TodoPayload(
        title: 'Buy fruit',
        summary: 'Buy fruit at the market',
        startAt: DateTime(2026, 7, 11, 15),
        endAt: DateTime(2026, 7, 11, 15, 30),
        location: 'market',
        topic: 'buy fruit',
        reminderAt: null,
        status: 'pending',
      ),
    ],
    ideaPayload: null,
  );
}
