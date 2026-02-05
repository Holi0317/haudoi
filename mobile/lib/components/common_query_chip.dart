import 'package:flutter/material.dart';

class CommonQueryChip extends StatelessWidget {
  const CommonQueryChip({
    super.key,
    required this.label,
    required this.query,
    required this.onQueryChanged,
  });

  final String label;
  final String query;
  final ValueChanged<String?> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        onQueryChanged(query);
      },
    );
  }
}
