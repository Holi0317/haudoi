import 'dart:math';

import 'package:flutter/material.dart';

import '../../i18n/strings.g.dart';

/// Tab for picking from preset colors.
class ColorPickerPresetTab extends StatelessWidget {
  const ColorPickerPresetTab({
    super.key,
    required this.presetColors,
    required this.selectedColor,
    required this.setSelected,
  });

  final List<Color> presetColors;
  final Color selectedColor;
  final ValueSetter<Color> setSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8.0,
        children: [
          Text(
            t.colorPicker.presetColors,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final color in presetColors)
                _PresetColorButton(
                  color: color,
                  selected: selectedColor == color,
                  onPressed: () {
                    setSelected(color);
                  },
                ),
            ],
          ),
          TextButton.icon(
            onPressed: () {
              final random =
                  presetColors[Random().nextInt(presetColors.length)];
              setSelected(random);
            },
            icon: const Icon(Icons.shuffle),
            label: Text(t.colorPicker.randomize),
          ),
        ],
      ),
    );
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

  static const double size = 56;

  @override
  Widget build(BuildContext context) {
    final contrast = color.computeLuminance() > 0.5
        ? Colors.black87
        : Colors.white;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? contrast : Colors.black26,
            width: selected ? 2.5 : 1,
          ),
        ),
        child: selected
            ? Icon(Icons.check, size: size * 0.6, color: contrast)
            : null,
      ),
    );
  }
}
