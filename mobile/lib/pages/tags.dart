import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../components/tag_chip.dart';
import '../i18n/strings.g.dart';
import '../models/tag.dart';
import '../providers/api/api.dart';
import '../utils.dart';

class _TagContent extends HookConsumerWidget {
  const _TagContent({required this.tags});

  final List<Tag> tags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deletingTagIds = useState(<int>{});

    if (tags.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12,
          children: [
            Text(t.tags.empty.message),
            FilledButton.icon(
              onPressed: () => context.push('/tags/new'),
              icon: const Icon(Icons.add),
              label: Text(t.tags.empty.button),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(tagsProvider);
        await ref.read(tagsProvider.future);
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: tags.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final tag = tags[index];

          return ListTile(
            title: Align(
              alignment: Alignment.centerLeft,
              child: TagChip(tag: tag),
            ),
            subtitle: Text(
              t.tags.createdLabel(date: formatRelativeDate(tag.createdAt)),
            ),
            trailing: deletingTagIds.value.contains(tag.id)
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: t.tags.editTooltip,
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () {
                          context.push('/tags/edit?id=${tag.id}');
                        },
                      ),
                      IconButton(
                        tooltip: t.tags.deleteTooltip,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () =>
                            _deleteTag(context, ref, tag, deletingTagIds),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Future<void> _deleteTag(
    BuildContext context,
    WidgetRef ref,
    Tag tag,
    ValueNotifier<Set<int>> deletingTagIds,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.tags.deleteDialog.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8.0,
            children: [
              Text(t.tags.deleteDialog.deleteMessage(name: tag.name)),
              Text(
                t.tags.deleteDialog.warning,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(t.dialogs.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(t.dialogs.delete),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    deletingTagIds.value = deletingTagIds.value.toSet()..add(tag.id);

    try {
      final api = await ref.read(apiRepositoryProvider.future);
      await api.deleteTag(tag.id);
      ref.invalidate(tagsProvider);
      ref.invalidate(searchProvider);

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.tags.toast.deleted)));
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.tags.toast.deleteFailed(error: '$error'))),
      );
    } finally {
      if (context.mounted) {
        deletingTagIds.value = deletingTagIds.value.toSet()..remove(tag.id);
      }
    }
  }
}

class TagsPage extends ConsumerWidget {
  const TagsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(tagsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.tags.title),
        actions: [
          IconButton(
            tooltip: t.tags.createTag,
            onPressed: () => context.push('/tags/new'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: switch (tagsAsync) {
        AsyncData(value: final tags) => _TagContent(tags: tags),
        AsyncError(error: final error) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Failed to load tags: $error'),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
