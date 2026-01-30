import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../i18n/strings.g.dart';
import '../models/edit_op.dart';
import '../models/link_action.dart';
import '../providers/sync/queue.dart';
import 'selection_controller.dart';

/// [AppBar] used in selection mode
class EditAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const EditAppBar({
    super.key,
    this.actions = const [],
    this.menuActions = const [],
    required this.controller,
  });

  /// List of actions to show on app bar
  final List<LinkAction> actions;

  /// List of actions to show in overflow menu
  final List<LinkAction> menuActions;

  /// Controller for managing selection state.
  final SelectionController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text(t.editBar.title(count: controller.length)),
      leading: IconButton(
        icon: const Icon(Icons.close),
        tooltip: t.editBar.cancel,
        onPressed: controller.clear,
      ),
      actions: [
        for (final action in actions)
          IconButton(
            icon: Icon(action.icon),
            tooltip: action.label,
            onPressed: () => _handleAction(context, ref, action),
          ),

        if (menuActions.isNotEmpty)
          PopupMenuButton<LinkAction>(
            icon: const Icon(Icons.more_vert),
            tooltip: t.editBar.more,
            itemBuilder: (context) =>
                menuActions.map((action) => action.popup()).toList(),
            onSelected: (action) => _handleAction(context, ref, action),
          ),
      ],
    );
  }

  // Absolute no idea what this is. But required to satisfy Scaffold's appBar property.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  void _handleAction(BuildContext context, WidgetRef ref, LinkAction action) {
    switch (action) {
      case LinkAction.delete:
        _showDeleteDialog(context, ref);
      case LinkAction.archive:
        _edit(ref, EditOpBoolField.archive, true);
      case LinkAction.unarchive:
        _edit(ref, EditOpBoolField.archive, false);
      case LinkAction.favorite:
        _edit(ref, EditOpBoolField.favorite, true);
      case LinkAction.unfavorite:
        _edit(ref, EditOpBoolField.favorite, false);
      case LinkAction.share:
        throw UnimplementedError();
    }
  }

  Future<void> _showDeleteDialog(BuildContext context, WidgetRef ref) async {
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
      return;
    }

    final queue = ref.read(editQueueProvider.notifier);
    queue.addAll(controller.value.map((id) => EditOp.delete(id: id)));

    controller.clear();
  }

  void _edit(WidgetRef ref, EditOpBoolField field, bool value) {
    final queue = ref.read(editQueueProvider.notifier);
    queue.addAll(
      controller.value.map(
        (id) => EditOp.setBool(id: id, field: field, value: value),
      ),
    );

    controller.clear();
  }
}
