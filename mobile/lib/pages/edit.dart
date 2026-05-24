import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../components/edit_page_form.dart';
import '../components/error_state.dart';
import '../i18n/strings.g.dart';
import '../providers/api/api.dart';
import '../providers/api/item.dart';

class EditPage extends HookConsumerWidget {
  const EditPage({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linkAsync = ref.watch(linkItemProvider(id));
    final tagsAsync = ref.watch(tagsProvider);

    return switch ((linkAsync, tagsAsync)) {
      (AsyncError(error: final error), _) ||
      (_, AsyncError(error: final error)) => _buildLoading(
        child: ErrorState(
          error: error,
          onRetry: () {
            ref.invalidate(linkItemProvider(id));
            ref.invalidate(tagsProvider);
          },
        ),
      ),
      (AsyncData(value: final link), AsyncData(value: final tags)) =>
        EditPageForm(link: link, tags: tags),
      (_, _) => _buildLoading(child: const CircularProgressIndicator()),
    };
  }

  Widget _buildLoading({required Widget child}) {
    return Scaffold(
      appBar: AppBar(title: Text(t.edit.title)),
      body: Center(child: child),
    );
  }
}
