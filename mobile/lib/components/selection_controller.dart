import 'package:flutter/foundation.dart';

import '../models/link.dart';

/// A controller for managing selection state of link items.
///
/// This controller is similar to [TextEditingController] in that it holds
/// state and notifies listeners when the state changes. It should be created
/// in the parent widget's state and disposed when no longer needed.
///
/// The controller holds full [Link] instances and deduplicates based on link ID.
///
/// This doesn't handle updates on [Link] changes. It is assumed that selected links properties remain
/// unchanged for the duration of their selection.
///
/// Example usage:
/// ```dart
/// class _MyWidgetState extends State<MyWidget> {
///   final _selectionController = SelectionController();
///
///   @override
///   void dispose() {
///     _selectionController.dispose();
///     super.dispose();
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return LinkList(
///       selectionController: _selectionController,
///       // ...
///     );
///   }
/// }
/// ```
class SelectionController extends ChangeNotifier {
  SelectionController();

  List<Link> _selection = const [];

  /// The current selection as a list of [Link] objects.
  List<Link> get value => List.unmodifiable(_selection);

  /// Whether any items are currently selected.
  bool get isSelecting => _selection.isNotEmpty;

  /// The number of selected items.
  int get length => _selection.length;

  /// Returns true if a link with the given [id] is selected.
  bool contains(int id) => _selection.any((link) => link.id == id);

  /// Selects a link. Does nothing if a link with the same ID is already selected.
  void select(Link link) {
    if (contains(link.id)) return;
    _selection = [..._selection, link];
    notifyListeners();
  }

  /// Deselects a link by ID.
  void deselect(Link link) {
    if (!contains(link.id)) return;
    _selection = _selection.where((that) => that.id != link.id).toList();
    notifyListeners();
  }

  /// Toggles the selection state of a link.
  void toggle(Link link) {
    if (contains(link.id)) {
      deselect(link);
    } else {
      select(link);
    }
  }

  /// Clears all selections.
  void clear() {
    if (_selection.isEmpty) return;
    _selection = const [];
    notifyListeners();
  }
}
