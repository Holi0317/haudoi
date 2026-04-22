import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../models/link.dart';
import 'link_tile.dart';

/// A shimmer loading placeholder for LinkTile
class LinkTileShimmer extends StatelessWidget {
  const LinkTileShimmer({super.key, required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Column(
        children: List.generate(
          itemCount,
          (index) => LinkTileDisplay(
            item: const Link(
              id: 0,
              title: 'Title title title',
              url: 'https://flutter.dev',
              favorite: false,
              archive: false,
              tags: [],
              createdAt: 0,
              note: '',
            ),
            leading: LayoutBuilder(
              builder: (context, constraint) {
                final width = math.max(40.0, constraint.maxWidth * 0.25);
                final height = constraint.maxHeight;
                final color = Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest;

                return Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: ColoredBox(
                    color: color,
                    child: SizedBox(width: width, height: height),
                  ),
                );
              },
            ),
            selected: false,
            isSelecting: false,
          ),
        ),
      ),
    );
  }
}
