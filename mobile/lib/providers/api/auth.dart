import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../repositories/api_error.dart';
import '../bindings/shared_preferences.dart';
import '../sync/queue.dart';
import 'api.dart';

part 'auth.g.dart';

/// Represents the authentication state of the user.
enum AuthStateEnum {
  /// User is authenticated with a valid session.
  authenticated,

  /// API URL is not configured yet.
  notConfig,

  /// User is not authenticated (no valid session).
  unauthenticated,

  /// Network error occurred while checking authentication.
  networkErr,

  /// Initial state, authentication state is being loaded.
  loading,
}

/// A notifier that monitors authentication state.
///
/// Listens to API errors (401, transport errors) and probes the server
/// to determine if the user is authenticated.
@riverpod
class AuthState extends _$AuthState {
  final _logger = Logger('AuthStateProvider');

  void _setState(AuthStateEnum newState) {
    if (ref.mounted) {
      state = newState;
    }
  }

  @override
  AuthStateEnum build() {
    _watchUnauth();

    return AuthStateEnum.loading;
  }

  /// Sets up listeners for unauthentication events from the API client.
  Future<void> _watchUnauth() async {
    final client = await ref.watch(apiRepositoryProvider.future);

    if (client.baseUrl.isEmpty) {
      _setState(AuthStateEnum.notConfig);
      return;
    }

    final subscription1 = client.eventBus.on<KnownServerApiError>().listen((
      event,
    ) {
      if (event.model.code == "unauthenticated") {
        _logger.info(
          "Received 401 Unauthorized response on ${event.method} ${event.path}, marking authState unauthenticated. Body = ${event.body}",
        );
        _setState(AuthStateEnum.unauthenticated);
      }
    });

    final subscription2 = client.eventBus.on<TransportApiError>().listen((
      event,
    ) {
      _logger.warning(
        "Received transport error on ${event.method} ${event.path}: ${event.cause}",
        event.cause,
        event.stackTrace,
      );

      _setState(AuthStateEnum.networkErr);
    });

    ref.onDispose(subscription1.cancel);
    ref.onDispose(subscription2.cancel);

    await _probe();
  }

  /// Probes the server to check if the user has a valid session.
  Future<void> _probe() async {
    if (!ref.mounted) return;

    try {
      final serverInfoData = await ref.watch(serverInfoProvider.future);

      _setState(
        serverInfoData.session != null
            ? AuthStateEnum.authenticated
            : AuthStateEnum.unauthenticated,
      );
    } on CancelledApiError catch (err) {
      _logger.warning("Probe was cancelled", err);
    } on TransportApiError catch (err) {
      _logger.warning("Network error while probing server", err);
      _setState(AuthStateEnum.networkErr);
    } on KnownServerApiError catch (err) {
      _logger.warning(
        "Server error while probing: [${err.model.code}] ${err.model.message}",
      );
      _setState(AuthStateEnum.unauthenticated);
    } on ApiError catch (err) {
      _logger.warning("API error while probing server: $err");
      _setState(AuthStateEnum.networkErr);
    } catch (err) {
      _logger.warning("Unexpected error while probing server: $err");
      _setState(AuthStateEnum.networkErr);
    }
  }
}

/// A notifier for managing authentication actions.
/// Return of this provider doesn't matter. Only use methods in the notifier instead.
@riverpod
class Auth extends _$Auth {
  @override
  Future<void> build() async {}

  /// Logs in the user by storing the API token and URL.
  Future<void> login({required String apiUrl, required String token}) async {
    final t = ref.read(
      preferenceProvider(SharedPreferenceKey.apiToken).notifier,
    );
    final url = ref.read(
      preferenceProvider(SharedPreferenceKey.apiUrl).notifier,
    );
    final recent = ref.read(recentServersProvider.notifier);

    await t.set(token);
    await url.set(apiUrl);
    await recent.add(apiUrl);
  }

  /// Logs out the user from this app.
  /// Optionally takes a [BuildContext] to navigate to the login screen after logout.
  Future<void> logout([BuildContext? context]) async {
    final apiToken = ref.read(
      preferenceProvider(SharedPreferenceKey.apiToken).notifier,
    );
    final editQueue = ref.read(editQueueProvider.notifier);

    await apiToken.reset();
    editQueue.reset();

    if (context == null || !context.mounted) {
      return;
    }

    context.go('/login');
  }
}
