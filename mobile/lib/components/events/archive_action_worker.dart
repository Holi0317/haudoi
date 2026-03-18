import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../../models/edit_op.dart';
import '../../platform/custom_tabs_bridge.dart';
import '../../providers/sync/queue.dart';

/// Listens to Android custom tabs archive callbacks and queues archive edits.
class ArchiveActionWorkerWidget extends ConsumerStatefulWidget {
  const ArchiveActionWorkerWidget({super.key, this.child});

  final Widget? child;

  @override
  ConsumerState<ArchiveActionWorkerWidget> createState() =>
      _ArchiveActionWorkerWidgetState();
}

class _ArchiveActionWorkerWidgetState
    extends ConsumerState<ArchiveActionWorkerWidget>
    with WidgetsBindingObserver {
  StreamSubscription<ArchiveActionEvent>? _archiveActionSubscription;

  final _logger = Logger("ArchiveActionWorkerWidget");

  @override
  void initState() {
    super.initState();

    _logger.fine('worker initState register observer and archive listener');
    WidgetsBinding.instance.addObserver(this);
    CustomTabsBridge.instance.initialize();
    _archiveActionSubscription = CustomTabsBridge.instance.archiveActions
        .listen((event) {
          _logger.info('worker received archive event ${event.summary}');
          final queue = ref.read(editQueueProvider.notifier);
          queue.add(
            EditOp.setBool(
              id: event.linkId,
              field: EditOpBoolField.archive,
              value: true,
            ),
          );
          _logger.fine('worker queued archive edit ${event.summary}');
        });

    // Drain once on mount so cold starts and process restarts consume any event the
    // Android receiver already persisted. See ArchiveActionSupport.kt for the flow.
    _logger.fine('worker drain on startup');
    unawaited(CustomTabsBridge.instance.drainPendingArchiveActions());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _logger.fine('worker lifecycle state=$state');
    if (state != AppLifecycleState.resumed) {
      return;
    }

    // Drain again when the app is foregrounded after the custom tab or deep link returns.
    _logger.fine('worker drain on resume');
    unawaited(CustomTabsBridge.instance.drainPendingArchiveActions());
  }

  @override
  void dispose() {
    _logger.fine('worker dispose remove observer and cancel listener');
    WidgetsBinding.instance.removeObserver(this);
    _archiveActionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox.shrink();
  }
}
