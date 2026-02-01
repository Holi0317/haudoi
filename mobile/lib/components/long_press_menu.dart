import 'package:flutter/material.dart';

/// Wrapper for [GestureDetector] that detects long-presses and provides
/// the position of the long-press in a [RelativeRect].
///
/// Typically used to show context menus via [showMenu] at the position of the
/// long-press.
class LongPressMenu extends StatefulWidget {
  const LongPressMenu({super.key, required this.child, this.onLongPress});

  final Widget child;
  final void Function(RelativeRect)? onLongPress;

  @override
  State<LongPressMenu> createState() => _LongPressMenuState();
}

class _LongPressMenuState extends State<LongPressMenu> {
  Offset _longPressPosition = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressDown: (details) {
        _longPressPosition = details.globalPosition;
      },
      onLongPress: widget.onLongPress == null ? null : _onLongPress,
      child: widget.child,
    );
  }

  void _onLongPress() async {
    if (widget.onLongPress == null) {
      return;
    }

    await Feedback.forLongPress(context);
    if (!mounted) {
      return;
    }

    final position = RelativeRect.fromLTRB(
      _longPressPosition.dx,
      _longPressPosition.dy,
      MediaQuery.of(context).size.width - _longPressPosition.dx,
      MediaQuery.of(context).size.height - _longPressPosition.dy,
    );

    widget.onLongPress?.call(position);
  }
}
