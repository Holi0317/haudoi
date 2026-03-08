import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/color_picker_field.dart';
import '../components/tag_chip.dart';
import '../i18n/strings.g.dart';
import '../models/tag.dart';
import '../providers/api/api.dart';
import '../utils.dart';

class NewTagPage extends ConsumerStatefulWidget {
  const NewTagPage({super.key});

  @override
  ConsumerState<NewTagPage> createState() => _NewTagPageState();
}

class _NewTagPageState extends ConsumerState<NewTagPage> {
  final _nameController = TextEditingController();
  final _emojiController = TextEditingController();
  final _colorController = TextEditingController(text: '#546E7A');
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
    final canSave =
        _nameController.text.trim().isNotEmpty &&
        isValidHexColor(_normalizedColorHex);

    final previewTag = Tag(
      id: 0,
      name: _nameController.text.trim().isEmpty
          ? t.tagNew.defaultName
          : _nameController.text.trim(),
      color: isValidHexColor(_normalizedColorHex)
          ? _normalizedColorHex
          : '#546E7A',
      emoji: _emojiController.text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          return;
        }

        await _confirmDiscardAndMaybePop();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.tagNew.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _confirmDiscardAndMaybePop,
          ),
          actions: [
            TextButton(
              onPressed: _saving || !canSave ? null : _create,
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(t.tagNew.create),
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
              value: _normalizedColorHex,
              labelText: t.colorPicker.label,
              hintText: '#RRGGBB',
              onChanged: (value) {
                _colorController.text = normalizeHexColor(value);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  bool get _hasUnsavedChanges {
    return _nameController.text.trim().isNotEmpty ||
        _emojiController.text.isNotEmpty ||
        _normalizedColorHex != '#546E7A';
  }

  String get _normalizedColorHex => normalizeHexColor(_colorController.text);

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
          content: Text(t.tagNew.discardMessage),
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

  Future<void> _create() async {
    final name = _nameController.text.trim();
    final emoji = _emojiController.text.trim();
    final color = _normalizedColorHex;

    if (name.isEmpty || !isValidHexColor(color)) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final api = await ref.read(apiRepositoryProvider.future);
      await api.createTag(
        TagCreateBody(
          name: name,
          color: color,
          emoji: emoji.isEmpty ? null : emoji,
        ),
      );
      ref.invalidate(tagsProvider);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.tagNew.toast.created)));
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.tagNew.toast.createFailed(error: '$error'))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }
}
