import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';

import '../../models/edit_op.dart';
import '../../platform/custom_tabs_bridge.dart';
import '../../providers/sync/queue.dart';

/// Listens to Android custom tabs archive callbacks and queues archive edits.
class ArchiveActionWorkerWidget extends HookConsumerWidget {
  final _logger = Logger("ArchiveActionWorkerWidget");

  ArchiveActionWorkerWidget({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> drain() async {
      _logger.fine('drain pending archive actions');
      final events = await CustomTabsBridge.instance
          .drainPendingArchiveActions();

      final ops = events.map(
        (event) => EditOp.setBool(
          id: event.linkId,
          field: EditOpBoolField.archive,
          value: true,
        ),
      );

      final queue = ref.read(editQueueProvider.notifier);
      queue.addAll(ops);
    }

    // Drain once on mount so cold starts and process any pending events.
    useEffect(() {
      drain();
      return null;
    }, []);

    // Drain whenever the app is back on foreground, which could be user closing the custom tab.
    useOnAppLifecycleStateChange((_, state) {
      _logger.fine('worker lifecycle state=$state');
      if (state != AppLifecycleState.resumed) {
        return;
      }

      // Drain again when the app is foregrounded after the custom tab or deep link returns.
      _logger.fine('worker drain on resume');
      drain();
    });

    return child ?? const SizedBox.shrink();
  }
}
