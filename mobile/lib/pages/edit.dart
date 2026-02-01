import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/link.dart';
import '../providers/api/item.dart';

class EditPage extends ConsumerStatefulWidget {
  const EditPage({super.key, required this.id});

  final int id;

  @override
  ConsumerState<EditPage> createState() => _EditPageState();
}

class _EditPageState extends ConsumerState<EditPage> {
  late TextEditingController _titleController;
  late TextEditingController _urlController;
  late TextEditingController _noteController;
  bool _isFavorite = false;
  bool _isArchive = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _urlController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _initializeFormFromLink(Link link) {
    _titleController.text = link.title;
    _urlController.text = link.url;
    _noteController.text = link.note;
    _isFavorite = link.favorite;
    _isArchive = link.archive;
  }

  void _handleSave() {
    // TODO: Implement save functionality with API call
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
          if (!_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: _handleSave,
                icon: const Icon(Icons.check),
                label: const Text('Save'),
              ),
            ),
          if (_isLoading)
            const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
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
      if (_titleController.text.isEmpty) {
        _initializeFormFromLink(link);
      }
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(labelText: 'URL'),
          ),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(labelText: 'Note'),
            maxLines: null,
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
    );
  }
}
