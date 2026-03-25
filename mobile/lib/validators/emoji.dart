import 'package:reactive_forms/reactive_forms.dart';

class EmojiValidator extends Validator<dynamic> {
  const EmojiValidator() : super();

  static final _regExp = RegExp(
    r'^(\p{Extended_Pictographic}|\p{Emoji_Component})+$',
    unicode: true,
  );

  @override
  Map<String, dynamic>? validate(AbstractControl<dynamic> control) {
    final value = control.value;

    if (value is! String) {
      return null;
    }

    if (_regExp.hasMatch(value)) {
      return null;
    }

    return {'emoji': true};
  }
}
