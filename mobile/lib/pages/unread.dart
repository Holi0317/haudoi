import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/edit_app_bar.dart';
import '../components/link_list.dart';
import '../components/reselect.dart';
import '../components/selection_controller.dart';
import '../i18n/strings.g.dart';
import '../models/link_action.dart';
import '../models/search_query.dart';
import '../providers/api/search.dart';
import '../providers/extensions.dart';

class UnreadPage extends ConsumerStatefulWidget {
  const UnreadPage({super.key});

  @override
  ConsumerState<UnreadPage> createState() => _UnreadPageState();
}

class _UnreadPageState extends ConsumerState<UnreadPage> {
  final _controller = SelectionController();
  SearchOrder _order = SearchOrder.createdAtDesc;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSelectionChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSelectionChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final unreadSearchQuery = SearchQuery(archive: false, order: _order);

    final count = ref.watch(
      searchAppliedProvider(unreadSearchQuery).selectData((data) => data.count),
    );

    final PreferredSizeWidget appBar = !_controller.isSelecting
        ? AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: switch (count) {
              // FIXME: Count is inaccurate when there are pending edits in queue.
              AsyncValue(:final value?, hasValue: true) => Text(
                t.unread.title(count: value),
              ),
              _ => Text(t.nav.unread),
            },
            actions: [_sortAction(context)],
          )
        : EditAppBar(
            controller: _controller,
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
          controller: _controller,
        ),
      ),
    );
  }

  Widget _sortAction(BuildContext context) {
    return IconButton(
      icon: Icon(
        _order == SearchOrder.createdAtAsc
            ? Icons.arrow_upward
            : Icons.arrow_downward,
      ),
      tooltip: _order == SearchOrder.createdAtAsc
          ? t.unread.toggleSortingAsc
          : t.unread.toggleSortingDesc,
      onPressed: () {
        setState(() {
          _order = _order == SearchOrder.createdAtAsc
              ? SearchOrder.createdAtDesc
              : SearchOrder.createdAtAsc;
        });
      },
    );
  }
}
