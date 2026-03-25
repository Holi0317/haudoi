import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../hooks/globalkey.dart';
import '../i18n/strings.g.dart';
import '../models/edit_op.dart';
import '../models/link.dart';
import '../models/tag.dart';
import '../platform/custom_tabs_bridge.dart';
import '../providers/sync/queue.dart';
import '../utils.dart';
import 'form_builder_switch_list_tile.dart';
import 'link_image_preview.dart';

/// Form widget for editing a link. This is used in the edit page.
class EditPageForm extends HookConsumerWidget {
  const EditPageForm({super.key, required this.link, required this.tags});

  final Link link;
  final List<Tag> tags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useFormBuilderKey();

    return Scaffold(
      appBar: AppBar(
        title: Text(t.edit.title),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FilledButton.icon(
              onPressed: () => _submit(context, ref, formKey),
              icon: const Icon(Icons.save),
              label: Text(t.edit.save),
            ),
          ),
        ],
      ),
      body: FormBuilder(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUnfocus,
        child: Padding(
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
                onTap: _openLink,
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_new),
                  onPressed: _openLink,
                ),
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'note',
                initialValue: link.note,
                validator: FormBuilderValidators.maxLength(4096),
                decoration: InputDecoration(
                  labelText: t.edit.fields.note,
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 8,
                minLines: 4,
                maxLength: 4096,
              ),
              FormBuilderSwitchListTile(
                name: 'isFavorite',
                initialValue: link.favorite,
                title: Text(t.edit.fields.favorite),
                secondary: const Icon(Icons.favorite),
              ),
              FormBuilderSwitchListTile(
                name: 'isArchive',
                initialValue: link.archive,
                title: Text(t.edit.fields.archive),
                secondary: const Icon(Icons.archive),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(t.edit.tags.title),
                contentPadding: EdgeInsets.zero,
              ),
              _SelectedTagField(link: link, tags: tags),
            ],
          ),
        ),
      ),
    );
  }

  void _openLink() async {
    final opened = await CustomTabsBridge.instance.openLink(
      uri: Uri.parse(link.url),
      linkId: link.id,
      archiveButton: false,
    );

    if (!opened) {
      throw Exception('Could not launch ${link.url}');
    }
  }

  void _submit(
    BuildContext context,
    WidgetRef ref,
    GlobalKey<FormBuilderState> formKey,
  ) {
    final form = formKey.currentState!;

    if (!form.saveAndValidate()) {
      return;
    }

    final ops = _buildEditOps(form);

    if (ops.isNotEmpty) {
      ref.read(editQueueProvider.notifier).addAll(ops);
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t.edit.toast)));
    Navigator.of(context).pop();
  }

  /// Build a list of edit operations base on the form and changed fields.
  List<EditOp> _buildEditOps(FormBuilderState form) {
    final ops = <EditOp>[];

    final value = form.value;
    final note = value['note'] as String;
    final isArchive = value['isArchive'] as bool;
    final isFavorite = value['isFavorite'] as bool;
    final selectedTagIds = value['selectedTagIds'] as Set<int>;

    if (note != link.note) {
      ops.add(
        EditOp.setString(
          id: link.id,
          field: EditOpStringField.note,
          value: note,
        ),
      );
    }

    if (isArchive != link.archive) {
      ops.add(
        EditOp.setBool(
          id: link.id,
          field: EditOpBoolField.archive,
          value: isArchive,
        ),
      );
    }

    if (isFavorite != link.favorite) {
      ops.add(
        EditOp.setBool(
          id: link.id,
          field: EditOpBoolField.favorite,
          value: isFavorite,
        ),
      );
    }

    final linkTagIds = link.tags.map((tag) => tag.id).toSet();
    if (selectedTagIds != linkTagIds) {
      final tagIds = selectedTagIds.toList()..sort();
      ops.add(EditOp.setTags(id: link.id, tagIds: tagIds));
    }

    return ops;
  }
}

class _SelectedTagField extends StatelessWidget {
  const _SelectedTagField({required this.link, required this.tags});

  final Link link;
  final List<Tag> tags;

  @override
  Widget build(BuildContext context) {
    return FormBuilderField(
      name: "selectedTagIds",
      initialValue: link.tags.map((tag) => tag.id).toSet(),
      builder: (field) {
        if (tags.isEmpty) {
          return Card(
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
          );
        }

        return Column(
          children: tags.map((tag) {
            final isSelected = field.value?.contains(tag.id) ?? false;
            final color = colorFromHex(tag.color);

            return CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                tag.emoji.isNotEmpty ? '${tag.emoji} ${tag.name}' : tag.name,
              ),
              secondary: Icon(Icons.label, size: 16, color: color),
              value: isSelected,
              onChanged: (selected) {
                final next = field.value?.toSet() ?? {};

                if (selected == true) {
                  next.add(tag.id);
                } else {
                  next.remove(tag.id);
                }

                field.didChange(next);
              },
            );
          }).toList(),
        );
      },
    );
  }
}
