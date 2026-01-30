import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../i18n/strings.g.dart';
import '../models/link_action.dart';
import '../models/link_action_handle.dart';
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
            onPressed: () => action.handle(context, ref, controller),
          ),

        if (menuActions.isNotEmpty)
          PopupMenuButton<LinkAction>(
            icon: const Icon(Icons.more_vert),
            tooltip: t.editBar.more,
            itemBuilder: (context) =>
                menuActions.map((action) => action.popup()).toList(),
            onSelected: (action) => action.handle(context, ref, controller),
          ),
      ],
    );
  }

  // Absolute no idea what this is. But required to satisfy Scaffold's appBar property.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
