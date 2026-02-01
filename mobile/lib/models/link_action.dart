import 'package:flutter/material.dart';

import '../i18n/strings.g.dart';

/// Enum of actions that can be performed on a link.
enum LinkAction {
  // FIXME: Fix the colors. They are super ugly right now

  archive(Icons.archive, Colors.lime),
  unarchive(Icons.unarchive, Colors.lime),
  favorite(Icons.favorite, Colors.lightBlue),
  unfavorite(Icons.favorite_border, Colors.lightBlue),
  share(Icons.share, Colors.amber),
  delete(Icons.delete, Colors.red);

  final IconData icon;
  final Color color;

  const LinkAction(this.icon, this.color);

  /// Get the localized label for this action.
  /// Must run in a context where [Translations] is available.
  String get label {
    return t.linkAction[name]!;
  }

  /// Create a [PopupMenuItem] for this action for use in menus.
  PopupMenuItem<LinkAction> popup() {
    return PopupMenuItem<LinkAction>(
      value: this,
      child: ListTile(leading: Icon(icon), title: Text(label)),
    );
  }
}
