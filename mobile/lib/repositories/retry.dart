import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_error.dart';

// Client errors that won't be resolved by retrying.
const _noRetryStatus = {
  400, // Bad Request
  401, // Unauthorized
  403, // Forbidden
  404, // Not Found
  405, // Method Not Allowed
  409, // Conflict
  410, // Gone
  422, // Unprocessable Entity
};

/// Retry strategy for Riverpod providers.
///
/// Only [TransportApiError] (network blips, DNS failures, etc.) and
/// [HttpApiError] with non-permanent status codes are retried.
/// Everything else — client errors, cancellations, decoding failures, and
/// definitive server responses — is surfaced to the caller immediately.
Duration? retryStrategy(int retryCount, Object error) {
  final shouldRetry = switch (error) {
    TransportApiError() => true,
    HttpApiError() => !_noRetryStatus.contains(error.statusCode),
    _ => false,
  };

  if (!shouldRetry) return null;

  return ProviderContainer.defaultRetry(
    retryCount,
    error,
    maxRetries: 3,
    minDelay: const Duration(milliseconds: 100),
    maxDelay: const Duration(seconds: 8),
  );
}
