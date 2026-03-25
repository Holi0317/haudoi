import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../hooks/globalkey.dart';
import '../i18n/strings.g.dart';
import '../models/tag.dart';
import 'color_picker/form_builder.dart';
import 'tag_chip.dart';

class EditTagForm extends HookWidget {
  const EditTagForm({
    super.key,
    required this.value,
    required this.onSubmit,
    this.isLoading = false,
  });

  final Tag value;
  final ValueChanged<Tag> onSubmit;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final formKey = useFormBuilderKey();
    final preview = useState(value);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.tagEdit.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _confirmPop(context, formKey),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FilledButton.icon(
              onPressed: isLoading ? null : () => _submit(context, formKey),
              icon: isLoading
                  ? const CircularProgressIndicator()
                  : const Icon(Icons.save),
              label: Text(t.edit.save),
            ),
          ),
        ],
      ),
      body: FormBuilder(
        key: formKey,
        enabled: !isLoading,
        onChanged: () {
          if (formKey.currentState != null) {
            preview.value = _fromForm(formKey);
          }
        },
        canPop: formKey.currentState?.isDirty ?? true,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) {
            return;
          }

          await _confirmPop(context, formKey);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              t.tagEdit.preview,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(children: [TagChip(tag: preview.value)]),
            const SizedBox(height: 20),
            FormBuilderTextField(
              name: 'name',
              initialValue: value.name,
              decoration: InputDecoration(
                labelText: t.tagEdit.fields.title,
                border: const OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            FormBuilderTextField(
              name: 'emoji',
              initialValue: value.emoji,
              decoration: InputDecoration(
                labelText: t.tagEdit.fields.emoji,
                hintText: t.tagEdit.fields.emojiHint,
                border: const OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            FormBuilderColorPickerField(
              name: 'color',
              initialValue: colorFromHex(value.color),
              decoration: InputDecoration(
                labelText: t.colorPicker.label,
                hintText: '#RRGGBB',
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.arrow_drop_down),
              ),
            ),
            // TODO: Add "search existing links" for this tag
          ],
        ),
      ),
    );
  }

  Tag _fromForm(GlobalKey<FormBuilderState> formKey) {
    final form = formKey.currentState;
    if (form == null) {
      return Tag(
        id: value.id,
        createdAt: value.createdAt,
        name: value.name,
        color: value.color,
        emoji: value.emoji,
      );
    }

    form.save();

    return Tag(
      id: value.id,
      createdAt: value.createdAt,
      name: form.value['name'] as String,
      color: colorToHex(
        form.value['color'] as Color,
        includeHashSign: true,
        enableAlpha: false,
      ),
      emoji: form.value['emoji'] as String,
    );
  }

  Future<void> _confirmPop(
    BuildContext context,
    GlobalKey<FormBuilderState> formKey,
  ) async {
    final isDirty = formKey.currentState?.isDirty ?? false;

    if (!isDirty) {
      if (context.mounted) {
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

    if (shouldDiscard == true && context.mounted) {
      Navigator.of(context).pop();
    }
  }

  void _submit(BuildContext context, GlobalKey<FormBuilderState> formKey) {
    final form = formKey.currentState;
    if (form == null) {
      return;
    }

    if (!form.saveAndValidate()) {
      return;
    }

    final tag = _fromForm(formKey);
    onSubmit(tag);
  }
}
