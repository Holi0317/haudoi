import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_query.freezed.dart';

/// Query on searching API
@freezed
abstract class SearchQuery with _$SearchQuery {
  const SearchQuery._();

  @Assert('limit >= 1 && limit <= 300', 'Limit must be between 1 and 300')
  const factory SearchQuery({
    /// DSL search query string. Empty string means no filters applied. See repository README.md for documentation.
    String? query,

    /// Cursor for pagination.
    /// null / empty string will be treated as noop.
    /// Note the client must keep other search parameters the same when paginating.
    String? cursor,

    /// Limit items to return.
    @Default(30) int limit,

    /// Order in result. Can only sort by created_at.
    @Default(SearchOrder.createdAtDesc) SearchOrder order,
  }) = _SearchQuery;

  Map<String, String> toMap() {
    final map = <String, String>{};

    if (query != null && query!.isNotEmpty) {
      map['query'] = query!;
    }

    if (cursor != null && cursor!.isNotEmpty) {
      map['cursor'] = cursor!;
    }

    map['limit'] = limit.toString();
    map['order'] = order.value;

    return map;
  }

  /// Parse a boolean field from the DSL query string.
  ///
  /// Returns `true`/`false` if the field is explicitly set in the query,
  /// `null` if the field is not mentioned (no filtering on this field).
  ///
  /// This parsing is quite naive and only checks for exact matches of
  /// `field:true` or `field:false` in the query string. Might give false positives
  /// if the field name is a substring of another field.
  bool? parseBool(String field) {
    final q = query;

    // `null` for not filtering on the field
    if (q == null) {
      return null;
    }

    if (q.contains("$field:true")) {
      return true;
    }

    if (q.contains("$field:false")) {
      return false;
    }

    // Field not mentioned in query.
    return null;
  }
}

enum SearchOrder {
  createdAtAsc('created_at_asc'),
  createdAtDesc('created_at_desc');

  const SearchOrder(this.value);

  final String value;
}
