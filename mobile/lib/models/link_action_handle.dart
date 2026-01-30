import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:logging/logging.dart';
import 'package:share_plus/share_plus.dart';

import '../components/selection_controller.dart';
import '../i18n/strings.g.dart';
import '../providers/sync/queue.dart';
import 'edit_op.dart';
import 'link.dart';
import 'link_action.dart';

final _logger = Logger('LinkActionHandle');

extension LinkActionHandle on LinkAction {
  /// Create a [SlidableAction] for this action for use in flutter_slidable.
  ///
  /// [onPressed] will get called when the action is pressed.
  SlidableAction slideable(WidgetRef ref, Link link) {
    return SlidableAction(
      onPressed: (context) {
        handleOne(context, ref, link);
      },
      backgroundColor: color,
      foregroundColor: color.computeLuminance() > 0.5
          ? Colors.black87
          : Colors.white,
      icon: icon,
      label: label,
    );
  }

  /// Handle this action for a single link.
  Future<void> handleOne(BuildContext context, WidgetRef ref, Link link) async {
    // Fake controller for reusing some action handlers.
    final controller = SelectionController();
    controller.select(link);

    await handle(context, ref, controller);
  }

  /// Handle this action for given set of selections.
  ///
  /// After successful handling, this will clear the selection in [controller].
  Future<void> handle(
    BuildContext context,
    WidgetRef ref,
    SelectionController controller,
  ) async {
    final acted = await switch (this) {
      LinkAction.delete => _showDeleteDialog(context, ref, controller),
      LinkAction.archive => _edit(
        ref,
        controller,
        EditOpBoolField.archive,
        true,
      ),
      LinkAction.unarchive => _edit(
        ref,
        controller,
        EditOpBoolField.archive,
        false,
      ),
      LinkAction.favorite => _edit(
        ref,
        controller,
        EditOpBoolField.favorite,
        true,
      ),
      LinkAction.unfavorite => _edit(
        ref,
        controller,
        EditOpBoolField.favorite,
        false,
      ),
      LinkAction.share => _share(controller),
    };

    if (acted) {
      controller.clear();
    }
  }
}

Future<bool> _showDeleteDialog(
  BuildContext context,
  WidgetRef ref,
  SelectionController controller,
) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(t.editBar.deletePrompt(count: controller.value.length)),
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
  queue.addAll(controller.value.map((link) => EditOp.delete(id: link.id)));

  return true;
}

Future<bool> _edit(
  WidgetRef ref,
  SelectionController controller,
  EditOpBoolField field,
  bool value,
) async {
  final queue = ref.read(editQueueProvider.notifier);
  queue.addAll(
    controller.value.map(
      (link) => EditOp.setBool(id: link.id, field: field, value: value),
    ),
  );

  return true;
}

Future<bool> _share(SelectionController controller) async {
  // If multiple items are selected, do nothing.
  if (controller.value.length != 1) {
    _logger.warning(
      "Tried to show edit page with multiple selection. Skipping action.",
    );

    return false;
  }

  final uri = Uri.parse(controller.value.first.url);

  await SharePlus.instance.share(ShareParams(uri: uri));

  return true;
}
