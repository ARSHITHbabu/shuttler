// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coach_salary_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$coachSalaryListHash() => r'1b7eb5cee5aead71962791ed308e79d89c1f86b7';

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

/// See also [coachSalaryList].
@ProviderFor(coachSalaryList)
const coachSalaryListProvider = CoachSalaryListFamily();

/// See also [coachSalaryList].
class CoachSalaryListFamily extends Family<AsyncValue<List<CoachSalary>>> {
  /// See also [coachSalaryList].
  const CoachSalaryListFamily();

  /// See also [coachSalaryList].
  CoachSalaryListProvider call({String? month}) {
    return CoachSalaryListProvider(month: month);
  }

  @override
  CoachSalaryListProvider getProviderOverride(
    covariant CoachSalaryListProvider provider,
  ) {
    return call(month: provider.month);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'coachSalaryListProvider';
}

/// See also [coachSalaryList].
class CoachSalaryListProvider
    extends AutoDisposeFutureProvider<List<CoachSalary>> {
  /// See also [coachSalaryList].
  CoachSalaryListProvider({String? month})
    : this._internal(
        (ref) => coachSalaryList(ref as CoachSalaryListRef, month: month),
        from: coachSalaryListProvider,
        name: r'coachSalaryListProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$coachSalaryListHash,
        dependencies: CoachSalaryListFamily._dependencies,
        allTransitiveDependencies:
            CoachSalaryListFamily._allTransitiveDependencies,
        month: month,
      );

  CoachSalaryListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.month,
  }) : super.internal();

  final String? month;

  @override
  Override overrideWith(
    FutureOr<List<CoachSalary>> Function(CoachSalaryListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CoachSalaryListProvider._internal(
        (ref) => create(ref as CoachSalaryListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        month: month,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<CoachSalary>> createElement() {
    return _CoachSalaryListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CoachSalaryListProvider && other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CoachSalaryListRef on AutoDisposeFutureProviderRef<List<CoachSalary>> {
  /// The parameter `month` of this provider.
  String? get month;
}

class _CoachSalaryListProviderElement
    extends AutoDisposeFutureProviderElement<List<CoachSalary>>
    with CoachSalaryListRef {
  _CoachSalaryListProviderElement(super.provider);

  @override
  String? get month => (origin as CoachSalaryListProvider).month;
}

String _$coachMonthlySummaryHash() =>
    r'957f58b65ca6146a7baeeb93e81abacf6b54f193';

/// See also [coachMonthlySummary].
@ProviderFor(coachMonthlySummary)
const coachMonthlySummaryProvider = CoachMonthlySummaryFamily();

/// See also [coachMonthlySummary].
class CoachMonthlySummaryFamily
    extends Family<AsyncValue<List<CoachSalaryState>>> {
  /// See also [coachMonthlySummary].
  const CoachMonthlySummaryFamily();

  /// See also [coachMonthlySummary].
  CoachMonthlySummaryProvider call(String month) {
    return CoachMonthlySummaryProvider(month);
  }

  @override
  CoachMonthlySummaryProvider getProviderOverride(
    covariant CoachMonthlySummaryProvider provider,
  ) {
    return call(provider.month);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'coachMonthlySummaryProvider';
}

/// See also [coachMonthlySummary].
class CoachMonthlySummaryProvider
    extends AutoDisposeFutureProvider<List<CoachSalaryState>> {
  /// See also [coachMonthlySummary].
  CoachMonthlySummaryProvider(String month)
    : this._internal(
        (ref) => coachMonthlySummary(ref as CoachMonthlySummaryRef, month),
        from: coachMonthlySummaryProvider,
        name: r'coachMonthlySummaryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$coachMonthlySummaryHash,
        dependencies: CoachMonthlySummaryFamily._dependencies,
        allTransitiveDependencies:
            CoachMonthlySummaryFamily._allTransitiveDependencies,
        month: month,
      );

  CoachMonthlySummaryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.month,
  }) : super.internal();

  final String month;

  @override
  Override overrideWith(
    FutureOr<List<CoachSalaryState>> Function(CoachMonthlySummaryRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CoachMonthlySummaryProvider._internal(
        (ref) => create(ref as CoachMonthlySummaryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        month: month,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<CoachSalaryState>> createElement() {
    return _CoachMonthlySummaryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CoachMonthlySummaryProvider && other.month == month;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, month.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CoachMonthlySummaryRef
    on AutoDisposeFutureProviderRef<List<CoachSalaryState>> {
  /// The parameter `month` of this provider.
  String get month;
}

class _CoachMonthlySummaryProviderElement
    extends AutoDisposeFutureProviderElement<List<CoachSalaryState>>
    with CoachMonthlySummaryRef {
  _CoachMonthlySummaryProviderElement(super.provider);

  @override
  String get month => (origin as CoachMonthlySummaryProvider).month;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
