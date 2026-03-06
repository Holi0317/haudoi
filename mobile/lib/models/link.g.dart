// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Link _$LinkFromJson(Map<String, dynamic> json) => _Link(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  url: json['url'] as String,
  favorite: json['favorite'] as bool,
  archive: json['archive'] as bool,
  tags: (json['tags'] as List<dynamic>)
      .map((e) => Tag.fromJson(e as Map<String, dynamic>))
      .toList(),
  createdAt: (json['created_at'] as num).toInt(),
  note: json['note'] as String,
);

Map<String, dynamic> _$LinkToJson(_Link instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'url': instance.url,
  'favorite': instance.favorite,
  'archive': instance.archive,
  'tags': instance.tags,
  'created_at': instance.createdAt,
  'note': instance.note,
};
