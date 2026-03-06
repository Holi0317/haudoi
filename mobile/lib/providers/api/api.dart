import 'dart:async';

import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/search_query.dart';
import '../../models/search_response.dart';
import '../../models/server_info.dart';
import '../../models/tag.dart';
import '../../models/with_timestamp.dart';
import '../../repositories/api.dart';
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

enum AuthStateEnum { authenticated, notConfig, unauthenticated, loading }

@riverpod
class AuthState extends _$AuthState {
  final _logger = Logger('AuthStateProvider');

  @override
  AuthStateEnum build() {
    _watchUnauth();

    return AuthStateEnum.loading;
  }

  Future<void> _watchUnauth() async {
    final client = await ref.watch(apiRepositoryProvider.future);

    if (client.baseUrl.isEmpty) {
      state = AuthStateEnum.notConfig;
      return;
    }

    await _probe();

    final subscription = client.eventBus.on<RequestException>().listen((event) {
      if (event.statusCode == 401) {
        _logger.info(
          "Received 401 Unauthorized response on ${event.method} ${event.path}, marking authState unauthenticated. Body = ${event.body}",
        );
        state = AuthStateEnum.unauthenticated;
      }
    });

    ref.onDispose(subscription.cancel);
  }

  Future<void> _probe() async {
    try {
      final info = await ref.watch(serverInfoProvider.future);

      state = info.session != null
          ? AuthStateEnum.authenticated
          : AuthStateEnum.unauthenticated;
    } catch (err) {
      // FIXME: distinguish network error and unauthenticated
      _logger.warning("Failed to fetch server info: $err");
      state = AuthStateEnum.unauthenticated;
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
