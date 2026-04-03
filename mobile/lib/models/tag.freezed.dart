// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tag.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Tag {

 int get id; String get name; String get color; String get emoji;@JsonKey(name: 'created_at') int get createdAt;
/// Create a copy of Tag
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TagCopyWith<Tag> get copyWith => _$TagCopyWithImpl<Tag>(this as Tag, _$identity);

  /// Serializes this Tag to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Tag&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,color,emoji,createdAt);

@override
String toString() {
  return 'Tag(id: $id, name: $name, color: $color, emoji: $emoji, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $TagCopyWith<$Res>  {
  factory $TagCopyWith(Tag value, $Res Function(Tag) _then) = _$TagCopyWithImpl;
@useResult
$Res call({
 int id, String name, String color, String emoji,@JsonKey(name: 'created_at') int createdAt
});




}
/// @nodoc
class _$TagCopyWithImpl<$Res>
    implements $TagCopyWith<$Res> {
  _$TagCopyWithImpl(this._self, this._then);

  final Tag _self;
  final $Res Function(Tag) _then;

/// Create a copy of Tag
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? color = null,Object? emoji = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Tag].
extension TagPatterns on Tag {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Tag value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Tag() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Tag value)  $default,){
final _that = this;
switch (_that) {
case _Tag():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Tag value)?  $default,){
final _that = this;
switch (_that) {
case _Tag() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String color,  String emoji, @JsonKey(name: 'created_at')  int createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Tag() when $default != null:
return $default(_that.id,_that.name,_that.color,_that.emoji,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String color,  String emoji, @JsonKey(name: 'created_at')  int createdAt)  $default,) {final _that = this;
switch (_that) {
case _Tag():
return $default(_that.id,_that.name,_that.color,_that.emoji,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String color,  String emoji, @JsonKey(name: 'created_at')  int createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Tag() when $default != null:
return $default(_that.id,_that.name,_that.color,_that.emoji,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Tag implements Tag {
  const _Tag({required this.id, required this.name, required this.color, required this.emoji, @JsonKey(name: 'created_at') required this.createdAt});
  factory _Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);

@override final  int id;
@override final  String name;
@override final  String color;
@override final  String emoji;
@override@JsonKey(name: 'created_at') final  int createdAt;

/// Create a copy of Tag
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TagCopyWith<_Tag> get copyWith => __$TagCopyWithImpl<_Tag>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TagToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Tag&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,color,emoji,createdAt);

@override
String toString() {
  return 'Tag(id: $id, name: $name, color: $color, emoji: $emoji, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$TagCopyWith<$Res> implements $TagCopyWith<$Res> {
  factory _$TagCopyWith(_Tag value, $Res Function(_Tag) _then) = __$TagCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String color, String emoji,@JsonKey(name: 'created_at') int createdAt
});




}
/// @nodoc
class __$TagCopyWithImpl<$Res>
    implements _$TagCopyWith<$Res> {
  __$TagCopyWithImpl(this._self, this._then);

  final _Tag _self;
  final $Res Function(_Tag) _then;

/// Create a copy of Tag
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? color = null,Object? emoji = null,Object? createdAt = null,}) {
  return _then(_Tag(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,emoji: null == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TagListResponse {

 List<Tag> get items;
/// Create a copy of TagListResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TagListResponseCopyWith<TagListResponse> get copyWith => _$TagListResponseCopyWithImpl<TagListResponse>(this as TagListResponse, _$identity);

  /// Serializes this TagListResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TagListResponse&&const DeepCollectionEquality().equals(other.items, items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items));

@override
String toString() {
  return 'TagListResponse(items: $items)';
}


}

/// @nodoc
abstract mixin class $TagListResponseCopyWith<$Res>  {
  factory $TagListResponseCopyWith(TagListResponse value, $Res Function(TagListResponse) _then) = _$TagListResponseCopyWithImpl;
@useResult
$Res call({
 List<Tag> items
});




}
/// @nodoc
class _$TagListResponseCopyWithImpl<$Res>
    implements $TagListResponseCopyWith<$Res> {
  _$TagListResponseCopyWithImpl(this._self, this._then);

  final TagListResponse _self;
  final $Res Function(TagListResponse) _then;

/// Create a copy of TagListResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<Tag>,
  ));
}

}


/// Adds pattern-matching-related methods to [TagListResponse].
extension TagListResponsePatterns on TagListResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TagListResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TagListResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TagListResponse value)  $default,){
final _that = this;
switch (_that) {
case _TagListResponse():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TagListResponse value)?  $default,){
final _that = this;
switch (_that) {
case _TagListResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Tag> items)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TagListResponse() when $default != null:
return $default(_that.items);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Tag> items)  $default,) {final _that = this;
switch (_that) {
case _TagListResponse():
return $default(_that.items);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Tag> items)?  $default,) {final _that = this;
switch (_that) {
case _TagListResponse() when $default != null:
return $default(_that.items);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TagListResponse implements TagListResponse {
  const _TagListResponse({required final  List<Tag> items}): _items = items;
  factory _TagListResponse.fromJson(Map<String, dynamic> json) => _$TagListResponseFromJson(json);

 final  List<Tag> _items;
@override List<Tag> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}


/// Create a copy of TagListResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TagListResponseCopyWith<_TagListResponse> get copyWith => __$TagListResponseCopyWithImpl<_TagListResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TagListResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TagListResponse&&const DeepCollectionEquality().equals(other._items, _items));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_items));

@override
String toString() {
  return 'TagListResponse(items: $items)';
}


}

/// @nodoc
abstract mixin class _$TagListResponseCopyWith<$Res> implements $TagListResponseCopyWith<$Res> {
  factory _$TagListResponseCopyWith(_TagListResponse value, $Res Function(_TagListResponse) _then) = __$TagListResponseCopyWithImpl;
@override @useResult
$Res call({
 List<Tag> items
});




}
/// @nodoc
class __$TagListResponseCopyWithImpl<$Res>
    implements _$TagListResponseCopyWith<$Res> {
  __$TagListResponseCopyWithImpl(this._self, this._then);

  final _TagListResponse _self;
  final $Res Function(_TagListResponse) _then;

/// Create a copy of TagListResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,}) {
  return _then(_TagListResponse(
items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<Tag>,
  ));
}


}


/// @nodoc
mixin _$TagCreateBody {

 String get name; String get color;@JsonKey(includeIfNull: false) String? get emoji;
/// Create a copy of TagCreateBody
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TagCreateBodyCopyWith<TagCreateBody> get copyWith => _$TagCreateBodyCopyWithImpl<TagCreateBody>(this as TagCreateBody, _$identity);

  /// Serializes this TagCreateBody to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TagCreateBody&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.emoji, emoji) || other.emoji == emoji));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,color,emoji);

@override
String toString() {
  return 'TagCreateBody(name: $name, color: $color, emoji: $emoji)';
}


}

/// @nodoc
abstract mixin class $TagCreateBodyCopyWith<$Res>  {
  factory $TagCreateBodyCopyWith(TagCreateBody value, $Res Function(TagCreateBody) _then) = _$TagCreateBodyCopyWithImpl;
@useResult
$Res call({
 String name, String color,@JsonKey(includeIfNull: false) String? emoji
});




}
/// @nodoc
class _$TagCreateBodyCopyWithImpl<$Res>
    implements $TagCreateBodyCopyWith<$Res> {
  _$TagCreateBodyCopyWithImpl(this._self, this._then);

  final TagCreateBody _self;
  final $Res Function(TagCreateBody) _then;

/// Create a copy of TagCreateBody
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? color = null,Object? emoji = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TagCreateBody].
extension TagCreateBodyPatterns on TagCreateBody {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TagCreateBody value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TagCreateBody() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TagCreateBody value)  $default,){
final _that = this;
switch (_that) {
case _TagCreateBody():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TagCreateBody value)?  $default,){
final _that = this;
switch (_that) {
case _TagCreateBody() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String color, @JsonKey(includeIfNull: false)  String? emoji)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TagCreateBody() when $default != null:
return $default(_that.name,_that.color,_that.emoji);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String color, @JsonKey(includeIfNull: false)  String? emoji)  $default,) {final _that = this;
switch (_that) {
case _TagCreateBody():
return $default(_that.name,_that.color,_that.emoji);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String color, @JsonKey(includeIfNull: false)  String? emoji)?  $default,) {final _that = this;
switch (_that) {
case _TagCreateBody() when $default != null:
return $default(_that.name,_that.color,_that.emoji);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TagCreateBody implements TagCreateBody {
  const _TagCreateBody({required this.name, required this.color, @JsonKey(includeIfNull: false) this.emoji});
  factory _TagCreateBody.fromJson(Map<String, dynamic> json) => _$TagCreateBodyFromJson(json);

@override final  String name;
@override final  String color;
@override@JsonKey(includeIfNull: false) final  String? emoji;

/// Create a copy of TagCreateBody
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TagCreateBodyCopyWith<_TagCreateBody> get copyWith => __$TagCreateBodyCopyWithImpl<_TagCreateBody>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TagCreateBodyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TagCreateBody&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.emoji, emoji) || other.emoji == emoji));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,color,emoji);

@override
String toString() {
  return 'TagCreateBody(name: $name, color: $color, emoji: $emoji)';
}


}

/// @nodoc
abstract mixin class _$TagCreateBodyCopyWith<$Res> implements $TagCreateBodyCopyWith<$Res> {
  factory _$TagCreateBodyCopyWith(_TagCreateBody value, $Res Function(_TagCreateBody) _then) = __$TagCreateBodyCopyWithImpl;
@override @useResult
$Res call({
 String name, String color,@JsonKey(includeIfNull: false) String? emoji
});




}
/// @nodoc
class __$TagCreateBodyCopyWithImpl<$Res>
    implements _$TagCreateBodyCopyWith<$Res> {
  __$TagCreateBodyCopyWithImpl(this._self, this._then);

  final _TagCreateBody _self;
  final $Res Function(_TagCreateBody) _then;

/// Create a copy of TagCreateBody
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? color = null,Object? emoji = freezed,}) {
  return _then(_TagCreateBody(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TagUpdateBody {

 String? get name; String? get color; String? get emoji;
/// Create a copy of TagUpdateBody
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TagUpdateBodyCopyWith<TagUpdateBody> get copyWith => _$TagUpdateBodyCopyWithImpl<TagUpdateBody>(this as TagUpdateBody, _$identity);

  /// Serializes this TagUpdateBody to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TagUpdateBody&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.emoji, emoji) || other.emoji == emoji));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,color,emoji);

@override
String toString() {
  return 'TagUpdateBody(name: $name, color: $color, emoji: $emoji)';
}


}

/// @nodoc
abstract mixin class $TagUpdateBodyCopyWith<$Res>  {
  factory $TagUpdateBodyCopyWith(TagUpdateBody value, $Res Function(TagUpdateBody) _then) = _$TagUpdateBodyCopyWithImpl;
@useResult
$Res call({
 String? name, String? color, String? emoji
});




}
/// @nodoc
class _$TagUpdateBodyCopyWithImpl<$Res>
    implements $TagUpdateBodyCopyWith<$Res> {
  _$TagUpdateBodyCopyWithImpl(this._self, this._then);

  final TagUpdateBody _self;
  final $Res Function(TagUpdateBody) _then;

/// Create a copy of TagUpdateBody
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? color = freezed,Object? emoji = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TagUpdateBody].
extension TagUpdateBodyPatterns on TagUpdateBody {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TagUpdateBody value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TagUpdateBody() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TagUpdateBody value)  $default,){
final _that = this;
switch (_that) {
case _TagUpdateBody():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TagUpdateBody value)?  $default,){
final _that = this;
switch (_that) {
case _TagUpdateBody() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  String? color,  String? emoji)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TagUpdateBody() when $default != null:
return $default(_that.name,_that.color,_that.emoji);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  String? color,  String? emoji)  $default,) {final _that = this;
switch (_that) {
case _TagUpdateBody():
return $default(_that.name,_that.color,_that.emoji);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  String? color,  String? emoji)?  $default,) {final _that = this;
switch (_that) {
case _TagUpdateBody() when $default != null:
return $default(_that.name,_that.color,_that.emoji);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TagUpdateBody implements TagUpdateBody {
  const _TagUpdateBody({this.name, this.color, this.emoji});
  factory _TagUpdateBody.fromJson(Map<String, dynamic> json) => _$TagUpdateBodyFromJson(json);

@override final  String? name;
@override final  String? color;
@override final  String? emoji;

/// Create a copy of TagUpdateBody
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TagUpdateBodyCopyWith<_TagUpdateBody> get copyWith => __$TagUpdateBodyCopyWithImpl<_TagUpdateBody>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TagUpdateBodyToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TagUpdateBody&&(identical(other.name, name) || other.name == name)&&(identical(other.color, color) || other.color == color)&&(identical(other.emoji, emoji) || other.emoji == emoji));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,color,emoji);

@override
String toString() {
  return 'TagUpdateBody(name: $name, color: $color, emoji: $emoji)';
}


}

/// @nodoc
abstract mixin class _$TagUpdateBodyCopyWith<$Res> implements $TagUpdateBodyCopyWith<$Res> {
  factory _$TagUpdateBodyCopyWith(_TagUpdateBody value, $Res Function(_TagUpdateBody) _then) = __$TagUpdateBodyCopyWithImpl;
@override @useResult
$Res call({
 String? name, String? color, String? emoji
});




}
/// @nodoc
class __$TagUpdateBodyCopyWithImpl<$Res>
    implements _$TagUpdateBodyCopyWith<$Res> {
  __$TagUpdateBodyCopyWithImpl(this._self, this._then);

  final _TagUpdateBody _self;
  final $Res Function(_TagUpdateBody) _then;

/// Create a copy of TagUpdateBody
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? color = freezed,Object? emoji = freezed,}) {
  return _then(_TagUpdateBody(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
