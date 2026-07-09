part of 'app_database.dart';

class CaptureSessions extends Table {
  late final TextColumn id = text()();
  late final TextColumn rawText = text()();
  late final TextColumn status = text()();
  late final TextColumn createdAt = text()();
  late final TextColumn updatedAt = text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Entries extends Table {
  late final TextColumn id = text()();
  late final TextColumn entryType = text().named('type').customConstraint("NOT NULL CHECK (type IN ('todo', 'idea'))")();
  late final TextColumn title = text()();
  late final TextColumn rawText = text()();
  late final TextColumn normalizedText = text()();
  late final TextColumn createdAt = text()();
  late final TextColumn updatedAt = text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Todos extends Table {
  late final TextColumn entryId = text().references(Entries, #id, onDelete: KeyAction.cascade)();
  late final TextColumn startAt = text().nullable()();
  late final TextColumn endAt = text().nullable()();
  late final TextColumn location = text().nullable()();
  late final TextColumn topic = text().nullable()();
  late final TextColumn reminderAt = text().nullable()();
  late final TextColumn status = text().withDefault(const Constant('draft'))();

  @override
  Set<Column<Object>> get primaryKey => {entryId};
}

class Ideas extends Table {
  late final TextColumn entryId = text().references(Entries, #id, onDelete: KeyAction.cascade)();
  late final TextColumn summary = text()();
  late final TextColumn sourceHint = text().nullable()();
  late final BoolColumn favorite = boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {entryId};
}

class Tags extends Table {
  late final TextColumn id = text()();
  late final TextColumn name = text().unique()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class EntryTags extends Table {
  late final TextColumn entryId = text().references(Entries, #id, onDelete: KeyAction.cascade)();
  late final TextColumn tagId = text().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column<Object>> get primaryKey => {entryId, tagId};
}
