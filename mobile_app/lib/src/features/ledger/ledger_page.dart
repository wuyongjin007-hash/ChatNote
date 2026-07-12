import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_database.dart';
import '../../providers.dart';
import '../../widgets/page_header.dart';

class LedgerPage extends ConsumerStatefulWidget {
  const LedgerPage({super.key});

  @override
  ConsumerState<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends ConsumerState<LedgerPage> {
  late DateTime _month;
  late Future<_LedgerMonthData> _data;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
    _reload();
  }

  void _reload() {
    _data = _load();
  }

  Future<_LedgerMonthData> _load() async {
    final database = ref.read(databaseProvider);
    final next = DateTime(_month.year, _month.month + 1);
    final results = await Future.wait<Object>([
      database.ledgerSummary(_month.year, _month.month),
      database.listLedgerTransactions(_month, next),
    ]);
    return _LedgerMonthData(
      summary: results[0] as LedgerMonthlySummary,
      rows: results[1] as List<LedgerTransaction>,
    );
  }

  void _changeMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
      _reload();
    });
  }

  Future<void> _editTransaction(LedgerTransaction row) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _LedgerEditorSheet(
        database: ref.read(databaseProvider),
        row: row,
      ),
    );
    if (changed == true && mounted) {
      setState(_reload);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          const PageHeader(title: '记账'),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                key: const Key('ledger-previous-month'),
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Text(
                '${_month.year}年${_month.month}月',
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              IconButton(
                key: const Key('ledger-next-month'),
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder<_LedgerMonthData>(
              future: _data,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = snapshot.data!;
                return RefreshIndicator(
                  onRefresh: () async {
                    setState(_reload);
                    await _data;
                  },
                  child: _LedgerMonthView(
                    data: data,
                    onEdit: _editTransaction,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LedgerMonthView extends StatelessWidget {
  const _LedgerMonthView({required this.data, required this.onEdit});
  final _LedgerMonthData data;
  final ValueChanged<LedgerTransaction> onEdit;

  @override
  Widget build(BuildContext context) {
    final groups = <DateTime, List<LedgerTransaction>>{};
    for (final row in data.rows) {
      final local = DateTime.parse(row.occurredAt).toLocal();
      final day = DateTime(local.year, local.month, local.day);
      groups.putIfAbsent(day, () => []).add(row);
    }
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        _MonthlySummaryCard(summary: data.summary),
        const SizedBox(height: 18),
        if (groups.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 90),
            child: Column(
              children: [
                Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text('这个月还没有账目'),
                SizedBox(height: 4),
                Text('去记录页说一句话，记下第一笔收支'),
              ],
            ),
          )
        else
          for (final entry in groups.entries) ...[
            _DayHeader(day: entry.key, rows: entry.value),
            for (final row in entry.value)
              _LedgerRow(row: row, onTap: () => onEdit(row)),
            const SizedBox(height: 14),
          ],
      ],
    );
  }
}

class _MonthlySummaryCard extends StatelessWidget {
  const _MonthlySummaryCard({required this.summary});
  final LedgerMonthlySummary summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xffeaf1ff), Color(0xfff6f9ff)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffd7e3ff)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('本月支出', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 4),
          Text(
            _money(summary.expenseCents),
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 22,
            children: [
              Text('收入 ${_money(summary.incomeCents)}',
                  style: const TextStyle(color: Color(0xff18876b))),
              Text('结余 ${_money(summary.balanceCents)}',
                  style: const TextStyle(color: Color(0xff315fbd))),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day, required this.rows});
  final DateTime day;
  final List<LedgerTransaction> rows;

  @override
  Widget build(BuildContext context) {
    var income = 0;
    var expense = 0;
    for (final row in rows) {
      if (row.direction == 'income') {
        income += row.amountCents;
      } else {
        expense += row.amountCents;
      }
    }
    final now = DateTime.now();
    final isToday =
        day.year == now.year && day.month == now.month && day.day == now.day;
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 4, 2, 8),
      child: Row(
        children: [
          Text(
            '${isToday ? '今天 ' : ''}${day.month}月${day.day}日',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          Text('支出 ${_money(expense)}  收入 ${_money(income)}',
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
        ],
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  const _LedgerRow({required this.row, required this.onTap});
  final LedgerTransaction row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final time = DateTime.parse(row.occurredAt).toLocal();
    final income = row.direction == 'income';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Icon(income ? Icons.south_west : Icons.north_east, size: 18),
        ),
        title: Text(row.note.isEmpty ? _category(row.categoryCode) : row.note),
        subtitle: Text(
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}  ${_category(row.categoryCode)}'),
        trailing: Text(
          '${income ? '+' : '-'}${_money(row.amountCents)}',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: income ? const Color(0xff18876b) : Colors.black87,
          ),
        ),
      ),
    );
  }
}

class _LedgerEditorSheet extends StatefulWidget {
  const _LedgerEditorSheet({required this.database, required this.row});
  final AppDatabase database;
  final LedgerTransaction row;

  @override
  State<_LedgerEditorSheet> createState() => _LedgerEditorSheetState();
}

class _LedgerEditorSheetState extends State<_LedgerEditorSheet> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late String _direction;
  late String _category;
  late DateTime _occurredAt;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text:
          '${widget.row.amountCents ~/ 100}.${(widget.row.amountCents % 100).toString().padLeft(2, '0')}',
    );
    _noteController = TextEditingController(text: widget.row.note);
    _direction = widget.row.direction;
    _category = widget.row.categoryCode;
    _occurredAt = DateTime.parse(widget.row.occurredAt).toLocal();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  List<String> get _categories => _direction == 'income'
      ? const [
          'salary',
          'bonus',
          'part_time',
          'investment',
          'refund',
          'gift',
          'other_income'
        ]
      : const [
          'food',
          'transport',
          'shopping',
          'housing',
          'entertainment',
          'medical',
          'education',
          'social',
          'tobacco_alcohol',
          'other_expense'
        ];

  Future<void> _save() async {
    final cents = _parseCents(_amountController.text);
    if (cents == null || cents <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('请输入正确的金额')));
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.database.updateLedgerTransaction(
        widget.row.id,
        {
          'direction': _direction,
          'amount_cents': cents,
          'category_code': _category,
          'note': _noteController.text.trim(),
          'occurred_at': _occurredAt.toUtc().toIso8601String(),
        },
        expectedUpdatedAt: widget.row.updatedAt,
      );
      if (mounted) Navigator.of(context).pop(true);
    } on StateError {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('账目已在其他位置更新，请刷新后重试')));
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除账目？'),
        content: Text('确定删除“${widget.row.note}”吗？此操作无法撤销。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('删除')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await widget.database.deleteLedgerTransaction(widget.row.id,
        expectedUpdatedAt: widget.row.updatedAt);
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _occurredAt,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      _occurredAt = DateTime(picked.year, picked.month, picked.day,
          _occurredAt.hour, _occurredAt.minute);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            20, 18, 20, 18 + MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('编辑账目',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'expense', label: Text('支出')),
                  ButtonSegment(value: 'income', label: Text('收入')),
                ],
                selected: {_direction},
                onSelectionChanged: (selection) {
                  setState(() {
                    _direction = selection.single;
                    if (!_categories.contains(_category)) {
                      _category = _categories.first;
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: '金额（元）'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: '分类'),
                items: _categories
                    .map((code) => DropdownMenuItem(
                        value: code, child: Text(_categoryName(code))))
                    .toList(),
                onChanged: (value) => setState(() => _category = value!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: '备注'),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('发生日期'),
                subtitle: Text(
                    '${_occurredAt.year}年${_occurredAt.month}月${_occurredAt.day}日'),
                trailing: const Icon(Icons.calendar_month_outlined),
                onTap: _pickDate,
              ),
              const SizedBox(height: 12),
              FilledButton(
                key: const Key('ledger-edit-save'),
                onPressed: _saving ? null : _save,
                child: const Text('保存修改'),
              ),
              TextButton.icon(
                key: const Key('ledger-edit-delete'),
                onPressed: _saving ? null : _delete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('删除账目'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _categoryName(String code) => _category(code);

int? _parseCents(String value) {
  final normalized = value.trim();
  if (!RegExp(r'^\d+(?:\.\d{1,2})?$').hasMatch(normalized)) return null;
  final parts = normalized.split('.');
  final yuan = int.tryParse(parts[0]);
  if (yuan == null) return null;
  final fraction = parts.length == 1
      ? 0
      : int.parse(parts[1].padRight(2, '0').substring(0, 2));
  return yuan * 100 + fraction;
}

class _LedgerMonthData {
  const _LedgerMonthData({required this.summary, required this.rows});
  final LedgerMonthlySummary summary;
  final List<LedgerTransaction> rows;
}

String _money(int cents) {
  final sign = cents < 0 ? '-' : '';
  final absolute = cents.abs();
  return '$sign¥${absolute ~/ 100}.${(absolute % 100).toString().padLeft(2, '0')}';
}

String _category(String code) =>
    const {
      'food': '餐饮',
      'transport': '交通',
      'shopping': '购物',
      'housing': '居住',
      'entertainment': '娱乐',
      'medical': '医疗',
      'education': '学习',
      'social': '人情',
      'tobacco_alcohol': '烟酒',
      'salary': '工资',
      'bonus': '奖金',
      'part_time': '兼职',
      'investment': '理财',
      'refund': '退款',
      'gift': '礼金',
    }[code] ??
    '其他';
