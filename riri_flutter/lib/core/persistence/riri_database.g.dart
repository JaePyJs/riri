// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'riri_database.dart';

// ignore_for_file: type=lint
class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, Reminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  late final GeneratedColumnWithTypeConverter<ReminderCategory, String>
      category = GeneratedColumn<String>('category', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<ReminderCategory>($RemindersTable.$convertercategory);
  @override
  late final GeneratedColumnWithTypeConverter<PersonalityMode, String>
      personalityMode = GeneratedColumn<String>(
              'personality_mode', aliasedName, false,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              defaultValue: const Constant('bestie'))
          .withConverter<PersonalityMode>(
              $RemindersTable.$converterpersonalityMode);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> dueDateTime =
      GeneratedColumn<int>('due_date_time', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<DateTime>($RemindersTable.$converterdueDateTime);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>('created_at', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<DateTime>($RemindersTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> completedAt =
      GeneratedColumn<int>('completed_at', aliasedName, true,
              type: DriftSqlType.int, requiredDuringInsert: false)
          .withConverter<DateTime?>($RemindersTable.$convertercompletedAtn);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isRecurringMeta =
      const VerificationMeta('isRecurring');
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
      'is_recurring', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_recurring" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _recurringIntervalMeta =
      const VerificationMeta('recurringInterval');
  @override
  late final GeneratedColumn<String> recurringInterval =
      GeneratedColumn<String>('recurring_interval', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recurringRuleJsonMeta =
      const VerificationMeta('recurringRuleJson');
  @override
  late final GeneratedColumn<String> recurringRuleJson =
      GeneratedColumn<String>('recurring_rule_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _snoozeCountMeta =
      const VerificationMeta('snoozeCount');
  @override
  late final GeneratedColumn<int> snoozeCount = GeneratedColumn<int>(
      'snooze_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _rescheduleCountMeta =
      const VerificationMeta('rescheduleCount');
  @override
  late final GeneratedColumn<int> rescheduleCount = GeneratedColumn<int>(
      'reschedule_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _rawInputMeta =
      const VerificationMeta('rawInput');
  @override
  late final GeneratedColumn<String> rawInput = GeneratedColumn<String>(
      'raw_input', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _taglishNormalizedMeta =
      const VerificationMeta('taglishNormalized');
  @override
  late final GeneratedColumn<String> taglishNormalized =
      GeneratedColumn<String>('taglish_normalized', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _taglishTokensJsonMeta =
      const VerificationMeta('taglishTokensJson');
  @override
  late final GeneratedColumn<String> taglishTokensJson =
      GeneratedColumn<String>('taglish_tokens_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _procrastinationScoreMeta =
      const VerificationMeta('procrastinationScore');
  @override
  late final GeneratedColumn<double> procrastinationScore =
      GeneratedColumn<double>('procrastination_score', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        description,
        category,
        personalityMode,
        dueDateTime,
        createdAt,
        completedAt,
        isCompleted,
        isRecurring,
        recurringInterval,
        recurringRuleJson,
        snoozeCount,
        rescheduleCount,
        rawInput,
        taglishNormalized,
        taglishTokensJson,
        procrastinationScore
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(Insertable<Reminder> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('is_recurring')) {
      context.handle(
          _isRecurringMeta,
          isRecurring.isAcceptableOrUnknown(
              data['is_recurring']!, _isRecurringMeta));
    }
    if (data.containsKey('recurring_interval')) {
      context.handle(
          _recurringIntervalMeta,
          recurringInterval.isAcceptableOrUnknown(
              data['recurring_interval']!, _recurringIntervalMeta));
    }
    if (data.containsKey('recurring_rule_json')) {
      context.handle(
          _recurringRuleJsonMeta,
          recurringRuleJson.isAcceptableOrUnknown(
              data['recurring_rule_json']!, _recurringRuleJsonMeta));
    }
    if (data.containsKey('snooze_count')) {
      context.handle(
          _snoozeCountMeta,
          snoozeCount.isAcceptableOrUnknown(
              data['snooze_count']!, _snoozeCountMeta));
    }
    if (data.containsKey('reschedule_count')) {
      context.handle(
          _rescheduleCountMeta,
          rescheduleCount.isAcceptableOrUnknown(
              data['reschedule_count']!, _rescheduleCountMeta));
    }
    if (data.containsKey('raw_input')) {
      context.handle(_rawInputMeta,
          rawInput.isAcceptableOrUnknown(data['raw_input']!, _rawInputMeta));
    }
    if (data.containsKey('taglish_normalized')) {
      context.handle(
          _taglishNormalizedMeta,
          taglishNormalized.isAcceptableOrUnknown(
              data['taglish_normalized']!, _taglishNormalizedMeta));
    }
    if (data.containsKey('taglish_tokens_json')) {
      context.handle(
          _taglishTokensJsonMeta,
          taglishTokensJson.isAcceptableOrUnknown(
              data['taglish_tokens_json']!, _taglishTokensJsonMeta));
    }
    if (data.containsKey('procrastination_score')) {
      context.handle(
          _procrastinationScoreMeta,
          procrastinationScore.isAcceptableOrUnknown(
              data['procrastination_score']!, _procrastinationScoreMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Reminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reminder(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      category: $RemindersTable.$convertercategory.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!),
      personalityMode: $RemindersTable.$converterpersonalityMode.fromSql(
          attachedDatabase.typeMapping.read(DriftSqlType.string,
              data['${effectivePrefix}personality_mode'])!),
      dueDateTime: $RemindersTable.$converterdueDateTime.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.int, data['${effectivePrefix}due_date_time'])!),
      createdAt: $RemindersTable.$convertercreatedAt.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!),
      completedAt: $RemindersTable.$convertercompletedAtn.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}completed_at'])),
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      isRecurring: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_recurring'])!,
      recurringInterval: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}recurring_interval']),
      recurringRuleJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}recurring_rule_json']),
      snoozeCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}snooze_count'])!,
      rescheduleCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reschedule_count'])!,
      rawInput: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}raw_input']),
      taglishNormalized: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}taglish_normalized']),
      taglishTokensJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}taglish_tokens_json']),
      procrastinationScore: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}procrastination_score'])!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<ReminderCategory, String, String>
      $convertercategory =
      const EnumNameConverter<ReminderCategory>(ReminderCategory.values);
  static JsonTypeConverter2<PersonalityMode, String, String>
      $converterpersonalityMode =
      const EnumNameConverter<PersonalityMode>(PersonalityMode.values);
  static TypeConverter<DateTime, int> $converterdueDateTime =
      const DateTimeConverter();
  static TypeConverter<DateTime, int> $convertercreatedAt =
      const DateTimeConverter();
  static TypeConverter<DateTime, int> $convertercompletedAt =
      const DateTimeConverter();
  static TypeConverter<DateTime?, int?> $convertercompletedAtn =
      NullAwareTypeConverter.wrap($convertercompletedAt);
}

class Reminder extends DataClass implements Insertable<Reminder> {
  final int id;
  final String title;
  final String? description;
  final ReminderCategory category;
  final PersonalityMode personalityMode;
  final DateTime dueDateTime;
  final DateTime createdAt;
  final DateTime? completedAt;
  final bool isCompleted;
  final bool isRecurring;
  final String? recurringInterval;
  final String? recurringRuleJson;
  final int snoozeCount;
  final int rescheduleCount;
  final String? rawInput;
  final String? taglishNormalized;
  final String? taglishTokensJson;
  final double procrastinationScore;
  const Reminder(
      {required this.id,
      required this.title,
      this.description,
      required this.category,
      required this.personalityMode,
      required this.dueDateTime,
      required this.createdAt,
      this.completedAt,
      required this.isCompleted,
      required this.isRecurring,
      this.recurringInterval,
      this.recurringRuleJson,
      required this.snoozeCount,
      required this.rescheduleCount,
      this.rawInput,
      this.taglishNormalized,
      this.taglishTokensJson,
      required this.procrastinationScore});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    {
      map['category'] =
          Variable<String>($RemindersTable.$convertercategory.toSql(category));
    }
    {
      map['personality_mode'] = Variable<String>(
          $RemindersTable.$converterpersonalityMode.toSql(personalityMode));
    }
    {
      map['due_date_time'] = Variable<int>(
          $RemindersTable.$converterdueDateTime.toSql(dueDateTime));
    }
    {
      map['created_at'] =
          Variable<int>($RemindersTable.$convertercreatedAt.toSql(createdAt));
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(
          $RemindersTable.$convertercompletedAtn.toSql(completedAt));
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    map['is_recurring'] = Variable<bool>(isRecurring);
    if (!nullToAbsent || recurringInterval != null) {
      map['recurring_interval'] = Variable<String>(recurringInterval);
    }
    if (!nullToAbsent || recurringRuleJson != null) {
      map['recurring_rule_json'] = Variable<String>(recurringRuleJson);
    }
    map['snooze_count'] = Variable<int>(snoozeCount);
    map['reschedule_count'] = Variable<int>(rescheduleCount);
    if (!nullToAbsent || rawInput != null) {
      map['raw_input'] = Variable<String>(rawInput);
    }
    if (!nullToAbsent || taglishNormalized != null) {
      map['taglish_normalized'] = Variable<String>(taglishNormalized);
    }
    if (!nullToAbsent || taglishTokensJson != null) {
      map['taglish_tokens_json'] = Variable<String>(taglishTokensJson);
    }
    map['procrastination_score'] = Variable<double>(procrastinationScore);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      id: Value(id),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      category: Value(category),
      personalityMode: Value(personalityMode),
      dueDateTime: Value(dueDateTime),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      isCompleted: Value(isCompleted),
      isRecurring: Value(isRecurring),
      recurringInterval: recurringInterval == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringInterval),
      recurringRuleJson: recurringRuleJson == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringRuleJson),
      snoozeCount: Value(snoozeCount),
      rescheduleCount: Value(rescheduleCount),
      rawInput: rawInput == null && nullToAbsent
          ? const Value.absent()
          : Value(rawInput),
      taglishNormalized: taglishNormalized == null && nullToAbsent
          ? const Value.absent()
          : Value(taglishNormalized),
      taglishTokensJson: taglishTokensJson == null && nullToAbsent
          ? const Value.absent()
          : Value(taglishTokensJson),
      procrastinationScore: Value(procrastinationScore),
    );
  }

  factory Reminder.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      category: $RemindersTable.$convertercategory
          .fromJson(serializer.fromJson<String>(json['category'])),
      personalityMode: $RemindersTable.$converterpersonalityMode
          .fromJson(serializer.fromJson<String>(json['personalityMode'])),
      dueDateTime: serializer.fromJson<DateTime>(json['dueDateTime']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
      recurringInterval:
          serializer.fromJson<String?>(json['recurringInterval']),
      recurringRuleJson:
          serializer.fromJson<String?>(json['recurringRuleJson']),
      snoozeCount: serializer.fromJson<int>(json['snoozeCount']),
      rescheduleCount: serializer.fromJson<int>(json['rescheduleCount']),
      rawInput: serializer.fromJson<String?>(json['rawInput']),
      taglishNormalized:
          serializer.fromJson<String?>(json['taglishNormalized']),
      taglishTokensJson:
          serializer.fromJson<String?>(json['taglishTokensJson']),
      procrastinationScore:
          serializer.fromJson<double>(json['procrastinationScore']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'category': serializer
          .toJson<String>($RemindersTable.$convertercategory.toJson(category)),
      'personalityMode': serializer.toJson<String>(
          $RemindersTable.$converterpersonalityMode.toJson(personalityMode)),
      'dueDateTime': serializer.toJson<DateTime>(dueDateTime),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'isRecurring': serializer.toJson<bool>(isRecurring),
      'recurringInterval': serializer.toJson<String?>(recurringInterval),
      'recurringRuleJson': serializer.toJson<String?>(recurringRuleJson),
      'snoozeCount': serializer.toJson<int>(snoozeCount),
      'rescheduleCount': serializer.toJson<int>(rescheduleCount),
      'rawInput': serializer.toJson<String?>(rawInput),
      'taglishNormalized': serializer.toJson<String?>(taglishNormalized),
      'taglishTokensJson': serializer.toJson<String?>(taglishTokensJson),
      'procrastinationScore': serializer.toJson<double>(procrastinationScore),
    };
  }

  Reminder copyWith(
          {int? id,
          String? title,
          Value<String?> description = const Value.absent(),
          ReminderCategory? category,
          PersonalityMode? personalityMode,
          DateTime? dueDateTime,
          DateTime? createdAt,
          Value<DateTime?> completedAt = const Value.absent(),
          bool? isCompleted,
          bool? isRecurring,
          Value<String?> recurringInterval = const Value.absent(),
          Value<String?> recurringRuleJson = const Value.absent(),
          int? snoozeCount,
          int? rescheduleCount,
          Value<String?> rawInput = const Value.absent(),
          Value<String?> taglishNormalized = const Value.absent(),
          Value<String?> taglishTokensJson = const Value.absent(),
          double? procrastinationScore}) =>
      Reminder(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        category: category ?? this.category,
        personalityMode: personalityMode ?? this.personalityMode,
        dueDateTime: dueDateTime ?? this.dueDateTime,
        createdAt: createdAt ?? this.createdAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        isCompleted: isCompleted ?? this.isCompleted,
        isRecurring: isRecurring ?? this.isRecurring,
        recurringInterval: recurringInterval.present
            ? recurringInterval.value
            : this.recurringInterval,
        recurringRuleJson: recurringRuleJson.present
            ? recurringRuleJson.value
            : this.recurringRuleJson,
        snoozeCount: snoozeCount ?? this.snoozeCount,
        rescheduleCount: rescheduleCount ?? this.rescheduleCount,
        rawInput: rawInput.present ? rawInput.value : this.rawInput,
        taglishNormalized: taglishNormalized.present
            ? taglishNormalized.value
            : this.taglishNormalized,
        taglishTokensJson: taglishTokensJson.present
            ? taglishTokensJson.value
            : this.taglishTokensJson,
        procrastinationScore: procrastinationScore ?? this.procrastinationScore,
      );
  Reminder copyWithCompanion(RemindersCompanion data) {
    return Reminder(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      category: data.category.present ? data.category.value : this.category,
      personalityMode: data.personalityMode.present
          ? data.personalityMode.value
          : this.personalityMode,
      dueDateTime:
          data.dueDateTime.present ? data.dueDateTime.value : this.dueDateTime,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      isRecurring:
          data.isRecurring.present ? data.isRecurring.value : this.isRecurring,
      recurringInterval: data.recurringInterval.present
          ? data.recurringInterval.value
          : this.recurringInterval,
      recurringRuleJson: data.recurringRuleJson.present
          ? data.recurringRuleJson.value
          : this.recurringRuleJson,
      snoozeCount:
          data.snoozeCount.present ? data.snoozeCount.value : this.snoozeCount,
      rescheduleCount: data.rescheduleCount.present
          ? data.rescheduleCount.value
          : this.rescheduleCount,
      rawInput: data.rawInput.present ? data.rawInput.value : this.rawInput,
      taglishNormalized: data.taglishNormalized.present
          ? data.taglishNormalized.value
          : this.taglishNormalized,
      taglishTokensJson: data.taglishTokensJson.present
          ? data.taglishTokensJson.value
          : this.taglishTokensJson,
      procrastinationScore: data.procrastinationScore.present
          ? data.procrastinationScore.value
          : this.procrastinationScore,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('personalityMode: $personalityMode, ')
          ..write('dueDateTime: $dueDateTime, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurringInterval: $recurringInterval, ')
          ..write('recurringRuleJson: $recurringRuleJson, ')
          ..write('snoozeCount: $snoozeCount, ')
          ..write('rescheduleCount: $rescheduleCount, ')
          ..write('rawInput: $rawInput, ')
          ..write('taglishNormalized: $taglishNormalized, ')
          ..write('taglishTokensJson: $taglishTokensJson, ')
          ..write('procrastinationScore: $procrastinationScore')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      description,
      category,
      personalityMode,
      dueDateTime,
      createdAt,
      completedAt,
      isCompleted,
      isRecurring,
      recurringInterval,
      recurringRuleJson,
      snoozeCount,
      rescheduleCount,
      rawInput,
      taglishNormalized,
      taglishTokensJson,
      procrastinationScore);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.category == this.category &&
          other.personalityMode == this.personalityMode &&
          other.dueDateTime == this.dueDateTime &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt &&
          other.isCompleted == this.isCompleted &&
          other.isRecurring == this.isRecurring &&
          other.recurringInterval == this.recurringInterval &&
          other.recurringRuleJson == this.recurringRuleJson &&
          other.snoozeCount == this.snoozeCount &&
          other.rescheduleCount == this.rescheduleCount &&
          other.rawInput == this.rawInput &&
          other.taglishNormalized == this.taglishNormalized &&
          other.taglishTokensJson == this.taglishTokensJson &&
          other.procrastinationScore == this.procrastinationScore);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> description;
  final Value<ReminderCategory> category;
  final Value<PersonalityMode> personalityMode;
  final Value<DateTime> dueDateTime;
  final Value<DateTime> createdAt;
  final Value<DateTime?> completedAt;
  final Value<bool> isCompleted;
  final Value<bool> isRecurring;
  final Value<String?> recurringInterval;
  final Value<String?> recurringRuleJson;
  final Value<int> snoozeCount;
  final Value<int> rescheduleCount;
  final Value<String?> rawInput;
  final Value<String?> taglishNormalized;
  final Value<String?> taglishTokensJson;
  final Value<double> procrastinationScore;
  const RemindersCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.personalityMode = const Value.absent(),
    this.dueDateTime = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.recurringInterval = const Value.absent(),
    this.recurringRuleJson = const Value.absent(),
    this.snoozeCount = const Value.absent(),
    this.rescheduleCount = const Value.absent(),
    this.rawInput = const Value.absent(),
    this.taglishNormalized = const Value.absent(),
    this.taglishTokensJson = const Value.absent(),
    this.procrastinationScore = const Value.absent(),
  });
  RemindersCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required ReminderCategory category,
    this.personalityMode = const Value.absent(),
    required DateTime dueDateTime,
    required DateTime createdAt,
    this.completedAt = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.recurringInterval = const Value.absent(),
    this.recurringRuleJson = const Value.absent(),
    this.snoozeCount = const Value.absent(),
    this.rescheduleCount = const Value.absent(),
    this.rawInput = const Value.absent(),
    this.taglishNormalized = const Value.absent(),
    this.taglishTokensJson = const Value.absent(),
    this.procrastinationScore = const Value.absent(),
  })  : title = Value(title),
        category = Value(category),
        dueDateTime = Value(dueDateTime),
        createdAt = Value(createdAt);
  static Insertable<Reminder> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? category,
    Expression<String>? personalityMode,
    Expression<int>? dueDateTime,
    Expression<int>? createdAt,
    Expression<int>? completedAt,
    Expression<bool>? isCompleted,
    Expression<bool>? isRecurring,
    Expression<String>? recurringInterval,
    Expression<String>? recurringRuleJson,
    Expression<int>? snoozeCount,
    Expression<int>? rescheduleCount,
    Expression<String>? rawInput,
    Expression<String>? taglishNormalized,
    Expression<String>? taglishTokensJson,
    Expression<double>? procrastinationScore,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (personalityMode != null) 'personality_mode': personalityMode,
      if (dueDateTime != null) 'due_date_time': dueDateTime,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (isRecurring != null) 'is_recurring': isRecurring,
      if (recurringInterval != null) 'recurring_interval': recurringInterval,
      if (recurringRuleJson != null) 'recurring_rule_json': recurringRuleJson,
      if (snoozeCount != null) 'snooze_count': snoozeCount,
      if (rescheduleCount != null) 'reschedule_count': rescheduleCount,
      if (rawInput != null) 'raw_input': rawInput,
      if (taglishNormalized != null) 'taglish_normalized': taglishNormalized,
      if (taglishTokensJson != null) 'taglish_tokens_json': taglishTokensJson,
      if (procrastinationScore != null)
        'procrastination_score': procrastinationScore,
    });
  }

  RemindersCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String?>? description,
      Value<ReminderCategory>? category,
      Value<PersonalityMode>? personalityMode,
      Value<DateTime>? dueDateTime,
      Value<DateTime>? createdAt,
      Value<DateTime?>? completedAt,
      Value<bool>? isCompleted,
      Value<bool>? isRecurring,
      Value<String?>? recurringInterval,
      Value<String?>? recurringRuleJson,
      Value<int>? snoozeCount,
      Value<int>? rescheduleCount,
      Value<String?>? rawInput,
      Value<String?>? taglishNormalized,
      Value<String?>? taglishTokensJson,
      Value<double>? procrastinationScore}) {
    return RemindersCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      personalityMode: personalityMode ?? this.personalityMode,
      dueDateTime: dueDateTime ?? this.dueDateTime,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringInterval: recurringInterval ?? this.recurringInterval,
      recurringRuleJson: recurringRuleJson ?? this.recurringRuleJson,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      rescheduleCount: rescheduleCount ?? this.rescheduleCount,
      rawInput: rawInput ?? this.rawInput,
      taglishNormalized: taglishNormalized ?? this.taglishNormalized,
      taglishTokensJson: taglishTokensJson ?? this.taglishTokensJson,
      procrastinationScore: procrastinationScore ?? this.procrastinationScore,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(
          $RemindersTable.$convertercategory.toSql(category.value));
    }
    if (personalityMode.present) {
      map['personality_mode'] = Variable<String>($RemindersTable
          .$converterpersonalityMode
          .toSql(personalityMode.value));
    }
    if (dueDateTime.present) {
      map['due_date_time'] = Variable<int>(
          $RemindersTable.$converterdueDateTime.toSql(dueDateTime.value));
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
          $RemindersTable.$convertercreatedAt.toSql(createdAt.value));
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(
          $RemindersTable.$convertercompletedAtn.toSql(completedAt.value));
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    if (recurringInterval.present) {
      map['recurring_interval'] = Variable<String>(recurringInterval.value);
    }
    if (recurringRuleJson.present) {
      map['recurring_rule_json'] = Variable<String>(recurringRuleJson.value);
    }
    if (snoozeCount.present) {
      map['snooze_count'] = Variable<int>(snoozeCount.value);
    }
    if (rescheduleCount.present) {
      map['reschedule_count'] = Variable<int>(rescheduleCount.value);
    }
    if (rawInput.present) {
      map['raw_input'] = Variable<String>(rawInput.value);
    }
    if (taglishNormalized.present) {
      map['taglish_normalized'] = Variable<String>(taglishNormalized.value);
    }
    if (taglishTokensJson.present) {
      map['taglish_tokens_json'] = Variable<String>(taglishTokensJson.value);
    }
    if (procrastinationScore.present) {
      map['procrastination_score'] =
          Variable<double>(procrastinationScore.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('personalityMode: $personalityMode, ')
          ..write('dueDateTime: $dueDateTime, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('recurringInterval: $recurringInterval, ')
          ..write('recurringRuleJson: $recurringRuleJson, ')
          ..write('snoozeCount: $snoozeCount, ')
          ..write('rescheduleCount: $rescheduleCount, ')
          ..write('rawInput: $rawInput, ')
          ..write('taglishNormalized: $taglishNormalized, ')
          ..write('taglishTokensJson: $taglishTokensJson, ')
          ..write('procrastinationScore: $procrastinationScore')
          ..write(')'))
        .toString();
  }
}

class $ChatMessagesTable extends ChatMessages
    with TableInfo<$ChatMessagesTable, ChatMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _messageTextMeta =
      const VerificationMeta('messageText');
  @override
  late final GeneratedColumn<String> messageText = GeneratedColumn<String>(
      'message_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isUserMeta = const VerificationMeta('isUser');
  @override
  late final GeneratedColumn<bool> isUser = GeneratedColumn<bool>(
      'is_user', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_user" IN (0, 1))'));
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> timestamp =
      GeneratedColumn<int>('timestamp', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<DateTime>($ChatMessagesTable.$convertertimestamp);
  static const VerificationMeta _stickerNameMeta =
      const VerificationMeta('stickerName');
  @override
  late final GeneratedColumn<String> stickerName = GeneratedColumn<String>(
      'sticker_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, messageText, isUser, timestamp, stickerName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_messages';
  @override
  VerificationContext validateIntegrity(Insertable<ChatMessage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('message_text')) {
      context.handle(
          _messageTextMeta,
          messageText.isAcceptableOrUnknown(
              data['message_text']!, _messageTextMeta));
    } else if (isInserting) {
      context.missing(_messageTextMeta);
    }
    if (data.containsKey('is_user')) {
      context.handle(_isUserMeta,
          isUser.isAcceptableOrUnknown(data['is_user']!, _isUserMeta));
    } else if (isInserting) {
      context.missing(_isUserMeta);
    }
    if (data.containsKey('sticker_name')) {
      context.handle(
          _stickerNameMeta,
          stickerName.isAcceptableOrUnknown(
              data['sticker_name']!, _stickerNameMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ChatMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessage(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      messageText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message_text'])!,
      isUser: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_user'])!,
      timestamp: $ChatMessagesTable.$convertertimestamp.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timestamp'])!),
      stickerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sticker_name']),
    );
  }

  @override
  $ChatMessagesTable createAlias(String alias) {
    return $ChatMessagesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertertimestamp =
      const DateTimeConverter();
}

class ChatMessage extends DataClass implements Insertable<ChatMessage> {
  final int id;
  final String messageText;
  final bool isUser;
  final DateTime timestamp;
  final String? stickerName;
  const ChatMessage(
      {required this.id,
      required this.messageText,
      required this.isUser,
      required this.timestamp,
      this.stickerName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['message_text'] = Variable<String>(messageText);
    map['is_user'] = Variable<bool>(isUser);
    {
      map['timestamp'] = Variable<int>(
          $ChatMessagesTable.$convertertimestamp.toSql(timestamp));
    }
    if (!nullToAbsent || stickerName != null) {
      map['sticker_name'] = Variable<String>(stickerName);
    }
    return map;
  }

  ChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return ChatMessagesCompanion(
      id: Value(id),
      messageText: Value(messageText),
      isUser: Value(isUser),
      timestamp: Value(timestamp),
      stickerName: stickerName == null && nullToAbsent
          ? const Value.absent()
          : Value(stickerName),
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessage(
      id: serializer.fromJson<int>(json['id']),
      messageText: serializer.fromJson<String>(json['messageText']),
      isUser: serializer.fromJson<bool>(json['isUser']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      stickerName: serializer.fromJson<String?>(json['stickerName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'messageText': serializer.toJson<String>(messageText),
      'isUser': serializer.toJson<bool>(isUser),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'stickerName': serializer.toJson<String?>(stickerName),
    };
  }

  ChatMessage copyWith(
          {int? id,
          String? messageText,
          bool? isUser,
          DateTime? timestamp,
          Value<String?> stickerName = const Value.absent()}) =>
      ChatMessage(
        id: id ?? this.id,
        messageText: messageText ?? this.messageText,
        isUser: isUser ?? this.isUser,
        timestamp: timestamp ?? this.timestamp,
        stickerName: stickerName.present ? stickerName.value : this.stickerName,
      );
  ChatMessage copyWithCompanion(ChatMessagesCompanion data) {
    return ChatMessage(
      id: data.id.present ? data.id.value : this.id,
      messageText:
          data.messageText.present ? data.messageText.value : this.messageText,
      isUser: data.isUser.present ? data.isUser.value : this.isUser,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      stickerName:
          data.stickerName.present ? data.stickerName.value : this.stickerName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessage(')
          ..write('id: $id, ')
          ..write('messageText: $messageText, ')
          ..write('isUser: $isUser, ')
          ..write('timestamp: $timestamp, ')
          ..write('stickerName: $stickerName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, messageText, isUser, timestamp, stickerName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessage &&
          other.id == this.id &&
          other.messageText == this.messageText &&
          other.isUser == this.isUser &&
          other.timestamp == this.timestamp &&
          other.stickerName == this.stickerName);
}

class ChatMessagesCompanion extends UpdateCompanion<ChatMessage> {
  final Value<int> id;
  final Value<String> messageText;
  final Value<bool> isUser;
  final Value<DateTime> timestamp;
  final Value<String?> stickerName;
  const ChatMessagesCompanion({
    this.id = const Value.absent(),
    this.messageText = const Value.absent(),
    this.isUser = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.stickerName = const Value.absent(),
  });
  ChatMessagesCompanion.insert({
    this.id = const Value.absent(),
    required String messageText,
    required bool isUser,
    required DateTime timestamp,
    this.stickerName = const Value.absent(),
  })  : messageText = Value(messageText),
        isUser = Value(isUser),
        timestamp = Value(timestamp);
  static Insertable<ChatMessage> custom({
    Expression<int>? id,
    Expression<String>? messageText,
    Expression<bool>? isUser,
    Expression<int>? timestamp,
    Expression<String>? stickerName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (messageText != null) 'message_text': messageText,
      if (isUser != null) 'is_user': isUser,
      if (timestamp != null) 'timestamp': timestamp,
      if (stickerName != null) 'sticker_name': stickerName,
    });
  }

  ChatMessagesCompanion copyWith(
      {Value<int>? id,
      Value<String>? messageText,
      Value<bool>? isUser,
      Value<DateTime>? timestamp,
      Value<String?>? stickerName}) {
    return ChatMessagesCompanion(
      id: id ?? this.id,
      messageText: messageText ?? this.messageText,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      stickerName: stickerName ?? this.stickerName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (messageText.present) {
      map['message_text'] = Variable<String>(messageText.value);
    }
    if (isUser.present) {
      map['is_user'] = Variable<bool>(isUser.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(
          $ChatMessagesTable.$convertertimestamp.toSql(timestamp.value));
    }
    if (stickerName.present) {
      map['sticker_name'] = Variable<String>(stickerName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('messageText: $messageText, ')
          ..write('isUser: $isUser, ')
          ..write('timestamp: $timestamp, ')
          ..write('stickerName: $stickerName')
          ..write(')'))
        .toString();
  }
}

class $UserStatsTable extends UserStats
    with TableInfo<$UserStatsTable, UserStat> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserStatsTable(this.attachedDatabase, [this._alias]);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> weekStartDate =
      GeneratedColumn<int>('week_start_date', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: false)
          .withConverter<DateTime>($UserStatsTable.$converterweekStartDate);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> weekEndDate =
      GeneratedColumn<int>('week_end_date', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<DateTime>($UserStatsTable.$converterweekEndDate);
  static const VerificationMeta _totalSetMeta =
      const VerificationMeta('totalSet');
  @override
  late final GeneratedColumn<int> totalSet = GeneratedColumn<int>(
      'total_set', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _totalCompletedMeta =
      const VerificationMeta('totalCompleted');
  @override
  late final GeneratedColumn<int> totalCompleted = GeneratedColumn<int>(
      'total_completed', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _totalIgnoredMeta =
      const VerificationMeta('totalIgnored');
  @override
  late final GeneratedColumn<int> totalIgnored = GeneratedColumn<int>(
      'total_ignored', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _totalRescheduledMeta =
      const VerificationMeta('totalRescheduled');
  @override
  late final GeneratedColumn<int> totalRescheduled = GeneratedColumn<int>(
      'total_rescheduled', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _currentStreakMeta =
      const VerificationMeta('currentStreak');
  @override
  late final GeneratedColumn<int> currentStreak = GeneratedColumn<int>(
      'current_streak', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _longestStreakMeta =
      const VerificationMeta('longestStreak');
  @override
  late final GeneratedColumn<int> longestStreak = GeneratedColumn<int>(
      'longest_streak', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _personalityTitleMeta =
      const VerificationMeta('personalityTitle');
  @override
  late final GeneratedColumn<String> personalityTitle = GeneratedColumn<String>(
      'personality_title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _procrastinationScoreMeta =
      const VerificationMeta('procrastinationScore');
  @override
  late final GeneratedColumn<double> procrastinationScore =
      GeneratedColumn<double>('procrastination_score', aliasedName, false,
          type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> lastCompletedDate =
      GeneratedColumn<int>('last_completed_date', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              defaultValue: const Constant(0))
          .withConverter<DateTime>($UserStatsTable.$converterlastCompletedDate);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> generatedAt =
      GeneratedColumn<int>('generated_at', aliasedName, false,
              type: DriftSqlType.int, requiredDuringInsert: true)
          .withConverter<DateTime>($UserStatsTable.$convertergeneratedAt);
  @override
  List<GeneratedColumn> get $columns => [
        weekStartDate,
        weekEndDate,
        totalSet,
        totalCompleted,
        totalIgnored,
        totalRescheduled,
        currentStreak,
        longestStreak,
        personalityTitle,
        procrastinationScore,
        lastCompletedDate,
        generatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_stats';
  @override
  VerificationContext validateIntegrity(Insertable<UserStat> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('total_set')) {
      context.handle(_totalSetMeta,
          totalSet.isAcceptableOrUnknown(data['total_set']!, _totalSetMeta));
    } else if (isInserting) {
      context.missing(_totalSetMeta);
    }
    if (data.containsKey('total_completed')) {
      context.handle(
          _totalCompletedMeta,
          totalCompleted.isAcceptableOrUnknown(
              data['total_completed']!, _totalCompletedMeta));
    } else if (isInserting) {
      context.missing(_totalCompletedMeta);
    }
    if (data.containsKey('total_ignored')) {
      context.handle(
          _totalIgnoredMeta,
          totalIgnored.isAcceptableOrUnknown(
              data['total_ignored']!, _totalIgnoredMeta));
    } else if (isInserting) {
      context.missing(_totalIgnoredMeta);
    }
    if (data.containsKey('total_rescheduled')) {
      context.handle(
          _totalRescheduledMeta,
          totalRescheduled.isAcceptableOrUnknown(
              data['total_rescheduled']!, _totalRescheduledMeta));
    } else if (isInserting) {
      context.missing(_totalRescheduledMeta);
    }
    if (data.containsKey('current_streak')) {
      context.handle(
          _currentStreakMeta,
          currentStreak.isAcceptableOrUnknown(
              data['current_streak']!, _currentStreakMeta));
    } else if (isInserting) {
      context.missing(_currentStreakMeta);
    }
    if (data.containsKey('longest_streak')) {
      context.handle(
          _longestStreakMeta,
          longestStreak.isAcceptableOrUnknown(
              data['longest_streak']!, _longestStreakMeta));
    } else if (isInserting) {
      context.missing(_longestStreakMeta);
    }
    if (data.containsKey('personality_title')) {
      context.handle(
          _personalityTitleMeta,
          personalityTitle.isAcceptableOrUnknown(
              data['personality_title']!, _personalityTitleMeta));
    } else if (isInserting) {
      context.missing(_personalityTitleMeta);
    }
    if (data.containsKey('procrastination_score')) {
      context.handle(
          _procrastinationScoreMeta,
          procrastinationScore.isAcceptableOrUnknown(
              data['procrastination_score']!, _procrastinationScoreMeta));
    } else if (isInserting) {
      context.missing(_procrastinationScoreMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {weekStartDate};
  @override
  UserStat map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserStat(
      weekStartDate: $UserStatsTable.$converterweekStartDate.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.int, data['${effectivePrefix}week_start_date'])!),
      weekEndDate: $UserStatsTable.$converterweekEndDate.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.int, data['${effectivePrefix}week_end_date'])!),
      totalSet: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_set'])!,
      totalCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_completed'])!,
      totalIgnored: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_ignored'])!,
      totalRescheduled: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_rescheduled'])!,
      currentStreak: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}current_streak'])!,
      longestStreak: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}longest_streak'])!,
      personalityTitle: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}personality_title'])!,
      procrastinationScore: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}procrastination_score'])!,
      lastCompletedDate: $UserStatsTable.$converterlastCompletedDate.fromSql(
          attachedDatabase.typeMapping.read(DriftSqlType.int,
              data['${effectivePrefix}last_completed_date'])!),
      generatedAt: $UserStatsTable.$convertergeneratedAt.fromSql(
          attachedDatabase.typeMapping
              .read(DriftSqlType.int, data['${effectivePrefix}generated_at'])!),
    );
  }

  @override
  $UserStatsTable createAlias(String alias) {
    return $UserStatsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterweekStartDate =
      const DateTimeConverter();
  static TypeConverter<DateTime, int> $converterweekEndDate =
      const DateTimeConverter();
  static TypeConverter<DateTime, int> $converterlastCompletedDate =
      const DateTimeConverter();
  static TypeConverter<DateTime, int> $convertergeneratedAt =
      const DateTimeConverter();
}

class UserStat extends DataClass implements Insertable<UserStat> {
  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final int totalSet;
  final int totalCompleted;
  final int totalIgnored;
  final int totalRescheduled;
  final int currentStreak;
  final int longestStreak;
  final String personalityTitle;
  final double procrastinationScore;
  final DateTime lastCompletedDate;
  final DateTime generatedAt;
  const UserStat(
      {required this.weekStartDate,
      required this.weekEndDate,
      required this.totalSet,
      required this.totalCompleted,
      required this.totalIgnored,
      required this.totalRescheduled,
      required this.currentStreak,
      required this.longestStreak,
      required this.personalityTitle,
      required this.procrastinationScore,
      required this.lastCompletedDate,
      required this.generatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['week_start_date'] = Variable<int>(
          $UserStatsTable.$converterweekStartDate.toSql(weekStartDate));
    }
    {
      map['week_end_date'] = Variable<int>(
          $UserStatsTable.$converterweekEndDate.toSql(weekEndDate));
    }
    map['total_set'] = Variable<int>(totalSet);
    map['total_completed'] = Variable<int>(totalCompleted);
    map['total_ignored'] = Variable<int>(totalIgnored);
    map['total_rescheduled'] = Variable<int>(totalRescheduled);
    map['current_streak'] = Variable<int>(currentStreak);
    map['longest_streak'] = Variable<int>(longestStreak);
    map['personality_title'] = Variable<String>(personalityTitle);
    map['procrastination_score'] = Variable<double>(procrastinationScore);
    {
      map['last_completed_date'] = Variable<int>(
          $UserStatsTable.$converterlastCompletedDate.toSql(lastCompletedDate));
    }
    {
      map['generated_at'] = Variable<int>(
          $UserStatsTable.$convertergeneratedAt.toSql(generatedAt));
    }
    return map;
  }

  UserStatsCompanion toCompanion(bool nullToAbsent) {
    return UserStatsCompanion(
      weekStartDate: Value(weekStartDate),
      weekEndDate: Value(weekEndDate),
      totalSet: Value(totalSet),
      totalCompleted: Value(totalCompleted),
      totalIgnored: Value(totalIgnored),
      totalRescheduled: Value(totalRescheduled),
      currentStreak: Value(currentStreak),
      longestStreak: Value(longestStreak),
      personalityTitle: Value(personalityTitle),
      procrastinationScore: Value(procrastinationScore),
      lastCompletedDate: Value(lastCompletedDate),
      generatedAt: Value(generatedAt),
    );
  }

  factory UserStat.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserStat(
      weekStartDate: serializer.fromJson<DateTime>(json['weekStartDate']),
      weekEndDate: serializer.fromJson<DateTime>(json['weekEndDate']),
      totalSet: serializer.fromJson<int>(json['totalSet']),
      totalCompleted: serializer.fromJson<int>(json['totalCompleted']),
      totalIgnored: serializer.fromJson<int>(json['totalIgnored']),
      totalRescheduled: serializer.fromJson<int>(json['totalRescheduled']),
      currentStreak: serializer.fromJson<int>(json['currentStreak']),
      longestStreak: serializer.fromJson<int>(json['longestStreak']),
      personalityTitle: serializer.fromJson<String>(json['personalityTitle']),
      procrastinationScore:
          serializer.fromJson<double>(json['procrastinationScore']),
      lastCompletedDate:
          serializer.fromJson<DateTime>(json['lastCompletedDate']),
      generatedAt: serializer.fromJson<DateTime>(json['generatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'weekStartDate': serializer.toJson<DateTime>(weekStartDate),
      'weekEndDate': serializer.toJson<DateTime>(weekEndDate),
      'totalSet': serializer.toJson<int>(totalSet),
      'totalCompleted': serializer.toJson<int>(totalCompleted),
      'totalIgnored': serializer.toJson<int>(totalIgnored),
      'totalRescheduled': serializer.toJson<int>(totalRescheduled),
      'currentStreak': serializer.toJson<int>(currentStreak),
      'longestStreak': serializer.toJson<int>(longestStreak),
      'personalityTitle': serializer.toJson<String>(personalityTitle),
      'procrastinationScore': serializer.toJson<double>(procrastinationScore),
      'lastCompletedDate': serializer.toJson<DateTime>(lastCompletedDate),
      'generatedAt': serializer.toJson<DateTime>(generatedAt),
    };
  }

  UserStat copyWith(
          {DateTime? weekStartDate,
          DateTime? weekEndDate,
          int? totalSet,
          int? totalCompleted,
          int? totalIgnored,
          int? totalRescheduled,
          int? currentStreak,
          int? longestStreak,
          String? personalityTitle,
          double? procrastinationScore,
          DateTime? lastCompletedDate,
          DateTime? generatedAt}) =>
      UserStat(
        weekStartDate: weekStartDate ?? this.weekStartDate,
        weekEndDate: weekEndDate ?? this.weekEndDate,
        totalSet: totalSet ?? this.totalSet,
        totalCompleted: totalCompleted ?? this.totalCompleted,
        totalIgnored: totalIgnored ?? this.totalIgnored,
        totalRescheduled: totalRescheduled ?? this.totalRescheduled,
        currentStreak: currentStreak ?? this.currentStreak,
        longestStreak: longestStreak ?? this.longestStreak,
        personalityTitle: personalityTitle ?? this.personalityTitle,
        procrastinationScore: procrastinationScore ?? this.procrastinationScore,
        lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
        generatedAt: generatedAt ?? this.generatedAt,
      );
  UserStat copyWithCompanion(UserStatsCompanion data) {
    return UserStat(
      weekStartDate: data.weekStartDate.present
          ? data.weekStartDate.value
          : this.weekStartDate,
      weekEndDate:
          data.weekEndDate.present ? data.weekEndDate.value : this.weekEndDate,
      totalSet: data.totalSet.present ? data.totalSet.value : this.totalSet,
      totalCompleted: data.totalCompleted.present
          ? data.totalCompleted.value
          : this.totalCompleted,
      totalIgnored: data.totalIgnored.present
          ? data.totalIgnored.value
          : this.totalIgnored,
      totalRescheduled: data.totalRescheduled.present
          ? data.totalRescheduled.value
          : this.totalRescheduled,
      currentStreak: data.currentStreak.present
          ? data.currentStreak.value
          : this.currentStreak,
      longestStreak: data.longestStreak.present
          ? data.longestStreak.value
          : this.longestStreak,
      personalityTitle: data.personalityTitle.present
          ? data.personalityTitle.value
          : this.personalityTitle,
      procrastinationScore: data.procrastinationScore.present
          ? data.procrastinationScore.value
          : this.procrastinationScore,
      lastCompletedDate: data.lastCompletedDate.present
          ? data.lastCompletedDate.value
          : this.lastCompletedDate,
      generatedAt:
          data.generatedAt.present ? data.generatedAt.value : this.generatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserStat(')
          ..write('weekStartDate: $weekStartDate, ')
          ..write('weekEndDate: $weekEndDate, ')
          ..write('totalSet: $totalSet, ')
          ..write('totalCompleted: $totalCompleted, ')
          ..write('totalIgnored: $totalIgnored, ')
          ..write('totalRescheduled: $totalRescheduled, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('personalityTitle: $personalityTitle, ')
          ..write('procrastinationScore: $procrastinationScore, ')
          ..write('lastCompletedDate: $lastCompletedDate, ')
          ..write('generatedAt: $generatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      weekStartDate,
      weekEndDate,
      totalSet,
      totalCompleted,
      totalIgnored,
      totalRescheduled,
      currentStreak,
      longestStreak,
      personalityTitle,
      procrastinationScore,
      lastCompletedDate,
      generatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserStat &&
          other.weekStartDate == this.weekStartDate &&
          other.weekEndDate == this.weekEndDate &&
          other.totalSet == this.totalSet &&
          other.totalCompleted == this.totalCompleted &&
          other.totalIgnored == this.totalIgnored &&
          other.totalRescheduled == this.totalRescheduled &&
          other.currentStreak == this.currentStreak &&
          other.longestStreak == this.longestStreak &&
          other.personalityTitle == this.personalityTitle &&
          other.procrastinationScore == this.procrastinationScore &&
          other.lastCompletedDate == this.lastCompletedDate &&
          other.generatedAt == this.generatedAt);
}

class UserStatsCompanion extends UpdateCompanion<UserStat> {
  final Value<DateTime> weekStartDate;
  final Value<DateTime> weekEndDate;
  final Value<int> totalSet;
  final Value<int> totalCompleted;
  final Value<int> totalIgnored;
  final Value<int> totalRescheduled;
  final Value<int> currentStreak;
  final Value<int> longestStreak;
  final Value<String> personalityTitle;
  final Value<double> procrastinationScore;
  final Value<DateTime> lastCompletedDate;
  final Value<DateTime> generatedAt;
  const UserStatsCompanion({
    this.weekStartDate = const Value.absent(),
    this.weekEndDate = const Value.absent(),
    this.totalSet = const Value.absent(),
    this.totalCompleted = const Value.absent(),
    this.totalIgnored = const Value.absent(),
    this.totalRescheduled = const Value.absent(),
    this.currentStreak = const Value.absent(),
    this.longestStreak = const Value.absent(),
    this.personalityTitle = const Value.absent(),
    this.procrastinationScore = const Value.absent(),
    this.lastCompletedDate = const Value.absent(),
    this.generatedAt = const Value.absent(),
  });
  UserStatsCompanion.insert({
    this.weekStartDate = const Value.absent(),
    required DateTime weekEndDate,
    required int totalSet,
    required int totalCompleted,
    required int totalIgnored,
    required int totalRescheduled,
    required int currentStreak,
    required int longestStreak,
    required String personalityTitle,
    required double procrastinationScore,
    this.lastCompletedDate = const Value.absent(),
    required DateTime generatedAt,
  })  : weekEndDate = Value(weekEndDate),
        totalSet = Value(totalSet),
        totalCompleted = Value(totalCompleted),
        totalIgnored = Value(totalIgnored),
        totalRescheduled = Value(totalRescheduled),
        currentStreak = Value(currentStreak),
        longestStreak = Value(longestStreak),
        personalityTitle = Value(personalityTitle),
        procrastinationScore = Value(procrastinationScore),
        generatedAt = Value(generatedAt);
  static Insertable<UserStat> custom({
    Expression<int>? weekStartDate,
    Expression<int>? weekEndDate,
    Expression<int>? totalSet,
    Expression<int>? totalCompleted,
    Expression<int>? totalIgnored,
    Expression<int>? totalRescheduled,
    Expression<int>? currentStreak,
    Expression<int>? longestStreak,
    Expression<String>? personalityTitle,
    Expression<double>? procrastinationScore,
    Expression<int>? lastCompletedDate,
    Expression<int>? generatedAt,
  }) {
    return RawValuesInsertable({
      if (weekStartDate != null) 'week_start_date': weekStartDate,
      if (weekEndDate != null) 'week_end_date': weekEndDate,
      if (totalSet != null) 'total_set': totalSet,
      if (totalCompleted != null) 'total_completed': totalCompleted,
      if (totalIgnored != null) 'total_ignored': totalIgnored,
      if (totalRescheduled != null) 'total_rescheduled': totalRescheduled,
      if (currentStreak != null) 'current_streak': currentStreak,
      if (longestStreak != null) 'longest_streak': longestStreak,
      if (personalityTitle != null) 'personality_title': personalityTitle,
      if (procrastinationScore != null)
        'procrastination_score': procrastinationScore,
      if (lastCompletedDate != null) 'last_completed_date': lastCompletedDate,
      if (generatedAt != null) 'generated_at': generatedAt,
    });
  }

  UserStatsCompanion copyWith(
      {Value<DateTime>? weekStartDate,
      Value<DateTime>? weekEndDate,
      Value<int>? totalSet,
      Value<int>? totalCompleted,
      Value<int>? totalIgnored,
      Value<int>? totalRescheduled,
      Value<int>? currentStreak,
      Value<int>? longestStreak,
      Value<String>? personalityTitle,
      Value<double>? procrastinationScore,
      Value<DateTime>? lastCompletedDate,
      Value<DateTime>? generatedAt}) {
    return UserStatsCompanion(
      weekStartDate: weekStartDate ?? this.weekStartDate,
      weekEndDate: weekEndDate ?? this.weekEndDate,
      totalSet: totalSet ?? this.totalSet,
      totalCompleted: totalCompleted ?? this.totalCompleted,
      totalIgnored: totalIgnored ?? this.totalIgnored,
      totalRescheduled: totalRescheduled ?? this.totalRescheduled,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      personalityTitle: personalityTitle ?? this.personalityTitle,
      procrastinationScore: procrastinationScore ?? this.procrastinationScore,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      generatedAt: generatedAt ?? this.generatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (weekStartDate.present) {
      map['week_start_date'] = Variable<int>(
          $UserStatsTable.$converterweekStartDate.toSql(weekStartDate.value));
    }
    if (weekEndDate.present) {
      map['week_end_date'] = Variable<int>(
          $UserStatsTable.$converterweekEndDate.toSql(weekEndDate.value));
    }
    if (totalSet.present) {
      map['total_set'] = Variable<int>(totalSet.value);
    }
    if (totalCompleted.present) {
      map['total_completed'] = Variable<int>(totalCompleted.value);
    }
    if (totalIgnored.present) {
      map['total_ignored'] = Variable<int>(totalIgnored.value);
    }
    if (totalRescheduled.present) {
      map['total_rescheduled'] = Variable<int>(totalRescheduled.value);
    }
    if (currentStreak.present) {
      map['current_streak'] = Variable<int>(currentStreak.value);
    }
    if (longestStreak.present) {
      map['longest_streak'] = Variable<int>(longestStreak.value);
    }
    if (personalityTitle.present) {
      map['personality_title'] = Variable<String>(personalityTitle.value);
    }
    if (procrastinationScore.present) {
      map['procrastination_score'] =
          Variable<double>(procrastinationScore.value);
    }
    if (lastCompletedDate.present) {
      map['last_completed_date'] = Variable<int>($UserStatsTable
          .$converterlastCompletedDate
          .toSql(lastCompletedDate.value));
    }
    if (generatedAt.present) {
      map['generated_at'] = Variable<int>(
          $UserStatsTable.$convertergeneratedAt.toSql(generatedAt.value));
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserStatsCompanion(')
          ..write('weekStartDate: $weekStartDate, ')
          ..write('weekEndDate: $weekEndDate, ')
          ..write('totalSet: $totalSet, ')
          ..write('totalCompleted: $totalCompleted, ')
          ..write('totalIgnored: $totalIgnored, ')
          ..write('totalRescheduled: $totalRescheduled, ')
          ..write('currentStreak: $currentStreak, ')
          ..write('longestStreak: $longestStreak, ')
          ..write('personalityTitle: $personalityTitle, ')
          ..write('procrastinationScore: $procrastinationScore, ')
          ..write('lastCompletedDate: $lastCompletedDate, ')
          ..write('generatedAt: $generatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$RiriDatabase extends GeneratedDatabase {
  _$RiriDatabase(QueryExecutor e) : super(e);
  $RiriDatabaseManager get managers => $RiriDatabaseManager(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $ChatMessagesTable chatMessages = $ChatMessagesTable(this);
  late final $UserStatsTable userStats = $UserStatsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [reminders, chatMessages, userStats];
}

typedef $$RemindersTableCreateCompanionBuilder = RemindersCompanion Function({
  Value<int> id,
  required String title,
  Value<String?> description,
  required ReminderCategory category,
  Value<PersonalityMode> personalityMode,
  required DateTime dueDateTime,
  required DateTime createdAt,
  Value<DateTime?> completedAt,
  Value<bool> isCompleted,
  Value<bool> isRecurring,
  Value<String?> recurringInterval,
  Value<String?> recurringRuleJson,
  Value<int> snoozeCount,
  Value<int> rescheduleCount,
  Value<String?> rawInput,
  Value<String?> taglishNormalized,
  Value<String?> taglishTokensJson,
  Value<double> procrastinationScore,
});
typedef $$RemindersTableUpdateCompanionBuilder = RemindersCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String?> description,
  Value<ReminderCategory> category,
  Value<PersonalityMode> personalityMode,
  Value<DateTime> dueDateTime,
  Value<DateTime> createdAt,
  Value<DateTime?> completedAt,
  Value<bool> isCompleted,
  Value<bool> isRecurring,
  Value<String?> recurringInterval,
  Value<String?> recurringRuleJson,
  Value<int> snoozeCount,
  Value<int> rescheduleCount,
  Value<String?> rawInput,
  Value<String?> taglishNormalized,
  Value<String?> taglishTokensJson,
  Value<double> procrastinationScore,
});

class $$RemindersTableFilterComposer
    extends Composer<_$RiriDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<ReminderCategory, ReminderCategory, String>
      get category => $composableBuilder(
          column: $table.category,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<PersonalityMode, PersonalityMode, String>
      get personalityMode => $composableBuilder(
          column: $table.personalityMode,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get dueDateTime =>
      $composableBuilder(
          column: $table.dueDateTime,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
          column: $table.createdAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get completedAt =>
      $composableBuilder(
          column: $table.completedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recurringInterval => $composableBuilder(
      column: $table.recurringInterval,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recurringRuleJson => $composableBuilder(
      column: $table.recurringRuleJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get snoozeCount => $composableBuilder(
      column: $table.snoozeCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rescheduleCount => $composableBuilder(
      column: $table.rescheduleCount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get rawInput => $composableBuilder(
      column: $table.rawInput, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taglishNormalized => $composableBuilder(
      column: $table.taglishNormalized,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get taglishTokensJson => $composableBuilder(
      column: $table.taglishTokensJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get procrastinationScore => $composableBuilder(
      column: $table.procrastinationScore,
      builder: (column) => ColumnFilters(column));
}

class $$RemindersTableOrderingComposer
    extends Composer<_$RiriDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get personalityMode => $composableBuilder(
      column: $table.personalityMode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dueDateTime => $composableBuilder(
      column: $table.dueDateTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recurringInterval => $composableBuilder(
      column: $table.recurringInterval,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recurringRuleJson => $composableBuilder(
      column: $table.recurringRuleJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get snoozeCount => $composableBuilder(
      column: $table.snoozeCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rescheduleCount => $composableBuilder(
      column: $table.rescheduleCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get rawInput => $composableBuilder(
      column: $table.rawInput, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taglishNormalized => $composableBuilder(
      column: $table.taglishNormalized,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get taglishTokensJson => $composableBuilder(
      column: $table.taglishTokensJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get procrastinationScore => $composableBuilder(
      column: $table.procrastinationScore,
      builder: (column) => ColumnOrderings(column));
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$RiriDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ReminderCategory, String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PersonalityMode, String>
      get personalityMode => $composableBuilder(
          column: $table.personalityMode, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get dueDateTime =>
      $composableBuilder(
          column: $table.dueDateTime, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get completedAt =>
      $composableBuilder(
          column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => column);

  GeneratedColumn<String> get recurringInterval => $composableBuilder(
      column: $table.recurringInterval, builder: (column) => column);

  GeneratedColumn<String> get recurringRuleJson => $composableBuilder(
      column: $table.recurringRuleJson, builder: (column) => column);

  GeneratedColumn<int> get snoozeCount => $composableBuilder(
      column: $table.snoozeCount, builder: (column) => column);

  GeneratedColumn<int> get rescheduleCount => $composableBuilder(
      column: $table.rescheduleCount, builder: (column) => column);

  GeneratedColumn<String> get rawInput =>
      $composableBuilder(column: $table.rawInput, builder: (column) => column);

  GeneratedColumn<String> get taglishNormalized => $composableBuilder(
      column: $table.taglishNormalized, builder: (column) => column);

  GeneratedColumn<String> get taglishTokensJson => $composableBuilder(
      column: $table.taglishTokensJson, builder: (column) => column);

  GeneratedColumn<double> get procrastinationScore => $composableBuilder(
      column: $table.procrastinationScore, builder: (column) => column);
}

class $$RemindersTableTableManager extends RootTableManager<
    _$RiriDatabase,
    $RemindersTable,
    Reminder,
    $$RemindersTableFilterComposer,
    $$RemindersTableOrderingComposer,
    $$RemindersTableAnnotationComposer,
    $$RemindersTableCreateCompanionBuilder,
    $$RemindersTableUpdateCompanionBuilder,
    (Reminder, BaseReferences<_$RiriDatabase, $RemindersTable, Reminder>),
    Reminder,
    PrefetchHooks Function()> {
  $$RemindersTableTableManager(_$RiriDatabase db, $RemindersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<ReminderCategory> category = const Value.absent(),
            Value<PersonalityMode> personalityMode = const Value.absent(),
            Value<DateTime> dueDateTime = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime?> completedAt = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<bool> isRecurring = const Value.absent(),
            Value<String?> recurringInterval = const Value.absent(),
            Value<String?> recurringRuleJson = const Value.absent(),
            Value<int> snoozeCount = const Value.absent(),
            Value<int> rescheduleCount = const Value.absent(),
            Value<String?> rawInput = const Value.absent(),
            Value<String?> taglishNormalized = const Value.absent(),
            Value<String?> taglishTokensJson = const Value.absent(),
            Value<double> procrastinationScore = const Value.absent(),
          }) =>
              RemindersCompanion(
            id: id,
            title: title,
            description: description,
            category: category,
            personalityMode: personalityMode,
            dueDateTime: dueDateTime,
            createdAt: createdAt,
            completedAt: completedAt,
            isCompleted: isCompleted,
            isRecurring: isRecurring,
            recurringInterval: recurringInterval,
            recurringRuleJson: recurringRuleJson,
            snoozeCount: snoozeCount,
            rescheduleCount: rescheduleCount,
            rawInput: rawInput,
            taglishNormalized: taglishNormalized,
            taglishTokensJson: taglishTokensJson,
            procrastinationScore: procrastinationScore,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String title,
            Value<String?> description = const Value.absent(),
            required ReminderCategory category,
            Value<PersonalityMode> personalityMode = const Value.absent(),
            required DateTime dueDateTime,
            required DateTime createdAt,
            Value<DateTime?> completedAt = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<bool> isRecurring = const Value.absent(),
            Value<String?> recurringInterval = const Value.absent(),
            Value<String?> recurringRuleJson = const Value.absent(),
            Value<int> snoozeCount = const Value.absent(),
            Value<int> rescheduleCount = const Value.absent(),
            Value<String?> rawInput = const Value.absent(),
            Value<String?> taglishNormalized = const Value.absent(),
            Value<String?> taglishTokensJson = const Value.absent(),
            Value<double> procrastinationScore = const Value.absent(),
          }) =>
              RemindersCompanion.insert(
            id: id,
            title: title,
            description: description,
            category: category,
            personalityMode: personalityMode,
            dueDateTime: dueDateTime,
            createdAt: createdAt,
            completedAt: completedAt,
            isCompleted: isCompleted,
            isRecurring: isRecurring,
            recurringInterval: recurringInterval,
            recurringRuleJson: recurringRuleJson,
            snoozeCount: snoozeCount,
            rescheduleCount: rescheduleCount,
            rawInput: rawInput,
            taglishNormalized: taglishNormalized,
            taglishTokensJson: taglishTokensJson,
            procrastinationScore: procrastinationScore,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$RemindersTableProcessedTableManager = ProcessedTableManager<
    _$RiriDatabase,
    $RemindersTable,
    Reminder,
    $$RemindersTableFilterComposer,
    $$RemindersTableOrderingComposer,
    $$RemindersTableAnnotationComposer,
    $$RemindersTableCreateCompanionBuilder,
    $$RemindersTableUpdateCompanionBuilder,
    (Reminder, BaseReferences<_$RiriDatabase, $RemindersTable, Reminder>),
    Reminder,
    PrefetchHooks Function()>;
typedef $$ChatMessagesTableCreateCompanionBuilder = ChatMessagesCompanion
    Function({
  Value<int> id,
  required String messageText,
  required bool isUser,
  required DateTime timestamp,
  Value<String?> stickerName,
});
typedef $$ChatMessagesTableUpdateCompanionBuilder = ChatMessagesCompanion
    Function({
  Value<int> id,
  Value<String> messageText,
  Value<bool> isUser,
  Value<DateTime> timestamp,
  Value<String?> stickerName,
});

class $$ChatMessagesTableFilterComposer
    extends Composer<_$RiriDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get messageText => $composableBuilder(
      column: $table.messageText, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isUser => $composableBuilder(
      column: $table.isUser, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get timestamp =>
      $composableBuilder(
          column: $table.timestamp,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get stickerName => $composableBuilder(
      column: $table.stickerName, builder: (column) => ColumnFilters(column));
}

class $$ChatMessagesTableOrderingComposer
    extends Composer<_$RiriDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get messageText => $composableBuilder(
      column: $table.messageText, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isUser => $composableBuilder(
      column: $table.isUser, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stickerName => $composableBuilder(
      column: $table.stickerName, builder: (column) => ColumnOrderings(column));
}

class $$ChatMessagesTableAnnotationComposer
    extends Composer<_$RiriDatabase, $ChatMessagesTable> {
  $$ChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get messageText => $composableBuilder(
      column: $table.messageText, builder: (column) => column);

  GeneratedColumn<bool> get isUser =>
      $composableBuilder(column: $table.isUser, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get stickerName => $composableBuilder(
      column: $table.stickerName, builder: (column) => column);
}

class $$ChatMessagesTableTableManager extends RootTableManager<
    _$RiriDatabase,
    $ChatMessagesTable,
    ChatMessage,
    $$ChatMessagesTableFilterComposer,
    $$ChatMessagesTableOrderingComposer,
    $$ChatMessagesTableAnnotationComposer,
    $$ChatMessagesTableCreateCompanionBuilder,
    $$ChatMessagesTableUpdateCompanionBuilder,
    (
      ChatMessage,
      BaseReferences<_$RiriDatabase, $ChatMessagesTable, ChatMessage>
    ),
    ChatMessage,
    PrefetchHooks Function()> {
  $$ChatMessagesTableTableManager(_$RiriDatabase db, $ChatMessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChatMessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChatMessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> messageText = const Value.absent(),
            Value<bool> isUser = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<String?> stickerName = const Value.absent(),
          }) =>
              ChatMessagesCompanion(
            id: id,
            messageText: messageText,
            isUser: isUser,
            timestamp: timestamp,
            stickerName: stickerName,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String messageText,
            required bool isUser,
            required DateTime timestamp,
            Value<String?> stickerName = const Value.absent(),
          }) =>
              ChatMessagesCompanion.insert(
            id: id,
            messageText: messageText,
            isUser: isUser,
            timestamp: timestamp,
            stickerName: stickerName,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChatMessagesTableProcessedTableManager = ProcessedTableManager<
    _$RiriDatabase,
    $ChatMessagesTable,
    ChatMessage,
    $$ChatMessagesTableFilterComposer,
    $$ChatMessagesTableOrderingComposer,
    $$ChatMessagesTableAnnotationComposer,
    $$ChatMessagesTableCreateCompanionBuilder,
    $$ChatMessagesTableUpdateCompanionBuilder,
    (
      ChatMessage,
      BaseReferences<_$RiriDatabase, $ChatMessagesTable, ChatMessage>
    ),
    ChatMessage,
    PrefetchHooks Function()>;
typedef $$UserStatsTableCreateCompanionBuilder = UserStatsCompanion Function({
  Value<DateTime> weekStartDate,
  required DateTime weekEndDate,
  required int totalSet,
  required int totalCompleted,
  required int totalIgnored,
  required int totalRescheduled,
  required int currentStreak,
  required int longestStreak,
  required String personalityTitle,
  required double procrastinationScore,
  Value<DateTime> lastCompletedDate,
  required DateTime generatedAt,
});
typedef $$UserStatsTableUpdateCompanionBuilder = UserStatsCompanion Function({
  Value<DateTime> weekStartDate,
  Value<DateTime> weekEndDate,
  Value<int> totalSet,
  Value<int> totalCompleted,
  Value<int> totalIgnored,
  Value<int> totalRescheduled,
  Value<int> currentStreak,
  Value<int> longestStreak,
  Value<String> personalityTitle,
  Value<double> procrastinationScore,
  Value<DateTime> lastCompletedDate,
  Value<DateTime> generatedAt,
});

class $$UserStatsTableFilterComposer
    extends Composer<_$RiriDatabase, $UserStatsTable> {
  $$UserStatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get weekStartDate =>
      $composableBuilder(
          column: $table.weekStartDate,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get weekEndDate =>
      $composableBuilder(
          column: $table.weekEndDate,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<int> get totalSet => $composableBuilder(
      column: $table.totalSet, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalCompleted => $composableBuilder(
      column: $table.totalCompleted,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalIgnored => $composableBuilder(
      column: $table.totalIgnored, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get totalRescheduled => $composableBuilder(
      column: $table.totalRescheduled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get currentStreak => $composableBuilder(
      column: $table.currentStreak, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get longestStreak => $composableBuilder(
      column: $table.longestStreak, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get personalityTitle => $composableBuilder(
      column: $table.personalityTitle,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get procrastinationScore => $composableBuilder(
      column: $table.procrastinationScore,
      builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, int>
      get lastCompletedDate => $composableBuilder(
          column: $table.lastCompletedDate,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get generatedAt =>
      $composableBuilder(
          column: $table.generatedAt,
          builder: (column) => ColumnWithTypeConverterFilters(column));
}

class $$UserStatsTableOrderingComposer
    extends Composer<_$RiriDatabase, $UserStatsTable> {
  $$UserStatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get weekStartDate => $composableBuilder(
      column: $table.weekStartDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get weekEndDate => $composableBuilder(
      column: $table.weekEndDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalSet => $composableBuilder(
      column: $table.totalSet, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalCompleted => $composableBuilder(
      column: $table.totalCompleted,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalIgnored => $composableBuilder(
      column: $table.totalIgnored,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get totalRescheduled => $composableBuilder(
      column: $table.totalRescheduled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get currentStreak => $composableBuilder(
      column: $table.currentStreak,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get longestStreak => $composableBuilder(
      column: $table.longestStreak,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get personalityTitle => $composableBuilder(
      column: $table.personalityTitle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get procrastinationScore => $composableBuilder(
      column: $table.procrastinationScore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastCompletedDate => $composableBuilder(
      column: $table.lastCompletedDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get generatedAt => $composableBuilder(
      column: $table.generatedAt, builder: (column) => ColumnOrderings(column));
}

class $$UserStatsTableAnnotationComposer
    extends Composer<_$RiriDatabase, $UserStatsTable> {
  $$UserStatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<DateTime, int> get weekStartDate =>
      $composableBuilder(
          column: $table.weekStartDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get weekEndDate =>
      $composableBuilder(
          column: $table.weekEndDate, builder: (column) => column);

  GeneratedColumn<int> get totalSet =>
      $composableBuilder(column: $table.totalSet, builder: (column) => column);

  GeneratedColumn<int> get totalCompleted => $composableBuilder(
      column: $table.totalCompleted, builder: (column) => column);

  GeneratedColumn<int> get totalIgnored => $composableBuilder(
      column: $table.totalIgnored, builder: (column) => column);

  GeneratedColumn<int> get totalRescheduled => $composableBuilder(
      column: $table.totalRescheduled, builder: (column) => column);

  GeneratedColumn<int> get currentStreak => $composableBuilder(
      column: $table.currentStreak, builder: (column) => column);

  GeneratedColumn<int> get longestStreak => $composableBuilder(
      column: $table.longestStreak, builder: (column) => column);

  GeneratedColumn<String> get personalityTitle => $composableBuilder(
      column: $table.personalityTitle, builder: (column) => column);

  GeneratedColumn<double> get procrastinationScore => $composableBuilder(
      column: $table.procrastinationScore, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get lastCompletedDate =>
      $composableBuilder(
          column: $table.lastCompletedDate, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get generatedAt =>
      $composableBuilder(
          column: $table.generatedAt, builder: (column) => column);
}

class $$UserStatsTableTableManager extends RootTableManager<
    _$RiriDatabase,
    $UserStatsTable,
    UserStat,
    $$UserStatsTableFilterComposer,
    $$UserStatsTableOrderingComposer,
    $$UserStatsTableAnnotationComposer,
    $$UserStatsTableCreateCompanionBuilder,
    $$UserStatsTableUpdateCompanionBuilder,
    (UserStat, BaseReferences<_$RiriDatabase, $UserStatsTable, UserStat>),
    UserStat,
    PrefetchHooks Function()> {
  $$UserStatsTableTableManager(_$RiriDatabase db, $UserStatsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserStatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserStatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserStatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<DateTime> weekStartDate = const Value.absent(),
            Value<DateTime> weekEndDate = const Value.absent(),
            Value<int> totalSet = const Value.absent(),
            Value<int> totalCompleted = const Value.absent(),
            Value<int> totalIgnored = const Value.absent(),
            Value<int> totalRescheduled = const Value.absent(),
            Value<int> currentStreak = const Value.absent(),
            Value<int> longestStreak = const Value.absent(),
            Value<String> personalityTitle = const Value.absent(),
            Value<double> procrastinationScore = const Value.absent(),
            Value<DateTime> lastCompletedDate = const Value.absent(),
            Value<DateTime> generatedAt = const Value.absent(),
          }) =>
              UserStatsCompanion(
            weekStartDate: weekStartDate,
            weekEndDate: weekEndDate,
            totalSet: totalSet,
            totalCompleted: totalCompleted,
            totalIgnored: totalIgnored,
            totalRescheduled: totalRescheduled,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            personalityTitle: personalityTitle,
            procrastinationScore: procrastinationScore,
            lastCompletedDate: lastCompletedDate,
            generatedAt: generatedAt,
          ),
          createCompanionCallback: ({
            Value<DateTime> weekStartDate = const Value.absent(),
            required DateTime weekEndDate,
            required int totalSet,
            required int totalCompleted,
            required int totalIgnored,
            required int totalRescheduled,
            required int currentStreak,
            required int longestStreak,
            required String personalityTitle,
            required double procrastinationScore,
            Value<DateTime> lastCompletedDate = const Value.absent(),
            required DateTime generatedAt,
          }) =>
              UserStatsCompanion.insert(
            weekStartDate: weekStartDate,
            weekEndDate: weekEndDate,
            totalSet: totalSet,
            totalCompleted: totalCompleted,
            totalIgnored: totalIgnored,
            totalRescheduled: totalRescheduled,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            personalityTitle: personalityTitle,
            procrastinationScore: procrastinationScore,
            lastCompletedDate: lastCompletedDate,
            generatedAt: generatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserStatsTableProcessedTableManager = ProcessedTableManager<
    _$RiriDatabase,
    $UserStatsTable,
    UserStat,
    $$UserStatsTableFilterComposer,
    $$UserStatsTableOrderingComposer,
    $$UserStatsTableAnnotationComposer,
    $$UserStatsTableCreateCompanionBuilder,
    $$UserStatsTableUpdateCompanionBuilder,
    (UserStat, BaseReferences<_$RiriDatabase, $UserStatsTable, UserStat>),
    UserStat,
    PrefetchHooks Function()>;

class $RiriDatabaseManager {
  final _$RiriDatabase _db;
  $RiriDatabaseManager(this._db);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$ChatMessagesTableTableManager get chatMessages =>
      $$ChatMessagesTableTableManager(_db, _db.chatMessages);
  $$UserStatsTableTableManager get userStats =>
      $$UserStatsTableTableManager(_db, _db.userStats);
}
