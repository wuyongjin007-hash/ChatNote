import 'package:uuid/uuid.dart';

import '../data/app_database.dart';
import '../domain/capture_models.dart';
import 'agent_models.dart';
import 'agent_tool.dart';

typedef _Execute = Future<ToolResult> Function(
    Map<String, dynamic>, ToolExecutionContext);
typedef _Preview = Future<ToolPreview?> Function(
    Map<String, dynamic>, ToolExecutionContext);

List<AgentTool> buildLocalAgentTools(AppDatabase database) => [
      _tool('todo_list', '查询待办，支持时间和关键词过滤', 'todo', ToolRiskLevel.read,
          _querySchema, (args, _) async {
        final payload = TodoQueryPayload(
          dateFrom: _date(args['date_from']),
          dateTo: _date(args['date_to']),
          keyword: args['keyword'] as String?,
          includeCompleted: args['include_completed'] as bool? ?? false,
        );
        final rows = await database.queryTodos(payload);
        return _listResult(rows.take(_limit(args)).map(_entryJson).toList());
      }),
      _recordGetTool(database, 'todo_get', 'todo'),
      _tool('todo_create', '创建一条待办', 'todo', ToolRiskLevel.create,
          _todoCreateSchema, (args, _) async {
        final title = args['title'] as String;
        final capture = CaptureResult(
          intentType: CaptureIntentType.todo,
          confidence: 1,
          title: title,
          summary: args['summary'] as String? ?? title,
          missingFields: const [],
          followUpQuestion: null,
          shouldSave: true,
          todoPayload: TodoPayload(
            title: title,
            summary: args['summary'] as String?,
            startAt: _date(args['start_at']),
            endAt: _date(args['end_at']),
            location: args['location'] as String?,
            topic: args['topic'] as String?,
            reminderAt: _date(args['reminder_at']),
            status: args['status'] as String? ?? 'pending',
          ),
          ideaPayload: null,
        );
        final ids = await database.saveTodos(capture: capture, rawText: title);
        return ToolResult.success({'id': ids.single, 'title': title});
      }),
      _recordUpdateTool(database, 'todo_update', 'todo'),
      _recordDeleteTool(database, 'todo_delete', 'todo'),
      _tool('idea_search', '搜索想法，可按关键词和时间范围查询', 'idea', ToolRiskLevel.read,
          _querySchema, (args, _) async {
        final page = await database.loadIdeaPage(
          query: args['keyword'] as String? ?? '',
          limit: _limit(args),
        );
        final from = _date(args['date_from']);
        final to = _date(args['date_to']);
        final rows = page.items
            .where((item) {
              return (from == null || !item.createdAt.isBefore(from)) &&
                  (to == null || item.createdAt.isBefore(to));
            })
            .map(_entryJson)
            .toList();
        return ToolResult.success({
          'items': rows,
          'returned_count': rows.length,
          'has_more': page.hasMore,
          'truncated': page.hasMore,
          'date_from': from?.toIso8601String(),
          'date_to': to?.toIso8601String(),
        });
      }),
      _recordGetTool(database, 'idea_get', 'idea'),
      _tool('idea_create', '创建一条想法', 'idea', ToolRiskLevel.create,
          _ideaCreateSchema, (args, _) async {
        final summary = args['summary'] as String;
        final capture = CaptureResult(
          intentType: CaptureIntentType.idea,
          confidence: 1,
          title: args['title'] as String? ?? summary,
          summary: summary,
          missingFields: const [],
          followUpQuestion: null,
          shouldSave: true,
          todoPayload: null,
          ideaPayload: IdeaPayload(
            summary: summary,
            sourceHint: args['source_hint'] as String?,
            tags: (args['tags'] as List<dynamic>? ?? const [])
                .map((value) => value.toString())
                .toList(),
          ),
        );
        final id = await database.saveIdea(capture: capture, rawText: summary);
        return ToolResult.success({'id': id, 'summary': summary});
      }),
      _recordUpdateTool(database, 'idea_update', 'idea'),
      _recordDeleteTool(database, 'idea_delete', 'idea'),
      _tool('ledger_list', '查询账目流水', 'ledger', ToolRiskLevel.read,
          _ledgerListSchema, (args, _) async {
        final from = _date(args['date_from']) ??
            DateTime.now().subtract(const Duration(days: 7));
        final to = _date(args['date_to']) ?? DateTime.now();
        var rows = await database.listLedgerTransactions(
          from,
          to,
          limit: _limit(args),
        );
        final keyword = (args['keyword'] as String? ?? '').trim();
        if (keyword.isNotEmpty) {
          rows = rows
              .where((row) =>
                  row.note.contains(keyword) ||
                  row.categoryCode.contains(keyword))
              .toList();
        }
        return ToolResult.success({
          'items': rows.map(_ledgerJson).toList(),
          'returned_count': rows.length,
          'date_from': from.toIso8601String(),
          'date_to': to.toIso8601String(),
          'truncated': rows.length == _limit(args),
        });
      }),
      _tool('ledger_get', '读取单条账目详情', 'ledger', ToolRiskLevel.read, _idSchema,
          (args, _) async {
        final row = await database.getLedgerTransaction(args['id'] as String);
        return row == null
            ? ToolResult.failure('not_found', '账目不存在')
            : ToolResult.success(_ledgerJson(row));
      }),
      _tool('ledger_create', '创建一条收入或支出', 'ledger', ToolRiskLevel.create,
          _ledgerCreateSchema, (args, _) async {
        final id = const Uuid().v4();
        final occurredAt = _date(args['occurred_at']) ?? DateTime.now();
        await database.createLedgerTransaction(
          id: id,
          direction: args['direction'] as String,
          amountCents: args['amount_cents'] as int,
          categoryCode: args['category_code'] as String,
          note: args['note'] as String? ?? '',
          occurredAt: occurredAt,
          source: args['source'] as String? ?? 'typedText',
          rawText: args['raw_text'] as String? ?? args['note'] as String? ?? '',
        );
        return ToolResult.success({'id': id, ...args});
      }),
      _ledgerUpdateTool(database),
      _ledgerDeleteTool(database),
      _tool('ledger_summary', '统计指定月份的收入、支出和结余', 'ledger', ToolRiskLevel.read,
          _ledgerSummarySchema, (args, _) async {
        final summary = await database.ledgerSummary(
            args['year'] as int, args['month'] as int);
        return ToolResult.success({
          'year': args['year'],
          'month': args['month'],
          'income_cents': summary.incomeCents,
          'expense_cents': summary.expenseCents,
          'balance_cents': summary.balanceCents,
        });
      }),
    ];

AgentTool _recordGetTool(AppDatabase db, String name, String domain) => _tool(
      name,
      '读取单条$domain记录详情',
      domain,
      ToolRiskLevel.read,
      _idSchema,
      (args, _) async {
        final record = await db.getAgentRecord(args['id'] as String);
        if (record == null || record.type != domain) {
          return ToolResult.failure('not_found', '记录不存在');
        }
        return ToolResult.success(record.toJson());
      },
    );

AgentTool _recordUpdateTool(AppDatabase db, String name, String domain) =>
    _tool(
      name,
      '修改已有$domain记录',
      domain,
      ToolRiskLevel.update,
      _recordUpdateSchema,
      (args, _) async {
        final id = args['id'] as String;
        final changes = Map<String, dynamic>.from(args)..remove('id');
        final changed = await db.updateAgentRecord(id, changes,
            expectedUpdatedAt: args['expected_updated_at'] as String?);
        return changed
            ? ToolResult.success({'id': id, 'updated': true})
            : ToolResult.failure('not_found', '记录不存在');
      },
      preview: (args, _) async {
        final record = await db.getAgentRecord(args['id'] as String);
        return record == null
            ? null
            : ToolPreview(
                title: '修改${domain == 'todo' ? '待办' : '想法'}',
                affectedCount: 1,
                before: record.toJson(),
                after: args,
                recordVersion: record.updatedAt,
              );
      },
    );

AgentTool _recordDeleteTool(AppDatabase db, String name, String domain) =>
    _tool(
      name,
      '删除一条$domain记录',
      domain,
      ToolRiskLevel.delete,
      _idSchema,
      (args, _) async {
        final record = await db.getAgentRecord(args['id'] as String);
        if (record == null || record.type != domain) {
          return ToolResult.failure('not_found', '记录不存在');
        }
        await db.deleteEntry(record.id);
        return ToolResult.success({'id': record.id, 'deleted': true});
      },
      preview: (args, _) async {
        final record = await db.getAgentRecord(args['id'] as String);
        return record == null
            ? null
            : ToolPreview(
                title: '删除${domain == 'todo' ? '待办' : '想法'}',
                affectedCount: 1,
                before: record.toJson(),
                recordVersion: record.updatedAt,
              );
      },
    );

AgentTool _ledgerUpdateTool(AppDatabase db) => _tool(
      'ledger_update',
      '修改一条账目',
      'ledger',
      ToolRiskLevel.update,
      _ledgerUpdateSchema,
      (args, _) async {
        final id = args['id'] as String;
        final changes = Map<String, dynamic>.from(args)..remove('id');
        final changed = await db.updateLedgerTransaction(id, changes,
            expectedUpdatedAt: args['expected_updated_at'] as String?);
        return changed
            ? ToolResult.success({'id': id, 'updated': true})
            : ToolResult.failure('not_found', '账目不存在');
      },
      preview: (args, _) async {
        final row = await db.getLedgerTransaction(args['id'] as String);
        return row == null
            ? null
            : ToolPreview(
                title: '修改账目',
                affectedCount: 1,
                before: _ledgerJson(row),
                after: args,
                recordVersion: row.updatedAt,
              );
      },
    );

AgentTool _ledgerDeleteTool(AppDatabase db) => _tool(
      'ledger_delete',
      '删除一条账目',
      'ledger',
      ToolRiskLevel.delete,
      _idSchema,
      (args, _) async {
        final deleted = await db.deleteLedgerTransaction(args['id'] as String,
            expectedUpdatedAt: args['expected_updated_at'] as String?);
        return deleted
            ? ToolResult.success({'id': args['id'], 'deleted': true})
            : ToolResult.failure('not_found', '账目不存在');
      },
      preview: (args, _) async {
        final row = await db.getLedgerTransaction(args['id'] as String);
        return row == null
            ? null
            : ToolPreview(
                title: '删除账目',
                affectedCount: 1,
                before: _ledgerJson(row),
                recordVersion: row.updatedAt,
              );
      },
    );

AgentTool _tool(
  String name,
  String description,
  String domain,
  ToolRiskLevel risk,
  Map<String, dynamic> schema,
  _Execute execute, {
  _Preview? preview,
}) =>
    _CallbackTool(
      definition: AgentToolDefinition(
        name: name,
        description: description,
        domain: domain,
        parameters: schema,
      ),
      riskLevel: risk,
      onExecute: execute,
      onPreview: preview,
    );

class _CallbackTool extends AgentTool {
  _CallbackTool({
    required this.definition,
    required this.riskLevel,
    required _Execute onExecute,
    _Preview? onPreview,
  })  : _onExecute = onExecute,
        _onPreview = onPreview;

  @override
  final AgentToolDefinition definition;
  @override
  final ToolRiskLevel riskLevel;
  final _Execute _onExecute;
  final _Preview? _onPreview;

  @override
  Future<ToolResult> execute(
          Map<String, dynamic> arguments, ToolExecutionContext context) =>
      _onExecute(arguments, context);

  @override
  Future<ToolPreview?> preview(
      Map<String, dynamic> arguments, ToolExecutionContext context) async {
    return _onPreview?.call(arguments, context);
  }
}

DateTime? _date(dynamic value) => value is String && value.isNotEmpty
    ? DateTime.tryParse(value)?.toLocal()
    : null;
int _limit(Map<String, dynamic> args) =>
    (args['limit'] as int? ?? 50).clamp(1, 100);

Map<String, dynamic> _entryJson(EntryListItem item) => {
      'id': item.id,
      'type': item.type.name,
      'title': item.title,
      'summary': item.summary,
      'start_at': item.startAt?.toIso8601String(),
      'end_at': item.endAt?.toIso8601String(),
      'location': item.location,
      'status': item.status,
      'created_at': item.createdAt.toIso8601String(),
      'updated_at': item.updatedAt.toIso8601String(),
    };

Map<String, dynamic> _ledgerJson(LedgerTransaction row) => {
      'id': row.id,
      'direction': row.direction,
      'amount_cents': row.amountCents,
      'category_code': row.categoryCode,
      'note': row.note,
      'occurred_at': row.occurredAt,
      'updated_at': row.updatedAt,
    };

ToolResult _listResult(List<Map<String, dynamic>> items) => ToolResult.success({
      'items': items,
      'returned_count': items.length,
      'truncated': items.length >= 100,
    });

const _idSchema = {
  'type': 'object',
  'properties': {
    'id': {'type': 'string'},
    'expected_updated_at': {'type': 'string'},
  },
  'required': ['id'],
  'additionalProperties': false,
};
const _querySchema = {
  'type': 'object',
  'properties': {
    'date_from': {'type': 'string'},
    'date_to': {'type': 'string'},
    'keyword': {'type': 'string'},
    'limit': {'type': 'integer'},
    'cursor': {'type': 'string'},
    'include_completed': {'type': 'boolean'},
  },
  'required': [],
  'additionalProperties': false,
};
const _todoCreateSchema = {
  'type': 'object',
  'properties': {
    'title': {'type': 'string'},
    'summary': {'type': 'string'},
    'start_at': {'type': 'string'},
    'end_at': {'type': 'string'},
    'location': {'type': 'string'},
    'topic': {'type': 'string'},
    'reminder_at': {'type': 'string'},
    'status': {'type': 'string'},
  },
  'required': ['title'],
  'additionalProperties': false,
};
const _ideaCreateSchema = {
  'type': 'object',
  'properties': {
    'title': {'type': 'string'},
    'summary': {'type': 'string'},
    'source_hint': {'type': 'string'},
    'tags': {'type': 'array'},
  },
  'required': ['summary'],
  'additionalProperties': false,
};
const _recordUpdateSchema = {
  'type': 'object',
  'properties': {
    'id': {'type': 'string'},
    'title': {'type': 'string'},
    'summary': {'type': 'string'},
    'start_at': {'type': 'string'},
    'end_at': {'type': 'string'},
    'location': {'type': 'string'},
    'topic': {'type': 'string'},
    'status': {'type': 'string'},
    'expected_updated_at': {'type': 'string'},
  },
  'required': ['id'],
  'additionalProperties': false,
};
const _ledgerListSchema = {
  'type': 'object',
  'properties': {
    'date_from': {'type': 'string'},
    'date_to': {'type': 'string'},
    'keyword': {'type': 'string'},
    'limit': {'type': 'integer'},
    'cursor': {'type': 'string'},
  },
  'required': [],
  'additionalProperties': false,
};
const _ledgerCreateSchema = {
  'type': 'object',
  'properties': {
    'direction': {'type': 'string'},
    'amount_cents': {'type': 'integer'},
    'category_code': {'type': 'string'},
    'note': {'type': 'string'},
    'occurred_at': {'type': 'string'},
    'source': {'type': 'string'},
    'raw_text': {'type': 'string'},
  },
  'required': ['direction', 'amount_cents', 'category_code'],
  'additionalProperties': false,
};
const _ledgerUpdateSchema = {
  'type': 'object',
  'properties': {
    'id': {'type': 'string'},
    'direction': {'type': 'string'},
    'amount_cents': {'type': 'integer'},
    'category_code': {'type': 'string'},
    'note': {'type': 'string'},
    'occurred_at': {'type': 'string'},
    'expected_updated_at': {'type': 'string'},
  },
  'required': ['id'],
  'additionalProperties': false,
};
const _ledgerSummarySchema = {
  'type': 'object',
  'properties': {
    'year': {'type': 'integer'},
    'month': {'type': 'integer'},
  },
  'required': ['year', 'month'],
  'additionalProperties': false,
};
