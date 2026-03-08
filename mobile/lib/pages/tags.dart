import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../components/tag_chip.dart';
import '../models/tag.dart';
import '../providers/api/api.dart';
import '../utils.dart';

class TagsPage extends ConsumerStatefulWidget {
  const TagsPage({super.key});

  @override
  ConsumerState<TagsPage> createState() => _TagsPageState();
}

class _TagsPageState extends ConsumerState<TagsPage> {
  final Set<int> _deletingTagIds = {};

  @override
  Widget build(BuildContext context) {
    final tagsAsync = ref.watch(tagsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tags'),
        actions: [
          IconButton(
            tooltip: 'Create Tag',
            onPressed: () => context.push('/tags/new'),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: switch (tagsAsync) {
        AsyncData(value: final tags) => _buildBody(tags),
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

  Widget _buildBody(List<Tag> tags) {
    if (tags.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12,
          children: [
            const Text('No tags yet'),
            FilledButton.icon(
              onPressed: () => context.push('/tags/new'),
              icon: const Icon(Icons.add),
              label: const Text('Create Tag'),
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
            // title: Text(
            //   tag.emoji.isNotEmpty ? '${tag.emoji} ${tag.name}' : tag.name,
            // ),
            subtitle: Text('Created ${formatRelativeDate(tag.createdAt)}'),
            trailing: _deletingTagIds.contains(tag.id)
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Edit tag',
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () {
                          context.push('/tags/edit?id=${tag.id}');
                        },
                      ),
                      IconButton(
                        tooltip: 'Delete tag',
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _deleteTag(tag),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Future<void> _deleteTag(Tag tag) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Tag'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8.0,
            children: [
              Text('Are you sure you want to delete "${tag.name}"?'),
              Text(
                'Links with this tag will remain unchanged.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    setState(() {
      _deletingTagIds.add(tag.id);
    });

    try {
      final api = await ref.read(apiRepositoryProvider.future);
      await api.deleteTag(tag.id);
      ref.invalidate(tagsProvider);
      ref.invalidate(searchProvider);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tag deleted')));
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete tag: $error')));
    } finally {
      if (mounted) {
        setState(() {
          _deletingTagIds.remove(tag.id);
        });
      }
    }
  }
}
