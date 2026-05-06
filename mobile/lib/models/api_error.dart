import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_error.freezed.dart';
part 'api_error.g.dart';

/// Model for error (>= 400) response from API.
///
/// Maps to [KnownServerApiError] exception.
@freezed
sealed class ApiErrorModel with _$ApiErrorModel {
  const factory ApiErrorModel({
    required String code,
    required String message,
    Map<String, dynamic>? details,
  }) = _ApiErrorModel;

  factory ApiErrorModel.fromJson(Map<String, dynamic> json) =>
      _$ApiErrorModelFromJson(json);
}
