// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_op.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditOpInsert _$EditOpInsertFromJson(Map<String, dynamic> json) => EditOpInsert(
  title: json['title'] as String?,
  url: json['url'] as String,
  archive: json['archive'] as bool?,
  favorite: json['favorite'] as bool?,
  note: json['note'] as String?,
  createdAt: (json['created_at'] as num?)?.toInt(),
  appliedAt: json['appliedAt'] == null
      ? null
      : DateTime.parse(json['appliedAt'] as String),
  $type: json['op'] as String?,
);

Map<String, dynamic> _$EditOpInsertToJson(EditOpInsert instance) =>
    <String, dynamic>{
      'title': instance.title,
      'url': instance.url,
      'archive': ?instance.archive,
      'favorite': ?instance.favorite,
      'note': ?instance.note,
      'created_at': ?instance.createdAt,
      'appliedAt': ?instance.appliedAt?.toIso8601String(),
      'op': instance.$type,
    };

EditOpSetBool _$EditOpSetBoolFromJson(Map<String, dynamic> json) =>
    EditOpSetBool(
      id: (json['id'] as num).toInt(),
      field: $enumDecode(_$EditOpBoolFieldEnumMap, json['field']),
      value: json['value'] as bool,
      appliedAt: json['appliedAt'] == null
          ? null
          : DateTime.parse(json['appliedAt'] as String),
      $type: json['op'] as String?,
    );

Map<String, dynamic> _$EditOpSetBoolToJson(EditOpSetBool instance) =>
    <String, dynamic>{
      'id': instance.id,
      'field': _$EditOpBoolFieldEnumMap[instance.field]!,
      'value': instance.value,
      'appliedAt': ?instance.appliedAt?.toIso8601String(),
      'op': instance.$type,
    };

const _$EditOpBoolFieldEnumMap = {
  EditOpBoolField.archive: 'archive',
  EditOpBoolField.favorite: 'favorite',
};

EditOpSetString _$EditOpSetStringFromJson(Map<String, dynamic> json) =>
    EditOpSetString(
      id: (json['id'] as num).toInt(),
      field: $enumDecode(_$EditOpStringFieldEnumMap, json['field']),
      value: json['value'] as String,
      appliedAt: json['appliedAt'] == null
          ? null
          : DateTime.parse(json['appliedAt'] as String),
      $type: json['op'] as String?,
    );

Map<String, dynamic> _$EditOpSetStringToJson(EditOpSetString instance) =>
    <String, dynamic>{
      'id': instance.id,
      'field': _$EditOpStringFieldEnumMap[instance.field]!,
      'value': instance.value,
      'appliedAt': ?instance.appliedAt?.toIso8601String(),
      'op': instance.$type,
    };

const _$EditOpStringFieldEnumMap = {EditOpStringField.note: 'note'};

EditOpDelete _$EditOpDeleteFromJson(Map<String, dynamic> json) => EditOpDelete(
  id: (json['id'] as num).toInt(),
  appliedAt: json['appliedAt'] == null
      ? null
      : DateTime.parse(json['appliedAt'] as String),
  $type: json['op'] as String?,
);

Map<String, dynamic> _$EditOpDeleteToJson(EditOpDelete instance) =>
    <String, dynamic>{
      'id': instance.id,
      'appliedAt': ?instance.appliedAt?.toIso8601String(),
      'op': instance.$type,
    };
