import 'dart:convert';
import 'dart:io' show Cookie;

import 'package:collection/collection.dart';
import 'package:event_bus/event_bus.dart';
import 'package:http/http.dart' as http;

import '../models/edit_op.dart';
import '../models/link.dart';
import '../models/search_query.dart';
import '../models/search_response.dart';
import '../models/server_info.dart';
import '../models/tag.dart';

class RequestException implements Exception {
  final String path;
  final String method;
  final int statusCode;
  final String body;

  const RequestException({
    required this.path,
    required this.method,
    required this.statusCode,
    required this.body,
  });

  @override
  String toString() {
    return "RequestException for $method $path $statusCode: $body";
  }
}

/// Binding for server API.
class ApiRepository {
  final http.Client _client;
  final String baseUrl;
  final String _authToken;

  /// Event bus for emitting failed request.
  ///
  /// For use of global event handling, e.g. logging out user on 401 Unauthorized.
  ///
  /// For http level error (by status code), [RequestException] will be emitted.
  /// For transport level error (eg server unreachable), [http.ClientException] will be emitted.
  /// JSON parsing error will not be emitted.
  final eventBus = EventBus();

  /// HTTP headers for requests.
  late final Map<String, String> headers = Map.unmodifiable({
    if (_authToken.isNotEmpty)
      'cookie': Cookie('__Host-haudoi-auth', _authToken).toString(),
    // FIXME: Add version
    'user-agent': 'haudoi-mobile',
  });

  ApiRepository({
    required http.Client transport,
    required this.baseUrl,
    required String authToken,
  }) : _authToken = authToken,
       _client = transport;

  /// Send a request to the server.
  ///
  /// This will emit a [http.ClientException] if there is a transport-level
  /// failure when communication with the server. For example, if the server could
  /// not be reached.
  ///
  /// Throws a [RequestException] if the response got a non-success (>= 400) status code.
  ///
  /// [path] should begin with a `/`.
  ///
  /// If [body] is provided, request will be sent as json. Do not provide [body]
  /// on GET request.
  Future<http.StreamedResponse> _request(
    String method,
    String path, {
    Object? body,
    Map<String, String>? queryParameters,
    Future<void>? abortTrigger,
  }) async {
    assert(path.startsWith('/'));

    final url = Uri.parse(
      '$baseUrl$path',
    ).replace(queryParameters: queryParameters);

    final req = http.AbortableRequest(method, url, abortTrigger: abortTrigger);
    req.headers.addAll(headers);

    if (body != null) {
      assert(method.toLowerCase() != 'get', 'Get request cannot contain body');

      req.headers['content-type'] = 'application/json';
      req.body = jsonEncode(body);
    }

    try {
      final resp = await _client.send(req);

      if (resp.statusCode >= 400) {
        final respBody = await resp.stream.bytesToString();
        throw RequestException(
          method: method,
          path: path,
          body: respBody,
          statusCode: resp.statusCode,
        );
      }

      return resp;
    } catch (err) {
      eventBus.fire(err);
      rethrow;
    }
  }

  Future<ServerInfo> info({Future<void>? abortTrigger}) async {
    final resp = await _request('GET', '/', abortTrigger: abortTrigger);

    final responseBodyString = await resp.stream.bytesToString();
    final jsonResponse = jsonDecode(responseBodyString);
    return ServerInfo.fromJson(jsonResponse as Map<String, dynamic>);
  }

  /// Search (or list) links from server.
  Future<SearchResponse> search(
    SearchQuery query, {
    Future<void>? abortTrigger,
  }) async {
    final resp = await _request(
      'GET',
      '/search',
      queryParameters: query.toMap(),
      abortTrigger: abortTrigger,
    );

    final responseBodyString = await resp.stream.bytesToString();
    final jsonResponse = jsonDecode(responseBodyString);
    return SearchResponse.fromJson(jsonResponse as Map<String, dynamic>);
  }

  /// Get a single link from server.
  ///
  /// If the item ID is not found, a [RequestException] with `statusCode == 404`
  /// will be thrown.
  Future<Link> getItem(int id, {Future<void>? abortTrigger}) async {
    final resp = await _request('GET', '/item/$id', abortTrigger: abortTrigger);

    final responseBodyString = await resp.stream.bytesToString();
    final jsonResponse = jsonDecode(responseBodyString);
    return Link.fromJson(jsonResponse as Map<String, dynamic>);
  }

  /// Edit or insert links.
  Future<void> edit(List<EditOp> op, {Future<void>? abortTrigger}) async {
    // Each batch only supports at most 30 items
    for (final chunk in op.slices(30)) {
      await _request(
        'POST',
        '/edit',
        body: {'op': chunk},
        abortTrigger: abortTrigger,
      );
    }
  }

  /// List all tags.
  Future<TagListResponse> listTags({Future<void>? abortTrigger}) async {
    final resp = await _request('GET', '/tag', abortTrigger: abortTrigger);

    final responseBodyString = await resp.stream.bytesToString();
    final jsonResponse = jsonDecode(responseBodyString);
    return TagListResponse.fromJson(jsonResponse as Map<String, dynamic>);
  }

  /// Create a new tag.
  Future<Tag> createTag(
    TagCreateBody body, {
    Future<void>? abortTrigger,
  }) async {
    final resp = await _request(
      'POST',
      '/tag',
      body: body.toJson(),
      abortTrigger: abortTrigger,
    );

    final responseBodyString = await resp.stream.bytesToString();
    final jsonResponse = jsonDecode(responseBodyString);
    return Tag.fromJson(jsonResponse as Map<String, dynamic>);
  }

  /// Update an existing tag.
  Future<Tag> updateTag(
    int id,
    TagUpdateBody body, {
    Future<void>? abortTrigger,
  }) async {
    final resp = await _request(
      'PATCH',
      '/tag/$id',
      body: body.toJson(),
      abortTrigger: abortTrigger,
    );

    final responseBodyString = await resp.stream.bytesToString();
    final jsonResponse = jsonDecode(responseBodyString);
    return Tag.fromJson(jsonResponse as Map<String, dynamic>);
  }

  /// Delete a tag by ID.
  Future<void> deleteTag(int id, {Future<void>? abortTrigger}) async {
    await _request('DELETE', '/tag/$id', abortTrigger: abortTrigger);
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
