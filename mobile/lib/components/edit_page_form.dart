import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../i18n/strings.g.dart';
import '../models/link.dart';
import '../models/tag.dart';
import '../platform/custom_tabs_bridge.dart';
import '../utils.dart';
import 'link_image_preview.dart';

/// Form widget for editing a link. This is used in the edit page.
class EditPageForm extends HookConsumerWidget {
  const EditPageForm({
    super.key,
    required this.form,
    required this.link,
    required this.tags,
  });

  final FormGroup form;
  final Link link;
  final List<Tag> tags;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ReactiveForm(
      formGroup: form,
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
              trailing: IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: openLink,
              ),
            ),
            const SizedBox(height: 16),
            ReactiveTextField(
              formControlName: 'note',
              decoration: InputDecoration(
                labelText: t.edit.fields.note,
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              minLines: 4,
              maxLength: 4096,
            ),
            ReactiveSwitchListTile(
              formControlName: 'isFavorite',
              title: Text(t.edit.fields.favorite),
            ),
            ReactiveSwitchListTile(
              formControlName: 'isArchive',
              title: Text(t.edit.fields.archive),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(t.edit.tags.title),
              contentPadding: EdgeInsets.zero,
            ),
            ..._build(context),
          ],
        ),
      ),
    );
  }

  void openLink() async {
    final opened = await CustomTabsBridge.instance.openLink(
      uri: Uri.parse(link.url),
      linkId: link.id,
      archiveButton: false,
    );

    if (!opened) {
      throw Exception('Could not launch ${link.url}');
    }
  }

  Iterable<Widget> _build(BuildContext context) {
    if (tags.isEmpty) {
      return [
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
        ),
      ];
    }

    final control = form.control('selectedTagIds') as FormControl<Set<int>>;
    final value = control.value!;

    return tags.map((tag) {
      final isSelected = value.contains(tag.id);
      final color = colorFromHex(tag.color);

      return CheckboxListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          tag.emoji.isNotEmpty ? '${tag.emoji} ${tag.name}' : tag.name,
        ),
        secondary: Icon(Icons.label, size: 16, color: color),
        value: isSelected,
        onChanged: (selected) {
          final next = value.toSet();

          if (selected == true) {
            next.add(tag.id);
          } else {
            next.remove(tag.id);
          }

          control.value = next;
        },
      );
    });
  }
}
