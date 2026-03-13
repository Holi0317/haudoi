import 'dart:async';

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
    extends ConsumerState<ArchiveActionWorkerWidget> {
  StreamSubscription<ArchiveActionEvent>? _archiveActionSubscription;

  @override
  void initState() {
    super.initState();

    CustomTabsBridge.instance.initialize();
    _archiveActionSubscription = CustomTabsBridge.instance.archiveActions
        .listen((event) {
          final queue = ref.read(editQueueProvider.notifier);
          queue.add(
            EditOp.setBool(
              id: event.linkId,
              field: EditOpBoolField.archive,
              value: true,
            ),
          );
        });
  }

  @override
  void dispose() {
    _archiveActionSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox.shrink();
  }
}
