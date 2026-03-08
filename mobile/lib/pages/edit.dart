import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/link_image_preview.dart';
import '../i18n/strings.g.dart';
import '../models/edit_op.dart';
import '../models/link.dart';
import '../models/tag.dart';
import '../providers/api/api.dart';
import '../providers/api/item.dart';
import '../providers/sync/queue.dart';
import '../utils.dart';

class EditPage extends ConsumerStatefulWidget {
  const EditPage({super.key, required this.id});

  final int id;

  @override
  ConsumerState<EditPage> createState() => _EditPageState();
}

class _EditPageState extends ConsumerState<EditPage> {
  late TextEditingController _noteController;
  bool _isFavorite = false;
  bool _isArchive = false;
  Set<int> _selectedTagIds = {};
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _initializeFormFromLink(Link link) {
    if (_initialized) return;

    setState(() {
      _noteController.text = link.note;
      _isFavorite = link.favorite;
      _isArchive = link.archive;
      _selectedTagIds = link.tags.map((tag) => tag.id).toSet();

      _initialized = true;
    });
  }

  bool _hasSameTags(Link link) {
    final initialTagIds = link.tags.map((tag) => tag.id).toSet();
    return initialTagIds.length == _selectedTagIds.length &&
        initialTagIds.containsAll(_selectedTagIds);
  }

  List<EditOp> _buildEditOps(Link link) {
    final ops = <EditOp>[];

    if (_noteController.text != link.note) {
      ops.add(
        EditOp.setString(
          id: widget.id,
          field: EditOpStringField.note,
          value: _noteController.text,
        ),
      );
    }

    if (_isArchive != link.archive) {
      ops.add(
        EditOp.setBool(
          id: widget.id,
          field: EditOpBoolField.archive,
          value: _isArchive,
        ),
      );
    }

    if (_isFavorite != link.favorite) {
      ops.add(
        EditOp.setBool(
          id: widget.id,
          field: EditOpBoolField.favorite,
          value: _isFavorite,
        ),
      );
    }

    if (!_hasSameTags(link)) {
      final tagIds = _selectedTagIds.toList()..sort();
      ops.add(EditOp.setTags(id: widget.id, tagIds: tagIds));
    }

    return ops;
  }

  void _handleSave() {
    final linkAsync = ref.read(linkItemProvider(widget.id));
    final link = linkAsync.value;
    if (link == null) return;

    final ops = _buildEditOps(link);

    if (ops.isNotEmpty) {
      ref.read(editQueueProvider.notifier).addAll(ops);
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t.edit.toast)));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final linkAsync = ref.watch(linkItemProvider(widget.id));
    final tagsAsync = ref.watch(tagsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.edit.title),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: linkAsync.hasValue && tagsAsync.hasValue
                  ? _handleSave
                  : null,
              icon: const Icon(Icons.check),
              label: Text(t.edit.save),
            ),
          ),
        ],
      ),
      body: switch ((linkAsync, tagsAsync)) {
        (AsyncError(error: final error), _) ||
        (_, AsyncError(error: final error)) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(linkItemProvider(widget.id));
                  ref.invalidate(tagsProvider);
                },
                child: Text(t.edit.retry),
              ),
            ],
          ),
        ),
        (AsyncData(value: final link), AsyncData(value: final tags)) =>
          _buildForm(context, link, tags),
        (_, _) => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _buildForm(BuildContext context, Link link, List<Tag> tags) {
    // Initialize form data on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFormFromLink(link);
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          SizedBox(height: 200, child: LinkImagePreview(item: link)),
          const SizedBox(height: 16),
          ListTile(
            title: Text(t.edit.fields.title),
            subtitle: Text(link.title),
            contentPadding: EdgeInsets.zero,
          ),
          ListTile(
            title: Text(t.edit.fields.url),
            subtitle: Text(link.url),
            contentPadding: EdgeInsets.zero,
            trailing: IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: () => launchUrl(Uri.parse(link.url)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: t.edit.fields.note,
              border: const OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
            maxLines: 8,
            minLines: 4,
            maxLength: 4096,
          ),
          SwitchListTile(
            title: Text(t.edit.fields.favorite),
            value: _isFavorite,
            onChanged: (value) {
              setState(() {
                _isFavorite = value;
              });
            },
          ),
          SwitchListTile(
            title: Text(t.edit.fields.archive),
            value: _isArchive,
            onChanged: (value) {
              setState(() {
                _isArchive = value;
              });
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            title: Text(t.edit.tags.title),
            contentPadding: EdgeInsets.zero,
          ),
          if (tags.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    Text(t.edit.tags.empty.message),
                    ElevatedButton(
                      onPressed: () {
                        context.push('/tags/new');
                      },
                      child: Text(t.edit.tags.empty.button),
                    ),
                  ],
                ),
              ),
            )
          else
            ...tags.map((tag) {
              final isSelected = _selectedTagIds.contains(tag.id);
              final color = colorFromHex(tag.color);

              return CheckboxListTile(
                contentPadding: EdgeInsets.zero,
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
            }),
        ],
      ),
    );
  }
}
