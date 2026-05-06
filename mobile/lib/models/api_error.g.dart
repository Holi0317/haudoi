// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_error.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ApiErrorModel _$ApiErrorModelFromJson(Map<String, dynamic> json) =>
    _ApiErrorModel(
      code: json['code'] as String,
      message: json['message'] as String,
      details: json['details'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$ApiErrorModelToJson(_ApiErrorModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'details': instance.details,
    };
