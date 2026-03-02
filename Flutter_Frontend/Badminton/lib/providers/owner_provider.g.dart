// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'owner_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ownerByIdHash() => r'a0ded3ab2f6229249172dd7e7787776fac1393a3';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider for owner by ID
///
/// Copied from [ownerById].
@ProviderFor(ownerById)
const ownerByIdProvider = OwnerByIdFamily();

/// Provider for owner by ID
///
/// Copied from [ownerById].
class OwnerByIdFamily extends Family<AsyncValue<Owner>> {
  /// Provider for owner by ID
  ///
  /// Copied from [ownerById].
  const OwnerByIdFamily();

  /// Provider for owner by ID
  ///
  /// Copied from [ownerById].
  OwnerByIdProvider call(int id) {
    return OwnerByIdProvider(id);
  }

  @override
  OwnerByIdProvider getProviderOverride(covariant OwnerByIdProvider provider) {
    return call(provider.id);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'ownerByIdProvider';
}

/// Provider for owner by ID
///
/// Copied from [ownerById].
class OwnerByIdProvider extends AutoDisposeFutureProvider<Owner> {
  /// Provider for owner by ID
  ///
  /// Copied from [ownerById].
  OwnerByIdProvider(int id)
    : this._internal(
        (ref) => ownerById(ref as OwnerByIdRef, id),
        from: ownerByIdProvider,
        name: r'ownerByIdProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$ownerByIdHash,
        dependencies: OwnerByIdFamily._dependencies,
        allTransitiveDependencies: OwnerByIdFamily._allTransitiveDependencies,
        id: id,
      );

  OwnerByIdProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.id,
  }) : super.internal();

  final int id;

  @override
  Override overrideWith(
    FutureOr<Owner> Function(OwnerByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: OwnerByIdProvider._internal(
        (ref) => create(ref as OwnerByIdRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        id: id,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Owner> createElement() {
    return _OwnerByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is OwnerByIdProvider && other.id == id;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, id.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin OwnerByIdRef on AutoDisposeFutureProviderRef<Owner> {
  /// The parameter `id` of this provider.
  int get id;
}

class _OwnerByIdProviderElement extends AutoDisposeFutureProviderElement<Owner>
    with OwnerByIdRef {
  _OwnerByIdProviderElement(super.provider);

  @override
  int get id => (origin as OwnerByIdProvider).id;
}

String _$activeOwnerHash() => r'e65c9d28770bb1d88721700290f88983170fa7a5';

/// Provider for the active owner
///
/// Copied from [activeOwner].
@ProviderFor(activeOwner)
final activeOwnerProvider = AutoDisposeFutureProvider<Owner?>.internal(
  activeOwner,
  name: r'activeOwnerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeOwnerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveOwnerRef = AutoDisposeFutureProviderRef<Owner?>;
String _$ownerListHash() => r'd015997cbf79d41a73e4d62fcc60d4cd10e0e841';

/// Provider for owner list state
///
/// Copied from [OwnerList].
@ProviderFor(OwnerList)
final ownerListProvider =
    AutoDisposeAsyncNotifierProvider<OwnerList, List<Owner>>.internal(
      OwnerList.new,
      name: r'ownerListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$ownerListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OwnerList = AutoDisposeAsyncNotifier<List<Owner>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
