import '../data/app_database.dart';
import 'agent_models.dart';

class AgentMemoryContext {
  const AgentMemoryContext({
    required this.recentMessages,
    required this.contextNote,
  });

  final List<AgentInputItem> recentMessages;
  final String contextNote;

  List<AgentInputItem> toInputItems() => [
        if (contextNote.isNotEmpty)
          AgentInputItem.message('developer', contextNote),
        ...recentMessages,
      ];
}

abstract interface class MemoryRetriever {
  Future<List<MemoryItem>> retrieve(
    String query, {
    required DateTime now,
    int limit = 5,
  });
}

class DatabaseMemoryRetriever implements MemoryRetriever {
  DatabaseMemoryRetriever(this._database);
  final AppDatabase _database;

  @override
  Future<List<MemoryItem>> retrieve(String query,
      {required DateTime now, int limit = 5}) {
    return _database.searchMemories(query, now: now, limit: limit);
  }
}

class MemoryContextBuilder {
  MemoryContextBuilder(AppDatabase database, {MemoryRetriever? retriever})
      : _database = database,
        _retriever = retriever ?? DatabaseMemoryRetriever(database);

  final AppDatabase _database;
  final MemoryRetriever _retriever;

  Future<AgentMemoryContext> build({
    required String threadId,
    required String memoryKeyword,
    DateTime? now,
  }) async {
    final clock = now ?? DateTime.now();
    final results = await Future.wait<Object?>([
      _database.loadAgentThread(threadId),
      _database.loadRecentAgentMessages(threadId, 12),
      memoryKeyword.trim().isEmpty
          ? Future<List<MemoryItem>>.value(const [])
          : _retriever.retrieve(memoryKeyword, now: clock, limit: 5),
    ]);
    final thread = results[0] as AgentThread?;
    final messages = results[1] as List<AgentMessage>;
    final memories = results[2] as List<MemoryItem>;
    final note = StringBuffer();
    final summary = thread?.rollingSummary?.trim();
    if (summary != null && summary.isNotEmpty) {
      note.writeln('会话滚动摘要：$summary');
    }
    final refs = thread?.entityRefsJson?.trim();
    if (refs != null && refs.isNotEmpty) {
      note.writeln('当前会话最近结果集（用于“第一条、刚才那个”等指代）：$refs');
    }
    if (memories.isNotEmpty) {
      note.writeln('以下是历史记忆，只能用于偏好和背景，业务数据仍需调用工具实时查询：');
      for (final memory in memories) {
        note.writeln('- [历史记忆/${memory.memoryType}] ${memory.content}');
      }
    }
    return AgentMemoryContext(
      recentMessages: messages
          .map((message) =>
              AgentInputItem.message(message.role, message.content))
          .toList(growable: false),
      contextNote: note.toString().trim(),
    );
  }
}
