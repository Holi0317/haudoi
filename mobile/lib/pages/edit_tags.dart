import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../i18n/strings.g.dart';
import '../models/edit_op.dart';
import '../models/link.dart';
import '../models/tag.dart';
import '../providers/api/api.dart';
import '../providers/api/item.dart';
import '../providers/sync/queue.dart';
import '../utils.dart';

class EditTagsPage extends ConsumerStatefulWidget {
  const EditTagsPage({super.key, required this.id});

  final int id;

  @override
  ConsumerState<EditTagsPage> createState() => _EditTagsPageState();
}

class _EditTagsPageState extends ConsumerState<EditTagsPage> {
  Set<int> _selectedTagIds = {};
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final linkAsync = ref.watch(linkItemProvider(widget.id));
    final tagsAsync = ref.watch(tagsProvider);

    return switch ((linkAsync, tagsAsync)) {
      (AsyncError(error: final error), _) ||
      (_, AsyncError(error: final error)) => Scaffold(
        appBar: AppBar(title: Text(t.edit.title)),
        body: Center(child: Text('Error loading tags: $error')),
      ),
      (AsyncData(value: final link), AsyncData(value: final tags)) =>
        _buildScaffold(context, link, tags),
      _ => Scaffold(
        appBar: AppBar(title: Text(t.edit.title)),
        body: const Center(child: CircularProgressIndicator()),
      ),
    };
  }

  Widget _buildScaffold(BuildContext context, Link link, List<Tag> tags) {
    if (!_initialized) {
      setState(() {
        _selectedTagIds = link.tags.map((tag) => tag.id).toSet();
        _initialized = true;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t.editTags.title),
        actions: [
          TextButton(
            onPressed: () => _saveTags(link.id),
            child: Text(t.edit.save),
          ),
        ],
      ),
      body: _buildBody(context, link, tags),
    );
  }

  Widget _buildBody(BuildContext context, Link link, List<Tag> tags) {
    // Should not happen (or only happen 1 frame) since we initialize the form asap.
    if (!_initialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tags.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 16.0,
          children: [
            Text(t.editTags.empty.message),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement /tags/new navigation or page
                // context.push('/tags/new');
              },
              child: Text(t.editTags.empty.button),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: tags.length,
      itemBuilder: (context, index) {
        final tag = tags[index];
        final isSelected = _selectedTagIds.contains(tag.id);
        final color = colorFromHex(tag.color);

        return CheckboxListTile(
          title: Text(
            tag.emoji.isNotEmpty ? '${tag.emoji} ${tag.name}' : tag.name,
          ),
          secondary: Icon(Icons.label, size: 16, color: color),
          value: isSelected,
          onChanged: (selected) {
            setState(() {
              if (selected == true) {
                _selectedTagIds.add(tag.id);
              } else {
                _selectedTagIds.remove(tag.id);
              }
            });
          },
        );
      },
    );
  }

  Future<void> _saveTags(int linkId) async {
    final queue = ref.read(editQueueProvider.notifier);
    queue.add(EditOp.setTags(id: linkId, tagIds: _selectedTagIds.toList()));

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.dialogs.copiedToClipboard)));

      Navigator.of(context).pop();
    }
  }
}
