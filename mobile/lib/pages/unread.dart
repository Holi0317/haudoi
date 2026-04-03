import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../components/edit_app_bar.dart';
import '../components/link_list.dart';
import '../components/reselect.dart';
import '../components/selection_controller.dart';
import '../i18n/strings.g.dart';
import '../models/link_action.dart';
import '../models/search_query.dart';
import '../providers/api/search.dart';
import '../providers/extensions.dart';

class UnreadPage extends HookConsumerWidget {
  const UnreadPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useSelectionController();
    final isSelecting = useListenableSelector(
      controller,
      () => controller.isSelecting,
    );

    final order = useState(SearchOrder.createdAtDesc);

    final unreadSearchQuery = SearchQuery(
      query: "archive:false",
      order: order.value,
    );

    final count = ref.watch(
      searchAppliedProvider(unreadSearchQuery).selectData((data) => data.count),
    );

    final PreferredSizeWidget appBar = !isSelecting
        ? AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: switch (count) {
              // FIXME: Count is inaccurate when there are pending edits in queue.
              AsyncValue(:final value?, hasValue: true) => Text(
                t.unread.title(count: value),
              ),
              _ => Text(t.nav.unread),
            },
            actions: [_sortAction(context, order)],
          )
        : EditAppBar(
            controller: controller,
            actions: [LinkAction.delete, LinkAction.archive],
          );

    return ReselectListener(
      onReselect: () {
        // FIXME(desktop): LinkList is probably isn't a primary scroller on desktop
        // See https://api.flutter.dev/flutter/widgets/PrimaryScrollController-class.html
        PrimaryScrollController.of(context).animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      },
      child: Scaffold(
        appBar: appBar,
        body: LinkList(
          query: unreadSearchQuery,
          dismissible: true,
          controller: controller,
        ),
      ),
    );
  }

  Widget _sortAction(BuildContext context, ValueNotifier<SearchOrder> order) {
    return IconButton(
      icon: Icon(
        order.value == SearchOrder.createdAtAsc
            ? Icons.arrow_upward
            : Icons.arrow_downward,
      ),
      tooltip: order.value == SearchOrder.createdAtAsc
          ? t.unread.toggleSortingAsc
          : t.unread.toggleSortingDesc,
      onPressed: () {
        order.value = order.value == SearchOrder.createdAtAsc
            ? SearchOrder.createdAtDesc
            : SearchOrder.createdAtAsc;
      },
    );
  }
}
