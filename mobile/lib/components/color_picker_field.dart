import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../i18n/strings.g.dart';

class ColorPickerField extends StatelessWidget {
  const ColorPickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.labelText,
    this.hintText = '#RRGGBB',
    this.presetColors = _defaultPresetColors,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String? labelText;
  final String hintText;
  final List<Color> presetColors;

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
    final normalized = _normalizeHexColor(value);
    final isValid = _isValidHexColor(normalized);
    final displayColor = _safeColorFromHex(
      normalized,
      fallback: presetColors.first,
    );

    return InkWell(
      onTap: () => _openPickerDialog(context),
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText ?? t.colorPicker.label,
          hintText: hintText,
          border: const OutlineInputBorder(),
          errorText: normalized.isEmpty || isValid
              ? null
              : t.colorPicker.invalidRgbHex,
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              normalized.isEmpty ? hintText : normalized,
              style: TextStyle(
                color: normalized.isEmpty
                    ? Theme.of(context).hintColor
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: displayColor,
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
    var selectedColor = _safeColorFromHex(
      _normalizeHexColor(value),
      fallback: presetColors.first,
    );

    final selectedHex = await showDialog<String>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(t.colorPicker.pickColor),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.colorPicker.presetColors,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final presetColor in presetColors)
                          _PresetColorButton(
                            color: presetColor,
                            selected:
                                _hexFromColor(presetColor) ==
                                _hexFromColor(selectedColor),
                            onPressed: () {
                              setDialogState(() {
                                selectedColor = presetColor;
                              });
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton.icon(
                  onPressed: () {
                    final random =
                        presetColors[Random().nextInt(presetColors.length)];
                    setDialogState(() {
                      selectedColor = random;
                    });
                  },
                  icon: const Icon(Icons.shuffle),
                  label: Text(t.colorPicker.randomize),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final custom = await _openCustomColorDialog(
                      context,
                      selectedColor,
                    );
                    if (custom == null) {
                      return;
                    }

                    setDialogState(() {
                      selectedColor = custom;
                    });
                  },
                  icon: const Icon(Icons.tune),
                  label: Text(t.colorPicker.custom),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(t.dialogs.cancel),
                ),
                FilledButton(
                  onPressed: () =>
                      Navigator.of(context).pop(_hexFromColor(selectedColor)),
                  child: Text(t.colorPicker.useColor),
                ),
              ],
            );
          },
        );
      },
    );

    if (selectedHex != null) {
      onChanged(selectedHex);
    }
  }

  Future<Color?> _openCustomColorDialog(
    BuildContext context,
    Color initialColor,
  ) async {
    var draftColor = initialColor;

    return showDialog<Color>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.colorPicker.pickCustomColor),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: draftColor,
              onColorChanged: (color) {
                draftColor = color;
              },
              enableAlpha: false,
              labelTypes: const [],
              portraitOnly: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t.dialogs.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(draftColor),
              child: Text(t.colorPicker.useColor),
            ),
          ],
        );
      },
    );
  }

  String _normalizeHexColor(String input) {
    var normalized = input.trim().toUpperCase();
    if (normalized.isEmpty) {
      return normalized;
    }

    if (!normalized.startsWith('#')) {
      normalized = '#$normalized';
    }

    return normalized;
  }

  bool _isValidHexColor(String hex) {
    return RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(hex);
  }

  Color _safeColorFromHex(String input, {required Color fallback}) {
    final normalized = _normalizeHexColor(input);
    if (!_isValidHexColor(normalized)) {
      return fallback;
    }

    final rgb = normalized.substring(1);
    return Color(int.parse('FF$rgb', radix: 16));
  }

  String _hexFromColor(Color color) {
    final rgb = color.toARGB32() & 0x00FFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }
}

class _PresetColorButton extends StatelessWidget {
  const _PresetColorButton({
    required this.color,
    required this.selected,
    required this.onPressed,
  });

  final Color color;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? Colors.black : Colors.black26,
            width: selected ? 2.5 : 1,
          ),
        ),
        child: selected
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : null,
      ),
    );
  }
}
