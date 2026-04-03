import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

/// [SwitchListTile] form field for form_builder package.
///
/// This is a minimal wrapper that fits our existing requirement.
class FormBuilderSwitchListTile extends StatelessWidget {
  const FormBuilderSwitchListTile({
    super.key,
    required this.name,
    this.initialValue,
    this.title,
    this.secondary,
  });

  final String name;
  final bool? initialValue;

  final Widget? title;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    return FormBuilderField<bool>(
      name: name,
      initialValue: initialValue,
      builder: (field) {
        return SwitchListTile(
          value: field.value ?? false,
          onChanged: field.didChange,
          title: title,
          secondary: secondary,
        );
      },
    );
  }
}
