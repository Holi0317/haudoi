import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:share_plus/share_plus.dart';

import '../components/selection_controller.dart';
import '../i18n/strings.g.dart';
import '../providers/sync/queue.dart';
import 'edit_op.dart';
import 'link.dart';
import 'link_action.dart';

extension LinkActionHandle on LinkAction {
  /// Create a [SlidableAction] for this action for use in flutter_slidable.
  ///
  /// [onPressed] will get called when the action is pressed.
  SlidableAction slideable(
    WidgetRef ref,
    SelectionController controller,
    Link link,
  ) {
    return SlidableAction(
      onPressed: (context) {
        handleOne(context, ref, controller, link);
      },
      backgroundColor: color,
      foregroundColor: color.computeLuminance() > 0.5
          ? Colors.black87
          : Colors.white,
      icon: icon,
      label: label,
    );
  }

  /// Whether this action supports bulk operations (multiple items).
  bool get supportsBulk {
    return switch (this) {
      LinkAction.share => false,
      _ => true,
    };
  }

  /// Handle this action for a single link.
  Future<void> handleOne(
    BuildContext context,
    WidgetRef ref,
    SelectionController controller,
    Link link,
  ) async {
    // Single-item only actions
    switch (this) {
      case LinkAction.share:
        await _shareLink(link);
        return;
      default:
        // Common actions that work on lists
        await _handleLinks(context, ref, [link]);
    }
  }

  /// Handle this action for given set of selections (bulk operation).
  ///
  /// After successful handling, this will clear the selection in [controller].
  /// Actions that don't support bulk operations will log a warning and do nothing.
  Future<void> handle(
    BuildContext context,
    WidgetRef ref,
    SelectionController controller,
  ) async {
    if (!supportsBulk) {
      throw StateError(
        'Action $this does not support bulk operations. Skipping.',
      );
    }

    final links = controller.value;
    if (links.isEmpty) {
      return;
    }

    final acted = await _handleLinks(context, ref, links);

    if (acted) {
      controller.clear();
    }
  }

  /// Internal implementation for handling actions on a list of links.
  /// Returns true if the action was performed, false if cancelled.
  Future<bool> _handleLinks(
    BuildContext context,
    WidgetRef ref,
    List<Link> links,
  ) async {
    return switch (this) {
      LinkAction.delete => _showDeleteDialog(context, ref, links),
      LinkAction.archive => _setBoolField(
        ref,
        links,
        EditOpBoolField.archive,
        true,
      ),
      LinkAction.unarchive => _setBoolField(
        ref,
        links,
        EditOpBoolField.archive,
        false,
      ),
      LinkAction.favorite => _setBoolField(
        ref,
        links,
        EditOpBoolField.favorite,
        true,
      ),
      LinkAction.unfavorite => _setBoolField(
        ref,
        links,
        EditOpBoolField.favorite,
        false,
      ),
      // These are handled separately and should never reach here
      LinkAction.share => throw StateError(
        'Action $this should not be handled by _handleLinks',
      ),
    };
  }
}

Future<bool> _showDeleteDialog(
  BuildContext context,
  WidgetRef ref,
  List<Link> links,
) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(t.editBar.deletePrompt(count: links.length)),
        content: SingleChildScrollView(
          child: ListBody(children: <Widget>[Text(t.editBar.deleteWarning)]),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.dialogs.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.dialogs.delete),
          ),
        ],
      );
    },
  );

  if (confirm != true) {
    return false;
  }

  final queue = ref.read(editQueueProvider.notifier);
  queue.addAll(links.map((link) => EditOp.delete(id: link.id)));

  return true;
}

Future<bool> _setBoolField(
  WidgetRef ref,
  List<Link> links,
  EditOpBoolField field,
  bool value,
) async {
  final queue = ref.read(editQueueProvider.notifier);
  queue.addAll(
    links.map(
      (link) => EditOp.setBool(id: link.id, field: field, value: value),
    ),
  );

  return true;
}

Future<void> _shareLink(Link link) async {
  final uri = Uri.parse(link.url);
  await SharePlus.instance.share(ShareParams(uri: uri));
}
