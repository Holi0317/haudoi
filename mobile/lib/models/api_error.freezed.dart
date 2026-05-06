// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_error.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ApiErrorModel {

 String get code; String get message; Map<String, dynamic>? get details;
/// Create a copy of ApiErrorModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiErrorModelCopyWith<ApiErrorModel> get copyWith => _$ApiErrorModelCopyWithImpl<ApiErrorModel>(this as ApiErrorModel, _$identity);

  /// Serializes this ApiErrorModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiErrorModel&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.details, details));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,message,const DeepCollectionEquality().hash(details));

@override
String toString() {
  return 'ApiErrorModel(code: $code, message: $message, details: $details)';
}


}

/// @nodoc
abstract mixin class $ApiErrorModelCopyWith<$Res>  {
  factory $ApiErrorModelCopyWith(ApiErrorModel value, $Res Function(ApiErrorModel) _then) = _$ApiErrorModelCopyWithImpl;
@useResult
$Res call({
 String code, String message, Map<String, dynamic>? details
});




}
/// @nodoc
class _$ApiErrorModelCopyWithImpl<$Res>
    implements $ApiErrorModelCopyWith<$Res> {
  _$ApiErrorModelCopyWithImpl(this._self, this._then);

  final ApiErrorModel _self;
  final $Res Function(ApiErrorModel) _then;

/// Create a copy of ApiErrorModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? message = null,Object? details = freezed,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiErrorModel].
extension ApiErrorModelPatterns on ApiErrorModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiErrorModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiErrorModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiErrorModel value)  $default,){
final _that = this;
switch (_that) {
case _ApiErrorModel():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiErrorModel value)?  $default,){
final _that = this;
switch (_that) {
case _ApiErrorModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String message,  Map<String, dynamic>? details)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiErrorModel() when $default != null:
return $default(_that.code,_that.message,_that.details);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String message,  Map<String, dynamic>? details)  $default,) {final _that = this;
switch (_that) {
case _ApiErrorModel():
return $default(_that.code,_that.message,_that.details);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String message,  Map<String, dynamic>? details)?  $default,) {final _that = this;
switch (_that) {
case _ApiErrorModel() when $default != null:
return $default(_that.code,_that.message,_that.details);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ApiErrorModel implements ApiErrorModel {
  const _ApiErrorModel({required this.code, required this.message, final  Map<String, dynamic>? details}): _details = details;
  factory _ApiErrorModel.fromJson(Map<String, dynamic> json) => _$ApiErrorModelFromJson(json);

@override final  String code;
@override final  String message;
 final  Map<String, dynamic>? _details;
@override Map<String, dynamic>? get details {
  final value = _details;
  if (value == null) return null;
  if (_details is EqualUnmodifiableMapView) return _details;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of ApiErrorModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiErrorModelCopyWith<_ApiErrorModel> get copyWith => __$ApiErrorModelCopyWithImpl<_ApiErrorModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApiErrorModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiErrorModel&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other._details, _details));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,message,const DeepCollectionEquality().hash(_details));

@override
String toString() {
  return 'ApiErrorModel(code: $code, message: $message, details: $details)';
}


}

/// @nodoc
abstract mixin class _$ApiErrorModelCopyWith<$Res> implements $ApiErrorModelCopyWith<$Res> {
  factory _$ApiErrorModelCopyWith(_ApiErrorModel value, $Res Function(_ApiErrorModel) _then) = __$ApiErrorModelCopyWithImpl;
@override @useResult
$Res call({
 String code, String message, Map<String, dynamic>? details
});




}
/// @nodoc
class __$ApiErrorModelCopyWithImpl<$Res>
    implements _$ApiErrorModelCopyWith<$Res> {
  __$ApiErrorModelCopyWithImpl(this._self, this._then);

  final _ApiErrorModel _self;
  final $Res Function(_ApiErrorModel) _then;

/// Create a copy of ApiErrorModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? message = null,Object? details = freezed,}) {
  return _then(_ApiErrorModel(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,details: freezed == details ? _self._details : details // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
