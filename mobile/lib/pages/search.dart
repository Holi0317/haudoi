import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../components/edit_app_bar.dart';
import '../components/filter_overlay.dart';
import '../components/link_list.dart';
import '../components/reselect.dart';
import '../components/selection_controller.dart';
import '../i18n/strings.g.dart';
import '../models/link_action.dart';
import '../models/search_query.dart';

class SearchPage extends HookWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    final focusNode = useFocusNode();

    final selectionCtl = useSelectionController();
    final isSelecting = useListenableSelector(
      selectionCtl,
      () => selectionCtl.isSelecting,
    );

    final query = useState(const SearchQuery());

    final textCtl = useTextEditingController();
    // Sync text controller to query state
    useEffect(() {
      query.value = query.value.copyWith(query: textCtl.text);
      return null;
    }, [textCtl.text]);

    final openFilter = useCallback(() {
      FilterOverlay.show(
        context,
        query: query.value,
        onQueryChanged: (newQuery) {
          query.value = newQuery;
          textCtl.text = newQuery.query ?? '';
        },
      );
    }, [query, textCtl, context]);

    final PreferredSizeWidget appBar = !isSelecting
        ? AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: SizedBox(
              height: kToolbarHeight - 12,
              child: TextField(
                autofocus: true,
                focusNode: focusNode,
                controller: textCtl,
                onChanged: (value) =>
                    query.value = query.value.copyWith(query: value),
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
                    onPressed: openFilter,
                  ),
                ),
                textInputAction: TextInputAction.search,
              ),
            ),
          )
        : EditAppBar(
            controller: selectionCtl,
            actions: [LinkAction.archive, LinkAction.favorite],
            menuActions: [
              LinkAction.unarchive,
              LinkAction.unfavorite,
              LinkAction.delete,
            ],
          );

    return ReselectListener(
      onReselect: focusNode.requestFocus,
      child: Scaffold(
        appBar: appBar,
        body: LinkList(query: query.value, controller: selectionCtl),
      ),
    );
  }
}
