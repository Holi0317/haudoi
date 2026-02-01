// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(linkItem)
final linkItemProvider = LinkItemFamily._();

final class LinkItemProvider
    extends $FunctionalProvider<AsyncValue<Link>, Link, FutureOr<Link>>
    with $FutureModifier<Link>, $FutureProvider<Link> {
  LinkItemProvider._({
    required LinkItemFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'linkItemProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$linkItemHash();

  @override
  String toString() {
    return r'linkItemProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Link> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Link> create(Ref ref) {
    final argument = this.argument as int;
    return linkItem(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LinkItemProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$linkItemHash() => r'a4048c00d42f321aee8b9caf47774fe2f7b30ad8';

final class LinkItemFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Link>, int> {
  LinkItemFamily._()
    : super(
        retry: null,
        name: r'linkItemProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LinkItemProvider call(int id) => LinkItemProvider._(argument: id, from: this);

  @override
  String toString() => r'linkItemProvider';
}
