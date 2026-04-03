import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

/// Create and dispose a [SlidableController] for the widget.
SlidableController useSlidableController() {
  final ticker = useSingleTickerProvider();
  final slidableController = useMemoized(() => SlidableController(ticker), [
    ticker,
  ]);

  useEffect(() {
    return slidableController.dispose;
  }, [slidableController]);

  return slidableController;
}
