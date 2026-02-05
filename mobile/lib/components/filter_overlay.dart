import 'package:flutter/material.dart';

import '../models/search_query.dart';
import 'filter_form.dart';

/// A stateful overlay that displays a filter form below the app bar.
///
/// See [FilterOverlay.show] for opening the overlay.
///
/// Position of the overlay is pretty hard-coded. It assumes that the overlay
/// is shown right below an [AppBar] at the top of the screen.
class FilterOverlay extends StatefulWidget {
  const FilterOverlay({
    super.key,
    required this.query,
    required this.onQueryChanged,
    required this.onDismiss,
  });

  final SearchQuery query;
  final ValueChanged<SearchQuery> onQueryChanged;
  final VoidCallback onDismiss;

  @override
  State<FilterOverlay> createState() => _FilterOverlayState();

  /// Show the filter overlay as an overlay entry.
  static void show(
    BuildContext context, {
    required SearchQuery query,
    required ValueChanged<SearchQuery> onQueryChanged,
  }) {
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return FilterOverlay(
          query: query,
          onQueryChanged: onQueryChanged,
          onDismiss: () => entry.remove(),
        );
      },
    );

    Overlay.of(context).insert(entry);
  }
}

class _FilterOverlayState extends State<FilterOverlay>
    with SingleTickerProviderStateMixin {
  // We maintain a local copy of the query to ensure immediate UI updates
  // when the user interacts with the filter controls. This provides instant
  // visual feedback while the parent widget's state is being updated.
  late SearchQuery _currentQuery;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _currentQuery = widget.query;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Start the show animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateQuery(SearchQuery newQuery) {
    setState(() {
      _currentQuery = newQuery;
    });
    widget.onQueryChanged(newQuery);
  }

  Future<void> _dismiss() async {
    await _animationController.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final top = kToolbarHeight + MediaQuery.of(context).padding.top;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _dismiss();
        }
      },
      child: Positioned.fill(
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // dismiss when tapping outside with fade animation
              FadeTransition(
                opacity: _fadeAnimation,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _dismiss,
                  child: Container(color: Colors.black.withValues(alpha: 0.3)),
                ),
              ),
              // the filter form positioned right under AppBar with slide animation
              Positioned(
                top: top,
                left: 0,
                right: 0,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Material(
                    elevation: 8,
                    color: Theme.of(context).cardColor,
                    child: FilterForm(
                      query: _currentQuery.query,
                      order: _currentQuery.order,
                      onQueryChanged: (value) {
                        _updateQuery(_currentQuery.copyWith(query: value));
                      },
                      onOrderChanged: (value) {
                        _updateQuery(_currentQuery.copyWith(order: value));
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
