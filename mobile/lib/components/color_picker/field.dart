import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'dialog.dart';

class ColorPickerField extends HookWidget {
  const ColorPickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.decoration,
    this.presetColors = _defaultPresetColors,
  });

  final Color value;
  final ValueChanged<Color> onChanged;
  final InputDecoration? decoration;
  final List<Color> presetColors;

  /// Default preset colors
  static const List<Color> _defaultPresetColors = [
    Color(0xFFE53935),
    Color(0xFFFB8C00),
    Color(0xFFFDD835),
    Color(0xFF43A047),
    Color(0xFF00ACC1),
    Color(0xFF1E88E5),
    Color(0xFF3949AB),
    Color(0xFF8E24AA),
    Color(0xFFD81B60),
    Color(0xFF6D4C41),
    Color(0xFF546E7A),
    Color(0xFF424242),
  ];

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openPickerDialog(context),
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: decoration ?? const InputDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              colorToHex(value, enableAlpha: false, includeHashSign: true),
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: value,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.black26),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPickerDialog(BuildContext context) async {
    final selectedHex = await showDialog<Color>(
      context: context,
      builder: (context) {
        return ColorPickerDialog(presetColors: presetColors, value: value);
      },
    );

    if (selectedHex != null) {
      onChanged(selectedHex);
    }
  }
}
