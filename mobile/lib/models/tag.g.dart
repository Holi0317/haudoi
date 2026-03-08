// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tag.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Tag _$TagFromJson(Map<String, dynamic> json) => _Tag(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  color: json['color'] as String,
  emoji: json['emoji'] as String,
  createdAt: (json['created_at'] as num).toInt(),
);

Map<String, dynamic> _$TagToJson(_Tag instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'color': instance.color,
  'emoji': instance.emoji,
  'created_at': instance.createdAt,
};

_TagListResponse _$TagListResponseFromJson(Map<String, dynamic> json) =>
    _TagListResponse(
      items: (json['items'] as List<dynamic>)
          .map((e) => Tag.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TagListResponseToJson(_TagListResponse instance) =>
    <String, dynamic>{'items': instance.items};

_TagCreateBody _$TagCreateBodyFromJson(Map<String, dynamic> json) =>
    _TagCreateBody(
      name: json['name'] as String,
      color: json['color'] as String,
      emoji: json['emoji'] as String?,
    );

Map<String, dynamic> _$TagCreateBodyToJson(_TagCreateBody instance) =>
    <String, dynamic>{
      'name': instance.name,
      'color': instance.color,
      'emoji': instance.emoji,
    };

_TagUpdateBody _$TagUpdateBodyFromJson(Map<String, dynamic> json) =>
    _TagUpdateBody(
      name: json['name'] as String?,
      color: json['color'] as String?,
      emoji: json['emoji'] as String?,
    );

Map<String, dynamic> _$TagUpdateBodyToJson(_TagUpdateBody instance) =>
    <String, dynamic>{
      'name': instance.name,
      'color': instance.color,
      'emoji': instance.emoji,
    };
