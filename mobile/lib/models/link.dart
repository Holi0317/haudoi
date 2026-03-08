import 'package:freezed_annotation/freezed_annotation.dart';

import 'tag.dart';

part 'link.freezed.dart';
part 'link.g.dart';

/// A single link item.
/// This maps to `LinkItemWithTags` type on worker side. However `LinkItem` type is an internal type on worker side
/// and is not referenced directly in the API, so we can change the structure of this class without worrying about breaking API compatibility.
@freezed
abstract class Link with _$Link {
  const factory Link({
    required int id,
    required String title,
    required String url,
    required bool favorite,
    required bool archive,
    required List<Tag> tags,
    @JsonKey(name: 'created_at') required int createdAt,
    required String note,
  }) = _Link;

  factory Link.fromJson(Map<String, dynamic> json) => _$LinkFromJson(json);
}
