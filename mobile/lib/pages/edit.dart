import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/link_image_preview.dart';
import '../models/edit_op.dart';
import '../models/link.dart';
import '../providers/api/item.dart';
import '../providers/sync/queue.dart';

class EditPage extends ConsumerStatefulWidget {
  const EditPage({super.key, required this.id});

  final int id;

  @override
  ConsumerState<EditPage> createState() => _EditPageState();
}

class _EditPageState extends ConsumerState<EditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _noteController;
  bool _isFavorite = false;
  bool _isArchive = false;
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

      _initialized = true;
    });
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
    ).showSnackBar(const SnackBar(content: Text('Changes saved')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final linkAsync = ref.watch(linkItemProvider(widget.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Link'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: linkAsync.hasValue ? _handleSave : null,
              icon: const Icon(Icons.check),
              label: const Text('Save'),
            ),
          ),
        ],
      ),
      body: switch (linkAsync) {
        AsyncValue(:final value?, hasValue: true) => _buildForm(context, value),
        AsyncValue(:final error?) => Center(
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
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        AsyncValue() => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  Widget _buildForm(BuildContext context, Link link) {
    // Initialize form data on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFormFromLink(link);
    });

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SizedBox(height: 200, child: LinkImagePreview(item: link)),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Title'),
              subtitle: Text(link.title),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              title: const Text('URL'),
              subtitle: Text(link.url),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              minLines: 4,
              maxLength: 4096,
            ),
            SwitchListTile(
              title: const Text('Favorite'),
              value: _isFavorite,
              onChanged: (value) {
                setState(() {
                  _isFavorite = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Archive'),
              value: _isArchive,
              onChanged: (value) {
                setState(() {
                  _isArchive = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
