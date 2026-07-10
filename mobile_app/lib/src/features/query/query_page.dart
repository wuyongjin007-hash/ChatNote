import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_database.dart';
import '../../providers.dart';
import '../../widgets/page_header.dart';

class TodoQueryPage extends ConsumerWidget {
  const TodoQueryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PageHeader(title: '待办'),
          SizedBox(height: 12),
          Expanded(child: _TodoList()),
        ],
      ),
    );
  }
}

class IdeaQueryPage extends ConsumerStatefulWidget {
  const IdeaQueryPage({super.key});

  @override
  ConsumerState<IdeaQueryPage> createState() => _IdeaQueryPageState();
}

class _IdeaQueryPageState extends ConsumerState<IdeaQueryPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeader(title: '创意'),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '搜索创意...',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => setState(() {}),
              ),
            ),
            onSubmitted: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Expanded(child: _IdeaList(queryBuilder: _query)),
        ],
      ),
    );
  }

  String _query() => _searchController.text;
}

class _TodoList extends ConsumerWidget {
  const _TodoList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<EntryListItem>>(
      future: ref.watch(entryRepositoryProvider).loadUpcomingTodos(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final todos = snapshot.data!;
        if (todos.isEmpty) {
          return const Center(child: Text('还没有待办。'));
        }
        return ListView(children: _groupTodosByDay(context, todos));
      },
    );
  }
}

class _IdeaList extends ConsumerWidget {
  const _IdeaList({required this.queryBuilder});

  final String Function() queryBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<EntryListItem>>(
      future: ref.watch(entryRepositoryProvider).searchIdeas(queryBuilder()),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final ideas = snapshot.data!;
        if (ideas.isEmpty) {
          return const Center(child: Text('还没有创意。'));
        }
        return ListView.separated(
          itemCount: ideas.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final idea = ideas[index];
            return Card(
              child: ListTile(
                leading: const Icon(Icons.lightbulb_outline),
                title: Text(idea.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(idea.summary ?? idea.normalizedText),
                    if (idea.tags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final tag in idea.tags) _IdeaTagPill(tag: tag),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _IdeaTagPill extends StatelessWidget {
  const _IdeaTagPill({required this.tag});

  final String tag;

  static const _palette = [
    (background: Color(0xfffff1f2), foreground: Color(0xffbe123c)),
    (background: Color(0xffeff6ff), foreground: Color(0xff1d4ed8)),
    (background: Color(0xffecfdf5), foreground: Color(0xff047857)),
    (background: Color(0xfffff7ed), foreground: Color(0xffc2410c)),
    (background: Color(0xfff5f3ff), foreground: Color(0xff6d28d9)),
    (background: Color(0xfff0fdfa), foreground: Color(0xff0f766e)),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = _palette[tag.hashCode.abs() % _palette.length];
    return Container(
      key: Key('idea-tag-pill-$tag'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: colors.foreground.withValues(alpha: 0.14)),
      ),
      child: Text(
        tag,
        style: TextStyle(
          color: colors.foreground,
          fontSize: 11,
          height: 1.1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

List<Widget> _groupTodosByDay(BuildContext context, List<EntryListItem> todos) {
  final grouped = <String, List<EntryListItem>>{};
  for (final todo in todos) {
    final day = _dayLabel(todo.startAt!);
    grouped.putIfAbsent(day, () => []).add(todo);
  }

  return [
    for (final entry in grouped.entries) ...[
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          entry.key,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      for (final todo in entry.value)
        Card(
          child: ListTile(
            leading: const Icon(Icons.event_available),
            title: Text(todo.title),
            subtitle: Text([
              if (todo.startAt != null && todo.endAt != null)
                '${_timeLabel(todo.startAt!)}-${_timeLabel(todo.endAt!)}',
              if ((todo.location ?? '').isNotEmpty) todo.location!,
              if ((todo.topic ?? '').isNotEmpty) todo.topic!,
            ].join('  ')),
          ),
        ),
    ],
  ];
}

String _dayLabel(DateTime date) {
  const weekdays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
  return '${date.month}月${date.day}日 ${weekdays[date.weekday - 1]}';
}

String _timeLabel(DateTime date) {
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(date.hour)}:${two(date.minute)}';
}
