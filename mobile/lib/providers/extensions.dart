import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

extension RefAbortTrigger on Ref {
  /// Create an abortTrigger for http library from riverpod [Ref].
  ///
  /// The returned future will be resolved when either:
  /// - The [timeout] duration expires (default 30 seconds)
  /// - The ref is disposed
  ///
  /// Whichever happens first will complete the abort trigger.
  /// You can customize the timeout by passing a [Duration], or disable it by passing [Duration.zero].
  Future<void> abortTrigger({Duration timeout = const Duration(seconds: 10)}) {
    final completer = Completer<void>();

    Timer? timer;
    if (timeout > Duration.zero) {
      timer = Timer(timeout, completer.complete);
    }

    onDispose(() {
      timer?.cancel();
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    return completer.future;
  }
}

extension ProviderListenableSelectData<InT>
    on ProviderListenable<AsyncValue<InT>> {
  /// Similar to [ProviderListenable.select], but works on [AsyncValue] and only selects
  /// on successful data.
  ProviderListenable<AsyncValue<OutT>> selectData<OutT>(
    OutT Function(InT value) selector,
  ) {
    return ProviderListenableSelect(this).select((v) => v.whenData(selector));
  }
}
