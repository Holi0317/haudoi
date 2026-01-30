import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../models/link.dart';
import '../models/search_query.dart';
import '../providers/api/api.dart';
import '../providers/api/search.dart';
import 'link_tile.dart';
import 'link_tile_shimmer.dart';
import 'selection_controller.dart';

class LinkList extends ConsumerStatefulWidget {
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
  ConsumerState<LinkList> createState() => _LinkListState();
}

class _LinkListState extends ConsumerState<LinkList> {
  List<String> _cursors = const [];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onSelectionChanged);
  }

  @override
  void didUpdateWidget(covariant LinkList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onSelectionChanged);
      widget.controller.addListener(_onSelectionChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSelectionChanged);
    super.dispose();
  }

  void _onSelectionChanged() {
    setState(() {});
  }

  void _fetchNextPage(PagingState<String, Link> state) {
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

    setState(() {
      _cursors = List.unmodifiable([..._cursors, nextCursor]);
    });
  }

  void _refresh() {
    setState(() {
      _cursors = const [];
    });

    // Invalidate all search provider. Might be invalidating too much but better sorry than stale.
    ref.invalidate(searchProvider);
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchPaginatedProvider(widget.query, _cursors));

    return PopScope(
      canPop: !widget.controller.isSelecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          widget.controller.clear();
        }
      },
      child: RefreshIndicator(
        onRefresh: () async {
          _refresh();
        },
        child: PagedListView<String, Link>(
          state: state,
          fetchNextPage: () {
            _fetchNextPage(state);
          },
          builderDelegate: PagedChildBuilderDelegate(
            itemBuilder: (context, item, index) => LinkTile(
              key: ValueKey(item.id),
              item: item,
              dismissible: widget.dismissible,
              selecting: widget.controller.isSelecting,
              selected: widget.controller.contains(item.id),
              onSelect: (selected) {
                if (selected) {
                  widget.controller.select(item);
                } else {
                  widget.controller.deselect(item);
                }
              },
            ),
            animateTransitions: true,
            firstPageProgressIndicatorBuilder: _buildFirstPageLoadingIndicator,
            newPageProgressIndicatorBuilder: _buildNewPageLoadingIndicator,
          ),
        ),
      ),
    );
  }
}
