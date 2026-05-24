import 'dart:convert';
import 'dart:io' show Cookie;

import 'package:collection/collection.dart';
import 'package:event_bus/event_bus.dart';
import 'package:http/http.dart' as http;

import '../models/api_error.dart';
import '../models/edit_op.dart';
import '../models/link.dart';
import '../models/search_query.dart';
import '../models/search_response.dart';
import '../models/server_info.dart';
import '../models/tag.dart';
import 'api_error.dart';

class _ApiClient {
  final http.Client _client;
  final String baseUrl;
  final String _authToken;

  final eventBus = EventBus();

  _ApiClient({
    required http.Client transport,
    required this.baseUrl,
    required String authToken,
  }) : _authToken = authToken,
       _client = transport;

  /// HTTP headers for requests.
  late final Map<String, String> headers = Map.unmodifiable({
    if (_authToken.isNotEmpty)
      'cookie': Cookie('__Host-haudoi-auth', _authToken).toString(),
    // FIXME: Add version
    'user-agent': 'haudoi-mobile',
  });

  /// Send a request to the server and parse response body as JSON.
  ///
  /// Use [requestRaw] for endpoints with non-JSON response body or empty response.
  Future<T> requestJson<T>(
    String method,
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    Future<void>? abortTrigger,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    return _wrapError(
      method,
      path,
      () => _requestJson(
        method,
        path,
        body: body,
        queryParameters: queryParameters,
        abortTrigger: abortTrigger,
        fromJson: fromJson,
      ),
    );
  }

  Future<T> _requestJson<T>(
    String method,
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    Future<void>? abortTrigger,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final resp = await requestRaw(
      method,
      path,
      body: body,
      queryParameters: queryParameters,
      abortTrigger: abortTrigger,
    );

    final responseBodyString = await resp.stream.bytesToString();

    final dynamic jsonResponse;
    try {
      jsonResponse = jsonDecode(responseBodyString);
    } catch (err, st) {
      throw InvalidJsonApiError(
        method: method,
        path: path,
        body: responseBodyString,
        cause: err,
        stackTrace: st,
      );
    }

    try {
      return fromJson(jsonResponse as Map<String, dynamic>);
    } catch (err, st) {
      throw InvalidPayloadApiError(
        method: method,
        path: path,
        decodedBody: jsonResponse,
        cause: err,
        stackTrace: st,
      );
    }
  }

  /// Send a request to the server.
  ///
  /// This is a low-level method for getting raw response stream, suitable for endpoints
  /// where the response body is not JSON, or is empty.
  /// Use [requestJson] for endpoint with JSON response body instead.
  ///
  /// Throws [ApiError] and emit into [eventBus] for error from the server. See [ApiError] for details on error types.
  ///
  /// [method] should be a valid HTTP method, e.g. 'GET', 'POST', etc.
  /// Internally this will get converted to uppercase, but still recommend passing in uppercase for readability.
  ///
  /// [path] should begin with a `/`.
  ///
  /// If [body] is provided, request will be sent as json. Do not provide [body]
  /// on GET request.
  Future<http.StreamedResponse> requestRaw(
    String method,
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    Future<void>? abortTrigger,
  }) async {
    return _wrapError(
      method,
      path,
      () => _requestRaw(
        method,
        path,
        body: body,
        queryParameters: queryParameters,
        abortTrigger: abortTrigger,
      ),
    );
  }

  Future<http.StreamedResponse> _requestRaw(
    String method,
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    Future<void>? abortTrigger,
  }) async {
    method = method.toUpperCase();

    assert(
      path.startsWith('/'),
      'Path should start with a slash, this is a configuration error',
    );

    final url = Uri.parse(
      '$baseUrl$path',
    ).replace(queryParameters: queryParameters);

    final req = http.AbortableRequest(method, url, abortTrigger: abortTrigger);
    req.headers.addAll(headers);

    if (body != null) {
      assert(method != 'GET', 'GET request cannot contain body');

      req.headers['content-type'] = 'application/json';
      req.body = jsonEncode(body);
    }

    final resp = await _client.send(req);

    if (resp.statusCode < 400) {
      return resp;
    }

    // Error response. First try to parse as known error format
    final respBody = await resp.stream.bytesToString();

    try {
      final json = jsonDecode(respBody) as Map<String, dynamic>;
      final model = ApiErrorModel.fromJson(json);
      throw KnownServerApiError(
        method: method,
        path: path,
        statusCode: resp.statusCode,
        body: respBody,
        model: model,
      );
    } on KnownServerApiError {
      rethrow;
    } catch (err) {
      // Cannot parse error response, throw generic exception with raw body.
      throw HttpApiError(
        method: method,
        path: path,
        body: respBody,
        statusCode: resp.statusCode,
      );
    }
  }

  Future<T> _wrapError<T>(
    String method,
    String path,
    Future<T> Function() fn,
  ) async {
    try {
      return await fn();
    } on ApiError catch (err) {
      eventBus.fire(err);
      rethrow;
    } on http.AbortableStreamedRequest catch (err, st) {
      final e2 = CancelledApiError(
        method: method,
        path: path,
        cause: err,
        stackTrace: st,
      );
      eventBus.fire(e2);
      throw e2;
    } on http.ClientException catch (err, st) {
      final e2 = TransportApiError(
        method: method,
        path: path,
        cause: err,
        stackTrace: st,
      );
      eventBus.fire(e2);
      throw e2;
    } catch (err, st) {
      final e2 = UnknownApiError(
        method: method,
        path: path,
        cause: err,
        stackTrace: st,
      );
      eventBus.fire(e2);
      throw e2;
    }
  }
}

/// Binding for server API.
class ApiRepository {
  final _ApiClient _client;

  ApiRepository({
    required http.Client transport,
    required String baseUrl,
    required String authToken,
  }) : _client = _ApiClient(
         transport: transport,
         baseUrl: baseUrl,
         authToken: authToken,
       );

  String get baseUrl => _client.baseUrl;

  Map<String, String> get headers => _client.headers;

  /// Event bus for emitting failed request.
  ///
  /// For use of global event handling, e.g. logging out user on 401 Unauthorized.
  ///
  /// Emits [ApiError] variants for all error types. See child classes of [ApiError] for details on error types.
  EventBus get eventBus => _client.eventBus;

  Future<ServerInfo> info({Future<void>? abortTrigger}) {
    return _client.requestJson(
      'GET',
      '/',
      abortTrigger: abortTrigger,
      fromJson: ServerInfo.fromJson,
    );
  }

  /// Search (or list) links from server.
  Future<SearchResponse> search(
    SearchQuery query, {
    Future<void>? abortTrigger,
  }) {
    return _client.requestJson(
      'GET',
      '/search',
      queryParameters: query.toMap(),
      abortTrigger: abortTrigger,
      fromJson: SearchResponse.fromJson,
    );
  }

  /// Get a single link from server.
  ///
  /// If the item ID is not found, throws [KnownServerApiError] with status code 404
  /// (or [HttpApiError] if the error response format is unrecognized).
  Future<Link> getItem(int id, {Future<void>? abortTrigger}) {
    return _client.requestJson(
      'GET',
      '/item/$id',
      abortTrigger: abortTrigger,
      fromJson: Link.fromJson,
    );
  }

  /// Edit or insert links.
  Future<void> edit(List<EditOp> op, {Future<void>? abortTrigger}) async {
    // Each batch only supports at most 30 items
    for (final chunk in op.slices(30)) {
      final resp = await _client.requestRaw(
        'POST',
        '/edit',
        body: {'op': chunk},
        abortTrigger: abortTrigger,
      );

      // Drain the response stream to prevent resource leak.
      resp.stream.drain().ignore();
    }
  }

  /// List all tags.
  Future<TagListResponse> listTags({Future<void>? abortTrigger}) {
    return _client.requestJson(
      'GET',
      '/tag',
      abortTrigger: abortTrigger,
      fromJson: TagListResponse.fromJson,
    );
  }

  /// Create a new tag.
  Future<Tag> createTag(TagCreateBody body, {Future<void>? abortTrigger}) {
    return _client.requestJson(
      'POST',
      '/tag',
      body: body.toJson(),
      abortTrigger: abortTrigger,
      fromJson: Tag.fromJson,
    );
  }

  /// Update an existing tag.
  Future<Tag> updateTag(
    int id,
    TagUpdateBody body, {
    Future<void>? abortTrigger,
  }) {
    return _client.requestJson(
      'PATCH',
      '/tag/$id',
      body: body.toJson(),
      abortTrigger: abortTrigger,
      fromJson: Tag.fromJson,
    );
  }

  /// Delete a tag by ID.
  Future<void> deleteTag(int id, {Future<void>? abortTrigger}) async {
    final resp = await _client.requestRaw(
      'DELETE',
      '/tag/$id',
      abortTrigger: abortTrigger,
    );

    // Drain the response stream to prevent resource leak.
    resp.stream.drain().ignore();
  }

  /// Get url for requesting image preview for a link.
  ///
  /// This does not download the image, just returns the URL. Mainly for use in `Image.network` or similar widgets.
  ///
  /// The URL still needs authentication headers. Pass in [headers] into the widget responsible for making the HTTP request.
  ///
  /// Use [type] to specify 'social' (default) for og:image/twitter:image or 'favicon' for site favicon.
  ///
  /// Use [dpr], [width], and [height] to request image with specific device pixel ratio and size.
  ///
  /// For transforming image format, use `Accept` header in the request.
  String imageUrl(
    String url, {
    String type = 'social',
    double? dpr,
    double? width,
    double? height,
  }) {
    final queryParameters = <String, String>{
      'url': url,
      'type': type,
      if (dpr != null) 'dpr': dpr.toString(),
      if (width != null) 'width': width.toString(),
      if (height != null) 'height': height.toString(),
    };

    final uri = Uri.parse(
      '$baseUrl/image',
    ).replace(queryParameters: queryParameters);

    return uri.toString();
  }
}
