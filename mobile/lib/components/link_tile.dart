import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../hooks/slidable.dart';
import '../models/link.dart';
import '../models/link_action.dart';
import '../models/link_action_handle.dart';
import '../platform/custom_tabs_bridge.dart';
import 'link_image_preview.dart';
import 'link_tile_subtitle.dart';
import 'long_press_menu.dart';
import 'selection_controller.dart';

/// A tile widget that displays a [Link] with actions.
///
/// WARNING: This does not expects [item.id] to change. Make sure to provide a key
/// if the item instance may change to a different link with the same id.
class LinkTile extends HookConsumerWidget {
  const LinkTile({
    super.key,
    required this.item,
    required this.controller,
    this.dismissible = false,
  });

  final Link item;
  final SelectionController controller;

  /// If true, the tile can be dismissed and archived by swiping.
  ///
  /// IMPORTANT: flutter_slidable expects the item will get removed from the list after dismiss.
  /// Parent widget must make sure they have `archive: true` in `SearchQuery` to prevent the item from re-appearing.
  /// Failing to do so will cause error in runtime.
  final bool dismissible;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slidableController = useSlidableController();
    final uri = useMemoized(() => Uri.parse(item.url), [item.url]);

    final isSelected = useListenableSelector(
      controller,
      () => controller.contains(item.id),
    );
    final isSelecting = useListenableSelector(
      controller,
      () => controller.isSelecting,
    );

    final onLongPress = isSelecting
        ? null
        : (RelativeRect position) => _showActionMenu(context, ref, position);

    void onTap() {
      if (isSelecting) {
        controller.toggle(item);
      } else {
        _open(uri);
      }
    }

    final theme = Theme.of(context);

    return Slidable(
      key: ValueKey(item.id),
      controller: slidableController,
      enabled: !isSelecting,

      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.2,

        children: [LinkAction.select.slideable(ref, controller, item)],
      ),

      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.4,

        dismissible: dismissible && !item.archive
            ? DismissiblePane(
                onDismissed: () => LinkAction.archive.handleOne(
                  context,
                  ref,
                  controller,
                  item,
                ),
              )
            : null,

        children: [
          // FIXME: Icon animation....?
          LinkAction.share.slideable(ref, controller, item),
          if (item.archive)
            LinkAction.unarchive.slideable(ref, controller, item)
          else
            LinkAction.archive.slideable(ref, controller, item),
        ],
      ),

      child: LongPressMenu(
        onLongPress: onLongPress,
        child: ListTile(
          horizontalTitleGap: 0,
          minLeadingWidth: 0,
          title: Text(item.title.isEmpty ? uri.toString() : item.title),
          subtitle: LinkTileSubtitle(item: item),
          selected: isSelected,
          selectedColor: theme.colorScheme.onSurface,
          selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.2),
          leading: LinkImagePreview(
            item: item,
            padding: const EdgeInsets.only(right: 16.0),
          ),
          trailing: isSelecting
              ? Checkbox(value: isSelected, onChanged: null)
              : null,
          onTap: onTap,
        ),
      ),
    );
  }

  Future<void> _open(Uri uri) async {
    final opened = await CustomTabsBridge.instance.openLink(
      uri: uri,
      linkId: item.id,
      archiveButton: !item.archive,
    );

    if (!opened) {
      throw Exception('Could not launch $uri');
    }
  }

  Future<void> _showActionMenu(
    BuildContext context,
    WidgetRef ref,
    RelativeRect position,
  ) async {
    final action = await showMenu<LinkAction>(
      context: context,
      position: position,
      items: [
        if (item.favorite) LinkAction.unfavorite else LinkAction.favorite,
        LinkAction.share,
        if (item.archive) LinkAction.unarchive else LinkAction.archive,
        LinkAction.edit,
        LinkAction.delete,
        LinkAction.select,
      ].map((item) => item.popup()).toList(),
    );

    if (action == null) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    await action.handleOne(context, ref, controller, item);
  }
}
