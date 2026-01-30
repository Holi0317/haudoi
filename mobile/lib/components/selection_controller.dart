import 'package:flutter/foundation.dart';

/// A controller for managing selection state of link items.
///
/// This controller is similar to [TextEditingController] in that it holds
/// state and notifies listeners when the state changes. It should be created
/// in the parent widget's state and disposed when no longer needed.
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

  Set<int> _selection = const {};

  /// The current selection as an unmodifiable set of IDs.
  Set<int> get value => _selection;

  /// Whether any items are currently selected.
  bool get isSelecting => _selection.isNotEmpty;

  /// The number of selected items.
  int get length => _selection.length;

  /// Returns true if the given [id] is selected.
  bool contains(int id) => _selection.contains(id);

  /// Selects a single item by ID.
  void select(int id) {
    if (_selection.contains(id)) return;
    _selection = {..._selection, id};
    notifyListeners();
  }

  /// Deselects a single item by ID.
  void deselect(int id) {
    if (!_selection.contains(id)) return;
    final next = _selection.toSet();
    next.remove(id);
    _selection = Set.unmodifiable(next);
    notifyListeners();
  }

  /// Toggles the selection state of an item.
  void toggle(int id) {
    if (_selection.contains(id)) {
      deselect(id);
    } else {
      select(id);
    }
  }

  /// Sets the selection state of an item.
  void setSelected(int id, bool selected) {
    if (selected) {
      select(id);
    } else {
      deselect(id);
    }
  }

  /// Clears all selections.
  void clear() {
    if (_selection.isEmpty) return;
    _selection = const {};
    notifyListeners();
  }
}
