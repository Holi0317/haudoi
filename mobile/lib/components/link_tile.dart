import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/link.dart';
import '../models/link_action.dart';
import '../models/link_action_handle.dart';
import '../utils.dart';
import 'link_favicon.dart';
import 'link_image_preview.dart';
import 'long_press_menu.dart';
import 'selection_controller.dart';

/// A tile widget that displays a [Link] with actions.
///
/// WARNING: This does not expects [item.id] to change. Make sure to provide a key
/// if the item instance may change to a different link with the same id.
class LinkTile extends ConsumerStatefulWidget {
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
  ConsumerState<LinkTile> createState() => _LinkTileState();
}

class _LinkTileState extends ConsumerState<LinkTile>
    with TickerProviderStateMixin {
  late final controller = SlidableController(this);

  // FIXME: Handle url parsing error
  late final uri = Uri.parse(widget.item.url);

  bool get isSelecting => widget.controller.isSelecting;

  bool get isSelected => widget.controller.contains(widget.item.id);

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onSelectionChanged);
  }

  @override
  void didUpdateWidget(LinkTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onSelectionChanged);
      widget.controller.addListener(_onSelectionChanged);
    }

    // Close slidable when entering selection mode
    // Seems that disabling the slidable doesn't close it automatically
    if (widget.controller.isSelecting &&
        !oldWidget.controller.isSelecting &&
        controller.ratio != 0) {
      controller.close(duration: const Duration());
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSelectionChanged);
    controller.dispose();
    super.dispose();
  }

  void _onSelectionChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Slidable(
      key: ValueKey(widget.item.id),
      controller: controller,
      enabled: !isSelecting,

      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.2,

        children: [
          if (widget.item.favorite)
            LinkAction.unfavorite.slideable(ref, widget.controller, widget.item)
          else
            LinkAction.favorite.slideable(ref, widget.controller, widget.item),
        ],
      ),

      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        extentRatio: 0.4,

        dismissible: widget.dismissible && !widget.item.archive
            ? DismissiblePane(
                onDismissed: () => LinkAction.archive.handleOne(
                  context,
                  ref,
                  widget.controller,
                  widget.item,
                ),
              )
            : null,

        children: [
          // FIXME: Icon animation....?
          LinkAction.share.slideable(ref, widget.controller, widget.item),
          if (widget.item.archive)
            LinkAction.unarchive.slideable(ref, widget.controller, widget.item)
          else
            LinkAction.archive.slideable(ref, widget.controller, widget.item),
        ],
      ),

      child: LongPressMenu(
        onLongPress: isSelecting ? null : _showActionMenu,
        child: ListTile(
          title: Text(
            widget.item.title.isEmpty ? uri.toString() : widget.item.title,
          ),
          subtitle: Row(
            children: [
              LinkFavicon(item: widget.item),
              Flexible(
                child: Text(
                  uri.host,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(' • ${formatRelativeDate(widget.item.createdAt)}'),
              if (widget.item.favorite)
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Icon(
                    Icons.favorite,
                    color: Colors.pink,
                    size: theme.textTheme.bodyMedium!.fontSize,
                  ),
                ),

              if (widget.item.archive)
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Icon(
                    Icons.archive,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: theme.textTheme.bodyMedium!.fontSize,
                  ),
                ),
            ],
          ),
          selected: isSelected,
          selectedColor: theme.colorScheme.onSurface,
          selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.2),
          leading: LinkImagePreview(item: widget.item),
          trailing: isSelecting
              ? Checkbox(value: isSelected, onChanged: null)
              : null,
          onTap: _onTap,
        ),
      ),
    );
  }

  void _onTap() {
    if (isSelecting) {
      widget.controller.toggle(widget.item);
    } else {
      _open();
    }
  }

  Future<void> _open() async {
    // TODO(GH-16): Add action button in custom tabs. Might need to write native code for that.
    // See https://developer.chrome.com/docs/android/custom-tabs/guide-interactivity
    // For now open the drawer after opening the link for archive
    final opened = await launchUrl(
      uri,
      mode: LaunchMode.inAppBrowserView,
      webOnlyWindowName: "_blank",
    );

    if (!opened) {
      throw Exception('Could not launch $uri');
    }

    await controller.openEndActionPane();
  }

  Future<void> _showActionMenu(RelativeRect position) async {
    final action = await showMenu<LinkAction>(
      context: context,
      position: position,
      items: [
        if (widget.item.favorite)
          LinkAction.unfavorite
        else
          LinkAction.favorite,
        LinkAction.share,
        if (widget.item.archive) LinkAction.unarchive else LinkAction.archive,
        LinkAction.edit,
        LinkAction.delete,
        LinkAction.select,
      ].map((item) => item.popup()).toList(),
    );

    if (action == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    await action.handleOne(context, ref, widget.controller, widget.item);
  }
}
