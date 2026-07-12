// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CaptureSessionsTable extends CaptureSessions
    with TableInfo<$CaptureSessionsTable, CaptureSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CaptureSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rawTextMeta =
      const VerificationMeta('rawText');
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
      'raw_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _conversationJsonMeta =
      const VerificationMeta('conversationJson');
  @override
  late final GeneratedColumn<String> conversationJson = GeneratedColumn<String>(
      'conversation_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _activeDraftJsonMeta =
      const VerificationMeta('activeDraftJson');
  @override
  late final GeneratedColumn<String> activeDraftJson = GeneratedColumn<String>(
      'active_draft_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recoverableDraftJsonMeta =
      const VerificationMeta('recoverableDraftJson');
  @override
  late final GeneratedColumn<String> recoverableDraftJson =
      GeneratedColumn<String>('recoverable_draft_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _expiresAtMeta =
      const VerificationMeta('expiresAt');
  @override
  late final GeneratedColumn<String> expiresAt = GeneratedColumn<String>(
      'expires_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        rawText,
        status,
        createdAt,
        updatedAt,
        conversationJson,
        activeDraftJson,
        recoverableDraftJson,
        expiresAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'capture_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<CaptureSession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('raw_text')) {
      context.handle(_rawTextMeta,
          rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta));
    } else if (isInserting) {
      context.missing(_rawTextMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('conversation_json')) {
      context.handle(
          _conversationJsonMeta,
          conversationJson.isAcceptableOrUnknown(
              data['conversation_json']!, _conversationJsonMeta));
    }
    if (data.containsKey('active_draft_json')) {
      context.handle(
          _activeDraftJsonMeta,
          activeDraftJson.isAcceptableOrUnknown(
              data['active_draft_json']!, _activeDraftJsonMeta));
    }
    if (data.containsKey('recoverable_draft_json')) {
      context.handle(
          _recoverableDraftJsonMeta,
          recoverableDraftJson.isAcceptableOrUnknown(
              data['recoverable_draft_json']!, _recoverableDraftJsonMeta));
    }
    if (data.containsKey('expires_at')) {
      context.handle(_expiresAtMeta,
          expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CaptureSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CaptureSession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      rawText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_text'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
      conversationJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}conversation_json']),
      activeDraftJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}active_draft_json']),
      recoverableDraftJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}recoverable_draft_json']),
      expiresAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}expires_at']),
    );
  }

  @override
  $CaptureSessionsTable createAlias(String alias) {
    return $CaptureSessionsTable(attachedDatabase, alias);
  }
}

class CaptureSession extends DataClass implements Insertable<CaptureSession> {
  final String id;
  final String rawText;
  final String status;
  final String createdAt;
  final String updatedAt;
  final String? conversationJson;
  final String? activeDraftJson;
  final String? recoverableDraftJson;
  final String? expiresAt;
  const CaptureSession(
      {required this.id,
      required this.rawText,
      required this.status,
      required this.createdAt,
      required this.updatedAt,
      this.conversationJson,
      this.activeDraftJson,
      this.recoverableDraftJson,
      this.expiresAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['raw_text'] = Variable<String>(rawText);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    if (!nullToAbsent || conversationJson != null) {
      map['conversation_json'] = Variable<String>(conversationJson);
    }
    if (!nullToAbsent || activeDraftJson != null) {
      map['active_draft_json'] = Variable<String>(activeDraftJson);
    }
    if (!nullToAbsent || recoverableDraftJson != null) {
      map['recoverable_draft_json'] = Variable<String>(recoverableDraftJson);
    }
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<String>(expiresAt);
    }
    return map;
  }

  CaptureSessionsCompanion toCompanion(bool nullToAbsent) {
    return CaptureSessionsCompanion(
      id: Value(id),
      rawText: Value(rawText),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      conversationJson: conversationJson == null && nullToAbsent
          ? const Value.absent()
          : Value(conversationJson),
      activeDraftJson: activeDraftJson == null && nullToAbsent
          ? const Value.absent()
          : Value(activeDraftJson),
      recoverableDraftJson: recoverableDraftJson == null && nullToAbsent
          ? const Value.absent()
          : Value(recoverableDraftJson),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
    );
  }

  factory CaptureSession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CaptureSession(
      id: serializer.fromJson<String>(json['id']),
      rawText: serializer.fromJson<String>(json['rawText']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
      conversationJson: serializer.fromJson<String?>(json['conversationJson']),
      activeDraftJson: serializer.fromJson<String?>(json['activeDraftJson']),
      recoverableDraftJson:
          serializer.fromJson<String?>(json['recoverableDraftJson']),
      expiresAt: serializer.fromJson<String?>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'rawText': serializer.toJson<String>(rawText),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
      'conversationJson': serializer.toJson<String?>(conversationJson),
      'activeDraftJson': serializer.toJson<String?>(activeDraftJson),
      'recoverableDraftJson': serializer.toJson<String?>(recoverableDraftJson),
      'expiresAt': serializer.toJson<String?>(expiresAt),
    };
  }

  CaptureSession copyWith(
          {String? id,
          String? rawText,
          String? status,
          String? createdAt,
          String? updatedAt,
          Value<String?> conversationJson = const Value.absent(),
          Value<String?> activeDraftJson = const Value.absent(),
          Value<String?> recoverableDraftJson = const Value.absent(),
          Value<String?> expiresAt = const Value.absent()}) =>
      CaptureSession(
        id: id ?? this.id,
        rawText: rawText ?? this.rawText,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        conversationJson: conversationJson.present
            ? conversationJson.value
            : this.conversationJson,
        activeDraftJson: activeDraftJson.present
            ? activeDraftJson.value
            : this.activeDraftJson,
        recoverableDraftJson: recoverableDraftJson.present
            ? recoverableDraftJson.value
            : this.recoverableDraftJson,
        expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
      );
  CaptureSession copyWithCompanion(CaptureSessionsCompanion data) {
    return CaptureSession(
      id: data.id.present ? data.id.value : this.id,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      conversationJson: data.conversationJson.present
          ? data.conversationJson.value
          : this.conversationJson,
      activeDraftJson: data.activeDraftJson.present
          ? data.activeDraftJson.value
          : this.activeDraftJson,
      recoverableDraftJson: data.recoverableDraftJson.present
          ? data.recoverableDraftJson.value
          : this.recoverableDraftJson,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CaptureSession(')
          ..write('id: $id, ')
          ..write('rawText: $rawText, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('conversationJson: $conversationJson, ')
          ..write('activeDraftJson: $activeDraftJson, ')
          ..write('recoverableDraftJson: $recoverableDraftJson, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, rawText, status, createdAt, updatedAt,
      conversationJson, activeDraftJson, recoverableDraftJson, expiresAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CaptureSession &&
          other.id == this.id &&
          other.rawText == this.rawText &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.conversationJson == this.conversationJson &&
          other.activeDraftJson == this.activeDraftJson &&
          other.recoverableDraftJson == this.recoverableDraftJson &&
          other.expiresAt == this.expiresAt);
}

class CaptureSessionsCompanion extends UpdateCompanion<CaptureSession> {
  final Value<String> id;
  final Value<String> rawText;
  final Value<String> status;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<String?> conversationJson;
  final Value<String?> activeDraftJson;
  final Value<String?> recoverableDraftJson;
  final Value<String?> expiresAt;
  final Value<int> rowid;
  const CaptureSessionsCompanion({
    this.id = const Value.absent(),
    this.rawText = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.conversationJson = const Value.absent(),
    this.activeDraftJson = const Value.absent(),
    this.recoverableDraftJson = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CaptureSessionsCompanion.insert({
    required String id,
    required String rawText,
    required String status,
    required String createdAt,
    required String updatedAt,
    this.conversationJson = const Value.absent(),
    this.activeDraftJson = const Value.absent(),
    this.recoverableDraftJson = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        rawText = Value(rawText),
        status = Value(status),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<CaptureSession> custom({
    Expression<String>? id,
    Expression<String>? rawText,
    Expression<String>? status,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<String>? conversationJson,
    Expression<String>? activeDraftJson,
    Expression<String>? recoverableDraftJson,
    Expression<String>? expiresAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rawText != null) 'raw_text': rawText,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (conversationJson != null) 'conversation_json': conversationJson,
      if (activeDraftJson != null) 'active_draft_json': activeDraftJson,
      if (recoverableDraftJson != null)
        'recoverable_draft_json': recoverableDraftJson,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CaptureSessionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? rawText,
      Value<String>? status,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<String?>? conversationJson,
      Value<String?>? activeDraftJson,
      Value<String?>? recoverableDraftJson,
      Value<String?>? expiresAt,
      Value<int>? rowid}) {
    return CaptureSessionsCompanion(
      id: id ?? this.id,
      rawText: rawText ?? this.rawText,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      conversationJson: conversationJson ?? this.conversationJson,
      activeDraftJson: activeDraftJson ?? this.activeDraftJson,
      recoverableDraftJson: recoverableDraftJson ?? this.recoverableDraftJson,
      expiresAt: expiresAt ?? this.expiresAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (conversationJson.present) {
      map['conversation_json'] = Variable<String>(conversationJson.value);
    }
    if (activeDraftJson.present) {
      map['active_draft_json'] = Variable<String>(activeDraftJson.value);
    }
    if (recoverableDraftJson.present) {
      map['recoverable_draft_json'] =
          Variable<String>(recoverableDraftJson.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<String>(expiresAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CaptureSessionsCompanion(')
          ..write('id: $id, ')
          ..write('rawText: $rawText, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('conversationJson: $conversationJson, ')
          ..write('activeDraftJson: $activeDraftJson, ')
          ..write('recoverableDraftJson: $recoverableDraftJson, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntriesTable extends Entries with TableInfo<$EntriesTable, Entry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entryTypeMeta =
      const VerificationMeta('entryType');
  @override
  late final GeneratedColumn<String> entryType = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL CHECK (type IN (\'todo\', \'idea\'))');
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rawTextMeta =
      const VerificationMeta('rawText');
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
      'raw_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _normalizedTextMeta =
      const VerificationMeta('normalizedText');
  @override
  late final GeneratedColumn<String> normalizedText = GeneratedColumn<String>(
      'normalized_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, entryType, title, rawText, normalizedText, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entries';
  @override
  VerificationContext validateIntegrity(Insertable<Entry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(_entryTypeMeta,
          entryType.isAcceptableOrUnknown(data['type']!, _entryTypeMeta));
    } else if (isInserting) {
      context.missing(_entryTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('raw_text')) {
      context.handle(_rawTextMeta,
          rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta));
    } else if (isInserting) {
      context.missing(_rawTextMeta);
    }
    if (data.containsKey('normalized_text')) {
      context.handle(
          _normalizedTextMeta,
          normalizedText.isAcceptableOrUnknown(
              data['normalized_text']!, _normalizedTextMeta));
    } else if (isInserting) {
      context.missing(_normalizedTextMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Entry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Entry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      entryType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      rawText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_text'])!,
      normalizedText: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}normalized_text'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $EntriesTable createAlias(String alias) {
    return $EntriesTable(attachedDatabase, alias);
  }
}

class Entry extends DataClass implements Insertable<Entry> {
  final String id;
  final String entryType;
  final String title;
  final String rawText;
  final String normalizedText;
  final String createdAt;
  final String updatedAt;
  const Entry(
      {required this.id,
      required this.entryType,
      required this.title,
      required this.rawText,
      required this.normalizedText,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(entryType);
    map['title'] = Variable<String>(title);
    map['raw_text'] = Variable<String>(rawText);
    map['normalized_text'] = Variable<String>(normalizedText);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  EntriesCompanion toCompanion(bool nullToAbsent) {
    return EntriesCompanion(
      id: Value(id),
      entryType: Value(entryType),
      title: Value(title),
      rawText: Value(rawText),
      normalizedText: Value(normalizedText),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Entry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Entry(
      id: serializer.fromJson<String>(json['id']),
      entryType: serializer.fromJson<String>(json['entryType']),
      title: serializer.fromJson<String>(json['title']),
      rawText: serializer.fromJson<String>(json['rawText']),
      normalizedText: serializer.fromJson<String>(json['normalizedText']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'entryType': serializer.toJson<String>(entryType),
      'title': serializer.toJson<String>(title),
      'rawText': serializer.toJson<String>(rawText),
      'normalizedText': serializer.toJson<String>(normalizedText),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  Entry copyWith(
          {String? id,
          String? entryType,
          String? title,
          String? rawText,
          String? normalizedText,
          String? createdAt,
          String? updatedAt}) =>
      Entry(
        id: id ?? this.id,
        entryType: entryType ?? this.entryType,
        title: title ?? this.title,
        rawText: rawText ?? this.rawText,
        normalizedText: normalizedText ?? this.normalizedText,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Entry copyWithCompanion(EntriesCompanion data) {
    return Entry(
      id: data.id.present ? data.id.value : this.id,
      entryType: data.entryType.present ? data.entryType.value : this.entryType,
      title: data.title.present ? data.title.value : this.title,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
      normalizedText: data.normalizedText.present
          ? data.normalizedText.value
          : this.normalizedText,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Entry(')
          ..write('id: $id, ')
          ..write('entryType: $entryType, ')
          ..write('title: $title, ')
          ..write('rawText: $rawText, ')
          ..write('normalizedText: $normalizedText, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, entryType, title, rawText, normalizedText, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Entry &&
          other.id == this.id &&
          other.entryType == this.entryType &&
          other.title == this.title &&
          other.rawText == this.rawText &&
          other.normalizedText == this.normalizedText &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class EntriesCompanion extends UpdateCompanion<Entry> {
  final Value<String> id;
  final Value<String> entryType;
  final Value<String> title;
  final Value<String> rawText;
  final Value<String> normalizedText;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const EntriesCompanion({
    this.id = const Value.absent(),
    this.entryType = const Value.absent(),
    this.title = const Value.absent(),
    this.rawText = const Value.absent(),
    this.normalizedText = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntriesCompanion.insert({
    required String id,
    required String entryType,
    required String title,
    required String rawText,
    required String normalizedText,
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        entryType = Value(entryType),
        title = Value(title),
        rawText = Value(rawText),
        normalizedText = Value(normalizedText),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Entry> custom({
    Expression<String>? id,
    Expression<String>? entryType,
    Expression<String>? title,
    Expression<String>? rawText,
    Expression<String>? normalizedText,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entryType != null) 'type': entryType,
      if (title != null) 'title': title,
      if (rawText != null) 'raw_text': rawText,
      if (normalizedText != null) 'normalized_text': normalizedText,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? entryType,
      Value<String>? title,
      Value<String>? rawText,
      Value<String>? normalizedText,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? rowid}) {
    return EntriesCompanion(
      id: id ?? this.id,
      entryType: entryType ?? this.entryType,
      title: title ?? this.title,
      rawText: rawText ?? this.rawText,
      normalizedText: normalizedText ?? this.normalizedText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (entryType.present) {
      map['type'] = Variable<String>(entryType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (normalizedText.present) {
      map['normalized_text'] = Variable<String>(normalizedText.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntriesCompanion(')
          ..write('id: $id, ')
          ..write('entryType: $entryType, ')
          ..write('title: $title, ')
          ..write('rawText: $rawText, ')
          ..write('normalizedText: $normalizedText, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TodosTable extends Todos with TableInfo<$TodosTable, Todo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entryIdMeta =
      const VerificationMeta('entryId');
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
      'entry_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startAtMeta =
      const VerificationMeta('startAt');
  @override
  late final GeneratedColumn<String> startAt = GeneratedColumn<String>(
      'start_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _endAtMeta = const VerificationMeta('endAt');
  @override
  late final GeneratedColumn<String> endAt = GeneratedColumn<String>(
      'end_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  @override
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
      'topic', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _reminderAtMeta =
      const VerificationMeta('reminderAt');
  @override
  late final GeneratedColumn<String> reminderAt = GeneratedColumn<String>(
      'reminder_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('draft'));
  @override
  List<GeneratedColumn> get $columns =>
      [entryId, startAt, endAt, location, topic, reminderAt, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'todos';
  @override
  VerificationContext validateIntegrity(Insertable<Todo> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entry_id')) {
      context.handle(_entryIdMeta,
          entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta));
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('start_at')) {
      context.handle(_startAtMeta,
          startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta));
    }
    if (data.containsKey('end_at')) {
      context.handle(
          _endAtMeta, endAt.isAcceptableOrUnknown(data['end_at']!, _endAtMeta));
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('topic')) {
      context.handle(
          _topicMeta, topic.isAcceptableOrUnknown(data['topic']!, _topicMeta));
    }
    if (data.containsKey('reminder_at')) {
      context.handle(
          _reminderAtMeta,
          reminderAt.isAcceptableOrUnknown(
              data['reminder_at']!, _reminderAtMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entryId};
  @override
  Todo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Todo(
      entryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entry_id'])!,
      startAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}start_at']),
      endAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}end_at']),
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location']),
      topic: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}topic']),
      reminderAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reminder_at']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $TodosTable createAlias(String alias) {
    return $TodosTable(attachedDatabase, alias);
  }
}

class Todo extends DataClass implements Insertable<Todo> {
  final String entryId;
  final String? startAt;
  final String? endAt;
  final String? location;
  final String? topic;
  final String? reminderAt;
  final String status;
  const Todo(
      {required this.entryId,
      this.startAt,
      this.endAt,
      this.location,
      this.topic,
      this.reminderAt,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entry_id'] = Variable<String>(entryId);
    if (!nullToAbsent || startAt != null) {
      map['start_at'] = Variable<String>(startAt);
    }
    if (!nullToAbsent || endAt != null) {
      map['end_at'] = Variable<String>(endAt);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || topic != null) {
      map['topic'] = Variable<String>(topic);
    }
    if (!nullToAbsent || reminderAt != null) {
      map['reminder_at'] = Variable<String>(reminderAt);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  TodosCompanion toCompanion(bool nullToAbsent) {
    return TodosCompanion(
      entryId: Value(entryId),
      startAt: startAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startAt),
      endAt:
          endAt == null && nullToAbsent ? const Value.absent() : Value(endAt),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      topic:
          topic == null && nullToAbsent ? const Value.absent() : Value(topic),
      reminderAt: reminderAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderAt),
      status: Value(status),
    );
  }

  factory Todo.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Todo(
      entryId: serializer.fromJson<String>(json['entryId']),
      startAt: serializer.fromJson<String?>(json['startAt']),
      endAt: serializer.fromJson<String?>(json['endAt']),
      location: serializer.fromJson<String?>(json['location']),
      topic: serializer.fromJson<String?>(json['topic']),
      reminderAt: serializer.fromJson<String?>(json['reminderAt']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entryId': serializer.toJson<String>(entryId),
      'startAt': serializer.toJson<String?>(startAt),
      'endAt': serializer.toJson<String?>(endAt),
      'location': serializer.toJson<String?>(location),
      'topic': serializer.toJson<String?>(topic),
      'reminderAt': serializer.toJson<String?>(reminderAt),
      'status': serializer.toJson<String>(status),
    };
  }

  Todo copyWith(
          {String? entryId,
          Value<String?> startAt = const Value.absent(),
          Value<String?> endAt = const Value.absent(),
          Value<String?> location = const Value.absent(),
          Value<String?> topic = const Value.absent(),
          Value<String?> reminderAt = const Value.absent(),
          String? status}) =>
      Todo(
        entryId: entryId ?? this.entryId,
        startAt: startAt.present ? startAt.value : this.startAt,
        endAt: endAt.present ? endAt.value : this.endAt,
        location: location.present ? location.value : this.location,
        topic: topic.present ? topic.value : this.topic,
        reminderAt: reminderAt.present ? reminderAt.value : this.reminderAt,
        status: status ?? this.status,
      );
  Todo copyWithCompanion(TodosCompanion data) {
    return Todo(
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
      location: data.location.present ? data.location.value : this.location,
      topic: data.topic.present ? data.topic.value : this.topic,
      reminderAt:
          data.reminderAt.present ? data.reminderAt.value : this.reminderAt,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Todo(')
          ..write('entryId: $entryId, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('location: $location, ')
          ..write('topic: $topic, ')
          ..write('reminderAt: $reminderAt, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(entryId, startAt, endAt, location, topic, reminderAt, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Todo &&
          other.entryId == this.entryId &&
          other.startAt == this.startAt &&
          other.endAt == this.endAt &&
          other.location == this.location &&
          other.topic == this.topic &&
          other.reminderAt == this.reminderAt &&
          other.status == this.status);
}

class TodosCompanion extends UpdateCompanion<Todo> {
  final Value<String> entryId;
  final Value<String?> startAt;
  final Value<String?> endAt;
  final Value<String?> location;
  final Value<String?> topic;
  final Value<String?> reminderAt;
  final Value<String> status;
  final Value<int> rowid;
  const TodosCompanion({
    this.entryId = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.location = const Value.absent(),
    this.topic = const Value.absent(),
    this.reminderAt = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TodosCompanion.insert({
    required String entryId,
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.location = const Value.absent(),
    this.topic = const Value.absent(),
    this.reminderAt = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : entryId = Value(entryId);
  static Insertable<Todo> custom({
    Expression<String>? entryId,
    Expression<String>? startAt,
    Expression<String>? endAt,
    Expression<String>? location,
    Expression<String>? topic,
    Expression<String>? reminderAt,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entryId != null) 'entry_id': entryId,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (location != null) 'location': location,
      if (topic != null) 'topic': topic,
      if (reminderAt != null) 'reminder_at': reminderAt,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TodosCompanion copyWith(
      {Value<String>? entryId,
      Value<String?>? startAt,
      Value<String?>? endAt,
      Value<String?>? location,
      Value<String?>? topic,
      Value<String?>? reminderAt,
      Value<String>? status,
      Value<int>? rowid}) {
    return TodosCompanion(
      entryId: entryId ?? this.entryId,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      location: location ?? this.location,
      topic: topic ?? this.topic,
      reminderAt: reminderAt ?? this.reminderAt,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<String>(startAt.value);
    }
    if (endAt.present) {
      map['end_at'] = Variable<String>(endAt.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (reminderAt.present) {
      map['reminder_at'] = Variable<String>(reminderAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodosCompanion(')
          ..write('entryId: $entryId, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('location: $location, ')
          ..write('topic: $topic, ')
          ..write('reminderAt: $reminderAt, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IdeasTable extends Ideas with TableInfo<$IdeasTable, Idea> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IdeasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entryIdMeta =
      const VerificationMeta('entryId');
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
      'entry_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _summaryMeta =
      const VerificationMeta('summary');
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
      'summary', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceHintMeta =
      const VerificationMeta('sourceHint');
  @override
  late final GeneratedColumn<String> sourceHint = GeneratedColumn<String>(
      'source_hint', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _favoriteMeta =
      const VerificationMeta('favorite');
  @override
  late final GeneratedColumn<bool> favorite = GeneratedColumn<bool>(
      'favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [entryId, summary, sourceHint, favorite];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ideas';
  @override
  VerificationContext validateIntegrity(Insertable<Idea> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entry_id')) {
      context.handle(_entryIdMeta,
          entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta));
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(_summaryMeta,
          summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta));
    } else if (isInserting) {
      context.missing(_summaryMeta);
    }
    if (data.containsKey('source_hint')) {
      context.handle(
          _sourceHintMeta,
          sourceHint.isAcceptableOrUnknown(
              data['source_hint']!, _sourceHintMeta));
    }
    if (data.containsKey('favorite')) {
      context.handle(_favoriteMeta,
          favorite.isAcceptableOrUnknown(data['favorite']!, _favoriteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entryId};
  @override
  Idea map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Idea(
      entryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entry_id'])!,
      summary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}summary'])!,
      sourceHint: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_hint']),
      favorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}favorite'])!,
    );
  }

  @override
  $IdeasTable createAlias(String alias) {
    return $IdeasTable(attachedDatabase, alias);
  }
}

class Idea extends DataClass implements Insertable<Idea> {
  final String entryId;
  final String summary;
  final String? sourceHint;
  final bool favorite;
  const Idea(
      {required this.entryId,
      required this.summary,
      this.sourceHint,
      required this.favorite});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entry_id'] = Variable<String>(entryId);
    map['summary'] = Variable<String>(summary);
    if (!nullToAbsent || sourceHint != null) {
      map['source_hint'] = Variable<String>(sourceHint);
    }
    map['favorite'] = Variable<bool>(favorite);
    return map;
  }

  IdeasCompanion toCompanion(bool nullToAbsent) {
    return IdeasCompanion(
      entryId: Value(entryId),
      summary: Value(summary),
      sourceHint: sourceHint == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceHint),
      favorite: Value(favorite),
    );
  }

  factory Idea.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Idea(
      entryId: serializer.fromJson<String>(json['entryId']),
      summary: serializer.fromJson<String>(json['summary']),
      sourceHint: serializer.fromJson<String?>(json['sourceHint']),
      favorite: serializer.fromJson<bool>(json['favorite']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entryId': serializer.toJson<String>(entryId),
      'summary': serializer.toJson<String>(summary),
      'sourceHint': serializer.toJson<String?>(sourceHint),
      'favorite': serializer.toJson<bool>(favorite),
    };
  }

  Idea copyWith(
          {String? entryId,
          String? summary,
          Value<String?> sourceHint = const Value.absent(),
          bool? favorite}) =>
      Idea(
        entryId: entryId ?? this.entryId,
        summary: summary ?? this.summary,
        sourceHint: sourceHint.present ? sourceHint.value : this.sourceHint,
        favorite: favorite ?? this.favorite,
      );
  Idea copyWithCompanion(IdeasCompanion data) {
    return Idea(
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      summary: data.summary.present ? data.summary.value : this.summary,
      sourceHint:
          data.sourceHint.present ? data.sourceHint.value : this.sourceHint,
      favorite: data.favorite.present ? data.favorite.value : this.favorite,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Idea(')
          ..write('entryId: $entryId, ')
          ..write('summary: $summary, ')
          ..write('sourceHint: $sourceHint, ')
          ..write('favorite: $favorite')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entryId, summary, sourceHint, favorite);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Idea &&
          other.entryId == this.entryId &&
          other.summary == this.summary &&
          other.sourceHint == this.sourceHint &&
          other.favorite == this.favorite);
}

class IdeasCompanion extends UpdateCompanion<Idea> {
  final Value<String> entryId;
  final Value<String> summary;
  final Value<String?> sourceHint;
  final Value<bool> favorite;
  final Value<int> rowid;
  const IdeasCompanion({
    this.entryId = const Value.absent(),
    this.summary = const Value.absent(),
    this.sourceHint = const Value.absent(),
    this.favorite = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IdeasCompanion.insert({
    required String entryId,
    required String summary,
    this.sourceHint = const Value.absent(),
    this.favorite = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : entryId = Value(entryId),
        summary = Value(summary);
  static Insertable<Idea> custom({
    Expression<String>? entryId,
    Expression<String>? summary,
    Expression<String>? sourceHint,
    Expression<bool>? favorite,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entryId != null) 'entry_id': entryId,
      if (summary != null) 'summary': summary,
      if (sourceHint != null) 'source_hint': sourceHint,
      if (favorite != null) 'favorite': favorite,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IdeasCompanion copyWith(
      {Value<String>? entryId,
      Value<String>? summary,
      Value<String?>? sourceHint,
      Value<bool>? favorite,
      Value<int>? rowid}) {
    return IdeasCompanion(
      entryId: entryId ?? this.entryId,
      summary: summary ?? this.summary,
      sourceHint: sourceHint ?? this.sourceHint,
      favorite: favorite ?? this.favorite,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (sourceHint.present) {
      map['source_hint'] = Variable<String>(sourceHint.value);
    }
    if (favorite.present) {
      map['favorite'] = Variable<bool>(favorite.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IdeasCompanion(')
          ..write('entryId: $entryId, ')
          ..write('summary: $summary, ')
          ..write('sourceHint: $sourceHint, ')
          ..write('favorite: $favorite, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(Insertable<Tag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final String id;
  final String name;
  const Tag({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
    );
  }

  factory Tag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Tag copyWith({String? id, String? name}) => Tag(
        id: id ?? this.id,
        name: name ?? this.name,
      );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag && other.id == this.id && other.name == this.name);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith(
      {Value<String>? id, Value<String>? name, Value<int>? rowid}) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntryTagsTable extends EntryTags
    with TableInfo<$EntryTagsTable, EntryTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntryTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entryIdMeta =
      const VerificationMeta('entryId');
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
      'entry_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
      'tag_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [entryId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entry_tags';
  @override
  VerificationContext validateIntegrity(Insertable<EntryTag> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entry_id')) {
      context.handle(_entryIdMeta,
          entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta));
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
          _tagIdMeta, tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta));
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entryId, tagId};
  @override
  EntryTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntryTag(
      entryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entry_id'])!,
      tagId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tag_id'])!,
    );
  }

  @override
  $EntryTagsTable createAlias(String alias) {
    return $EntryTagsTable(attachedDatabase, alias);
  }
}

class EntryTag extends DataClass implements Insertable<EntryTag> {
  final String entryId;
  final String tagId;
  const EntryTag({required this.entryId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entry_id'] = Variable<String>(entryId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  EntryTagsCompanion toCompanion(bool nullToAbsent) {
    return EntryTagsCompanion(
      entryId: Value(entryId),
      tagId: Value(tagId),
    );
  }

  factory EntryTag.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntryTag(
      entryId: serializer.fromJson<String>(json['entryId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entryId': serializer.toJson<String>(entryId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  EntryTag copyWith({String? entryId, String? tagId}) => EntryTag(
        entryId: entryId ?? this.entryId,
        tagId: tagId ?? this.tagId,
      );
  EntryTag copyWithCompanion(EntryTagsCompanion data) {
    return EntryTag(
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntryTag(')
          ..write('entryId: $entryId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entryId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntryTag &&
          other.entryId == this.entryId &&
          other.tagId == this.tagId);
}

class EntryTagsCompanion extends UpdateCompanion<EntryTag> {
  final Value<String> entryId;
  final Value<String> tagId;
  final Value<int> rowid;
  const EntryTagsCompanion({
    this.entryId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntryTagsCompanion.insert({
    required String entryId,
    required String tagId,
    this.rowid = const Value.absent(),
  })  : entryId = Value(entryId),
        tagId = Value(tagId);
  static Insertable<EntryTag> custom({
    Expression<String>? entryId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entryId != null) 'entry_id': entryId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntryTagsCompanion copyWith(
      {Value<String>? entryId, Value<String>? tagId, Value<int>? rowid}) {
    return EntryTagsCompanion(
      entryId: entryId ?? this.entryId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntryTagsCompanion(')
          ..write('entryId: $entryId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LedgerTransactionsTable extends LedgerTransactions
    with TableInfo<$LedgerTransactionsTable, LedgerTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LedgerTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _directionMeta =
      const VerificationMeta('direction');
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
      'direction', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints:
          'NOT NULL CHECK (direction IN (\'expense\', \'income\'))');
  static const VerificationMeta _amountCentsMeta =
      const VerificationMeta('amountCents');
  @override
  late final GeneratedColumn<int> amountCents = GeneratedColumn<int>(
      'amount_cents', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL CHECK (amount_cents > 0)');
  static const VerificationMeta _categoryCodeMeta =
      const VerificationMeta('categoryCode');
  @override
  late final GeneratedColumn<String> categoryCode = GeneratedColumn<String>(
      'category_code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _occurredAtMeta =
      const VerificationMeta('occurredAt');
  @override
  late final GeneratedColumn<String> occurredAt = GeneratedColumn<String>(
      'occurred_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _rawTextMeta =
      const VerificationMeta('rawText');
  @override
  late final GeneratedColumn<String> rawText = GeneratedColumn<String>(
      'raw_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        direction,
        amountCents,
        categoryCode,
        note,
        occurredAt,
        source,
        rawText,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ledger_transactions';
  @override
  VerificationContext validateIntegrity(Insertable<LedgerTransaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('direction')) {
      context.handle(_directionMeta,
          direction.isAcceptableOrUnknown(data['direction']!, _directionMeta));
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('amount_cents')) {
      context.handle(
          _amountCentsMeta,
          amountCents.isAcceptableOrUnknown(
              data['amount_cents']!, _amountCentsMeta));
    } else if (isInserting) {
      context.missing(_amountCentsMeta);
    }
    if (data.containsKey('category_code')) {
      context.handle(
          _categoryCodeMeta,
          categoryCode.isAcceptableOrUnknown(
              data['category_code']!, _categoryCodeMeta));
    } else if (isInserting) {
      context.missing(_categoryCodeMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
          _occurredAtMeta,
          occurredAt.isAcceptableOrUnknown(
              data['occurred_at']!, _occurredAtMeta));
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('raw_text')) {
      context.handle(_rawTextMeta,
          rawText.isAcceptableOrUnknown(data['raw_text']!, _rawTextMeta));
    } else if (isInserting) {
      context.missing(_rawTextMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LedgerTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LedgerTransaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      direction: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}direction'])!,
      amountCents: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}amount_cents'])!,
      categoryCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_code'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note'])!,
      occurredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}occurred_at'])!,
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      rawText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_text'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $LedgerTransactionsTable createAlias(String alias) {
    return $LedgerTransactionsTable(attachedDatabase, alias);
  }
}

class LedgerTransaction extends DataClass
    implements Insertable<LedgerTransaction> {
  final String id;
  final String direction;
  final int amountCents;
  final String categoryCode;
  final String note;
  final String occurredAt;
  final String source;
  final String rawText;
  final String createdAt;
  final String updatedAt;
  const LedgerTransaction(
      {required this.id,
      required this.direction,
      required this.amountCents,
      required this.categoryCode,
      required this.note,
      required this.occurredAt,
      required this.source,
      required this.rawText,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['direction'] = Variable<String>(direction);
    map['amount_cents'] = Variable<int>(amountCents);
    map['category_code'] = Variable<String>(categoryCode);
    map['note'] = Variable<String>(note);
    map['occurred_at'] = Variable<String>(occurredAt);
    map['source'] = Variable<String>(source);
    map['raw_text'] = Variable<String>(rawText);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  LedgerTransactionsCompanion toCompanion(bool nullToAbsent) {
    return LedgerTransactionsCompanion(
      id: Value(id),
      direction: Value(direction),
      amountCents: Value(amountCents),
      categoryCode: Value(categoryCode),
      note: Value(note),
      occurredAt: Value(occurredAt),
      source: Value(source),
      rawText: Value(rawText),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LedgerTransaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LedgerTransaction(
      id: serializer.fromJson<String>(json['id']),
      direction: serializer.fromJson<String>(json['direction']),
      amountCents: serializer.fromJson<int>(json['amountCents']),
      categoryCode: serializer.fromJson<String>(json['categoryCode']),
      note: serializer.fromJson<String>(json['note']),
      occurredAt: serializer.fromJson<String>(json['occurredAt']),
      source: serializer.fromJson<String>(json['source']),
      rawText: serializer.fromJson<String>(json['rawText']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'direction': serializer.toJson<String>(direction),
      'amountCents': serializer.toJson<int>(amountCents),
      'categoryCode': serializer.toJson<String>(categoryCode),
      'note': serializer.toJson<String>(note),
      'occurredAt': serializer.toJson<String>(occurredAt),
      'source': serializer.toJson<String>(source),
      'rawText': serializer.toJson<String>(rawText),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  LedgerTransaction copyWith(
          {String? id,
          String? direction,
          int? amountCents,
          String? categoryCode,
          String? note,
          String? occurredAt,
          String? source,
          String? rawText,
          String? createdAt,
          String? updatedAt}) =>
      LedgerTransaction(
        id: id ?? this.id,
        direction: direction ?? this.direction,
        amountCents: amountCents ?? this.amountCents,
        categoryCode: categoryCode ?? this.categoryCode,
        note: note ?? this.note,
        occurredAt: occurredAt ?? this.occurredAt,
        source: source ?? this.source,
        rawText: rawText ?? this.rawText,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  LedgerTransaction copyWithCompanion(LedgerTransactionsCompanion data) {
    return LedgerTransaction(
      id: data.id.present ? data.id.value : this.id,
      direction: data.direction.present ? data.direction.value : this.direction,
      amountCents:
          data.amountCents.present ? data.amountCents.value : this.amountCents,
      categoryCode: data.categoryCode.present
          ? data.categoryCode.value
          : this.categoryCode,
      note: data.note.present ? data.note.value : this.note,
      occurredAt:
          data.occurredAt.present ? data.occurredAt.value : this.occurredAt,
      source: data.source.present ? data.source.value : this.source,
      rawText: data.rawText.present ? data.rawText.value : this.rawText,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LedgerTransaction(')
          ..write('id: $id, ')
          ..write('direction: $direction, ')
          ..write('amountCents: $amountCents, ')
          ..write('categoryCode: $categoryCode, ')
          ..write('note: $note, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('source: $source, ')
          ..write('rawText: $rawText, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, direction, amountCents, categoryCode,
      note, occurredAt, source, rawText, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LedgerTransaction &&
          other.id == this.id &&
          other.direction == this.direction &&
          other.amountCents == this.amountCents &&
          other.categoryCode == this.categoryCode &&
          other.note == this.note &&
          other.occurredAt == this.occurredAt &&
          other.source == this.source &&
          other.rawText == this.rawText &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LedgerTransactionsCompanion extends UpdateCompanion<LedgerTransaction> {
  final Value<String> id;
  final Value<String> direction;
  final Value<int> amountCents;
  final Value<String> categoryCode;
  final Value<String> note;
  final Value<String> occurredAt;
  final Value<String> source;
  final Value<String> rawText;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const LedgerTransactionsCompanion({
    this.id = const Value.absent(),
    this.direction = const Value.absent(),
    this.amountCents = const Value.absent(),
    this.categoryCode = const Value.absent(),
    this.note = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.source = const Value.absent(),
    this.rawText = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LedgerTransactionsCompanion.insert({
    required String id,
    required String direction,
    required int amountCents,
    required String categoryCode,
    this.note = const Value.absent(),
    required String occurredAt,
    required String source,
    required String rawText,
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        direction = Value(direction),
        amountCents = Value(amountCents),
        categoryCode = Value(categoryCode),
        occurredAt = Value(occurredAt),
        source = Value(source),
        rawText = Value(rawText),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<LedgerTransaction> custom({
    Expression<String>? id,
    Expression<String>? direction,
    Expression<int>? amountCents,
    Expression<String>? categoryCode,
    Expression<String>? note,
    Expression<String>? occurredAt,
    Expression<String>? source,
    Expression<String>? rawText,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (direction != null) 'direction': direction,
      if (amountCents != null) 'amount_cents': amountCents,
      if (categoryCode != null) 'category_code': categoryCode,
      if (note != null) 'note': note,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (source != null) 'source': source,
      if (rawText != null) 'raw_text': rawText,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LedgerTransactionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? direction,
      Value<int>? amountCents,
      Value<String>? categoryCode,
      Value<String>? note,
      Value<String>? occurredAt,
      Value<String>? source,
      Value<String>? rawText,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? rowid}) {
    return LedgerTransactionsCompanion(
      id: id ?? this.id,
      direction: direction ?? this.direction,
      amountCents: amountCents ?? this.amountCents,
      categoryCode: categoryCode ?? this.categoryCode,
      note: note ?? this.note,
      occurredAt: occurredAt ?? this.occurredAt,
      source: source ?? this.source,
      rawText: rawText ?? this.rawText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (amountCents.present) {
      map['amount_cents'] = Variable<int>(amountCents.value);
    }
    if (categoryCode.present) {
      map['category_code'] = Variable<String>(categoryCode.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<String>(occurredAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rawText.present) {
      map['raw_text'] = Variable<String>(rawText.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LedgerTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('direction: $direction, ')
          ..write('amountCents: $amountCents, ')
          ..write('categoryCode: $categoryCode, ')
          ..write('note: $note, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('source: $source, ')
          ..write('rawText: $rawText, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AgentThreadsTable extends AgentThreads
    with TableInfo<$AgentThreadsTable, AgentThread> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AgentThreadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _previousResponseIdMeta =
      const VerificationMeta('previousResponseId');
  @override
  late final GeneratedColumn<String> previousResponseId =
      GeneratedColumn<String>('previous_response_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _rollingSummaryMeta =
      const VerificationMeta('rollingSummary');
  @override
  late final GeneratedColumn<String> rollingSummary = GeneratedColumn<String>(
      'rolling_summary', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _entityRefsJsonMeta =
      const VerificationMeta('entityRefsJson');
  @override
  late final GeneratedColumn<String> entityRefsJson = GeneratedColumn<String>(
      'entity_refs_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        status,
        previousResponseId,
        rollingSummary,
        entityRefsJson,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'agent_threads';
  @override
  VerificationContext validateIntegrity(Insertable<AgentThread> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('previous_response_id')) {
      context.handle(
          _previousResponseIdMeta,
          previousResponseId.isAcceptableOrUnknown(
              data['previous_response_id']!, _previousResponseIdMeta));
    }
    if (data.containsKey('rolling_summary')) {
      context.handle(
          _rollingSummaryMeta,
          rollingSummary.isAcceptableOrUnknown(
              data['rolling_summary']!, _rollingSummaryMeta));
    }
    if (data.containsKey('entity_refs_json')) {
      context.handle(
          _entityRefsJsonMeta,
          entityRefsJson.isAcceptableOrUnknown(
              data['entity_refs_json']!, _entityRefsJsonMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AgentThread map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AgentThread(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      previousResponseId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}previous_response_id']),
      rollingSummary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}rolling_summary']),
      entityRefsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}entity_refs_json']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AgentThreadsTable createAlias(String alias) {
    return $AgentThreadsTable(attachedDatabase, alias);
  }
}

class AgentThread extends DataClass implements Insertable<AgentThread> {
  final String id;
  final String status;
  final String? previousResponseId;
  final String? rollingSummary;
  final String? entityRefsJson;
  final String createdAt;
  final String updatedAt;
  const AgentThread(
      {required this.id,
      required this.status,
      this.previousResponseId,
      this.rollingSummary,
      this.entityRefsJson,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || previousResponseId != null) {
      map['previous_response_id'] = Variable<String>(previousResponseId);
    }
    if (!nullToAbsent || rollingSummary != null) {
      map['rolling_summary'] = Variable<String>(rollingSummary);
    }
    if (!nullToAbsent || entityRefsJson != null) {
      map['entity_refs_json'] = Variable<String>(entityRefsJson);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  AgentThreadsCompanion toCompanion(bool nullToAbsent) {
    return AgentThreadsCompanion(
      id: Value(id),
      status: Value(status),
      previousResponseId: previousResponseId == null && nullToAbsent
          ? const Value.absent()
          : Value(previousResponseId),
      rollingSummary: rollingSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(rollingSummary),
      entityRefsJson: entityRefsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(entityRefsJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AgentThread.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AgentThread(
      id: serializer.fromJson<String>(json['id']),
      status: serializer.fromJson<String>(json['status']),
      previousResponseId:
          serializer.fromJson<String?>(json['previousResponseId']),
      rollingSummary: serializer.fromJson<String?>(json['rollingSummary']),
      entityRefsJson: serializer.fromJson<String?>(json['entityRefsJson']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'status': serializer.toJson<String>(status),
      'previousResponseId': serializer.toJson<String?>(previousResponseId),
      'rollingSummary': serializer.toJson<String?>(rollingSummary),
      'entityRefsJson': serializer.toJson<String?>(entityRefsJson),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  AgentThread copyWith(
          {String? id,
          String? status,
          Value<String?> previousResponseId = const Value.absent(),
          Value<String?> rollingSummary = const Value.absent(),
          Value<String?> entityRefsJson = const Value.absent(),
          String? createdAt,
          String? updatedAt}) =>
      AgentThread(
        id: id ?? this.id,
        status: status ?? this.status,
        previousResponseId: previousResponseId.present
            ? previousResponseId.value
            : this.previousResponseId,
        rollingSummary:
            rollingSummary.present ? rollingSummary.value : this.rollingSummary,
        entityRefsJson:
            entityRefsJson.present ? entityRefsJson.value : this.entityRefsJson,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AgentThread copyWithCompanion(AgentThreadsCompanion data) {
    return AgentThread(
      id: data.id.present ? data.id.value : this.id,
      status: data.status.present ? data.status.value : this.status,
      previousResponseId: data.previousResponseId.present
          ? data.previousResponseId.value
          : this.previousResponseId,
      rollingSummary: data.rollingSummary.present
          ? data.rollingSummary.value
          : this.rollingSummary,
      entityRefsJson: data.entityRefsJson.present
          ? data.entityRefsJson.value
          : this.entityRefsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AgentThread(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('previousResponseId: $previousResponseId, ')
          ..write('rollingSummary: $rollingSummary, ')
          ..write('entityRefsJson: $entityRefsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, status, previousResponseId,
      rollingSummary, entityRefsJson, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AgentThread &&
          other.id == this.id &&
          other.status == this.status &&
          other.previousResponseId == this.previousResponseId &&
          other.rollingSummary == this.rollingSummary &&
          other.entityRefsJson == this.entityRefsJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AgentThreadsCompanion extends UpdateCompanion<AgentThread> {
  final Value<String> id;
  final Value<String> status;
  final Value<String?> previousResponseId;
  final Value<String?> rollingSummary;
  final Value<String?> entityRefsJson;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const AgentThreadsCompanion({
    this.id = const Value.absent(),
    this.status = const Value.absent(),
    this.previousResponseId = const Value.absent(),
    this.rollingSummary = const Value.absent(),
    this.entityRefsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AgentThreadsCompanion.insert({
    required String id,
    required String status,
    this.previousResponseId = const Value.absent(),
    this.rollingSummary = const Value.absent(),
    this.entityRefsJson = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        status = Value(status),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<AgentThread> custom({
    Expression<String>? id,
    Expression<String>? status,
    Expression<String>? previousResponseId,
    Expression<String>? rollingSummary,
    Expression<String>? entityRefsJson,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (status != null) 'status': status,
      if (previousResponseId != null)
        'previous_response_id': previousResponseId,
      if (rollingSummary != null) 'rolling_summary': rollingSummary,
      if (entityRefsJson != null) 'entity_refs_json': entityRefsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AgentThreadsCompanion copyWith(
      {Value<String>? id,
      Value<String>? status,
      Value<String?>? previousResponseId,
      Value<String?>? rollingSummary,
      Value<String?>? entityRefsJson,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? rowid}) {
    return AgentThreadsCompanion(
      id: id ?? this.id,
      status: status ?? this.status,
      previousResponseId: previousResponseId ?? this.previousResponseId,
      rollingSummary: rollingSummary ?? this.rollingSummary,
      entityRefsJson: entityRefsJson ?? this.entityRefsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (previousResponseId.present) {
      map['previous_response_id'] = Variable<String>(previousResponseId.value);
    }
    if (rollingSummary.present) {
      map['rolling_summary'] = Variable<String>(rollingSummary.value);
    }
    if (entityRefsJson.present) {
      map['entity_refs_json'] = Variable<String>(entityRefsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AgentThreadsCompanion(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('previousResponseId: $previousResponseId, ')
          ..write('rollingSummary: $rollingSummary, ')
          ..write('entityRefsJson: $entityRefsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AgentMessagesTable extends AgentMessages
    with TableInfo<$AgentMessagesTable, AgentMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AgentMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _threadIdMeta =
      const VerificationMeta('threadId');
  @override
  late final GeneratedColumn<String> threadId = GeneratedColumn<String>(
      'thread_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, threadId, role, content, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'agent_messages';
  @override
  VerificationContext validateIntegrity(Insertable<AgentMessage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('thread_id')) {
      context.handle(_threadIdMeta,
          threadId.isAcceptableOrUnknown(data['thread_id']!, _threadIdMeta));
    } else if (isInserting) {
      context.missing(_threadIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AgentMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AgentMessage(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      threadId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thread_id'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AgentMessagesTable createAlias(String alias) {
    return $AgentMessagesTable(attachedDatabase, alias);
  }
}

class AgentMessage extends DataClass implements Insertable<AgentMessage> {
  final String id;
  final String threadId;
  final String role;
  final String content;
  final String createdAt;
  const AgentMessage(
      {required this.id,
      required this.threadId,
      required this.role,
      required this.content,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['thread_id'] = Variable<String>(threadId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  AgentMessagesCompanion toCompanion(bool nullToAbsent) {
    return AgentMessagesCompanion(
      id: Value(id),
      threadId: Value(threadId),
      role: Value(role),
      content: Value(content),
      createdAt: Value(createdAt),
    );
  }

  factory AgentMessage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AgentMessage(
      id: serializer.fromJson<String>(json['id']),
      threadId: serializer.fromJson<String>(json['threadId']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'threadId': serializer.toJson<String>(threadId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  AgentMessage copyWith(
          {String? id,
          String? threadId,
          String? role,
          String? content,
          String? createdAt}) =>
      AgentMessage(
        id: id ?? this.id,
        threadId: threadId ?? this.threadId,
        role: role ?? this.role,
        content: content ?? this.content,
        createdAt: createdAt ?? this.createdAt,
      );
  AgentMessage copyWithCompanion(AgentMessagesCompanion data) {
    return AgentMessage(
      id: data.id.present ? data.id.value : this.id,
      threadId: data.threadId.present ? data.threadId.value : this.threadId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AgentMessage(')
          ..write('id: $id, ')
          ..write('threadId: $threadId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, threadId, role, content, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AgentMessage &&
          other.id == this.id &&
          other.threadId == this.threadId &&
          other.role == this.role &&
          other.content == this.content &&
          other.createdAt == this.createdAt);
}

class AgentMessagesCompanion extends UpdateCompanion<AgentMessage> {
  final Value<String> id;
  final Value<String> threadId;
  final Value<String> role;
  final Value<String> content;
  final Value<String> createdAt;
  final Value<int> rowid;
  const AgentMessagesCompanion({
    this.id = const Value.absent(),
    this.threadId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AgentMessagesCompanion.insert({
    required String id,
    required String threadId,
    required String role,
    required String content,
    required String createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        threadId = Value(threadId),
        role = Value(role),
        content = Value(content),
        createdAt = Value(createdAt);
  static Insertable<AgentMessage> custom({
    Expression<String>? id,
    Expression<String>? threadId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (threadId != null) 'thread_id': threadId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AgentMessagesCompanion copyWith(
      {Value<String>? id,
      Value<String>? threadId,
      Value<String>? role,
      Value<String>? content,
      Value<String>? createdAt,
      Value<int>? rowid}) {
    return AgentMessagesCompanion(
      id: id ?? this.id,
      threadId: threadId ?? this.threadId,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (threadId.present) {
      map['thread_id'] = Variable<String>(threadId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AgentMessagesCompanion(')
          ..write('id: $id, ')
          ..write('threadId: $threadId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AgentRunsTable extends AgentRuns
    with TableInfo<$AgentRunsTable, AgentRun> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AgentRunsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _threadIdMeta =
      const VerificationMeta('threadId');
  @override
  late final GeneratedColumn<String> threadId = GeneratedColumn<String>(
      'thread_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _modelRoundsMeta =
      const VerificationMeta('modelRounds');
  @override
  late final GeneratedColumn<int> modelRounds = GeneratedColumn<int>(
      'model_rounds', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _toolCallsMeta =
      const VerificationMeta('toolCalls');
  @override
  late final GeneratedColumn<int> toolCalls = GeneratedColumn<int>(
      'tool_calls', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
      'error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        threadId,
        status,
        modelRounds,
        toolCalls,
        error,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'agent_runs';
  @override
  VerificationContext validateIntegrity(Insertable<AgentRun> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('thread_id')) {
      context.handle(_threadIdMeta,
          threadId.isAcceptableOrUnknown(data['thread_id']!, _threadIdMeta));
    } else if (isInserting) {
      context.missing(_threadIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('model_rounds')) {
      context.handle(
          _modelRoundsMeta,
          modelRounds.isAcceptableOrUnknown(
              data['model_rounds']!, _modelRoundsMeta));
    }
    if (data.containsKey('tool_calls')) {
      context.handle(_toolCallsMeta,
          toolCalls.isAcceptableOrUnknown(data['tool_calls']!, _toolCallsMeta));
    }
    if (data.containsKey('error')) {
      context.handle(
          _errorMeta, error.isAcceptableOrUnknown(data['error']!, _errorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AgentRun map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AgentRun(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      threadId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thread_id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      modelRounds: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}model_rounds'])!,
      toolCalls: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}tool_calls'])!,
      error: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AgentRunsTable createAlias(String alias) {
    return $AgentRunsTable(attachedDatabase, alias);
  }
}

class AgentRun extends DataClass implements Insertable<AgentRun> {
  final String id;
  final String threadId;
  final String status;
  final int modelRounds;
  final int toolCalls;
  final String? error;
  final String createdAt;
  final String updatedAt;
  const AgentRun(
      {required this.id,
      required this.threadId,
      required this.status,
      required this.modelRounds,
      required this.toolCalls,
      this.error,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['thread_id'] = Variable<String>(threadId);
    map['status'] = Variable<String>(status);
    map['model_rounds'] = Variable<int>(modelRounds);
    map['tool_calls'] = Variable<int>(toolCalls);
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  AgentRunsCompanion toCompanion(bool nullToAbsent) {
    return AgentRunsCompanion(
      id: Value(id),
      threadId: Value(threadId),
      status: Value(status),
      modelRounds: Value(modelRounds),
      toolCalls: Value(toolCalls),
      error:
          error == null && nullToAbsent ? const Value.absent() : Value(error),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AgentRun.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AgentRun(
      id: serializer.fromJson<String>(json['id']),
      threadId: serializer.fromJson<String>(json['threadId']),
      status: serializer.fromJson<String>(json['status']),
      modelRounds: serializer.fromJson<int>(json['modelRounds']),
      toolCalls: serializer.fromJson<int>(json['toolCalls']),
      error: serializer.fromJson<String?>(json['error']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'threadId': serializer.toJson<String>(threadId),
      'status': serializer.toJson<String>(status),
      'modelRounds': serializer.toJson<int>(modelRounds),
      'toolCalls': serializer.toJson<int>(toolCalls),
      'error': serializer.toJson<String?>(error),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  AgentRun copyWith(
          {String? id,
          String? threadId,
          String? status,
          int? modelRounds,
          int? toolCalls,
          Value<String?> error = const Value.absent(),
          String? createdAt,
          String? updatedAt}) =>
      AgentRun(
        id: id ?? this.id,
        threadId: threadId ?? this.threadId,
        status: status ?? this.status,
        modelRounds: modelRounds ?? this.modelRounds,
        toolCalls: toolCalls ?? this.toolCalls,
        error: error.present ? error.value : this.error,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AgentRun copyWithCompanion(AgentRunsCompanion data) {
    return AgentRun(
      id: data.id.present ? data.id.value : this.id,
      threadId: data.threadId.present ? data.threadId.value : this.threadId,
      status: data.status.present ? data.status.value : this.status,
      modelRounds:
          data.modelRounds.present ? data.modelRounds.value : this.modelRounds,
      toolCalls: data.toolCalls.present ? data.toolCalls.value : this.toolCalls,
      error: data.error.present ? data.error.value : this.error,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AgentRun(')
          ..write('id: $id, ')
          ..write('threadId: $threadId, ')
          ..write('status: $status, ')
          ..write('modelRounds: $modelRounds, ')
          ..write('toolCalls: $toolCalls, ')
          ..write('error: $error, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, threadId, status, modelRounds, toolCalls,
      error, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AgentRun &&
          other.id == this.id &&
          other.threadId == this.threadId &&
          other.status == this.status &&
          other.modelRounds == this.modelRounds &&
          other.toolCalls == this.toolCalls &&
          other.error == this.error &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AgentRunsCompanion extends UpdateCompanion<AgentRun> {
  final Value<String> id;
  final Value<String> threadId;
  final Value<String> status;
  final Value<int> modelRounds;
  final Value<int> toolCalls;
  final Value<String?> error;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const AgentRunsCompanion({
    this.id = const Value.absent(),
    this.threadId = const Value.absent(),
    this.status = const Value.absent(),
    this.modelRounds = const Value.absent(),
    this.toolCalls = const Value.absent(),
    this.error = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AgentRunsCompanion.insert({
    required String id,
    required String threadId,
    required String status,
    this.modelRounds = const Value.absent(),
    this.toolCalls = const Value.absent(),
    this.error = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        threadId = Value(threadId),
        status = Value(status),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<AgentRun> custom({
    Expression<String>? id,
    Expression<String>? threadId,
    Expression<String>? status,
    Expression<int>? modelRounds,
    Expression<int>? toolCalls,
    Expression<String>? error,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (threadId != null) 'thread_id': threadId,
      if (status != null) 'status': status,
      if (modelRounds != null) 'model_rounds': modelRounds,
      if (toolCalls != null) 'tool_calls': toolCalls,
      if (error != null) 'error': error,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AgentRunsCompanion copyWith(
      {Value<String>? id,
      Value<String>? threadId,
      Value<String>? status,
      Value<int>? modelRounds,
      Value<int>? toolCalls,
      Value<String?>? error,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? rowid}) {
    return AgentRunsCompanion(
      id: id ?? this.id,
      threadId: threadId ?? this.threadId,
      status: status ?? this.status,
      modelRounds: modelRounds ?? this.modelRounds,
      toolCalls: toolCalls ?? this.toolCalls,
      error: error ?? this.error,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (threadId.present) {
      map['thread_id'] = Variable<String>(threadId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (modelRounds.present) {
      map['model_rounds'] = Variable<int>(modelRounds.value);
    }
    if (toolCalls.present) {
      map['tool_calls'] = Variable<int>(toolCalls.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AgentRunsCompanion(')
          ..write('id: $id, ')
          ..write('threadId: $threadId, ')
          ..write('status: $status, ')
          ..write('modelRounds: $modelRounds, ')
          ..write('toolCalls: $toolCalls, ')
          ..write('error: $error, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AgentToolCallsTable extends AgentToolCalls
    with TableInfo<$AgentToolCallsTable, AgentToolCallRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AgentToolCallsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<String> runId = GeneratedColumn<String>(
      'run_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _callIdMeta = const VerificationMeta('callId');
  @override
  late final GeneratedColumn<String> callId = GeneratedColumn<String>(
      'call_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _toolNameMeta =
      const VerificationMeta('toolName');
  @override
  late final GeneratedColumn<String> toolName = GeneratedColumn<String>(
      'tool_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _argumentsJsonMeta =
      const VerificationMeta('argumentsJson');
  @override
  late final GeneratedColumn<String> argumentsJson = GeneratedColumn<String>(
      'arguments_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _riskLevelMeta =
      const VerificationMeta('riskLevel');
  @override
  late final GeneratedColumn<String> riskLevel = GeneratedColumn<String>(
      'risk_level', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _resultJsonMeta =
      const VerificationMeta('resultJson');
  @override
  late final GeneratedColumn<String> resultJson = GeneratedColumn<String>(
      'result_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _idempotencyKeyMeta =
      const VerificationMeta('idempotencyKey');
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
      'idempotency_key', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
      'error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        runId,
        callId,
        toolName,
        argumentsJson,
        riskLevel,
        status,
        resultJson,
        idempotencyKey,
        error,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'agent_tool_calls';
  @override
  VerificationContext validateIntegrity(Insertable<AgentToolCallRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('run_id')) {
      context.handle(
          _runIdMeta, runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta));
    } else if (isInserting) {
      context.missing(_runIdMeta);
    }
    if (data.containsKey('call_id')) {
      context.handle(_callIdMeta,
          callId.isAcceptableOrUnknown(data['call_id']!, _callIdMeta));
    } else if (isInserting) {
      context.missing(_callIdMeta);
    }
    if (data.containsKey('tool_name')) {
      context.handle(_toolNameMeta,
          toolName.isAcceptableOrUnknown(data['tool_name']!, _toolNameMeta));
    } else if (isInserting) {
      context.missing(_toolNameMeta);
    }
    if (data.containsKey('arguments_json')) {
      context.handle(
          _argumentsJsonMeta,
          argumentsJson.isAcceptableOrUnknown(
              data['arguments_json']!, _argumentsJsonMeta));
    } else if (isInserting) {
      context.missing(_argumentsJsonMeta);
    }
    if (data.containsKey('risk_level')) {
      context.handle(_riskLevelMeta,
          riskLevel.isAcceptableOrUnknown(data['risk_level']!, _riskLevelMeta));
    } else if (isInserting) {
      context.missing(_riskLevelMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('result_json')) {
      context.handle(
          _resultJsonMeta,
          resultJson.isAcceptableOrUnknown(
              data['result_json']!, _resultJsonMeta));
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
          _idempotencyKeyMeta,
          idempotencyKey.isAcceptableOrUnknown(
              data['idempotency_key']!, _idempotencyKeyMeta));
    }
    if (data.containsKey('error')) {
      context.handle(
          _errorMeta, error.isAcceptableOrUnknown(data['error']!, _errorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AgentToolCallRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AgentToolCallRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      runId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}run_id'])!,
      callId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}call_id'])!,
      toolName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tool_name'])!,
      argumentsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}arguments_json'])!,
      riskLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}risk_level'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      resultJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}result_json']),
      idempotencyKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}idempotency_key']),
      error: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $AgentToolCallsTable createAlias(String alias) {
    return $AgentToolCallsTable(attachedDatabase, alias);
  }
}

class AgentToolCallRow extends DataClass
    implements Insertable<AgentToolCallRow> {
  final String id;
  final String runId;
  final String callId;
  final String toolName;
  final String argumentsJson;
  final String riskLevel;
  final String status;
  final String? resultJson;
  final String? idempotencyKey;
  final String? error;
  final String createdAt;
  final String updatedAt;
  const AgentToolCallRow(
      {required this.id,
      required this.runId,
      required this.callId,
      required this.toolName,
      required this.argumentsJson,
      required this.riskLevel,
      required this.status,
      this.resultJson,
      this.idempotencyKey,
      this.error,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['run_id'] = Variable<String>(runId);
    map['call_id'] = Variable<String>(callId);
    map['tool_name'] = Variable<String>(toolName);
    map['arguments_json'] = Variable<String>(argumentsJson);
    map['risk_level'] = Variable<String>(riskLevel);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || resultJson != null) {
      map['result_json'] = Variable<String>(resultJson);
    }
    if (!nullToAbsent || idempotencyKey != null) {
      map['idempotency_key'] = Variable<String>(idempotencyKey);
    }
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  AgentToolCallsCompanion toCompanion(bool nullToAbsent) {
    return AgentToolCallsCompanion(
      id: Value(id),
      runId: Value(runId),
      callId: Value(callId),
      toolName: Value(toolName),
      argumentsJson: Value(argumentsJson),
      riskLevel: Value(riskLevel),
      status: Value(status),
      resultJson: resultJson == null && nullToAbsent
          ? const Value.absent()
          : Value(resultJson),
      idempotencyKey: idempotencyKey == null && nullToAbsent
          ? const Value.absent()
          : Value(idempotencyKey),
      error:
          error == null && nullToAbsent ? const Value.absent() : Value(error),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AgentToolCallRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AgentToolCallRow(
      id: serializer.fromJson<String>(json['id']),
      runId: serializer.fromJson<String>(json['runId']),
      callId: serializer.fromJson<String>(json['callId']),
      toolName: serializer.fromJson<String>(json['toolName']),
      argumentsJson: serializer.fromJson<String>(json['argumentsJson']),
      riskLevel: serializer.fromJson<String>(json['riskLevel']),
      status: serializer.fromJson<String>(json['status']),
      resultJson: serializer.fromJson<String?>(json['resultJson']),
      idempotencyKey: serializer.fromJson<String?>(json['idempotencyKey']),
      error: serializer.fromJson<String?>(json['error']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'runId': serializer.toJson<String>(runId),
      'callId': serializer.toJson<String>(callId),
      'toolName': serializer.toJson<String>(toolName),
      'argumentsJson': serializer.toJson<String>(argumentsJson),
      'riskLevel': serializer.toJson<String>(riskLevel),
      'status': serializer.toJson<String>(status),
      'resultJson': serializer.toJson<String?>(resultJson),
      'idempotencyKey': serializer.toJson<String?>(idempotencyKey),
      'error': serializer.toJson<String?>(error),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  AgentToolCallRow copyWith(
          {String? id,
          String? runId,
          String? callId,
          String? toolName,
          String? argumentsJson,
          String? riskLevel,
          String? status,
          Value<String?> resultJson = const Value.absent(),
          Value<String?> idempotencyKey = const Value.absent(),
          Value<String?> error = const Value.absent(),
          String? createdAt,
          String? updatedAt}) =>
      AgentToolCallRow(
        id: id ?? this.id,
        runId: runId ?? this.runId,
        callId: callId ?? this.callId,
        toolName: toolName ?? this.toolName,
        argumentsJson: argumentsJson ?? this.argumentsJson,
        riskLevel: riskLevel ?? this.riskLevel,
        status: status ?? this.status,
        resultJson: resultJson.present ? resultJson.value : this.resultJson,
        idempotencyKey:
            idempotencyKey.present ? idempotencyKey.value : this.idempotencyKey,
        error: error.present ? error.value : this.error,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  AgentToolCallRow copyWithCompanion(AgentToolCallsCompanion data) {
    return AgentToolCallRow(
      id: data.id.present ? data.id.value : this.id,
      runId: data.runId.present ? data.runId.value : this.runId,
      callId: data.callId.present ? data.callId.value : this.callId,
      toolName: data.toolName.present ? data.toolName.value : this.toolName,
      argumentsJson: data.argumentsJson.present
          ? data.argumentsJson.value
          : this.argumentsJson,
      riskLevel: data.riskLevel.present ? data.riskLevel.value : this.riskLevel,
      status: data.status.present ? data.status.value : this.status,
      resultJson:
          data.resultJson.present ? data.resultJson.value : this.resultJson,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      error: data.error.present ? data.error.value : this.error,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AgentToolCallRow(')
          ..write('id: $id, ')
          ..write('runId: $runId, ')
          ..write('callId: $callId, ')
          ..write('toolName: $toolName, ')
          ..write('argumentsJson: $argumentsJson, ')
          ..write('riskLevel: $riskLevel, ')
          ..write('status: $status, ')
          ..write('resultJson: $resultJson, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('error: $error, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      runId,
      callId,
      toolName,
      argumentsJson,
      riskLevel,
      status,
      resultJson,
      idempotencyKey,
      error,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AgentToolCallRow &&
          other.id == this.id &&
          other.runId == this.runId &&
          other.callId == this.callId &&
          other.toolName == this.toolName &&
          other.argumentsJson == this.argumentsJson &&
          other.riskLevel == this.riskLevel &&
          other.status == this.status &&
          other.resultJson == this.resultJson &&
          other.idempotencyKey == this.idempotencyKey &&
          other.error == this.error &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AgentToolCallsCompanion extends UpdateCompanion<AgentToolCallRow> {
  final Value<String> id;
  final Value<String> runId;
  final Value<String> callId;
  final Value<String> toolName;
  final Value<String> argumentsJson;
  final Value<String> riskLevel;
  final Value<String> status;
  final Value<String?> resultJson;
  final Value<String?> idempotencyKey;
  final Value<String?> error;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const AgentToolCallsCompanion({
    this.id = const Value.absent(),
    this.runId = const Value.absent(),
    this.callId = const Value.absent(),
    this.toolName = const Value.absent(),
    this.argumentsJson = const Value.absent(),
    this.riskLevel = const Value.absent(),
    this.status = const Value.absent(),
    this.resultJson = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.error = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AgentToolCallsCompanion.insert({
    required String id,
    required String runId,
    required String callId,
    required String toolName,
    required String argumentsJson,
    required String riskLevel,
    required String status,
    this.resultJson = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.error = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        runId = Value(runId),
        callId = Value(callId),
        toolName = Value(toolName),
        argumentsJson = Value(argumentsJson),
        riskLevel = Value(riskLevel),
        status = Value(status),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<AgentToolCallRow> custom({
    Expression<String>? id,
    Expression<String>? runId,
    Expression<String>? callId,
    Expression<String>? toolName,
    Expression<String>? argumentsJson,
    Expression<String>? riskLevel,
    Expression<String>? status,
    Expression<String>? resultJson,
    Expression<String>? idempotencyKey,
    Expression<String>? error,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (runId != null) 'run_id': runId,
      if (callId != null) 'call_id': callId,
      if (toolName != null) 'tool_name': toolName,
      if (argumentsJson != null) 'arguments_json': argumentsJson,
      if (riskLevel != null) 'risk_level': riskLevel,
      if (status != null) 'status': status,
      if (resultJson != null) 'result_json': resultJson,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (error != null) 'error': error,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AgentToolCallsCompanion copyWith(
      {Value<String>? id,
      Value<String>? runId,
      Value<String>? callId,
      Value<String>? toolName,
      Value<String>? argumentsJson,
      Value<String>? riskLevel,
      Value<String>? status,
      Value<String?>? resultJson,
      Value<String?>? idempotencyKey,
      Value<String?>? error,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? rowid}) {
    return AgentToolCallsCompanion(
      id: id ?? this.id,
      runId: runId ?? this.runId,
      callId: callId ?? this.callId,
      toolName: toolName ?? this.toolName,
      argumentsJson: argumentsJson ?? this.argumentsJson,
      riskLevel: riskLevel ?? this.riskLevel,
      status: status ?? this.status,
      resultJson: resultJson ?? this.resultJson,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      error: error ?? this.error,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (runId.present) {
      map['run_id'] = Variable<String>(runId.value);
    }
    if (callId.present) {
      map['call_id'] = Variable<String>(callId.value);
    }
    if (toolName.present) {
      map['tool_name'] = Variable<String>(toolName.value);
    }
    if (argumentsJson.present) {
      map['arguments_json'] = Variable<String>(argumentsJson.value);
    }
    if (riskLevel.present) {
      map['risk_level'] = Variable<String>(riskLevel.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (resultJson.present) {
      map['result_json'] = Variable<String>(resultJson.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AgentToolCallsCompanion(')
          ..write('id: $id, ')
          ..write('runId: $runId, ')
          ..write('callId: $callId, ')
          ..write('toolName: $toolName, ')
          ..write('argumentsJson: $argumentsJson, ')
          ..write('riskLevel: $riskLevel, ')
          ..write('status: $status, ')
          ..write('resultJson: $resultJson, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('error: $error, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AgentConfirmationsTable extends AgentConfirmations
    with TableInfo<$AgentConfirmationsTable, AgentConfirmation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AgentConfirmationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tokenMeta = const VerificationMeta('token');
  @override
  late final GeneratedColumn<String> token = GeneratedColumn<String>(
      'token', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _toolCallIdMeta =
      const VerificationMeta('toolCallId');
  @override
  late final GeneratedColumn<String> toolCallId = GeneratedColumn<String>(
      'tool_call_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _runIdMeta = const VerificationMeta('runId');
  @override
  late final GeneratedColumn<String> runId = GeneratedColumn<String>(
      'run_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _toolNameMeta =
      const VerificationMeta('toolName');
  @override
  late final GeneratedColumn<String> toolName = GeneratedColumn<String>(
      'tool_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _argumentsJsonMeta =
      const VerificationMeta('argumentsJson');
  @override
  late final GeneratedColumn<String> argumentsJson = GeneratedColumn<String>(
      'arguments_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _previewJsonMeta =
      const VerificationMeta('previewJson');
  @override
  late final GeneratedColumn<String> previewJson = GeneratedColumn<String>(
      'preview_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _responseIdMeta =
      const VerificationMeta('responseId');
  @override
  late final GeneratedColumn<String> responseId = GeneratedColumn<String>(
      'response_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _recordVersionMeta =
      const VerificationMeta('recordVersion');
  @override
  late final GeneratedColumn<String> recordVersion = GeneratedColumn<String>(
      'record_version', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _expiresAtMeta =
      const VerificationMeta('expiresAt');
  @override
  late final GeneratedColumn<String> expiresAt = GeneratedColumn<String>(
      'expires_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        token,
        toolCallId,
        runId,
        toolName,
        argumentsJson,
        previewJson,
        responseId,
        status,
        recordVersion,
        expiresAt,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'agent_confirmations';
  @override
  VerificationContext validateIntegrity(Insertable<AgentConfirmation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('token')) {
      context.handle(
          _tokenMeta, token.isAcceptableOrUnknown(data['token']!, _tokenMeta));
    } else if (isInserting) {
      context.missing(_tokenMeta);
    }
    if (data.containsKey('tool_call_id')) {
      context.handle(
          _toolCallIdMeta,
          toolCallId.isAcceptableOrUnknown(
              data['tool_call_id']!, _toolCallIdMeta));
    } else if (isInserting) {
      context.missing(_toolCallIdMeta);
    }
    if (data.containsKey('run_id')) {
      context.handle(
          _runIdMeta, runId.isAcceptableOrUnknown(data['run_id']!, _runIdMeta));
    } else if (isInserting) {
      context.missing(_runIdMeta);
    }
    if (data.containsKey('tool_name')) {
      context.handle(_toolNameMeta,
          toolName.isAcceptableOrUnknown(data['tool_name']!, _toolNameMeta));
    } else if (isInserting) {
      context.missing(_toolNameMeta);
    }
    if (data.containsKey('arguments_json')) {
      context.handle(
          _argumentsJsonMeta,
          argumentsJson.isAcceptableOrUnknown(
              data['arguments_json']!, _argumentsJsonMeta));
    } else if (isInserting) {
      context.missing(_argumentsJsonMeta);
    }
    if (data.containsKey('preview_json')) {
      context.handle(
          _previewJsonMeta,
          previewJson.isAcceptableOrUnknown(
              data['preview_json']!, _previewJsonMeta));
    } else if (isInserting) {
      context.missing(_previewJsonMeta);
    }
    if (data.containsKey('response_id')) {
      context.handle(
          _responseIdMeta,
          responseId.isAcceptableOrUnknown(
              data['response_id']!, _responseIdMeta));
    } else if (isInserting) {
      context.missing(_responseIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('record_version')) {
      context.handle(
          _recordVersionMeta,
          recordVersion.isAcceptableOrUnknown(
              data['record_version']!, _recordVersionMeta));
    }
    if (data.containsKey('expires_at')) {
      context.handle(_expiresAtMeta,
          expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta));
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {token};
  @override
  AgentConfirmation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AgentConfirmation(
      token: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}token'])!,
      toolCallId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tool_call_id'])!,
      runId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}run_id'])!,
      toolName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tool_name'])!,
      argumentsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}arguments_json'])!,
      previewJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}preview_json'])!,
      responseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}response_id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      recordVersion: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}record_version']),
      expiresAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}expires_at'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AgentConfirmationsTable createAlias(String alias) {
    return $AgentConfirmationsTable(attachedDatabase, alias);
  }
}

class AgentConfirmation extends DataClass
    implements Insertable<AgentConfirmation> {
  final String token;
  final String toolCallId;
  final String runId;
  final String toolName;
  final String argumentsJson;
  final String previewJson;
  final String responseId;
  final String status;
  final String? recordVersion;
  final String expiresAt;
  final String createdAt;
  const AgentConfirmation(
      {required this.token,
      required this.toolCallId,
      required this.runId,
      required this.toolName,
      required this.argumentsJson,
      required this.previewJson,
      required this.responseId,
      required this.status,
      this.recordVersion,
      required this.expiresAt,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['token'] = Variable<String>(token);
    map['tool_call_id'] = Variable<String>(toolCallId);
    map['run_id'] = Variable<String>(runId);
    map['tool_name'] = Variable<String>(toolName);
    map['arguments_json'] = Variable<String>(argumentsJson);
    map['preview_json'] = Variable<String>(previewJson);
    map['response_id'] = Variable<String>(responseId);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || recordVersion != null) {
      map['record_version'] = Variable<String>(recordVersion);
    }
    map['expires_at'] = Variable<String>(expiresAt);
    map['created_at'] = Variable<String>(createdAt);
    return map;
  }

  AgentConfirmationsCompanion toCompanion(bool nullToAbsent) {
    return AgentConfirmationsCompanion(
      token: Value(token),
      toolCallId: Value(toolCallId),
      runId: Value(runId),
      toolName: Value(toolName),
      argumentsJson: Value(argumentsJson),
      previewJson: Value(previewJson),
      responseId: Value(responseId),
      status: Value(status),
      recordVersion: recordVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(recordVersion),
      expiresAt: Value(expiresAt),
      createdAt: Value(createdAt),
    );
  }

  factory AgentConfirmation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AgentConfirmation(
      token: serializer.fromJson<String>(json['token']),
      toolCallId: serializer.fromJson<String>(json['toolCallId']),
      runId: serializer.fromJson<String>(json['runId']),
      toolName: serializer.fromJson<String>(json['toolName']),
      argumentsJson: serializer.fromJson<String>(json['argumentsJson']),
      previewJson: serializer.fromJson<String>(json['previewJson']),
      responseId: serializer.fromJson<String>(json['responseId']),
      status: serializer.fromJson<String>(json['status']),
      recordVersion: serializer.fromJson<String?>(json['recordVersion']),
      expiresAt: serializer.fromJson<String>(json['expiresAt']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'token': serializer.toJson<String>(token),
      'toolCallId': serializer.toJson<String>(toolCallId),
      'runId': serializer.toJson<String>(runId),
      'toolName': serializer.toJson<String>(toolName),
      'argumentsJson': serializer.toJson<String>(argumentsJson),
      'previewJson': serializer.toJson<String>(previewJson),
      'responseId': serializer.toJson<String>(responseId),
      'status': serializer.toJson<String>(status),
      'recordVersion': serializer.toJson<String?>(recordVersion),
      'expiresAt': serializer.toJson<String>(expiresAt),
      'createdAt': serializer.toJson<String>(createdAt),
    };
  }

  AgentConfirmation copyWith(
          {String? token,
          String? toolCallId,
          String? runId,
          String? toolName,
          String? argumentsJson,
          String? previewJson,
          String? responseId,
          String? status,
          Value<String?> recordVersion = const Value.absent(),
          String? expiresAt,
          String? createdAt}) =>
      AgentConfirmation(
        token: token ?? this.token,
        toolCallId: toolCallId ?? this.toolCallId,
        runId: runId ?? this.runId,
        toolName: toolName ?? this.toolName,
        argumentsJson: argumentsJson ?? this.argumentsJson,
        previewJson: previewJson ?? this.previewJson,
        responseId: responseId ?? this.responseId,
        status: status ?? this.status,
        recordVersion:
            recordVersion.present ? recordVersion.value : this.recordVersion,
        expiresAt: expiresAt ?? this.expiresAt,
        createdAt: createdAt ?? this.createdAt,
      );
  AgentConfirmation copyWithCompanion(AgentConfirmationsCompanion data) {
    return AgentConfirmation(
      token: data.token.present ? data.token.value : this.token,
      toolCallId:
          data.toolCallId.present ? data.toolCallId.value : this.toolCallId,
      runId: data.runId.present ? data.runId.value : this.runId,
      toolName: data.toolName.present ? data.toolName.value : this.toolName,
      argumentsJson: data.argumentsJson.present
          ? data.argumentsJson.value
          : this.argumentsJson,
      previewJson:
          data.previewJson.present ? data.previewJson.value : this.previewJson,
      responseId:
          data.responseId.present ? data.responseId.value : this.responseId,
      status: data.status.present ? data.status.value : this.status,
      recordVersion: data.recordVersion.present
          ? data.recordVersion.value
          : this.recordVersion,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AgentConfirmation(')
          ..write('token: $token, ')
          ..write('toolCallId: $toolCallId, ')
          ..write('runId: $runId, ')
          ..write('toolName: $toolName, ')
          ..write('argumentsJson: $argumentsJson, ')
          ..write('previewJson: $previewJson, ')
          ..write('responseId: $responseId, ')
          ..write('status: $status, ')
          ..write('recordVersion: $recordVersion, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      token,
      toolCallId,
      runId,
      toolName,
      argumentsJson,
      previewJson,
      responseId,
      status,
      recordVersion,
      expiresAt,
      createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AgentConfirmation &&
          other.token == this.token &&
          other.toolCallId == this.toolCallId &&
          other.runId == this.runId &&
          other.toolName == this.toolName &&
          other.argumentsJson == this.argumentsJson &&
          other.previewJson == this.previewJson &&
          other.responseId == this.responseId &&
          other.status == this.status &&
          other.recordVersion == this.recordVersion &&
          other.expiresAt == this.expiresAt &&
          other.createdAt == this.createdAt);
}

class AgentConfirmationsCompanion extends UpdateCompanion<AgentConfirmation> {
  final Value<String> token;
  final Value<String> toolCallId;
  final Value<String> runId;
  final Value<String> toolName;
  final Value<String> argumentsJson;
  final Value<String> previewJson;
  final Value<String> responseId;
  final Value<String> status;
  final Value<String?> recordVersion;
  final Value<String> expiresAt;
  final Value<String> createdAt;
  final Value<int> rowid;
  const AgentConfirmationsCompanion({
    this.token = const Value.absent(),
    this.toolCallId = const Value.absent(),
    this.runId = const Value.absent(),
    this.toolName = const Value.absent(),
    this.argumentsJson = const Value.absent(),
    this.previewJson = const Value.absent(),
    this.responseId = const Value.absent(),
    this.status = const Value.absent(),
    this.recordVersion = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AgentConfirmationsCompanion.insert({
    required String token,
    required String toolCallId,
    required String runId,
    required String toolName,
    required String argumentsJson,
    required String previewJson,
    required String responseId,
    required String status,
    this.recordVersion = const Value.absent(),
    required String expiresAt,
    required String createdAt,
    this.rowid = const Value.absent(),
  })  : token = Value(token),
        toolCallId = Value(toolCallId),
        runId = Value(runId),
        toolName = Value(toolName),
        argumentsJson = Value(argumentsJson),
        previewJson = Value(previewJson),
        responseId = Value(responseId),
        status = Value(status),
        expiresAt = Value(expiresAt),
        createdAt = Value(createdAt);
  static Insertable<AgentConfirmation> custom({
    Expression<String>? token,
    Expression<String>? toolCallId,
    Expression<String>? runId,
    Expression<String>? toolName,
    Expression<String>? argumentsJson,
    Expression<String>? previewJson,
    Expression<String>? responseId,
    Expression<String>? status,
    Expression<String>? recordVersion,
    Expression<String>? expiresAt,
    Expression<String>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (token != null) 'token': token,
      if (toolCallId != null) 'tool_call_id': toolCallId,
      if (runId != null) 'run_id': runId,
      if (toolName != null) 'tool_name': toolName,
      if (argumentsJson != null) 'arguments_json': argumentsJson,
      if (previewJson != null) 'preview_json': previewJson,
      if (responseId != null) 'response_id': responseId,
      if (status != null) 'status': status,
      if (recordVersion != null) 'record_version': recordVersion,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AgentConfirmationsCompanion copyWith(
      {Value<String>? token,
      Value<String>? toolCallId,
      Value<String>? runId,
      Value<String>? toolName,
      Value<String>? argumentsJson,
      Value<String>? previewJson,
      Value<String>? responseId,
      Value<String>? status,
      Value<String?>? recordVersion,
      Value<String>? expiresAt,
      Value<String>? createdAt,
      Value<int>? rowid}) {
    return AgentConfirmationsCompanion(
      token: token ?? this.token,
      toolCallId: toolCallId ?? this.toolCallId,
      runId: runId ?? this.runId,
      toolName: toolName ?? this.toolName,
      argumentsJson: argumentsJson ?? this.argumentsJson,
      previewJson: previewJson ?? this.previewJson,
      responseId: responseId ?? this.responseId,
      status: status ?? this.status,
      recordVersion: recordVersion ?? this.recordVersion,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (token.present) {
      map['token'] = Variable<String>(token.value);
    }
    if (toolCallId.present) {
      map['tool_call_id'] = Variable<String>(toolCallId.value);
    }
    if (runId.present) {
      map['run_id'] = Variable<String>(runId.value);
    }
    if (toolName.present) {
      map['tool_name'] = Variable<String>(toolName.value);
    }
    if (argumentsJson.present) {
      map['arguments_json'] = Variable<String>(argumentsJson.value);
    }
    if (previewJson.present) {
      map['preview_json'] = Variable<String>(previewJson.value);
    }
    if (responseId.present) {
      map['response_id'] = Variable<String>(responseId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (recordVersion.present) {
      map['record_version'] = Variable<String>(recordVersion.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<String>(expiresAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AgentConfirmationsCompanion(')
          ..write('token: $token, ')
          ..write('toolCallId: $toolCallId, ')
          ..write('runId: $runId, ')
          ..write('toolName: $toolName, ')
          ..write('argumentsJson: $argumentsJson, ')
          ..write('previewJson: $previewJson, ')
          ..write('responseId: $responseId, ')
          ..write('status: $status, ')
          ..write('recordVersion: $recordVersion, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MemoryItemsTable extends MemoryItems
    with TableInfo<$MemoryItemsTable, MemoryItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoryItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _memoryTypeMeta =
      const VerificationMeta('memoryType');
  @override
  late final GeneratedColumn<String> memoryType = GeneratedColumn<String>(
      'memory_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sourceMessageIdMeta =
      const VerificationMeta('sourceMessageId');
  @override
  late final GeneratedColumn<String> sourceMessageId = GeneratedColumn<String>(
      'source_message_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
      'confidence', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastUsedAtMeta =
      const VerificationMeta('lastUsedAt');
  @override
  late final GeneratedColumn<String> lastUsedAt = GeneratedColumn<String>(
      'last_used_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _expiresAtMeta =
      const VerificationMeta('expiresAt');
  @override
  late final GeneratedColumn<String> expiresAt = GeneratedColumn<String>(
      'expires_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        memoryType,
        content,
        sourceMessageId,
        confidence,
        createdAt,
        lastUsedAt,
        expiresAt,
        status
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memory_items';
  @override
  VerificationContext validateIntegrity(Insertable<MemoryItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('memory_type')) {
      context.handle(
          _memoryTypeMeta,
          memoryType.isAcceptableOrUnknown(
              data['memory_type']!, _memoryTypeMeta));
    } else if (isInserting) {
      context.missing(_memoryTypeMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('source_message_id')) {
      context.handle(
          _sourceMessageIdMeta,
          sourceMessageId.isAcceptableOrUnknown(
              data['source_message_id']!, _sourceMessageIdMeta));
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    } else if (isInserting) {
      context.missing(_confidenceMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
          _lastUsedAtMeta,
          lastUsedAt.isAcceptableOrUnknown(
              data['last_used_at']!, _lastUsedAtMeta));
    }
    if (data.containsKey('expires_at')) {
      context.handle(_expiresAtMeta,
          expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MemoryItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MemoryItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      memoryType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}memory_type'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      sourceMessageId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}source_message_id']),
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}confidence'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      lastUsedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_used_at']),
      expiresAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}expires_at']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $MemoryItemsTable createAlias(String alias) {
    return $MemoryItemsTable(attachedDatabase, alias);
  }
}

class MemoryItem extends DataClass implements Insertable<MemoryItem> {
  final String id;
  final String memoryType;
  final String content;
  final String? sourceMessageId;
  final double confidence;
  final String createdAt;
  final String? lastUsedAt;
  final String? expiresAt;
  final String status;
  const MemoryItem(
      {required this.id,
      required this.memoryType,
      required this.content,
      this.sourceMessageId,
      required this.confidence,
      required this.createdAt,
      this.lastUsedAt,
      this.expiresAt,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['memory_type'] = Variable<String>(memoryType);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || sourceMessageId != null) {
      map['source_message_id'] = Variable<String>(sourceMessageId);
    }
    map['confidence'] = Variable<double>(confidence);
    map['created_at'] = Variable<String>(createdAt);
    if (!nullToAbsent || lastUsedAt != null) {
      map['last_used_at'] = Variable<String>(lastUsedAt);
    }
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<String>(expiresAt);
    }
    map['status'] = Variable<String>(status);
    return map;
  }

  MemoryItemsCompanion toCompanion(bool nullToAbsent) {
    return MemoryItemsCompanion(
      id: Value(id),
      memoryType: Value(memoryType),
      content: Value(content),
      sourceMessageId: sourceMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceMessageId),
      confidence: Value(confidence),
      createdAt: Value(createdAt),
      lastUsedAt: lastUsedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUsedAt),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
      status: Value(status),
    );
  }

  factory MemoryItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MemoryItem(
      id: serializer.fromJson<String>(json['id']),
      memoryType: serializer.fromJson<String>(json['memoryType']),
      content: serializer.fromJson<String>(json['content']),
      sourceMessageId: serializer.fromJson<String?>(json['sourceMessageId']),
      confidence: serializer.fromJson<double>(json['confidence']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      lastUsedAt: serializer.fromJson<String?>(json['lastUsedAt']),
      expiresAt: serializer.fromJson<String?>(json['expiresAt']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'memoryType': serializer.toJson<String>(memoryType),
      'content': serializer.toJson<String>(content),
      'sourceMessageId': serializer.toJson<String?>(sourceMessageId),
      'confidence': serializer.toJson<double>(confidence),
      'createdAt': serializer.toJson<String>(createdAt),
      'lastUsedAt': serializer.toJson<String?>(lastUsedAt),
      'expiresAt': serializer.toJson<String?>(expiresAt),
      'status': serializer.toJson<String>(status),
    };
  }

  MemoryItem copyWith(
          {String? id,
          String? memoryType,
          String? content,
          Value<String?> sourceMessageId = const Value.absent(),
          double? confidence,
          String? createdAt,
          Value<String?> lastUsedAt = const Value.absent(),
          Value<String?> expiresAt = const Value.absent(),
          String? status}) =>
      MemoryItem(
        id: id ?? this.id,
        memoryType: memoryType ?? this.memoryType,
        content: content ?? this.content,
        sourceMessageId: sourceMessageId.present
            ? sourceMessageId.value
            : this.sourceMessageId,
        confidence: confidence ?? this.confidence,
        createdAt: createdAt ?? this.createdAt,
        lastUsedAt: lastUsedAt.present ? lastUsedAt.value : this.lastUsedAt,
        expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
        status: status ?? this.status,
      );
  MemoryItem copyWithCompanion(MemoryItemsCompanion data) {
    return MemoryItem(
      id: data.id.present ? data.id.value : this.id,
      memoryType:
          data.memoryType.present ? data.memoryType.value : this.memoryType,
      content: data.content.present ? data.content.value : this.content,
      sourceMessageId: data.sourceMessageId.present
          ? data.sourceMessageId.value
          : this.sourceMessageId,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastUsedAt:
          data.lastUsedAt.present ? data.lastUsedAt.value : this.lastUsedAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MemoryItem(')
          ..write('id: $id, ')
          ..write('memoryType: $memoryType, ')
          ..write('content: $content, ')
          ..write('sourceMessageId: $sourceMessageId, ')
          ..write('confidence: $confidence, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, memoryType, content, sourceMessageId,
      confidence, createdAt, lastUsedAt, expiresAt, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MemoryItem &&
          other.id == this.id &&
          other.memoryType == this.memoryType &&
          other.content == this.content &&
          other.sourceMessageId == this.sourceMessageId &&
          other.confidence == this.confidence &&
          other.createdAt == this.createdAt &&
          other.lastUsedAt == this.lastUsedAt &&
          other.expiresAt == this.expiresAt &&
          other.status == this.status);
}

class MemoryItemsCompanion extends UpdateCompanion<MemoryItem> {
  final Value<String> id;
  final Value<String> memoryType;
  final Value<String> content;
  final Value<String?> sourceMessageId;
  final Value<double> confidence;
  final Value<String> createdAt;
  final Value<String?> lastUsedAt;
  final Value<String?> expiresAt;
  final Value<String> status;
  final Value<int> rowid;
  const MemoryItemsCompanion({
    this.id = const Value.absent(),
    this.memoryType = const Value.absent(),
    this.content = const Value.absent(),
    this.sourceMessageId = const Value.absent(),
    this.confidence = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemoryItemsCompanion.insert({
    required String id,
    required String memoryType,
    required String content,
    this.sourceMessageId = const Value.absent(),
    required double confidence,
    required String createdAt,
    this.lastUsedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        memoryType = Value(memoryType),
        content = Value(content),
        confidence = Value(confidence),
        createdAt = Value(createdAt);
  static Insertable<MemoryItem> custom({
    Expression<String>? id,
    Expression<String>? memoryType,
    Expression<String>? content,
    Expression<String>? sourceMessageId,
    Expression<double>? confidence,
    Expression<String>? createdAt,
    Expression<String>? lastUsedAt,
    Expression<String>? expiresAt,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (memoryType != null) 'memory_type': memoryType,
      if (content != null) 'content': content,
      if (sourceMessageId != null) 'source_message_id': sourceMessageId,
      if (confidence != null) 'confidence': confidence,
      if (createdAt != null) 'created_at': createdAt,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemoryItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? memoryType,
      Value<String>? content,
      Value<String?>? sourceMessageId,
      Value<double>? confidence,
      Value<String>? createdAt,
      Value<String?>? lastUsedAt,
      Value<String?>? expiresAt,
      Value<String>? status,
      Value<int>? rowid}) {
    return MemoryItemsCompanion(
      id: id ?? this.id,
      memoryType: memoryType ?? this.memoryType,
      content: content ?? this.content,
      sourceMessageId: sourceMessageId ?? this.sourceMessageId,
      confidence: confidence ?? this.confidence,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (memoryType.present) {
      map['memory_type'] = Variable<String>(memoryType.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (sourceMessageId.present) {
      map['source_message_id'] = Variable<String>(sourceMessageId.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<String>(lastUsedAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<String>(expiresAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoryItemsCompanion(')
          ..write('id: $id, ')
          ..write('memoryType: $memoryType, ')
          ..write('content: $content, ')
          ..write('sourceMessageId: $sourceMessageId, ')
          ..write('confidence: $confidence, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CaptureSessionsTable captureSessions =
      $CaptureSessionsTable(this);
  late final $EntriesTable entries = $EntriesTable(this);
  late final $TodosTable todos = $TodosTable(this);
  late final $IdeasTable ideas = $IdeasTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $EntryTagsTable entryTags = $EntryTagsTable(this);
  late final $LedgerTransactionsTable ledgerTransactions =
      $LedgerTransactionsTable(this);
  late final $AgentThreadsTable agentThreads = $AgentThreadsTable(this);
  late final $AgentMessagesTable agentMessages = $AgentMessagesTable(this);
  late final $AgentRunsTable agentRuns = $AgentRunsTable(this);
  late final $AgentToolCallsTable agentToolCalls = $AgentToolCallsTable(this);
  late final $AgentConfirmationsTable agentConfirmations =
      $AgentConfirmationsTable(this);
  late final $MemoryItemsTable memoryItems = $MemoryItemsTable(this);
  late final EntryDao entryDao = EntryDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        captureSessions,
        entries,
        todos,
        ideas,
        tags,
        entryTags,
        ledgerTransactions,
        agentThreads,
        agentMessages,
        agentRuns,
        agentToolCalls,
        agentConfirmations,
        memoryItems
      ];
}

typedef $$CaptureSessionsTableCreateCompanionBuilder = CaptureSessionsCompanion
    Function({
  required String id,
  required String rawText,
  required String status,
  required String createdAt,
  required String updatedAt,
  Value<String?> conversationJson,
  Value<String?> activeDraftJson,
  Value<String?> recoverableDraftJson,
  Value<String?> expiresAt,
  Value<int> rowid,
});
typedef $$CaptureSessionsTableUpdateCompanionBuilder = CaptureSessionsCompanion
    Function({
  Value<String> id,
  Value<String> rawText,
  Value<String> status,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<String?> conversationJson,
  Value<String?> activeDraftJson,
  Value<String?> recoverableDraftJson,
  Value<String?> expiresAt,
  Value<int> rowid,
});

class $$CaptureSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $CaptureSessionsTable> {
  $$CaptureSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawText => $composableBuilder(
      column: $table.rawText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get conversationJson => $composableBuilder(
      column: $table.conversationJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get activeDraftJson => $composableBuilder(
      column: $table.activeDraftJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recoverableDraftJson => $composableBuilder(
      column: $table.recoverableDraftJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnFilters(column));
}

class $$CaptureSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CaptureSessionsTable> {
  $$CaptureSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawText => $composableBuilder(
      column: $table.rawText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get conversationJson => $composableBuilder(
      column: $table.conversationJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activeDraftJson => $composableBuilder(
      column: $table.activeDraftJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recoverableDraftJson => $composableBuilder(
      column: $table.recoverableDraftJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnOrderings(column));
}

class $$CaptureSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CaptureSessionsTable> {
  $$CaptureSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get conversationJson => $composableBuilder(
      column: $table.conversationJson, builder: (column) => column);

  GeneratedColumn<String> get activeDraftJson => $composableBuilder(
      column: $table.activeDraftJson, builder: (column) => column);

  GeneratedColumn<String> get recoverableDraftJson => $composableBuilder(
      column: $table.recoverableDraftJson, builder: (column) => column);

  GeneratedColumn<String> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$CaptureSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CaptureSessionsTable,
    CaptureSession,
    $$CaptureSessionsTableFilterComposer,
    $$CaptureSessionsTableOrderingComposer,
    $$CaptureSessionsTableAnnotationComposer,
    $$CaptureSessionsTableCreateCompanionBuilder,
    $$CaptureSessionsTableUpdateCompanionBuilder,
    (
      CaptureSession,
      BaseReferences<_$AppDatabase, $CaptureSessionsTable, CaptureSession>
    ),
    CaptureSession,
    PrefetchHooks Function()> {
  $$CaptureSessionsTableTableManager(
      _$AppDatabase db, $CaptureSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CaptureSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CaptureSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CaptureSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> rawText = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<String?> conversationJson = const Value.absent(),
            Value<String?> activeDraftJson = const Value.absent(),
            Value<String?> recoverableDraftJson = const Value.absent(),
            Value<String?> expiresAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CaptureSessionsCompanion(
            id: id,
            rawText: rawText,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            conversationJson: conversationJson,
            activeDraftJson: activeDraftJson,
            recoverableDraftJson: recoverableDraftJson,
            expiresAt: expiresAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String rawText,
            required String status,
            required String createdAt,
            required String updatedAt,
            Value<String?> conversationJson = const Value.absent(),
            Value<String?> activeDraftJson = const Value.absent(),
            Value<String?> recoverableDraftJson = const Value.absent(),
            Value<String?> expiresAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CaptureSessionsCompanion.insert(
            id: id,
            rawText: rawText,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            conversationJson: conversationJson,
            activeDraftJson: activeDraftJson,
            recoverableDraftJson: recoverableDraftJson,
            expiresAt: expiresAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CaptureSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CaptureSessionsTable,
    CaptureSession,
    $$CaptureSessionsTableFilterComposer,
    $$CaptureSessionsTableOrderingComposer,
    $$CaptureSessionsTableAnnotationComposer,
    $$CaptureSessionsTableCreateCompanionBuilder,
    $$CaptureSessionsTableUpdateCompanionBuilder,
    (
      CaptureSession,
      BaseReferences<_$AppDatabase, $CaptureSessionsTable, CaptureSession>
    ),
    CaptureSession,
    PrefetchHooks Function()>;
typedef $$EntriesTableCreateCompanionBuilder = EntriesCompanion Function({
  required String id,
  required String entryType,
  required String title,
  required String rawText,
  required String normalizedText,
  required String createdAt,
  required String updatedAt,
  Value<int> rowid,
});
typedef $$EntriesTableUpdateCompanionBuilder = EntriesCompanion Function({
  Value<String> id,
  Value<String> entryType,
  Value<String> title,
  Value<String> rawText,
  Value<String> normalizedText,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> rowid,
});

class $$EntriesTableFilterComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entryType => $composableBuilder(
      column: $table.entryType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawText => $composableBuilder(
      column: $table.rawText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get normalizedText => $composableBuilder(
      column: $table.normalizedText,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$EntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entryType => $composableBuilder(
      column: $table.entryType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawText => $composableBuilder(
      column: $table.rawText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get normalizedText => $composableBuilder(
      column: $table.normalizedText,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$EntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntriesTable> {
  $$EntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get entryType =>
      $composableBuilder(column: $table.entryType, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);

  GeneratedColumn<String> get normalizedText => $composableBuilder(
      column: $table.normalizedText, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$EntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EntriesTable,
    Entry,
    $$EntriesTableFilterComposer,
    $$EntriesTableOrderingComposer,
    $$EntriesTableAnnotationComposer,
    $$EntriesTableCreateCompanionBuilder,
    $$EntriesTableUpdateCompanionBuilder,
    (Entry, BaseReferences<_$AppDatabase, $EntriesTable, Entry>),
    Entry,
    PrefetchHooks Function()> {
  $$EntriesTableTableManager(_$AppDatabase db, $EntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> entryType = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> rawText = const Value.absent(),
            Value<String> normalizedText = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EntriesCompanion(
            id: id,
            entryType: entryType,
            title: title,
            rawText: rawText,
            normalizedText: normalizedText,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String entryType,
            required String title,
            required String rawText,
            required String normalizedText,
            required String createdAt,
            required String updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              EntriesCompanion.insert(
            id: id,
            entryType: entryType,
            title: title,
            rawText: rawText,
            normalizedText: normalizedText,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EntriesTable,
    Entry,
    $$EntriesTableFilterComposer,
    $$EntriesTableOrderingComposer,
    $$EntriesTableAnnotationComposer,
    $$EntriesTableCreateCompanionBuilder,
    $$EntriesTableUpdateCompanionBuilder,
    (Entry, BaseReferences<_$AppDatabase, $EntriesTable, Entry>),
    Entry,
    PrefetchHooks Function()>;
typedef $$TodosTableCreateCompanionBuilder = TodosCompanion Function({
  required String entryId,
  Value<String?> startAt,
  Value<String?> endAt,
  Value<String?> location,
  Value<String?> topic,
  Value<String?> reminderAt,
  Value<String> status,
  Value<int> rowid,
});
typedef $$TodosTableUpdateCompanionBuilder = TodosCompanion Function({
  Value<String> entryId,
  Value<String?> startAt,
  Value<String?> endAt,
  Value<String?> location,
  Value<String?> topic,
  Value<String?> reminderAt,
  Value<String> status,
  Value<int> rowid,
});

class $$TodosTableFilterComposer extends Composer<_$AppDatabase, $TodosTable> {
  $$TodosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entryId => $composableBuilder(
      column: $table.entryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startAt => $composableBuilder(
      column: $table.startAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get endAt => $composableBuilder(
      column: $table.endAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get topic => $composableBuilder(
      column: $table.topic, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reminderAt => $composableBuilder(
      column: $table.reminderAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
}

class $$TodosTableOrderingComposer
    extends Composer<_$AppDatabase, $TodosTable> {
  $$TodosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entryId => $composableBuilder(
      column: $table.entryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startAt => $composableBuilder(
      column: $table.startAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get endAt => $composableBuilder(
      column: $table.endAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get location => $composableBuilder(
      column: $table.location, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get topic => $composableBuilder(
      column: $table.topic, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reminderAt => $composableBuilder(
      column: $table.reminderAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$TodosTableAnnotationComposer
    extends Composer<_$AppDatabase, $TodosTable> {
  $$TodosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => column);

  GeneratedColumn<String> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => column);

  GeneratedColumn<String> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get topic =>
      $composableBuilder(column: $table.topic, builder: (column) => column);

  GeneratedColumn<String> get reminderAt => $composableBuilder(
      column: $table.reminderAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$TodosTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TodosTable,
    Todo,
    $$TodosTableFilterComposer,
    $$TodosTableOrderingComposer,
    $$TodosTableAnnotationComposer,
    $$TodosTableCreateCompanionBuilder,
    $$TodosTableUpdateCompanionBuilder,
    (Todo, BaseReferences<_$AppDatabase, $TodosTable, Todo>),
    Todo,
    PrefetchHooks Function()> {
  $$TodosTableTableManager(_$AppDatabase db, $TodosTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TodosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TodosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TodosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> entryId = const Value.absent(),
            Value<String?> startAt = const Value.absent(),
            Value<String?> endAt = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<String?> topic = const Value.absent(),
            Value<String?> reminderAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TodosCompanion(
            entryId: entryId,
            startAt: startAt,
            endAt: endAt,
            location: location,
            topic: topic,
            reminderAt: reminderAt,
            status: status,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String entryId,
            Value<String?> startAt = const Value.absent(),
            Value<String?> endAt = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<String?> topic = const Value.absent(),
            Value<String?> reminderAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TodosCompanion.insert(
            entryId: entryId,
            startAt: startAt,
            endAt: endAt,
            location: location,
            topic: topic,
            reminderAt: reminderAt,
            status: status,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TodosTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TodosTable,
    Todo,
    $$TodosTableFilterComposer,
    $$TodosTableOrderingComposer,
    $$TodosTableAnnotationComposer,
    $$TodosTableCreateCompanionBuilder,
    $$TodosTableUpdateCompanionBuilder,
    (Todo, BaseReferences<_$AppDatabase, $TodosTable, Todo>),
    Todo,
    PrefetchHooks Function()>;
typedef $$IdeasTableCreateCompanionBuilder = IdeasCompanion Function({
  required String entryId,
  required String summary,
  Value<String?> sourceHint,
  Value<bool> favorite,
  Value<int> rowid,
});
typedef $$IdeasTableUpdateCompanionBuilder = IdeasCompanion Function({
  Value<String> entryId,
  Value<String> summary,
  Value<String?> sourceHint,
  Value<bool> favorite,
  Value<int> rowid,
});

class $$IdeasTableFilterComposer extends Composer<_$AppDatabase, $IdeasTable> {
  $$IdeasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entryId => $composableBuilder(
      column: $table.entryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceHint => $composableBuilder(
      column: $table.sourceHint, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get favorite => $composableBuilder(
      column: $table.favorite, builder: (column) => ColumnFilters(column));
}

class $$IdeasTableOrderingComposer
    extends Composer<_$AppDatabase, $IdeasTable> {
  $$IdeasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entryId => $composableBuilder(
      column: $table.entryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceHint => $composableBuilder(
      column: $table.sourceHint, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get favorite => $composableBuilder(
      column: $table.favorite, builder: (column) => ColumnOrderings(column));
}

class $$IdeasTableAnnotationComposer
    extends Composer<_$AppDatabase, $IdeasTable> {
  $$IdeasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get sourceHint => $composableBuilder(
      column: $table.sourceHint, builder: (column) => column);

  GeneratedColumn<bool> get favorite =>
      $composableBuilder(column: $table.favorite, builder: (column) => column);
}

class $$IdeasTableTableManager extends RootTableManager<
    _$AppDatabase,
    $IdeasTable,
    Idea,
    $$IdeasTableFilterComposer,
    $$IdeasTableOrderingComposer,
    $$IdeasTableAnnotationComposer,
    $$IdeasTableCreateCompanionBuilder,
    $$IdeasTableUpdateCompanionBuilder,
    (Idea, BaseReferences<_$AppDatabase, $IdeasTable, Idea>),
    Idea,
    PrefetchHooks Function()> {
  $$IdeasTableTableManager(_$AppDatabase db, $IdeasTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IdeasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IdeasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IdeasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> entryId = const Value.absent(),
            Value<String> summary = const Value.absent(),
            Value<String?> sourceHint = const Value.absent(),
            Value<bool> favorite = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              IdeasCompanion(
            entryId: entryId,
            summary: summary,
            sourceHint: sourceHint,
            favorite: favorite,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String entryId,
            required String summary,
            Value<String?> sourceHint = const Value.absent(),
            Value<bool> favorite = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              IdeasCompanion.insert(
            entryId: entryId,
            summary: summary,
            sourceHint: sourceHint,
            favorite: favorite,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$IdeasTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $IdeasTable,
    Idea,
    $$IdeasTableFilterComposer,
    $$IdeasTableOrderingComposer,
    $$IdeasTableAnnotationComposer,
    $$IdeasTableCreateCompanionBuilder,
    $$IdeasTableUpdateCompanionBuilder,
    (Idea, BaseReferences<_$AppDatabase, $IdeasTable, Idea>),
    Idea,
    PrefetchHooks Function()>;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  required String id,
  required String name,
  Value<int> rowid,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> rowid,
});

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$TagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TagsTable,
    Tag,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (Tag, BaseReferences<_$AppDatabase, $TagsTable, Tag>),
    Tag,
    PrefetchHooks Function()> {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsCompanion(
            id: id,
            name: name,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<int> rowid = const Value.absent(),
          }) =>
              TagsCompanion.insert(
            id: id,
            name: name,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TagsTable,
    Tag,
    $$TagsTableFilterComposer,
    $$TagsTableOrderingComposer,
    $$TagsTableAnnotationComposer,
    $$TagsTableCreateCompanionBuilder,
    $$TagsTableUpdateCompanionBuilder,
    (Tag, BaseReferences<_$AppDatabase, $TagsTable, Tag>),
    Tag,
    PrefetchHooks Function()>;
typedef $$EntryTagsTableCreateCompanionBuilder = EntryTagsCompanion Function({
  required String entryId,
  required String tagId,
  Value<int> rowid,
});
typedef $$EntryTagsTableUpdateCompanionBuilder = EntryTagsCompanion Function({
  Value<String> entryId,
  Value<String> tagId,
  Value<int> rowid,
});

class $$EntryTagsTableFilterComposer
    extends Composer<_$AppDatabase, $EntryTagsTable> {
  $$EntryTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entryId => $composableBuilder(
      column: $table.entryId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagId => $composableBuilder(
      column: $table.tagId, builder: (column) => ColumnFilters(column));
}

class $$EntryTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $EntryTagsTable> {
  $$EntryTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entryId => $composableBuilder(
      column: $table.entryId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagId => $composableBuilder(
      column: $table.tagId, builder: (column) => ColumnOrderings(column));
}

class $$EntryTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntryTagsTable> {
  $$EntryTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => column);

  GeneratedColumn<String> get tagId =>
      $composableBuilder(column: $table.tagId, builder: (column) => column);
}

class $$EntryTagsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $EntryTagsTable,
    EntryTag,
    $$EntryTagsTableFilterComposer,
    $$EntryTagsTableOrderingComposer,
    $$EntryTagsTableAnnotationComposer,
    $$EntryTagsTableCreateCompanionBuilder,
    $$EntryTagsTableUpdateCompanionBuilder,
    (EntryTag, BaseReferences<_$AppDatabase, $EntryTagsTable, EntryTag>),
    EntryTag,
    PrefetchHooks Function()> {
  $$EntryTagsTableTableManager(_$AppDatabase db, $EntryTagsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntryTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntryTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntryTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> entryId = const Value.absent(),
            Value<String> tagId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EntryTagsCompanion(
            entryId: entryId,
            tagId: tagId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String entryId,
            required String tagId,
            Value<int> rowid = const Value.absent(),
          }) =>
              EntryTagsCompanion.insert(
            entryId: entryId,
            tagId: tagId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$EntryTagsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $EntryTagsTable,
    EntryTag,
    $$EntryTagsTableFilterComposer,
    $$EntryTagsTableOrderingComposer,
    $$EntryTagsTableAnnotationComposer,
    $$EntryTagsTableCreateCompanionBuilder,
    $$EntryTagsTableUpdateCompanionBuilder,
    (EntryTag, BaseReferences<_$AppDatabase, $EntryTagsTable, EntryTag>),
    EntryTag,
    PrefetchHooks Function()>;
typedef $$LedgerTransactionsTableCreateCompanionBuilder
    = LedgerTransactionsCompanion Function({
  required String id,
  required String direction,
  required int amountCents,
  required String categoryCode,
  Value<String> note,
  required String occurredAt,
  required String source,
  required String rawText,
  required String createdAt,
  required String updatedAt,
  Value<int> rowid,
});
typedef $$LedgerTransactionsTableUpdateCompanionBuilder
    = LedgerTransactionsCompanion Function({
  Value<String> id,
  Value<String> direction,
  Value<int> amountCents,
  Value<String> categoryCode,
  Value<String> note,
  Value<String> occurredAt,
  Value<String> source,
  Value<String> rawText,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> rowid,
});

class $$LedgerTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $LedgerTransactionsTable> {
  $$LedgerTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get direction => $composableBuilder(
      column: $table.direction, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get amountCents => $composableBuilder(
      column: $table.amountCents, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoryCode => $composableBuilder(
      column: $table.categoryCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawText => $composableBuilder(
      column: $table.rawText, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LedgerTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LedgerTransactionsTable> {
  $$LedgerTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get direction => $composableBuilder(
      column: $table.direction, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get amountCents => $composableBuilder(
      column: $table.amountCents, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoryCode => $composableBuilder(
      column: $table.categoryCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawText => $composableBuilder(
      column: $table.rawText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LedgerTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LedgerTransactionsTable> {
  $$LedgerTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<int> get amountCents => $composableBuilder(
      column: $table.amountCents, builder: (column) => column);

  GeneratedColumn<String> get categoryCode => $composableBuilder(
      column: $table.categoryCode, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get occurredAt => $composableBuilder(
      column: $table.occurredAt, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get rawText =>
      $composableBuilder(column: $table.rawText, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LedgerTransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LedgerTransactionsTable,
    LedgerTransaction,
    $$LedgerTransactionsTableFilterComposer,
    $$LedgerTransactionsTableOrderingComposer,
    $$LedgerTransactionsTableAnnotationComposer,
    $$LedgerTransactionsTableCreateCompanionBuilder,
    $$LedgerTransactionsTableUpdateCompanionBuilder,
    (
      LedgerTransaction,
      BaseReferences<_$AppDatabase, $LedgerTransactionsTable, LedgerTransaction>
    ),
    LedgerTransaction,
    PrefetchHooks Function()> {
  $$LedgerTransactionsTableTableManager(
      _$AppDatabase db, $LedgerTransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LedgerTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LedgerTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LedgerTransactionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> direction = const Value.absent(),
            Value<int> amountCents = const Value.absent(),
            Value<String> categoryCode = const Value.absent(),
            Value<String> note = const Value.absent(),
            Value<String> occurredAt = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String> rawText = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LedgerTransactionsCompanion(
            id: id,
            direction: direction,
            amountCents: amountCents,
            categoryCode: categoryCode,
            note: note,
            occurredAt: occurredAt,
            source: source,
            rawText: rawText,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String direction,
            required int amountCents,
            required String categoryCode,
            Value<String> note = const Value.absent(),
            required String occurredAt,
            required String source,
            required String rawText,
            required String createdAt,
            required String updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              LedgerTransactionsCompanion.insert(
            id: id,
            direction: direction,
            amountCents: amountCents,
            categoryCode: categoryCode,
            note: note,
            occurredAt: occurredAt,
            source: source,
            rawText: rawText,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LedgerTransactionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LedgerTransactionsTable,
    LedgerTransaction,
    $$LedgerTransactionsTableFilterComposer,
    $$LedgerTransactionsTableOrderingComposer,
    $$LedgerTransactionsTableAnnotationComposer,
    $$LedgerTransactionsTableCreateCompanionBuilder,
    $$LedgerTransactionsTableUpdateCompanionBuilder,
    (
      LedgerTransaction,
      BaseReferences<_$AppDatabase, $LedgerTransactionsTable, LedgerTransaction>
    ),
    LedgerTransaction,
    PrefetchHooks Function()>;
typedef $$AgentThreadsTableCreateCompanionBuilder = AgentThreadsCompanion
    Function({
  required String id,
  required String status,
  Value<String?> previousResponseId,
  Value<String?> rollingSummary,
  Value<String?> entityRefsJson,
  required String createdAt,
  required String updatedAt,
  Value<int> rowid,
});
typedef $$AgentThreadsTableUpdateCompanionBuilder = AgentThreadsCompanion
    Function({
  Value<String> id,
  Value<String> status,
  Value<String?> previousResponseId,
  Value<String?> rollingSummary,
  Value<String?> entityRefsJson,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> rowid,
});

class $$AgentThreadsTableFilterComposer
    extends Composer<_$AppDatabase, $AgentThreadsTable> {
  $$AgentThreadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get previousResponseId => $composableBuilder(
      column: $table.previousResponseId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rollingSummary => $composableBuilder(
      column: $table.rollingSummary,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityRefsJson => $composableBuilder(
      column: $table.entityRefsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$AgentThreadsTableOrderingComposer
    extends Composer<_$AppDatabase, $AgentThreadsTable> {
  $$AgentThreadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get previousResponseId => $composableBuilder(
      column: $table.previousResponseId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rollingSummary => $composableBuilder(
      column: $table.rollingSummary,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityRefsJson => $composableBuilder(
      column: $table.entityRefsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AgentThreadsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AgentThreadsTable> {
  $$AgentThreadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get previousResponseId => $composableBuilder(
      column: $table.previousResponseId, builder: (column) => column);

  GeneratedColumn<String> get rollingSummary => $composableBuilder(
      column: $table.rollingSummary, builder: (column) => column);

  GeneratedColumn<String> get entityRefsJson => $composableBuilder(
      column: $table.entityRefsJson, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AgentThreadsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AgentThreadsTable,
    AgentThread,
    $$AgentThreadsTableFilterComposer,
    $$AgentThreadsTableOrderingComposer,
    $$AgentThreadsTableAnnotationComposer,
    $$AgentThreadsTableCreateCompanionBuilder,
    $$AgentThreadsTableUpdateCompanionBuilder,
    (
      AgentThread,
      BaseReferences<_$AppDatabase, $AgentThreadsTable, AgentThread>
    ),
    AgentThread,
    PrefetchHooks Function()> {
  $$AgentThreadsTableTableManager(_$AppDatabase db, $AgentThreadsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AgentThreadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AgentThreadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AgentThreadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> previousResponseId = const Value.absent(),
            Value<String?> rollingSummary = const Value.absent(),
            Value<String?> entityRefsJson = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AgentThreadsCompanion(
            id: id,
            status: status,
            previousResponseId: previousResponseId,
            rollingSummary: rollingSummary,
            entityRefsJson: entityRefsJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String status,
            Value<String?> previousResponseId = const Value.absent(),
            Value<String?> rollingSummary = const Value.absent(),
            Value<String?> entityRefsJson = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AgentThreadsCompanion.insert(
            id: id,
            status: status,
            previousResponseId: previousResponseId,
            rollingSummary: rollingSummary,
            entityRefsJson: entityRefsJson,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AgentThreadsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AgentThreadsTable,
    AgentThread,
    $$AgentThreadsTableFilterComposer,
    $$AgentThreadsTableOrderingComposer,
    $$AgentThreadsTableAnnotationComposer,
    $$AgentThreadsTableCreateCompanionBuilder,
    $$AgentThreadsTableUpdateCompanionBuilder,
    (
      AgentThread,
      BaseReferences<_$AppDatabase, $AgentThreadsTable, AgentThread>
    ),
    AgentThread,
    PrefetchHooks Function()>;
typedef $$AgentMessagesTableCreateCompanionBuilder = AgentMessagesCompanion
    Function({
  required String id,
  required String threadId,
  required String role,
  required String content,
  required String createdAt,
  Value<int> rowid,
});
typedef $$AgentMessagesTableUpdateCompanionBuilder = AgentMessagesCompanion
    Function({
  Value<String> id,
  Value<String> threadId,
  Value<String> role,
  Value<String> content,
  Value<String> createdAt,
  Value<int> rowid,
});

class $$AgentMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $AgentMessagesTable> {
  $$AgentMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get threadId => $composableBuilder(
      column: $table.threadId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$AgentMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $AgentMessagesTable> {
  $$AgentMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get threadId => $composableBuilder(
      column: $table.threadId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$AgentMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AgentMessagesTable> {
  $$AgentMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get threadId =>
      $composableBuilder(column: $table.threadId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AgentMessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AgentMessagesTable,
    AgentMessage,
    $$AgentMessagesTableFilterComposer,
    $$AgentMessagesTableOrderingComposer,
    $$AgentMessagesTableAnnotationComposer,
    $$AgentMessagesTableCreateCompanionBuilder,
    $$AgentMessagesTableUpdateCompanionBuilder,
    (
      AgentMessage,
      BaseReferences<_$AppDatabase, $AgentMessagesTable, AgentMessage>
    ),
    AgentMessage,
    PrefetchHooks Function()> {
  $$AgentMessagesTableTableManager(_$AppDatabase db, $AgentMessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AgentMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AgentMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AgentMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> threadId = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AgentMessagesCompanion(
            id: id,
            threadId: threadId,
            role: role,
            content: content,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String threadId,
            required String role,
            required String content,
            required String createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AgentMessagesCompanion.insert(
            id: id,
            threadId: threadId,
            role: role,
            content: content,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AgentMessagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AgentMessagesTable,
    AgentMessage,
    $$AgentMessagesTableFilterComposer,
    $$AgentMessagesTableOrderingComposer,
    $$AgentMessagesTableAnnotationComposer,
    $$AgentMessagesTableCreateCompanionBuilder,
    $$AgentMessagesTableUpdateCompanionBuilder,
    (
      AgentMessage,
      BaseReferences<_$AppDatabase, $AgentMessagesTable, AgentMessage>
    ),
    AgentMessage,
    PrefetchHooks Function()>;
typedef $$AgentRunsTableCreateCompanionBuilder = AgentRunsCompanion Function({
  required String id,
  required String threadId,
  required String status,
  Value<int> modelRounds,
  Value<int> toolCalls,
  Value<String?> error,
  required String createdAt,
  required String updatedAt,
  Value<int> rowid,
});
typedef $$AgentRunsTableUpdateCompanionBuilder = AgentRunsCompanion Function({
  Value<String> id,
  Value<String> threadId,
  Value<String> status,
  Value<int> modelRounds,
  Value<int> toolCalls,
  Value<String?> error,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> rowid,
});

class $$AgentRunsTableFilterComposer
    extends Composer<_$AppDatabase, $AgentRunsTable> {
  $$AgentRunsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get threadId => $composableBuilder(
      column: $table.threadId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get modelRounds => $composableBuilder(
      column: $table.modelRounds, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get toolCalls => $composableBuilder(
      column: $table.toolCalls, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get error => $composableBuilder(
      column: $table.error, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$AgentRunsTableOrderingComposer
    extends Composer<_$AppDatabase, $AgentRunsTable> {
  $$AgentRunsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get threadId => $composableBuilder(
      column: $table.threadId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get modelRounds => $composableBuilder(
      column: $table.modelRounds, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get toolCalls => $composableBuilder(
      column: $table.toolCalls, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get error => $composableBuilder(
      column: $table.error, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AgentRunsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AgentRunsTable> {
  $$AgentRunsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get threadId =>
      $composableBuilder(column: $table.threadId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get modelRounds => $composableBuilder(
      column: $table.modelRounds, builder: (column) => column);

  GeneratedColumn<int> get toolCalls =>
      $composableBuilder(column: $table.toolCalls, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AgentRunsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AgentRunsTable,
    AgentRun,
    $$AgentRunsTableFilterComposer,
    $$AgentRunsTableOrderingComposer,
    $$AgentRunsTableAnnotationComposer,
    $$AgentRunsTableCreateCompanionBuilder,
    $$AgentRunsTableUpdateCompanionBuilder,
    (AgentRun, BaseReferences<_$AppDatabase, $AgentRunsTable, AgentRun>),
    AgentRun,
    PrefetchHooks Function()> {
  $$AgentRunsTableTableManager(_$AppDatabase db, $AgentRunsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AgentRunsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AgentRunsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AgentRunsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> threadId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> modelRounds = const Value.absent(),
            Value<int> toolCalls = const Value.absent(),
            Value<String?> error = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AgentRunsCompanion(
            id: id,
            threadId: threadId,
            status: status,
            modelRounds: modelRounds,
            toolCalls: toolCalls,
            error: error,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String threadId,
            required String status,
            Value<int> modelRounds = const Value.absent(),
            Value<int> toolCalls = const Value.absent(),
            Value<String?> error = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AgentRunsCompanion.insert(
            id: id,
            threadId: threadId,
            status: status,
            modelRounds: modelRounds,
            toolCalls: toolCalls,
            error: error,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AgentRunsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AgentRunsTable,
    AgentRun,
    $$AgentRunsTableFilterComposer,
    $$AgentRunsTableOrderingComposer,
    $$AgentRunsTableAnnotationComposer,
    $$AgentRunsTableCreateCompanionBuilder,
    $$AgentRunsTableUpdateCompanionBuilder,
    (AgentRun, BaseReferences<_$AppDatabase, $AgentRunsTable, AgentRun>),
    AgentRun,
    PrefetchHooks Function()>;
typedef $$AgentToolCallsTableCreateCompanionBuilder = AgentToolCallsCompanion
    Function({
  required String id,
  required String runId,
  required String callId,
  required String toolName,
  required String argumentsJson,
  required String riskLevel,
  required String status,
  Value<String?> resultJson,
  Value<String?> idempotencyKey,
  Value<String?> error,
  required String createdAt,
  required String updatedAt,
  Value<int> rowid,
});
typedef $$AgentToolCallsTableUpdateCompanionBuilder = AgentToolCallsCompanion
    Function({
  Value<String> id,
  Value<String> runId,
  Value<String> callId,
  Value<String> toolName,
  Value<String> argumentsJson,
  Value<String> riskLevel,
  Value<String> status,
  Value<String?> resultJson,
  Value<String?> idempotencyKey,
  Value<String?> error,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> rowid,
});

class $$AgentToolCallsTableFilterComposer
    extends Composer<_$AppDatabase, $AgentToolCallsTable> {
  $$AgentToolCallsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get runId => $composableBuilder(
      column: $table.runId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get callId => $composableBuilder(
      column: $table.callId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get toolName => $composableBuilder(
      column: $table.toolName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get argumentsJson => $composableBuilder(
      column: $table.argumentsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get riskLevel => $composableBuilder(
      column: $table.riskLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resultJson => $composableBuilder(
      column: $table.resultJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get error => $composableBuilder(
      column: $table.error, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$AgentToolCallsTableOrderingComposer
    extends Composer<_$AppDatabase, $AgentToolCallsTable> {
  $$AgentToolCallsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get runId => $composableBuilder(
      column: $table.runId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get callId => $composableBuilder(
      column: $table.callId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get toolName => $composableBuilder(
      column: $table.toolName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get argumentsJson => $composableBuilder(
      column: $table.argumentsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get riskLevel => $composableBuilder(
      column: $table.riskLevel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resultJson => $composableBuilder(
      column: $table.resultJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get error => $composableBuilder(
      column: $table.error, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$AgentToolCallsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AgentToolCallsTable> {
  $$AgentToolCallsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get runId =>
      $composableBuilder(column: $table.runId, builder: (column) => column);

  GeneratedColumn<String> get callId =>
      $composableBuilder(column: $table.callId, builder: (column) => column);

  GeneratedColumn<String> get toolName =>
      $composableBuilder(column: $table.toolName, builder: (column) => column);

  GeneratedColumn<String> get argumentsJson => $composableBuilder(
      column: $table.argumentsJson, builder: (column) => column);

  GeneratedColumn<String> get riskLevel =>
      $composableBuilder(column: $table.riskLevel, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get resultJson => $composableBuilder(
      column: $table.resultJson, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
      column: $table.idempotencyKey, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AgentToolCallsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AgentToolCallsTable,
    AgentToolCallRow,
    $$AgentToolCallsTableFilterComposer,
    $$AgentToolCallsTableOrderingComposer,
    $$AgentToolCallsTableAnnotationComposer,
    $$AgentToolCallsTableCreateCompanionBuilder,
    $$AgentToolCallsTableUpdateCompanionBuilder,
    (
      AgentToolCallRow,
      BaseReferences<_$AppDatabase, $AgentToolCallsTable, AgentToolCallRow>
    ),
    AgentToolCallRow,
    PrefetchHooks Function()> {
  $$AgentToolCallsTableTableManager(
      _$AppDatabase db, $AgentToolCallsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AgentToolCallsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AgentToolCallsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AgentToolCallsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> runId = const Value.absent(),
            Value<String> callId = const Value.absent(),
            Value<String> toolName = const Value.absent(),
            Value<String> argumentsJson = const Value.absent(),
            Value<String> riskLevel = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> resultJson = const Value.absent(),
            Value<String?> idempotencyKey = const Value.absent(),
            Value<String?> error = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AgentToolCallsCompanion(
            id: id,
            runId: runId,
            callId: callId,
            toolName: toolName,
            argumentsJson: argumentsJson,
            riskLevel: riskLevel,
            status: status,
            resultJson: resultJson,
            idempotencyKey: idempotencyKey,
            error: error,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String runId,
            required String callId,
            required String toolName,
            required String argumentsJson,
            required String riskLevel,
            required String status,
            Value<String?> resultJson = const Value.absent(),
            Value<String?> idempotencyKey = const Value.absent(),
            Value<String?> error = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AgentToolCallsCompanion.insert(
            id: id,
            runId: runId,
            callId: callId,
            toolName: toolName,
            argumentsJson: argumentsJson,
            riskLevel: riskLevel,
            status: status,
            resultJson: resultJson,
            idempotencyKey: idempotencyKey,
            error: error,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AgentToolCallsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AgentToolCallsTable,
    AgentToolCallRow,
    $$AgentToolCallsTableFilterComposer,
    $$AgentToolCallsTableOrderingComposer,
    $$AgentToolCallsTableAnnotationComposer,
    $$AgentToolCallsTableCreateCompanionBuilder,
    $$AgentToolCallsTableUpdateCompanionBuilder,
    (
      AgentToolCallRow,
      BaseReferences<_$AppDatabase, $AgentToolCallsTable, AgentToolCallRow>
    ),
    AgentToolCallRow,
    PrefetchHooks Function()>;
typedef $$AgentConfirmationsTableCreateCompanionBuilder
    = AgentConfirmationsCompanion Function({
  required String token,
  required String toolCallId,
  required String runId,
  required String toolName,
  required String argumentsJson,
  required String previewJson,
  required String responseId,
  required String status,
  Value<String?> recordVersion,
  required String expiresAt,
  required String createdAt,
  Value<int> rowid,
});
typedef $$AgentConfirmationsTableUpdateCompanionBuilder
    = AgentConfirmationsCompanion Function({
  Value<String> token,
  Value<String> toolCallId,
  Value<String> runId,
  Value<String> toolName,
  Value<String> argumentsJson,
  Value<String> previewJson,
  Value<String> responseId,
  Value<String> status,
  Value<String?> recordVersion,
  Value<String> expiresAt,
  Value<String> createdAt,
  Value<int> rowid,
});

class $$AgentConfirmationsTableFilterComposer
    extends Composer<_$AppDatabase, $AgentConfirmationsTable> {
  $$AgentConfirmationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get token => $composableBuilder(
      column: $table.token, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get toolCallId => $composableBuilder(
      column: $table.toolCallId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get runId => $composableBuilder(
      column: $table.runId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get toolName => $composableBuilder(
      column: $table.toolName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get argumentsJson => $composableBuilder(
      column: $table.argumentsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get previewJson => $composableBuilder(
      column: $table.previewJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get responseId => $composableBuilder(
      column: $table.responseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recordVersion => $composableBuilder(
      column: $table.recordVersion, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$AgentConfirmationsTableOrderingComposer
    extends Composer<_$AppDatabase, $AgentConfirmationsTable> {
  $$AgentConfirmationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get token => $composableBuilder(
      column: $table.token, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get toolCallId => $composableBuilder(
      column: $table.toolCallId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get runId => $composableBuilder(
      column: $table.runId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get toolName => $composableBuilder(
      column: $table.toolName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get argumentsJson => $composableBuilder(
      column: $table.argumentsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get previewJson => $composableBuilder(
      column: $table.previewJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get responseId => $composableBuilder(
      column: $table.responseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recordVersion => $composableBuilder(
      column: $table.recordVersion,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$AgentConfirmationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AgentConfirmationsTable> {
  $$AgentConfirmationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get token =>
      $composableBuilder(column: $table.token, builder: (column) => column);

  GeneratedColumn<String> get toolCallId => $composableBuilder(
      column: $table.toolCallId, builder: (column) => column);

  GeneratedColumn<String> get runId =>
      $composableBuilder(column: $table.runId, builder: (column) => column);

  GeneratedColumn<String> get toolName =>
      $composableBuilder(column: $table.toolName, builder: (column) => column);

  GeneratedColumn<String> get argumentsJson => $composableBuilder(
      column: $table.argumentsJson, builder: (column) => column);

  GeneratedColumn<String> get previewJson => $composableBuilder(
      column: $table.previewJson, builder: (column) => column);

  GeneratedColumn<String> get responseId => $composableBuilder(
      column: $table.responseId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get recordVersion => $composableBuilder(
      column: $table.recordVersion, builder: (column) => column);

  GeneratedColumn<String> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AgentConfirmationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AgentConfirmationsTable,
    AgentConfirmation,
    $$AgentConfirmationsTableFilterComposer,
    $$AgentConfirmationsTableOrderingComposer,
    $$AgentConfirmationsTableAnnotationComposer,
    $$AgentConfirmationsTableCreateCompanionBuilder,
    $$AgentConfirmationsTableUpdateCompanionBuilder,
    (
      AgentConfirmation,
      BaseReferences<_$AppDatabase, $AgentConfirmationsTable, AgentConfirmation>
    ),
    AgentConfirmation,
    PrefetchHooks Function()> {
  $$AgentConfirmationsTableTableManager(
      _$AppDatabase db, $AgentConfirmationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AgentConfirmationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AgentConfirmationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AgentConfirmationsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> token = const Value.absent(),
            Value<String> toolCallId = const Value.absent(),
            Value<String> runId = const Value.absent(),
            Value<String> toolName = const Value.absent(),
            Value<String> argumentsJson = const Value.absent(),
            Value<String> previewJson = const Value.absent(),
            Value<String> responseId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> recordVersion = const Value.absent(),
            Value<String> expiresAt = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AgentConfirmationsCompanion(
            token: token,
            toolCallId: toolCallId,
            runId: runId,
            toolName: toolName,
            argumentsJson: argumentsJson,
            previewJson: previewJson,
            responseId: responseId,
            status: status,
            recordVersion: recordVersion,
            expiresAt: expiresAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String token,
            required String toolCallId,
            required String runId,
            required String toolName,
            required String argumentsJson,
            required String previewJson,
            required String responseId,
            required String status,
            Value<String?> recordVersion = const Value.absent(),
            required String expiresAt,
            required String createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AgentConfirmationsCompanion.insert(
            token: token,
            toolCallId: toolCallId,
            runId: runId,
            toolName: toolName,
            argumentsJson: argumentsJson,
            previewJson: previewJson,
            responseId: responseId,
            status: status,
            recordVersion: recordVersion,
            expiresAt: expiresAt,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AgentConfirmationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AgentConfirmationsTable,
    AgentConfirmation,
    $$AgentConfirmationsTableFilterComposer,
    $$AgentConfirmationsTableOrderingComposer,
    $$AgentConfirmationsTableAnnotationComposer,
    $$AgentConfirmationsTableCreateCompanionBuilder,
    $$AgentConfirmationsTableUpdateCompanionBuilder,
    (
      AgentConfirmation,
      BaseReferences<_$AppDatabase, $AgentConfirmationsTable, AgentConfirmation>
    ),
    AgentConfirmation,
    PrefetchHooks Function()>;
typedef $$MemoryItemsTableCreateCompanionBuilder = MemoryItemsCompanion
    Function({
  required String id,
  required String memoryType,
  required String content,
  Value<String?> sourceMessageId,
  required double confidence,
  required String createdAt,
  Value<String?> lastUsedAt,
  Value<String?> expiresAt,
  Value<String> status,
  Value<int> rowid,
});
typedef $$MemoryItemsTableUpdateCompanionBuilder = MemoryItemsCompanion
    Function({
  Value<String> id,
  Value<String> memoryType,
  Value<String> content,
  Value<String?> sourceMessageId,
  Value<double> confidence,
  Value<String> createdAt,
  Value<String?> lastUsedAt,
  Value<String?> expiresAt,
  Value<String> status,
  Value<int> rowid,
});

class $$MemoryItemsTableFilterComposer
    extends Composer<_$AppDatabase, $MemoryItemsTable> {
  $$MemoryItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get memoryType => $composableBuilder(
      column: $table.memoryType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceMessageId => $composableBuilder(
      column: $table.sourceMessageId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastUsedAt => $composableBuilder(
      column: $table.lastUsedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
}

class $$MemoryItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $MemoryItemsTable> {
  $$MemoryItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get memoryType => $composableBuilder(
      column: $table.memoryType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceMessageId => $composableBuilder(
      column: $table.sourceMessageId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastUsedAt => $composableBuilder(
      column: $table.lastUsedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$MemoryItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemoryItemsTable> {
  $$MemoryItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get memoryType => $composableBuilder(
      column: $table.memoryType, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get sourceMessageId => $composableBuilder(
      column: $table.sourceMessageId, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get lastUsedAt => $composableBuilder(
      column: $table.lastUsedAt, builder: (column) => column);

  GeneratedColumn<String> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$MemoryItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MemoryItemsTable,
    MemoryItem,
    $$MemoryItemsTableFilterComposer,
    $$MemoryItemsTableOrderingComposer,
    $$MemoryItemsTableAnnotationComposer,
    $$MemoryItemsTableCreateCompanionBuilder,
    $$MemoryItemsTableUpdateCompanionBuilder,
    (MemoryItem, BaseReferences<_$AppDatabase, $MemoryItemsTable, MemoryItem>),
    MemoryItem,
    PrefetchHooks Function()> {
  $$MemoryItemsTableTableManager(_$AppDatabase db, $MemoryItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoryItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoryItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemoryItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> memoryType = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String?> sourceMessageId = const Value.absent(),
            Value<double> confidence = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String?> lastUsedAt = const Value.absent(),
            Value<String?> expiresAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MemoryItemsCompanion(
            id: id,
            memoryType: memoryType,
            content: content,
            sourceMessageId: sourceMessageId,
            confidence: confidence,
            createdAt: createdAt,
            lastUsedAt: lastUsedAt,
            expiresAt: expiresAt,
            status: status,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String memoryType,
            required String content,
            Value<String?> sourceMessageId = const Value.absent(),
            required double confidence,
            required String createdAt,
            Value<String?> lastUsedAt = const Value.absent(),
            Value<String?> expiresAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MemoryItemsCompanion.insert(
            id: id,
            memoryType: memoryType,
            content: content,
            sourceMessageId: sourceMessageId,
            confidence: confidence,
            createdAt: createdAt,
            lastUsedAt: lastUsedAt,
            expiresAt: expiresAt,
            status: status,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MemoryItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MemoryItemsTable,
    MemoryItem,
    $$MemoryItemsTableFilterComposer,
    $$MemoryItemsTableOrderingComposer,
    $$MemoryItemsTableAnnotationComposer,
    $$MemoryItemsTableCreateCompanionBuilder,
    $$MemoryItemsTableUpdateCompanionBuilder,
    (MemoryItem, BaseReferences<_$AppDatabase, $MemoryItemsTable, MemoryItem>),
    MemoryItem,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CaptureSessionsTableTableManager get captureSessions =>
      $$CaptureSessionsTableTableManager(_db, _db.captureSessions);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db, _db.entries);
  $$TodosTableTableManager get todos =>
      $$TodosTableTableManager(_db, _db.todos);
  $$IdeasTableTableManager get ideas =>
      $$IdeasTableTableManager(_db, _db.ideas);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$EntryTagsTableTableManager get entryTags =>
      $$EntryTagsTableTableManager(_db, _db.entryTags);
  $$LedgerTransactionsTableTableManager get ledgerTransactions =>
      $$LedgerTransactionsTableTableManager(_db, _db.ledgerTransactions);
  $$AgentThreadsTableTableManager get agentThreads =>
      $$AgentThreadsTableTableManager(_db, _db.agentThreads);
  $$AgentMessagesTableTableManager get agentMessages =>
      $$AgentMessagesTableTableManager(_db, _db.agentMessages);
  $$AgentRunsTableTableManager get agentRuns =>
      $$AgentRunsTableTableManager(_db, _db.agentRuns);
  $$AgentToolCallsTableTableManager get agentToolCalls =>
      $$AgentToolCallsTableTableManager(_db, _db.agentToolCalls);
  $$AgentConfirmationsTableTableManager get agentConfirmations =>
      $$AgentConfirmationsTableTableManager(_db, _db.agentConfirmations);
  $$MemoryItemsTableTableManager get memoryItems =>
      $$MemoryItemsTableTableManager(_db, _db.memoryItems);
}
