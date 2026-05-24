import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../i18n/strings.g.dart';
import '../../providers/api/version.dart';
import '../error_state.dart';

class AppVersionDialog extends ConsumerWidget {
  const AppVersionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final line = ref.watch(appVersionLineProvider);

    return switch (line) {
      AsyncValue(:final value?, hasValue: true) => SelectableText(
        value,
        style: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
        onTap: () {
          Clipboard.setData(ClipboardData(text: value));
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(t.dialogs.copiedToClipboard)));
        },
      ),
      AsyncValue(:final error?) => ErrorState(
        error: error,
        compact: true,
        onRetry: () => ref.invalidate(appVersionLineProvider),
      ),
      AsyncValue() => const CircularProgressIndicator(),
    };
  }
}
