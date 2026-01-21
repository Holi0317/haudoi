import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/sync/sync_worker.dart';

/// Flutter widget for [SyncWorker] to keep it alive in the widget tree.
///
/// Just place this somewhere in the widget tree.
///
/// FIXME(GH-19): Move the worker to maybe `flutter_workmanager` or `flutter_background_fetch`
class SyncWorkerWidget extends ConsumerWidget {
  const SyncWorkerWidget({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(syncWorkerProvider.select((data) => null));

    return child ?? const SizedBox.shrink();
  }
}
