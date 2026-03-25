import 'package:freezed_annotation/freezed_annotation.dart';

part 'tag.freezed.dart';
part 'tag.g.dart';

@freezed
abstract class Tag with _$Tag {
  const factory Tag({
    required int id,
    required String name,
    required String color,
    required String emoji,
    @JsonKey(name: 'created_at') required int createdAt,
  }) = _Tag;

  factory Tag.fromJson(Map<String, dynamic> json) => _$TagFromJson(json);
}

@freezed
abstract class TagListResponse with _$TagListResponse {
  const factory TagListResponse({required List<Tag> items}) = _TagListResponse;

  factory TagListResponse.fromJson(Map<String, dynamic> json) =>
      _$TagListResponseFromJson(json);
}

@freezed
abstract class TagCreateBody with _$TagCreateBody {
  const factory TagCreateBody({
    required String name,
    required String color,
    @JsonKey(includeIfNull: false) String? emoji,
  }) = _TagCreateBody;

  factory TagCreateBody.fromJson(Map<String, dynamic> json) =>
      _$TagCreateBodyFromJson(json);
}

@freezed
abstract class TagUpdateBody with _$TagUpdateBody {
  const factory TagUpdateBody({String? name, String? color, String? emoji}) =
      _TagUpdateBody;

  factory TagUpdateBody.fromJson(Map<String, dynamic> json) =>
      _$TagUpdateBodyFromJson(json);
}
