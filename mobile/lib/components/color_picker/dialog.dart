import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../i18n/strings.g.dart';
import 'preset.dart';

class ColorPickerDialog extends HookWidget {
  const ColorPickerDialog({
    super.key,
    required this.presetColors,
    required this.value,
  });

  final List<Color> presetColors;
  final Color value;

  @override
  Widget build(BuildContext context) {
    final tabController = useTabController(initialLength: 2);
    final selectedColor = useState(value);

    return AlertDialog(
      title: Text(t.colorPicker.pickColor),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.sizeOf(context).height * 0.6,
        child: Column(
          children: [
            TabBar.secondary(
              controller: tabController,
              tabs: const [
                Tab(text: 'Preset', icon: Icon(Icons.palette)),
                Tab(text: 'Custom', icon: Icon(Icons.tune)),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  ColorPickerPresetTab(
                    presetColors: presetColors,
                    selectedColor: selectedColor.value,
                    setSelected: (color) => selectedColor.value = color,
                  ),
                  // Wrapping with SingleChildScrollView to avoid overflow when the keyboard is open
                  SingleChildScrollView(
                    child: HueRingPicker(
                      pickerColor: selectedColor.value,
                      onColorChanged: (color) {
                        selectedColor.value = color;
                      },
                      enableAlpha: false,
                      portraitOnly: true,
                      displayThumbColor: true,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(t.dialogs.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(selectedColor.value),
          child: Text(t.dialogs.confirm),
        ),
      ],
    );
  }
}
