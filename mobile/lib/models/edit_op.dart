import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_op.freezed.dart';
part 'edit_op.g.dart';

enum EditOpBoolField {
  @JsonValue('archive')
  archive,
  @JsonValue('favorite')
  favorite,
}

enum EditOpStringField {
  @JsonValue('note')
  note,
}

/// An edit operation to be performed on a link, or an insertion of a new link.
///
/// Note: The `appliedAt` field isn't present in the server. It's used for tracking
/// when the operation got sent to the server locally.
@Freezed(unionKey: 'op', unionValueCase: FreezedUnionCase.snake)
sealed class EditOp with _$EditOp {
  const EditOp._();

  const factory EditOp.insert({
    String? title,
    required String url,
    @JsonKey(includeIfNull: false) bool? archive,
    @JsonKey(includeIfNull: false) bool? favorite,
    @JsonKey(includeIfNull: false) String? note,
    @JsonKey(name: 'created_at', includeIfNull: false) int? createdAt,
    @JsonKey(includeIfNull: false) DateTime? appliedAt,
  }) = EditOpInsert;

  const factory EditOp.setBool({
    required int id,
    required EditOpBoolField field,
    required bool value,
    @JsonKey(includeIfNull: false) DateTime? appliedAt,
  }) = EditOpSetBool;

  const factory EditOp.setString({
    required int id,
    required EditOpStringField field,
    required String value,
    @JsonKey(includeIfNull: false) DateTime? appliedAt,
  }) = EditOpSetString;

  const factory EditOp.delete({
    required int id,
    @JsonKey(includeIfNull: false) DateTime? appliedAt,
  }) = EditOpDelete;

  factory EditOp.fromJson(Map<String, dynamic> json) => _$EditOpFromJson(json);

  /// Returns the associated link ID if applicable, or null for insert operations.
  int? get maybeId => switch (this) {
    EditOpInsert() => null,
    EditOpSetBool(:final id) => id,
    EditOpSetString(:final id) => id,
    EditOpDelete(:final id) => id,
  };
}
