// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_worker.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Background worker that listens to [EditQueue] and processes the queue when there are pending operations.
///
/// Value of this provider doesn't matter.

@ProviderFor(SyncWorker)
final syncWorkerProvider = SyncWorkerProvider._();

/// Background worker that listens to [EditQueue] and processes the queue when there are pending operations.
///
/// Value of this provider doesn't matter.
final class SyncWorkerProvider extends $NotifierProvider<SyncWorker, int> {
  /// Background worker that listens to [EditQueue] and processes the queue when there are pending operations.
  ///
  /// Value of this provider doesn't matter.
  SyncWorkerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncWorkerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncWorkerHash();

  @$internal
  @override
  SyncWorker create() => SyncWorker();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$syncWorkerHash() => r'7a383661c9079b65f58b8ceaa947aa3c43771d62';

/// Background worker that listens to [EditQueue] and processes the queue when there are pending operations.
///
/// Value of this provider doesn't matter.

abstract class _$SyncWorker extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
