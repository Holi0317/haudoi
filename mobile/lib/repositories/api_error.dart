import '../models/api_error.dart';

sealed class ApiError implements Exception {
  /// HTTP method used for this request, for example `GET` or `POST`.
  final String method;

  /// API path for this request, always starting with `/`.
  final String path;

  const ApiError({required this.method, required this.path});

  @override
  String toString() => 'ApiError for $method $path';
}

/// Error raised when the request cannot reach a valid HTTP response.
///
/// This covers network and transport failures, such as DNS lookup failure,
/// TCP/TLS handshake issues, or client-side socket errors.
final class TransportApiError extends ApiError {
  /// Original exception thrown by the HTTP transport.
  final Object cause;

  /// Optional stack trace for diagnostics.
  final StackTrace? stackTrace;

  const TransportApiError({
    required super.method,
    required super.path,
    required this.cause,
    this.stackTrace,
  });

  @override
  String toString() => 'TransportApiError for $method $path: $cause';
}

/// Error raised when the request is cancelled intentionally.
///
/// This is expected in many flows, for example when a user leaves a screen
/// and in-flight requests are aborted, or the request has timeout.
final class CancelledApiError extends ApiError {
  /// Original exception thrown by the HTTP transport.
  final Object cause;

  /// Optional stack trace for diagnostics.
  final StackTrace? stackTrace;

  const CancelledApiError({
    required super.method,
    required super.path,
    required this.cause,
    this.stackTrace,
  });

  @override
  String toString() => 'CancelledApiError for $method $path';
}

/// Error raised when a response is received but HTTP status is not successful.
///
/// This class keeps the raw response body for logging or fallback parsing.
///
/// For known server errors with machine-readable codes, see [KnownServerApiError] instead.
class HttpApiError extends ApiError {
  /// HTTP response status code.
  final int statusCode;

  /// Raw response body.
  final String body;

  const HttpApiError({
    required super.method,
    required super.path,
    required this.statusCode,
    required this.body,
  });

  @override
  String toString() {
    return 'HttpApiError for $method $path $statusCode: $body';
  }
}

/// Error raised for non-success HTTP responses with a known server error code.
///
/// Use this variant when the backend returns a recognized machine-readable
/// code (for example `TAG_NAME_EXISTS`) that consumers can branch on.
final class KnownServerApiError extends HttpApiError {
  final ApiErrorModel model;

  const KnownServerApiError({
    required super.method,
    required super.path,
    required super.statusCode,
    required super.body,
    required this.model,
  });

  @override
  String toString() {
    return 'KnownServerApiError for $method $path $statusCode [${model.code}]: ${model.message}';
  }
}

/// Error raised when a JSON response is expected but decoding fails.
///
/// This means the server returned malformed JSON or a non-JSON payload.
final class InvalidJsonApiError extends ApiError {
  /// Raw response body that failed to decode.
  final String body;

  /// Decoder exception, usually [FormatException].
  final Object cause;

  /// Optional stack trace from decoder.
  final StackTrace? stackTrace;

  const InvalidJsonApiError({
    required super.method,
    required super.path,
    required this.body,
    required this.cause,
    this.stackTrace,
  });

  @override
  String toString() => 'InvalidJsonApiError for $method $path: $cause';
}

/// Error raised when JSON is decoded successfully but does not match model shape.
///
/// This is commonly thrown when generated `fromJson` code (for example from
/// `freezed` + `json_serializable`) rejects missing fields or wrong types.
final class InvalidPayloadApiError extends ApiError {
  /// Decoded JSON body that failed model parsing.
  final Object? decodedBody;

  /// Parser exception from model conversion.
  final Object cause;

  /// Optional stack trace from parser.
  final StackTrace? stackTrace;

  const InvalidPayloadApiError({
    required super.method,
    required super.path,
    required this.decodedBody,
    required this.cause,
    this.stackTrace,
  });

  @override
  String toString() => 'InvalidPayloadApiError for $method $path: $cause';
}

/// Fallback error when a failure does not match any specific [ApiError] type.
final class UnknownApiError extends ApiError {
  /// Original exception.
  final Object cause;

  /// Optional stack trace for diagnostics.
  final StackTrace? stackTrace;

  const UnknownApiError({
    required super.method,
    required super.path,
    required this.cause,
    this.stackTrace,
  });

  @override
  String toString() => 'UnknownApiError for $method $path: $cause';
}
