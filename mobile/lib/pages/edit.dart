import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:reactive_forms/reactive_forms.dart';

import '../components/edit_page_form.dart';
import '../i18n/strings.g.dart';
import '../models/edit_op.dart';
import '../models/link.dart';
import '../providers/api/api.dart';
import '../providers/api/item.dart';
import '../providers/sync/queue.dart';

class EditPage extends HookConsumerWidget {
  const EditPage({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linkAsync = ref.watch(linkItemProvider(id));
    final tagsAsync = ref.watch(tagsProvider);

    final form = _makeForm(ref);
    // React to form status change so that `canSubmit` is updated when `form.valid` changes.
    useStream(form.statusChanged, initialData: form.status);
    final canSubmit = linkAsync.hasValue && tagsAsync.hasValue && form.valid;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.edit.title),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: canSubmit
                  ? () => _submit(context, ref, form, linkAsync.requireValue)
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
                  ref.invalidate(linkItemProvider(id));
                  ref.invalidate(tagsProvider);
                },
                child: Text(t.edit.retry),
              ),
            ],
          ),
        ),
        (AsyncData(value: final link), AsyncData(value: final tags)) =>
          EditPageForm(form: form, link: link, tags: tags),
        (_, _) => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  FormGroup _makeForm(WidgetRef ref) {
    final linkAsync = ref.watch(linkItemProvider(id));

    final form = useMemoized(
      () => FormGroup({
        'isFavorite': FormControl<bool>(value: false),
        'isArchive': FormControl<bool>(value: false),
        'selectedTagIds': FormControl<Set<int>>(value: {}),
        'note': FormControl<String>(
          value: '',
          validators: const [MaxLengthValidator(4096)],
        ),
      }),
    );

    // Initialize form fields when link data is loaded
    useEffect(() {
      final link = linkAsync.value;

      if (link != null) {
        form.value = {
          'isFavorite': link.favorite,
          'isArchive': link.archive,
          'selectedTagIds': link.tags.map((tag) => tag.id).toSet(),
          'note': link.note,
        };

        form.markAsPristine();
      }

      return null;
    }, [linkAsync.value]);

    return form;
  }

  void _submit(BuildContext context, WidgetRef ref, FormGroup form, Link link) {
    form.updateValueAndValidity();

    if (form.invalid) {
      return;
    }

    final ops = _buildEditOps(form, link);

    if (ops.isNotEmpty) {
      ref.read(editQueueProvider.notifier).addAll(ops);
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t.edit.toast)));
    Navigator.of(context).pop();
  }

  /// Build a list of edit operations base on the form and changed fields.
  List<EditOp> _buildEditOps(FormGroup form, Link link) {
    final ops = <EditOp>[];

    final value = form.value;
    final note = value['note'] as String;
    final isArchive = value['isArchive'] as bool;
    final isFavorite = value['isFavorite'] as bool;
    final selectedTagIds = value['selectedTagIds'] as Set<int>;

    if (note != link.note) {
      ops.add(
        EditOp.setString(id: id, field: EditOpStringField.note, value: note),
      );
    }

    if (isArchive != link.archive) {
      ops.add(
        EditOp.setBool(
          id: id,
          field: EditOpBoolField.archive,
          value: isArchive,
        ),
      );
    }

    if (isFavorite != link.favorite) {
      ops.add(
        EditOp.setBool(
          id: id,
          field: EditOpBoolField.favorite,
          value: isFavorite,
        ),
      );
    }

    final linkTagIds = link.tags.map((tag) => tag.id).toSet();
    if (selectedTagIds != linkTagIds) {
      final tagIds = selectedTagIds.toList()..sort();
      ops.add(EditOp.setTags(id: id, tagIds: tagIds));
    }

    return ops;
  }
}
