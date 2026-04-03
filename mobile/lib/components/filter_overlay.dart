import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../models/search_query.dart';
import 'filter_form.dart';

/// A stateful overlay that displays a filter form below the app bar.
///
/// See [FilterOverlay.show] for opening the overlay.
///
/// Position of the overlay is pretty hard-coded. It assumes that the overlay
/// is shown right below an [AppBar] at the top of the screen.
class FilterOverlay extends HookWidget {
  const FilterOverlay({
    super.key,
    required this.query,
    required this.onQueryChanged,
    required this.onDismiss,
  });

  final SearchQuery query;
  final ValueChanged<SearchQuery> onQueryChanged;
  final VoidCallback onDismiss;

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

  @override
  Widget build(BuildContext context) {
    // We maintain a local copy of the query to ensure immediate UI updates
    // when the user interacts with the filter controls. This provides instant
    // visual feedback while the parent widget's state is being updated.
    final currentQuery = useState(query);
    final updateQuery = useCallback((SearchQuery newQuery) {
      currentQuery.value = newQuery;
      onQueryChanged(newQuery);
    }, [currentQuery, onQueryChanged]);

    final animationController = useAnimationController(
      duration: const Duration(milliseconds: 250),
    );
    final fadeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOut,
    );
    final slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    useEffect(() {
      // Start the show animation on mount
      animationController.forward();
      return null;
    }, []);

    final dismiss = useCallback(() async {
      await animationController.reverse();
      onDismiss();
    }, [animationController, onDismiss]);

    final top = kToolbarHeight + MediaQuery.of(context).padding.top;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          dismiss();
        }
      },
      child: Positioned.fill(
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // dismiss when tapping outside with fade animation
              FadeTransition(
                opacity: fadeAnimation,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: dismiss,
                  child: Container(color: Colors.black.withValues(alpha: 0.3)),
                ),
              ),
              // the filter form positioned right under AppBar with slide animation
              Positioned(
                top: top,
                left: 0,
                right: 0,
                child: SlideTransition(
                  position: slideAnimation,
                  child: Material(
                    elevation: 8,
                    color: Theme.of(context).cardColor,
                    child: FilterForm(
                      query: currentQuery.value.query,
                      order: currentQuery.value.order,
                      onQueryChanged: (value) {
                        updateQuery(currentQuery.value.copyWith(query: value));
                      },
                      onOrderChanged: (value) {
                        updateQuery(currentQuery.value.copyWith(order: value));
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
