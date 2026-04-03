import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ReselectNotifier extends ChangeNotifier {
  void notifyReselect() {
    notifyListeners();
  }
}

class ReselectScope extends InheritedNotifier<ReselectNotifier> {
  const ReselectScope({
    required ReselectNotifier super.notifier,
    required super.child,
    super.key,
  });

  static ReselectNotifier of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ReselectScope>();
    assert(scope != null, 'No ReselectScope found in context');
    return scope!.notifier!;
  }
}

/// Listen to reselect events from [ReselectNotifier].
///
/// Reselect means user tapping on selected icon in bottom navigation bar. Pages probably want to scroll to top
/// or refresh content when reselected.
class ReselectListener extends HookWidget {
  const ReselectListener({
    super.key,
    required this.onReselect,
    required this.child,
  });

  final VoidCallback onReselect;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final notifier = ReselectScope.of(context);

    useEffect(() {
      notifier.addListener(onReselect);
      return () => notifier.removeListener(onReselect);
    }, [notifier, onReselect]);

    return child;
  }
}
