import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @override
  void initState() {
    super.initState();

    _log('worker initState register observer and archive listener');
    WidgetsBinding.instance.addObserver(this);
    CustomTabsBridge.instance.initialize();
    _archiveActionSubscription = CustomTabsBridge.instance.archiveActions
        .listen((event) {
          _log('worker received archive event ${event.summary}');
          final queue = ref.read(editQueueProvider.notifier);
          queue.add(
            EditOp.setBool(
              id: event.linkId,
              field: EditOpBoolField.archive,
              value: true,
            ),
          );
          _log('worker queued archive edit ${event.summary}');
        });
    _log('worker drain on startup');
    unawaited(CustomTabsBridge.instance.drainPendingArchiveActions());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _log('worker lifecycle state=$state');
    if (state != AppLifecycleState.resumed) {
      return;
    }

    _log('worker drain on resume');
    unawaited(CustomTabsBridge.instance.drainPendingArchiveActions());
  }

  @override
  void dispose() {
    _log('worker dispose remove observer and cancel listener');
    WidgetsBinding.instance.removeObserver(this);
    _archiveActionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox.shrink();
  }

  static void _log(String message) {
    if (kDebugMode) {
      debugPrint('[ArchiveFlow] $message');
    }
  }
}
