import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_error.dart';

const _noRetryStatus = {
  // Transient errors
  400, 408, 500, 502, 503, 504,

  // Throttling errors
  /* 400, */ 403, 429, /* 502, 503, */ 509,
};

/// Retry strategy for riverpod provider.
///
/// Mostly based on AWS SDK's default retry strategy:
/// See https://docs.aws.amazon.com/sdkref/latest/guide/feature-retry-behavior.html
Duration? retryStrategy(int retryCount, Object error) {
  if (error is HttpApiError && _noRetryStatus.contains(error.statusCode)) {
    return null;
  }

  return ProviderContainer.defaultRetry(
    retryCount,
    error,
    maxRetries: 3,
    minDelay: const Duration(milliseconds: 100),
    maxDelay: const Duration(seconds: 20),
  );
}
