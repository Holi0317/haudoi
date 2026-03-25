import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../components/edit_tag_form.dart';
import '../i18n/strings.g.dart';
import '../models/tag.dart';
import '../providers/api/api.dart';

class EditTagPage extends HookConsumerWidget {
  const EditTagPage({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagsProvider);
    final isLoading = useState(false);

    return switch (tagsAsync) {
      AsyncError(error: final error) => Scaffold(
        appBar: AppBar(title: Text(t.tagEdit.title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(t.tagEdit.loadingError(error: '$error')),
          ),
        ),
      ),
      AsyncData(value: final tags) => _buildLoaded(
        context,
        ref,
        tags,
        isLoading,
      ),
      _ => Scaffold(
        appBar: AppBar(title: Text(t.tagEdit.title)),
        body: const Center(child: CircularProgressIndicator()),
      ),
    };
  }

  Widget _buildLoaded(
    BuildContext context,
    WidgetRef ref,
    List<Tag> tags,
    ValueNotifier<bool> isLoading,
  ) {
    final tag = _findTag(tags);
    if (tag == null) {
      return Scaffold(
        appBar: AppBar(title: Text(t.tagEdit.title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(t.tagEdit.notFound(id: id)),
          ),
        ),
      );
    }

    return EditTagForm(
      value: tag,
      onSubmit: (tag) async {
        if (isLoading.value) {
          return;
        }

        try {
          isLoading.value = true;
          await _submit(context, ref, tag);
        } finally {
          isLoading.value = false;
        }
      },
      isLoading: isLoading.value,
    );
  }

  Tag? _findTag(List<Tag> tags) {
    return tags.firstWhereOrNull((t) => t.id == id);
  }

  Future<void> _submit(BuildContext context, WidgetRef ref, Tag tag) async {
    try {
      final api = await ref.read(apiRepositoryProvider.future);
      await api.updateTag(
        tag.id,
        TagUpdateBody(name: tag.name, emoji: tag.emoji, color: tag.color),
      );
      ref.invalidate(tagsProvider);
      ref.invalidate(searchProvider);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.tagEdit.toast.updated)));
      Navigator.of(context).pop();
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.tagEdit.toast.updateFailed(error: '$error'))),
      );
    }
  }
}
