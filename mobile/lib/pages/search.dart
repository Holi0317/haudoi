import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/edit_app_bar.dart';
import '../components/filter_overlay.dart';
import '../components/link_list.dart';
import '../components/reselect.dart';
import '../components/selection_controller.dart';
import '../i18n/strings.g.dart';
import '../models/link_action.dart';
import '../models/search_query.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = SelectionController();
  var query = const SearchQuery();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSelectionChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSelectionChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final PreferredSizeWidget appBar = !_controller.isSelecting
        ? AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: SizedBox(
              height: kToolbarHeight - 12,
              child: TextField(
                autofocus: true,
                focusNode: _focusNode,
                onChanged: (value) =>
                    setState(() => query = query.copyWith(query: value)),
                decoration: InputDecoration(
                  hintText: t.search.search,
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  suffixIcon: IconButton(
                    tooltip: t.search.filterTooltip,
                    icon: Icon(
                      Icons.filter_alt,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    onPressed: () => _openFilter(context),
                  ),
                ),
                textInputAction: TextInputAction.search,
              ),
            ),
          )
        : EditAppBar(
            controller: _controller,
            actions: [LinkAction.archive, LinkAction.favorite],
            menuActions: [
              LinkAction.unarchive,
              LinkAction.unfavorite,
              LinkAction.delete,
            ],
          );

    return ReselectListener(
      onReselect: () {
        _focusNode.requestFocus();
      },
      child: Scaffold(
        appBar: appBar,
        body: LinkList(query: query, controller: _controller),
      ),
    );
  }

  void _openFilter(BuildContext context) {
    FilterOverlay.show(
      context,
      query: query,
      onQueryChanged: (newQuery) {
        setState(() {
          query = newQuery;
        });
      },
    );
  }
}
