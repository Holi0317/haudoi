import 'package:flutter/material.dart';

import '../models/link.dart';
import '../utils.dart';
import 'link_favicon.dart';
import 'tag_chip.dart';

class LinkTileSubtitle extends StatelessWidget {
  final Link item;

  const LinkTileSubtitle({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final uri = Uri.parse(item.url);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            LinkFavicon(item: item),
            Flexible(
              child: Text(
                uri.host,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(' • ${formatRelativeDate(item.createdAt)}'),
            if (item.favorite)
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Icon(
                  Icons.favorite,
                  color: Colors.pink,
                  size: theme.textTheme.bodyMedium!.fontSize,
                ),
              ),

            if (item.archive)
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Icon(
                  Icons.archive,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: theme.textTheme.bodyMedium!.fontSize,
                ),
              ),
          ],
        ),
        if (item.tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Wrap(
              spacing: 4.0,
              runSpacing: 4.0,
              children: item.tags.map((tag) => TagChip(tag: tag)).toList(),
            ),
          ),
      ],
    );
  }
}
