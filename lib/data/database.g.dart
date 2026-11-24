// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AdventurersTable extends Adventurers
    with TableInfo<$AdventurersTable, AdventurerRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdventurersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _identityMeta = const VerificationMeta(
    'identity',
  );
  @override
  late final GeneratedColumn<String> identity = GeneratedColumn<String>(
    'identity',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heroClassMeta = const VerificationMeta(
    'heroClass',
  );
  @override
  late final GeneratedColumn<String> heroClass = GeneratedColumn<String>(
    'hero_class',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classStatsMeta = const VerificationMeta(
    'classStats',
  );
  @override
  late final GeneratedColumn<String> classStats = GeneratedColumn<String>(
    'class_stats',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LogicalDay?, String> classSince =
      GeneratedColumn<String>(
        'class_since',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<LogicalDay?>($AdventurersTable.$converterclassSincen);
  static const VerificationMeta _classFlavorMeta = const VerificationMeta(
    'classFlavor',
  );
  @override
  late final GeneratedColumn<String> classFlavor = GeneratedColumn<String>(
    'class_flavor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _portraitIdMeta = const VerificationMeta(
    'portraitId',
  );
  @override
  late final GeneratedColumn<String> portraitId = GeneratedColumn<String>(
    'portrait_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<QuestRank, String> guildRank =
      GeneratedColumn<String>(
        'guild_rank',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('f'),
      ).withConverter<QuestRank>($AdventurersTable.$converterguildRank);
  @override
  late final GeneratedColumnWithTypeConverter<LogicalDay?, String> rankSince =
      GeneratedColumn<String>(
        'rank_since',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<LogicalDay?>($AdventurersTable.$converterrankSincen);
  @override
  late final GeneratedColumnWithTypeConverter<LogicalDay?, String> trialStart =
      GeneratedColumn<String>(
        'trial_start',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<LogicalDay?>($AdventurersTable.$convertertrialStartn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    identity,
    heroClass,
    title,
    createdAt,
    classStats,
    classSince,
    classFlavor,
    portraitId,
    guildRank,
    rankSince,
    trialStart,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'adventurers';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdventurerRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('identity')) {
      context.handle(
        _identityMeta,
        identity.isAcceptableOrUnknown(data['identity']!, _identityMeta),
      );
    }
    if (data.containsKey('hero_class')) {
      context.handle(
        _heroClassMeta,
        heroClass.isAcceptableOrUnknown(data['hero_class']!, _heroClassMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('class_stats')) {
      context.handle(
        _classStatsMeta,
        classStats.isAcceptableOrUnknown(data['class_stats']!, _classStatsMeta),
      );
    }
    if (data.containsKey('class_flavor')) {
      context.handle(
        _classFlavorMeta,
        classFlavor.isAcceptableOrUnknown(
          data['class_flavor']!,
          _classFlavorMeta,
        ),
      );
    }
    if (data.containsKey('portrait_id')) {
      context.handle(
        _portraitIdMeta,
        portraitId.isAcceptableOrUnknown(data['portrait_id']!, _portraitIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AdventurerRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdventurerRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      identity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}identity'],
      ),
      heroClass: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hero_class'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      classStats: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_stats'],
      ),
      classSince: $AdventurersTable.$converterclassSincen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}class_since'],
        ),
      ),
      classFlavor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_flavor'],
      ),
      portraitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}portrait_id'],
      ),
      guildRank: $AdventurersTable.$converterguildRank.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}guild_rank'],
        )!,
      ),
      rankSince: $AdventurersTable.$converterrankSincen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}rank_since'],
        ),
      ),
      trialStart: $AdventurersTable.$convertertrialStartn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}trial_start'],
        ),
      ),
    );
  }

  @override
  $AdventurersTable createAlias(String alias) {
    return $AdventurersTable(attachedDatabase, alias);
  }

  static TypeConverter<LogicalDay, String> $converterclassSince =
      const LogicalDayConverter();
  static TypeConverter<LogicalDay?, String?> $converterclassSincen =
      NullAwareTypeConverter.wrap($converterclassSince);
  static JsonTypeConverter2<QuestRank, String, String> $converterguildRank =
      const EnumNameConverter<QuestRank>(QuestRank.values);
  static TypeConverter<LogicalDay, String> $converterrankSince =
      const LogicalDayConverter();
  static TypeConverter<LogicalDay?, String?> $converterrankSincen =
      NullAwareTypeConverter.wrap($converterrankSince);
  static TypeConverter<LogicalDay, String> $convertertrialStart =
      const LogicalDayConverter();
  static TypeConverter<LogicalDay?, String?> $convertertrialStartn =
      NullAwareTypeConverter.wrap($convertertrialStart);
}

class AdventurerRow extends DataClass implements Insertable<AdventurerRow> {
  final int id;
  final String name;
  final String? identity;
  final String? heroClass;
  final String? title;
  final DateTime createdAt;

  /// Comma-separated `Stat` names; null until the class is appraised.
  final String? classStats;
  final LogicalDay? classSince;
  final String? classFlavor;
  final String? portraitId;
  final QuestRank guildRank;
  final LogicalDay? rankSince;
  final LogicalDay? trialStart;
  const AdventurerRow({
    required this.id,
    required this.name,
    this.identity,
    this.heroClass,
    this.title,
    required this.createdAt,
    this.classStats,
    this.classSince,
    this.classFlavor,
    this.portraitId,
    required this.guildRank,
    this.rankSince,
    this.trialStart,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || identity != null) {
      map['identity'] = Variable<String>(identity);
    }
    if (!nullToAbsent || heroClass != null) {
      map['hero_class'] = Variable<String>(heroClass);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || classStats != null) {
      map['class_stats'] = Variable<String>(classStats);
    }
    if (!nullToAbsent || classSince != null) {
      map['class_since'] = Variable<String>(
        $AdventurersTable.$converterclassSincen.toSql(classSince),
      );
    }
    if (!nullToAbsent || classFlavor != null) {
      map['class_flavor'] = Variable<String>(classFlavor);
    }
    if (!nullToAbsent || portraitId != null) {
      map['portrait_id'] = Variable<String>(portraitId);
    }
    {
      map['guild_rank'] = Variable<String>(
        $AdventurersTable.$converterguildRank.toSql(guildRank),
      );
    }
    if (!nullToAbsent || rankSince != null) {
      map['rank_since'] = Variable<String>(
        $AdventurersTable.$converterrankSincen.toSql(rankSince),
      );
    }
    if (!nullToAbsent || trialStart != null) {
      map['trial_start'] = Variable<String>(
        $AdventurersTable.$convertertrialStartn.toSql(trialStart),
      );
    }
    return map;
  }

  AdventurersCompanion toCompanion(bool nullToAbsent) {
    return AdventurersCompanion(
      id: Value(id),
      name: Value(name),
      identity: identity == null && nullToAbsent
          ? const Value.absent()
          : Value(identity),
      heroClass: heroClass == null && nullToAbsent
          ? const Value.absent()
          : Value(heroClass),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      createdAt: Value(createdAt),
      classStats: classStats == null && nullToAbsent
          ? const Value.absent()
          : Value(classStats),
      classSince: classSince == null && nullToAbsent
          ? const Value.absent()
          : Value(classSince),
      classFlavor: classFlavor == null && nullToAbsent
          ? const Value.absent()
          : Value(classFlavor),
      portraitId: portraitId == null && nullToAbsent
          ? const Value.absent()
          : Value(portraitId),
      guildRank: Value(guildRank),
      rankSince: rankSince == null && nullToAbsent
          ? const Value.absent()
          : Value(rankSince),
      trialStart: trialStart == null && nullToAbsent
          ? const Value.absent()
          : Value(trialStart),
    );
  }

  factory AdventurerRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdventurerRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      identity: serializer.fromJson<String?>(json['identity']),
      heroClass: serializer.fromJson<String?>(json['heroClass']),
      title: serializer.fromJson<String?>(json['title']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      classStats: serializer.fromJson<String?>(json['classStats']),
      classSince: serializer.fromJson<LogicalDay?>(json['classSince']),
      classFlavor: serializer.fromJson<String?>(json['classFlavor']),
      portraitId: serializer.fromJson<String?>(json['portraitId']),
      guildRank: $AdventurersTable.$converterguildRank.fromJson(
        serializer.fromJson<String>(json['guildRank']),
      ),
      rankSince: serializer.fromJson<LogicalDay?>(json['rankSince']),
      trialStart: serializer.fromJson<LogicalDay?>(json['trialStart']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'identity': serializer.toJson<String?>(identity),
      'heroClass': serializer.toJson<String?>(heroClass),
      'title': serializer.toJson<String?>(title),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'classStats': serializer.toJson<String?>(classStats),
      'classSince': serializer.toJson<LogicalDay?>(classSince),
      'classFlavor': serializer.toJson<String?>(classFlavor),
      'portraitId': serializer.toJson<String?>(portraitId),
      'guildRank': serializer.toJson<String>(
        $AdventurersTable.$converterguildRank.toJson(guildRank),
      ),
      'rankSince': serializer.toJson<LogicalDay?>(rankSince),
      'trialStart': serializer.toJson<LogicalDay?>(trialStart),
    };
  }

  AdventurerRow copyWith({
    int? id,
    String? name,
    Value<String?> identity = const Value.absent(),
    Value<String?> heroClass = const Value.absent(),
    Value<String?> title = const Value.absent(),
    DateTime? createdAt,
    Value<String?> classStats = const Value.absent(),
    Value<LogicalDay?> classSince = const Value.absent(),
    Value<String?> classFlavor = const Value.absent(),
    Value<String?> portraitId = const Value.absent(),
    QuestRank? guildRank,
    Value<LogicalDay?> rankSince = const Value.absent(),
    Value<LogicalDay?> trialStart = const Value.absent(),
  }) => AdventurerRow(
    id: id ?? this.id,
    name: name ?? this.name,
    identity: identity.present ? identity.value : this.identity,
    heroClass: heroClass.present ? heroClass.value : this.heroClass,
    title: title.present ? title.value : this.title,
    createdAt: createdAt ?? this.createdAt,
    classStats: classStats.present ? classStats.value : this.classStats,
    classSince: classSince.present ? classSince.value : this.classSince,
    classFlavor: classFlavor.present ? classFlavor.value : this.classFlavor,
    portraitId: portraitId.present ? portraitId.value : this.portraitId,
    guildRank: guildRank ?? this.guildRank,
    rankSince: rankSince.present ? rankSince.value : this.rankSince,
    trialStart: trialStart.present ? trialStart.value : this.trialStart,
  );
  AdventurerRow copyWithCompanion(AdventurersCompanion data) {
    return AdventurerRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      identity: data.identity.present ? data.identity.value : this.identity,
      heroClass: data.heroClass.present ? data.heroClass.value : this.heroClass,
      title: data.title.present ? data.title.value : this.title,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      classStats: data.classStats.present
          ? data.classStats.value
          : this.classStats,
      classSince: data.classSince.present
          ? data.classSince.value
          : this.classSince,
      classFlavor: data.classFlavor.present
          ? data.classFlavor.value
          : this.classFlavor,
      portraitId: data.portraitId.present
          ? data.portraitId.value
          : this.portraitId,
      guildRank: data.guildRank.present ? data.guildRank.value : this.guildRank,
      rankSince: data.rankSince.present ? data.rankSince.value : this.rankSince,
      trialStart: data.trialStart.present
          ? data.trialStart.value
          : this.trialStart,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdventurerRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('identity: $identity, ')
          ..write('heroClass: $heroClass, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('classStats: $classStats, ')
          ..write('classSince: $classSince, ')
          ..write('classFlavor: $classFlavor, ')
          ..write('portraitId: $portraitId, ')
          ..write('guildRank: $guildRank, ')
          ..write('rankSince: $rankSince, ')
          ..write('trialStart: $trialStart')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    identity,
    heroClass,
    title,
    createdAt,
    classStats,
    classSince,
    classFlavor,
    portraitId,
    guildRank,
    rankSince,
    trialStart,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdventurerRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.identity == this.identity &&
          other.heroClass == this.heroClass &&
          other.title == this.title &&
          other.createdAt == this.createdAt &&
          other.classStats == this.classStats &&
          other.classSince == this.classSince &&
          other.classFlavor == this.classFlavor &&
          other.portraitId == this.portraitId &&
          other.guildRank == this.guildRank &&
          other.rankSince == this.rankSince &&
          other.trialStart == this.trialStart);
}

class AdventurersCompanion extends UpdateCompanion<AdventurerRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> identity;
  final Value<String?> heroClass;
  final Value<String?> title;
  final Value<DateTime> createdAt;
  final Value<String?> classStats;
  final Value<LogicalDay?> classSince;
  final Value<String?> classFlavor;
  final Value<String?> portraitId;
  final Value<QuestRank> guildRank;
  final Value<LogicalDay?> rankSince;
  final Value<LogicalDay?> trialStart;
  const AdventurersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.identity = const Value.absent(),
    this.heroClass = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.classStats = const Value.absent(),
    this.classSince = const Value.absent(),
    this.classFlavor = const Value.absent(),
    this.portraitId = const Value.absent(),
    this.guildRank = const Value.absent(),
    this.rankSince = const Value.absent(),
    this.trialStart = const Value.absent(),
  });
  AdventurersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.identity = const Value.absent(),
    this.heroClass = const Value.absent(),
    this.title = const Value.absent(),
    required DateTime createdAt,
    this.classStats = const Value.absent(),
    this.classSince = const Value.absent(),
    this.classFlavor = const Value.absent(),
    this.portraitId = const Value.absent(),
    this.guildRank = const Value.absent(),
    this.rankSince = const Value.absent(),
    this.trialStart = const Value.absent(),
  }) : name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<AdventurerRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? identity,
    Expression<String>? heroClass,
    Expression<String>? title,
    Expression<DateTime>? createdAt,
    Expression<String>? classStats,
    Expression<String>? classSince,
    Expression<String>? classFlavor,
    Expression<String>? portraitId,
    Expression<String>? guildRank,
    Expression<String>? rankSince,
    Expression<String>? trialStart,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (identity != null) 'identity': identity,
      if (heroClass != null) 'hero_class': heroClass,
      if (title != null) 'title': title,
      if (createdAt != null) 'created_at': createdAt,
      if (classStats != null) 'class_stats': classStats,
      if (classSince != null) 'class_since': classSince,
      if (classFlavor != null) 'class_flavor': classFlavor,
      if (portraitId != null) 'portrait_id': portraitId,
      if (guildRank != null) 'guild_rank': guildRank,
      if (rankSince != null) 'rank_since': rankSince,
      if (trialStart != null) 'trial_start': trialStart,
    });
  }

  AdventurersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? identity,
    Value<String?>? heroClass,
    Value<String?>? title,
    Value<DateTime>? createdAt,
    Value<String?>? classStats,
    Value<LogicalDay?>? classSince,
    Value<String?>? classFlavor,
    Value<String?>? portraitId,
    Value<QuestRank>? guildRank,
    Value<LogicalDay?>? rankSince,
    Value<LogicalDay?>? trialStart,
  }) {
    return AdventurersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      identity: identity ?? this.identity,
      heroClass: heroClass ?? this.heroClass,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      classStats: classStats ?? this.classStats,
      classSince: classSince ?? this.classSince,
      classFlavor: classFlavor ?? this.classFlavor,
      portraitId: portraitId ?? this.portraitId,
      guildRank: guildRank ?? this.guildRank,
      rankSince: rankSince ?? this.rankSince,
      trialStart: trialStart ?? this.trialStart,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (identity.present) {
      map['identity'] = Variable<String>(identity.value);
    }
    if (heroClass.present) {
      map['hero_class'] = Variable<String>(heroClass.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (classStats.present) {
      map['class_stats'] = Variable<String>(classStats.value);
    }
    if (classSince.present) {
      map['class_since'] = Variable<String>(
        $AdventurersTable.$converterclassSincen.toSql(classSince.value),
      );
    }
    if (classFlavor.present) {
      map['class_flavor'] = Variable<String>(classFlavor.value);
    }
    if (portraitId.present) {
      map['portrait_id'] = Variable<String>(portraitId.value);
    }
    if (guildRank.present) {
      map['guild_rank'] = Variable<String>(
        $AdventurersTable.$converterguildRank.toSql(guildRank.value),
      );
    }
    if (rankSince.present) {
      map['rank_since'] = Variable<String>(
        $AdventurersTable.$converterrankSincen.toSql(rankSince.value),
      );
    }
    if (trialStart.present) {
      map['trial_start'] = Variable<String>(
        $AdventurersTable.$convertertrialStartn.toSql(trialStart.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdventurersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('identity: $identity, ')
          ..write('heroClass: $heroClass, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('classStats: $classStats, ')
          ..write('classSince: $classSince, ')
          ..write('classFlavor: $classFlavor, ')
          ..write('portraitId: $portraitId, ')
          ..write('guildRank: $guildRank, ')
          ..write('rankSince: $rankSince, ')
          ..write('trialStart: $trialStart')
          ..write(')'))
        .toString();
  }
}

class $HabitsTable extends Habits with TableInfo<$HabitsTable, HabitRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<HabitKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<HabitKind>($HabitsTable.$converterkind);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<double> target = GeneratedColumn<double>(
    'target',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timesPerWeekMeta = const VerificationMeta(
    'timesPerWeek',
  );
  @override
  late final GeneratedColumn<int> timesPerWeek = GeneratedColumn<int>(
    'times_per_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(7),
  );
  static const VerificationMeta _intentionMeta = const VerificationMeta(
    'intention',
  );
  @override
  late final GeneratedColumn<String> intention = GeneratedColumn<String>(
    'intention',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LogicalDay, String> firstDay =
      GeneratedColumn<String>(
        'first_day',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LogicalDay>($HabitsTable.$converterfirstDay);
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LogicalDay?, String> cursedOn =
      GeneratedColumn<String>(
        'cursed_on',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<LogicalDay?>($HabitsTable.$convertercursedOnn);
  static const VerificationMeta _anchorHabitIdMeta = const VerificationMeta(
    'anchorHabitId',
  );
  @override
  late final GeneratedColumn<int> anchorHabitId = GeneratedColumn<int>(
    'anchor_habit_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _anchorTextMeta = const VerificationMeta(
    'anchorText',
  );
  @override
  late final GeneratedColumn<String> anchorText = GeneratedColumn<String>(
    'anchor_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    name,
    unit,
    target,
    timesPerWeek,
    intention,
    firstDay,
    createdAt,
    archivedAt,
    cursedOn,
    anchorHabitId,
    anchorText,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    }
    if (data.containsKey('times_per_week')) {
      context.handle(
        _timesPerWeekMeta,
        timesPerWeek.isAcceptableOrUnknown(
          data['times_per_week']!,
          _timesPerWeekMeta,
        ),
      );
    }
    if (data.containsKey('intention')) {
      context.handle(
        _intentionMeta,
        intention.isAcceptableOrUnknown(data['intention']!, _intentionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    if (data.containsKey('anchor_habit_id')) {
      context.handle(
        _anchorHabitIdMeta,
        anchorHabitId.isAcceptableOrUnknown(
          data['anchor_habit_id']!,
          _anchorHabitIdMeta,
        ),
      );
    }
    if (data.containsKey('anchor_text')) {
      context.handle(
        _anchorTextMeta,
        anchorText.isAcceptableOrUnknown(data['anchor_text']!, _anchorTextMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HabitRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kind: $HabitsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target'],
      ),
      timesPerWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}times_per_week'],
      )!,
      intention: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}intention'],
      ),
      firstDay: $HabitsTable.$converterfirstDay.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}first_day'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
      cursedOn: $HabitsTable.$convertercursedOnn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}cursed_on'],
        ),
      ),
      anchorHabitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}anchor_habit_id'],
      ),
      anchorText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}anchor_text'],
      ),
    );
  }

  @override
  $HabitsTable createAlias(String alias) {
    return $HabitsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<HabitKind, String, String> $converterkind =
      const EnumNameConverter<HabitKind>(HabitKind.values);
  static TypeConverter<LogicalDay, String> $converterfirstDay =
      const LogicalDayConverter();
  static TypeConverter<LogicalDay, String> $convertercursedOn =
      const LogicalDayConverter();
  static TypeConverter<LogicalDay?, String?> $convertercursedOnn =
      NullAwareTypeConverter.wrap($convertercursedOn);
}

class HabitRow extends DataClass implements Insertable<HabitRow> {
  final int id;
  final HabitKind kind;
  final String name;
  final String? unit;
  final double? target;
  final int timesPerWeek;
  final String? intention;
  final LogicalDay firstDay;
  final DateTime createdAt;
  final DateTime? archivedAt;
  final LogicalDay? cursedOn;
  final int? anchorHabitId;
  final String? anchorText;
  const HabitRow({
    required this.id,
    required this.kind,
    required this.name,
    this.unit,
    this.target,
    required this.timesPerWeek,
    this.intention,
    required this.firstDay,
    required this.createdAt,
    this.archivedAt,
    this.cursedOn,
    this.anchorHabitId,
    this.anchorText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['kind'] = Variable<String>($HabitsTable.$converterkind.toSql(kind));
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    if (!nullToAbsent || target != null) {
      map['target'] = Variable<double>(target);
    }
    map['times_per_week'] = Variable<int>(timesPerWeek);
    if (!nullToAbsent || intention != null) {
      map['intention'] = Variable<String>(intention);
    }
    {
      map['first_day'] = Variable<String>(
        $HabitsTable.$converterfirstDay.toSql(firstDay),
      );
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    if (!nullToAbsent || cursedOn != null) {
      map['cursed_on'] = Variable<String>(
        $HabitsTable.$convertercursedOnn.toSql(cursedOn),
      );
    }
    if (!nullToAbsent || anchorHabitId != null) {
      map['anchor_habit_id'] = Variable<int>(anchorHabitId);
    }
    if (!nullToAbsent || anchorText != null) {
      map['anchor_text'] = Variable<String>(anchorText);
    }
    return map;
  }

  HabitsCompanion toCompanion(bool nullToAbsent) {
    return HabitsCompanion(
      id: Value(id),
      kind: Value(kind),
      name: Value(name),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      target: target == null && nullToAbsent
          ? const Value.absent()
          : Value(target),
      timesPerWeek: Value(timesPerWeek),
      intention: intention == null && nullToAbsent
          ? const Value.absent()
          : Value(intention),
      firstDay: Value(firstDay),
      createdAt: Value(createdAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      cursedOn: cursedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(cursedOn),
      anchorHabitId: anchorHabitId == null && nullToAbsent
          ? const Value.absent()
          : Value(anchorHabitId),
      anchorText: anchorText == null && nullToAbsent
          ? const Value.absent()
          : Value(anchorText),
    );
  }

  factory HabitRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitRow(
      id: serializer.fromJson<int>(json['id']),
      kind: $HabitsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      name: serializer.fromJson<String>(json['name']),
      unit: serializer.fromJson<String?>(json['unit']),
      target: serializer.fromJson<double?>(json['target']),
      timesPerWeek: serializer.fromJson<int>(json['timesPerWeek']),
      intention: serializer.fromJson<String?>(json['intention']),
      firstDay: serializer.fromJson<LogicalDay>(json['firstDay']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
      cursedOn: serializer.fromJson<LogicalDay?>(json['cursedOn']),
      anchorHabitId: serializer.fromJson<int?>(json['anchorHabitId']),
      anchorText: serializer.fromJson<String?>(json['anchorText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(
        $HabitsTable.$converterkind.toJson(kind),
      ),
      'name': serializer.toJson<String>(name),
      'unit': serializer.toJson<String?>(unit),
      'target': serializer.toJson<double?>(target),
      'timesPerWeek': serializer.toJson<int>(timesPerWeek),
      'intention': serializer.toJson<String?>(intention),
      'firstDay': serializer.toJson<LogicalDay>(firstDay),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
      'cursedOn': serializer.toJson<LogicalDay?>(cursedOn),
      'anchorHabitId': serializer.toJson<int?>(anchorHabitId),
      'anchorText': serializer.toJson<String?>(anchorText),
    };
  }

  HabitRow copyWith({
    int? id,
    HabitKind? kind,
    String? name,
    Value<String?> unit = const Value.absent(),
    Value<double?> target = const Value.absent(),
    int? timesPerWeek,
    Value<String?> intention = const Value.absent(),
    LogicalDay? firstDay,
    DateTime? createdAt,
    Value<DateTime?> archivedAt = const Value.absent(),
    Value<LogicalDay?> cursedOn = const Value.absent(),
    Value<int?> anchorHabitId = const Value.absent(),
    Value<String?> anchorText = const Value.absent(),
  }) => HabitRow(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    name: name ?? this.name,
    unit: unit.present ? unit.value : this.unit,
    target: target.present ? target.value : this.target,
    timesPerWeek: timesPerWeek ?? this.timesPerWeek,
    intention: intention.present ? intention.value : this.intention,
    firstDay: firstDay ?? this.firstDay,
    createdAt: createdAt ?? this.createdAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    cursedOn: cursedOn.present ? cursedOn.value : this.cursedOn,
    anchorHabitId: anchorHabitId.present
        ? anchorHabitId.value
        : this.anchorHabitId,
    anchorText: anchorText.present ? anchorText.value : this.anchorText,
  );
  HabitRow copyWithCompanion(HabitsCompanion data) {
    return HabitRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      name: data.name.present ? data.name.value : this.name,
      unit: data.unit.present ? data.unit.value : this.unit,
      target: data.target.present ? data.target.value : this.target,
      timesPerWeek: data.timesPerWeek.present
          ? data.timesPerWeek.value
          : this.timesPerWeek,
      intention: data.intention.present ? data.intention.value : this.intention,
      firstDay: data.firstDay.present ? data.firstDay.value : this.firstDay,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
      cursedOn: data.cursedOn.present ? data.cursedOn.value : this.cursedOn,
      anchorHabitId: data.anchorHabitId.present
          ? data.anchorHabitId.value
          : this.anchorHabitId,
      anchorText: data.anchorText.present
          ? data.anchorText.value
          : this.anchorText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('target: $target, ')
          ..write('timesPerWeek: $timesPerWeek, ')
          ..write('intention: $intention, ')
          ..write('firstDay: $firstDay, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('cursedOn: $cursedOn, ')
          ..write('anchorHabitId: $anchorHabitId, ')
          ..write('anchorText: $anchorText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    name,
    unit,
    target,
    timesPerWeek,
    intention,
    firstDay,
    createdAt,
    archivedAt,
    cursedOn,
    anchorHabitId,
    anchorText,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.name == this.name &&
          other.unit == this.unit &&
          other.target == this.target &&
          other.timesPerWeek == this.timesPerWeek &&
          other.intention == this.intention &&
          other.firstDay == this.firstDay &&
          other.createdAt == this.createdAt &&
          other.archivedAt == this.archivedAt &&
          other.cursedOn == this.cursedOn &&
          other.anchorHabitId == this.anchorHabitId &&
          other.anchorText == this.anchorText);
}

class HabitsCompanion extends UpdateCompanion<HabitRow> {
  final Value<int> id;
  final Value<HabitKind> kind;
  final Value<String> name;
  final Value<String?> unit;
  final Value<double?> target;
  final Value<int> timesPerWeek;
  final Value<String?> intention;
  final Value<LogicalDay> firstDay;
  final Value<DateTime> createdAt;
  final Value<DateTime?> archivedAt;
  final Value<LogicalDay?> cursedOn;
  final Value<int?> anchorHabitId;
  final Value<String?> anchorText;
  const HabitsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.name = const Value.absent(),
    this.unit = const Value.absent(),
    this.target = const Value.absent(),
    this.timesPerWeek = const Value.absent(),
    this.intention = const Value.absent(),
    this.firstDay = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.cursedOn = const Value.absent(),
    this.anchorHabitId = const Value.absent(),
    this.anchorText = const Value.absent(),
  });
  HabitsCompanion.insert({
    this.id = const Value.absent(),
    required HabitKind kind,
    required String name,
    this.unit = const Value.absent(),
    this.target = const Value.absent(),
    this.timesPerWeek = const Value.absent(),
    this.intention = const Value.absent(),
    required LogicalDay firstDay,
    required DateTime createdAt,
    this.archivedAt = const Value.absent(),
    this.cursedOn = const Value.absent(),
    this.anchorHabitId = const Value.absent(),
    this.anchorText = const Value.absent(),
  }) : kind = Value(kind),
       name = Value(name),
       firstDay = Value(firstDay),
       createdAt = Value(createdAt);
  static Insertable<HabitRow> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<String>? name,
    Expression<String>? unit,
    Expression<double>? target,
    Expression<int>? timesPerWeek,
    Expression<String>? intention,
    Expression<String>? firstDay,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? archivedAt,
    Expression<String>? cursedOn,
    Expression<int>? anchorHabitId,
    Expression<String>? anchorText,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (name != null) 'name': name,
      if (unit != null) 'unit': unit,
      if (target != null) 'target': target,
      if (timesPerWeek != null) 'times_per_week': timesPerWeek,
      if (intention != null) 'intention': intention,
      if (firstDay != null) 'first_day': firstDay,
      if (createdAt != null) 'created_at': createdAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (cursedOn != null) 'cursed_on': cursedOn,
      if (anchorHabitId != null) 'anchor_habit_id': anchorHabitId,
      if (anchorText != null) 'anchor_text': anchorText,
    });
  }

  HabitsCompanion copyWith({
    Value<int>? id,
    Value<HabitKind>? kind,
    Value<String>? name,
    Value<String?>? unit,
    Value<double?>? target,
    Value<int>? timesPerWeek,
    Value<String?>? intention,
    Value<LogicalDay>? firstDay,
    Value<DateTime>? createdAt,
    Value<DateTime?>? archivedAt,
    Value<LogicalDay?>? cursedOn,
    Value<int?>? anchorHabitId,
    Value<String?>? anchorText,
  }) {
    return HabitsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      target: target ?? this.target,
      timesPerWeek: timesPerWeek ?? this.timesPerWeek,
      intention: intention ?? this.intention,
      firstDay: firstDay ?? this.firstDay,
      createdAt: createdAt ?? this.createdAt,
      archivedAt: archivedAt ?? this.archivedAt,
      cursedOn: cursedOn ?? this.cursedOn,
      anchorHabitId: anchorHabitId ?? this.anchorHabitId,
      anchorText: anchorText ?? this.anchorText,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $HabitsTable.$converterkind.toSql(kind.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (target.present) {
      map['target'] = Variable<double>(target.value);
    }
    if (timesPerWeek.present) {
      map['times_per_week'] = Variable<int>(timesPerWeek.value);
    }
    if (intention.present) {
      map['intention'] = Variable<String>(intention.value);
    }
    if (firstDay.present) {
      map['first_day'] = Variable<String>(
        $HabitsTable.$converterfirstDay.toSql(firstDay.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (cursedOn.present) {
      map['cursed_on'] = Variable<String>(
        $HabitsTable.$convertercursedOnn.toSql(cursedOn.value),
      );
    }
    if (anchorHabitId.present) {
      map['anchor_habit_id'] = Variable<int>(anchorHabitId.value);
    }
    if (anchorText.present) {
      map['anchor_text'] = Variable<String>(anchorText.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('target: $target, ')
          ..write('timesPerWeek: $timesPerWeek, ')
          ..write('intention: $intention, ')
          ..write('firstDay: $firstDay, ')
          ..write('createdAt: $createdAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('cursedOn: $cursedOn, ')
          ..write('anchorHabitId: $anchorHabitId, ')
          ..write('anchorText: $anchorText')
          ..write(')'))
        .toString();
  }
}

class $QuestsTable extends Quests with TableInfo<$QuestsTable, QuestRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<int> habitId = GeneratedColumn<int>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES habits (id)',
    ),
  );
  static const VerificationMeta _tierMeta = const VerificationMeta('tier');
  @override
  late final GeneratedColumn<int> tier = GeneratedColumn<int>(
    'tier',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  late final GeneratedColumnWithTypeConverter<QuestRank, String> rank =
      GeneratedColumn<String>(
        'rank',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<QuestRank>($QuestsTable.$converterrank);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtitleMeta = const VerificationMeta(
    'subtitle',
  );
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
    'subtitle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _flavorMeta = const VerificationMeta('flavor');
  @override
  late final GeneratedColumn<String> flavor = GeneratedColumn<String>(
    'flavor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _spriteIdMeta = const VerificationMeta(
    'spriteId',
  );
  @override
  late final GeneratedColumn<String> spriteId = GeneratedColumn<String>(
    'sprite_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('scroll'),
  );
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<double> target = GeneratedColumn<double>(
    'target',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LogicalDay, String> activeFrom =
      GeneratedColumn<String>(
        'active_from',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LogicalDay>($QuestsTable.$converteractiveFrom);
  @override
  late final GeneratedColumnWithTypeConverter<LogicalDay?, String> activeUntil =
      GeneratedColumn<String>(
        'active_until',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<LogicalDay?>($QuestsTable.$converteractiveUntiln);
  @override
  late final GeneratedColumnWithTypeConverter<Stat?, String> attribute =
      GeneratedColumn<String>(
        'attribute',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Stat?>($QuestsTable.$converterattributen);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    habitId,
    tier,
    rank,
    title,
    subtitle,
    flavor,
    spriteId,
    target,
    activeFrom,
    activeUntil,
    attribute,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quests';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuestRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('tier')) {
      context.handle(
        _tierMeta,
        tier.isAcceptableOrUnknown(data['tier']!, _tierMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('subtitle')) {
      context.handle(
        _subtitleMeta,
        subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta),
      );
    }
    if (data.containsKey('flavor')) {
      context.handle(
        _flavorMeta,
        flavor.isAcceptableOrUnknown(data['flavor']!, _flavorMeta),
      );
    }
    if (data.containsKey('sprite_id')) {
      context.handle(
        _spriteIdMeta,
        spriteId.isAcceptableOrUnknown(data['sprite_id']!, _spriteIdMeta),
      );
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuestRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}habit_id'],
      )!,
      tier: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tier'],
      )!,
      rank: $QuestsTable.$converterrank.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}rank'],
        )!,
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      subtitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtitle'],
      )!,
      flavor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flavor'],
      )!,
      spriteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sprite_id'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target'],
      ),
      activeFrom: $QuestsTable.$converteractiveFrom.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}active_from'],
        )!,
      ),
      activeUntil: $QuestsTable.$converteractiveUntiln.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}active_until'],
        ),
      ),
      attribute: $QuestsTable.$converterattributen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}attribute'],
        ),
      ),
    );
  }

  @override
  $QuestsTable createAlias(String alias) {
    return $QuestsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<QuestRank, String, String> $converterrank =
      const EnumNameConverter<QuestRank>(QuestRank.values);
  static TypeConverter<LogicalDay, String> $converteractiveFrom =
      const LogicalDayConverter();
  static TypeConverter<LogicalDay, String> $converteractiveUntil =
      const LogicalDayConverter();
  static TypeConverter<LogicalDay?, String?> $converteractiveUntiln =
      NullAwareTypeConverter.wrap($converteractiveUntil);
  static JsonTypeConverter2<Stat, String, String> $converterattribute =
      const EnumNameConverter<Stat>(Stat.values);
  static JsonTypeConverter2<Stat?, String?, String?> $converterattributen =
      JsonTypeConverter2.asNullable($converterattribute);
}

class QuestRow extends DataClass implements Insertable<QuestRow> {
  final int id;
  final int habitId;
  final int tier;
  final QuestRank rank;
  final String title;
  final String subtitle;
  final String flavor;
  final String spriteId;
  final double? target;
  final LogicalDay activeFrom;
  final LogicalDay? activeUntil;
  final Stat? attribute;
  const QuestRow({
    required this.id,
    required this.habitId,
    required this.tier,
    required this.rank,
    required this.title,
    required this.subtitle,
    required this.flavor,
    required this.spriteId,
    this.target,
    required this.activeFrom,
    this.activeUntil,
    this.attribute,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['habit_id'] = Variable<int>(habitId);
    map['tier'] = Variable<int>(tier);
    {
      map['rank'] = Variable<String>($QuestsTable.$converterrank.toSql(rank));
    }
    map['title'] = Variable<String>(title);
    map['subtitle'] = Variable<String>(subtitle);
    map['flavor'] = Variable<String>(flavor);
    map['sprite_id'] = Variable<String>(spriteId);
    if (!nullToAbsent || target != null) {
      map['target'] = Variable<double>(target);
    }
    {
      map['active_from'] = Variable<String>(
        $QuestsTable.$converteractiveFrom.toSql(activeFrom),
      );
    }
    if (!nullToAbsent || activeUntil != null) {
      map['active_until'] = Variable<String>(
        $QuestsTable.$converteractiveUntiln.toSql(activeUntil),
      );
    }
    if (!nullToAbsent || attribute != null) {
      map['attribute'] = Variable<String>(
        $QuestsTable.$converterattributen.toSql(attribute),
      );
    }
    return map;
  }

  QuestsCompanion toCompanion(bool nullToAbsent) {
    return QuestsCompanion(
      id: Value(id),
      habitId: Value(habitId),
      tier: Value(tier),
      rank: Value(rank),
      title: Value(title),
      subtitle: Value(subtitle),
      flavor: Value(flavor),
      spriteId: Value(spriteId),
      target: target == null && nullToAbsent
          ? const Value.absent()
          : Value(target),
      activeFrom: Value(activeFrom),
      activeUntil: activeUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(activeUntil),
      attribute: attribute == null && nullToAbsent
          ? const Value.absent()
          : Value(attribute),
    );
  }

  factory QuestRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestRow(
      id: serializer.fromJson<int>(json['id']),
      habitId: serializer.fromJson<int>(json['habitId']),
      tier: serializer.fromJson<int>(json['tier']),
      rank: $QuestsTable.$converterrank.fromJson(
        serializer.fromJson<String>(json['rank']),
      ),
      title: serializer.fromJson<String>(json['title']),
      subtitle: serializer.fromJson<String>(json['subtitle']),
      flavor: serializer.fromJson<String>(json['flavor']),
      spriteId: serializer.fromJson<String>(json['spriteId']),
      target: serializer.fromJson<double?>(json['target']),
      activeFrom: serializer.fromJson<LogicalDay>(json['activeFrom']),
      activeUntil: serializer.fromJson<LogicalDay?>(json['activeUntil']),
      attribute: $QuestsTable.$converterattributen.fromJson(
        serializer.fromJson<String?>(json['attribute']),
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'habitId': serializer.toJson<int>(habitId),
      'tier': serializer.toJson<int>(tier),
      'rank': serializer.toJson<String>(
        $QuestsTable.$converterrank.toJson(rank),
      ),
      'title': serializer.toJson<String>(title),
      'subtitle': serializer.toJson<String>(subtitle),
      'flavor': serializer.toJson<String>(flavor),
      'spriteId': serializer.toJson<String>(spriteId),
      'target': serializer.toJson<double?>(target),
      'activeFrom': serializer.toJson<LogicalDay>(activeFrom),
      'activeUntil': serializer.toJson<LogicalDay?>(activeUntil),
      'attribute': serializer.toJson<String?>(
        $QuestsTable.$converterattributen.toJson(attribute),
      ),
    };
  }

  QuestRow copyWith({
    int? id,
    int? habitId,
    int? tier,
    QuestRank? rank,
    String? title,
    String? subtitle,
    String? flavor,
    String? spriteId,
    Value<double?> target = const Value.absent(),
    LogicalDay? activeFrom,
    Value<LogicalDay?> activeUntil = const Value.absent(),
    Value<Stat?> attribute = const Value.absent(),
  }) => QuestRow(
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    tier: tier ?? this.tier,
    rank: rank ?? this.rank,
    title: title ?? this.title,
    subtitle: subtitle ?? this.subtitle,
    flavor: flavor ?? this.flavor,
    spriteId: spriteId ?? this.spriteId,
    target: target.present ? target.value : this.target,
    activeFrom: activeFrom ?? this.activeFrom,
    activeUntil: activeUntil.present ? activeUntil.value : this.activeUntil,
    attribute: attribute.present ? attribute.value : this.attribute,
  );
  QuestRow copyWithCompanion(QuestsCompanion data) {
    return QuestRow(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      tier: data.tier.present ? data.tier.value : this.tier,
      rank: data.rank.present ? data.rank.value : this.rank,
      title: data.title.present ? data.title.value : this.title,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      flavor: data.flavor.present ? data.flavor.value : this.flavor,
      spriteId: data.spriteId.present ? data.spriteId.value : this.spriteId,
      target: data.target.present ? data.target.value : this.target,
      activeFrom: data.activeFrom.present
          ? data.activeFrom.value
          : this.activeFrom,
      activeUntil: data.activeUntil.present
          ? data.activeUntil.value
          : this.activeUntil,
      attribute: data.attribute.present ? data.attribute.value : this.attribute,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestRow(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('tier: $tier, ')
          ..write('rank: $rank, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('flavor: $flavor, ')
          ..write('spriteId: $spriteId, ')
          ..write('target: $target, ')
          ..write('activeFrom: $activeFrom, ')
          ..write('activeUntil: $activeUntil, ')
          ..write('attribute: $attribute')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    habitId,
    tier,
    rank,
    title,
    subtitle,
    flavor,
    spriteId,
    target,
    activeFrom,
    activeUntil,
    attribute,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestRow &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.tier == this.tier &&
          other.rank == this.rank &&
          other.title == this.title &&
          other.subtitle == this.subtitle &&
          other.flavor == this.flavor &&
          other.spriteId == this.spriteId &&
          other.target == this.target &&
          other.activeFrom == this.activeFrom &&
          other.activeUntil == this.activeUntil &&
          other.attribute == this.attribute);
}

class QuestsCompanion extends UpdateCompanion<QuestRow> {
  final Value<int> id;
  final Value<int> habitId;
  final Value<int> tier;
  final Value<QuestRank> rank;
  final Value<String> title;
  final Value<String> subtitle;
  final Value<String> flavor;
  final Value<String> spriteId;
  final Value<double?> target;
  final Value<LogicalDay> activeFrom;
  final Value<LogicalDay?> activeUntil;
  final Value<Stat?> attribute;
  const QuestsCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.tier = const Value.absent(),
    this.rank = const Value.absent(),
    this.title = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.flavor = const Value.absent(),
    this.spriteId = const Value.absent(),
    this.target = const Value.absent(),
    this.activeFrom = const Value.absent(),
    this.activeUntil = const Value.absent(),
    this.attribute = const Value.absent(),
  });
  QuestsCompanion.insert({
    this.id = const Value.absent(),
    required int habitId,
    this.tier = const Value.absent(),
    required QuestRank rank,
    required String title,
    this.subtitle = const Value.absent(),
    this.flavor = const Value.absent(),
    this.spriteId = const Value.absent(),
    this.target = const Value.absent(),
    required LogicalDay activeFrom,
    this.activeUntil = const Value.absent(),
    this.attribute = const Value.absent(),
  }) : habitId = Value(habitId),
       rank = Value(rank),
       title = Value(title),
       activeFrom = Value(activeFrom);
  static Insertable<QuestRow> custom({
    Expression<int>? id,
    Expression<int>? habitId,
    Expression<int>? tier,
    Expression<String>? rank,
    Expression<String>? title,
    Expression<String>? subtitle,
    Expression<String>? flavor,
    Expression<String>? spriteId,
    Expression<double>? target,
    Expression<String>? activeFrom,
    Expression<String>? activeUntil,
    Expression<String>? attribute,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (tier != null) 'tier': tier,
      if (rank != null) 'rank': rank,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (flavor != null) 'flavor': flavor,
      if (spriteId != null) 'sprite_id': spriteId,
      if (target != null) 'target': target,
      if (activeFrom != null) 'active_from': activeFrom,
      if (activeUntil != null) 'active_until': activeUntil,
      if (attribute != null) 'attribute': attribute,
    });
  }

  QuestsCompanion copyWith({
    Value<int>? id,
    Value<int>? habitId,
    Value<int>? tier,
    Value<QuestRank>? rank,
    Value<String>? title,
    Value<String>? subtitle,
    Value<String>? flavor,
    Value<String>? spriteId,
    Value<double?>? target,
    Value<LogicalDay>? activeFrom,
    Value<LogicalDay?>? activeUntil,
    Value<Stat?>? attribute,
  }) {
    return QuestsCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      tier: tier ?? this.tier,
      rank: rank ?? this.rank,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      flavor: flavor ?? this.flavor,
      spriteId: spriteId ?? this.spriteId,
      target: target ?? this.target,
      activeFrom: activeFrom ?? this.activeFrom,
      activeUntil: activeUntil ?? this.activeUntil,
      attribute: attribute ?? this.attribute,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<int>(habitId.value);
    }
    if (tier.present) {
      map['tier'] = Variable<int>(tier.value);
    }
    if (rank.present) {
      map['rank'] = Variable<String>(
        $QuestsTable.$converterrank.toSql(rank.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (flavor.present) {
      map['flavor'] = Variable<String>(flavor.value);
    }
    if (spriteId.present) {
      map['sprite_id'] = Variable<String>(spriteId.value);
    }
    if (target.present) {
      map['target'] = Variable<double>(target.value);
    }
    if (activeFrom.present) {
      map['active_from'] = Variable<String>(
        $QuestsTable.$converteractiveFrom.toSql(activeFrom.value),
      );
    }
    if (activeUntil.present) {
      map['active_until'] = Variable<String>(
        $QuestsTable.$converteractiveUntiln.toSql(activeUntil.value),
      );
    }
    if (attribute.present) {
      map['attribute'] = Variable<String>(
        $QuestsTable.$converterattributen.toSql(attribute.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestsCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('tier: $tier, ')
          ..write('rank: $rank, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('flavor: $flavor, ')
          ..write('spriteId: $spriteId, ')
          ..write('target: $target, ')
          ..write('activeFrom: $activeFrom, ')
          ..write('activeUntil: $activeUntil, ')
          ..write('attribute: $attribute')
          ..write(')'))
        .toString();
  }
}

class $CheckInsTable extends CheckIns
    with TableInfo<$CheckInsTable, CheckInRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CheckInsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<int> habitId = GeneratedColumn<int>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES habits (id)',
    ),
  );
  static const VerificationMeta _questIdMeta = const VerificationMeta(
    'questId',
  );
  @override
  late final GeneratedColumn<int> questId = GeneratedColumn<int>(
    'quest_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES quests (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LogicalDay, String> day =
      GeneratedColumn<String>(
        'day',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LogicalDay>($CheckInsTable.$converterday);
  @override
  late final GeneratedColumnWithTypeConverter<CheckInOutcome, String> outcome =
      GeneratedColumn<String>(
        'outcome',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CheckInOutcome>($CheckInsTable.$converteroutcome);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _xpMeta = const VerificationMeta('xp');
  @override
  late final GeneratedColumn<int> xp = GeneratedColumn<int>(
    'xp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goldMeta = const VerificationMeta('gold');
  @override
  late final GeneratedColumn<int> gold = GeneratedColumn<int>(
    'gold',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    habitId,
    questId,
    day,
    outcome,
    amount,
    note,
    xp,
    createdAt,
    gold,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'check_ins';
  @override
  VerificationContext validateIntegrity(
    Insertable<CheckInRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('quest_id')) {
      context.handle(
        _questIdMeta,
        questId.isAcceptableOrUnknown(data['quest_id']!, _questIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('xp')) {
      context.handle(_xpMeta, xp.isAcceptableOrUnknown(data['xp']!, _xpMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('gold')) {
      context.handle(
        _goldMeta,
        gold.isAcceptableOrUnknown(data['gold']!, _goldMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {habitId, day},
  ];
  @override
  CheckInRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CheckInRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}habit_id'],
      )!,
      questId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quest_id'],
      )!,
      day: $CheckInsTable.$converterday.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}day'],
        )!,
      ),
      outcome: $CheckInsTable.$converteroutcome.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}outcome'],
        )!,
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      xp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}xp'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      gold: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gold'],
      )!,
    );
  }

  @override
  $CheckInsTable createAlias(String alias) {
    return $CheckInsTable(attachedDatabase, alias);
  }

  static TypeConverter<LogicalDay, String> $converterday =
      const LogicalDayConverter();
  static JsonTypeConverter2<CheckInOutcome, String, String> $converteroutcome =
      const EnumNameConverter<CheckInOutcome>(CheckInOutcome.values);
}

class CheckInRow extends DataClass implements Insertable<CheckInRow> {
  final int id;
  final int habitId;
  final int questId;
  final LogicalDay day;
  final CheckInOutcome outcome;
  final double? amount;
  final String? note;
  final int xp;
  final DateTime createdAt;
  final int gold;
  const CheckInRow({
    required this.id,
    required this.habitId,
    required this.questId,
    required this.day,
    required this.outcome,
    this.amount,
    this.note,
    required this.xp,
    required this.createdAt,
    required this.gold,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['habit_id'] = Variable<int>(habitId);
    map['quest_id'] = Variable<int>(questId);
    {
      map['day'] = Variable<String>($CheckInsTable.$converterday.toSql(day));
    }
    {
      map['outcome'] = Variable<String>(
        $CheckInsTable.$converteroutcome.toSql(outcome),
      );
    }
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<double>(amount);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['xp'] = Variable<int>(xp);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['gold'] = Variable<int>(gold);
    return map;
  }

  CheckInsCompanion toCompanion(bool nullToAbsent) {
    return CheckInsCompanion(
      id: Value(id),
      habitId: Value(habitId),
      questId: Value(questId),
      day: Value(day),
      outcome: Value(outcome),
      amount: amount == null && nullToAbsent
          ? const Value.absent()
          : Value(amount),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      xp: Value(xp),
      createdAt: Value(createdAt),
      gold: Value(gold),
    );
  }

  factory CheckInRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CheckInRow(
      id: serializer.fromJson<int>(json['id']),
      habitId: serializer.fromJson<int>(json['habitId']),
      questId: serializer.fromJson<int>(json['questId']),
      day: serializer.fromJson<LogicalDay>(json['day']),
      outcome: $CheckInsTable.$converteroutcome.fromJson(
        serializer.fromJson<String>(json['outcome']),
      ),
      amount: serializer.fromJson<double?>(json['amount']),
      note: serializer.fromJson<String?>(json['note']),
      xp: serializer.fromJson<int>(json['xp']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      gold: serializer.fromJson<int>(json['gold']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'habitId': serializer.toJson<int>(habitId),
      'questId': serializer.toJson<int>(questId),
      'day': serializer.toJson<LogicalDay>(day),
      'outcome': serializer.toJson<String>(
        $CheckInsTable.$converteroutcome.toJson(outcome),
      ),
      'amount': serializer.toJson<double?>(amount),
      'note': serializer.toJson<String?>(note),
      'xp': serializer.toJson<int>(xp),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'gold': serializer.toJson<int>(gold),
    };
  }

  CheckInRow copyWith({
    int? id,
    int? habitId,
    int? questId,
    LogicalDay? day,
    CheckInOutcome? outcome,
    Value<double?> amount = const Value.absent(),
    Value<String?> note = const Value.absent(),
    int? xp,
    DateTime? createdAt,
    int? gold,
  }) => CheckInRow(
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    questId: questId ?? this.questId,
    day: day ?? this.day,
    outcome: outcome ?? this.outcome,
    amount: amount.present ? amount.value : this.amount,
    note: note.present ? note.value : this.note,
    xp: xp ?? this.xp,
    createdAt: createdAt ?? this.createdAt,
    gold: gold ?? this.gold,
  );
  CheckInRow copyWithCompanion(CheckInsCompanion data) {
    return CheckInRow(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      questId: data.questId.present ? data.questId.value : this.questId,
      day: data.day.present ? data.day.value : this.day,
      outcome: data.outcome.present ? data.outcome.value : this.outcome,
      amount: data.amount.present ? data.amount.value : this.amount,
      note: data.note.present ? data.note.value : this.note,
      xp: data.xp.present ? data.xp.value : this.xp,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      gold: data.gold.present ? data.gold.value : this.gold,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CheckInRow(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('questId: $questId, ')
          ..write('day: $day, ')
          ..write('outcome: $outcome, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('xp: $xp, ')
          ..write('createdAt: $createdAt, ')
          ..write('gold: $gold')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    habitId,
    questId,
    day,
    outcome,
    amount,
    note,
    xp,
    createdAt,
    gold,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CheckInRow &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.questId == this.questId &&
          other.day == this.day &&
          other.outcome == this.outcome &&
          other.amount == this.amount &&
          other.note == this.note &&
          other.xp == this.xp &&
          other.createdAt == this.createdAt &&
          other.gold == this.gold);
}

class CheckInsCompanion extends UpdateCompanion<CheckInRow> {
  final Value<int> id;
  final Value<int> habitId;
  final Value<int> questId;
  final Value<LogicalDay> day;
  final Value<CheckInOutcome> outcome;
  final Value<double?> amount;
  final Value<String?> note;
  final Value<int> xp;
  final Value<DateTime> createdAt;
  final Value<int> gold;
  const CheckInsCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.questId = const Value.absent(),
    this.day = const Value.absent(),
    this.outcome = const Value.absent(),
    this.amount = const Value.absent(),
    this.note = const Value.absent(),
    this.xp = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.gold = const Value.absent(),
  });
  CheckInsCompanion.insert({
    this.id = const Value.absent(),
    required int habitId,
    required int questId,
    required LogicalDay day,
    required CheckInOutcome outcome,
    this.amount = const Value.absent(),
    this.note = const Value.absent(),
    this.xp = const Value.absent(),
    required DateTime createdAt,
    this.gold = const Value.absent(),
  }) : habitId = Value(habitId),
       questId = Value(questId),
       day = Value(day),
       outcome = Value(outcome),
       createdAt = Value(createdAt);
  static Insertable<CheckInRow> custom({
    Expression<int>? id,
    Expression<int>? habitId,
    Expression<int>? questId,
    Expression<String>? day,
    Expression<String>? outcome,
    Expression<double>? amount,
    Expression<String>? note,
    Expression<int>? xp,
    Expression<DateTime>? createdAt,
    Expression<int>? gold,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (questId != null) 'quest_id': questId,
      if (day != null) 'day': day,
      if (outcome != null) 'outcome': outcome,
      if (amount != null) 'amount': amount,
      if (note != null) 'note': note,
      if (xp != null) 'xp': xp,
      if (createdAt != null) 'created_at': createdAt,
      if (gold != null) 'gold': gold,
    });
  }

  CheckInsCompanion copyWith({
    Value<int>? id,
    Value<int>? habitId,
    Value<int>? questId,
    Value<LogicalDay>? day,
    Value<CheckInOutcome>? outcome,
    Value<double?>? amount,
    Value<String?>? note,
    Value<int>? xp,
    Value<DateTime>? createdAt,
    Value<int>? gold,
  }) {
    return CheckInsCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      questId: questId ?? this.questId,
      day: day ?? this.day,
      outcome: outcome ?? this.outcome,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      xp: xp ?? this.xp,
      createdAt: createdAt ?? this.createdAt,
      gold: gold ?? this.gold,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<int>(habitId.value);
    }
    if (questId.present) {
      map['quest_id'] = Variable<int>(questId.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(
        $CheckInsTable.$converterday.toSql(day.value),
      );
    }
    if (outcome.present) {
      map['outcome'] = Variable<String>(
        $CheckInsTable.$converteroutcome.toSql(outcome.value),
      );
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (xp.present) {
      map['xp'] = Variable<int>(xp.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (gold.present) {
      map['gold'] = Variable<int>(gold.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CheckInsCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('questId: $questId, ')
          ..write('day: $day, ')
          ..write('outcome: $outcome, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('xp: $xp, ')
          ..write('createdAt: $createdAt, ')
          ..write('gold: $gold')
          ..write(')'))
        .toString();
  }
}

class $XpEventsTable extends XpEvents
    with TableInfo<$XpEventsTable, XpEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $XpEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refIdMeta = const VerificationMeta('refId');
  @override
  late final GeneratedColumn<int> refId = GeneratedColumn<int>(
    'ref_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, amount, source, refId, at];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'xp_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<XpEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('ref_id')) {
      context.handle(
        _refIdMeta,
        refId.isAcceptableOrUnknown(data['ref_id']!, _refIdMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  XpEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return XpEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      refId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ref_id'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
    );
  }

  @override
  $XpEventsTable createAlias(String alias) {
    return $XpEventsTable(attachedDatabase, alias);
  }
}

class XpEventRow extends DataClass implements Insertable<XpEventRow> {
  final int id;
  final int amount;
  final String source;
  final int? refId;
  final DateTime at;
  const XpEventRow({
    required this.id,
    required this.amount,
    required this.source,
    this.refId,
    required this.at,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount'] = Variable<int>(amount);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || refId != null) {
      map['ref_id'] = Variable<int>(refId);
    }
    map['at'] = Variable<DateTime>(at);
    return map;
  }

  XpEventsCompanion toCompanion(bool nullToAbsent) {
    return XpEventsCompanion(
      id: Value(id),
      amount: Value(amount),
      source: Value(source),
      refId: refId == null && nullToAbsent
          ? const Value.absent()
          : Value(refId),
      at: Value(at),
    );
  }

  factory XpEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return XpEventRow(
      id: serializer.fromJson<int>(json['id']),
      amount: serializer.fromJson<int>(json['amount']),
      source: serializer.fromJson<String>(json['source']),
      refId: serializer.fromJson<int?>(json['refId']),
      at: serializer.fromJson<DateTime>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amount': serializer.toJson<int>(amount),
      'source': serializer.toJson<String>(source),
      'refId': serializer.toJson<int?>(refId),
      'at': serializer.toJson<DateTime>(at),
    };
  }

  XpEventRow copyWith({
    int? id,
    int? amount,
    String? source,
    Value<int?> refId = const Value.absent(),
    DateTime? at,
  }) => XpEventRow(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    source: source ?? this.source,
    refId: refId.present ? refId.value : this.refId,
    at: at ?? this.at,
  );
  XpEventRow copyWithCompanion(XpEventsCompanion data) {
    return XpEventRow(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      source: data.source.present ? data.source.value : this.source,
      refId: data.refId.present ? data.refId.value : this.refId,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('XpEventRow(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('source: $source, ')
          ..write('refId: $refId, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, amount, source, refId, at);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is XpEventRow &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.source == this.source &&
          other.refId == this.refId &&
          other.at == this.at);
}

class XpEventsCompanion extends UpdateCompanion<XpEventRow> {
  final Value<int> id;
  final Value<int> amount;
  final Value<String> source;
  final Value<int?> refId;
  final Value<DateTime> at;
  const XpEventsCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.source = const Value.absent(),
    this.refId = const Value.absent(),
    this.at = const Value.absent(),
  });
  XpEventsCompanion.insert({
    this.id = const Value.absent(),
    required int amount,
    required String source,
    this.refId = const Value.absent(),
    required DateTime at,
  }) : amount = Value(amount),
       source = Value(source),
       at = Value(at);
  static Insertable<XpEventRow> custom({
    Expression<int>? id,
    Expression<int>? amount,
    Expression<String>? source,
    Expression<int>? refId,
    Expression<DateTime>? at,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (source != null) 'source': source,
      if (refId != null) 'ref_id': refId,
      if (at != null) 'at': at,
    });
  }

  XpEventsCompanion copyWith({
    Value<int>? id,
    Value<int>? amount,
    Value<String>? source,
    Value<int?>? refId,
    Value<DateTime>? at,
  }) {
    return XpEventsCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      source: source ?? this.source,
      refId: refId ?? this.refId,
      at: at ?? this.at,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (refId.present) {
      map['ref_id'] = Variable<int>(refId.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('XpEventsCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('source: $source, ')
          ..write('refId: $refId, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }
}

class $GoldEventsTable extends GoldEvents
    with TableInfo<$GoldEventsTable, GoldEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoldEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _refMeta = const VerificationMeta('ref');
  @override
  late final GeneratedColumn<String> ref = GeneratedColumn<String>(
    'ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, amount, source, ref, at];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gold_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoldEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('ref')) {
      context.handle(
        _refMeta,
        ref.isAcceptableOrUnknown(data['ref']!, _refMeta),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoldEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoldEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      ref: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
    );
  }

  @override
  $GoldEventsTable createAlias(String alias) {
    return $GoldEventsTable(attachedDatabase, alias);
  }
}

class GoldEventRow extends DataClass implements Insertable<GoldEventRow> {
  final int id;
  final int amount;
  final String source;

  /// e.g. the perfect day as `yyyy-MM-dd`, or a side quest id.
  final String? ref;
  final DateTime at;
  const GoldEventRow({
    required this.id,
    required this.amount,
    required this.source,
    this.ref,
    required this.at,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount'] = Variable<int>(amount);
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || ref != null) {
      map['ref'] = Variable<String>(ref);
    }
    map['at'] = Variable<DateTime>(at);
    return map;
  }

  GoldEventsCompanion toCompanion(bool nullToAbsent) {
    return GoldEventsCompanion(
      id: Value(id),
      amount: Value(amount),
      source: Value(source),
      ref: ref == null && nullToAbsent ? const Value.absent() : Value(ref),
      at: Value(at),
    );
  }

  factory GoldEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoldEventRow(
      id: serializer.fromJson<int>(json['id']),
      amount: serializer.fromJson<int>(json['amount']),
      source: serializer.fromJson<String>(json['source']),
      ref: serializer.fromJson<String?>(json['ref']),
      at: serializer.fromJson<DateTime>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amount': serializer.toJson<int>(amount),
      'source': serializer.toJson<String>(source),
      'ref': serializer.toJson<String?>(ref),
      'at': serializer.toJson<DateTime>(at),
    };
  }

  GoldEventRow copyWith({
    int? id,
    int? amount,
    String? source,
    Value<String?> ref = const Value.absent(),
    DateTime? at,
  }) => GoldEventRow(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    source: source ?? this.source,
    ref: ref.present ? ref.value : this.ref,
    at: at ?? this.at,
  );
  GoldEventRow copyWithCompanion(GoldEventsCompanion data) {
    return GoldEventRow(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      source: data.source.present ? data.source.value : this.source,
      ref: data.ref.present ? data.ref.value : this.ref,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoldEventRow(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('source: $source, ')
          ..write('ref: $ref, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, amount, source, ref, at);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoldEventRow &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.source == this.source &&
          other.ref == this.ref &&
          other.at == this.at);
}

class GoldEventsCompanion extends UpdateCompanion<GoldEventRow> {
  final Value<int> id;
  final Value<int> amount;
  final Value<String> source;
  final Value<String?> ref;
  final Value<DateTime> at;
  const GoldEventsCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.source = const Value.absent(),
    this.ref = const Value.absent(),
    this.at = const Value.absent(),
  });
  GoldEventsCompanion.insert({
    this.id = const Value.absent(),
    required int amount,
    required String source,
    this.ref = const Value.absent(),
    required DateTime at,
  }) : amount = Value(amount),
       source = Value(source),
       at = Value(at);
  static Insertable<GoldEventRow> custom({
    Expression<int>? id,
    Expression<int>? amount,
    Expression<String>? source,
    Expression<String>? ref,
    Expression<DateTime>? at,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (source != null) 'source': source,
      if (ref != null) 'ref': ref,
      if (at != null) 'at': at,
    });
  }

  GoldEventsCompanion copyWith({
    Value<int>? id,
    Value<int>? amount,
    Value<String>? source,
    Value<String?>? ref,
    Value<DateTime>? at,
  }) {
    return GoldEventsCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      source: source ?? this.source,
      ref: ref ?? this.ref,
      at: at ?? this.at,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (ref.present) {
      map['ref'] = Variable<String>(ref.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoldEventsCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('source: $source, ')
          ..write('ref: $ref, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }
}

class $PurchasesTable extends Purchases
    with TableInfo<$PurchasesTable, PurchaseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<int> price = GeneratedColumn<int>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [itemId, price, at];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchases';
  @override
  VerificationContext validateIntegrity(
    Insertable<PurchaseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId};
  @override
  PurchaseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseRow(
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price'],
      )!,
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
    );
  }

  @override
  $PurchasesTable createAlias(String alias) {
    return $PurchasesTable(attachedDatabase, alias);
  }
}

class PurchaseRow extends DataClass implements Insertable<PurchaseRow> {
  final String itemId;
  final int price;
  final DateTime at;
  const PurchaseRow({
    required this.itemId,
    required this.price,
    required this.at,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['price'] = Variable<int>(price);
    map['at'] = Variable<DateTime>(at);
    return map;
  }

  PurchasesCompanion toCompanion(bool nullToAbsent) {
    return PurchasesCompanion(
      itemId: Value(itemId),
      price: Value(price),
      at: Value(at),
    );
  }

  factory PurchaseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseRow(
      itemId: serializer.fromJson<String>(json['itemId']),
      price: serializer.fromJson<int>(json['price']),
      at: serializer.fromJson<DateTime>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'price': serializer.toJson<int>(price),
      'at': serializer.toJson<DateTime>(at),
    };
  }

  PurchaseRow copyWith({String? itemId, int? price, DateTime? at}) =>
      PurchaseRow(
        itemId: itemId ?? this.itemId,
        price: price ?? this.price,
        at: at ?? this.at,
      );
  PurchaseRow copyWithCompanion(PurchasesCompanion data) {
    return PurchaseRow(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      price: data.price.present ? data.price.value : this.price,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseRow(')
          ..write('itemId: $itemId, ')
          ..write('price: $price, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(itemId, price, at);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseRow &&
          other.itemId == this.itemId &&
          other.price == this.price &&
          other.at == this.at);
}

class PurchasesCompanion extends UpdateCompanion<PurchaseRow> {
  final Value<String> itemId;
  final Value<int> price;
  final Value<DateTime> at;
  final Value<int> rowid;
  const PurchasesCompanion({
    this.itemId = const Value.absent(),
    this.price = const Value.absent(),
    this.at = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PurchasesCompanion.insert({
    required String itemId,
    required int price,
    required DateTime at,
    this.rowid = const Value.absent(),
  }) : itemId = Value(itemId),
       price = Value(price),
       at = Value(at);
  static Insertable<PurchaseRow> custom({
    Expression<String>? itemId,
    Expression<int>? price,
    Expression<DateTime>? at,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (price != null) 'price': price,
      if (at != null) 'at': at,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PurchasesCompanion copyWith({
    Value<String>? itemId,
    Value<int>? price,
    Value<DateTime>? at,
    Value<int>? rowid,
  }) {
    return PurchasesCompanion(
      itemId: itemId ?? this.itemId,
      price: price ?? this.price,
      at: at ?? this.at,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (price.present) {
      map['price'] = Variable<int>(price.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchasesCompanion(')
          ..write('itemId: $itemId, ')
          ..write('price: $price, ')
          ..write('at: $at, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PriceWeeksTable extends PriceWeeks
    with TableInfo<$PriceWeeksTable, PriceWeekRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PriceWeeksTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<LogicalDay, String> weekStart =
      GeneratedColumn<String>(
        'week_start',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LogicalDay>($PriceWeeksTable.$converterweekStart);
  @override
  late final GeneratedColumnWithTypeConverter<QuestRank, String> rank =
      GeneratedColumn<String>(
        'rank',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<QuestRank>($PriceWeeksTable.$converterrank);
  static const VerificationMeta _percentMeta = const VerificationMeta(
    'percent',
  );
  @override
  late final GeneratedColumn<int> percent = GeneratedColumn<int>(
    'percent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [weekStart, rank, percent];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'price_weeks';
  @override
  VerificationContext validateIntegrity(
    Insertable<PriceWeekRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('percent')) {
      context.handle(
        _percentMeta,
        percent.isAcceptableOrUnknown(data['percent']!, _percentMeta),
      );
    } else if (isInserting) {
      context.missing(_percentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {weekStart};
  @override
  PriceWeekRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PriceWeekRow(
      weekStart: $PriceWeeksTable.$converterweekStart.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}week_start'],
        )!,
      ),
      rank: $PriceWeeksTable.$converterrank.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}rank'],
        )!,
      ),
      percent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}percent'],
      )!,
    );
  }

  @override
  $PriceWeeksTable createAlias(String alias) {
    return $PriceWeeksTable(attachedDatabase, alias);
  }

  static TypeConverter<LogicalDay, String> $converterweekStart =
      const LogicalDayConverter();
  static JsonTypeConverter2<QuestRank, String, String> $converterrank =
      const EnumNameConverter<QuestRank>(QuestRank.values);
}

class PriceWeekRow extends DataClass implements Insertable<PriceWeekRow> {
  final LogicalDay weekStart;

  /// The guild rank the level was taken from.
  final QuestRank rank;
  final int percent;
  const PriceWeekRow({
    required this.weekStart,
    required this.rank,
    required this.percent,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['week_start'] = Variable<String>(
        $PriceWeeksTable.$converterweekStart.toSql(weekStart),
      );
    }
    {
      map['rank'] = Variable<String>(
        $PriceWeeksTable.$converterrank.toSql(rank),
      );
    }
    map['percent'] = Variable<int>(percent);
    return map;
  }

  PriceWeeksCompanion toCompanion(bool nullToAbsent) {
    return PriceWeeksCompanion(
      weekStart: Value(weekStart),
      rank: Value(rank),
      percent: Value(percent),
    );
  }

  factory PriceWeekRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PriceWeekRow(
      weekStart: serializer.fromJson<LogicalDay>(json['weekStart']),
      rank: $PriceWeeksTable.$converterrank.fromJson(
        serializer.fromJson<String>(json['rank']),
      ),
      percent: serializer.fromJson<int>(json['percent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'weekStart': serializer.toJson<LogicalDay>(weekStart),
      'rank': serializer.toJson<String>(
        $PriceWeeksTable.$converterrank.toJson(rank),
      ),
      'percent': serializer.toJson<int>(percent),
    };
  }

  PriceWeekRow copyWith({
    LogicalDay? weekStart,
    QuestRank? rank,
    int? percent,
  }) => PriceWeekRow(
    weekStart: weekStart ?? this.weekStart,
    rank: rank ?? this.rank,
    percent: percent ?? this.percent,
  );
  PriceWeekRow copyWithCompanion(PriceWeeksCompanion data) {
    return PriceWeekRow(
      weekStart: data.weekStart.present ? data.weekStart.value : this.weekStart,
      rank: data.rank.present ? data.rank.value : this.rank,
      percent: data.percent.present ? data.percent.value : this.percent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PriceWeekRow(')
          ..write('weekStart: $weekStart, ')
          ..write('rank: $rank, ')
          ..write('percent: $percent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(weekStart, rank, percent);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PriceWeekRow &&
          other.weekStart == this.weekStart &&
          other.rank == this.rank &&
          other.percent == this.percent);
}

class PriceWeeksCompanion extends UpdateCompanion<PriceWeekRow> {
  final Value<LogicalDay> weekStart;
  final Value<QuestRank> rank;
  final Value<int> percent;
  final Value<int> rowid;
  const PriceWeeksCompanion({
    this.weekStart = const Value.absent(),
    this.rank = const Value.absent(),
    this.percent = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PriceWeeksCompanion.insert({
    required LogicalDay weekStart,
    required QuestRank rank,
    required int percent,
    this.rowid = const Value.absent(),
  }) : weekStart = Value(weekStart),
       rank = Value(rank),
       percent = Value(percent);
  static Insertable<PriceWeekRow> custom({
    Expression<String>? weekStart,
    Expression<String>? rank,
    Expression<int>? percent,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (weekStart != null) 'week_start': weekStart,
      if (rank != null) 'rank': rank,
      if (percent != null) 'percent': percent,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PriceWeeksCompanion copyWith({
    Value<LogicalDay>? weekStart,
    Value<QuestRank>? rank,
    Value<int>? percent,
    Value<int>? rowid,
  }) {
    return PriceWeeksCompanion(
      weekStart: weekStart ?? this.weekStart,
      rank: rank ?? this.rank,
      percent: percent ?? this.percent,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (weekStart.present) {
      map['week_start'] = Variable<String>(
        $PriceWeeksTable.$converterweekStart.toSql(weekStart.value),
      );
    }
    if (rank.present) {
      map['rank'] = Variable<String>(
        $PriceWeeksTable.$converterrank.toSql(rank.value),
      );
    }
    if (percent.present) {
      map['percent'] = Variable<int>(percent.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PriceWeeksCompanion(')
          ..write('weekStart: $weekStart, ')
          ..write('rank: $rank, ')
          ..write('percent: $percent, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FocusWeeksTable extends FocusWeeks
    with TableInfo<$FocusWeeksTable, FocusWeekRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FocusWeeksTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<LogicalDay, String> weekStart =
      GeneratedColumn<String>(
        'week_start',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LogicalDay>($FocusWeeksTable.$converterweekStart);
  @override
  late final GeneratedColumnWithTypeConverter<LogicalDay, String> fromDay =
      GeneratedColumn<String>(
        'from_day',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LogicalDay>($FocusWeeksTable.$converterfromDay);
  static const VerificationMeta _dailyMinutesMeta = const VerificationMeta(
    'dailyMinutes',
  );
  @override
  late final GeneratedColumn<int> dailyMinutes = GeneratedColumn<int>(
    'daily_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capMinutesMeta = const VerificationMeta(
    'capMinutes',
  );
  @override
  late final GeneratedColumn<int> capMinutes = GeneratedColumn<int>(
    'cap_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _earnCapMinutesMeta = const VerificationMeta(
    'earnCapMinutes',
  );
  @override
  late final GeneratedColumn<int> earnCapMinutes = GeneratedColumn<int>(
    'earn_cap_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goldPerHourMeta = const VerificationMeta(
    'goldPerHour',
  );
  @override
  late final GeneratedColumn<int> goldPerHour = GeneratedColumn<int>(
    'gold_per_hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _settledAtMeta = const VerificationMeta(
    'settledAt',
  );
  @override
  late final GeneratedColumn<DateTime> settledAt = GeneratedColumn<DateTime>(
    'settled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unpaidSecondsMeta = const VerificationMeta(
    'unpaidSeconds',
  );
  @override
  late final GeneratedColumn<int> unpaidSeconds = GeneratedColumn<int>(
    'unpaid_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _penaltyMeta = const VerificationMeta(
    'penalty',
  );
  @override
  late final GeneratedColumn<int> penalty = GeneratedColumn<int>(
    'penalty',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    weekStart,
    fromDay,
    dailyMinutes,
    capMinutes,
    earnCapMinutes,
    goldPerHour,
    settledAt,
    unpaidSeconds,
    penalty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'focus_weeks';
  @override
  VerificationContext validateIntegrity(
    Insertable<FocusWeekRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('daily_minutes')) {
      context.handle(
        _dailyMinutesMeta,
        dailyMinutes.isAcceptableOrUnknown(
          data['daily_minutes']!,
          _dailyMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dailyMinutesMeta);
    }
    if (data.containsKey('cap_minutes')) {
      context.handle(
        _capMinutesMeta,
        capMinutes.isAcceptableOrUnknown(data['cap_minutes']!, _capMinutesMeta),
      );
    } else if (isInserting) {
      context.missing(_capMinutesMeta);
    }
    if (data.containsKey('earn_cap_minutes')) {
      context.handle(
        _earnCapMinutesMeta,
        earnCapMinutes.isAcceptableOrUnknown(
          data['earn_cap_minutes']!,
          _earnCapMinutesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_earnCapMinutesMeta);
    }
    if (data.containsKey('gold_per_hour')) {
      context.handle(
        _goldPerHourMeta,
        goldPerHour.isAcceptableOrUnknown(
          data['gold_per_hour']!,
          _goldPerHourMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_goldPerHourMeta);
    }
    if (data.containsKey('settled_at')) {
      context.handle(
        _settledAtMeta,
        settledAt.isAcceptableOrUnknown(data['settled_at']!, _settledAtMeta),
      );
    }
    if (data.containsKey('unpaid_seconds')) {
      context.handle(
        _unpaidSecondsMeta,
        unpaidSeconds.isAcceptableOrUnknown(
          data['unpaid_seconds']!,
          _unpaidSecondsMeta,
        ),
      );
    }
    if (data.containsKey('penalty')) {
      context.handle(
        _penaltyMeta,
        penalty.isAcceptableOrUnknown(data['penalty']!, _penaltyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {weekStart};
  @override
  FocusWeekRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FocusWeekRow(
      weekStart: $FocusWeeksTable.$converterweekStart.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}week_start'],
        )!,
      ),
      fromDay: $FocusWeeksTable.$converterfromDay.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}from_day'],
        )!,
      ),
      dailyMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daily_minutes'],
      )!,
      capMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cap_minutes'],
      )!,
      earnCapMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}earn_cap_minutes'],
      )!,
      goldPerHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}gold_per_hour'],
      )!,
      settledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}settled_at'],
      ),
      unpaidSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unpaid_seconds'],
      ),
      penalty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}penalty'],
      ),
    );
  }

  @override
  $FocusWeeksTable createAlias(String alias) {
    return $FocusWeeksTable(attachedDatabase, alias);
  }

  static TypeConverter<LogicalDay, String> $converterweekStart =
      const LogicalDayConverter();
  static TypeConverter<LogicalDay, String> $converterfromDay =
      const LogicalDayConverter();
}

class FocusWeekRow extends DataClass implements Insertable<FocusWeekRow> {
  final LogicalDay weekStart;

  /// No debt is counted before this day: the week's first day, or the day
  /// focus was switched on.
  final LogicalDay fromDay;
  final int dailyMinutes;
  final int capMinutes;
  final int earnCapMinutes;
  final int goldPerHour;

  /// Set once the week is closed, with what was still owed and the gold
  /// taken for it.
  final DateTime? settledAt;
  final int? unpaidSeconds;
  final int? penalty;
  const FocusWeekRow({
    required this.weekStart,
    required this.fromDay,
    required this.dailyMinutes,
    required this.capMinutes,
    required this.earnCapMinutes,
    required this.goldPerHour,
    this.settledAt,
    this.unpaidSeconds,
    this.penalty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['week_start'] = Variable<String>(
        $FocusWeeksTable.$converterweekStart.toSql(weekStart),
      );
    }
    {
      map['from_day'] = Variable<String>(
        $FocusWeeksTable.$converterfromDay.toSql(fromDay),
      );
    }
    map['daily_minutes'] = Variable<int>(dailyMinutes);
    map['cap_minutes'] = Variable<int>(capMinutes);
    map['earn_cap_minutes'] = Variable<int>(earnCapMinutes);
    map['gold_per_hour'] = Variable<int>(goldPerHour);
    if (!nullToAbsent || settledAt != null) {
      map['settled_at'] = Variable<DateTime>(settledAt);
    }
    if (!nullToAbsent || unpaidSeconds != null) {
      map['unpaid_seconds'] = Variable<int>(unpaidSeconds);
    }
    if (!nullToAbsent || penalty != null) {
      map['penalty'] = Variable<int>(penalty);
    }
    return map;
  }

  FocusWeeksCompanion toCompanion(bool nullToAbsent) {
    return FocusWeeksCompanion(
      weekStart: Value(weekStart),
      fromDay: Value(fromDay),
      dailyMinutes: Value(dailyMinutes),
      capMinutes: Value(capMinutes),
      earnCapMinutes: Value(earnCapMinutes),
      goldPerHour: Value(goldPerHour),
      settledAt: settledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(settledAt),
      unpaidSeconds: unpaidSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(unpaidSeconds),
      penalty: penalty == null && nullToAbsent
          ? const Value.absent()
          : Value(penalty),
    );
  }

  factory FocusWeekRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FocusWeekRow(
      weekStart: serializer.fromJson<LogicalDay>(json['weekStart']),
      fromDay: serializer.fromJson<LogicalDay>(json['fromDay']),
      dailyMinutes: serializer.fromJson<int>(json['dailyMinutes']),
      capMinutes: serializer.fromJson<int>(json['capMinutes']),
      earnCapMinutes: serializer.fromJson<int>(json['earnCapMinutes']),
      goldPerHour: serializer.fromJson<int>(json['goldPerHour']),
      settledAt: serializer.fromJson<DateTime?>(json['settledAt']),
      unpaidSeconds: serializer.fromJson<int?>(json['unpaidSeconds']),
      penalty: serializer.fromJson<int?>(json['penalty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'weekStart': serializer.toJson<LogicalDay>(weekStart),
      'fromDay': serializer.toJson<LogicalDay>(fromDay),
      'dailyMinutes': serializer.toJson<int>(dailyMinutes),
      'capMinutes': serializer.toJson<int>(capMinutes),
      'earnCapMinutes': serializer.toJson<int>(earnCapMinutes),
      'goldPerHour': serializer.toJson<int>(goldPerHour),
      'settledAt': serializer.toJson<DateTime?>(settledAt),
      'unpaidSeconds': serializer.toJson<int?>(unpaidSeconds),
      'penalty': serializer.toJson<int?>(penalty),
    };
  }

  FocusWeekRow copyWith({
    LogicalDay? weekStart,
    LogicalDay? fromDay,
    int? dailyMinutes,
    int? capMinutes,
    int? earnCapMinutes,
    int? goldPerHour,
    Value<DateTime?> settledAt = const Value.absent(),
    Value<int?> unpaidSeconds = const Value.absent(),
    Value<int?> penalty = const Value.absent(),
  }) => FocusWeekRow(
    weekStart: weekStart ?? this.weekStart,
    fromDay: fromDay ?? this.fromDay,
    dailyMinutes: dailyMinutes ?? this.dailyMinutes,
    capMinutes: capMinutes ?? this.capMinutes,
    earnCapMinutes: earnCapMinutes ?? this.earnCapMinutes,
    goldPerHour: goldPerHour ?? this.goldPerHour,
    settledAt: settledAt.present ? settledAt.value : this.settledAt,
    unpaidSeconds: unpaidSeconds.present
        ? unpaidSeconds.value
        : this.unpaidSeconds,
    penalty: penalty.present ? penalty.value : this.penalty,
  );
  FocusWeekRow copyWithCompanion(FocusWeeksCompanion data) {
    return FocusWeekRow(
      weekStart: data.weekStart.present ? data.weekStart.value : this.weekStart,
      fromDay: data.fromDay.present ? data.fromDay.value : this.fromDay,
      dailyMinutes: data.dailyMinutes.present
          ? data.dailyMinutes.value
          : this.dailyMinutes,
      capMinutes: data.capMinutes.present
          ? data.capMinutes.value
          : this.capMinutes,
      earnCapMinutes: data.earnCapMinutes.present
          ? data.earnCapMinutes.value
          : this.earnCapMinutes,
      goldPerHour: data.goldPerHour.present
          ? data.goldPerHour.value
          : this.goldPerHour,
      settledAt: data.settledAt.present ? data.settledAt.value : this.settledAt,
      unpaidSeconds: data.unpaidSeconds.present
          ? data.unpaidSeconds.value
          : this.unpaidSeconds,
      penalty: data.penalty.present ? data.penalty.value : this.penalty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FocusWeekRow(')
          ..write('weekStart: $weekStart, ')
          ..write('fromDay: $fromDay, ')
          ..write('dailyMinutes: $dailyMinutes, ')
          ..write('capMinutes: $capMinutes, ')
          ..write('earnCapMinutes: $earnCapMinutes, ')
          ..write('goldPerHour: $goldPerHour, ')
          ..write('settledAt: $settledAt, ')
          ..write('unpaidSeconds: $unpaidSeconds, ')
          ..write('penalty: $penalty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    weekStart,
    fromDay,
    dailyMinutes,
    capMinutes,
    earnCapMinutes,
    goldPerHour,
    settledAt,
    unpaidSeconds,
    penalty,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FocusWeekRow &&
          other.weekStart == this.weekStart &&
          other.fromDay == this.fromDay &&
          other.dailyMinutes == this.dailyMinutes &&
          other.capMinutes == this.capMinutes &&
          other.earnCapMinutes == this.earnCapMinutes &&
          other.goldPerHour == this.goldPerHour &&
          other.settledAt == this.settledAt &&
          other.unpaidSeconds == this.unpaidSeconds &&
          other.penalty == this.penalty);
}

class FocusWeeksCompanion extends UpdateCompanion<FocusWeekRow> {
  final Value<LogicalDay> weekStart;
  final Value<LogicalDay> fromDay;
  final Value<int> dailyMinutes;
  final Value<int> capMinutes;
  final Value<int> earnCapMinutes;
  final Value<int> goldPerHour;
  final Value<DateTime?> settledAt;
  final Value<int?> unpaidSeconds;
  final Value<int?> penalty;
  final Value<int> rowid;
  const FocusWeeksCompanion({
    this.weekStart = const Value.absent(),
    this.fromDay = const Value.absent(),
    this.dailyMinutes = const Value.absent(),
    this.capMinutes = const Value.absent(),
    this.earnCapMinutes = const Value.absent(),
    this.goldPerHour = const Value.absent(),
    this.settledAt = const Value.absent(),
    this.unpaidSeconds = const Value.absent(),
    this.penalty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FocusWeeksCompanion.insert({
    required LogicalDay weekStart,
    required LogicalDay fromDay,
    required int dailyMinutes,
    required int capMinutes,
    required int earnCapMinutes,
    required int goldPerHour,
    this.settledAt = const Value.absent(),
    this.unpaidSeconds = const Value.absent(),
    this.penalty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : weekStart = Value(weekStart),
       fromDay = Value(fromDay),
       dailyMinutes = Value(dailyMinutes),
       capMinutes = Value(capMinutes),
       earnCapMinutes = Value(earnCapMinutes),
       goldPerHour = Value(goldPerHour);
  static Insertable<FocusWeekRow> custom({
    Expression<String>? weekStart,
    Expression<String>? fromDay,
    Expression<int>? dailyMinutes,
    Expression<int>? capMinutes,
    Expression<int>? earnCapMinutes,
    Expression<int>? goldPerHour,
    Expression<DateTime>? settledAt,
    Expression<int>? unpaidSeconds,
    Expression<int>? penalty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (weekStart != null) 'week_start': weekStart,
      if (fromDay != null) 'from_day': fromDay,
      if (dailyMinutes != null) 'daily_minutes': dailyMinutes,
      if (capMinutes != null) 'cap_minutes': capMinutes,
      if (earnCapMinutes != null) 'earn_cap_minutes': earnCapMinutes,
      if (goldPerHour != null) 'gold_per_hour': goldPerHour,
      if (settledAt != null) 'settled_at': settledAt,
      if (unpaidSeconds != null) 'unpaid_seconds': unpaidSeconds,
      if (penalty != null) 'penalty': penalty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FocusWeeksCompanion copyWith({
    Value<LogicalDay>? weekStart,
    Value<LogicalDay>? fromDay,
    Value<int>? dailyMinutes,
    Value<int>? capMinutes,
    Value<int>? earnCapMinutes,
    Value<int>? goldPerHour,
    Value<DateTime?>? settledAt,
    Value<int?>? unpaidSeconds,
    Value<int?>? penalty,
    Value<int>? rowid,
  }) {
    return FocusWeeksCompanion(
      weekStart: weekStart ?? this.weekStart,
      fromDay: fromDay ?? this.fromDay,
      dailyMinutes: dailyMinutes ?? this.dailyMinutes,
      capMinutes: capMinutes ?? this.capMinutes,
      earnCapMinutes: earnCapMinutes ?? this.earnCapMinutes,
      goldPerHour: goldPerHour ?? this.goldPerHour,
      settledAt: settledAt ?? this.settledAt,
      unpaidSeconds: unpaidSeconds ?? this.unpaidSeconds,
      penalty: penalty ?? this.penalty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (weekStart.present) {
      map['week_start'] = Variable<String>(
        $FocusWeeksTable.$converterweekStart.toSql(weekStart.value),
      );
    }
    if (fromDay.present) {
      map['from_day'] = Variable<String>(
        $FocusWeeksTable.$converterfromDay.toSql(fromDay.value),
      );
    }
    if (dailyMinutes.present) {
      map['daily_minutes'] = Variable<int>(dailyMinutes.value);
    }
    if (capMinutes.present) {
      map['cap_minutes'] = Variable<int>(capMinutes.value);
    }
    if (earnCapMinutes.present) {
      map['earn_cap_minutes'] = Variable<int>(earnCapMinutes.value);
    }
    if (goldPerHour.present) {
      map['gold_per_hour'] = Variable<int>(goldPerHour.value);
    }
    if (settledAt.present) {
      map['settled_at'] = Variable<DateTime>(settledAt.value);
    }
    if (unpaidSeconds.present) {
      map['unpaid_seconds'] = Variable<int>(unpaidSeconds.value);
    }
    if (penalty.present) {
      map['penalty'] = Variable<int>(penalty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FocusWeeksCompanion(')
          ..write('weekStart: $weekStart, ')
          ..write('fromDay: $fromDay, ')
          ..write('dailyMinutes: $dailyMinutes, ')
          ..write('capMinutes: $capMinutes, ')
          ..write('earnCapMinutes: $earnCapMinutes, ')
          ..write('goldPerHour: $goldPerHour, ')
          ..write('settledAt: $settledAt, ')
          ..write('unpaidSeconds: $unpaidSeconds, ')
          ..write('penalty: $penalty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FocusSessionsTable extends FocusSessions
    with TableInfo<$FocusSessionsTable, FocusSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FocusSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LogicalDay, String> day =
      GeneratedColumn<String>(
        'day',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LogicalDay>($FocusSessionsTable.$converterday);
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hiddenAtMeta = const VerificationMeta(
    'hiddenAt',
  );
  @override
  late final GeneratedColumn<DateTime> hiddenAt = GeneratedColumn<DateTime>(
    'hidden_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _awaySecondsMeta = const VerificationMeta(
    'awaySeconds',
  );
  @override
  late final GeneratedColumn<int> awaySeconds = GeneratedColumn<int>(
    'away_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _secondsMeta = const VerificationMeta(
    'seconds',
  );
  @override
  late final GeneratedColumn<int> seconds = GeneratedColumn<int>(
    'seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _endReasonMeta = const VerificationMeta(
    'endReason',
  );
  @override
  late final GeneratedColumn<String> endReason = GeneratedColumn<String>(
    'end_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    day,
    startedAt,
    lastSeenAt,
    hiddenAt,
    endedAt,
    awaySeconds,
    seconds,
    endReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'focus_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<FocusSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastSeenAtMeta);
    }
    if (data.containsKey('hidden_at')) {
      context.handle(
        _hiddenAtMeta,
        hiddenAt.isAcceptableOrUnknown(data['hidden_at']!, _hiddenAtMeta),
      );
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('away_seconds')) {
      context.handle(
        _awaySecondsMeta,
        awaySeconds.isAcceptableOrUnknown(
          data['away_seconds']!,
          _awaySecondsMeta,
        ),
      );
    }
    if (data.containsKey('seconds')) {
      context.handle(
        _secondsMeta,
        seconds.isAcceptableOrUnknown(data['seconds']!, _secondsMeta),
      );
    }
    if (data.containsKey('end_reason')) {
      context.handle(
        _endReasonMeta,
        endReason.isAcceptableOrUnknown(data['end_reason']!, _endReasonMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FocusSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FocusSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      day: $FocusSessionsTable.$converterday.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}day'],
        )!,
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      )!,
      hiddenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}hidden_at'],
      ),
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      awaySeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}away_seconds'],
      )!,
      seconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seconds'],
      )!,
      endReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_reason'],
      ),
    );
  }

  @override
  $FocusSessionsTable createAlias(String alias) {
    return $FocusSessionsTable(attachedDatabase, alias);
  }

  static TypeConverter<LogicalDay, String> $converterday =
      const LogicalDayConverter();
}

class FocusSessionRow extends DataClass implements Insertable<FocusSessionRow> {
  final int id;
  final LogicalDay day;
  final DateTime startedAt;

  /// When the running session was last saved: where it ends if the app
  /// never comes back.
  final DateTime lastSeenAt;

  /// Set while the app is in the background.
  final DateTime? hiddenAt;
  final DateTime? endedAt;

  /// Time spent outside the app within the grace period; not focus.
  final int awaySeconds;

  /// Focused seconds so far; final once [endedAt] is set.
  final int seconds;
  final String? endReason;
  const FocusSessionRow({
    required this.id,
    required this.day,
    required this.startedAt,
    required this.lastSeenAt,
    this.hiddenAt,
    this.endedAt,
    required this.awaySeconds,
    required this.seconds,
    this.endReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['day'] = Variable<String>(
        $FocusSessionsTable.$converterday.toSql(day),
      );
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    if (!nullToAbsent || hiddenAt != null) {
      map['hidden_at'] = Variable<DateTime>(hiddenAt);
    }
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['away_seconds'] = Variable<int>(awaySeconds);
    map['seconds'] = Variable<int>(seconds);
    if (!nullToAbsent || endReason != null) {
      map['end_reason'] = Variable<String>(endReason);
    }
    return map;
  }

  FocusSessionsCompanion toCompanion(bool nullToAbsent) {
    return FocusSessionsCompanion(
      id: Value(id),
      day: Value(day),
      startedAt: Value(startedAt),
      lastSeenAt: Value(lastSeenAt),
      hiddenAt: hiddenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(hiddenAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      awaySeconds: Value(awaySeconds),
      seconds: Value(seconds),
      endReason: endReason == null && nullToAbsent
          ? const Value.absent()
          : Value(endReason),
    );
  }

  factory FocusSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FocusSessionRow(
      id: serializer.fromJson<int>(json['id']),
      day: serializer.fromJson<LogicalDay>(json['day']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      lastSeenAt: serializer.fromJson<DateTime>(json['lastSeenAt']),
      hiddenAt: serializer.fromJson<DateTime?>(json['hiddenAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      awaySeconds: serializer.fromJson<int>(json['awaySeconds']),
      seconds: serializer.fromJson<int>(json['seconds']),
      endReason: serializer.fromJson<String?>(json['endReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'day': serializer.toJson<LogicalDay>(day),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'lastSeenAt': serializer.toJson<DateTime>(lastSeenAt),
      'hiddenAt': serializer.toJson<DateTime?>(hiddenAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'awaySeconds': serializer.toJson<int>(awaySeconds),
      'seconds': serializer.toJson<int>(seconds),
      'endReason': serializer.toJson<String?>(endReason),
    };
  }

  FocusSessionRow copyWith({
    int? id,
    LogicalDay? day,
    DateTime? startedAt,
    DateTime? lastSeenAt,
    Value<DateTime?> hiddenAt = const Value.absent(),
    Value<DateTime?> endedAt = const Value.absent(),
    int? awaySeconds,
    int? seconds,
    Value<String?> endReason = const Value.absent(),
  }) => FocusSessionRow(
    id: id ?? this.id,
    day: day ?? this.day,
    startedAt: startedAt ?? this.startedAt,
    lastSeenAt: lastSeenAt ?? this.lastSeenAt,
    hiddenAt: hiddenAt.present ? hiddenAt.value : this.hiddenAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    awaySeconds: awaySeconds ?? this.awaySeconds,
    seconds: seconds ?? this.seconds,
    endReason: endReason.present ? endReason.value : this.endReason,
  );
  FocusSessionRow copyWithCompanion(FocusSessionsCompanion data) {
    return FocusSessionRow(
      id: data.id.present ? data.id.value : this.id,
      day: data.day.present ? data.day.value : this.day,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
      hiddenAt: data.hiddenAt.present ? data.hiddenAt.value : this.hiddenAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      awaySeconds: data.awaySeconds.present
          ? data.awaySeconds.value
          : this.awaySeconds,
      seconds: data.seconds.present ? data.seconds.value : this.seconds,
      endReason: data.endReason.present ? data.endReason.value : this.endReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FocusSessionRow(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('startedAt: $startedAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('hiddenAt: $hiddenAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('awaySeconds: $awaySeconds, ')
          ..write('seconds: $seconds, ')
          ..write('endReason: $endReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    day,
    startedAt,
    lastSeenAt,
    hiddenAt,
    endedAt,
    awaySeconds,
    seconds,
    endReason,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FocusSessionRow &&
          other.id == this.id &&
          other.day == this.day &&
          other.startedAt == this.startedAt &&
          other.lastSeenAt == this.lastSeenAt &&
          other.hiddenAt == this.hiddenAt &&
          other.endedAt == this.endedAt &&
          other.awaySeconds == this.awaySeconds &&
          other.seconds == this.seconds &&
          other.endReason == this.endReason);
}

class FocusSessionsCompanion extends UpdateCompanion<FocusSessionRow> {
  final Value<int> id;
  final Value<LogicalDay> day;
  final Value<DateTime> startedAt;
  final Value<DateTime> lastSeenAt;
  final Value<DateTime?> hiddenAt;
  final Value<DateTime?> endedAt;
  final Value<int> awaySeconds;
  final Value<int> seconds;
  final Value<String?> endReason;
  const FocusSessionsCompanion({
    this.id = const Value.absent(),
    this.day = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.hiddenAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.awaySeconds = const Value.absent(),
    this.seconds = const Value.absent(),
    this.endReason = const Value.absent(),
  });
  FocusSessionsCompanion.insert({
    this.id = const Value.absent(),
    required LogicalDay day,
    required DateTime startedAt,
    required DateTime lastSeenAt,
    this.hiddenAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.awaySeconds = const Value.absent(),
    this.seconds = const Value.absent(),
    this.endReason = const Value.absent(),
  }) : day = Value(day),
       startedAt = Value(startedAt),
       lastSeenAt = Value(lastSeenAt);
  static Insertable<FocusSessionRow> custom({
    Expression<int>? id,
    Expression<String>? day,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? lastSeenAt,
    Expression<DateTime>? hiddenAt,
    Expression<DateTime>? endedAt,
    Expression<int>? awaySeconds,
    Expression<int>? seconds,
    Expression<String>? endReason,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (day != null) 'day': day,
      if (startedAt != null) 'started_at': startedAt,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (hiddenAt != null) 'hidden_at': hiddenAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (awaySeconds != null) 'away_seconds': awaySeconds,
      if (seconds != null) 'seconds': seconds,
      if (endReason != null) 'end_reason': endReason,
    });
  }

  FocusSessionsCompanion copyWith({
    Value<int>? id,
    Value<LogicalDay>? day,
    Value<DateTime>? startedAt,
    Value<DateTime>? lastSeenAt,
    Value<DateTime?>? hiddenAt,
    Value<DateTime?>? endedAt,
    Value<int>? awaySeconds,
    Value<int>? seconds,
    Value<String?>? endReason,
  }) {
    return FocusSessionsCompanion(
      id: id ?? this.id,
      day: day ?? this.day,
      startedAt: startedAt ?? this.startedAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      hiddenAt: hiddenAt ?? this.hiddenAt,
      endedAt: endedAt ?? this.endedAt,
      awaySeconds: awaySeconds ?? this.awaySeconds,
      seconds: seconds ?? this.seconds,
      endReason: endReason ?? this.endReason,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(
        $FocusSessionsTable.$converterday.toSql(day.value),
      );
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (hiddenAt.present) {
      map['hidden_at'] = Variable<DateTime>(hiddenAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (awaySeconds.present) {
      map['away_seconds'] = Variable<int>(awaySeconds.value);
    }
    if (seconds.present) {
      map['seconds'] = Variable<int>(seconds.value);
    }
    if (endReason.present) {
      map['end_reason'] = Variable<String>(endReason.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FocusSessionsCompanion(')
          ..write('id: $id, ')
          ..write('day: $day, ')
          ..write('startedAt: $startedAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('hiddenAt: $hiddenAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('awaySeconds: $awaySeconds, ')
          ..write('seconds: $seconds, ')
          ..write('endReason: $endReason')
          ..write(')'))
        .toString();
  }
}

class $BankAccountsTable extends BankAccounts
    with TableInfo<$BankAccountsTable, BankAccountRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BankAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<AccountRole?, String> role =
      GeneratedColumn<String>(
        'role',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<AccountRole?>($BankAccountsTable.$converterrolen);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<int> weight = GeneratedColumn<int>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    role,
    icon,
    weight,
    sortOrder,
    archivedAt,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bank_accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<BankAccountRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BankAccountRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BankAccountRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      role: $BankAccountsTable.$converterrolen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}role'],
        ),
      ),
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weight'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BankAccountsTable createAlias(String alias) {
    return $BankAccountsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AccountRole, String, String> $converterrole =
      const EnumNameConverter<AccountRole>(AccountRole.values);
  static JsonTypeConverter2<AccountRole?, String?, String?> $converterrolen =
      JsonTypeConverter2.asNullable($converterrole);
}

class BankAccountRow extends DataClass implements Insertable<BankAccountRow> {
  final int id;
  final String name;

  /// Null for a plain envelope.
  final AccountRole? role;

  /// A `PixelIcons` id.
  final String icon;

  /// Share of the casino's prizes.
  final int weight;
  final int sortOrder;
  final DateTime? archivedAt;
  final DateTime createdAt;
  const BankAccountRow({
    required this.id,
    required this.name,
    this.role,
    required this.icon,
    required this.weight,
    required this.sortOrder,
    this.archivedAt,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || role != null) {
      map['role'] = Variable<String>(
        $BankAccountsTable.$converterrolen.toSql(role),
      );
    }
    map['icon'] = Variable<String>(icon);
    map['weight'] = Variable<int>(weight);
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BankAccountsCompanion toCompanion(bool nullToAbsent) {
    return BankAccountsCompanion(
      id: Value(id),
      name: Value(name),
      role: role == null && nullToAbsent ? const Value.absent() : Value(role),
      icon: Value(icon),
      weight: Value(weight),
      sortOrder: Value(sortOrder),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      createdAt: Value(createdAt),
    );
  }

  factory BankAccountRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BankAccountRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      role: $BankAccountsTable.$converterrolen.fromJson(
        serializer.fromJson<String?>(json['role']),
      ),
      icon: serializer.fromJson<String>(json['icon']),
      weight: serializer.fromJson<int>(json['weight']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'role': serializer.toJson<String?>(
        $BankAccountsTable.$converterrolen.toJson(role),
      ),
      'icon': serializer.toJson<String>(icon),
      'weight': serializer.toJson<int>(weight),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BankAccountRow copyWith({
    int? id,
    String? name,
    Value<AccountRole?> role = const Value.absent(),
    String? icon,
    int? weight,
    int? sortOrder,
    Value<DateTime?> archivedAt = const Value.absent(),
    DateTime? createdAt,
  }) => BankAccountRow(
    id: id ?? this.id,
    name: name ?? this.name,
    role: role.present ? role.value : this.role,
    icon: icon ?? this.icon,
    weight: weight ?? this.weight,
    sortOrder: sortOrder ?? this.sortOrder,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    createdAt: createdAt ?? this.createdAt,
  );
  BankAccountRow copyWithCompanion(BankAccountsCompanion data) {
    return BankAccountRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      role: data.role.present ? data.role.value : this.role,
      icon: data.icon.present ? data.icon.value : this.icon,
      weight: data.weight.present ? data.weight.value : this.weight,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BankAccountRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('icon: $icon, ')
          ..write('weight: $weight, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    role,
    icon,
    weight,
    sortOrder,
    archivedAt,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BankAccountRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.role == this.role &&
          other.icon == this.icon &&
          other.weight == this.weight &&
          other.sortOrder == this.sortOrder &&
          other.archivedAt == this.archivedAt &&
          other.createdAt == this.createdAt);
}

class BankAccountsCompanion extends UpdateCompanion<BankAccountRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<AccountRole?> role;
  final Value<String> icon;
  final Value<int> weight;
  final Value<int> sortOrder;
  final Value<DateTime?> archivedAt;
  final Value<DateTime> createdAt;
  const BankAccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.role = const Value.absent(),
    this.icon = const Value.absent(),
    this.weight = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BankAccountsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.role = const Value.absent(),
    required String icon,
    this.weight = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.archivedAt = const Value.absent(),
    required DateTime createdAt,
  }) : name = Value(name),
       icon = Value(icon),
       createdAt = Value(createdAt);
  static Insertable<BankAccountRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? role,
    Expression<String>? icon,
    Expression<int>? weight,
    Expression<int>? sortOrder,
    Expression<DateTime>? archivedAt,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (role != null) 'role': role,
      if (icon != null) 'icon': icon,
      if (weight != null) 'weight': weight,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BankAccountsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<AccountRole?>? role,
    Value<String>? icon,
    Value<int>? weight,
    Value<int>? sortOrder,
    Value<DateTime?>? archivedAt,
    Value<DateTime>? createdAt,
  }) {
    return BankAccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      icon: icon ?? this.icon,
      weight: weight ?? this.weight,
      sortOrder: sortOrder ?? this.sortOrder,
      archivedAt: archivedAt ?? this.archivedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(
        $BankAccountsTable.$converterrolen.toSql(role.value),
      );
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (weight.present) {
      map['weight'] = Variable<int>(weight.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BankAccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('icon: $icon, ')
          ..write('weight: $weight, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $BankTxnsTable extends BankTxns
    with TableInfo<$BankTxnsTable, BankTxnRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BankTxnsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _uidMeta = const VerificationMeta('uid');
  @override
  late final GeneratedColumn<String> uid = GeneratedColumn<String>(
    'uid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TxnKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TxnKind>($BankTxnsTable.$converterkind);
  static const VerificationMeta _fromIdMeta = const VerificationMeta('fromId');
  @override
  late final GeneratedColumn<int> fromId = GeneratedColumn<int>(
    'from_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bank_accounts (id)',
    ),
  );
  static const VerificationMeta _toIdMeta = const VerificationMeta('toId');
  @override
  late final GeneratedColumn<int> toId = GeneratedColumn<int>(
    'to_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bank_accounts (id)',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    check: () => ComparableExpr(amount).isBiggerThanValue(0),
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LogicalDay, String> day =
      GeneratedColumn<String>(
        'day',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LogicalDay>($BankTxnsTable.$converterday);
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _refMeta = const VerificationMeta('ref');
  @override
  late final GeneratedColumn<String> ref = GeneratedColumn<String>(
    'ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _groupIdMeta = const VerificationMeta(
    'groupId',
  );
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
    'group_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fixedIdMeta = const VerificationMeta(
    'fixedId',
  );
  @override
  late final GeneratedColumn<String> fixedId = GeneratedColumn<String>(
    'fixed_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voidedAtMeta = const VerificationMeta(
    'voidedAt',
  );
  @override
  late final GeneratedColumn<DateTime> voidedAt = GeneratedColumn<DateTime>(
    'voided_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inboxMeta = const VerificationMeta('inbox');
  @override
  late final GeneratedColumn<bool> inbox = GeneratedColumn<bool>(
    'inbox',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("inbox" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notionPageIdMeta = const VerificationMeta(
    'notionPageId',
  );
  @override
  late final GeneratedColumn<String> notionPageId = GeneratedColumn<String>(
    'notion_page_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _notionEditedAtMeta = const VerificationMeta(
    'notionEditedAt',
  );
  @override
  late final GeneratedColumn<DateTime> notionEditedAt =
      GeneratedColumn<DateTime>(
        'notion_edited_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<String> syncState = GeneratedColumn<String>(
    'sync_state',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    uid,
    kind,
    fromId,
    toId,
    amount,
    day,
    at,
    title,
    note,
    ref,
    groupId,
    fixedId,
    voidedAt,
    category,
    inbox,
    notionPageId,
    notionEditedAt,
    syncState,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bank_txns';
  @override
  VerificationContext validateIntegrity(
    Insertable<BankTxnRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('uid')) {
      context.handle(
        _uidMeta,
        uid.isAcceptableOrUnknown(data['uid']!, _uidMeta),
      );
    } else if (isInserting) {
      context.missing(_uidMeta);
    }
    if (data.containsKey('from_id')) {
      context.handle(
        _fromIdMeta,
        fromId.isAcceptableOrUnknown(data['from_id']!, _fromIdMeta),
      );
    }
    if (data.containsKey('to_id')) {
      context.handle(
        _toIdMeta,
        toId.isAcceptableOrUnknown(data['to_id']!, _toIdMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    } else if (isInserting) {
      context.missing(_atMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('ref')) {
      context.handle(
        _refMeta,
        ref.isAcceptableOrUnknown(data['ref']!, _refMeta),
      );
    }
    if (data.containsKey('group_id')) {
      context.handle(
        _groupIdMeta,
        groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta),
      );
    }
    if (data.containsKey('fixed_id')) {
      context.handle(
        _fixedIdMeta,
        fixedId.isAcceptableOrUnknown(data['fixed_id']!, _fixedIdMeta),
      );
    }
    if (data.containsKey('voided_at')) {
      context.handle(
        _voidedAtMeta,
        voidedAt.isAcceptableOrUnknown(data['voided_at']!, _voidedAtMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('inbox')) {
      context.handle(
        _inboxMeta,
        inbox.isAcceptableOrUnknown(data['inbox']!, _inboxMeta),
      );
    }
    if (data.containsKey('notion_page_id')) {
      context.handle(
        _notionPageIdMeta,
        notionPageId.isAcceptableOrUnknown(
          data['notion_page_id']!,
          _notionPageIdMeta,
        ),
      );
    }
    if (data.containsKey('notion_edited_at')) {
      context.handle(
        _notionEditedAtMeta,
        notionEditedAt.isAcceptableOrUnknown(
          data['notion_edited_at']!,
          _notionEditedAtMeta,
        ),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BankTxnRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BankTxnRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      uid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uid'],
      )!,
      kind: $BankTxnsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      fromId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}from_id'],
      ),
      toId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}to_id'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      day: $BankTxnsTable.$converterday.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}day'],
        )!,
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      ref: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ref'],
      ),
      groupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}group_id'],
      ),
      fixedId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fixed_id'],
      ),
      voidedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}voided_at'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      inbox: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}inbox'],
      )!,
      notionPageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notion_page_id'],
      ),
      notionEditedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}notion_edited_at'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_state'],
      ),
    );
  }

  @override
  $BankTxnsTable createAlias(String alias) {
    return $BankTxnsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TxnKind, String, String> $converterkind =
      const EnumNameConverter<TxnKind>(TxnKind.values);
  static TypeConverter<LogicalDay, String> $converterday =
      const LogicalDayConverter();
}

class BankTxnRow extends DataClass implements Insertable<BankTxnRow> {
  final int id;

  /// Stable id outside this database (the Notion row's "App ID").
  final String uid;
  final TxnKind kind;
  final int? fromId;
  final int? toId;
  final int amount;
  final LogicalDay day;
  final DateTime at;
  final String title;
  final String note;

  /// Makes an automatic move happen once (`meal:<day>`, `refill:<month>`…).
  final String? ref;

  /// Rows that go together (a transfer and its fee) and are voided
  /// together.
  final String? groupId;

  /// The `FixedCost` this pays, charged or out of what was set aside.
  final String? fixedId;
  final DateTime? voidedAt;
  final String? category;
  final bool inbox;
  final String? notionPageId;
  final DateTime? notionEditedAt;
  final String? syncState;
  const BankTxnRow({
    required this.id,
    required this.uid,
    required this.kind,
    this.fromId,
    this.toId,
    required this.amount,
    required this.day,
    required this.at,
    required this.title,
    required this.note,
    this.ref,
    this.groupId,
    this.fixedId,
    this.voidedAt,
    this.category,
    required this.inbox,
    this.notionPageId,
    this.notionEditedAt,
    this.syncState,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['uid'] = Variable<String>(uid);
    {
      map['kind'] = Variable<String>($BankTxnsTable.$converterkind.toSql(kind));
    }
    if (!nullToAbsent || fromId != null) {
      map['from_id'] = Variable<int>(fromId);
    }
    if (!nullToAbsent || toId != null) {
      map['to_id'] = Variable<int>(toId);
    }
    map['amount'] = Variable<int>(amount);
    {
      map['day'] = Variable<String>($BankTxnsTable.$converterday.toSql(day));
    }
    map['at'] = Variable<DateTime>(at);
    map['title'] = Variable<String>(title);
    map['note'] = Variable<String>(note);
    if (!nullToAbsent || ref != null) {
      map['ref'] = Variable<String>(ref);
    }
    if (!nullToAbsent || groupId != null) {
      map['group_id'] = Variable<String>(groupId);
    }
    if (!nullToAbsent || fixedId != null) {
      map['fixed_id'] = Variable<String>(fixedId);
    }
    if (!nullToAbsent || voidedAt != null) {
      map['voided_at'] = Variable<DateTime>(voidedAt);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['inbox'] = Variable<bool>(inbox);
    if (!nullToAbsent || notionPageId != null) {
      map['notion_page_id'] = Variable<String>(notionPageId);
    }
    if (!nullToAbsent || notionEditedAt != null) {
      map['notion_edited_at'] = Variable<DateTime>(notionEditedAt);
    }
    if (!nullToAbsent || syncState != null) {
      map['sync_state'] = Variable<String>(syncState);
    }
    return map;
  }

  BankTxnsCompanion toCompanion(bool nullToAbsent) {
    return BankTxnsCompanion(
      id: Value(id),
      uid: Value(uid),
      kind: Value(kind),
      fromId: fromId == null && nullToAbsent
          ? const Value.absent()
          : Value(fromId),
      toId: toId == null && nullToAbsent ? const Value.absent() : Value(toId),
      amount: Value(amount),
      day: Value(day),
      at: Value(at),
      title: Value(title),
      note: Value(note),
      ref: ref == null && nullToAbsent ? const Value.absent() : Value(ref),
      groupId: groupId == null && nullToAbsent
          ? const Value.absent()
          : Value(groupId),
      fixedId: fixedId == null && nullToAbsent
          ? const Value.absent()
          : Value(fixedId),
      voidedAt: voidedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(voidedAt),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      inbox: Value(inbox),
      notionPageId: notionPageId == null && nullToAbsent
          ? const Value.absent()
          : Value(notionPageId),
      notionEditedAt: notionEditedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(notionEditedAt),
      syncState: syncState == null && nullToAbsent
          ? const Value.absent()
          : Value(syncState),
    );
  }

  factory BankTxnRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BankTxnRow(
      id: serializer.fromJson<int>(json['id']),
      uid: serializer.fromJson<String>(json['uid']),
      kind: $BankTxnsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      fromId: serializer.fromJson<int?>(json['fromId']),
      toId: serializer.fromJson<int?>(json['toId']),
      amount: serializer.fromJson<int>(json['amount']),
      day: serializer.fromJson<LogicalDay>(json['day']),
      at: serializer.fromJson<DateTime>(json['at']),
      title: serializer.fromJson<String>(json['title']),
      note: serializer.fromJson<String>(json['note']),
      ref: serializer.fromJson<String?>(json['ref']),
      groupId: serializer.fromJson<String?>(json['groupId']),
      fixedId: serializer.fromJson<String?>(json['fixedId']),
      voidedAt: serializer.fromJson<DateTime?>(json['voidedAt']),
      category: serializer.fromJson<String?>(json['category']),
      inbox: serializer.fromJson<bool>(json['inbox']),
      notionPageId: serializer.fromJson<String?>(json['notionPageId']),
      notionEditedAt: serializer.fromJson<DateTime?>(json['notionEditedAt']),
      syncState: serializer.fromJson<String?>(json['syncState']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'uid': serializer.toJson<String>(uid),
      'kind': serializer.toJson<String>(
        $BankTxnsTable.$converterkind.toJson(kind),
      ),
      'fromId': serializer.toJson<int?>(fromId),
      'toId': serializer.toJson<int?>(toId),
      'amount': serializer.toJson<int>(amount),
      'day': serializer.toJson<LogicalDay>(day),
      'at': serializer.toJson<DateTime>(at),
      'title': serializer.toJson<String>(title),
      'note': serializer.toJson<String>(note),
      'ref': serializer.toJson<String?>(ref),
      'groupId': serializer.toJson<String?>(groupId),
      'fixedId': serializer.toJson<String?>(fixedId),
      'voidedAt': serializer.toJson<DateTime?>(voidedAt),
      'category': serializer.toJson<String?>(category),
      'inbox': serializer.toJson<bool>(inbox),
      'notionPageId': serializer.toJson<String?>(notionPageId),
      'notionEditedAt': serializer.toJson<DateTime?>(notionEditedAt),
      'syncState': serializer.toJson<String?>(syncState),
    };
  }

  BankTxnRow copyWith({
    int? id,
    String? uid,
    TxnKind? kind,
    Value<int?> fromId = const Value.absent(),
    Value<int?> toId = const Value.absent(),
    int? amount,
    LogicalDay? day,
    DateTime? at,
    String? title,
    String? note,
    Value<String?> ref = const Value.absent(),
    Value<String?> groupId = const Value.absent(),
    Value<String?> fixedId = const Value.absent(),
    Value<DateTime?> voidedAt = const Value.absent(),
    Value<String?> category = const Value.absent(),
    bool? inbox,
    Value<String?> notionPageId = const Value.absent(),
    Value<DateTime?> notionEditedAt = const Value.absent(),
    Value<String?> syncState = const Value.absent(),
  }) => BankTxnRow(
    id: id ?? this.id,
    uid: uid ?? this.uid,
    kind: kind ?? this.kind,
    fromId: fromId.present ? fromId.value : this.fromId,
    toId: toId.present ? toId.value : this.toId,
    amount: amount ?? this.amount,
    day: day ?? this.day,
    at: at ?? this.at,
    title: title ?? this.title,
    note: note ?? this.note,
    ref: ref.present ? ref.value : this.ref,
    groupId: groupId.present ? groupId.value : this.groupId,
    fixedId: fixedId.present ? fixedId.value : this.fixedId,
    voidedAt: voidedAt.present ? voidedAt.value : this.voidedAt,
    category: category.present ? category.value : this.category,
    inbox: inbox ?? this.inbox,
    notionPageId: notionPageId.present ? notionPageId.value : this.notionPageId,
    notionEditedAt: notionEditedAt.present
        ? notionEditedAt.value
        : this.notionEditedAt,
    syncState: syncState.present ? syncState.value : this.syncState,
  );
  BankTxnRow copyWithCompanion(BankTxnsCompanion data) {
    return BankTxnRow(
      id: data.id.present ? data.id.value : this.id,
      uid: data.uid.present ? data.uid.value : this.uid,
      kind: data.kind.present ? data.kind.value : this.kind,
      fromId: data.fromId.present ? data.fromId.value : this.fromId,
      toId: data.toId.present ? data.toId.value : this.toId,
      amount: data.amount.present ? data.amount.value : this.amount,
      day: data.day.present ? data.day.value : this.day,
      at: data.at.present ? data.at.value : this.at,
      title: data.title.present ? data.title.value : this.title,
      note: data.note.present ? data.note.value : this.note,
      ref: data.ref.present ? data.ref.value : this.ref,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      fixedId: data.fixedId.present ? data.fixedId.value : this.fixedId,
      voidedAt: data.voidedAt.present ? data.voidedAt.value : this.voidedAt,
      category: data.category.present ? data.category.value : this.category,
      inbox: data.inbox.present ? data.inbox.value : this.inbox,
      notionPageId: data.notionPageId.present
          ? data.notionPageId.value
          : this.notionPageId,
      notionEditedAt: data.notionEditedAt.present
          ? data.notionEditedAt.value
          : this.notionEditedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BankTxnRow(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('kind: $kind, ')
          ..write('fromId: $fromId, ')
          ..write('toId: $toId, ')
          ..write('amount: $amount, ')
          ..write('day: $day, ')
          ..write('at: $at, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('ref: $ref, ')
          ..write('groupId: $groupId, ')
          ..write('fixedId: $fixedId, ')
          ..write('voidedAt: $voidedAt, ')
          ..write('category: $category, ')
          ..write('inbox: $inbox, ')
          ..write('notionPageId: $notionPageId, ')
          ..write('notionEditedAt: $notionEditedAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    uid,
    kind,
    fromId,
    toId,
    amount,
    day,
    at,
    title,
    note,
    ref,
    groupId,
    fixedId,
    voidedAt,
    category,
    inbox,
    notionPageId,
    notionEditedAt,
    syncState,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BankTxnRow &&
          other.id == this.id &&
          other.uid == this.uid &&
          other.kind == this.kind &&
          other.fromId == this.fromId &&
          other.toId == this.toId &&
          other.amount == this.amount &&
          other.day == this.day &&
          other.at == this.at &&
          other.title == this.title &&
          other.note == this.note &&
          other.ref == this.ref &&
          other.groupId == this.groupId &&
          other.fixedId == this.fixedId &&
          other.voidedAt == this.voidedAt &&
          other.category == this.category &&
          other.inbox == this.inbox &&
          other.notionPageId == this.notionPageId &&
          other.notionEditedAt == this.notionEditedAt &&
          other.syncState == this.syncState);
}

class BankTxnsCompanion extends UpdateCompanion<BankTxnRow> {
  final Value<int> id;
  final Value<String> uid;
  final Value<TxnKind> kind;
  final Value<int?> fromId;
  final Value<int?> toId;
  final Value<int> amount;
  final Value<LogicalDay> day;
  final Value<DateTime> at;
  final Value<String> title;
  final Value<String> note;
  final Value<String?> ref;
  final Value<String?> groupId;
  final Value<String?> fixedId;
  final Value<DateTime?> voidedAt;
  final Value<String?> category;
  final Value<bool> inbox;
  final Value<String?> notionPageId;
  final Value<DateTime?> notionEditedAt;
  final Value<String?> syncState;
  const BankTxnsCompanion({
    this.id = const Value.absent(),
    this.uid = const Value.absent(),
    this.kind = const Value.absent(),
    this.fromId = const Value.absent(),
    this.toId = const Value.absent(),
    this.amount = const Value.absent(),
    this.day = const Value.absent(),
    this.at = const Value.absent(),
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.ref = const Value.absent(),
    this.groupId = const Value.absent(),
    this.fixedId = const Value.absent(),
    this.voidedAt = const Value.absent(),
    this.category = const Value.absent(),
    this.inbox = const Value.absent(),
    this.notionPageId = const Value.absent(),
    this.notionEditedAt = const Value.absent(),
    this.syncState = const Value.absent(),
  });
  BankTxnsCompanion.insert({
    this.id = const Value.absent(),
    required String uid,
    required TxnKind kind,
    this.fromId = const Value.absent(),
    this.toId = const Value.absent(),
    required int amount,
    required LogicalDay day,
    required DateTime at,
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.ref = const Value.absent(),
    this.groupId = const Value.absent(),
    this.fixedId = const Value.absent(),
    this.voidedAt = const Value.absent(),
    this.category = const Value.absent(),
    this.inbox = const Value.absent(),
    this.notionPageId = const Value.absent(),
    this.notionEditedAt = const Value.absent(),
    this.syncState = const Value.absent(),
  }) : uid = Value(uid),
       kind = Value(kind),
       amount = Value(amount),
       day = Value(day),
       at = Value(at);
  static Insertable<BankTxnRow> custom({
    Expression<int>? id,
    Expression<String>? uid,
    Expression<String>? kind,
    Expression<int>? fromId,
    Expression<int>? toId,
    Expression<int>? amount,
    Expression<String>? day,
    Expression<DateTime>? at,
    Expression<String>? title,
    Expression<String>? note,
    Expression<String>? ref,
    Expression<String>? groupId,
    Expression<String>? fixedId,
    Expression<DateTime>? voidedAt,
    Expression<String>? category,
    Expression<bool>? inbox,
    Expression<String>? notionPageId,
    Expression<DateTime>? notionEditedAt,
    Expression<String>? syncState,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (uid != null) 'uid': uid,
      if (kind != null) 'kind': kind,
      if (fromId != null) 'from_id': fromId,
      if (toId != null) 'to_id': toId,
      if (amount != null) 'amount': amount,
      if (day != null) 'day': day,
      if (at != null) 'at': at,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
      if (ref != null) 'ref': ref,
      if (groupId != null) 'group_id': groupId,
      if (fixedId != null) 'fixed_id': fixedId,
      if (voidedAt != null) 'voided_at': voidedAt,
      if (category != null) 'category': category,
      if (inbox != null) 'inbox': inbox,
      if (notionPageId != null) 'notion_page_id': notionPageId,
      if (notionEditedAt != null) 'notion_edited_at': notionEditedAt,
      if (syncState != null) 'sync_state': syncState,
    });
  }

  BankTxnsCompanion copyWith({
    Value<int>? id,
    Value<String>? uid,
    Value<TxnKind>? kind,
    Value<int?>? fromId,
    Value<int?>? toId,
    Value<int>? amount,
    Value<LogicalDay>? day,
    Value<DateTime>? at,
    Value<String>? title,
    Value<String>? note,
    Value<String?>? ref,
    Value<String?>? groupId,
    Value<String?>? fixedId,
    Value<DateTime?>? voidedAt,
    Value<String?>? category,
    Value<bool>? inbox,
    Value<String?>? notionPageId,
    Value<DateTime?>? notionEditedAt,
    Value<String?>? syncState,
  }) {
    return BankTxnsCompanion(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      kind: kind ?? this.kind,
      fromId: fromId ?? this.fromId,
      toId: toId ?? this.toId,
      amount: amount ?? this.amount,
      day: day ?? this.day,
      at: at ?? this.at,
      title: title ?? this.title,
      note: note ?? this.note,
      ref: ref ?? this.ref,
      groupId: groupId ?? this.groupId,
      fixedId: fixedId ?? this.fixedId,
      voidedAt: voidedAt ?? this.voidedAt,
      category: category ?? this.category,
      inbox: inbox ?? this.inbox,
      notionPageId: notionPageId ?? this.notionPageId,
      notionEditedAt: notionEditedAt ?? this.notionEditedAt,
      syncState: syncState ?? this.syncState,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (uid.present) {
      map['uid'] = Variable<String>(uid.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $BankTxnsTable.$converterkind.toSql(kind.value),
      );
    }
    if (fromId.present) {
      map['from_id'] = Variable<int>(fromId.value);
    }
    if (toId.present) {
      map['to_id'] = Variable<int>(toId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(
        $BankTxnsTable.$converterday.toSql(day.value),
      );
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (ref.present) {
      map['ref'] = Variable<String>(ref.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (fixedId.present) {
      map['fixed_id'] = Variable<String>(fixedId.value);
    }
    if (voidedAt.present) {
      map['voided_at'] = Variable<DateTime>(voidedAt.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (inbox.present) {
      map['inbox'] = Variable<bool>(inbox.value);
    }
    if (notionPageId.present) {
      map['notion_page_id'] = Variable<String>(notionPageId.value);
    }
    if (notionEditedAt.present) {
      map['notion_edited_at'] = Variable<DateTime>(notionEditedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<String>(syncState.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BankTxnsCompanion(')
          ..write('id: $id, ')
          ..write('uid: $uid, ')
          ..write('kind: $kind, ')
          ..write('fromId: $fromId, ')
          ..write('toId: $toId, ')
          ..write('amount: $amount, ')
          ..write('day: $day, ')
          ..write('at: $at, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('ref: $ref, ')
          ..write('groupId: $groupId, ')
          ..write('fixedId: $fixedId, ')
          ..write('voidedAt: $voidedAt, ')
          ..write('category: $category, ')
          ..write('inbox: $inbox, ')
          ..write('notionPageId: $notionPageId, ')
          ..write('notionEditedAt: $notionEditedAt, ')
          ..write('syncState: $syncState')
          ..write(')'))
        .toString();
  }
}

class $BankMonthsTable extends BankMonths
    with TableInfo<$BankMonthsTable, BankMonthRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BankMonthsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<String> month = GeneratedColumn<String>(
    'month',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LogicalDay, String> firstDay =
      GeneratedColumn<String>(
        'first_day',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LogicalDay>($BankMonthsTable.$converterfirstDay);
  static const VerificationMeta _configJsonMeta = const VerificationMeta(
    'configJson',
  );
  @override
  late final GeneratedColumn<String> configJson = GeneratedColumn<String>(
    'config_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mealPlanJsonMeta = const VerificationMeta(
    'mealPlanJson',
  );
  @override
  late final GeneratedColumn<String> mealPlanJson = GeneratedColumn<String>(
    'meal_plan_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reservesJsonMeta = const VerificationMeta(
    'reservesJson',
  );
  @override
  late final GeneratedColumn<String> reservesJson = GeneratedColumn<String>(
    'reserves_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _refillMeta = const VerificationMeta('refill');
  @override
  late final GeneratedColumn<int> refill = GeneratedColumn<int>(
    'refill',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openedAtMeta = const VerificationMeta(
    'openedAt',
  );
  @override
  late final GeneratedColumn<DateTime> openedAt = GeneratedColumn<DateTime>(
    'opened_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
    'closed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    month,
    firstDay,
    configJson,
    mealPlanJson,
    reservesJson,
    refill,
    openedAt,
    closedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bank_months';
  @override
  VerificationContext validateIntegrity(
    Insertable<BankMonthRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('config_json')) {
      context.handle(
        _configJsonMeta,
        configJson.isAcceptableOrUnknown(data['config_json']!, _configJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_configJsonMeta);
    }
    if (data.containsKey('meal_plan_json')) {
      context.handle(
        _mealPlanJsonMeta,
        mealPlanJson.isAcceptableOrUnknown(
          data['meal_plan_json']!,
          _mealPlanJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mealPlanJsonMeta);
    }
    if (data.containsKey('reserves_json')) {
      context.handle(
        _reservesJsonMeta,
        reservesJson.isAcceptableOrUnknown(
          data['reserves_json']!,
          _reservesJsonMeta,
        ),
      );
    }
    if (data.containsKey('refill')) {
      context.handle(
        _refillMeta,
        refill.isAcceptableOrUnknown(data['refill']!, _refillMeta),
      );
    } else if (isInserting) {
      context.missing(_refillMeta);
    }
    if (data.containsKey('opened_at')) {
      context.handle(
        _openedAtMeta,
        openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_openedAtMeta);
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {month};
  @override
  BankMonthRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BankMonthRow(
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month'],
      )!,
      firstDay: $BankMonthsTable.$converterfirstDay.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}first_day'],
        )!,
      ),
      configJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config_json'],
      )!,
      mealPlanJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal_plan_json'],
      )!,
      reservesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reserves_json'],
      )!,
      refill: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}refill'],
      )!,
      openedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}opened_at'],
      )!,
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}closed_at'],
      ),
    );
  }

  @override
  $BankMonthsTable createAlias(String alias) {
    return $BankMonthsTable(attachedDatabase, alias);
  }

  static TypeConverter<LogicalDay, String> $converterfirstDay =
      const LogicalDayConverter();
}

class BankMonthRow extends DataClass implements Insertable<BankMonthRow> {
  /// `yyyy-MM`.
  final String month;

  /// The 1st, or the day the bank opened.
  final LogicalDay firstDay;
  final String configJson;

  /// Meal money of each day from [firstDay] on.
  final String mealPlanJson;

  /// What the vault sets aside this month, by fixed cost id.
  final String reservesJson;
  final int refill;
  final DateTime openedAt;
  final DateTime? closedAt;
  const BankMonthRow({
    required this.month,
    required this.firstDay,
    required this.configJson,
    required this.mealPlanJson,
    required this.reservesJson,
    required this.refill,
    required this.openedAt,
    this.closedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['month'] = Variable<String>(month);
    {
      map['first_day'] = Variable<String>(
        $BankMonthsTable.$converterfirstDay.toSql(firstDay),
      );
    }
    map['config_json'] = Variable<String>(configJson);
    map['meal_plan_json'] = Variable<String>(mealPlanJson);
    map['reserves_json'] = Variable<String>(reservesJson);
    map['refill'] = Variable<int>(refill);
    map['opened_at'] = Variable<DateTime>(openedAt);
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<DateTime>(closedAt);
    }
    return map;
  }

  BankMonthsCompanion toCompanion(bool nullToAbsent) {
    return BankMonthsCompanion(
      month: Value(month),
      firstDay: Value(firstDay),
      configJson: Value(configJson),
      mealPlanJson: Value(mealPlanJson),
      reservesJson: Value(reservesJson),
      refill: Value(refill),
      openedAt: Value(openedAt),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
    );
  }

  factory BankMonthRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BankMonthRow(
      month: serializer.fromJson<String>(json['month']),
      firstDay: serializer.fromJson<LogicalDay>(json['firstDay']),
      configJson: serializer.fromJson<String>(json['configJson']),
      mealPlanJson: serializer.fromJson<String>(json['mealPlanJson']),
      reservesJson: serializer.fromJson<String>(json['reservesJson']),
      refill: serializer.fromJson<int>(json['refill']),
      openedAt: serializer.fromJson<DateTime>(json['openedAt']),
      closedAt: serializer.fromJson<DateTime?>(json['closedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'month': serializer.toJson<String>(month),
      'firstDay': serializer.toJson<LogicalDay>(firstDay),
      'configJson': serializer.toJson<String>(configJson),
      'mealPlanJson': serializer.toJson<String>(mealPlanJson),
      'reservesJson': serializer.toJson<String>(reservesJson),
      'refill': serializer.toJson<int>(refill),
      'openedAt': serializer.toJson<DateTime>(openedAt),
      'closedAt': serializer.toJson<DateTime?>(closedAt),
    };
  }

  BankMonthRow copyWith({
    String? month,
    LogicalDay? firstDay,
    String? configJson,
    String? mealPlanJson,
    String? reservesJson,
    int? refill,
    DateTime? openedAt,
    Value<DateTime?> closedAt = const Value.absent(),
  }) => BankMonthRow(
    month: month ?? this.month,
    firstDay: firstDay ?? this.firstDay,
    configJson: configJson ?? this.configJson,
    mealPlanJson: mealPlanJson ?? this.mealPlanJson,
    reservesJson: reservesJson ?? this.reservesJson,
    refill: refill ?? this.refill,
    openedAt: openedAt ?? this.openedAt,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
  );
  BankMonthRow copyWithCompanion(BankMonthsCompanion data) {
    return BankMonthRow(
      month: data.month.present ? data.month.value : this.month,
      firstDay: data.firstDay.present ? data.firstDay.value : this.firstDay,
      configJson: data.configJson.present
          ? data.configJson.value
          : this.configJson,
      mealPlanJson: data.mealPlanJson.present
          ? data.mealPlanJson.value
          : this.mealPlanJson,
      reservesJson: data.reservesJson.present
          ? data.reservesJson.value
          : this.reservesJson,
      refill: data.refill.present ? data.refill.value : this.refill,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BankMonthRow(')
          ..write('month: $month, ')
          ..write('firstDay: $firstDay, ')
          ..write('configJson: $configJson, ')
          ..write('mealPlanJson: $mealPlanJson, ')
          ..write('reservesJson: $reservesJson, ')
          ..write('refill: $refill, ')
          ..write('openedAt: $openedAt, ')
          ..write('closedAt: $closedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    month,
    firstDay,
    configJson,
    mealPlanJson,
    reservesJson,
    refill,
    openedAt,
    closedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BankMonthRow &&
          other.month == this.month &&
          other.firstDay == this.firstDay &&
          other.configJson == this.configJson &&
          other.mealPlanJson == this.mealPlanJson &&
          other.reservesJson == this.reservesJson &&
          other.refill == this.refill &&
          other.openedAt == this.openedAt &&
          other.closedAt == this.closedAt);
}

class BankMonthsCompanion extends UpdateCompanion<BankMonthRow> {
  final Value<String> month;
  final Value<LogicalDay> firstDay;
  final Value<String> configJson;
  final Value<String> mealPlanJson;
  final Value<String> reservesJson;
  final Value<int> refill;
  final Value<DateTime> openedAt;
  final Value<DateTime?> closedAt;
  final Value<int> rowid;
  const BankMonthsCompanion({
    this.month = const Value.absent(),
    this.firstDay = const Value.absent(),
    this.configJson = const Value.absent(),
    this.mealPlanJson = const Value.absent(),
    this.reservesJson = const Value.absent(),
    this.refill = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BankMonthsCompanion.insert({
    required String month,
    required LogicalDay firstDay,
    required String configJson,
    required String mealPlanJson,
    this.reservesJson = const Value.absent(),
    required int refill,
    required DateTime openedAt,
    this.closedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : month = Value(month),
       firstDay = Value(firstDay),
       configJson = Value(configJson),
       mealPlanJson = Value(mealPlanJson),
       refill = Value(refill),
       openedAt = Value(openedAt);
  static Insertable<BankMonthRow> custom({
    Expression<String>? month,
    Expression<String>? firstDay,
    Expression<String>? configJson,
    Expression<String>? mealPlanJson,
    Expression<String>? reservesJson,
    Expression<int>? refill,
    Expression<DateTime>? openedAt,
    Expression<DateTime>? closedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (month != null) 'month': month,
      if (firstDay != null) 'first_day': firstDay,
      if (configJson != null) 'config_json': configJson,
      if (mealPlanJson != null) 'meal_plan_json': mealPlanJson,
      if (reservesJson != null) 'reserves_json': reservesJson,
      if (refill != null) 'refill': refill,
      if (openedAt != null) 'opened_at': openedAt,
      if (closedAt != null) 'closed_at': closedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BankMonthsCompanion copyWith({
    Value<String>? month,
    Value<LogicalDay>? firstDay,
    Value<String>? configJson,
    Value<String>? mealPlanJson,
    Value<String>? reservesJson,
    Value<int>? refill,
    Value<DateTime>? openedAt,
    Value<DateTime?>? closedAt,
    Value<int>? rowid,
  }) {
    return BankMonthsCompanion(
      month: month ?? this.month,
      firstDay: firstDay ?? this.firstDay,
      configJson: configJson ?? this.configJson,
      mealPlanJson: mealPlanJson ?? this.mealPlanJson,
      reservesJson: reservesJson ?? this.reservesJson,
      refill: refill ?? this.refill,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (month.present) {
      map['month'] = Variable<String>(month.value);
    }
    if (firstDay.present) {
      map['first_day'] = Variable<String>(
        $BankMonthsTable.$converterfirstDay.toSql(firstDay.value),
      );
    }
    if (configJson.present) {
      map['config_json'] = Variable<String>(configJson.value);
    }
    if (mealPlanJson.present) {
      map['meal_plan_json'] = Variable<String>(mealPlanJson.value);
    }
    if (reservesJson.present) {
      map['reserves_json'] = Variable<String>(reservesJson.value);
    }
    if (refill.present) {
      map['refill'] = Variable<int>(refill.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<DateTime>(openedAt.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BankMonthsCompanion(')
          ..write('month: $month, ')
          ..write('firstDay: $firstDay, ')
          ..write('configJson: $configJson, ')
          ..write('mealPlanJson: $mealPlanJson, ')
          ..write('reservesJson: $reservesJson, ')
          ..write('refill: $refill, ')
          ..write('openedAt: $openedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CasinoWeeksTable extends CasinoWeeks
    with TableInfo<$CasinoWeeksTable, CasinoWeekRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CasinoWeeksTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<LogicalDay, String> weekStart =
      GeneratedColumn<String>(
        'week_start',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LogicalDay>($CasinoWeeksTable.$converterweekStart);
  @override
  late final GeneratedColumnWithTypeConverter<LogicalDay, String> fromDay =
      GeneratedColumn<String>(
        'from_day',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LogicalDay>($CasinoWeeksTable.$converterfromDay);
  static const VerificationMeta _poolBeforeMeta = const VerificationMeta(
    'poolBefore',
  );
  @override
  late final GeneratedColumn<int> poolBefore = GeneratedColumn<int>(
    'pool_before',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _releasedMeta = const VerificationMeta(
    'released',
  );
  @override
  late final GeneratedColumn<int> released = GeneratedColumn<int>(
    'released',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<int> price = GeneratedColumn<int>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetGoldMeta = const VerificationMeta(
    'targetGold',
  );
  @override
  late final GeneratedColumn<int> targetGold = GeneratedColumn<int>(
    'target_gold',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceLevelMeta = const VerificationMeta(
    'priceLevel',
  );
  @override
  late final GeneratedColumn<int> priceLevel = GeneratedColumn<int>(
    'price_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _termsJsonMeta = const VerificationMeta(
    'termsJson',
  );
  @override
  late final GeneratedColumn<String> termsJson = GeneratedColumn<String>(
    'terms_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _openedAtMeta = const VerificationMeta(
    'openedAt',
  );
  @override
  late final GeneratedColumn<DateTime> openedAt = GeneratedColumn<DateTime>(
    'opened_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _settledAtMeta = const VerificationMeta(
    'settledAt',
  );
  @override
  late final GeneratedColumn<DateTime> settledAt = GeneratedColumn<DateTime>(
    'settled_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sweptMeta = const VerificationMeta('swept');
  @override
  late final GeneratedColumn<int> swept = GeneratedColumn<int>(
    'swept',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    weekStart,
    fromDay,
    poolBefore,
    released,
    price,
    targetGold,
    priceLevel,
    termsJson,
    openedAt,
    settledAt,
    swept,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'casino_weeks';
  @override
  VerificationContext validateIntegrity(
    Insertable<CasinoWeekRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pool_before')) {
      context.handle(
        _poolBeforeMeta,
        poolBefore.isAcceptableOrUnknown(data['pool_before']!, _poolBeforeMeta),
      );
    } else if (isInserting) {
      context.missing(_poolBeforeMeta);
    }
    if (data.containsKey('released')) {
      context.handle(
        _releasedMeta,
        released.isAcceptableOrUnknown(data['released']!, _releasedMeta),
      );
    } else if (isInserting) {
      context.missing(_releasedMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('target_gold')) {
      context.handle(
        _targetGoldMeta,
        targetGold.isAcceptableOrUnknown(data['target_gold']!, _targetGoldMeta),
      );
    } else if (isInserting) {
      context.missing(_targetGoldMeta);
    }
    if (data.containsKey('price_level')) {
      context.handle(
        _priceLevelMeta,
        priceLevel.isAcceptableOrUnknown(data['price_level']!, _priceLevelMeta),
      );
    } else if (isInserting) {
      context.missing(_priceLevelMeta);
    }
    if (data.containsKey('terms_json')) {
      context.handle(
        _termsJsonMeta,
        termsJson.isAcceptableOrUnknown(data['terms_json']!, _termsJsonMeta),
      );
    }
    if (data.containsKey('opened_at')) {
      context.handle(
        _openedAtMeta,
        openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_openedAtMeta);
    }
    if (data.containsKey('settled_at')) {
      context.handle(
        _settledAtMeta,
        settledAt.isAcceptableOrUnknown(data['settled_at']!, _settledAtMeta),
      );
    }
    if (data.containsKey('swept')) {
      context.handle(
        _sweptMeta,
        swept.isAcceptableOrUnknown(data['swept']!, _sweptMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {weekStart};
  @override
  CasinoWeekRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CasinoWeekRow(
      weekStart: $CasinoWeeksTable.$converterweekStart.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}week_start'],
        )!,
      ),
      fromDay: $CasinoWeeksTable.$converterfromDay.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}from_day'],
        )!,
      ),
      poolBefore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pool_before'],
      )!,
      released: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}released'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price'],
      )!,
      targetGold: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_gold'],
      )!,
      priceLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}price_level'],
      )!,
      termsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}terms_json'],
      )!,
      openedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}opened_at'],
      )!,
      settledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}settled_at'],
      ),
      swept: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}swept'],
      ),
    );
  }

  @override
  $CasinoWeeksTable createAlias(String alias) {
    return $CasinoWeeksTable(attachedDatabase, alias);
  }

  static TypeConverter<LogicalDay, String> $converterweekStart =
      const LogicalDayConverter();
  static TypeConverter<LogicalDay, String> $converterfromDay =
      const LogicalDayConverter();
}

class CasinoWeekRow extends DataClass implements Insertable<CasinoWeekRow> {
  final LogicalDay weekStart;

  /// The week's first day, or the day the casino opened.
  final LogicalDay fromDay;

  /// What the pool had free before the week took its money.
  final int poolBefore;

  /// The week's prize money; 0 when the pool had nothing to give.
  final int released;

  /// Gold per draw.
  final int price;

  /// The gold of the week with everything done (G*) the price is set on.
  final int targetGold;

  /// The week's price level, in percent.
  final int priceLevel;

  /// The month's release plan and the numbers the price came from.
  final String termsJson;
  final DateTime openedAt;

  /// Set once the week is closed, with what went to the invest envelope.
  final DateTime? settledAt;
  final int? swept;
  const CasinoWeekRow({
    required this.weekStart,
    required this.fromDay,
    required this.poolBefore,
    required this.released,
    required this.price,
    required this.targetGold,
    required this.priceLevel,
    required this.termsJson,
    required this.openedAt,
    this.settledAt,
    this.swept,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['week_start'] = Variable<String>(
        $CasinoWeeksTable.$converterweekStart.toSql(weekStart),
      );
    }
    {
      map['from_day'] = Variable<String>(
        $CasinoWeeksTable.$converterfromDay.toSql(fromDay),
      );
    }
    map['pool_before'] = Variable<int>(poolBefore);
    map['released'] = Variable<int>(released);
    map['price'] = Variable<int>(price);
    map['target_gold'] = Variable<int>(targetGold);
    map['price_level'] = Variable<int>(priceLevel);
    map['terms_json'] = Variable<String>(termsJson);
    map['opened_at'] = Variable<DateTime>(openedAt);
    if (!nullToAbsent || settledAt != null) {
      map['settled_at'] = Variable<DateTime>(settledAt);
    }
    if (!nullToAbsent || swept != null) {
      map['swept'] = Variable<int>(swept);
    }
    return map;
  }

  CasinoWeeksCompanion toCompanion(bool nullToAbsent) {
    return CasinoWeeksCompanion(
      weekStart: Value(weekStart),
      fromDay: Value(fromDay),
      poolBefore: Value(poolBefore),
      released: Value(released),
      price: Value(price),
      targetGold: Value(targetGold),
      priceLevel: Value(priceLevel),
      termsJson: Value(termsJson),
      openedAt: Value(openedAt),
      settledAt: settledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(settledAt),
      swept: swept == null && nullToAbsent
          ? const Value.absent()
          : Value(swept),
    );
  }

  factory CasinoWeekRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CasinoWeekRow(
      weekStart: serializer.fromJson<LogicalDay>(json['weekStart']),
      fromDay: serializer.fromJson<LogicalDay>(json['fromDay']),
      poolBefore: serializer.fromJson<int>(json['poolBefore']),
      released: serializer.fromJson<int>(json['released']),
      price: serializer.fromJson<int>(json['price']),
      targetGold: serializer.fromJson<int>(json['targetGold']),
      priceLevel: serializer.fromJson<int>(json['priceLevel']),
      termsJson: serializer.fromJson<String>(json['termsJson']),
      openedAt: serializer.fromJson<DateTime>(json['openedAt']),
      settledAt: serializer.fromJson<DateTime?>(json['settledAt']),
      swept: serializer.fromJson<int?>(json['swept']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'weekStart': serializer.toJson<LogicalDay>(weekStart),
      'fromDay': serializer.toJson<LogicalDay>(fromDay),
      'poolBefore': serializer.toJson<int>(poolBefore),
      'released': serializer.toJson<int>(released),
      'price': serializer.toJson<int>(price),
      'targetGold': serializer.toJson<int>(targetGold),
      'priceLevel': serializer.toJson<int>(priceLevel),
      'termsJson': serializer.toJson<String>(termsJson),
      'openedAt': serializer.toJson<DateTime>(openedAt),
      'settledAt': serializer.toJson<DateTime?>(settledAt),
      'swept': serializer.toJson<int?>(swept),
    };
  }

  CasinoWeekRow copyWith({
    LogicalDay? weekStart,
    LogicalDay? fromDay,
    int? poolBefore,
    int? released,
    int? price,
    int? targetGold,
    int? priceLevel,
    String? termsJson,
    DateTime? openedAt,
    Value<DateTime?> settledAt = const Value.absent(),
    Value<int?> swept = const Value.absent(),
  }) => CasinoWeekRow(
    weekStart: weekStart ?? this.weekStart,
    fromDay: fromDay ?? this.fromDay,
    poolBefore: poolBefore ?? this.poolBefore,
    released: released ?? this.released,
    price: price ?? this.price,
    targetGold: targetGold ?? this.targetGold,
    priceLevel: priceLevel ?? this.priceLevel,
    termsJson: termsJson ?? this.termsJson,
    openedAt: openedAt ?? this.openedAt,
    settledAt: settledAt.present ? settledAt.value : this.settledAt,
    swept: swept.present ? swept.value : this.swept,
  );
  CasinoWeekRow copyWithCompanion(CasinoWeeksCompanion data) {
    return CasinoWeekRow(
      weekStart: data.weekStart.present ? data.weekStart.value : this.weekStart,
      fromDay: data.fromDay.present ? data.fromDay.value : this.fromDay,
      poolBefore: data.poolBefore.present
          ? data.poolBefore.value
          : this.poolBefore,
      released: data.released.present ? data.released.value : this.released,
      price: data.price.present ? data.price.value : this.price,
      targetGold: data.targetGold.present
          ? data.targetGold.value
          : this.targetGold,
      priceLevel: data.priceLevel.present
          ? data.priceLevel.value
          : this.priceLevel,
      termsJson: data.termsJson.present ? data.termsJson.value : this.termsJson,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
      settledAt: data.settledAt.present ? data.settledAt.value : this.settledAt,
      swept: data.swept.present ? data.swept.value : this.swept,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CasinoWeekRow(')
          ..write('weekStart: $weekStart, ')
          ..write('fromDay: $fromDay, ')
          ..write('poolBefore: $poolBefore, ')
          ..write('released: $released, ')
          ..write('price: $price, ')
          ..write('targetGold: $targetGold, ')
          ..write('priceLevel: $priceLevel, ')
          ..write('termsJson: $termsJson, ')
          ..write('openedAt: $openedAt, ')
          ..write('settledAt: $settledAt, ')
          ..write('swept: $swept')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    weekStart,
    fromDay,
    poolBefore,
    released,
    price,
    targetGold,
    priceLevel,
    termsJson,
    openedAt,
    settledAt,
    swept,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CasinoWeekRow &&
          other.weekStart == this.weekStart &&
          other.fromDay == this.fromDay &&
          other.poolBefore == this.poolBefore &&
          other.released == this.released &&
          other.price == this.price &&
          other.targetGold == this.targetGold &&
          other.priceLevel == this.priceLevel &&
          other.termsJson == this.termsJson &&
          other.openedAt == this.openedAt &&
          other.settledAt == this.settledAt &&
          other.swept == this.swept);
}

class CasinoWeeksCompanion extends UpdateCompanion<CasinoWeekRow> {
  final Value<LogicalDay> weekStart;
  final Value<LogicalDay> fromDay;
  final Value<int> poolBefore;
  final Value<int> released;
  final Value<int> price;
  final Value<int> targetGold;
  final Value<int> priceLevel;
  final Value<String> termsJson;
  final Value<DateTime> openedAt;
  final Value<DateTime?> settledAt;
  final Value<int?> swept;
  final Value<int> rowid;
  const CasinoWeeksCompanion({
    this.weekStart = const Value.absent(),
    this.fromDay = const Value.absent(),
    this.poolBefore = const Value.absent(),
    this.released = const Value.absent(),
    this.price = const Value.absent(),
    this.targetGold = const Value.absent(),
    this.priceLevel = const Value.absent(),
    this.termsJson = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.settledAt = const Value.absent(),
    this.swept = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CasinoWeeksCompanion.insert({
    required LogicalDay weekStart,
    required LogicalDay fromDay,
    required int poolBefore,
    required int released,
    required int price,
    required int targetGold,
    required int priceLevel,
    this.termsJson = const Value.absent(),
    required DateTime openedAt,
    this.settledAt = const Value.absent(),
    this.swept = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : weekStart = Value(weekStart),
       fromDay = Value(fromDay),
       poolBefore = Value(poolBefore),
       released = Value(released),
       price = Value(price),
       targetGold = Value(targetGold),
       priceLevel = Value(priceLevel),
       openedAt = Value(openedAt);
  static Insertable<CasinoWeekRow> custom({
    Expression<String>? weekStart,
    Expression<String>? fromDay,
    Expression<int>? poolBefore,
    Expression<int>? released,
    Expression<int>? price,
    Expression<int>? targetGold,
    Expression<int>? priceLevel,
    Expression<String>? termsJson,
    Expression<DateTime>? openedAt,
    Expression<DateTime>? settledAt,
    Expression<int>? swept,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (weekStart != null) 'week_start': weekStart,
      if (fromDay != null) 'from_day': fromDay,
      if (poolBefore != null) 'pool_before': poolBefore,
      if (released != null) 'released': released,
      if (price != null) 'price': price,
      if (targetGold != null) 'target_gold': targetGold,
      if (priceLevel != null) 'price_level': priceLevel,
      if (termsJson != null) 'terms_json': termsJson,
      if (openedAt != null) 'opened_at': openedAt,
      if (settledAt != null) 'settled_at': settledAt,
      if (swept != null) 'swept': swept,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CasinoWeeksCompanion copyWith({
    Value<LogicalDay>? weekStart,
    Value<LogicalDay>? fromDay,
    Value<int>? poolBefore,
    Value<int>? released,
    Value<int>? price,
    Value<int>? targetGold,
    Value<int>? priceLevel,
    Value<String>? termsJson,
    Value<DateTime>? openedAt,
    Value<DateTime?>? settledAt,
    Value<int?>? swept,
    Value<int>? rowid,
  }) {
    return CasinoWeeksCompanion(
      weekStart: weekStart ?? this.weekStart,
      fromDay: fromDay ?? this.fromDay,
      poolBefore: poolBefore ?? this.poolBefore,
      released: released ?? this.released,
      price: price ?? this.price,
      targetGold: targetGold ?? this.targetGold,
      priceLevel: priceLevel ?? this.priceLevel,
      termsJson: termsJson ?? this.termsJson,
      openedAt: openedAt ?? this.openedAt,
      settledAt: settledAt ?? this.settledAt,
      swept: swept ?? this.swept,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (weekStart.present) {
      map['week_start'] = Variable<String>(
        $CasinoWeeksTable.$converterweekStart.toSql(weekStart.value),
      );
    }
    if (fromDay.present) {
      map['from_day'] = Variable<String>(
        $CasinoWeeksTable.$converterfromDay.toSql(fromDay.value),
      );
    }
    if (poolBefore.present) {
      map['pool_before'] = Variable<int>(poolBefore.value);
    }
    if (released.present) {
      map['released'] = Variable<int>(released.value);
    }
    if (price.present) {
      map['price'] = Variable<int>(price.value);
    }
    if (targetGold.present) {
      map['target_gold'] = Variable<int>(targetGold.value);
    }
    if (priceLevel.present) {
      map['price_level'] = Variable<int>(priceLevel.value);
    }
    if (termsJson.present) {
      map['terms_json'] = Variable<String>(termsJson.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<DateTime>(openedAt.value);
    }
    if (settledAt.present) {
      map['settled_at'] = Variable<DateTime>(settledAt.value);
    }
    if (swept.present) {
      map['swept'] = Variable<int>(swept.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CasinoWeeksCompanion(')
          ..write('weekStart: $weekStart, ')
          ..write('fromDay: $fromDay, ')
          ..write('poolBefore: $poolBefore, ')
          ..write('released: $released, ')
          ..write('price: $price, ')
          ..write('targetGold: $targetGold, ')
          ..write('priceLevel: $priceLevel, ')
          ..write('termsJson: $termsJson, ')
          ..write('openedAt: $openedAt, ')
          ..write('settledAt: $settledAt, ')
          ..write('swept: $swept, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CasinoTicketsTable extends CasinoTickets
    with TableInfo<$CasinoTicketsTable, CasinoTicketRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CasinoTicketsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LogicalDay, String> weekStart =
      GeneratedColumn<String>(
        'week_start',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LogicalDay>($CasinoTicketsTable.$converterweekStart);
  @override
  late final GeneratedColumnWithTypeConverter<TicketKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TicketKind>($CasinoTicketsTable.$converterkind);
  @override
  late final GeneratedColumnWithTypeConverter<PrizeTier?, String> tier =
      GeneratedColumn<String>(
        'tier',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<PrizeTier?>($CasinoTicketsTable.$convertertiern);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<int> accountId = GeneratedColumn<int>(
    'account_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _drawnAtMeta = const VerificationMeta(
    'drawnAt',
  );
  @override
  late final GeneratedColumn<DateTime> drawnAt = GeneratedColumn<DateTime>(
    'drawn_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CasinoGame?, String> game =
      GeneratedColumn<String>(
        'game',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<CasinoGame?>($CasinoTicketsTable.$convertergamen);
  static const VerificationMeta _paidMeta = const VerificationMeta('paid');
  @override
  late final GeneratedColumn<int> paid = GeneratedColumn<int>(
    'paid',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    weekStart,
    kind,
    tier,
    amount,
    accountId,
    drawnAt,
    game,
    paid,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'casino_tickets';
  @override
  VerificationContext validateIntegrity(
    Insertable<CasinoTicketRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    }
    if (data.containsKey('drawn_at')) {
      context.handle(
        _drawnAtMeta,
        drawnAt.isAcceptableOrUnknown(data['drawn_at']!, _drawnAtMeta),
      );
    }
    if (data.containsKey('paid')) {
      context.handle(
        _paidMeta,
        paid.isAcceptableOrUnknown(data['paid']!, _paidMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CasinoTicketRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CasinoTicketRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      weekStart: $CasinoTicketsTable.$converterweekStart.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}week_start'],
        )!,
      ),
      kind: $CasinoTicketsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      tier: $CasinoTicketsTable.$convertertiern.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tier'],
        ),
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}account_id'],
      ),
      drawnAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}drawn_at'],
      ),
      game: $CasinoTicketsTable.$convertergamen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}game'],
        ),
      ),
      paid: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paid'],
      ),
    );
  }

  @override
  $CasinoTicketsTable createAlias(String alias) {
    return $CasinoTicketsTable(attachedDatabase, alias);
  }

  static TypeConverter<LogicalDay, String> $converterweekStart =
      const LogicalDayConverter();
  static JsonTypeConverter2<TicketKind, String, String> $converterkind =
      const EnumNameConverter<TicketKind>(TicketKind.values);
  static JsonTypeConverter2<PrizeTier, String, String> $convertertier =
      const EnumNameConverter<PrizeTier>(PrizeTier.values);
  static JsonTypeConverter2<PrizeTier?, String?, String?> $convertertiern =
      JsonTypeConverter2.asNullable($convertertier);
  static JsonTypeConverter2<CasinoGame, String, String> $convertergame =
      const EnumNameConverter<CasinoGame>(CasinoGame.values);
  static JsonTypeConverter2<CasinoGame?, String?, String?> $convertergamen =
      JsonTypeConverter2.asNullable($convertergame);
}

class CasinoTicketRow extends DataClass implements Insertable<CasinoTicketRow> {
  final int id;
  final LogicalDay weekStart;
  final TicketKind kind;

  /// Null for a refund.
  final PrizeTier? tier;
  final int amount;

  /// The envelope a prize pays into; null for a refund.
  final int? accountId;

  /// Set once drawn, with the game it was drawn in and the gold paid.
  final DateTime? drawnAt;
  final CasinoGame? game;
  final int? paid;
  const CasinoTicketRow({
    required this.id,
    required this.weekStart,
    required this.kind,
    this.tier,
    required this.amount,
    this.accountId,
    this.drawnAt,
    this.game,
    this.paid,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['week_start'] = Variable<String>(
        $CasinoTicketsTable.$converterweekStart.toSql(weekStart),
      );
    }
    {
      map['kind'] = Variable<String>(
        $CasinoTicketsTable.$converterkind.toSql(kind),
      );
    }
    if (!nullToAbsent || tier != null) {
      map['tier'] = Variable<String>(
        $CasinoTicketsTable.$convertertiern.toSql(tier),
      );
    }
    map['amount'] = Variable<int>(amount);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<int>(accountId);
    }
    if (!nullToAbsent || drawnAt != null) {
      map['drawn_at'] = Variable<DateTime>(drawnAt);
    }
    if (!nullToAbsent || game != null) {
      map['game'] = Variable<String>(
        $CasinoTicketsTable.$convertergamen.toSql(game),
      );
    }
    if (!nullToAbsent || paid != null) {
      map['paid'] = Variable<int>(paid);
    }
    return map;
  }

  CasinoTicketsCompanion toCompanion(bool nullToAbsent) {
    return CasinoTicketsCompanion(
      id: Value(id),
      weekStart: Value(weekStart),
      kind: Value(kind),
      tier: tier == null && nullToAbsent ? const Value.absent() : Value(tier),
      amount: Value(amount),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      drawnAt: drawnAt == null && nullToAbsent
          ? const Value.absent()
          : Value(drawnAt),
      game: game == null && nullToAbsent ? const Value.absent() : Value(game),
      paid: paid == null && nullToAbsent ? const Value.absent() : Value(paid),
    );
  }

  factory CasinoTicketRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CasinoTicketRow(
      id: serializer.fromJson<int>(json['id']),
      weekStart: serializer.fromJson<LogicalDay>(json['weekStart']),
      kind: $CasinoTicketsTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      tier: $CasinoTicketsTable.$convertertiern.fromJson(
        serializer.fromJson<String?>(json['tier']),
      ),
      amount: serializer.fromJson<int>(json['amount']),
      accountId: serializer.fromJson<int?>(json['accountId']),
      drawnAt: serializer.fromJson<DateTime?>(json['drawnAt']),
      game: $CasinoTicketsTable.$convertergamen.fromJson(
        serializer.fromJson<String?>(json['game']),
      ),
      paid: serializer.fromJson<int?>(json['paid']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'weekStart': serializer.toJson<LogicalDay>(weekStart),
      'kind': serializer.toJson<String>(
        $CasinoTicketsTable.$converterkind.toJson(kind),
      ),
      'tier': serializer.toJson<String?>(
        $CasinoTicketsTable.$convertertiern.toJson(tier),
      ),
      'amount': serializer.toJson<int>(amount),
      'accountId': serializer.toJson<int?>(accountId),
      'drawnAt': serializer.toJson<DateTime?>(drawnAt),
      'game': serializer.toJson<String?>(
        $CasinoTicketsTable.$convertergamen.toJson(game),
      ),
      'paid': serializer.toJson<int?>(paid),
    };
  }

  CasinoTicketRow copyWith({
    int? id,
    LogicalDay? weekStart,
    TicketKind? kind,
    Value<PrizeTier?> tier = const Value.absent(),
    int? amount,
    Value<int?> accountId = const Value.absent(),
    Value<DateTime?> drawnAt = const Value.absent(),
    Value<CasinoGame?> game = const Value.absent(),
    Value<int?> paid = const Value.absent(),
  }) => CasinoTicketRow(
    id: id ?? this.id,
    weekStart: weekStart ?? this.weekStart,
    kind: kind ?? this.kind,
    tier: tier.present ? tier.value : this.tier,
    amount: amount ?? this.amount,
    accountId: accountId.present ? accountId.value : this.accountId,
    drawnAt: drawnAt.present ? drawnAt.value : this.drawnAt,
    game: game.present ? game.value : this.game,
    paid: paid.present ? paid.value : this.paid,
  );
  CasinoTicketRow copyWithCompanion(CasinoTicketsCompanion data) {
    return CasinoTicketRow(
      id: data.id.present ? data.id.value : this.id,
      weekStart: data.weekStart.present ? data.weekStart.value : this.weekStart,
      kind: data.kind.present ? data.kind.value : this.kind,
      tier: data.tier.present ? data.tier.value : this.tier,
      amount: data.amount.present ? data.amount.value : this.amount,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      drawnAt: data.drawnAt.present ? data.drawnAt.value : this.drawnAt,
      game: data.game.present ? data.game.value : this.game,
      paid: data.paid.present ? data.paid.value : this.paid,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CasinoTicketRow(')
          ..write('id: $id, ')
          ..write('weekStart: $weekStart, ')
          ..write('kind: $kind, ')
          ..write('tier: $tier, ')
          ..write('amount: $amount, ')
          ..write('accountId: $accountId, ')
          ..write('drawnAt: $drawnAt, ')
          ..write('game: $game, ')
          ..write('paid: $paid')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    weekStart,
    kind,
    tier,
    amount,
    accountId,
    drawnAt,
    game,
    paid,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CasinoTicketRow &&
          other.id == this.id &&
          other.weekStart == this.weekStart &&
          other.kind == this.kind &&
          other.tier == this.tier &&
          other.amount == this.amount &&
          other.accountId == this.accountId &&
          other.drawnAt == this.drawnAt &&
          other.game == this.game &&
          other.paid == this.paid);
}

class CasinoTicketsCompanion extends UpdateCompanion<CasinoTicketRow> {
  final Value<int> id;
  final Value<LogicalDay> weekStart;
  final Value<TicketKind> kind;
  final Value<PrizeTier?> tier;
  final Value<int> amount;
  final Value<int?> accountId;
  final Value<DateTime?> drawnAt;
  final Value<CasinoGame?> game;
  final Value<int?> paid;
  const CasinoTicketsCompanion({
    this.id = const Value.absent(),
    this.weekStart = const Value.absent(),
    this.kind = const Value.absent(),
    this.tier = const Value.absent(),
    this.amount = const Value.absent(),
    this.accountId = const Value.absent(),
    this.drawnAt = const Value.absent(),
    this.game = const Value.absent(),
    this.paid = const Value.absent(),
  });
  CasinoTicketsCompanion.insert({
    this.id = const Value.absent(),
    required LogicalDay weekStart,
    required TicketKind kind,
    this.tier = const Value.absent(),
    this.amount = const Value.absent(),
    this.accountId = const Value.absent(),
    this.drawnAt = const Value.absent(),
    this.game = const Value.absent(),
    this.paid = const Value.absent(),
  }) : weekStart = Value(weekStart),
       kind = Value(kind);
  static Insertable<CasinoTicketRow> custom({
    Expression<int>? id,
    Expression<String>? weekStart,
    Expression<String>? kind,
    Expression<String>? tier,
    Expression<int>? amount,
    Expression<int>? accountId,
    Expression<DateTime>? drawnAt,
    Expression<String>? game,
    Expression<int>? paid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (weekStart != null) 'week_start': weekStart,
      if (kind != null) 'kind': kind,
      if (tier != null) 'tier': tier,
      if (amount != null) 'amount': amount,
      if (accountId != null) 'account_id': accountId,
      if (drawnAt != null) 'drawn_at': drawnAt,
      if (game != null) 'game': game,
      if (paid != null) 'paid': paid,
    });
  }

  CasinoTicketsCompanion copyWith({
    Value<int>? id,
    Value<LogicalDay>? weekStart,
    Value<TicketKind>? kind,
    Value<PrizeTier?>? tier,
    Value<int>? amount,
    Value<int?>? accountId,
    Value<DateTime?>? drawnAt,
    Value<CasinoGame?>? game,
    Value<int?>? paid,
  }) {
    return CasinoTicketsCompanion(
      id: id ?? this.id,
      weekStart: weekStart ?? this.weekStart,
      kind: kind ?? this.kind,
      tier: tier ?? this.tier,
      amount: amount ?? this.amount,
      accountId: accountId ?? this.accountId,
      drawnAt: drawnAt ?? this.drawnAt,
      game: game ?? this.game,
      paid: paid ?? this.paid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (weekStart.present) {
      map['week_start'] = Variable<String>(
        $CasinoTicketsTable.$converterweekStart.toSql(weekStart.value),
      );
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $CasinoTicketsTable.$converterkind.toSql(kind.value),
      );
    }
    if (tier.present) {
      map['tier'] = Variable<String>(
        $CasinoTicketsTable.$convertertiern.toSql(tier.value),
      );
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<int>(accountId.value);
    }
    if (drawnAt.present) {
      map['drawn_at'] = Variable<DateTime>(drawnAt.value);
    }
    if (game.present) {
      map['game'] = Variable<String>(
        $CasinoTicketsTable.$convertergamen.toSql(game.value),
      );
    }
    if (paid.present) {
      map['paid'] = Variable<int>(paid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CasinoTicketsCompanion(')
          ..write('id: $id, ')
          ..write('weekStart: $weekStart, ')
          ..write('kind: $kind, ')
          ..write('tier: $tier, ')
          ..write('amount: $amount, ')
          ..write('accountId: $accountId, ')
          ..write('drawnAt: $drawnAt, ')
          ..write('game: $game, ')
          ..write('paid: $paid')
          ..write(')'))
        .toString();
  }
}

class $ChaptersTable extends Chapters
    with TableInfo<$ChaptersTable, ChapterRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _numberMeta = const VerificationMeta('number');
  @override
  late final GeneratedColumn<int> number = GeneratedColumn<int>(
    'number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LogicalDay, String> periodStart =
      GeneratedColumn<String>(
        'period_start',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LogicalDay>($ChaptersTable.$converterperiodStart);
  static const VerificationMeta _periodDaysMeta = const VerificationMeta(
    'periodDays',
  );
  @override
  late final GeneratedColumn<int> periodDays = GeneratedColumn<int>(
    'period_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<ChapterStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ChapterStatus>($ChaptersTable.$converterstatus);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _choicesJsonMeta = const VerificationMeta(
    'choicesJson',
  );
  @override
  late final GeneratedColumn<String> choicesJson = GeneratedColumn<String>(
    'choices_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _chosenIndexMeta = const VerificationMeta(
    'chosenIndex',
  );
  @override
  late final GeneratedColumn<int> chosenIndex = GeneratedColumn<int>(
    'chosen_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recapMeta = const VerificationMeta('recap');
  @override
  late final GeneratedColumn<String> recap = GeneratedColumn<String>(
    'recap',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _judgementMeta = const VerificationMeta(
    'judgement',
  );
  @override
  late final GeneratedColumn<String> judgement = GeneratedColumn<String>(
    'judgement',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
    'score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statsJsonMeta = const VerificationMeta(
    'statsJson',
  );
  @override
  late final GeneratedColumn<String> statsJson = GeneratedColumn<String>(
    'stats_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _writtenAtMeta = const VerificationMeta(
    'writtenAt',
  );
  @override
  late final GeneratedColumn<DateTime> writtenAt = GeneratedColumn<DateTime>(
    'written_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    number,
    periodStart,
    periodDays,
    status,
    title,
    body,
    choicesJson,
    chosenIndex,
    recap,
    judgement,
    score,
    statsJson,
    createdAt,
    writtenAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapters';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChapterRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('number')) {
      context.handle(
        _numberMeta,
        number.isAcceptableOrUnknown(data['number']!, _numberMeta),
      );
    } else if (isInserting) {
      context.missing(_numberMeta);
    }
    if (data.containsKey('period_days')) {
      context.handle(
        _periodDaysMeta,
        periodDays.isAcceptableOrUnknown(data['period_days']!, _periodDaysMeta),
      );
    } else if (isInserting) {
      context.missing(_periodDaysMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    }
    if (data.containsKey('choices_json')) {
      context.handle(
        _choicesJsonMeta,
        choicesJson.isAcceptableOrUnknown(
          data['choices_json']!,
          _choicesJsonMeta,
        ),
      );
    }
    if (data.containsKey('chosen_index')) {
      context.handle(
        _chosenIndexMeta,
        chosenIndex.isAcceptableOrUnknown(
          data['chosen_index']!,
          _chosenIndexMeta,
        ),
      );
    }
    if (data.containsKey('recap')) {
      context.handle(
        _recapMeta,
        recap.isAcceptableOrUnknown(data['recap']!, _recapMeta),
      );
    }
    if (data.containsKey('judgement')) {
      context.handle(
        _judgementMeta,
        judgement.isAcceptableOrUnknown(data['judgement']!, _judgementMeta),
      );
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    }
    if (data.containsKey('stats_json')) {
      context.handle(
        _statsJsonMeta,
        statsJson.isAcceptableOrUnknown(data['stats_json']!, _statsJsonMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('written_at')) {
      context.handle(
        _writtenAtMeta,
        writtenAt.isAcceptableOrUnknown(data['written_at']!, _writtenAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChapterRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChapterRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      number: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number'],
      )!,
      periodStart: $ChaptersTable.$converterperiodStart.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}period_start'],
        )!,
      ),
      periodDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}period_days'],
      )!,
      status: $ChaptersTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      choicesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}choices_json'],
      )!,
      chosenIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chosen_index'],
      ),
      recap: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recap'],
      )!,
      judgement: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}judgement'],
      ),
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}score'],
      ),
      statsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stats_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      writtenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}written_at'],
      ),
    );
  }

  @override
  $ChaptersTable createAlias(String alias) {
    return $ChaptersTable(attachedDatabase, alias);
  }

  static TypeConverter<LogicalDay, String> $converterperiodStart =
      const LogicalDayConverter();
  static JsonTypeConverter2<ChapterStatus, String, String> $converterstatus =
      const EnumNameConverter<ChapterStatus>(ChapterStatus.values);
}

class ChapterRow extends DataClass implements Insertable<ChapterRow> {
  final int id;
  final int number;
  final LogicalDay periodStart;
  final int periodDays;
  final ChapterStatus status;
  final String title;
  final String body;
  final String choicesJson;
  final int? chosenIndex;
  final String recap;
  final String? judgement;
  final double? score;

  /// Snapshot of the period's stats sent to the AI, kept for re-sends.
  final String statsJson;
  final DateTime createdAt;
  final DateTime? writtenAt;
  const ChapterRow({
    required this.id,
    required this.number,
    required this.periodStart,
    required this.periodDays,
    required this.status,
    required this.title,
    required this.body,
    required this.choicesJson,
    this.chosenIndex,
    required this.recap,
    this.judgement,
    this.score,
    required this.statsJson,
    required this.createdAt,
    this.writtenAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['number'] = Variable<int>(number);
    {
      map['period_start'] = Variable<String>(
        $ChaptersTable.$converterperiodStart.toSql(periodStart),
      );
    }
    map['period_days'] = Variable<int>(periodDays);
    {
      map['status'] = Variable<String>(
        $ChaptersTable.$converterstatus.toSql(status),
      );
    }
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['choices_json'] = Variable<String>(choicesJson);
    if (!nullToAbsent || chosenIndex != null) {
      map['chosen_index'] = Variable<int>(chosenIndex);
    }
    map['recap'] = Variable<String>(recap);
    if (!nullToAbsent || judgement != null) {
      map['judgement'] = Variable<String>(judgement);
    }
    if (!nullToAbsent || score != null) {
      map['score'] = Variable<double>(score);
    }
    map['stats_json'] = Variable<String>(statsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || writtenAt != null) {
      map['written_at'] = Variable<DateTime>(writtenAt);
    }
    return map;
  }

  ChaptersCompanion toCompanion(bool nullToAbsent) {
    return ChaptersCompanion(
      id: Value(id),
      number: Value(number),
      periodStart: Value(periodStart),
      periodDays: Value(periodDays),
      status: Value(status),
      title: Value(title),
      body: Value(body),
      choicesJson: Value(choicesJson),
      chosenIndex: chosenIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(chosenIndex),
      recap: Value(recap),
      judgement: judgement == null && nullToAbsent
          ? const Value.absent()
          : Value(judgement),
      score: score == null && nullToAbsent
          ? const Value.absent()
          : Value(score),
      statsJson: Value(statsJson),
      createdAt: Value(createdAt),
      writtenAt: writtenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(writtenAt),
    );
  }

  factory ChapterRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChapterRow(
      id: serializer.fromJson<int>(json['id']),
      number: serializer.fromJson<int>(json['number']),
      periodStart: serializer.fromJson<LogicalDay>(json['periodStart']),
      periodDays: serializer.fromJson<int>(json['periodDays']),
      status: $ChaptersTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      choicesJson: serializer.fromJson<String>(json['choicesJson']),
      chosenIndex: serializer.fromJson<int?>(json['chosenIndex']),
      recap: serializer.fromJson<String>(json['recap']),
      judgement: serializer.fromJson<String?>(json['judgement']),
      score: serializer.fromJson<double?>(json['score']),
      statsJson: serializer.fromJson<String>(json['statsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      writtenAt: serializer.fromJson<DateTime?>(json['writtenAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'number': serializer.toJson<int>(number),
      'periodStart': serializer.toJson<LogicalDay>(periodStart),
      'periodDays': serializer.toJson<int>(periodDays),
      'status': serializer.toJson<String>(
        $ChaptersTable.$converterstatus.toJson(status),
      ),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'choicesJson': serializer.toJson<String>(choicesJson),
      'chosenIndex': serializer.toJson<int?>(chosenIndex),
      'recap': serializer.toJson<String>(recap),
      'judgement': serializer.toJson<String?>(judgement),
      'score': serializer.toJson<double?>(score),
      'statsJson': serializer.toJson<String>(statsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'writtenAt': serializer.toJson<DateTime?>(writtenAt),
    };
  }

  ChapterRow copyWith({
    int? id,
    int? number,
    LogicalDay? periodStart,
    int? periodDays,
    ChapterStatus? status,
    String? title,
    String? body,
    String? choicesJson,
    Value<int?> chosenIndex = const Value.absent(),
    String? recap,
    Value<String?> judgement = const Value.absent(),
    Value<double?> score = const Value.absent(),
    String? statsJson,
    DateTime? createdAt,
    Value<DateTime?> writtenAt = const Value.absent(),
  }) => ChapterRow(
    id: id ?? this.id,
    number: number ?? this.number,
    periodStart: periodStart ?? this.periodStart,
    periodDays: periodDays ?? this.periodDays,
    status: status ?? this.status,
    title: title ?? this.title,
    body: body ?? this.body,
    choicesJson: choicesJson ?? this.choicesJson,
    chosenIndex: chosenIndex.present ? chosenIndex.value : this.chosenIndex,
    recap: recap ?? this.recap,
    judgement: judgement.present ? judgement.value : this.judgement,
    score: score.present ? score.value : this.score,
    statsJson: statsJson ?? this.statsJson,
    createdAt: createdAt ?? this.createdAt,
    writtenAt: writtenAt.present ? writtenAt.value : this.writtenAt,
  );
  ChapterRow copyWithCompanion(ChaptersCompanion data) {
    return ChapterRow(
      id: data.id.present ? data.id.value : this.id,
      number: data.number.present ? data.number.value : this.number,
      periodStart: data.periodStart.present
          ? data.periodStart.value
          : this.periodStart,
      periodDays: data.periodDays.present
          ? data.periodDays.value
          : this.periodDays,
      status: data.status.present ? data.status.value : this.status,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      choicesJson: data.choicesJson.present
          ? data.choicesJson.value
          : this.choicesJson,
      chosenIndex: data.chosenIndex.present
          ? data.chosenIndex.value
          : this.chosenIndex,
      recap: data.recap.present ? data.recap.value : this.recap,
      judgement: data.judgement.present ? data.judgement.value : this.judgement,
      score: data.score.present ? data.score.value : this.score,
      statsJson: data.statsJson.present ? data.statsJson.value : this.statsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      writtenAt: data.writtenAt.present ? data.writtenAt.value : this.writtenAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChapterRow(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodDays: $periodDays, ')
          ..write('status: $status, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('choicesJson: $choicesJson, ')
          ..write('chosenIndex: $chosenIndex, ')
          ..write('recap: $recap, ')
          ..write('judgement: $judgement, ')
          ..write('score: $score, ')
          ..write('statsJson: $statsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('writtenAt: $writtenAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    number,
    periodStart,
    periodDays,
    status,
    title,
    body,
    choicesJson,
    chosenIndex,
    recap,
    judgement,
    score,
    statsJson,
    createdAt,
    writtenAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChapterRow &&
          other.id == this.id &&
          other.number == this.number &&
          other.periodStart == this.periodStart &&
          other.periodDays == this.periodDays &&
          other.status == this.status &&
          other.title == this.title &&
          other.body == this.body &&
          other.choicesJson == this.choicesJson &&
          other.chosenIndex == this.chosenIndex &&
          other.recap == this.recap &&
          other.judgement == this.judgement &&
          other.score == this.score &&
          other.statsJson == this.statsJson &&
          other.createdAt == this.createdAt &&
          other.writtenAt == this.writtenAt);
}

class ChaptersCompanion extends UpdateCompanion<ChapterRow> {
  final Value<int> id;
  final Value<int> number;
  final Value<LogicalDay> periodStart;
  final Value<int> periodDays;
  final Value<ChapterStatus> status;
  final Value<String> title;
  final Value<String> body;
  final Value<String> choicesJson;
  final Value<int?> chosenIndex;
  final Value<String> recap;
  final Value<String?> judgement;
  final Value<double?> score;
  final Value<String> statsJson;
  final Value<DateTime> createdAt;
  final Value<DateTime?> writtenAt;
  const ChaptersCompanion({
    this.id = const Value.absent(),
    this.number = const Value.absent(),
    this.periodStart = const Value.absent(),
    this.periodDays = const Value.absent(),
    this.status = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.choicesJson = const Value.absent(),
    this.chosenIndex = const Value.absent(),
    this.recap = const Value.absent(),
    this.judgement = const Value.absent(),
    this.score = const Value.absent(),
    this.statsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.writtenAt = const Value.absent(),
  });
  ChaptersCompanion.insert({
    this.id = const Value.absent(),
    required int number,
    required LogicalDay periodStart,
    required int periodDays,
    required ChapterStatus status,
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.choicesJson = const Value.absent(),
    this.chosenIndex = const Value.absent(),
    this.recap = const Value.absent(),
    this.judgement = const Value.absent(),
    this.score = const Value.absent(),
    this.statsJson = const Value.absent(),
    required DateTime createdAt,
    this.writtenAt = const Value.absent(),
  }) : number = Value(number),
       periodStart = Value(periodStart),
       periodDays = Value(periodDays),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<ChapterRow> custom({
    Expression<int>? id,
    Expression<int>? number,
    Expression<String>? periodStart,
    Expression<int>? periodDays,
    Expression<String>? status,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? choicesJson,
    Expression<int>? chosenIndex,
    Expression<String>? recap,
    Expression<String>? judgement,
    Expression<double>? score,
    Expression<String>? statsJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? writtenAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (number != null) 'number': number,
      if (periodStart != null) 'period_start': periodStart,
      if (periodDays != null) 'period_days': periodDays,
      if (status != null) 'status': status,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (choicesJson != null) 'choices_json': choicesJson,
      if (chosenIndex != null) 'chosen_index': chosenIndex,
      if (recap != null) 'recap': recap,
      if (judgement != null) 'judgement': judgement,
      if (score != null) 'score': score,
      if (statsJson != null) 'stats_json': statsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (writtenAt != null) 'written_at': writtenAt,
    });
  }

  ChaptersCompanion copyWith({
    Value<int>? id,
    Value<int>? number,
    Value<LogicalDay>? periodStart,
    Value<int>? periodDays,
    Value<ChapterStatus>? status,
    Value<String>? title,
    Value<String>? body,
    Value<String>? choicesJson,
    Value<int?>? chosenIndex,
    Value<String>? recap,
    Value<String?>? judgement,
    Value<double?>? score,
    Value<String>? statsJson,
    Value<DateTime>? createdAt,
    Value<DateTime?>? writtenAt,
  }) {
    return ChaptersCompanion(
      id: id ?? this.id,
      number: number ?? this.number,
      periodStart: periodStart ?? this.periodStart,
      periodDays: periodDays ?? this.periodDays,
      status: status ?? this.status,
      title: title ?? this.title,
      body: body ?? this.body,
      choicesJson: choicesJson ?? this.choicesJson,
      chosenIndex: chosenIndex ?? this.chosenIndex,
      recap: recap ?? this.recap,
      judgement: judgement ?? this.judgement,
      score: score ?? this.score,
      statsJson: statsJson ?? this.statsJson,
      createdAt: createdAt ?? this.createdAt,
      writtenAt: writtenAt ?? this.writtenAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (number.present) {
      map['number'] = Variable<int>(number.value);
    }
    if (periodStart.present) {
      map['period_start'] = Variable<String>(
        $ChaptersTable.$converterperiodStart.toSql(periodStart.value),
      );
    }
    if (periodDays.present) {
      map['period_days'] = Variable<int>(periodDays.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $ChaptersTable.$converterstatus.toSql(status.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (choicesJson.present) {
      map['choices_json'] = Variable<String>(choicesJson.value);
    }
    if (chosenIndex.present) {
      map['chosen_index'] = Variable<int>(chosenIndex.value);
    }
    if (recap.present) {
      map['recap'] = Variable<String>(recap.value);
    }
    if (judgement.present) {
      map['judgement'] = Variable<String>(judgement.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    if (statsJson.present) {
      map['stats_json'] = Variable<String>(statsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (writtenAt.present) {
      map['written_at'] = Variable<DateTime>(writtenAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChaptersCompanion(')
          ..write('id: $id, ')
          ..write('number: $number, ')
          ..write('periodStart: $periodStart, ')
          ..write('periodDays: $periodDays, ')
          ..write('status: $status, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('choicesJson: $choicesJson, ')
          ..write('chosenIndex: $chosenIndex, ')
          ..write('recap: $recap, ')
          ..write('judgement: $judgement, ')
          ..write('score: $score, ')
          ..write('statsJson: $statsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('writtenAt: $writtenAt')
          ..write(')'))
        .toString();
  }
}

class $UpgradeOffersTable extends UpgradeOffers
    with TableInfo<$UpgradeOffersTable, UpgradeOfferRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UpgradeOffersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _questIdMeta = const VerificationMeta(
    'questId',
  );
  @override
  late final GeneratedColumn<int> questId = GeneratedColumn<int>(
    'quest_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES quests (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<OfferKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<OfferKind>($UpgradeOffersTable.$converterkind);
  static const VerificationMeta _proposedTargetMeta = const VerificationMeta(
    'proposedTarget',
  );
  @override
  late final GeneratedColumn<double> proposedTarget = GeneratedColumn<double>(
    'proposed_target',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proposedTitleMeta = const VerificationMeta(
    'proposedTitle',
  );
  @override
  late final GeneratedColumn<String> proposedTitle = GeneratedColumn<String>(
    'proposed_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proposedSubtitleMeta = const VerificationMeta(
    'proposedSubtitle',
  );
  @override
  late final GeneratedColumn<String> proposedSubtitle = GeneratedColumn<String>(
    'proposed_subtitle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _npcLineMeta = const VerificationMeta(
    'npcLine',
  );
  @override
  late final GeneratedColumn<String> npcLine = GeneratedColumn<String>(
    'npc_line',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<OfferStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<OfferStatus>($UpgradeOffersTable.$converterstatus);
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<int> chapterId = GeneratedColumn<int>(
    'chapter_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    questId,
    kind,
    proposedTarget,
    proposedTitle,
    proposedSubtitle,
    npcLine,
    status,
    chapterId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'upgrade_offers';
  @override
  VerificationContext validateIntegrity(
    Insertable<UpgradeOfferRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('quest_id')) {
      context.handle(
        _questIdMeta,
        questId.isAcceptableOrUnknown(data['quest_id']!, _questIdMeta),
      );
    } else if (isInserting) {
      context.missing(_questIdMeta);
    }
    if (data.containsKey('proposed_target')) {
      context.handle(
        _proposedTargetMeta,
        proposedTarget.isAcceptableOrUnknown(
          data['proposed_target']!,
          _proposedTargetMeta,
        ),
      );
    }
    if (data.containsKey('proposed_title')) {
      context.handle(
        _proposedTitleMeta,
        proposedTitle.isAcceptableOrUnknown(
          data['proposed_title']!,
          _proposedTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_proposedTitleMeta);
    }
    if (data.containsKey('proposed_subtitle')) {
      context.handle(
        _proposedSubtitleMeta,
        proposedSubtitle.isAcceptableOrUnknown(
          data['proposed_subtitle']!,
          _proposedSubtitleMeta,
        ),
      );
    }
    if (data.containsKey('npc_line')) {
      context.handle(
        _npcLineMeta,
        npcLine.isAcceptableOrUnknown(data['npc_line']!, _npcLineMeta),
      );
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UpgradeOfferRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UpgradeOfferRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      questId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quest_id'],
      )!,
      kind: $UpgradeOffersTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      proposedTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}proposed_target'],
      ),
      proposedTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}proposed_title'],
      )!,
      proposedSubtitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}proposed_subtitle'],
      )!,
      npcLine: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}npc_line'],
      )!,
      status: $UpgradeOffersTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UpgradeOffersTable createAlias(String alias) {
    return $UpgradeOffersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<OfferKind, String, String> $converterkind =
      const EnumNameConverter<OfferKind>(OfferKind.values);
  static JsonTypeConverter2<OfferStatus, String, String> $converterstatus =
      const EnumNameConverter<OfferStatus>(OfferStatus.values);
}

class UpgradeOfferRow extends DataClass implements Insertable<UpgradeOfferRow> {
  final int id;
  final int questId;
  final OfferKind kind;
  final double? proposedTarget;
  final String proposedTitle;
  final String proposedSubtitle;
  final String npcLine;
  final OfferStatus status;
  final int? chapterId;
  final DateTime createdAt;
  const UpgradeOfferRow({
    required this.id,
    required this.questId,
    required this.kind,
    this.proposedTarget,
    required this.proposedTitle,
    required this.proposedSubtitle,
    required this.npcLine,
    required this.status,
    this.chapterId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['quest_id'] = Variable<int>(questId);
    {
      map['kind'] = Variable<String>(
        $UpgradeOffersTable.$converterkind.toSql(kind),
      );
    }
    if (!nullToAbsent || proposedTarget != null) {
      map['proposed_target'] = Variable<double>(proposedTarget);
    }
    map['proposed_title'] = Variable<String>(proposedTitle);
    map['proposed_subtitle'] = Variable<String>(proposedSubtitle);
    map['npc_line'] = Variable<String>(npcLine);
    {
      map['status'] = Variable<String>(
        $UpgradeOffersTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || chapterId != null) {
      map['chapter_id'] = Variable<int>(chapterId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UpgradeOffersCompanion toCompanion(bool nullToAbsent) {
    return UpgradeOffersCompanion(
      id: Value(id),
      questId: Value(questId),
      kind: Value(kind),
      proposedTarget: proposedTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(proposedTarget),
      proposedTitle: Value(proposedTitle),
      proposedSubtitle: Value(proposedSubtitle),
      npcLine: Value(npcLine),
      status: Value(status),
      chapterId: chapterId == null && nullToAbsent
          ? const Value.absent()
          : Value(chapterId),
      createdAt: Value(createdAt),
    );
  }

  factory UpgradeOfferRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UpgradeOfferRow(
      id: serializer.fromJson<int>(json['id']),
      questId: serializer.fromJson<int>(json['questId']),
      kind: $UpgradeOffersTable.$converterkind.fromJson(
        serializer.fromJson<String>(json['kind']),
      ),
      proposedTarget: serializer.fromJson<double?>(json['proposedTarget']),
      proposedTitle: serializer.fromJson<String>(json['proposedTitle']),
      proposedSubtitle: serializer.fromJson<String>(json['proposedSubtitle']),
      npcLine: serializer.fromJson<String>(json['npcLine']),
      status: $UpgradeOffersTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      chapterId: serializer.fromJson<int?>(json['chapterId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'questId': serializer.toJson<int>(questId),
      'kind': serializer.toJson<String>(
        $UpgradeOffersTable.$converterkind.toJson(kind),
      ),
      'proposedTarget': serializer.toJson<double?>(proposedTarget),
      'proposedTitle': serializer.toJson<String>(proposedTitle),
      'proposedSubtitle': serializer.toJson<String>(proposedSubtitle),
      'npcLine': serializer.toJson<String>(npcLine),
      'status': serializer.toJson<String>(
        $UpgradeOffersTable.$converterstatus.toJson(status),
      ),
      'chapterId': serializer.toJson<int?>(chapterId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UpgradeOfferRow copyWith({
    int? id,
    int? questId,
    OfferKind? kind,
    Value<double?> proposedTarget = const Value.absent(),
    String? proposedTitle,
    String? proposedSubtitle,
    String? npcLine,
    OfferStatus? status,
    Value<int?> chapterId = const Value.absent(),
    DateTime? createdAt,
  }) => UpgradeOfferRow(
    id: id ?? this.id,
    questId: questId ?? this.questId,
    kind: kind ?? this.kind,
    proposedTarget: proposedTarget.present
        ? proposedTarget.value
        : this.proposedTarget,
    proposedTitle: proposedTitle ?? this.proposedTitle,
    proposedSubtitle: proposedSubtitle ?? this.proposedSubtitle,
    npcLine: npcLine ?? this.npcLine,
    status: status ?? this.status,
    chapterId: chapterId.present ? chapterId.value : this.chapterId,
    createdAt: createdAt ?? this.createdAt,
  );
  UpgradeOfferRow copyWithCompanion(UpgradeOffersCompanion data) {
    return UpgradeOfferRow(
      id: data.id.present ? data.id.value : this.id,
      questId: data.questId.present ? data.questId.value : this.questId,
      kind: data.kind.present ? data.kind.value : this.kind,
      proposedTarget: data.proposedTarget.present
          ? data.proposedTarget.value
          : this.proposedTarget,
      proposedTitle: data.proposedTitle.present
          ? data.proposedTitle.value
          : this.proposedTitle,
      proposedSubtitle: data.proposedSubtitle.present
          ? data.proposedSubtitle.value
          : this.proposedSubtitle,
      npcLine: data.npcLine.present ? data.npcLine.value : this.npcLine,
      status: data.status.present ? data.status.value : this.status,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UpgradeOfferRow(')
          ..write('id: $id, ')
          ..write('questId: $questId, ')
          ..write('kind: $kind, ')
          ..write('proposedTarget: $proposedTarget, ')
          ..write('proposedTitle: $proposedTitle, ')
          ..write('proposedSubtitle: $proposedSubtitle, ')
          ..write('npcLine: $npcLine, ')
          ..write('status: $status, ')
          ..write('chapterId: $chapterId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    questId,
    kind,
    proposedTarget,
    proposedTitle,
    proposedSubtitle,
    npcLine,
    status,
    chapterId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UpgradeOfferRow &&
          other.id == this.id &&
          other.questId == this.questId &&
          other.kind == this.kind &&
          other.proposedTarget == this.proposedTarget &&
          other.proposedTitle == this.proposedTitle &&
          other.proposedSubtitle == this.proposedSubtitle &&
          other.npcLine == this.npcLine &&
          other.status == this.status &&
          other.chapterId == this.chapterId &&
          other.createdAt == this.createdAt);
}

class UpgradeOffersCompanion extends UpdateCompanion<UpgradeOfferRow> {
  final Value<int> id;
  final Value<int> questId;
  final Value<OfferKind> kind;
  final Value<double?> proposedTarget;
  final Value<String> proposedTitle;
  final Value<String> proposedSubtitle;
  final Value<String> npcLine;
  final Value<OfferStatus> status;
  final Value<int?> chapterId;
  final Value<DateTime> createdAt;
  const UpgradeOffersCompanion({
    this.id = const Value.absent(),
    this.questId = const Value.absent(),
    this.kind = const Value.absent(),
    this.proposedTarget = const Value.absent(),
    this.proposedTitle = const Value.absent(),
    this.proposedSubtitle = const Value.absent(),
    this.npcLine = const Value.absent(),
    this.status = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UpgradeOffersCompanion.insert({
    this.id = const Value.absent(),
    required int questId,
    required OfferKind kind,
    this.proposedTarget = const Value.absent(),
    required String proposedTitle,
    this.proposedSubtitle = const Value.absent(),
    this.npcLine = const Value.absent(),
    required OfferStatus status,
    this.chapterId = const Value.absent(),
    required DateTime createdAt,
  }) : questId = Value(questId),
       kind = Value(kind),
       proposedTitle = Value(proposedTitle),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<UpgradeOfferRow> custom({
    Expression<int>? id,
    Expression<int>? questId,
    Expression<String>? kind,
    Expression<double>? proposedTarget,
    Expression<String>? proposedTitle,
    Expression<String>? proposedSubtitle,
    Expression<String>? npcLine,
    Expression<String>? status,
    Expression<int>? chapterId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (questId != null) 'quest_id': questId,
      if (kind != null) 'kind': kind,
      if (proposedTarget != null) 'proposed_target': proposedTarget,
      if (proposedTitle != null) 'proposed_title': proposedTitle,
      if (proposedSubtitle != null) 'proposed_subtitle': proposedSubtitle,
      if (npcLine != null) 'npc_line': npcLine,
      if (status != null) 'status': status,
      if (chapterId != null) 'chapter_id': chapterId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UpgradeOffersCompanion copyWith({
    Value<int>? id,
    Value<int>? questId,
    Value<OfferKind>? kind,
    Value<double?>? proposedTarget,
    Value<String>? proposedTitle,
    Value<String>? proposedSubtitle,
    Value<String>? npcLine,
    Value<OfferStatus>? status,
    Value<int?>? chapterId,
    Value<DateTime>? createdAt,
  }) {
    return UpgradeOffersCompanion(
      id: id ?? this.id,
      questId: questId ?? this.questId,
      kind: kind ?? this.kind,
      proposedTarget: proposedTarget ?? this.proposedTarget,
      proposedTitle: proposedTitle ?? this.proposedTitle,
      proposedSubtitle: proposedSubtitle ?? this.proposedSubtitle,
      npcLine: npcLine ?? this.npcLine,
      status: status ?? this.status,
      chapterId: chapterId ?? this.chapterId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (questId.present) {
      map['quest_id'] = Variable<int>(questId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $UpgradeOffersTable.$converterkind.toSql(kind.value),
      );
    }
    if (proposedTarget.present) {
      map['proposed_target'] = Variable<double>(proposedTarget.value);
    }
    if (proposedTitle.present) {
      map['proposed_title'] = Variable<String>(proposedTitle.value);
    }
    if (proposedSubtitle.present) {
      map['proposed_subtitle'] = Variable<String>(proposedSubtitle.value);
    }
    if (npcLine.present) {
      map['npc_line'] = Variable<String>(npcLine.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $UpgradeOffersTable.$converterstatus.toSql(status.value),
      );
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<int>(chapterId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UpgradeOffersCompanion(')
          ..write('id: $id, ')
          ..write('questId: $questId, ')
          ..write('kind: $kind, ')
          ..write('proposedTarget: $proposedTarget, ')
          ..write('proposedTitle: $proposedTitle, ')
          ..write('proposedSubtitle: $proposedSubtitle, ')
          ..write('npcLine: $npcLine, ')
          ..write('status: $status, ')
          ..write('chapterId: $chapterId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(SettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AdventurersTable adventurers = $AdventurersTable(this);
  late final $HabitsTable habits = $HabitsTable(this);
  late final $QuestsTable quests = $QuestsTable(this);
  late final $CheckInsTable checkIns = $CheckInsTable(this);
  late final $XpEventsTable xpEvents = $XpEventsTable(this);
  late final $GoldEventsTable goldEvents = $GoldEventsTable(this);
  late final $PurchasesTable purchases = $PurchasesTable(this);
  late final $PriceWeeksTable priceWeeks = $PriceWeeksTable(this);
  late final $FocusWeeksTable focusWeeks = $FocusWeeksTable(this);
  late final $FocusSessionsTable focusSessions = $FocusSessionsTable(this);
  late final $BankAccountsTable bankAccounts = $BankAccountsTable(this);
  late final $BankTxnsTable bankTxns = $BankTxnsTable(this);
  late final $BankMonthsTable bankMonths = $BankMonthsTable(this);
  late final $CasinoWeeksTable casinoWeeks = $CasinoWeeksTable(this);
  late final $CasinoTicketsTable casinoTickets = $CasinoTicketsTable(this);
  late final $ChaptersTable chapters = $ChaptersTable(this);
  late final $UpgradeOffersTable upgradeOffers = $UpgradeOffersTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final Index questsHabitActive = Index(
    'quests_habit_active',
    'CREATE INDEX quests_habit_active ON quests (habit_id, active_until)',
  );
  late final Index checkInsDay = Index(
    'check_ins_day',
    'CREATE INDEX check_ins_day ON check_ins (day)',
  );
  late final Index checkInsQuest = Index(
    'check_ins_quest',
    'CREATE INDEX check_ins_quest ON check_ins (quest_id)',
  );
  late final Index focusSessionsDay = Index(
    'focus_sessions_day',
    'CREATE INDEX focus_sessions_day ON focus_sessions (day)',
  );
  late final Index bankTxnsDay = Index(
    'bank_txns_day',
    'CREATE INDEX bank_txns_day ON bank_txns (day)',
  );
  late final Index bankTxnsFrom = Index(
    'bank_txns_from',
    'CREATE INDEX bank_txns_from ON bank_txns (from_id)',
  );
  late final Index bankTxnsTo = Index(
    'bank_txns_to',
    'CREATE INDEX bank_txns_to ON bank_txns (to_id)',
  );
  late final Index casinoTicketsWeek = Index(
    'casino_tickets_week',
    'CREATE INDEX casino_tickets_week ON casino_tickets (week_start)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    adventurers,
    habits,
    quests,
    checkIns,
    xpEvents,
    goldEvents,
    purchases,
    priceWeeks,
    focusWeeks,
    focusSessions,
    bankAccounts,
    bankTxns,
    bankMonths,
    casinoWeeks,
    casinoTickets,
    chapters,
    upgradeOffers,
    settings,
    questsHabitActive,
    checkInsDay,
    checkInsQuest,
    focusSessionsDay,
    bankTxnsDay,
    bankTxnsFrom,
    bankTxnsTo,
    casinoTicketsWeek,
  ];
}

typedef $$AdventurersTableCreateCompanionBuilder =
    AdventurersCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> identity,
      Value<String?> heroClass,
      Value<String?> title,
      required DateTime createdAt,
      Value<String?> classStats,
      Value<LogicalDay?> classSince,
      Value<String?> classFlavor,
      Value<String?> portraitId,
      Value<QuestRank> guildRank,
      Value<LogicalDay?> rankSince,
      Value<LogicalDay?> trialStart,
    });
typedef $$AdventurersTableUpdateCompanionBuilder =
    AdventurersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> identity,
      Value<String?> heroClass,
      Value<String?> title,
      Value<DateTime> createdAt,
      Value<String?> classStats,
      Value<LogicalDay?> classSince,
      Value<String?> classFlavor,
      Value<String?> portraitId,
      Value<QuestRank> guildRank,
      Value<LogicalDay?> rankSince,
      Value<LogicalDay?> trialStart,
    });

class $$AdventurersTableFilterComposer
    extends Composer<_$AppDatabase, $AdventurersTable> {
  $$AdventurersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get identity => $composableBuilder(
    column: $table.identity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get heroClass => $composableBuilder(
    column: $table.heroClass,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classStats => $composableBuilder(
    column: $table.classStats,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LogicalDay?, LogicalDay, String>
  get classSince => $composableBuilder(
    column: $table.classSince,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get classFlavor => $composableBuilder(
    column: $table.classFlavor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get portraitId => $composableBuilder(
    column: $table.portraitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<QuestRank, QuestRank, String> get guildRank =>
      $composableBuilder(
        column: $table.guildRank,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<LogicalDay?, LogicalDay, String>
  get rankSince => $composableBuilder(
    column: $table.rankSince,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<LogicalDay?, LogicalDay, String>
  get trialStart => $composableBuilder(
    column: $table.trialStart,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $$AdventurersTableOrderingComposer
    extends Composer<_$AppDatabase, $AdventurersTable> {
  $$AdventurersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get identity => $composableBuilder(
    column: $table.identity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get heroClass => $composableBuilder(
    column: $table.heroClass,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classStats => $composableBuilder(
    column: $table.classStats,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classSince => $composableBuilder(
    column: $table.classSince,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classFlavor => $composableBuilder(
    column: $table.classFlavor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get portraitId => $composableBuilder(
    column: $table.portraitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guildRank => $composableBuilder(
    column: $table.guildRank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rankSince => $composableBuilder(
    column: $table.rankSince,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trialStart => $composableBuilder(
    column: $table.trialStart,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AdventurersTableAnnotationComposer
    extends Composer<_$AppDatabase, $AdventurersTable> {
  $$AdventurersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get identity =>
      $composableBuilder(column: $table.identity, builder: (column) => column);

  GeneratedColumn<String> get heroClass =>
      $composableBuilder(column: $table.heroClass, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get classStats => $composableBuilder(
    column: $table.classStats,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<LogicalDay?, String> get classSince =>
      $composableBuilder(
        column: $table.classSince,
        builder: (column) => column,
      );

  GeneratedColumn<String> get classFlavor => $composableBuilder(
    column: $table.classFlavor,
    builder: (column) => column,
  );

  GeneratedColumn<String> get portraitId => $composableBuilder(
    column: $table.portraitId,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<QuestRank, String> get guildRank =>
      $composableBuilder(column: $table.guildRank, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LogicalDay?, String> get rankSince =>
      $composableBuilder(column: $table.rankSince, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LogicalDay?, String> get trialStart =>
      $composableBuilder(
        column: $table.trialStart,
        builder: (column) => column,
      );
}

class $$AdventurersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AdventurersTable,
          AdventurerRow,
          $$AdventurersTableFilterComposer,
          $$AdventurersTableOrderingComposer,
          $$AdventurersTableAnnotationComposer,
          $$AdventurersTableCreateCompanionBuilder,
          $$AdventurersTableUpdateCompanionBuilder,
          (
            AdventurerRow,
            BaseReferences<_$AppDatabase, $AdventurersTable, AdventurerRow>,
          ),
          AdventurerRow,
          PrefetchHooks Function()
        > {
  $$AdventurersTableTableManager(_$AppDatabase db, $AdventurersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdventurersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AdventurersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AdventurersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> identity = const Value.absent(),
                Value<String?> heroClass = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> classStats = const Value.absent(),
                Value<LogicalDay?> classSince = const Value.absent(),
                Value<String?> classFlavor = const Value.absent(),
                Value<String?> portraitId = const Value.absent(),
                Value<QuestRank> guildRank = const Value.absent(),
                Value<LogicalDay?> rankSince = const Value.absent(),
                Value<LogicalDay?> trialStart = const Value.absent(),
              }) => AdventurersCompanion(
                id: id,
                name: name,
                identity: identity,
                heroClass: heroClass,
                title: title,
                createdAt: createdAt,
                classStats: classStats,
                classSince: classSince,
                classFlavor: classFlavor,
                portraitId: portraitId,
                guildRank: guildRank,
                rankSince: rankSince,
                trialStart: trialStart,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> identity = const Value.absent(),
                Value<String?> heroClass = const Value.absent(),
                Value<String?> title = const Value.absent(),
                required DateTime createdAt,
                Value<String?> classStats = const Value.absent(),
                Value<LogicalDay?> classSince = const Value.absent(),
                Value<String?> classFlavor = const Value.absent(),
                Value<String?> portraitId = const Value.absent(),
                Value<QuestRank> guildRank = const Value.absent(),
                Value<LogicalDay?> rankSince = const Value.absent(),
                Value<LogicalDay?> trialStart = const Value.absent(),
              }) => AdventurersCompanion.insert(
                id: id,
                name: name,
                identity: identity,
                heroClass: heroClass,
                title: title,
                createdAt: createdAt,
                classStats: classStats,
                classSince: classSince,
                classFlavor: classFlavor,
                portraitId: portraitId,
                guildRank: guildRank,
                rankSince: rankSince,
                trialStart: trialStart,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AdventurersTable, AdventurerRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AdventurersTable,
                    AdventurerRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AdventurersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AdventurersTable,
      AdventurerRow,
      $$AdventurersTableFilterComposer,
      $$AdventurersTableOrderingComposer,
      $$AdventurersTableAnnotationComposer,
      $$AdventurersTableCreateCompanionBuilder,
      $$AdventurersTableUpdateCompanionBuilder,
      (
        AdventurerRow,
        BaseReferences<_$AppDatabase, $AdventurersTable, AdventurerRow>,
      ),
      AdventurerRow,
      PrefetchHooks Function()
    >;
typedef $$HabitsTableCreateCompanionBuilder = HabitsCompanion Function({
  Value<int> id,
  required HabitKind kind,
  required String name,
  Value<String?> unit,
  Value<double?> target,
  Value<int> timesPerWeek,
  Value<String?> intention,
  required LogicalDay firstDay,
  required DateTime createdAt,
  Value<DateTime?> archivedAt,
  Value<LogicalDay?> cursedOn,
  Value<int?> anchorHabitId,
  Value<String?> anchorText,
});
typedef $$HabitsTableUpdateCompanionBuilder = HabitsCompanion Function({
  Value<int> id,
  Value<HabitKind> kind,
  Value<String> name,
  Value<String?> unit,
  Value<double?> target,
  Value<int> timesPerWeek,
  Value<String?> intention,
  Value<LogicalDay> firstDay,
  Value<DateTime> createdAt,
  Value<DateTime?> archivedAt,
  Value<LogicalDay?> cursedOn,
  Value<int?> anchorHabitId,
  Value<String?> anchorText,
});

final class $$HabitsTableReferences
    extends BaseReferences<_$AppDatabase, $HabitsTable, HabitRow> {
  $$HabitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$QuestsTable, List<QuestRow>> _questsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.quests,
    aliasName: 'habits__id__quests__habit_id',
  );

  $$QuestsTableProcessedTableManager get questsRefs {
    final manager = $$QuestsTableTableManager(
      $_db,
      $_db.quests,
    ).filter((f) => f.habitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_questsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CheckInsTable, List<CheckInRow>>
  _checkInsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.checkIns,
    aliasName: 'habits__id__check_ins__habit_id',
  );

  $$CheckInsTableProcessedTableManager get checkInsRefs {
    final manager = $$CheckInsTableTableManager(
      $_db,
      $_db.checkIns,
    ).filter((f) => f.habitId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_checkInsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HabitsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<HabitKind, HabitKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timesPerWeek => $composableBuilder(
    column: $table.timesPerWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get intention => $composableBuilder(
    column: $table.intention,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LogicalDay, LogicalDay, String> get firstDay =>
      $composableBuilder(
        column: $table.firstDay,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LogicalDay?, LogicalDay, String>
  get cursedOn => $composableBuilder(
    column: $table.cursedOn,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get anchorHabitId => $composableBuilder(
    column: $table.anchorHabitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get anchorText => $composableBuilder(
    column: $table.anchorText,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> questsRefs(
    Expression<bool> Function($$QuestsTableFilterComposer f) f,
  ) {
    final $$QuestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quests,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestsTableFilterComposer(
            $db: $db,
            $table: $db.quests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> checkInsRefs(
    Expression<bool> Function($$CheckInsTableFilterComposer f) f,
  ) {
    final $$CheckInsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.checkIns,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CheckInsTableFilterComposer(
            $db: $db,
            $table: $db.checkIns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timesPerWeek => $composableBuilder(
    column: $table.timesPerWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get intention => $composableBuilder(
    column: $table.intention,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstDay => $composableBuilder(
    column: $table.firstDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cursedOn => $composableBuilder(
    column: $table.cursedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get anchorHabitId => $composableBuilder(
    column: $table.anchorHabitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get anchorText => $composableBuilder(
    column: $table.anchorText,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<HabitKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<int> get timesPerWeek => $composableBuilder(
    column: $table.timesPerWeek,
    builder: (column) => column,
  );

  GeneratedColumn<String> get intention =>
      $composableBuilder(column: $table.intention, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LogicalDay, String> get firstDay =>
      $composableBuilder(column: $table.firstDay, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<LogicalDay?, String> get cursedOn =>
      $composableBuilder(column: $table.cursedOn, builder: (column) => column);

  GeneratedColumn<int> get anchorHabitId => $composableBuilder(
    column: $table.anchorHabitId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get anchorText => $composableBuilder(
    column: $table.anchorText,
    builder: (column) => column,
  );

  Expression<T> questsRefs<T extends Object>(
    Expression<T> Function($$QuestsTableAnnotationComposer a) f,
  ) {
    final $$QuestsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quests,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestsTableAnnotationComposer(
            $db: $db,
            $table: $db.quests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> checkInsRefs<T extends Object>(
    Expression<T> Function($$CheckInsTableAnnotationComposer a) f,
  ) {
    final $$CheckInsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.checkIns,
      getReferencedColumn: (t) => t.habitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CheckInsTableAnnotationComposer(
            $db: $db,
            $table: $db.checkIns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HabitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitsTable,
          HabitRow,
          $$HabitsTableFilterComposer,
          $$HabitsTableOrderingComposer,
          $$HabitsTableAnnotationComposer,
          $$HabitsTableCreateCompanionBuilder,
          $$HabitsTableUpdateCompanionBuilder,
          (HabitRow, $$HabitsTableReferences),
          HabitRow,
          PrefetchHooks Function({bool questsRefs, bool checkInsRefs})
        > {
  $$HabitsTableTableManager(_$AppDatabase db, $HabitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<HabitKind> kind = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<double?> target = const Value.absent(),
                Value<int> timesPerWeek = const Value.absent(),
                Value<String?> intention = const Value.absent(),
                Value<LogicalDay> firstDay = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<LogicalDay?> cursedOn = const Value.absent(),
                Value<int?> anchorHabitId = const Value.absent(),
                Value<String?> anchorText = const Value.absent(),
              }) => HabitsCompanion(
                id: id,
                kind: kind,
                name: name,
                unit: unit,
                target: target,
                timesPerWeek: timesPerWeek,
                intention: intention,
                firstDay: firstDay,
                createdAt: createdAt,
                archivedAt: archivedAt,
                cursedOn: cursedOn,
                anchorHabitId: anchorHabitId,
                anchorText: anchorText,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required HabitKind kind,
                required String name,
                Value<String?> unit = const Value.absent(),
                Value<double?> target = const Value.absent(),
                Value<int> timesPerWeek = const Value.absent(),
                Value<String?> intention = const Value.absent(),
                required LogicalDay firstDay,
                required DateTime createdAt,
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<LogicalDay?> cursedOn = const Value.absent(),
                Value<int?> anchorHabitId = const Value.absent(),
                Value<String?> anchorText = const Value.absent(),
              }) => HabitsCompanion.insert(
                id: id,
                kind: kind,
                name: name,
                unit: unit,
                target: target,
                timesPerWeek: timesPerWeek,
                intention: intention,
                firstDay: firstDay,
                createdAt: createdAt,
                archivedAt: archivedAt,
                cursedOn: cursedOn,
                anchorHabitId: anchorHabitId,
                anchorText: anchorText,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HabitsTable, HabitRow>(table),
                  $$HabitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({questsRefs = false, checkInsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (questsRefs) db.quests,
                if (checkInsRefs) db.checkIns,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (questsRefs)
                    await $_getPrefetchedDataByColumns<
                      HabitRow,
                      $HabitsTable,
                      QuestRow,
                      $QuestsTable
                    >(
                      currentTable: table,
                      referencedTable: $$HabitsTableReferences._questsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$HabitsTableReferences(db, table, p0).questsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'habit_id',
                      typedResults: items,
                    ),
                  if (checkInsRefs)
                    await $_getPrefetchedDataByColumns<
                      HabitRow,
                      $HabitsTable,
                      CheckInRow,
                      $CheckInsTable
                    >(
                      currentTable: table,
                      referencedTable: $$HabitsTableReferences
                          ._checkInsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$HabitsTableReferences(db, table, p0).checkInsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'habit_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$HabitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitsTable,
      HabitRow,
      $$HabitsTableFilterComposer,
      $$HabitsTableOrderingComposer,
      $$HabitsTableAnnotationComposer,
      $$HabitsTableCreateCompanionBuilder,
      $$HabitsTableUpdateCompanionBuilder,
      (HabitRow, $$HabitsTableReferences),
      HabitRow,
      PrefetchHooks Function({bool questsRefs, bool checkInsRefs})
    >;
typedef $$QuestsTableCreateCompanionBuilder = QuestsCompanion Function({
  Value<int> id,
  required int habitId,
  Value<int> tier,
  required QuestRank rank,
  required String title,
  Value<String> subtitle,
  Value<String> flavor,
  Value<String> spriteId,
  Value<double?> target,
  required LogicalDay activeFrom,
  Value<LogicalDay?> activeUntil,
  Value<Stat?> attribute,
});
typedef $$QuestsTableUpdateCompanionBuilder = QuestsCompanion Function({
  Value<int> id,
  Value<int> habitId,
  Value<int> tier,
  Value<QuestRank> rank,
  Value<String> title,
  Value<String> subtitle,
  Value<String> flavor,
  Value<String> spriteId,
  Value<double?> target,
  Value<LogicalDay> activeFrom,
  Value<LogicalDay?> activeUntil,
  Value<Stat?> attribute,
});

final class $$QuestsTableReferences
    extends BaseReferences<_$AppDatabase, $QuestsTable, QuestRow> {
  $$QuestsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HabitsTable _habitIdTable(_$AppDatabase db) =>
      db.habits.createAlias('quests__habit_id__habits__id');

  $$HabitsTableProcessedTableManager get habitId {
    final $_column = $_itemColumn<int>('habit_id')!;

    final manager = $$HabitsTableTableManager(
      $_db,
      $_db.habits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_habitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CheckInsTable, List<CheckInRow>>
  _checkInsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.checkIns,
    aliasName: 'quests__id__check_ins__quest_id',
  );

  $$CheckInsTableProcessedTableManager get checkInsRefs {
    final manager = $$CheckInsTableTableManager(
      $_db,
      $_db.checkIns,
    ).filter((f) => f.questId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_checkInsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$UpgradeOffersTable, List<UpgradeOfferRow>>
  _upgradeOffersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.upgradeOffers,
    aliasName: 'quests__id__upgrade_offers__quest_id',
  );

  $$UpgradeOffersTableProcessedTableManager get upgradeOffersRefs {
    final manager = $$UpgradeOffersTableTableManager(
      $_db,
      $_db.upgradeOffers,
    ).filter((f) => f.questId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_upgradeOffersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$QuestsTableFilterComposer
    extends Composer<_$AppDatabase, $QuestsTable> {
  $$QuestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<QuestRank, QuestRank, String> get rank =>
      $composableBuilder(
        column: $table.rank,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get flavor => $composableBuilder(
    column: $table.flavor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get spriteId => $composableBuilder(
    column: $table.spriteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LogicalDay, LogicalDay, String>
  get activeFrom => $composableBuilder(
    column: $table.activeFrom,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<LogicalDay?, LogicalDay, String>
  get activeUntil => $composableBuilder(
    column: $table.activeUntil,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<Stat?, Stat, String> get attribute =>
      $composableBuilder(
        column: $table.attribute,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$HabitsTableFilterComposer get habitId {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableFilterComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> checkInsRefs(
    Expression<bool> Function($$CheckInsTableFilterComposer f) f,
  ) {
    final $$CheckInsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.checkIns,
      getReferencedColumn: (t) => t.questId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CheckInsTableFilterComposer(
            $db: $db,
            $table: $db.checkIns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> upgradeOffersRefs(
    Expression<bool> Function($$UpgradeOffersTableFilterComposer f) f,
  ) {
    final $$UpgradeOffersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.upgradeOffers,
      getReferencedColumn: (t) => t.questId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UpgradeOffersTableFilterComposer(
            $db: $db,
            $table: $db.upgradeOffers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QuestsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestsTable> {
  $$QuestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flavor => $composableBuilder(
    column: $table.flavor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get spriteId => $composableBuilder(
    column: $table.spriteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeFrom => $composableBuilder(
    column: $table.activeFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get activeUntil => $composableBuilder(
    column: $table.activeUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attribute => $composableBuilder(
    column: $table.attribute,
    builder: (column) => ColumnOrderings(column),
  );

  $$HabitsTableOrderingComposer get habitId {
    final $$HabitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableOrderingComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestsTable> {
  $$QuestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get tier =>
      $composableBuilder(column: $table.tier, builder: (column) => column);

  GeneratedColumnWithTypeConverter<QuestRank, String> get rank =>
      $composableBuilder(column: $table.rank, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumn<String> get flavor =>
      $composableBuilder(column: $table.flavor, builder: (column) => column);

  GeneratedColumn<String> get spriteId =>
      $composableBuilder(column: $table.spriteId, builder: (column) => column);

  GeneratedColumn<double> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LogicalDay, String> get activeFrom =>
      $composableBuilder(
        column: $table.activeFrom,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<LogicalDay?, String> get activeUntil =>
      $composableBuilder(
        column: $table.activeUntil,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Stat?, String> get attribute =>
      $composableBuilder(column: $table.attribute, builder: (column) => column);

  $$HabitsTableAnnotationComposer get habitId {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableAnnotationComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> checkInsRefs<T extends Object>(
    Expression<T> Function($$CheckInsTableAnnotationComposer a) f,
  ) {
    final $$CheckInsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.checkIns,
      getReferencedColumn: (t) => t.questId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CheckInsTableAnnotationComposer(
            $db: $db,
            $table: $db.checkIns,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> upgradeOffersRefs<T extends Object>(
    Expression<T> Function($$UpgradeOffersTableAnnotationComposer a) f,
  ) {
    final $$UpgradeOffersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.upgradeOffers,
      getReferencedColumn: (t) => t.questId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UpgradeOffersTableAnnotationComposer(
            $db: $db,
            $table: $db.upgradeOffers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QuestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuestsTable,
          QuestRow,
          $$QuestsTableFilterComposer,
          $$QuestsTableOrderingComposer,
          $$QuestsTableAnnotationComposer,
          $$QuestsTableCreateCompanionBuilder,
          $$QuestsTableUpdateCompanionBuilder,
          (QuestRow, $$QuestsTableReferences),
          QuestRow,
          PrefetchHooks Function({
            bool habitId,
            bool checkInsRefs,
            bool upgradeOffersRefs,
          })
        > {
  $$QuestsTableTableManager(_$AppDatabase db, $QuestsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> habitId = const Value.absent(),
                Value<int> tier = const Value.absent(),
                Value<QuestRank> rank = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> subtitle = const Value.absent(),
                Value<String> flavor = const Value.absent(),
                Value<String> spriteId = const Value.absent(),
                Value<double?> target = const Value.absent(),
                Value<LogicalDay> activeFrom = const Value.absent(),
                Value<LogicalDay?> activeUntil = const Value.absent(),
                Value<Stat?> attribute = const Value.absent(),
              }) => QuestsCompanion(
                id: id,
                habitId: habitId,
                tier: tier,
                rank: rank,
                title: title,
                subtitle: subtitle,
                flavor: flavor,
                spriteId: spriteId,
                target: target,
                activeFrom: activeFrom,
                activeUntil: activeUntil,
                attribute: attribute,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int habitId,
                Value<int> tier = const Value.absent(),
                required QuestRank rank,
                required String title,
                Value<String> subtitle = const Value.absent(),
                Value<String> flavor = const Value.absent(),
                Value<String> spriteId = const Value.absent(),
                Value<double?> target = const Value.absent(),
                required LogicalDay activeFrom,
                Value<LogicalDay?> activeUntil = const Value.absent(),
                Value<Stat?> attribute = const Value.absent(),
              }) => QuestsCompanion.insert(
                id: id,
                habitId: habitId,
                tier: tier,
                rank: rank,
                title: title,
                subtitle: subtitle,
                flavor: flavor,
                spriteId: spriteId,
                target: target,
                activeFrom: activeFrom,
                activeUntil: activeUntil,
                attribute: attribute,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QuestsTable, QuestRow>(table),
                  $$QuestsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                habitId = false,
                checkInsRefs = false,
                upgradeOffersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (checkInsRefs) db.checkIns,
                    if (upgradeOffersRefs) db.upgradeOffers,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (habitId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.habitId,
                            referencedTable: $$QuestsTableReferences
                                ._habitIdTable(db),
                            referencedColumn: $$QuestsTableReferences
                                ._habitIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (checkInsRefs)
                        await $_getPrefetchedDataByColumns<
                          QuestRow,
                          $QuestsTable,
                          CheckInRow,
                          $CheckInsTable
                        >(
                          currentTable: table,
                          referencedTable: $$QuestsTableReferences
                              ._checkInsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$QuestsTableReferences(
                                db,
                                table,
                                p0,
                              ).checkInsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'quest_id',
                          typedResults: items,
                        ),
                      if (upgradeOffersRefs)
                        await $_getPrefetchedDataByColumns<
                          QuestRow,
                          $QuestsTable,
                          UpgradeOfferRow,
                          $UpgradeOffersTable
                        >(
                          currentTable: table,
                          referencedTable: $$QuestsTableReferences
                              ._upgradeOffersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$QuestsTableReferences(
                                db,
                                table,
                                p0,
                              ).upgradeOffersRefs,
                          currentColumn: 'id',
                          referencedColumn: 'quest_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$QuestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuestsTable,
      QuestRow,
      $$QuestsTableFilterComposer,
      $$QuestsTableOrderingComposer,
      $$QuestsTableAnnotationComposer,
      $$QuestsTableCreateCompanionBuilder,
      $$QuestsTableUpdateCompanionBuilder,
      (QuestRow, $$QuestsTableReferences),
      QuestRow,
      PrefetchHooks Function({
        bool habitId,
        bool checkInsRefs,
        bool upgradeOffersRefs,
      })
    >;
typedef $$CheckInsTableCreateCompanionBuilder = CheckInsCompanion Function({
  Value<int> id,
  required int habitId,
  required int questId,
  required LogicalDay day,
  required CheckInOutcome outcome,
  Value<double?> amount,
  Value<String?> note,
  Value<int> xp,
  required DateTime createdAt,
  Value<int> gold,
});
typedef $$CheckInsTableUpdateCompanionBuilder = CheckInsCompanion Function({
  Value<int> id,
  Value<int> habitId,
  Value<int> questId,
  Value<LogicalDay> day,
  Value<CheckInOutcome> outcome,
  Value<double?> amount,
  Value<String?> note,
  Value<int> xp,
  Value<DateTime> createdAt,
  Value<int> gold,
});

final class $$CheckInsTableReferences
    extends BaseReferences<_$AppDatabase, $CheckInsTable, CheckInRow> {
  $$CheckInsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $HabitsTable _habitIdTable(_$AppDatabase db) =>
      db.habits.createAlias('check_ins__habit_id__habits__id');

  $$HabitsTableProcessedTableManager get habitId {
    final $_column = $_itemColumn<int>('habit_id')!;

    final manager = $$HabitsTableTableManager(
      $_db,
      $_db.habits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_habitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $QuestsTable _questIdTable(_$AppDatabase db) =>
      db.quests.createAlias('check_ins__quest_id__quests__id');

  $$QuestsTableProcessedTableManager get questId {
    final $_column = $_itemColumn<int>('quest_id')!;

    final manager = $$QuestsTableTableManager(
      $_db,
      $_db.quests,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_questIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CheckInsTableFilterComposer
    extends Composer<_$AppDatabase, $CheckInsTable> {
  $$CheckInsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LogicalDay, LogicalDay, String> get day =>
      $composableBuilder(
        column: $table.day,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<CheckInOutcome, CheckInOutcome, String>
  get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gold => $composableBuilder(
    column: $table.gold,
    builder: (column) => ColumnFilters(column),
  );

  $$HabitsTableFilterComposer get habitId {
    final $$HabitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableFilterComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$QuestsTableFilterComposer get questId {
    final $$QuestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questId,
      referencedTable: $db.quests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestsTableFilterComposer(
            $db: $db,
            $table: $db.quests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CheckInsTableOrderingComposer
    extends Composer<_$AppDatabase, $CheckInsTable> {
  $$CheckInsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outcome => $composableBuilder(
    column: $table.outcome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get xp => $composableBuilder(
    column: $table.xp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gold => $composableBuilder(
    column: $table.gold,
    builder: (column) => ColumnOrderings(column),
  );

  $$HabitsTableOrderingComposer get habitId {
    final $$HabitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableOrderingComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$QuestsTableOrderingComposer get questId {
    final $$QuestsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questId,
      referencedTable: $db.quests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestsTableOrderingComposer(
            $db: $db,
            $table: $db.quests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CheckInsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CheckInsTable> {
  $$CheckInsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LogicalDay, String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CheckInOutcome, String> get outcome =>
      $composableBuilder(column: $table.outcome, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get xp =>
      $composableBuilder(column: $table.xp, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get gold =>
      $composableBuilder(column: $table.gold, builder: (column) => column);

  $$HabitsTableAnnotationComposer get habitId {
    final $$HabitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.habitId,
      referencedTable: $db.habits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HabitsTableAnnotationComposer(
            $db: $db,
            $table: $db.habits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$QuestsTableAnnotationComposer get questId {
    final $$QuestsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questId,
      referencedTable: $db.quests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestsTableAnnotationComposer(
            $db: $db,
            $table: $db.quests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CheckInsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CheckInsTable,
          CheckInRow,
          $$CheckInsTableFilterComposer,
          $$CheckInsTableOrderingComposer,
          $$CheckInsTableAnnotationComposer,
          $$CheckInsTableCreateCompanionBuilder,
          $$CheckInsTableUpdateCompanionBuilder,
          (CheckInRow, $$CheckInsTableReferences),
          CheckInRow,
          PrefetchHooks Function({bool habitId, bool questId})
        > {
  $$CheckInsTableTableManager(_$AppDatabase db, $CheckInsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CheckInsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CheckInsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CheckInsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> habitId = const Value.absent(),
                Value<int> questId = const Value.absent(),
                Value<LogicalDay> day = const Value.absent(),
                Value<CheckInOutcome> outcome = const Value.absent(),
                Value<double?> amount = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> xp = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> gold = const Value.absent(),
              }) => CheckInsCompanion(
                id: id,
                habitId: habitId,
                questId: questId,
                day: day,
                outcome: outcome,
                amount: amount,
                note: note,
                xp: xp,
                createdAt: createdAt,
                gold: gold,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int habitId,
                required int questId,
                required LogicalDay day,
                required CheckInOutcome outcome,
                Value<double?> amount = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> xp = const Value.absent(),
                required DateTime createdAt,
                Value<int> gold = const Value.absent(),
              }) => CheckInsCompanion.insert(
                id: id,
                habitId: habitId,
                questId: questId,
                day: day,
                outcome: outcome,
                amount: amount,
                note: note,
                xp: xp,
                createdAt: createdAt,
                gold: gold,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CheckInsTable, CheckInRow>(table),
                  $$CheckInsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({habitId = false, questId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (habitId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.habitId,
                        referencedTable: $$CheckInsTableReferences
                            ._habitIdTable(db),
                        referencedColumn: $$CheckInsTableReferences
                            ._habitIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (questId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.questId,
                        referencedTable: $$CheckInsTableReferences
                            ._questIdTable(db),
                        referencedColumn: $$CheckInsTableReferences
                            ._questIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CheckInsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CheckInsTable,
      CheckInRow,
      $$CheckInsTableFilterComposer,
      $$CheckInsTableOrderingComposer,
      $$CheckInsTableAnnotationComposer,
      $$CheckInsTableCreateCompanionBuilder,
      $$CheckInsTableUpdateCompanionBuilder,
      (CheckInRow, $$CheckInsTableReferences),
      CheckInRow,
      PrefetchHooks Function({bool habitId, bool questId})
    >;
typedef $$XpEventsTableCreateCompanionBuilder = XpEventsCompanion Function({
  Value<int> id,
  required int amount,
  required String source,
  Value<int?> refId,
  required DateTime at,
});
typedef $$XpEventsTableUpdateCompanionBuilder = XpEventsCompanion Function({
  Value<int> id,
  Value<int> amount,
  Value<String> source,
  Value<int?> refId,
  Value<DateTime> at,
});

class $$XpEventsTableFilterComposer
    extends Composer<_$AppDatabase, $XpEventsTable> {
  $$XpEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get refId => $composableBuilder(
    column: $table.refId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );
}

class $$XpEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $XpEventsTable> {
  $$XpEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get refId => $composableBuilder(
    column: $table.refId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$XpEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $XpEventsTable> {
  $$XpEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<int> get refId =>
      $composableBuilder(column: $table.refId, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);
}

class $$XpEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $XpEventsTable,
          XpEventRow,
          $$XpEventsTableFilterComposer,
          $$XpEventsTableOrderingComposer,
          $$XpEventsTableAnnotationComposer,
          $$XpEventsTableCreateCompanionBuilder,
          $$XpEventsTableUpdateCompanionBuilder,
          (
            XpEventRow,
            BaseReferences<_$AppDatabase, $XpEventsTable, XpEventRow>,
          ),
          XpEventRow,
          PrefetchHooks Function()
        > {
  $$XpEventsTableTableManager(_$AppDatabase db, $XpEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$XpEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$XpEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$XpEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int?> refId = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
              }) => XpEventsCompanion(
                id: id,
                amount: amount,
                source: source,
                refId: refId,
                at: at,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int amount,
                required String source,
                Value<int?> refId = const Value.absent(),
                required DateTime at,
              }) => XpEventsCompanion.insert(
                id: id,
                amount: amount,
                source: source,
                refId: refId,
                at: at,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$XpEventsTable, XpEventRow>(table),
                  BaseReferences<_$AppDatabase, $XpEventsTable, XpEventRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$XpEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $XpEventsTable,
      XpEventRow,
      $$XpEventsTableFilterComposer,
      $$XpEventsTableOrderingComposer,
      $$XpEventsTableAnnotationComposer,
      $$XpEventsTableCreateCompanionBuilder,
      $$XpEventsTableUpdateCompanionBuilder,
      (XpEventRow, BaseReferences<_$AppDatabase, $XpEventsTable, XpEventRow>),
      XpEventRow,
      PrefetchHooks Function()
    >;
typedef $$GoldEventsTableCreateCompanionBuilder = GoldEventsCompanion Function({
  Value<int> id,
  required int amount,
  required String source,
  Value<String?> ref,
  required DateTime at,
});
typedef $$GoldEventsTableUpdateCompanionBuilder = GoldEventsCompanion Function({
  Value<int> id,
  Value<int> amount,
  Value<String> source,
  Value<String?> ref,
  Value<DateTime> at,
});

class $$GoldEventsTableFilterComposer
    extends Composer<_$AppDatabase, $GoldEventsTable> {
  $$GoldEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GoldEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoldEventsTable> {
  $$GoldEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoldEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoldEventsTable> {
  $$GoldEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get ref =>
      $composableBuilder(column: $table.ref, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);
}

class $$GoldEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoldEventsTable,
          GoldEventRow,
          $$GoldEventsTableFilterComposer,
          $$GoldEventsTableOrderingComposer,
          $$GoldEventsTableAnnotationComposer,
          $$GoldEventsTableCreateCompanionBuilder,
          $$GoldEventsTableUpdateCompanionBuilder,
          (
            GoldEventRow,
            BaseReferences<_$AppDatabase, $GoldEventsTable, GoldEventRow>,
          ),
          GoldEventRow,
          PrefetchHooks Function()
        > {
  $$GoldEventsTableTableManager(_$AppDatabase db, $GoldEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoldEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoldEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoldEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String?> ref = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
              }) => GoldEventsCompanion(
                id: id,
                amount: amount,
                source: source,
                ref: ref,
                at: at,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int amount,
                required String source,
                Value<String?> ref = const Value.absent(),
                required DateTime at,
              }) => GoldEventsCompanion.insert(
                id: id,
                amount: amount,
                source: source,
                ref: ref,
                at: at,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GoldEventsTable, GoldEventRow>(table),
                  BaseReferences<_$AppDatabase, $GoldEventsTable, GoldEventRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GoldEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoldEventsTable,
      GoldEventRow,
      $$GoldEventsTableFilterComposer,
      $$GoldEventsTableOrderingComposer,
      $$GoldEventsTableAnnotationComposer,
      $$GoldEventsTableCreateCompanionBuilder,
      $$GoldEventsTableUpdateCompanionBuilder,
      (
        GoldEventRow,
        BaseReferences<_$AppDatabase, $GoldEventsTable, GoldEventRow>,
      ),
      GoldEventRow,
      PrefetchHooks Function()
    >;
typedef $$PurchasesTableCreateCompanionBuilder = PurchasesCompanion Function({
  required String itemId,
  required int price,
  required DateTime at,
  Value<int> rowid,
});
typedef $$PurchasesTableUpdateCompanionBuilder = PurchasesCompanion Function({
  Value<String> itemId,
  Value<int> price,
  Value<DateTime> at,
  Value<int> rowid,
});

class $$PurchasesTableFilterComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PurchasesTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PurchasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<int> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);
}

class $$PurchasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PurchasesTable,
          PurchaseRow,
          $$PurchasesTableFilterComposer,
          $$PurchasesTableOrderingComposer,
          $$PurchasesTableAnnotationComposer,
          $$PurchasesTableCreateCompanionBuilder,
          $$PurchasesTableUpdateCompanionBuilder,
          (
            PurchaseRow,
            BaseReferences<_$AppDatabase, $PurchasesTable, PurchaseRow>,
          ),
          PurchaseRow,
          PrefetchHooks Function()
        > {
  $$PurchasesTableTableManager(_$AppDatabase db, $PurchasesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> itemId = const Value.absent(),
                Value<int> price = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PurchasesCompanion(
                itemId: itemId,
                price: price,
                at: at,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String itemId,
                required int price,
                required DateTime at,
                Value<int> rowid = const Value.absent(),
              }) => PurchasesCompanion.insert(
                itemId: itemId,
                price: price,
                at: at,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PurchasesTable, PurchaseRow>(table),
                  BaseReferences<_$AppDatabase, $PurchasesTable, PurchaseRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PurchasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PurchasesTable,
      PurchaseRow,
      $$PurchasesTableFilterComposer,
      $$PurchasesTableOrderingComposer,
      $$PurchasesTableAnnotationComposer,
      $$PurchasesTableCreateCompanionBuilder,
      $$PurchasesTableUpdateCompanionBuilder,
      (
        PurchaseRow,
        BaseReferences<_$AppDatabase, $PurchasesTable, PurchaseRow>,
      ),
      PurchaseRow,
      PrefetchHooks Function()
    >;
typedef $$PriceWeeksTableCreateCompanionBuilder = PriceWeeksCompanion Function({
  required LogicalDay weekStart,
  required QuestRank rank,
  required int percent,
  Value<int> rowid,
});
typedef $$PriceWeeksTableUpdateCompanionBuilder = PriceWeeksCompanion Function({
  Value<LogicalDay> weekStart,
  Value<QuestRank> rank,
  Value<int> percent,
  Value<int> rowid,
});

class $$PriceWeeksTableFilterComposer
    extends Composer<_$AppDatabase, $PriceWeeksTable> {
  $$PriceWeeksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<LogicalDay, LogicalDay, String>
  get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<QuestRank, QuestRank, String> get rank =>
      $composableBuilder(
        column: $table.rank,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get percent => $composableBuilder(
    column: $table.percent,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PriceWeeksTableOrderingComposer
    extends Composer<_$AppDatabase, $PriceWeeksTable> {
  $$PriceWeeksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rank => $composableBuilder(
    column: $table.rank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get percent => $composableBuilder(
    column: $table.percent,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PriceWeeksTableAnnotationComposer
    extends Composer<_$AppDatabase, $PriceWeeksTable> {
  $$PriceWeeksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<LogicalDay, String> get weekStart =>
      $composableBuilder(column: $table.weekStart, builder: (column) => column);

  GeneratedColumnWithTypeConverter<QuestRank, String> get rank =>
      $composableBuilder(column: $table.rank, builder: (column) => column);

  GeneratedColumn<int> get percent =>
      $composableBuilder(column: $table.percent, builder: (column) => column);
}

class $$PriceWeeksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PriceWeeksTable,
          PriceWeekRow,
          $$PriceWeeksTableFilterComposer,
          $$PriceWeeksTableOrderingComposer,
          $$PriceWeeksTableAnnotationComposer,
          $$PriceWeeksTableCreateCompanionBuilder,
          $$PriceWeeksTableUpdateCompanionBuilder,
          (
            PriceWeekRow,
            BaseReferences<_$AppDatabase, $PriceWeeksTable, PriceWeekRow>,
          ),
          PriceWeekRow,
          PrefetchHooks Function()
        > {
  $$PriceWeeksTableTableManager(_$AppDatabase db, $PriceWeeksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PriceWeeksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PriceWeeksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PriceWeeksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<LogicalDay> weekStart = const Value.absent(),
                Value<QuestRank> rank = const Value.absent(),
                Value<int> percent = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PriceWeeksCompanion(
                weekStart: weekStart,
                rank: rank,
                percent: percent,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required LogicalDay weekStart,
                required QuestRank rank,
                required int percent,
                Value<int> rowid = const Value.absent(),
              }) => PriceWeeksCompanion.insert(
                weekStart: weekStart,
                rank: rank,
                percent: percent,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PriceWeeksTable, PriceWeekRow>(table),
                  BaseReferences<_$AppDatabase, $PriceWeeksTable, PriceWeekRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PriceWeeksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PriceWeeksTable,
      PriceWeekRow,
      $$PriceWeeksTableFilterComposer,
      $$PriceWeeksTableOrderingComposer,
      $$PriceWeeksTableAnnotationComposer,
      $$PriceWeeksTableCreateCompanionBuilder,
      $$PriceWeeksTableUpdateCompanionBuilder,
      (
        PriceWeekRow,
        BaseReferences<_$AppDatabase, $PriceWeeksTable, PriceWeekRow>,
      ),
      PriceWeekRow,
      PrefetchHooks Function()
    >;
typedef $$FocusWeeksTableCreateCompanionBuilder = FocusWeeksCompanion Function({
  required LogicalDay weekStart,
  required LogicalDay fromDay,
  required int dailyMinutes,
  required int capMinutes,
  required int earnCapMinutes,
  required int goldPerHour,
  Value<DateTime?> settledAt,
  Value<int?> unpaidSeconds,
  Value<int?> penalty,
  Value<int> rowid,
});
typedef $$FocusWeeksTableUpdateCompanionBuilder = FocusWeeksCompanion Function({
  Value<LogicalDay> weekStart,
  Value<LogicalDay> fromDay,
  Value<int> dailyMinutes,
  Value<int> capMinutes,
  Value<int> earnCapMinutes,
  Value<int> goldPerHour,
  Value<DateTime?> settledAt,
  Value<int?> unpaidSeconds,
  Value<int?> penalty,
  Value<int> rowid,
});

class $$FocusWeeksTableFilterComposer
    extends Composer<_$AppDatabase, $FocusWeeksTable> {
  $$FocusWeeksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<LogicalDay, LogicalDay, String>
  get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<LogicalDay, LogicalDay, String> get fromDay =>
      $composableBuilder(
        column: $table.fromDay,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get dailyMinutes => $composableBuilder(
    column: $table.dailyMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capMinutes => $composableBuilder(
    column: $table.capMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get earnCapMinutes => $composableBuilder(
    column: $table.earnCapMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get goldPerHour => $composableBuilder(
    column: $table.goldPerHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get settledAt => $composableBuilder(
    column: $table.settledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unpaidSeconds => $composableBuilder(
    column: $table.unpaidSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get penalty => $composableBuilder(
    column: $table.penalty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FocusWeeksTableOrderingComposer
    extends Composer<_$AppDatabase, $FocusWeeksTable> {
  $$FocusWeeksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromDay => $composableBuilder(
    column: $table.fromDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get dailyMinutes => $composableBuilder(
    column: $table.dailyMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capMinutes => $composableBuilder(
    column: $table.capMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get earnCapMinutes => $composableBuilder(
    column: $table.earnCapMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get goldPerHour => $composableBuilder(
    column: $table.goldPerHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get settledAt => $composableBuilder(
    column: $table.settledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unpaidSeconds => $composableBuilder(
    column: $table.unpaidSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get penalty => $composableBuilder(
    column: $table.penalty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FocusWeeksTableAnnotationComposer
    extends Composer<_$AppDatabase, $FocusWeeksTable> {
  $$FocusWeeksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<LogicalDay, String> get weekStart =>
      $composableBuilder(column: $table.weekStart, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LogicalDay, String> get fromDay =>
      $composableBuilder(column: $table.fromDay, builder: (column) => column);

  GeneratedColumn<int> get dailyMinutes => $composableBuilder(
    column: $table.dailyMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get capMinutes => $composableBuilder(
    column: $table.capMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get earnCapMinutes => $composableBuilder(
    column: $table.earnCapMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get goldPerHour => $composableBuilder(
    column: $table.goldPerHour,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get settledAt =>
      $composableBuilder(column: $table.settledAt, builder: (column) => column);

  GeneratedColumn<int> get unpaidSeconds => $composableBuilder(
    column: $table.unpaidSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get penalty =>
      $composableBuilder(column: $table.penalty, builder: (column) => column);
}

class $$FocusWeeksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FocusWeeksTable,
          FocusWeekRow,
          $$FocusWeeksTableFilterComposer,
          $$FocusWeeksTableOrderingComposer,
          $$FocusWeeksTableAnnotationComposer,
          $$FocusWeeksTableCreateCompanionBuilder,
          $$FocusWeeksTableUpdateCompanionBuilder,
          (
            FocusWeekRow,
            BaseReferences<_$AppDatabase, $FocusWeeksTable, FocusWeekRow>,
          ),
          FocusWeekRow,
          PrefetchHooks Function()
        > {
  $$FocusWeeksTableTableManager(_$AppDatabase db, $FocusWeeksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FocusWeeksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FocusWeeksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FocusWeeksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<LogicalDay> weekStart = const Value.absent(),
                Value<LogicalDay> fromDay = const Value.absent(),
                Value<int> dailyMinutes = const Value.absent(),
                Value<int> capMinutes = const Value.absent(),
                Value<int> earnCapMinutes = const Value.absent(),
                Value<int> goldPerHour = const Value.absent(),
                Value<DateTime?> settledAt = const Value.absent(),
                Value<int?> unpaidSeconds = const Value.absent(),
                Value<int?> penalty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FocusWeeksCompanion(
                weekStart: weekStart,
                fromDay: fromDay,
                dailyMinutes: dailyMinutes,
                capMinutes: capMinutes,
                earnCapMinutes: earnCapMinutes,
                goldPerHour: goldPerHour,
                settledAt: settledAt,
                unpaidSeconds: unpaidSeconds,
                penalty: penalty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required LogicalDay weekStart,
                required LogicalDay fromDay,
                required int dailyMinutes,
                required int capMinutes,
                required int earnCapMinutes,
                required int goldPerHour,
                Value<DateTime?> settledAt = const Value.absent(),
                Value<int?> unpaidSeconds = const Value.absent(),
                Value<int?> penalty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FocusWeeksCompanion.insert(
                weekStart: weekStart,
                fromDay: fromDay,
                dailyMinutes: dailyMinutes,
                capMinutes: capMinutes,
                earnCapMinutes: earnCapMinutes,
                goldPerHour: goldPerHour,
                settledAt: settledAt,
                unpaidSeconds: unpaidSeconds,
                penalty: penalty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FocusWeeksTable, FocusWeekRow>(table),
                  BaseReferences<_$AppDatabase, $FocusWeeksTable, FocusWeekRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FocusWeeksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FocusWeeksTable,
      FocusWeekRow,
      $$FocusWeeksTableFilterComposer,
      $$FocusWeeksTableOrderingComposer,
      $$FocusWeeksTableAnnotationComposer,
      $$FocusWeeksTableCreateCompanionBuilder,
      $$FocusWeeksTableUpdateCompanionBuilder,
      (
        FocusWeekRow,
        BaseReferences<_$AppDatabase, $FocusWeeksTable, FocusWeekRow>,
      ),
      FocusWeekRow,
      PrefetchHooks Function()
    >;
typedef $$FocusSessionsTableCreateCompanionBuilder =
    FocusSessionsCompanion Function({
      Value<int> id,
      required LogicalDay day,
      required DateTime startedAt,
      required DateTime lastSeenAt,
      Value<DateTime?> hiddenAt,
      Value<DateTime?> endedAt,
      Value<int> awaySeconds,
      Value<int> seconds,
      Value<String?> endReason,
    });
typedef $$FocusSessionsTableUpdateCompanionBuilder =
    FocusSessionsCompanion Function({
      Value<int> id,
      Value<LogicalDay> day,
      Value<DateTime> startedAt,
      Value<DateTime> lastSeenAt,
      Value<DateTime?> hiddenAt,
      Value<DateTime?> endedAt,
      Value<int> awaySeconds,
      Value<int> seconds,
      Value<String?> endReason,
    });

class $$FocusSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LogicalDay, LogicalDay, String> get day =>
      $composableBuilder(
        column: $table.day,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get hiddenAt => $composableBuilder(
    column: $table.hiddenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get awaySeconds => $composableBuilder(
    column: $table.awaySeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seconds => $composableBuilder(
    column: $table.seconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endReason => $composableBuilder(
    column: $table.endReason,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FocusSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get hiddenAt => $composableBuilder(
    column: $table.hiddenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get awaySeconds => $composableBuilder(
    column: $table.awaySeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seconds => $composableBuilder(
    column: $table.seconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endReason => $composableBuilder(
    column: $table.endReason,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FocusSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LogicalDay, String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get hiddenAt =>
      $composableBuilder(column: $table.hiddenAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get awaySeconds => $composableBuilder(
    column: $table.awaySeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get seconds =>
      $composableBuilder(column: $table.seconds, builder: (column) => column);

  GeneratedColumn<String> get endReason =>
      $composableBuilder(column: $table.endReason, builder: (column) => column);
}

class $$FocusSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FocusSessionsTable,
          FocusSessionRow,
          $$FocusSessionsTableFilterComposer,
          $$FocusSessionsTableOrderingComposer,
          $$FocusSessionsTableAnnotationComposer,
          $$FocusSessionsTableCreateCompanionBuilder,
          $$FocusSessionsTableUpdateCompanionBuilder,
          (
            FocusSessionRow,
            BaseReferences<_$AppDatabase, $FocusSessionsTable, FocusSessionRow>,
          ),
          FocusSessionRow,
          PrefetchHooks Function()
        > {
  $$FocusSessionsTableTableManager(_$AppDatabase db, $FocusSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FocusSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FocusSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FocusSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<LogicalDay> day = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> lastSeenAt = const Value.absent(),
                Value<DateTime?> hiddenAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> awaySeconds = const Value.absent(),
                Value<int> seconds = const Value.absent(),
                Value<String?> endReason = const Value.absent(),
              }) => FocusSessionsCompanion(
                id: id,
                day: day,
                startedAt: startedAt,
                lastSeenAt: lastSeenAt,
                hiddenAt: hiddenAt,
                endedAt: endedAt,
                awaySeconds: awaySeconds,
                seconds: seconds,
                endReason: endReason,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required LogicalDay day,
                required DateTime startedAt,
                required DateTime lastSeenAt,
                Value<DateTime?> hiddenAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> awaySeconds = const Value.absent(),
                Value<int> seconds = const Value.absent(),
                Value<String?> endReason = const Value.absent(),
              }) => FocusSessionsCompanion.insert(
                id: id,
                day: day,
                startedAt: startedAt,
                lastSeenAt: lastSeenAt,
                hiddenAt: hiddenAt,
                endedAt: endedAt,
                awaySeconds: awaySeconds,
                seconds: seconds,
                endReason: endReason,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$FocusSessionsTable, FocusSessionRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $FocusSessionsTable,
                    FocusSessionRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FocusSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FocusSessionsTable,
      FocusSessionRow,
      $$FocusSessionsTableFilterComposer,
      $$FocusSessionsTableOrderingComposer,
      $$FocusSessionsTableAnnotationComposer,
      $$FocusSessionsTableCreateCompanionBuilder,
      $$FocusSessionsTableUpdateCompanionBuilder,
      (
        FocusSessionRow,
        BaseReferences<_$AppDatabase, $FocusSessionsTable, FocusSessionRow>,
      ),
      FocusSessionRow,
      PrefetchHooks Function()
    >;
typedef $$BankAccountsTableCreateCompanionBuilder =
    BankAccountsCompanion Function({
      Value<int> id,
      required String name,
      Value<AccountRole?> role,
      required String icon,
      Value<int> weight,
      Value<int> sortOrder,
      Value<DateTime?> archivedAt,
      required DateTime createdAt,
    });
typedef $$BankAccountsTableUpdateCompanionBuilder =
    BankAccountsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<AccountRole?> role,
      Value<String> icon,
      Value<int> weight,
      Value<int> sortOrder,
      Value<DateTime?> archivedAt,
      Value<DateTime> createdAt,
    });

class $$BankAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $BankAccountsTable> {
  $$BankAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AccountRole?, AccountRole, String> get role =>
      $composableBuilder(
        column: $table.role,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BankAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $BankAccountsTable> {
  $$BankAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BankAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BankAccountsTable> {
  $$BankAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<AccountRole?, String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BankAccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BankAccountsTable,
          BankAccountRow,
          $$BankAccountsTableFilterComposer,
          $$BankAccountsTableOrderingComposer,
          $$BankAccountsTableAnnotationComposer,
          $$BankAccountsTableCreateCompanionBuilder,
          $$BankAccountsTableUpdateCompanionBuilder,
          (
            BankAccountRow,
            BaseReferences<_$AppDatabase, $BankAccountsTable, BankAccountRow>,
          ),
          BankAccountRow,
          PrefetchHooks Function()
        > {
  $$BankAccountsTableTableManager(_$AppDatabase db, $BankAccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BankAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BankAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BankAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<AccountRole?> role = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> weight = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BankAccountsCompanion(
                id: id,
                name: name,
                role: role,
                icon: icon,
                weight: weight,
                sortOrder: sortOrder,
                archivedAt: archivedAt,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<AccountRole?> role = const Value.absent(),
                required String icon,
                Value<int> weight = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                required DateTime createdAt,
              }) => BankAccountsCompanion.insert(
                id: id,
                name: name,
                role: role,
                icon: icon,
                weight: weight,
                sortOrder: sortOrder,
                archivedAt: archivedAt,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BankAccountsTable, BankAccountRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BankAccountsTable,
                    BankAccountRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BankAccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BankAccountsTable,
      BankAccountRow,
      $$BankAccountsTableFilterComposer,
      $$BankAccountsTableOrderingComposer,
      $$BankAccountsTableAnnotationComposer,
      $$BankAccountsTableCreateCompanionBuilder,
      $$BankAccountsTableUpdateCompanionBuilder,
      (
        BankAccountRow,
        BaseReferences<_$AppDatabase, $BankAccountsTable, BankAccountRow>,
      ),
      BankAccountRow,
      PrefetchHooks Function()
    >;
typedef $$BankTxnsTableCreateCompanionBuilder = BankTxnsCompanion Function({
  Value<int> id,
  required String uid,
  required TxnKind kind,
  Value<int?> fromId,
  Value<int?> toId,
  required int amount,
  required LogicalDay day,
  required DateTime at,
  Value<String> title,
  Value<String> note,
  Value<String?> ref,
  Value<String?> groupId,
  Value<String?> fixedId,
  Value<DateTime?> voidedAt,
  Value<String?> category,
  Value<bool> inbox,
  Value<String?> notionPageId,
  Value<DateTime?> notionEditedAt,
  Value<String?> syncState,
});
typedef $$BankTxnsTableUpdateCompanionBuilder = BankTxnsCompanion Function({
  Value<int> id,
  Value<String> uid,
  Value<TxnKind> kind,
  Value<int?> fromId,
  Value<int?> toId,
  Value<int> amount,
  Value<LogicalDay> day,
  Value<DateTime> at,
  Value<String> title,
  Value<String> note,
  Value<String?> ref,
  Value<String?> groupId,
  Value<String?> fixedId,
  Value<DateTime?> voidedAt,
  Value<String?> category,
  Value<bool> inbox,
  Value<String?> notionPageId,
  Value<DateTime?> notionEditedAt,
  Value<String?> syncState,
});

final class $$BankTxnsTableReferences
    extends BaseReferences<_$AppDatabase, $BankTxnsTable, BankTxnRow> {
  $$BankTxnsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BankAccountsTable _fromIdTable(_$AppDatabase db) =>
      db.bankAccounts.createAlias('bank_txns__from_id__bank_accounts__id');

  $$BankAccountsTableProcessedTableManager? get fromId {
    final $_column = $_itemColumn<int>('from_id');
    if ($_column == null) return null;
    final manager = $$BankAccountsTableTableManager(
      $_db,
      $_db.bankAccounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fromIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $BankAccountsTable _toIdTable(_$AppDatabase db) =>
      db.bankAccounts.createAlias('bank_txns__to_id__bank_accounts__id');

  $$BankAccountsTableProcessedTableManager? get toId {
    final $_column = $_itemColumn<int>('to_id');
    if ($_column == null) return null;
    final manager = $$BankAccountsTableTableManager(
      $_db,
      $_db.bankAccounts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_toIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BankTxnsTableFilterComposer
    extends Composer<_$AppDatabase, $BankTxnsTable> {
  $$BankTxnsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TxnKind, TxnKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LogicalDay, LogicalDay, String> get day =>
      $composableBuilder(
        column: $table.day,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fixedId => $composableBuilder(
    column: $table.fixedId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get voidedAt => $composableBuilder(
    column: $table.voidedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get inbox => $composableBuilder(
    column: $table.inbox,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notionPageId => $composableBuilder(
    column: $table.notionPageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get notionEditedAt => $composableBuilder(
    column: $table.notionEditedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  $$BankAccountsTableFilterComposer get fromId {
    final $$BankAccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromId,
      referencedTable: $db.bankAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BankAccountsTableFilterComposer(
            $db: $db,
            $table: $db.bankAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BankAccountsTableFilterComposer get toId {
    final $$BankAccountsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toId,
      referencedTable: $db.bankAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BankAccountsTableFilterComposer(
            $db: $db,
            $table: $db.bankAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BankTxnsTableOrderingComposer
    extends Composer<_$AppDatabase, $BankTxnsTable> {
  $$BankTxnsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uid => $composableBuilder(
    column: $table.uid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ref => $composableBuilder(
    column: $table.ref,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get groupId => $composableBuilder(
    column: $table.groupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fixedId => $composableBuilder(
    column: $table.fixedId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get voidedAt => $composableBuilder(
    column: $table.voidedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get inbox => $composableBuilder(
    column: $table.inbox,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notionPageId => $composableBuilder(
    column: $table.notionPageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get notionEditedAt => $composableBuilder(
    column: $table.notionEditedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  $$BankAccountsTableOrderingComposer get fromId {
    final $$BankAccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromId,
      referencedTable: $db.bankAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BankAccountsTableOrderingComposer(
            $db: $db,
            $table: $db.bankAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BankAccountsTableOrderingComposer get toId {
    final $$BankAccountsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toId,
      referencedTable: $db.bankAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BankAccountsTableOrderingComposer(
            $db: $db,
            $table: $db.bankAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BankTxnsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BankTxnsTable> {
  $$BankTxnsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get uid =>
      $composableBuilder(column: $table.uid, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TxnKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LogicalDay, String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get ref =>
      $composableBuilder(column: $table.ref, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get fixedId =>
      $composableBuilder(column: $table.fixedId, builder: (column) => column);

  GeneratedColumn<DateTime> get voidedAt =>
      $composableBuilder(column: $table.voidedAt, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<bool> get inbox =>
      $composableBuilder(column: $table.inbox, builder: (column) => column);

  GeneratedColumn<String> get notionPageId => $composableBuilder(
    column: $table.notionPageId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get notionEditedAt => $composableBuilder(
    column: $table.notionEditedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  $$BankAccountsTableAnnotationComposer get fromId {
    final $$BankAccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.fromId,
      referencedTable: $db.bankAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BankAccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.bankAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BankAccountsTableAnnotationComposer get toId {
    final $$BankAccountsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.toId,
      referencedTable: $db.bankAccounts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BankAccountsTableAnnotationComposer(
            $db: $db,
            $table: $db.bankAccounts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BankTxnsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BankTxnsTable,
          BankTxnRow,
          $$BankTxnsTableFilterComposer,
          $$BankTxnsTableOrderingComposer,
          $$BankTxnsTableAnnotationComposer,
          $$BankTxnsTableCreateCompanionBuilder,
          $$BankTxnsTableUpdateCompanionBuilder,
          (BankTxnRow, $$BankTxnsTableReferences),
          BankTxnRow,
          PrefetchHooks Function({bool fromId, bool toId})
        > {
  $$BankTxnsTableTableManager(_$AppDatabase db, $BankTxnsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BankTxnsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BankTxnsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BankTxnsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> uid = const Value.absent(),
                Value<TxnKind> kind = const Value.absent(),
                Value<int?> fromId = const Value.absent(),
                Value<int?> toId = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<LogicalDay> day = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String?> ref = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<String?> fixedId = const Value.absent(),
                Value<DateTime?> voidedAt = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<bool> inbox = const Value.absent(),
                Value<String?> notionPageId = const Value.absent(),
                Value<DateTime?> notionEditedAt = const Value.absent(),
                Value<String?> syncState = const Value.absent(),
              }) => BankTxnsCompanion(
                id: id,
                uid: uid,
                kind: kind,
                fromId: fromId,
                toId: toId,
                amount: amount,
                day: day,
                at: at,
                title: title,
                note: note,
                ref: ref,
                groupId: groupId,
                fixedId: fixedId,
                voidedAt: voidedAt,
                category: category,
                inbox: inbox,
                notionPageId: notionPageId,
                notionEditedAt: notionEditedAt,
                syncState: syncState,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String uid,
                required TxnKind kind,
                Value<int?> fromId = const Value.absent(),
                Value<int?> toId = const Value.absent(),
                required int amount,
                required LogicalDay day,
                required DateTime at,
                Value<String> title = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String?> ref = const Value.absent(),
                Value<String?> groupId = const Value.absent(),
                Value<String?> fixedId = const Value.absent(),
                Value<DateTime?> voidedAt = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<bool> inbox = const Value.absent(),
                Value<String?> notionPageId = const Value.absent(),
                Value<DateTime?> notionEditedAt = const Value.absent(),
                Value<String?> syncState = const Value.absent(),
              }) => BankTxnsCompanion.insert(
                id: id,
                uid: uid,
                kind: kind,
                fromId: fromId,
                toId: toId,
                amount: amount,
                day: day,
                at: at,
                title: title,
                note: note,
                ref: ref,
                groupId: groupId,
                fixedId: fixedId,
                voidedAt: voidedAt,
                category: category,
                inbox: inbox,
                notionPageId: notionPageId,
                notionEditedAt: notionEditedAt,
                syncState: syncState,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BankTxnsTable, BankTxnRow>(table),
                  $$BankTxnsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({fromId = false, toId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (fromId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.fromId,
                        referencedTable: $$BankTxnsTableReferences._fromIdTable(
                          db,
                        ),
                        referencedColumn: $$BankTxnsTableReferences
                            ._fromIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (toId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.toId,
                        referencedTable: $$BankTxnsTableReferences._toIdTable(
                          db,
                        ),
                        referencedColumn: $$BankTxnsTableReferences
                            ._toIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BankTxnsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BankTxnsTable,
      BankTxnRow,
      $$BankTxnsTableFilterComposer,
      $$BankTxnsTableOrderingComposer,
      $$BankTxnsTableAnnotationComposer,
      $$BankTxnsTableCreateCompanionBuilder,
      $$BankTxnsTableUpdateCompanionBuilder,
      (BankTxnRow, $$BankTxnsTableReferences),
      BankTxnRow,
      PrefetchHooks Function({bool fromId, bool toId})
    >;
typedef $$BankMonthsTableCreateCompanionBuilder = BankMonthsCompanion Function({
  required String month,
  required LogicalDay firstDay,
  required String configJson,
  required String mealPlanJson,
  Value<String> reservesJson,
  required int refill,
  required DateTime openedAt,
  Value<DateTime?> closedAt,
  Value<int> rowid,
});
typedef $$BankMonthsTableUpdateCompanionBuilder = BankMonthsCompanion Function({
  Value<String> month,
  Value<LogicalDay> firstDay,
  Value<String> configJson,
  Value<String> mealPlanJson,
  Value<String> reservesJson,
  Value<int> refill,
  Value<DateTime> openedAt,
  Value<DateTime?> closedAt,
  Value<int> rowid,
});

class $$BankMonthsTableFilterComposer
    extends Composer<_$AppDatabase, $BankMonthsTable> {
  $$BankMonthsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LogicalDay, LogicalDay, String> get firstDay =>
      $composableBuilder(
        column: $table.firstDay,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mealPlanJson => $composableBuilder(
    column: $table.mealPlanJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reservesJson => $composableBuilder(
    column: $table.reservesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get refill => $composableBuilder(
    column: $table.refill,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BankMonthsTableOrderingComposer
    extends Composer<_$AppDatabase, $BankMonthsTable> {
  $$BankMonthsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstDay => $composableBuilder(
    column: $table.firstDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mealPlanJson => $composableBuilder(
    column: $table.mealPlanJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reservesJson => $composableBuilder(
    column: $table.reservesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get refill => $composableBuilder(
    column: $table.refill,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BankMonthsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BankMonthsTable> {
  $$BankMonthsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LogicalDay, String> get firstDay =>
      $composableBuilder(column: $table.firstDay, builder: (column) => column);

  GeneratedColumn<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mealPlanJson => $composableBuilder(
    column: $table.mealPlanJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reservesJson => $composableBuilder(
    column: $table.reservesJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get refill =>
      $composableBuilder(column: $table.refill, builder: (column) => column);

  GeneratedColumn<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);
}

class $$BankMonthsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BankMonthsTable,
          BankMonthRow,
          $$BankMonthsTableFilterComposer,
          $$BankMonthsTableOrderingComposer,
          $$BankMonthsTableAnnotationComposer,
          $$BankMonthsTableCreateCompanionBuilder,
          $$BankMonthsTableUpdateCompanionBuilder,
          (
            BankMonthRow,
            BaseReferences<_$AppDatabase, $BankMonthsTable, BankMonthRow>,
          ),
          BankMonthRow,
          PrefetchHooks Function()
        > {
  $$BankMonthsTableTableManager(_$AppDatabase db, $BankMonthsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BankMonthsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BankMonthsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BankMonthsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> month = const Value.absent(),
                Value<LogicalDay> firstDay = const Value.absent(),
                Value<String> configJson = const Value.absent(),
                Value<String> mealPlanJson = const Value.absent(),
                Value<String> reservesJson = const Value.absent(),
                Value<int> refill = const Value.absent(),
                Value<DateTime> openedAt = const Value.absent(),
                Value<DateTime?> closedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BankMonthsCompanion(
                month: month,
                firstDay: firstDay,
                configJson: configJson,
                mealPlanJson: mealPlanJson,
                reservesJson: reservesJson,
                refill: refill,
                openedAt: openedAt,
                closedAt: closedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String month,
                required LogicalDay firstDay,
                required String configJson,
                required String mealPlanJson,
                Value<String> reservesJson = const Value.absent(),
                required int refill,
                required DateTime openedAt,
                Value<DateTime?> closedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BankMonthsCompanion.insert(
                month: month,
                firstDay: firstDay,
                configJson: configJson,
                mealPlanJson: mealPlanJson,
                reservesJson: reservesJson,
                refill: refill,
                openedAt: openedAt,
                closedAt: closedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BankMonthsTable, BankMonthRow>(table),
                  BaseReferences<_$AppDatabase, $BankMonthsTable, BankMonthRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BankMonthsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BankMonthsTable,
      BankMonthRow,
      $$BankMonthsTableFilterComposer,
      $$BankMonthsTableOrderingComposer,
      $$BankMonthsTableAnnotationComposer,
      $$BankMonthsTableCreateCompanionBuilder,
      $$BankMonthsTableUpdateCompanionBuilder,
      (
        BankMonthRow,
        BaseReferences<_$AppDatabase, $BankMonthsTable, BankMonthRow>,
      ),
      BankMonthRow,
      PrefetchHooks Function()
    >;
typedef $$CasinoWeeksTableCreateCompanionBuilder =
    CasinoWeeksCompanion Function({
      required LogicalDay weekStart,
      required LogicalDay fromDay,
      required int poolBefore,
      required int released,
      required int price,
      required int targetGold,
      required int priceLevel,
      Value<String> termsJson,
      required DateTime openedAt,
      Value<DateTime?> settledAt,
      Value<int?> swept,
      Value<int> rowid,
    });
typedef $$CasinoWeeksTableUpdateCompanionBuilder =
    CasinoWeeksCompanion Function({
      Value<LogicalDay> weekStart,
      Value<LogicalDay> fromDay,
      Value<int> poolBefore,
      Value<int> released,
      Value<int> price,
      Value<int> targetGold,
      Value<int> priceLevel,
      Value<String> termsJson,
      Value<DateTime> openedAt,
      Value<DateTime?> settledAt,
      Value<int?> swept,
      Value<int> rowid,
    });

class $$CasinoWeeksTableFilterComposer
    extends Composer<_$AppDatabase, $CasinoWeeksTable> {
  $$CasinoWeeksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<LogicalDay, LogicalDay, String>
  get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<LogicalDay, LogicalDay, String> get fromDay =>
      $composableBuilder(
        column: $table.fromDay,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get poolBefore => $composableBuilder(
    column: $table.poolBefore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get released => $composableBuilder(
    column: $table.released,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetGold => $composableBuilder(
    column: $table.targetGold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priceLevel => $composableBuilder(
    column: $table.priceLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get termsJson => $composableBuilder(
    column: $table.termsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get settledAt => $composableBuilder(
    column: $table.settledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get swept => $composableBuilder(
    column: $table.swept,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CasinoWeeksTableOrderingComposer
    extends Composer<_$AppDatabase, $CasinoWeeksTable> {
  $$CasinoWeeksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromDay => $composableBuilder(
    column: $table.fromDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get poolBefore => $composableBuilder(
    column: $table.poolBefore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get released => $composableBuilder(
    column: $table.released,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetGold => $composableBuilder(
    column: $table.targetGold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priceLevel => $composableBuilder(
    column: $table.priceLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get termsJson => $composableBuilder(
    column: $table.termsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get settledAt => $composableBuilder(
    column: $table.settledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get swept => $composableBuilder(
    column: $table.swept,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CasinoWeeksTableAnnotationComposer
    extends Composer<_$AppDatabase, $CasinoWeeksTable> {
  $$CasinoWeeksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<LogicalDay, String> get weekStart =>
      $composableBuilder(column: $table.weekStart, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LogicalDay, String> get fromDay =>
      $composableBuilder(column: $table.fromDay, builder: (column) => column);

  GeneratedColumn<int> get poolBefore => $composableBuilder(
    column: $table.poolBefore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get released =>
      $composableBuilder(column: $table.released, builder: (column) => column);

  GeneratedColumn<int> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<int> get targetGold => $composableBuilder(
    column: $table.targetGold,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priceLevel => $composableBuilder(
    column: $table.priceLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get termsJson =>
      $composableBuilder(column: $table.termsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get settledAt =>
      $composableBuilder(column: $table.settledAt, builder: (column) => column);

  GeneratedColumn<int> get swept =>
      $composableBuilder(column: $table.swept, builder: (column) => column);
}

class $$CasinoWeeksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CasinoWeeksTable,
          CasinoWeekRow,
          $$CasinoWeeksTableFilterComposer,
          $$CasinoWeeksTableOrderingComposer,
          $$CasinoWeeksTableAnnotationComposer,
          $$CasinoWeeksTableCreateCompanionBuilder,
          $$CasinoWeeksTableUpdateCompanionBuilder,
          (
            CasinoWeekRow,
            BaseReferences<_$AppDatabase, $CasinoWeeksTable, CasinoWeekRow>,
          ),
          CasinoWeekRow,
          PrefetchHooks Function()
        > {
  $$CasinoWeeksTableTableManager(_$AppDatabase db, $CasinoWeeksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CasinoWeeksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CasinoWeeksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CasinoWeeksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<LogicalDay> weekStart = const Value.absent(),
                Value<LogicalDay> fromDay = const Value.absent(),
                Value<int> poolBefore = const Value.absent(),
                Value<int> released = const Value.absent(),
                Value<int> price = const Value.absent(),
                Value<int> targetGold = const Value.absent(),
                Value<int> priceLevel = const Value.absent(),
                Value<String> termsJson = const Value.absent(),
                Value<DateTime> openedAt = const Value.absent(),
                Value<DateTime?> settledAt = const Value.absent(),
                Value<int?> swept = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CasinoWeeksCompanion(
                weekStart: weekStart,
                fromDay: fromDay,
                poolBefore: poolBefore,
                released: released,
                price: price,
                targetGold: targetGold,
                priceLevel: priceLevel,
                termsJson: termsJson,
                openedAt: openedAt,
                settledAt: settledAt,
                swept: swept,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required LogicalDay weekStart,
                required LogicalDay fromDay,
                required int poolBefore,
                required int released,
                required int price,
                required int targetGold,
                required int priceLevel,
                Value<String> termsJson = const Value.absent(),
                required DateTime openedAt,
                Value<DateTime?> settledAt = const Value.absent(),
                Value<int?> swept = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CasinoWeeksCompanion.insert(
                weekStart: weekStart,
                fromDay: fromDay,
                poolBefore: poolBefore,
                released: released,
                price: price,
                targetGold: targetGold,
                priceLevel: priceLevel,
                termsJson: termsJson,
                openedAt: openedAt,
                settledAt: settledAt,
                swept: swept,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CasinoWeeksTable, CasinoWeekRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CasinoWeeksTable,
                    CasinoWeekRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CasinoWeeksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CasinoWeeksTable,
      CasinoWeekRow,
      $$CasinoWeeksTableFilterComposer,
      $$CasinoWeeksTableOrderingComposer,
      $$CasinoWeeksTableAnnotationComposer,
      $$CasinoWeeksTableCreateCompanionBuilder,
      $$CasinoWeeksTableUpdateCompanionBuilder,
      (
        CasinoWeekRow,
        BaseReferences<_$AppDatabase, $CasinoWeeksTable, CasinoWeekRow>,
      ),
      CasinoWeekRow,
      PrefetchHooks Function()
    >;
typedef $$CasinoTicketsTableCreateCompanionBuilder =
    CasinoTicketsCompanion Function({
      Value<int> id,
      required LogicalDay weekStart,
      required TicketKind kind,
      Value<PrizeTier?> tier,
      Value<int> amount,
      Value<int?> accountId,
      Value<DateTime?> drawnAt,
      Value<CasinoGame?> game,
      Value<int?> paid,
    });
typedef $$CasinoTicketsTableUpdateCompanionBuilder =
    CasinoTicketsCompanion Function({
      Value<int> id,
      Value<LogicalDay> weekStart,
      Value<TicketKind> kind,
      Value<PrizeTier?> tier,
      Value<int> amount,
      Value<int?> accountId,
      Value<DateTime?> drawnAt,
      Value<CasinoGame?> game,
      Value<int?> paid,
    });

class $$CasinoTicketsTableFilterComposer
    extends Composer<_$AppDatabase, $CasinoTicketsTable> {
  $$CasinoTicketsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LogicalDay, LogicalDay, String>
  get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<TicketKind, TicketKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<PrizeTier?, PrizeTier, String> get tier =>
      $composableBuilder(
        column: $table.tier,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get drawnAt => $composableBuilder(
    column: $table.drawnAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CasinoGame?, CasinoGame, String> get game =>
      $composableBuilder(
        column: $table.game,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get paid => $composableBuilder(
    column: $table.paid,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CasinoTicketsTableOrderingComposer
    extends Composer<_$AppDatabase, $CasinoTicketsTable> {
  $$CasinoTicketsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get drawnAt => $composableBuilder(
    column: $table.drawnAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get game => $composableBuilder(
    column: $table.game,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paid => $composableBuilder(
    column: $table.paid,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CasinoTicketsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CasinoTicketsTable> {
  $$CasinoTicketsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LogicalDay, String> get weekStart =>
      $composableBuilder(column: $table.weekStart, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TicketKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PrizeTier?, String> get tier =>
      $composableBuilder(column: $table.tier, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<DateTime> get drawnAt =>
      $composableBuilder(column: $table.drawnAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CasinoGame?, String> get game =>
      $composableBuilder(column: $table.game, builder: (column) => column);

  GeneratedColumn<int> get paid =>
      $composableBuilder(column: $table.paid, builder: (column) => column);
}

class $$CasinoTicketsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CasinoTicketsTable,
          CasinoTicketRow,
          $$CasinoTicketsTableFilterComposer,
          $$CasinoTicketsTableOrderingComposer,
          $$CasinoTicketsTableAnnotationComposer,
          $$CasinoTicketsTableCreateCompanionBuilder,
          $$CasinoTicketsTableUpdateCompanionBuilder,
          (
            CasinoTicketRow,
            BaseReferences<_$AppDatabase, $CasinoTicketsTable, CasinoTicketRow>,
          ),
          CasinoTicketRow,
          PrefetchHooks Function()
        > {
  $$CasinoTicketsTableTableManager(_$AppDatabase db, $CasinoTicketsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CasinoTicketsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CasinoTicketsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CasinoTicketsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<LogicalDay> weekStart = const Value.absent(),
                Value<TicketKind> kind = const Value.absent(),
                Value<PrizeTier?> tier = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<int?> accountId = const Value.absent(),
                Value<DateTime?> drawnAt = const Value.absent(),
                Value<CasinoGame?> game = const Value.absent(),
                Value<int?> paid = const Value.absent(),
              }) => CasinoTicketsCompanion(
                id: id,
                weekStart: weekStart,
                kind: kind,
                tier: tier,
                amount: amount,
                accountId: accountId,
                drawnAt: drawnAt,
                game: game,
                paid: paid,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required LogicalDay weekStart,
                required TicketKind kind,
                Value<PrizeTier?> tier = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<int?> accountId = const Value.absent(),
                Value<DateTime?> drawnAt = const Value.absent(),
                Value<CasinoGame?> game = const Value.absent(),
                Value<int?> paid = const Value.absent(),
              }) => CasinoTicketsCompanion.insert(
                id: id,
                weekStart: weekStart,
                kind: kind,
                tier: tier,
                amount: amount,
                accountId: accountId,
                drawnAt: drawnAt,
                game: game,
                paid: paid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CasinoTicketsTable, CasinoTicketRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $CasinoTicketsTable,
                    CasinoTicketRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CasinoTicketsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CasinoTicketsTable,
      CasinoTicketRow,
      $$CasinoTicketsTableFilterComposer,
      $$CasinoTicketsTableOrderingComposer,
      $$CasinoTicketsTableAnnotationComposer,
      $$CasinoTicketsTableCreateCompanionBuilder,
      $$CasinoTicketsTableUpdateCompanionBuilder,
      (
        CasinoTicketRow,
        BaseReferences<_$AppDatabase, $CasinoTicketsTable, CasinoTicketRow>,
      ),
      CasinoTicketRow,
      PrefetchHooks Function()
    >;
typedef $$ChaptersTableCreateCompanionBuilder = ChaptersCompanion Function({
  Value<int> id,
  required int number,
  required LogicalDay periodStart,
  required int periodDays,
  required ChapterStatus status,
  Value<String> title,
  Value<String> body,
  Value<String> choicesJson,
  Value<int?> chosenIndex,
  Value<String> recap,
  Value<String?> judgement,
  Value<double?> score,
  Value<String> statsJson,
  required DateTime createdAt,
  Value<DateTime?> writtenAt,
});
typedef $$ChaptersTableUpdateCompanionBuilder = ChaptersCompanion Function({
  Value<int> id,
  Value<int> number,
  Value<LogicalDay> periodStart,
  Value<int> periodDays,
  Value<ChapterStatus> status,
  Value<String> title,
  Value<String> body,
  Value<String> choicesJson,
  Value<int?> chosenIndex,
  Value<String> recap,
  Value<String?> judgement,
  Value<double?> score,
  Value<String> statsJson,
  Value<DateTime> createdAt,
  Value<DateTime?> writtenAt,
});

class $$ChaptersTableFilterComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LogicalDay, LogicalDay, String>
  get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<int> get periodDays => $composableBuilder(
    column: $table.periodDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ChapterStatus, ChapterStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get choicesJson => $composableBuilder(
    column: $table.choicesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chosenIndex => $composableBuilder(
    column: $table.chosenIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recap => $composableBuilder(
    column: $table.recap,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get judgement => $composableBuilder(
    column: $table.judgement,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statsJson => $composableBuilder(
    column: $table.statsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get writtenAt => $composableBuilder(
    column: $table.writtenAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChaptersTableOrderingComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get number => $composableBuilder(
    column: $table.number,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodStart => $composableBuilder(
    column: $table.periodStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get periodDays => $composableBuilder(
    column: $table.periodDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get choicesJson => $composableBuilder(
    column: $table.choicesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chosenIndex => $composableBuilder(
    column: $table.chosenIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recap => $composableBuilder(
    column: $table.recap,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get judgement => $composableBuilder(
    column: $table.judgement,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statsJson => $composableBuilder(
    column: $table.statsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get writtenAt => $composableBuilder(
    column: $table.writtenAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChaptersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get number =>
      $composableBuilder(column: $table.number, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LogicalDay, String> get periodStart =>
      $composableBuilder(
        column: $table.periodStart,
        builder: (column) => column,
      );

  GeneratedColumn<int> get periodDays => $composableBuilder(
    column: $table.periodDays,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<ChapterStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get choicesJson => $composableBuilder(
    column: $table.choicesJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get chosenIndex => $composableBuilder(
    column: $table.chosenIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get recap =>
      $composableBuilder(column: $table.recap, builder: (column) => column);

  GeneratedColumn<String> get judgement =>
      $composableBuilder(column: $table.judgement, builder: (column) => column);

  GeneratedColumn<double> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<String> get statsJson =>
      $composableBuilder(column: $table.statsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get writtenAt =>
      $composableBuilder(column: $table.writtenAt, builder: (column) => column);
}

class $$ChaptersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChaptersTable,
          ChapterRow,
          $$ChaptersTableFilterComposer,
          $$ChaptersTableOrderingComposer,
          $$ChaptersTableAnnotationComposer,
          $$ChaptersTableCreateCompanionBuilder,
          $$ChaptersTableUpdateCompanionBuilder,
          (
            ChapterRow,
            BaseReferences<_$AppDatabase, $ChaptersTable, ChapterRow>,
          ),
          ChapterRow,
          PrefetchHooks Function()
        > {
  $$ChaptersTableTableManager(_$AppDatabase db, $ChaptersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> number = const Value.absent(),
                Value<LogicalDay> periodStart = const Value.absent(),
                Value<int> periodDays = const Value.absent(),
                Value<ChapterStatus> status = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> choicesJson = const Value.absent(),
                Value<int?> chosenIndex = const Value.absent(),
                Value<String> recap = const Value.absent(),
                Value<String?> judgement = const Value.absent(),
                Value<double?> score = const Value.absent(),
                Value<String> statsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> writtenAt = const Value.absent(),
              }) => ChaptersCompanion(
                id: id,
                number: number,
                periodStart: periodStart,
                periodDays: periodDays,
                status: status,
                title: title,
                body: body,
                choicesJson: choicesJson,
                chosenIndex: chosenIndex,
                recap: recap,
                judgement: judgement,
                score: score,
                statsJson: statsJson,
                createdAt: createdAt,
                writtenAt: writtenAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int number,
                required LogicalDay periodStart,
                required int periodDays,
                required ChapterStatus status,
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> choicesJson = const Value.absent(),
                Value<int?> chosenIndex = const Value.absent(),
                Value<String> recap = const Value.absent(),
                Value<String?> judgement = const Value.absent(),
                Value<double?> score = const Value.absent(),
                Value<String> statsJson = const Value.absent(),
                required DateTime createdAt,
                Value<DateTime?> writtenAt = const Value.absent(),
              }) => ChaptersCompanion.insert(
                id: id,
                number: number,
                periodStart: periodStart,
                periodDays: periodDays,
                status: status,
                title: title,
                body: body,
                choicesJson: choicesJson,
                chosenIndex: chosenIndex,
                recap: recap,
                judgement: judgement,
                score: score,
                statsJson: statsJson,
                createdAt: createdAt,
                writtenAt: writtenAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChaptersTable, ChapterRow>(table),
                  BaseReferences<_$AppDatabase, $ChaptersTable, ChapterRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChaptersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChaptersTable,
      ChapterRow,
      $$ChaptersTableFilterComposer,
      $$ChaptersTableOrderingComposer,
      $$ChaptersTableAnnotationComposer,
      $$ChaptersTableCreateCompanionBuilder,
      $$ChaptersTableUpdateCompanionBuilder,
      (ChapterRow, BaseReferences<_$AppDatabase, $ChaptersTable, ChapterRow>),
      ChapterRow,
      PrefetchHooks Function()
    >;
typedef $$UpgradeOffersTableCreateCompanionBuilder =
    UpgradeOffersCompanion Function({
      Value<int> id,
      required int questId,
      required OfferKind kind,
      Value<double?> proposedTarget,
      required String proposedTitle,
      Value<String> proposedSubtitle,
      Value<String> npcLine,
      required OfferStatus status,
      Value<int?> chapterId,
      required DateTime createdAt,
    });
typedef $$UpgradeOffersTableUpdateCompanionBuilder =
    UpgradeOffersCompanion Function({
      Value<int> id,
      Value<int> questId,
      Value<OfferKind> kind,
      Value<double?> proposedTarget,
      Value<String> proposedTitle,
      Value<String> proposedSubtitle,
      Value<String> npcLine,
      Value<OfferStatus> status,
      Value<int?> chapterId,
      Value<DateTime> createdAt,
    });

final class $$UpgradeOffersTableReferences
    extends
        BaseReferences<_$AppDatabase, $UpgradeOffersTable, UpgradeOfferRow> {
  $$UpgradeOffersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $QuestsTable _questIdTable(_$AppDatabase db) =>
      db.quests.createAlias('upgrade_offers__quest_id__quests__id');

  $$QuestsTableProcessedTableManager get questId {
    final $_column = $_itemColumn<int>('quest_id')!;

    final manager = $$QuestsTableTableManager(
      $_db,
      $_db.quests,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_questIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UpgradeOffersTableFilterComposer
    extends Composer<_$AppDatabase, $UpgradeOffersTable> {
  $$UpgradeOffersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<OfferKind, OfferKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get proposedTarget => $composableBuilder(
    column: $table.proposedTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get proposedTitle => $composableBuilder(
    column: $table.proposedTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get proposedSubtitle => $composableBuilder(
    column: $table.proposedSubtitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get npcLine => $composableBuilder(
    column: $table.npcLine,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<OfferStatus, OfferStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$QuestsTableFilterComposer get questId {
    final $$QuestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questId,
      referencedTable: $db.quests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestsTableFilterComposer(
            $db: $db,
            $table: $db.quests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UpgradeOffersTableOrderingComposer
    extends Composer<_$AppDatabase, $UpgradeOffersTable> {
  $$UpgradeOffersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proposedTarget => $composableBuilder(
    column: $table.proposedTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get proposedTitle => $composableBuilder(
    column: $table.proposedTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get proposedSubtitle => $composableBuilder(
    column: $table.proposedSubtitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get npcLine => $composableBuilder(
    column: $table.npcLine,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$QuestsTableOrderingComposer get questId {
    final $$QuestsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questId,
      referencedTable: $db.quests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestsTableOrderingComposer(
            $db: $db,
            $table: $db.quests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UpgradeOffersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UpgradeOffersTable> {
  $$UpgradeOffersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<OfferKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<double> get proposedTarget => $composableBuilder(
    column: $table.proposedTarget,
    builder: (column) => column,
  );

  GeneratedColumn<String> get proposedTitle => $composableBuilder(
    column: $table.proposedTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get proposedSubtitle => $composableBuilder(
    column: $table.proposedSubtitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get npcLine =>
      $composableBuilder(column: $table.npcLine, builder: (column) => column);

  GeneratedColumnWithTypeConverter<OfferStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$QuestsTableAnnotationComposer get questId {
    final $$QuestsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.questId,
      referencedTable: $db.quests,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuestsTableAnnotationComposer(
            $db: $db,
            $table: $db.quests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UpgradeOffersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UpgradeOffersTable,
          UpgradeOfferRow,
          $$UpgradeOffersTableFilterComposer,
          $$UpgradeOffersTableOrderingComposer,
          $$UpgradeOffersTableAnnotationComposer,
          $$UpgradeOffersTableCreateCompanionBuilder,
          $$UpgradeOffersTableUpdateCompanionBuilder,
          (UpgradeOfferRow, $$UpgradeOffersTableReferences),
          UpgradeOfferRow,
          PrefetchHooks Function({bool questId})
        > {
  $$UpgradeOffersTableTableManager(_$AppDatabase db, $UpgradeOffersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UpgradeOffersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UpgradeOffersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UpgradeOffersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> questId = const Value.absent(),
                Value<OfferKind> kind = const Value.absent(),
                Value<double?> proposedTarget = const Value.absent(),
                Value<String> proposedTitle = const Value.absent(),
                Value<String> proposedSubtitle = const Value.absent(),
                Value<String> npcLine = const Value.absent(),
                Value<OfferStatus> status = const Value.absent(),
                Value<int?> chapterId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UpgradeOffersCompanion(
                id: id,
                questId: questId,
                kind: kind,
                proposedTarget: proposedTarget,
                proposedTitle: proposedTitle,
                proposedSubtitle: proposedSubtitle,
                npcLine: npcLine,
                status: status,
                chapterId: chapterId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int questId,
                required OfferKind kind,
                Value<double?> proposedTarget = const Value.absent(),
                required String proposedTitle,
                Value<String> proposedSubtitle = const Value.absent(),
                Value<String> npcLine = const Value.absent(),
                required OfferStatus status,
                Value<int?> chapterId = const Value.absent(),
                required DateTime createdAt,
              }) => UpgradeOffersCompanion.insert(
                id: id,
                questId: questId,
                kind: kind,
                proposedTarget: proposedTarget,
                proposedTitle: proposedTitle,
                proposedSubtitle: proposedSubtitle,
                npcLine: npcLine,
                status: status,
                chapterId: chapterId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UpgradeOffersTable, UpgradeOfferRow>(table),
                  $$UpgradeOffersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({questId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (questId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.questId,
                        referencedTable: $$UpgradeOffersTableReferences
                            ._questIdTable(db),
                        referencedColumn: $$UpgradeOffersTableReferences
                            ._questIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$UpgradeOffersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UpgradeOffersTable,
      UpgradeOfferRow,
      $$UpgradeOffersTableFilterComposer,
      $$UpgradeOffersTableOrderingComposer,
      $$UpgradeOffersTableAnnotationComposer,
      $$UpgradeOffersTableCreateCompanionBuilder,
      $$UpgradeOffersTableUpdateCompanionBuilder,
      (UpgradeOfferRow, $$UpgradeOffersTableReferences),
      UpgradeOfferRow,
      PrefetchHooks Function({bool questId})
    >;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          SettingRow,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => SettingsCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingsTable, SettingRow>(table),
                  BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      SettingRow,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (SettingRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>),
      SettingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AdventurersTableTableManager get adventurers =>
      $$AdventurersTableTableManager(_db, _db.adventurers);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db, _db.habits);
  $$QuestsTableTableManager get quests =>
      $$QuestsTableTableManager(_db, _db.quests);
  $$CheckInsTableTableManager get checkIns =>
      $$CheckInsTableTableManager(_db, _db.checkIns);
  $$XpEventsTableTableManager get xpEvents =>
      $$XpEventsTableTableManager(_db, _db.xpEvents);
  $$GoldEventsTableTableManager get goldEvents =>
      $$GoldEventsTableTableManager(_db, _db.goldEvents);
  $$PurchasesTableTableManager get purchases =>
      $$PurchasesTableTableManager(_db, _db.purchases);
  $$PriceWeeksTableTableManager get priceWeeks =>
      $$PriceWeeksTableTableManager(_db, _db.priceWeeks);
  $$FocusWeeksTableTableManager get focusWeeks =>
      $$FocusWeeksTableTableManager(_db, _db.focusWeeks);
  $$FocusSessionsTableTableManager get focusSessions =>
      $$FocusSessionsTableTableManager(_db, _db.focusSessions);
  $$BankAccountsTableTableManager get bankAccounts =>
      $$BankAccountsTableTableManager(_db, _db.bankAccounts);
  $$BankTxnsTableTableManager get bankTxns =>
      $$BankTxnsTableTableManager(_db, _db.bankTxns);
  $$BankMonthsTableTableManager get bankMonths =>
      $$BankMonthsTableTableManager(_db, _db.bankMonths);
  $$CasinoWeeksTableTableManager get casinoWeeks =>
      $$CasinoWeeksTableTableManager(_db, _db.casinoWeeks);
  $$CasinoTicketsTableTableManager get casinoTickets =>
      $$CasinoTicketsTableTableManager(_db, _db.casinoTickets);
  $$ChaptersTableTableManager get chapters =>
      $$ChaptersTableTableManager(_db, _db.chapters);
  $$UpgradeOffersTableTableManager get upgradeOffers =>
      $$UpgradeOffersTableTableManager(_db, _db.upgradeOffers);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
