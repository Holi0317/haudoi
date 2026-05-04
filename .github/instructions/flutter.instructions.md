---
name: "Dart / Flutter / mobile instruction"
applyTo: "mobile/**/*.dart"
---

## Dart 3 pattern matching

- Prefer Dart 3 pattern matching with `switch` expressions/statements and
  destructuring.
- For Freezed union/sealed types, prefer exhaustive pattern matching over legacy
  callback APIs.
- Do not use Freezed `.when`, `.maybeWhen`, `.map`, or `.maybeMap` unless
  explicitly requested.
- For Riverpod `AsyncValue`, prefer `switch` pattern matching over `.when`
  unless explicitly requested.

## Generated files

- Never manually edit generated files such as `*.g.dart` and `*.freezed.dart`.
- Make changes in the source file, not the generated output.
- If a change affects generated code or i18n output, remind the user to
  regenerate the files.
- Keep generated-file references and `part` directives consistent with the
  source file.

## JSON and API models

- Do not write one-off inline JSON parsing such as `json['field']`,
  `map['x'] as String`, or ad hoc `Map<String, dynamic>` conversion logic in
  widgets, providers, or services.
- Prefer dedicated typed models for JSON payloads using `freezed` +
  `json_serializable`.
- For new request/response shapes, create a Freezed model with
  `fromJson`/`toJson` instead of parsing inline.
- Keep JSON parsing at the model boundary; the rest of the code should work with
  typed objects, not raw maps.
- Only use raw `Map<String, dynamic>` values when required by an external API
  boundary, and convert them to typed models immediately.
