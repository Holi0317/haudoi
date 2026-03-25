import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/color_picker/field.dart';
import '../components/tag_chip.dart';
import '../i18n/strings.g.dart';
import '../models/tag.dart';
import '../providers/api/api.dart';
import '../utils.dart' hide colorFromHex;

class EditTagPage extends ConsumerStatefulWidget {
  const EditTagPage({super.key, required this.id});

  final int id;

  @override
  ConsumerState<EditTagPage> createState() => _EditTagPageState();
}

class _EditTagPageState extends ConsumerState<EditTagPage> {
  final _nameController = TextEditingController();
  final _emojiController = TextEditingController();
  final _colorController = TextEditingController();

  Tag? _initialTag;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emojiController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tagsAsync = ref.watch(tagsProvider);

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }

        await _confirmDiscardAndMaybePop();
      },
      child: switch (tagsAsync) {
        AsyncData(value: final tags) => _buildLoaded(context, tags),
        AsyncError(error: final error) => Scaffold(
          appBar: AppBar(title: Text(t.tagEdit.title)),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(t.tagEdit.loadingError(error: '$error')),
            ),
          ),
        ),
        _ => Scaffold(
          appBar: AppBar(title: Text(t.tagEdit.title)),
          body: const Center(child: CircularProgressIndicator()),
        ),
      },
    );
  }

  Widget _buildLoaded(BuildContext context, List<Tag> tags) {
    final tag = _findTag(tags);
    if (tag == null) {
      return Scaffold(
        appBar: AppBar(title: Text(t.tagEdit.title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(t.tagEdit.notFound(id: widget.id)),
          ),
        ),
      );
    }

    _initIfNeeded(tag);

    final previewTag = Tag(
      id: tag.id,
      name: _nameController.text.trim().isEmpty
          ? tag.name
          : _nameController.text.trim(),
      color: isValidHexColor(_normalizedColorHex)
          ? _normalizedColorHex
          : tag.color,
      emoji: _emojiController.text,
      createdAt: tag.createdAt,
    );

    final canSave = _hasUnsavedChanges && isValidHexColor(_normalizedColorHex);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.tagEdit.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _confirmDiscardAndMaybePop,
        ),
        actions: [
          TextButton(
            onPressed: _saving || !canSave ? null : () => _save(tag),
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(t.edit.save),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            t.tagEdit.preview,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(children: [TagChip(tag: previewTag)]),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: t.tagEdit.fields.title,
              border: const OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _emojiController,
            decoration: InputDecoration(
              labelText: t.tagEdit.fields.emoji,
              hintText: t.tagEdit.fields.emojiHint,
              border: const OutlineInputBorder(),
            ),
            textInputAction: TextInputAction.next,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          ColorPickerField(
            value: colorFromHex(_colorController.text)!,
            decoration: InputDecoration(
              labelText: t.colorPicker.label,
              hintText: '#RRGGBB',
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.arrow_drop_down),
            ),
            onChanged: (value) {
              _colorController.text = value.toHexString();
              setState(() {});
            },
          ),
          // TODO: Add "search existing links" for this tag
        ],
      ),
    );
  }

  Tag? _findTag(List<Tag> tags) {
    for (final tag in tags) {
      if (tag.id == widget.id) {
        return tag;
      }
    }

    return null;
  }

  void _initIfNeeded(Tag tag) {
    if (_initialTag != null) {
      return;
    }

    _initialTag = tag;
    _nameController.text = tag.name;
    _emojiController.text = tag.emoji;
    _colorController.text = normalizeHexColor(tag.color);
  }

  bool get _hasUnsavedChanges {
    final initial = _initialTag;
    if (initial == null) {
      return false;
    }

    return _nameController.text.trim() != initial.name ||
        _emojiController.text != initial.emoji ||
        _normalizedColorHex != normalizeHexColor(initial.color);
  }

  Future<void> _confirmDiscardAndMaybePop() async {
    if (!_hasUnsavedChanges) {
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.tagEdit.discard.title),
          content: Text(t.tagEdit.discard.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(t.tagEdit.discard.stay),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(t.tagEdit.discard.discard),
            ),
          ],
        );
      },
    );

    if (shouldDiscard == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _save(Tag tag) async {
    final nextName = _nameController.text.trim();
    final nextEmoji = _emojiController.text;
    final nextColor = _normalizedColorHex;

    if (nextName.isEmpty || !isValidHexColor(nextColor)) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final api = await ref.read(apiRepositoryProvider.future);
      await api.updateTag(
        tag.id,
        TagUpdateBody(name: nextName, emoji: nextEmoji, color: nextColor),
      );
      ref.invalidate(tagsProvider);
      ref.invalidate(searchProvider);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.tagEdit.toast.updated)));
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.tagEdit.toast.updateFailed(error: '$error'))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  String get _normalizedColorHex {
    return normalizeHexColor(_colorController.text);
  }
}
