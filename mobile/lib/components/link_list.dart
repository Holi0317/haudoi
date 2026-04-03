import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../models/link.dart';
import '../models/search_query.dart';
import '../providers/api/api.dart';
import '../providers/api/search.dart';
import 'link_tile.dart';
import 'link_tile_shimmer.dart';
import 'selection_controller.dart';

class LinkList extends HookConsumerWidget {
  const LinkList({
    super.key,
    required this.query,
    required this.controller,
    this.dismissible = false,
  });

  /// SearchQuery for the first page
  final SearchQuery query;

  /// Controller for managing selection state.
  final SelectionController controller;

  /// See [LinkTile.dismissible].
  final bool dismissible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cursors = useState(<String>[]);
    final state = ref.watch(searchPaginatedProvider(query, cursors.value));

    final isSelecting = useListenableSelector(
      controller,
      () => controller.isSelecting,
    );

    return PopScope(
      canPop: !isSelecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          controller.clear();
        }
      },
      child: RefreshIndicator(
        onRefresh: () async {
          cursors.value = [];
          // Invalidate all search provider. Might be invalidating too much but better sorry than stale.
          ref.invalidate(searchProvider);
        },
        child: PagedListView<String, Link>(
          state: state,
          fetchNextPage: () {
            if (state.isLoading) {
              return;
            }

            if (!state.hasNextPage) {
              return;
            }

            final nextCursor = state.keys!.last;
            if (nextCursor == "") {
              return;
            }

            cursors.value = List.unmodifiable([...cursors.value, nextCursor]);
          },
          builderDelegate: PagedChildBuilderDelegate(
            itemBuilder: (context, item, index) => LinkTile(
              key: ValueKey(item.id),
              item: item,
              dismissible: dismissible,
              controller: controller,
            ),
            animateTransitions: true,
            firstPageProgressIndicatorBuilder: _buildFirstPageLoadingIndicator,
            newPageProgressIndicatorBuilder: _buildNewPageLoadingIndicator,
          ),
        ),
      ),
    );
  }

  Widget _buildFirstPageLoadingIndicator(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 1.5,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 50,
        itemBuilder: (context, index) => const LinkTileShimmer(),
      ),
    );
  }

  Widget _buildNewPageLoadingIndicator(BuildContext context) {
    return Column(
      children: List.generate(3, (index) => const LinkTileShimmer()),
    );
  }
}
