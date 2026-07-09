class TodoTimeBlock {
  const TodoTimeBlock({
    required this.id,
    required this.title,
    required this.startAt,
    required this.endAt,
  });

  final String id;
  final String title;
  final DateTime startAt;
  final DateTime endAt;
}

List<TodoTimeBlock> findTodoConflicts(TodoTimeBlock candidate, Iterable<TodoTimeBlock> existing) {
  return existing.where((block) {
    if (block.id == candidate.id) {
      return false;
    }
    return block.startAt.isBefore(candidate.endAt) && block.endAt.isAfter(candidate.startAt);
  }).toList(growable: false);
}
