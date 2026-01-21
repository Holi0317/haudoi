// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'edit_op.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
EditOp _$EditOpFromJson(
  Map<String, dynamic> json
) {
        switch (json['op']) {
                  case 'insert':
          return EditOpInsert.fromJson(
            json
          );
                case 'set_bool':
          return EditOpSetBool.fromJson(
            json
          );
                case 'set_string':
          return EditOpSetString.fromJson(
            json
          );
                case 'delete':
          return EditOpDelete.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'op',
  'EditOp',
  'Invalid union type "${json['op']}"!'
);
        }
      
}

/// @nodoc
mixin _$EditOp {

@JsonKey(includeIfNull: false) DateTime? get appliedAt;
/// Create a copy of EditOp
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditOpCopyWith<EditOp> get copyWith => _$EditOpCopyWithImpl<EditOp>(this as EditOp, _$identity);

  /// Serializes this EditOp to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditOp&&(identical(other.appliedAt, appliedAt) || other.appliedAt == appliedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,appliedAt);

@override
String toString() {
  return 'EditOp(appliedAt: $appliedAt)';
}


}

/// @nodoc
abstract mixin class $EditOpCopyWith<$Res>  {
  factory $EditOpCopyWith(EditOp value, $Res Function(EditOp) _then) = _$EditOpCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeIfNull: false) DateTime? appliedAt
});




}
/// @nodoc
class _$EditOpCopyWithImpl<$Res>
    implements $EditOpCopyWith<$Res> {
  _$EditOpCopyWithImpl(this._self, this._then);

  final EditOp _self;
  final $Res Function(EditOp) _then;

/// Create a copy of EditOp
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? appliedAt = freezed,}) {
  return _then(_self.copyWith(
appliedAt: freezed == appliedAt ? _self.appliedAt : appliedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [EditOp].
extension EditOpPatterns on EditOp {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( EditOpInsert value)?  insert,TResult Function( EditOpSetBool value)?  setBool,TResult Function( EditOpSetString value)?  setString,TResult Function( EditOpDelete value)?  delete,required TResult orElse(),}){
final _that = this;
switch (_that) {
case EditOpInsert() when insert != null:
return insert(_that);case EditOpSetBool() when setBool != null:
return setBool(_that);case EditOpSetString() when setString != null:
return setString(_that);case EditOpDelete() when delete != null:
return delete(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( EditOpInsert value)  insert,required TResult Function( EditOpSetBool value)  setBool,required TResult Function( EditOpSetString value)  setString,required TResult Function( EditOpDelete value)  delete,}){
final _that = this;
switch (_that) {
case EditOpInsert():
return insert(_that);case EditOpSetBool():
return setBool(_that);case EditOpSetString():
return setString(_that);case EditOpDelete():
return delete(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( EditOpInsert value)?  insert,TResult? Function( EditOpSetBool value)?  setBool,TResult? Function( EditOpSetString value)?  setString,TResult? Function( EditOpDelete value)?  delete,}){
final _that = this;
switch (_that) {
case EditOpInsert() when insert != null:
return insert(_that);case EditOpSetBool() when setBool != null:
return setBool(_that);case EditOpSetString() when setString != null:
return setString(_that);case EditOpDelete() when delete != null:
return delete(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String? title,  String url, @JsonKey(includeIfNull: false)  bool? archive, @JsonKey(includeIfNull: false)  bool? favorite, @JsonKey(includeIfNull: false)  String? note, @JsonKey(name: 'created_at', includeIfNull: false)  int? createdAt, @JsonKey(includeIfNull: false)  DateTime? appliedAt)?  insert,TResult Function( int id,  EditOpBoolField field,  bool value, @JsonKey(includeIfNull: false)  DateTime? appliedAt)?  setBool,TResult Function( int id,  EditOpStringField field,  String value, @JsonKey(includeIfNull: false)  DateTime? appliedAt)?  setString,TResult Function( int id, @JsonKey(includeIfNull: false)  DateTime? appliedAt)?  delete,required TResult orElse(),}) {final _that = this;
switch (_that) {
case EditOpInsert() when insert != null:
return insert(_that.title,_that.url,_that.archive,_that.favorite,_that.note,_that.createdAt,_that.appliedAt);case EditOpSetBool() when setBool != null:
return setBool(_that.id,_that.field,_that.value,_that.appliedAt);case EditOpSetString() when setString != null:
return setString(_that.id,_that.field,_that.value,_that.appliedAt);case EditOpDelete() when delete != null:
return delete(_that.id,_that.appliedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String? title,  String url, @JsonKey(includeIfNull: false)  bool? archive, @JsonKey(includeIfNull: false)  bool? favorite, @JsonKey(includeIfNull: false)  String? note, @JsonKey(name: 'created_at', includeIfNull: false)  int? createdAt, @JsonKey(includeIfNull: false)  DateTime? appliedAt)  insert,required TResult Function( int id,  EditOpBoolField field,  bool value, @JsonKey(includeIfNull: false)  DateTime? appliedAt)  setBool,required TResult Function( int id,  EditOpStringField field,  String value, @JsonKey(includeIfNull: false)  DateTime? appliedAt)  setString,required TResult Function( int id, @JsonKey(includeIfNull: false)  DateTime? appliedAt)  delete,}) {final _that = this;
switch (_that) {
case EditOpInsert():
return insert(_that.title,_that.url,_that.archive,_that.favorite,_that.note,_that.createdAt,_that.appliedAt);case EditOpSetBool():
return setBool(_that.id,_that.field,_that.value,_that.appliedAt);case EditOpSetString():
return setString(_that.id,_that.field,_that.value,_that.appliedAt);case EditOpDelete():
return delete(_that.id,_that.appliedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String? title,  String url, @JsonKey(includeIfNull: false)  bool? archive, @JsonKey(includeIfNull: false)  bool? favorite, @JsonKey(includeIfNull: false)  String? note, @JsonKey(name: 'created_at', includeIfNull: false)  int? createdAt, @JsonKey(includeIfNull: false)  DateTime? appliedAt)?  insert,TResult? Function( int id,  EditOpBoolField field,  bool value, @JsonKey(includeIfNull: false)  DateTime? appliedAt)?  setBool,TResult? Function( int id,  EditOpStringField field,  String value, @JsonKey(includeIfNull: false)  DateTime? appliedAt)?  setString,TResult? Function( int id, @JsonKey(includeIfNull: false)  DateTime? appliedAt)?  delete,}) {final _that = this;
switch (_that) {
case EditOpInsert() when insert != null:
return insert(_that.title,_that.url,_that.archive,_that.favorite,_that.note,_that.createdAt,_that.appliedAt);case EditOpSetBool() when setBool != null:
return setBool(_that.id,_that.field,_that.value,_that.appliedAt);case EditOpSetString() when setString != null:
return setString(_that.id,_that.field,_that.value,_that.appliedAt);case EditOpDelete() when delete != null:
return delete(_that.id,_that.appliedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class EditOpInsert extends EditOp {
  const EditOpInsert({this.title, required this.url, @JsonKey(includeIfNull: false) this.archive, @JsonKey(includeIfNull: false) this.favorite, @JsonKey(includeIfNull: false) this.note, @JsonKey(name: 'created_at', includeIfNull: false) this.createdAt, @JsonKey(includeIfNull: false) this.appliedAt, final  String? $type}): $type = $type ?? 'insert',super._();
  factory EditOpInsert.fromJson(Map<String, dynamic> json) => _$EditOpInsertFromJson(json);

 final  String? title;
 final  String url;
@JsonKey(includeIfNull: false) final  bool? archive;
@JsonKey(includeIfNull: false) final  bool? favorite;
@JsonKey(includeIfNull: false) final  String? note;
@JsonKey(name: 'created_at', includeIfNull: false) final  int? createdAt;
@override@JsonKey(includeIfNull: false) final  DateTime? appliedAt;

@JsonKey(name: 'op')
final String $type;


/// Create a copy of EditOp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditOpInsertCopyWith<EditOpInsert> get copyWith => _$EditOpInsertCopyWithImpl<EditOpInsert>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EditOpInsertToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditOpInsert&&(identical(other.title, title) || other.title == title)&&(identical(other.url, url) || other.url == url)&&(identical(other.archive, archive) || other.archive == archive)&&(identical(other.favorite, favorite) || other.favorite == favorite)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.appliedAt, appliedAt) || other.appliedAt == appliedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,url,archive,favorite,note,createdAt,appliedAt);

@override
String toString() {
  return 'EditOp.insert(title: $title, url: $url, archive: $archive, favorite: $favorite, note: $note, createdAt: $createdAt, appliedAt: $appliedAt)';
}


}

/// @nodoc
abstract mixin class $EditOpInsertCopyWith<$Res> implements $EditOpCopyWith<$Res> {
  factory $EditOpInsertCopyWith(EditOpInsert value, $Res Function(EditOpInsert) _then) = _$EditOpInsertCopyWithImpl;
@override @useResult
$Res call({
 String? title, String url,@JsonKey(includeIfNull: false) bool? archive,@JsonKey(includeIfNull: false) bool? favorite,@JsonKey(includeIfNull: false) String? note,@JsonKey(name: 'created_at', includeIfNull: false) int? createdAt,@JsonKey(includeIfNull: false) DateTime? appliedAt
});




}
/// @nodoc
class _$EditOpInsertCopyWithImpl<$Res>
    implements $EditOpInsertCopyWith<$Res> {
  _$EditOpInsertCopyWithImpl(this._self, this._then);

  final EditOpInsert _self;
  final $Res Function(EditOpInsert) _then;

/// Create a copy of EditOp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = freezed,Object? url = null,Object? archive = freezed,Object? favorite = freezed,Object? note = freezed,Object? createdAt = freezed,Object? appliedAt = freezed,}) {
  return _then(EditOpInsert(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,archive: freezed == archive ? _self.archive : archive // ignore: cast_nullable_to_non_nullable
as bool?,favorite: freezed == favorite ? _self.favorite : favorite // ignore: cast_nullable_to_non_nullable
as bool?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int?,appliedAt: freezed == appliedAt ? _self.appliedAt : appliedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class EditOpSetBool extends EditOp {
  const EditOpSetBool({required this.id, required this.field, required this.value, @JsonKey(includeIfNull: false) this.appliedAt, final  String? $type}): $type = $type ?? 'set_bool',super._();
  factory EditOpSetBool.fromJson(Map<String, dynamic> json) => _$EditOpSetBoolFromJson(json);

 final  int id;
 final  EditOpBoolField field;
 final  bool value;
@override@JsonKey(includeIfNull: false) final  DateTime? appliedAt;

@JsonKey(name: 'op')
final String $type;


/// Create a copy of EditOp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditOpSetBoolCopyWith<EditOpSetBool> get copyWith => _$EditOpSetBoolCopyWithImpl<EditOpSetBool>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EditOpSetBoolToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditOpSetBool&&(identical(other.id, id) || other.id == id)&&(identical(other.field, field) || other.field == field)&&(identical(other.value, value) || other.value == value)&&(identical(other.appliedAt, appliedAt) || other.appliedAt == appliedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,field,value,appliedAt);

@override
String toString() {
  return 'EditOp.setBool(id: $id, field: $field, value: $value, appliedAt: $appliedAt)';
}


}

/// @nodoc
abstract mixin class $EditOpSetBoolCopyWith<$Res> implements $EditOpCopyWith<$Res> {
  factory $EditOpSetBoolCopyWith(EditOpSetBool value, $Res Function(EditOpSetBool) _then) = _$EditOpSetBoolCopyWithImpl;
@override @useResult
$Res call({
 int id, EditOpBoolField field, bool value,@JsonKey(includeIfNull: false) DateTime? appliedAt
});




}
/// @nodoc
class _$EditOpSetBoolCopyWithImpl<$Res>
    implements $EditOpSetBoolCopyWith<$Res> {
  _$EditOpSetBoolCopyWithImpl(this._self, this._then);

  final EditOpSetBool _self;
  final $Res Function(EditOpSetBool) _then;

/// Create a copy of EditOp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? field = null,Object? value = null,Object? appliedAt = freezed,}) {
  return _then(EditOpSetBool(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as EditOpBoolField,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as bool,appliedAt: freezed == appliedAt ? _self.appliedAt : appliedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class EditOpSetString extends EditOp {
  const EditOpSetString({required this.id, required this.field, required this.value, @JsonKey(includeIfNull: false) this.appliedAt, final  String? $type}): $type = $type ?? 'set_string',super._();
  factory EditOpSetString.fromJson(Map<String, dynamic> json) => _$EditOpSetStringFromJson(json);

 final  int id;
 final  EditOpStringField field;
 final  String value;
@override@JsonKey(includeIfNull: false) final  DateTime? appliedAt;

@JsonKey(name: 'op')
final String $type;


/// Create a copy of EditOp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditOpSetStringCopyWith<EditOpSetString> get copyWith => _$EditOpSetStringCopyWithImpl<EditOpSetString>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EditOpSetStringToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditOpSetString&&(identical(other.id, id) || other.id == id)&&(identical(other.field, field) || other.field == field)&&(identical(other.value, value) || other.value == value)&&(identical(other.appliedAt, appliedAt) || other.appliedAt == appliedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,field,value,appliedAt);

@override
String toString() {
  return 'EditOp.setString(id: $id, field: $field, value: $value, appliedAt: $appliedAt)';
}


}

/// @nodoc
abstract mixin class $EditOpSetStringCopyWith<$Res> implements $EditOpCopyWith<$Res> {
  factory $EditOpSetStringCopyWith(EditOpSetString value, $Res Function(EditOpSetString) _then) = _$EditOpSetStringCopyWithImpl;
@override @useResult
$Res call({
 int id, EditOpStringField field, String value,@JsonKey(includeIfNull: false) DateTime? appliedAt
});




}
/// @nodoc
class _$EditOpSetStringCopyWithImpl<$Res>
    implements $EditOpSetStringCopyWith<$Res> {
  _$EditOpSetStringCopyWithImpl(this._self, this._then);

  final EditOpSetString _self;
  final $Res Function(EditOpSetString) _then;

/// Create a copy of EditOp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? field = null,Object? value = null,Object? appliedAt = freezed,}) {
  return _then(EditOpSetString(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as EditOpStringField,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,appliedAt: freezed == appliedAt ? _self.appliedAt : appliedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class EditOpDelete extends EditOp {
  const EditOpDelete({required this.id, @JsonKey(includeIfNull: false) this.appliedAt, final  String? $type}): $type = $type ?? 'delete',super._();
  factory EditOpDelete.fromJson(Map<String, dynamic> json) => _$EditOpDeleteFromJson(json);

 final  int id;
@override@JsonKey(includeIfNull: false) final  DateTime? appliedAt;

@JsonKey(name: 'op')
final String $type;


/// Create a copy of EditOp
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EditOpDeleteCopyWith<EditOpDelete> get copyWith => _$EditOpDeleteCopyWithImpl<EditOpDelete>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EditOpDeleteToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EditOpDelete&&(identical(other.id, id) || other.id == id)&&(identical(other.appliedAt, appliedAt) || other.appliedAt == appliedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,appliedAt);

@override
String toString() {
  return 'EditOp.delete(id: $id, appliedAt: $appliedAt)';
}


}

/// @nodoc
abstract mixin class $EditOpDeleteCopyWith<$Res> implements $EditOpCopyWith<$Res> {
  factory $EditOpDeleteCopyWith(EditOpDelete value, $Res Function(EditOpDelete) _then) = _$EditOpDeleteCopyWithImpl;
@override @useResult
$Res call({
 int id,@JsonKey(includeIfNull: false) DateTime? appliedAt
});




}
/// @nodoc
class _$EditOpDeleteCopyWithImpl<$Res>
    implements $EditOpDeleteCopyWith<$Res> {
  _$EditOpDeleteCopyWithImpl(this._self, this._then);

  final EditOpDelete _self;
  final $Res Function(EditOpDelete) _then;

/// Create a copy of EditOp
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? appliedAt = freezed,}) {
  return _then(EditOpDelete(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,appliedAt: freezed == appliedAt ? _self.appliedAt : appliedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
