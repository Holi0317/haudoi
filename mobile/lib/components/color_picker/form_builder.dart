import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'field.dart';

/// Bridge for using [ColorPickerField] with [FormBuilder].
class FormBuilderColorPickerField extends StatelessWidget {
  const FormBuilderColorPickerField({
    super.key,
    required this.name,
    this.initialValue,
    this.decoration,
  });

  final String name;
  final Color? initialValue;

  final InputDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<Color>(
      name: name,
      initialValue: initialValue,
      builder: (field) {
        return ColorPickerField(
          value: field.value ?? const Color(0x00000000),
          onChanged: field.didChange,
          decoration: decoration,
        );
      },
    );
  }
}
