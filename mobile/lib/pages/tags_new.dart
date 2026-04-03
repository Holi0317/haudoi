import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';

import '../components/edit_tag_form.dart';
import '../i18n/strings.g.dart';
import '../models/tag.dart';
import '../providers/api/api.dart';

final _logger = Logger('NewTagPage');

class NewTagPage extends HookConsumerWidget {
  const NewTagPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = useState(false);

    return EditTagForm(
      title: Text(t.tagNew.title),
      actionLabel: Text(t.tagNew.create),
      value: const Tag(
        id: 0,
        createdAt: 0,
        name: '',
        color: '#000000',
        emoji: '',
      ),
      onSubmit: (tag) async {
        if (isLoading.value) {
          return;
        }

        isLoading.value = true;
        try {
          final api = await ref.read(apiRepositoryProvider.future);
          await api.createTag(
            TagCreateBody(
              name: tag.name,
              color: tag.color,
              emoji: tag.emoji.isEmpty ? null : tag.emoji,
            ),
          );
          ref.invalidate(tagsProvider);

          if (!context.mounted) {
            return;
          }

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(t.tagNew.toast.created)));
          Navigator.of(context).pop();
        } catch (error, st) {
          _logger.warning("Failed to create tag", error, st);

          if (!context.mounted) {
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.tagNew.toast.createFailed(error: '$error')),
            ),
          );
        } finally {
          if (context.mounted) {
            isLoading.value = false;
          }
        }
      },
      isLoading: isLoading.value,
    );
  }
}
