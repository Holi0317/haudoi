import 'package:flutter/cupertino.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// A hook that creates and returns a [GlobalKey] of type [T].
GlobalKey<T> useGlobalKey<T extends State<StatefulWidget>>() {
  return useMemoized(() => GlobalKey<T>());
}

/// Convenience hook for creating a [GlobalKey] of type [FormBuilderState].
GlobalKey<FormBuilderState> useFormBuilderKey() {
  return useGlobalKey<FormBuilderState>();
}
