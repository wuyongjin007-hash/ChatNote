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
  var _refreshToken = 0;

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
                borderSide: const BorderSide(color: AppColors.border),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => setState(() => _refreshToken++),
              ),
            ),
            onSubmitted: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _IdeaList(
              query: _query(),
              refreshToken: _refreshToken,
            ),
          ),
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
  static const _futureWindow = Duration(days: 14);
  static const _pastWindow = Duration(days: 7);
  static const _prefetchExtent = 800.0;

  final _scrollController = ScrollController();
  final _todos = <EntryListItem>[];
  late DateTime _from;
  late DateTime _to;
  var _isInitialLoading = true;
  var _isLoadingNext = false;
  var _isLoadingPrevious = false;
  var _initialWindowCount = 0;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _from = DateTime(now.year, now.month, now.day);
    _to = _from.add(_futureWindow);
    _scrollController.addListener(_onScroll);
    _loadInitial();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadInitial() async {
    final items =
        await ref.read(entryRepositoryProvider).loadTodoWindow(_from, _to);
    if (!mounted) {
      return;
    }
    setState(() {
      _todos
        ..clear()
        ..addAll(items);
      _sortTodos();
      _isInitialLoading = false;
      _initialWindowCount = 1;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _fillInitialViewport());
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.extentAfter < _prefetchExtent) {
      _loadNext();
    }
  }

  Future<void> _fillInitialViewport() async {
    while (mounted &&
        _initialWindowCount < 3 &&
        _scrollController.hasClients &&
        _scrollController.position.maxScrollExtent <= 0) {
      await _loadNext(isInitialFill: true);
    }
  }

  Future<void> _loadNext({bool isInitialFill = false}) async {
    if (_isLoadingNext) {
      return;
    }
    _isLoadingNext = true;
    final nextTo = _to.add(_futureWindow);
    final items =
        await ref.read(entryRepositoryProvider).loadTodoWindow(_to, nextTo);
    if (!mounted) {
      return;
    }
    setState(() {
      _mergeTodos(items);
      _to = nextTo;
      _isLoadingNext = false;
      if (isInitialFill) {
        _initialWindowCount++;
      }
    });
  }

  Future<void> _loadPrevious() async {
    if (_isLoadingPrevious || !_scrollController.hasClients) {
      return;
    }
    _isLoadingPrevious = true;
    final previousFrom = _from.subtract(_pastWindow);
    final previousMaxExtent = _scrollController.position.maxScrollExtent;
    final previousOffset = _scrollController.offset;
    final items = await ref
        .read(entryRepositoryProvider)
        .loadTodoWindow(previousFrom, _from);
    if (!mounted) {
      return;
    }
    setState(() {
      _mergeTodos(items);
      _from = previousFrom;
      _isLoadingPrevious = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }
      final addedExtent =
          _scrollController.position.maxScrollExtent - previousMaxExtent;
      _scrollController.jumpTo((previousOffset + addedExtent).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      ));
    });
  }

  void _mergeTodos(Iterable<EntryListItem> items) {
    final byId = {for (final todo in _todos) todo.id: todo};
    for (final todo in items) {
      byId[todo.id] = todo;
    }
    _todos
      ..clear()
      ..addAll(byId.values);
    _sortTodos();
  }

  void _sortTodos() {
    _todos.sort((left, right) => left.startAt!.compareTo(right.startAt!));
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
      final index = _todos.indexWhere((item) => item.id == todo.id);
      if (index >= 0) {
        _todos[index] = _copyTodoWithStatus(todo, nextStatus);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitialLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final rows = _todoRows(_todos);
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is OverscrollNotification &&
            notification.overscroll < 0 &&
            _scrollController.hasClients &&
            _scrollController.position.pixels <= 0) {
          _loadPrevious();
        }
        return false;
      },
      child: ListView.builder(
        key: const PageStorageKey('todo-incremental-list'),
        controller: _scrollController,
        itemCount: rows.length + (_isLoadingNext ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == rows.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Center(
                  child: SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))),
            );
          }
          final row = rows[index];
          return switch (row) {
            _TodoDayHeaderRow(:final day) => Padding(
                key: Key(
                    'todo-day-${_relativeDayKey(day, _dateOnly(DateTime.now()))}-header'),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  _dayLabel(day),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            _TodoItemRow(:final todo) => _TodoCard(
                key: ValueKey(todo.id),
                todo: todo,
                onToggle: () => _toggleTodo(todo),
              ),
            _TodoEmptyTodayRow() => Card(
                color: AppColors.surface,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  child: Text(
                    '今天还没有待办。',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              ),
          };
        },
      ),
    );
  }
}

class _IdeaList extends ConsumerStatefulWidget {
  const _IdeaList({required this.query, required this.refreshToken});

  final String query;
  final int refreshToken;

  @override
  ConsumerState<_IdeaList> createState() => _IdeaListState();
}

class _IdeaListState extends ConsumerState<_IdeaList> {
  static const _deleteAnimationDuration = Duration(milliseconds: 420);
  static const _pageSize = 40;
  static const _prefetchExtent = 1200.0;

  final _scrollController = ScrollController();
  final _ideas = <EntryListItem>[];
  final _deletingIdeaIds = <String>{};
  OverlayEntry? _copyOverlay;
  IdeaPageCursor? _nextCursor;
  var _hasMore = true;
  var _isInitialLoading = true;
  var _isRefreshing = false;
  var _isLoadingNext = false;
  var _requestVersion = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitial();
  }

  @override
  void didUpdateWidget(covariant _IdeaList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query ||
        oldWidget.refreshToken != widget.refreshToken) {
      _loadInitial();
    }
  }

  @override
  void dispose() {
    _dismissCopyOverlay();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.extentAfter < _prefetchExtent) {
      _loadNext();
    }
  }

  Future<void> _loadInitial() async {
    final version = ++_requestVersion;
    setState(() {
      if (_ideas.isEmpty) {
        _isInitialLoading = true;
      } else {
        _isRefreshing = true;
      }
      _hasMore = true;
      _nextCursor = null;
    });
    final page = await ref.read(entryRepositoryProvider).loadIdeaPage(
          query: widget.query,
          limit: _pageSize,
        );
    if (!mounted || version != _requestVersion) {
      return;
    }
    setState(() {
      _ideas
        ..clear()
        ..addAll(page.items);
      _nextCursor = page.nextCursor;
      _hasMore = page.hasMore;
      _isInitialLoading = false;
      _isRefreshing = false;
    });
  }

  Future<void> _loadNext() async {
    if (_isLoadingNext || !_hasMore || _nextCursor == null) {
      return;
    }
    _isLoadingNext = true;
    final version = _requestVersion;
    final page = await ref.read(entryRepositoryProvider).loadIdeaPage(
          query: widget.query,
          after: _nextCursor,
          limit: _pageSize,
        );
    if (!mounted || version != _requestVersion) {
      return;
    }
    setState(() {
      final existingIds = _ideas.map((idea) => idea.id).toSet();
      _ideas.addAll(page.items.where((idea) => existingIds.add(idea.id)));
      _nextCursor = page.nextCursor;
      _hasMore = page.hasMore;
      _isLoadingNext = false;
    });
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
      _ideas.removeWhere((idea) => idea.id == id);
    });
    if (_ideas.length < _pageSize && _hasMore) {
      _loadNext();
    }
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
    if (_isInitialLoading && _ideas.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_ideas.isEmpty) {
      return const Center(child: Text('还没有想法。'));
    }
    return Column(
      children: [
        if (_isRefreshing) const LinearProgressIndicator(minHeight: 2),
        Expanded(
          child: ListView.separated(
            key: const PageStorageKey('idea-incremental-list'),
            controller: _scrollController,
            itemCount: _ideas.length + (_isLoadingNext ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              if (index == _ideas.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Center(
                      child: SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))),
                );
              }
              final idea = _ideas[index];
              return _IdeaDeleteAnimation(
                key: ValueKey('idea-delete-animation-${idea.id}'),
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
                                        padding: const EdgeInsets.only(top: 9),
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
          ),
        ),
      ],
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

sealed class _TodoListRow {
  const _TodoListRow();
}

class _TodoDayHeaderRow extends _TodoListRow {
  const _TodoDayHeaderRow(this.day);

  final DateTime day;
}

class _TodoItemRow extends _TodoListRow {
  const _TodoItemRow(this.todo);

  final EntryListItem todo;
}

class _TodoEmptyTodayRow extends _TodoListRow {
  const _TodoEmptyTodayRow();
}

List<_TodoListRow> _todoRows(List<EntryListItem> todos) {
  final today = _dateOnly(DateTime.now());
  final grouped = <DateTime, List<EntryListItem>>{};
  for (final todo in todos) {
    final day = _dateOnly(todo.startAt!.toLocal());
    grouped.putIfAbsent(day, () => []).add(todo);
  }
  grouped.putIfAbsent(today, () => const []);

  final days = grouped.keys.toList()..sort();

  return [
    for (final day in days) ...[
      _TodoDayHeaderRow(day),
      if (grouped[day]!.isEmpty)
        const _TodoEmptyTodayRow()
      else
        for (final todo in grouped[day]!) _TodoItemRow(todo),
    ],
  ];
}

class _TodoCard extends StatelessWidget {
  const _TodoCard({super.key, required this.todo, required this.onToggle});

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

EntryListItem _copyTodoWithStatus(EntryListItem todo, String status) {
  return EntryListItem(
    id: todo.id,
    type: todo.type,
    title: todo.title,
    rawText: todo.rawText,
    normalizedText: todo.normalizedText,
    createdAt: todo.createdAt,
    updatedAt: DateTime.now(),
    startAt: todo.startAt,
    endAt: todo.endAt,
    location: todo.location,
    topic: todo.topic,
    summary: todo.summary,
    tags: todo.tags,
    status: status,
  );
}

DateTime _dateOnly(DateTime date) {
  final local = date.toLocal();
  return DateTime(local.year, local.month, local.day);
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
