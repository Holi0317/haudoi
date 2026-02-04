import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/edit_op.dart';
import '../../models/link.dart';
import '../../models/search_query.dart';
import '../../models/search_response.dart';
import '../sync/queue.dart';
import 'api.dart';

part 'search.g.dart';

/// Combines [search] with [EditQueue] to apply pending edits to search results.
@riverpod
AsyncValue<SearchResponse> searchApplied(Ref ref, SearchQuery query) {
  // We **cannot** have async gap here. Riverpod will move our state to loading when
  // refreshing. While that won't really flicker in the UI, flutter_slidable will be unhappy
  // about that because the dismissed item is still in the list on the next frame.
  // Async gap will cause the items get removed on 2nd frame instead.

  final response = ref.watch(searchProvider(query));
  final queue = ref.watch(editQueueByIdProvider);

  return response.whenData((resp) {
    final items = resp.data.items
        .map((link) {
          final edits = (queue[link.id] ?? const [])
              .where(
                (op) =>
                    op.appliedAt == null ||
                    op.appliedAt!.isAfter(resp.timestamp),
              )
              .toList();

          return link.applyEdits(edits);
        })
        .nonNulls
        .where((link) => link.matchesQuery(query))
        .toList();

    return resp.data.copyWith(items: items);
  });
}

extension on Link {
  /// Applies a list of edit operations [EditOp] to this [Link] and returns applied result as a copy.
  ///
  /// If a delete operation is found, returns null. You might want to filter out nulls after applying edits.
  Link? applyEdits(List<EditOp> ops) {
    if (ops.isEmpty) {
      return this;
    }

    var result = this;

    for (var op in ops) {
      // Do ID check before the switch case so that dart can catch the expression
      // when we add more EditOp types in the future.
      //
      // This case should never happen since we filter by ID when building the map.
      if (op.maybeId != id) {
        continue;
      }

      switch (op) {
        case EditOpSetBool():
          result = result.copyWith(
            favorite: op.field == EditOpBoolField.favorite
                ? op.value
                : result.favorite,
            archive: op.field == EditOpBoolField.archive
                ? op.value
                : result.archive,
          );
        case EditOpSetString():
          result = result.copyWith(note: op.value);
        case EditOpDelete():
          return null;
        case EditOpInsert():
        // Insert ops are not applicable to existing links
      }
    }

    return result;
  }

  /// Checks if this link matches the given [SearchQuery].
  ///
  /// Note: This only checks favorite and archive fields, which are the only editable fields by [EditOp].
  bool matchesQuery(SearchQuery query) {
    final favoriteQ = query.parseBool('favorite');
    if (favoriteQ != null && favorite != favoriteQ) {
      return false;
    }

    final archiveQ = query.parseBool('archive');
    if (archiveQ != null && archive != archiveQ) {
      return false;
    }

    // Add more field checks as necessary
    return true;
  }
}

/// Search and paginate result. Returning PagingState for infinite_scroll_pagination package.
///
/// This uses [searchApplied] to get search results, with edits from [EditQueue] applied to the result.
///
/// [query] is the query for first page. After that, this provider will fetch pages with given [cursors] parameter.
/// Widget should keep a list of cursors that needs to be fetched. You can get the cursor from `state.keys!.last`.
/// Make sure to check that cursor as non-empty string. The page might be in loading or error state and we use empty
/// string here as filler. This provider will assert that all cursors are non-empty string.
///
/// WARN: [cursors] list must be immutable for riverpod's change detection to work.
@riverpod
PagingState<String, Link> searchPaginated(
  Ref ref,
  SearchQuery query,
  List<String> cursors,
) {
  assert(
    cursors.every((c) => c.isNotEmpty),
    "Cursors must not be empty string.",
  );

  final queries = [
    query,
    ...cursors.map((cursor) => query.copyWith(cursor: cursor)),
  ];

  final values = queries
      .map((q) => ref.watch(searchAppliedProvider(q)))
      .toList();

  final loaded = values.map((v) => v.value).nonNulls.toList();

  return PagingState(
    isLoading: values.any((v) => v.isLoading),
    hasNextPage: values.last.value?.hasMore ?? false,
    error: values.where((v) => v.error != null).firstOrNull?.error,
    // pages and keys need to be null for first page loading state
    pages: loaded.isEmpty ? null : loaded.map((v) => v.items).toList(),
    keys: loaded.isEmpty ? null : loaded.map(((v) => v.cursor ?? '')).toList(),
  );
}
