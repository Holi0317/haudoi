import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Wrapper for [GestureDetector] that detects long-presses and provides
/// the position of the long-press in a [RelativeRect].
///
/// Typically used to show context menus via [showMenu] at the position of the
/// long-press.
class LongPressMenu extends HookWidget {
  const LongPressMenu({super.key, required this.child, this.onLongPress});

  final Widget child;
  final void Function(RelativeRect)? onLongPress;

  @override
  Widget build(BuildContext context) {
    final longPressPosition = useRef(Offset.zero);

    final on = useCallback(() async {
      if (onLongPress == null) {
        return;
      }

      await Feedback.forLongPress(context);
      if (!context.mounted) {
        return;
      }

      final position = RelativeRect.fromLTRB(
        longPressPosition.value.dx,
        longPressPosition.value.dy,
        MediaQuery.of(context).size.width - longPressPosition.value.dx,
        MediaQuery.of(context).size.height - longPressPosition.value.dy,
      );

      onLongPress?.call(position);
    }, [onLongPress, longPressPosition, context]);

    return GestureDetector(
      onLongPressDown: (details) {
        longPressPosition.value = details.globalPosition;
      },
      onLongPress: onLongPress == null ? null : on,
      child: child,
    );
  }
}
