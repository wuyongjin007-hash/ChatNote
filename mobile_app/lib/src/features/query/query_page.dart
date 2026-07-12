import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../data/app_database.dart';
import '../../providers.dart';
import '../../theme/app_colors.dart';
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
          const PageHeader(title: '想法'),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: '搜索想法...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.surfaceSoft,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
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

class _TodoList extends ConsumerStatefulWidget {
  const _TodoList();

  @override
  ConsumerState<_TodoList> createState() => _TodoListState();
}

class _TodoListState extends ConsumerState<_TodoList> {
  late Future<List<EntryListItem>> _todos;

  @override
  void initState() {
    super.initState();
    _todos = ref.read(entryRepositoryProvider).loadUpcomingTodos();
  }

  Future<void> _toggleTodo(EntryListItem todo) async {
    final nextStatus = todo.status == 'completed' ? 'pending' : 'completed';
    await ref
        .read(entryRepositoryProvider)
        .updateTodoStatus(todo.id, nextStatus);
    if (!mounted) {
      return;
    }
    setState(() {
      _todos = ref.read(entryRepositoryProvider).loadUpcomingTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EntryListItem>>(
      future: _todos,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final todos = snapshot.data!;
        if (todos.isEmpty) {
          return const Center(child: Text('还没有待办。'));
        }
        return ListView(
          children: _groupTodosByDay(context, todos, _toggleTodo),
        );
      },
    );
  }
}

class _IdeaList extends ConsumerStatefulWidget {
  const _IdeaList({required this.queryBuilder});

  final String Function() queryBuilder;

  @override
  ConsumerState<_IdeaList> createState() => _IdeaListState();
}

class _IdeaListState extends ConsumerState<_IdeaList> {
  static const _deleteAnimationDuration = Duration(milliseconds: 420);

  late String _query;
  late Future<List<EntryListItem>> _ideas;
  final _deletingIdeaIds = <String>{};
  final _hiddenIdeaIds = <String>{};
  OverlayEntry? _copyOverlay;

  @override
  void initState() {
    super.initState();
    _query = widget.queryBuilder();
    _ideas = ref.read(entryRepositoryProvider).searchIdeas(_query);
  }

  @override
  void didUpdateWidget(covariant _IdeaList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _query = widget.queryBuilder();
    _ideas = ref.read(entryRepositoryProvider).searchIdeas(_query);
  }

  Future<void> _deleteIdea(String id) async {
    if (_deletingIdeaIds.contains(id)) {
      return;
    }

    setState(() {
      _deletingIdeaIds.add(id);
    });

    final repository = ref.read(entryRepositoryProvider);
    await Future<void>.delayed(_deleteAnimationDuration);
    await repository.deleteIdea(id);
    if (!mounted) {
      return;
    }
    setState(() {
      _deletingIdeaIds.remove(id);
      _hiddenIdeaIds.add(id);
    });
  }

  void _showCopyOverlay(EntryListItem idea, Offset globalPosition) {
    _dismissCopyOverlay();
    _copyOverlay = OverlayEntry(
      builder: (_) => GestureDetector(
        onTap: _dismissCopyOverlay,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            const Positioned.fill(
              child: ColoredBox(color: Colors.transparent),
            ),
            Positioned(
              left: globalPosition.dx - 28,
              top: globalPosition.dy - 40,
              child: _CopyButton(
                onTap: () {
                  _dismissCopyOverlay();
                  Clipboard.setData(ClipboardData(
                    text:
                        '${idea.title}\n${idea.summary ?? idea.normalizedText}',
                  ));
                },
              ),
            ),
          ],
        ),
      ),
    );
    Overlay.of(context).insert(_copyOverlay!);
  }

  void _dismissCopyOverlay() {
    _copyOverlay?.remove();
    _copyOverlay = null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<EntryListItem>>(
      future: _ideas,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final ideas = snapshot.data!
            .where((idea) => !_hiddenIdeaIds.contains(idea.id))
            .toList(growable: false);
        if (ideas.isEmpty) {
          return const Center(child: Text('还没有想法。'));
        }
        return ListView.separated(
          itemCount: ideas.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final idea = ideas[index];
            return _IdeaDeleteAnimation(
              key: Key('idea-delete-animation-${idea.id}'),
              isDeleting: _deletingIdeaIds.contains(idea.id),
              child: Slidable(
                key: Key('idea-card-${idea.id}'),
                groupTag: 'ideas',
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  extentRatio: 0.22,
                  children: [
                    CustomSlidableAction(
                      key: Key('idea-delete-action-${idea.id}'),
                      onPressed: (_) => _deleteIdea(idea.id),
                      padding: const EdgeInsets.only(left: 10),
                      backgroundColor: Colors.transparent,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: Color(0xffff3b30),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onLongPressStart: (details) =>
                      _showCopyOverlay(idea, details.globalPosition),
                  child: Container(
                    key: const Key('idea-card'),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.035),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(14, 13, 12, 13),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    idea.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                          height: 1.2,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    idea.summary ?? idea.normalizedText,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                          height: 1.35,
                                        ),
                                  ),
                                  if (idea.tags.isNotEmpty)
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(top: 9),
                                      child: Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: [
                                          for (final tag in idea.tags)
                                            _IdeaTagPill(tag: tag),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            width: 4,
                            decoration: const BoxDecoration(
                              color: AppColors.accentLine,
                              borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _IdeaDeleteAnimation extends StatelessWidget {
  const _IdeaDeleteAnimation({
    super.key,
    required this.isDeleting,
    required this.child,
  });

  final bool isDeleting;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isDeleting) {
      return child;
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: _IdeaListState._deleteAnimationDuration,
      curve: Curves.easeInOutCubic,
      child: child,
      builder: (context, progress, child) {
        final opacity = 1 - (progress / 0.34).clamp(0.0, 1.0);
        final heightFactor = progress <= 0.22
            ? 1.0
            : 1 - ((progress - 0.22) / 0.78).clamp(0.0, 1.0);
        return SizeTransition(
          alignment: Alignment.topCenter,
          sizeFactor: AlwaysStoppedAnimation(heightFactor),
          child: Opacity(opacity: opacity, child: child),
        );
      },
    );
  }
}

class _IdeaTagPill extends StatelessWidget {
  const _IdeaTagPill({required this.tag});

  final String tag;

  static const _palette = [
    (background: Color(0xffeaf2ff), foreground: Color(0xff2865c7)),
    (background: Color(0xffe8f5ef), foreground: Color(0xff16805f)),
    (background: Color(0xfffff1de), foreground: Color(0xffb8611f)),
    (background: Color(0xfffcebec), foreground: Color(0xffb9424b)),
    (background: Color(0xfff1ecfa), foreground: Color(0xff7250a6)),
    (background: Color(0xffe7f5f3), foreground: Color(0xff287e76)),
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

List<Widget> _groupTodosByDay(
  BuildContext context,
  List<EntryListItem> todos,
  ValueChanged<EntryListItem> onToggle,
) {
  final today = _dateOnly(DateTime.now());
  final grouped = <DateTime, List<EntryListItem>>{};
  for (final todo in todos) {
    final day = _dateOnly(todo.startAt!.toLocal());
    grouped.putIfAbsent(day, () => []).add(todo);
  }
  grouped.putIfAbsent(today, () => const []);

  final days = grouped.keys.toList()
    ..sort((a, b) {
      final rankA = _dayRank(a, today);
      final rankB = _dayRank(b, today);
      if (rankA != rankB) {
        return rankA.compareTo(rankB);
      }
      if (rankA == 2) {
        return b.compareTo(a);
      }
      return a.compareTo(b);
    });

  return [
    for (final day in days) ...[
      Padding(
        key: Key('todo-day-${_relativeDayKey(day, today)}-header'),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          _dayLabel(day),
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      if (grouped[day]!.isEmpty)
        Card(
          color: AppColors.surface,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Text(
              '今天还没有待办。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
        )
      else
        for (final todo in grouped[day]!)
          _TodoCard(todo: todo, onToggle: () => onToggle(todo)),
    ],
  ];
}

class _TodoCard extends StatelessWidget {
  const _TodoCard({required this.todo, required this.onToggle});

  final EntryListItem todo;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final detail = _todoDetail(todo);
    final isCompleted = todo.status == 'completed';
    return Container(
      key: const Key('todo-card'),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            const SizedBox(width: 18),
            InkWell(
              key: const Key('todo-check-box'),
              onTap: onToggle,
              borderRadius: BorderRadius.circular(5),
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color:
                      isCompleted ? AppColors.surfaceSoft : Colors.transparent,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: AppColors.textMuted,
                    width: 1.5,
                  ),
                ),
                child: isCompleted
                    ? const Icon(
                        Icons.check,
                        size: 17,
                        color: AppColors.textMuted,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      todo.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isCompleted
                                ? AppColors.textMuted
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w400,
                            height: 1.2,
                            decoration:
                                isCompleted ? TextDecoration.lineThrough : null,
                            decorationColor: AppColors.textMuted,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isCompleted
                                ? AppColors.textMuted
                                : AppColors.success,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              key: const Key('todo-card-accent'),
              width: 5,
              decoration: const BoxDecoration(
                color: AppColors.accentLine,
                borderRadius: BorderRadius.horizontal(
                  right: Radius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

DateTime _dateOnly(DateTime date) {
  final local = date.toLocal();
  return DateTime(local.year, local.month, local.day);
}

int _dayRank(DateTime day, DateTime today) {
  if (day == today) {
    return 0;
  }
  if (day.isAfter(today)) {
    return 1;
  }
  return 2;
}

String _relativeDayKey(DateTime day, DateTime today) {
  if (day == today) {
    return 'today';
  }
  if (day == today.subtract(const Duration(days: 1))) {
    return 'yesterday';
  }
  if (day == today.add(const Duration(days: 1))) {
    return 'tomorrow';
  }
  String two(int value) => value.toString().padLeft(2, '0');
  return '${day.year}-${two(day.month)}-${two(day.day)}';
}

String _dayLabel(DateTime date) {
  final local = date.toLocal();
  date = local;
  const weekdays = ['星期一', '星期二', '星期三', '星期四', '星期五', '星期六', '星期日'];
  return '${date.month}月${date.day}日 ${weekdays[date.weekday - 1]}';
}

String _timeLabel(DateTime date) {
  final local = date.toLocal();
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(local.hour)}:${two(local.minute)}';
}

String _todoDetail(EntryListItem todo) {
  final parts = <String>[
    if (todo.startAt != null) _timeLabel(todo.startAt!),
    if ((todo.location ?? '').isNotEmpty) todo.location!,
  ];
  return parts.join('  ');
}

class _CopyButton extends StatelessWidget {
  const _CopyButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: const Text(
            '复制',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
