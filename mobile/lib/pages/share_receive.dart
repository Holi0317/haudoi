import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';

import '../i18n/strings.g.dart';
import '../models/edit_op.dart';
import '../providers/sync/queue.dart';
import '../utils.dart';

final _log = Logger('ShareReceivePage');

class ShareReceivePage extends HookConsumerWidget {
  const ShareReceivePage({super.key, this.sharedUrl});

  final String? sharedUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = useState(const AsyncValue<String>.loading());

    Future<void> process(String? content) async {
      if (!state.value.isLoading) {
        _log.warning("Trying to process shared URL while not idle, skipping");
        return;
      }

      state.value = const AsyncValue.loading();

      final next = await AsyncValue.guard(() async {
        // Wait 1 tick so we are not updating riverpod providers on widget tree build.
        // Riverpod is pretty upset about that. See https://riverpod.dev/docs/root/do_dont#avoid-initializing-providers-in-a-widget.
        await Future.value();

        if (content == null || content.isEmpty) {
          _log.warning('Received share with empty content');

          throw ArgumentError("No URL received");
        }

        final url = isWebUri(content);
        if (url == null) {
          _log.warning('Received share with invalid URL: $content');

          throw ArgumentError("Invalid URL");
        }

        _log.info('Inserting shared URL into queue: $url');

        ref
            .read(editQueueProvider.notifier)
            .add(EditOp.insert(url: url.toString()));

        return '';
      });

      if (context.mounted) {
        state.value = next;
      }
    }

    useEffect(() {
      process(sharedUrl);
      return null;
    }, [sharedUrl]);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.share.title),
        automaticallyImplyLeading: false,
      ),
      body: Center(child: _buildContent(context, state.value)),
    );
  }

  Widget _buildContent(BuildContext context, AsyncValue<String> state) {
    final theme = Theme.of(context);

    return switch (state) {
      AsyncValue(hasError: true, :final error) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error, size: 80),
          const SizedBox(height: 16),
          Text(error.toString(), style: theme.textTheme.titleLarge),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => SystemNavigator.pop(animated: true),
            child: Text(t.dialogs.close),
          ),
        ],
      ),
      AsyncValue(hasValue: true) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 80),
          const SizedBox(height: 16),
          Text(t.share.success, style: theme.textTheme.titleLarge),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => SystemNavigator.pop(animated: true),
            child: Text(t.dialogs.close),
          ),
        ],
      ),
      _ => const CircularProgressIndicator(),
    };
  }
}
