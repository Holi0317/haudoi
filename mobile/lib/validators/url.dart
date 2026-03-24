import 'package:reactive_forms/reactive_forms.dart';

class AbsoluteUrlValidator extends Validator<dynamic> {
  const AbsoluteUrlValidator() : super();

  @override
  Map<String, dynamic>? validate(AbstractControl<dynamic> control) {
    final value = control.value;

    if (value is! String) {
      return null;
    }

    final uri = Uri.tryParse(value);
    if (uri != null && uri.isAbsolute) {
      return null;
    }

    return {'absoluteUrl': true};
  }
}
