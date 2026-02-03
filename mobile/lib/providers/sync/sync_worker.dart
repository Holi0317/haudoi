import 'dart:async';

import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/edit_op.dart';
import '../api/api.dart';
import '../api/item.dart';
import '../extensions.dart';
import 'queue.dart';

part 'sync_worker.g.dart';

/// Background worker that listens to [EditQueue] and processes the queue when there are pending operations.
///
/// Value of this provider doesn't matter.
@riverpod
class SyncWorker extends _$SyncWorker {
  bool _editProcessing = false;

  final log = Logger('SyncWorker');

  @override
  int build() {
    ref.listen(editQueuePendingProvider, (previous, next) {
      // TODO: Debounce?
      // TODO: Retry on failure?
      // TODO: Stop processing if we are not authenticated?
      // TODO: Status reporting?
      _process(next);
    });

    // Set up periodic timer to pop applied operations every minute
    final timer = Timer.periodic(const Duration(minutes: 1), (_) {
      ref.read(editQueueProvider.notifier).popApplied();
    });

    ref.onDispose(timer.cancel);

    return 1;
  }

  Future<void> _process(List<EditOp> ops) async {
    if (ops.isEmpty) {
      log.info('No pending operations, skipping processing.');
      return;
    }

    if (_editProcessing) {
      log.info('Another process is running, skipping this trigger.');
      return;
    }

    _editProcessing = true;

    log.info('Processing ${ops.length} EditOp');

    try {
      final api = await ref.read(apiRepositoryProvider.future);
      final queue = ref.read(editQueueProvider.notifier);

      await api.edit(ops, abortTrigger: ref.abortTrigger());

      ref.invalidate(searchProvider);
      ref.invalidate(linkItemProvider);
      queue.markApplied(ops);

      log.info('Processed ${ops.length} EditOp successfully.');
    } catch (e, st) {
      log.severe('Failed to process EditOp', e, st);
    } finally {
      _editProcessing = false;
    }
  }
}
