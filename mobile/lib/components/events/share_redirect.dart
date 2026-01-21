import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';

import '../../providers/share_handler.dart';

/// Widget that handles share intents by redirecting to the share page.
///
/// Place this somewhere in the widget tree to enable share handling.
class ShareRedirect extends ConsumerWidget {
  const ShareRedirect({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = Logger('ShareRedirect');

    ref.listen(sharedMediaProvider, (previous, next) {
      final value = next.value;
      if (value == null) {
        return;
      }

      final content = value.content;
      if (content == null || content.isEmpty) {
        log.warning(
          'Received shared media with empty content, ignoring. $value',
        );
        return;
      }

      log.info('Navigating to share page with URL: $content');

      context.push(
        Uri(path: '/share', queryParameters: {'url': content}).toString(),
      );
    });

    return child ?? const SizedBox.shrink();
  }
}
