import 'dart:async';

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
