import 'dart:async';

import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/search_query.dart';
import '../../models/search_response.dart';
import '../../models/server_info.dart';
import '../../models/tag.dart';
import '../../models/with_timestamp.dart';
import '../../repositories/api.dart';
import '../../repositories/api_error.dart';
import '../bindings/http.dart';
import '../extensions.dart';
import './../bindings/shared_preferences.dart';

part 'api.g.dart';

@riverpod
Future<ApiRepository> apiRepository(Ref ref) async {
  final httpClient = ref.watch(httpClientProvider);

  final apiUrl = await ref.watch(
    preferenceProvider(SharedPreferenceKey.apiUrl).future,
  );
  final apiToken = await ref.watch(
    preferenceProvider(SharedPreferenceKey.apiToken).future,
  );

  final client = ApiRepository(
    baseUrl: apiUrl,
    authToken: apiToken,
    transport: httpClient,
  );

  return client;
}

enum AuthStateEnum {
  authenticated,
  notConfig,
  unauthenticated,
  networkErr,
  loading,
}

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

  Future<void> _watchUnauth() async {
    final client = await ref.watch(apiRepositoryProvider.future);

    if (client.baseUrl.isEmpty) {
      _setState(AuthStateEnum.notConfig);
      return;
    }

    await _probe();

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

    ref.onDispose(subscription1.cancel);

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

    ref.onDispose(subscription2.cancel);
  }

  Future<void> _probe() async {
    try {
      final serverInfoData = await ref.watch(serverInfoProvider.future);

      _setState(serverInfoData.session != null
          ? AuthStateEnum.authenticated
          : AuthStateEnum.unauthenticated);
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

@riverpod
Future<ServerInfo> serverInfo(Ref ref) async {
  final client = await ref.watch(apiRepositoryProvider.future);
  return client.info(abortTrigger: ref.abortTrigger());
}

@riverpod
Future<WithTimestamp<SearchResponse>> search(Ref ref, SearchQuery query) async {
  final client = await ref.watch(apiRepositoryProvider.future);
  final data = await client.search(query, abortTrigger: ref.abortTrigger());

  return WithTimestamp(data);
}

@riverpod
Future<List<Tag>> tags(Ref ref) async {
  final client = await ref.watch(apiRepositoryProvider.future);
  final response = await client.listTags(abortTrigger: ref.abortTrigger());
  return response.items;
}
