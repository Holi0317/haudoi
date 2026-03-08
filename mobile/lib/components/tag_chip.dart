import 'package:flutter/material.dart';

import '../models/tag.dart';
import '../utils.dart';

/// Display a tag as a colored chip with optional emoji.
class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.tag});

  final Tag tag;

  @override
  Widget build(BuildContext context) {
    final color = colorFromHex(tag.color);

    return Chip(
      avatar: tag.emoji.isNotEmpty
          ? Text(tag.emoji, style: const TextStyle(fontSize: 14))
          : Icon(Icons.label, size: 16, color: color),
      label: Text(tag.name, style: const TextStyle(fontSize: 11)),
      backgroundColor: color.withAlpha(51),
      side: BorderSide(color: color),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
